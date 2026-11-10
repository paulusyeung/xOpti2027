using Npgsql;
using static xOpti.Migrations.SchemaMapper;

namespace xOpti.Migrations;

public sealed record TableResult(string SourceTable, string? TargetTable, string Status, long Rows, string? Detail);

public sealed class TransformReport
{
    public List<TableResult> Tables { get; } = [];
    public List<(string Kind, string Table, string Detail, int Count)> Anomalies { get; } = [];
    public List<string> SequenceActions { get; } = [];
    public bool AllOk => Tables.All(t => t.Status is "upserted" or "loaded" or "skipped-populated" or "skipped-empty-target");
}

/// <summary>
/// Set-based idempotent transforms: legacy staging (text) into the normalized public schema
/// using generated INSERT ... SELECT ... ON CONFLICT DO UPDATE statements, master data first,
/// then stock, then transactions, then summaries. Failures roll back per table (savepoint) and
/// are reported instead of aborting the run.
/// </summary>
public sealed class TransformRunner(MigrationConfig config)
{
    public const string SyntheticColumn = "is_synthetic";

    /// <summary>Transform order: master data, stock/opening balances, transactions, summaries.</summary>
    public static readonly string[][] OrderGroups =
    [
        [
            "add", "taxmethod", "sex", "maritalstatus", "salutation", "security", "payper", "payperiod",
            "paymentmethods", "costingmethod", "invtmethod", "jobnature", "jobstatus", "jobtitle",
            "salesorderstatus", "zdefaultclass", "zdefaultremarks", "footer", "remarks", "country",
            "province", "city", "branch", "department", "class", "category", "brand", "material",
            "staff", "supplier", "suppliercontactperson", "doctor", "customer",
        ],
        [
            "preference", "preftxnumber", "customeraccounts", "customermedical", "customerpreslens",
            "customerprescontact", "inventory", "retailprice", "wholesaleprice", "rebuildcost",
            "barcodepool", "invtlotrecord", "branchinventory", "staffhistory", "invtstheader",
            "invtstdetails", "invtstimport", "invtststatus", "utilchecklog", "pasteerrors",
        ],
        [
            "txheader", "txdetails", "txpayment", "txsaleperson", "txsorderlens", "txsorderframe",
            "txsordercont", "txsorderadd", "txsorderextra",
        ],
        [
            "invtsummary", "categorysummary", "classsummary", "deptsummary", "suppliersummary",
            "paymentsummary", "branchsummary",
        ],
    ];

    public static IReadOnlyList<string> TransactionChildren = ["txdetails", "txpayment", "txsaleperson",
        "txsorderlens", "txsorderframe", "txsordercont", "txsorderadd", "txsorderextra"];

    public async Task<TransformReport> RunAsync(
        NpgsqlConnection conn, long runId, IReadOnlyList<StagingTable> staged,
        IReadOnlyDictionary<string, TargetTable> catalog, CancellationToken ct = default)
    {
        var report = new TransformReport();
        await EnsureSyntheticColumnAsync(conn, ct);

        var maps = new Dictionary<string, TableMap>(StringComparer.OrdinalIgnoreCase);
        foreach (var source in staged)
        {
            var target = FindTarget(source, catalog);
            if (target is null)
            {
                report.Tables.Add(new TableResult(source.Name, null, "no-target", 0,
                    "no target table matches this staged source table"));
                continue;
            }
            maps[source.CanonicalName] = Build(source, target);
        }

        var remaining = new HashSet<string>(staged.Select(s => s.CanonicalName), StringComparer.OrdinalIgnoreCase);
        foreach (var group in OrderGroups)
        {
            foreach (var name in group)
            {
                if (!remaining.Remove(name) || !maps.TryGetValue(name, out var map))
                    continue;
                await TransformTableAsync(conn, map, report, ct);

                // Synthetic headers for orphaned children are created right after the header load.
                if (name == "txheader")
                {
                    var headerOk = report.Tables.LastOrDefault(t => t.SourceTable == "txheader")?.Status
                                   is "upserted" or "loaded";
                    if (headerOk)
                    {
                        Console.Write("  synthetic stub headers for orphaned children: ");
                        var t0 = DateTime.UtcNow;
                        await CreateStubHeadersAsync(conn, runId, staged, report, ct);
                        Console.WriteLine($"done [{(DateTime.UtcNow - t0).TotalSeconds:F1}s]");
                    }
                    else
                    {
                        Console.WriteLine("  skipping synthetic stubs: txheader transform failed/skipped");
                        report.Anomalies.Add(("missing_header_stub", "txheader", "skipped: txheader transform failed", 0));
                    }
                }
            }
        }

        // Anything not in an explicit group (schema drift) lands last, best effort.
        foreach (var name in remaining.Where(maps.ContainsKey))
            await TransformTableAsync(conn, maps[name], report, ct);

        await AdvanceSequencesAsync(conn, report, ct);
        await AdvanceControlNumbersAsync(conn, report, ct);
        return report;
    }

    /// <summary>tx_header must carry the synthetic flag used by orphan handling (task 4.4).</summary>
    public static async Task EnsureSyntheticColumnAsync(NpgsqlConnection conn, CancellationToken ct)
    {
        await using var cmd = conn.CreateCommand();
        cmd.CommandText = "ALTER TABLE public.tx_header ADD COLUMN IF NOT EXISTS " + SyntheticColumn +
                          " boolean NOT NULL DEFAULT FALSE;";
        await cmd.ExecuteNonQueryAsync(ct);
    }

    private async Task TransformTableAsync(
        NpgsqlConnection conn, TableMap map, TransformReport report, CancellationToken ct)
    {
        var savepoint = "sp_" + NameNormalizer.Canonical(map.Source.Name);
        await using (var sp = conn.CreateCommand())
        {
            sp.CommandText = "SAVEPOINT " + savepoint + ";";
            await sp.ExecuteNonQueryAsync(ct);
        }

        try
        {
            var started = DateTime.UtcNow;
            Console.Write($"  {map.Source.Name} -> {map.Target.Name}: ");
            long rows;
            string status;

            // Bulk-load trick, transaction-safe: secondary indexes are dropped and rebuilt inside
            // the same savepoint as the load, so a failure rolls the schema state back too.
            List<string> indexDefs = [];
            var stagedRows = await ScalarLongAsync(conn,
                $"SELECT count(*) FROM {SchemaMapper.Quote(config.LegacySchema)}." +
                $"{SchemaMapper.Quote(map.Source.Name)};", ct);
            if (stagedRows >= BulkIndexDropThreshold)
                indexDefs = await DropSecondaryIndexesAsync(conn, map.Target.Name, ct);
            if (map.HasPrimaryKey)
            {
                await using var cmd = conn.CreateCommand();
                cmd.CommandText = BuildUpsert(map, config.LegacySchema);
                cmd.CommandTimeout = 900;
                rows = await cmd.ExecuteNonQueryAsync(ct);
                status = "upserted";
            }
            else
            {
                await using var count = conn.CreateCommand();
                count.CommandText = "SELECT count(*) FROM public." + Quote(map.Target.Name) + ";";
                var existing = Convert.ToInt64(await count.ExecuteScalarAsync(ct) ?? 0L);
                if (existing > 0)
                {
                    rows = 0;
                    status = "skipped-populated"; // no primary key to upsert against; existing rows retained
                }
                else
                {
                    await using var cmd = conn.CreateCommand();
                    cmd.CommandText = BuildInsert(map, config.LegacySchema);
                    cmd.CommandTimeout = 900;
                    rows = await cmd.ExecuteNonQueryAsync(ct);
                    status = "loaded";
                }
            }

            if (indexDefs.Count > 0)
            {
                Console.Write($"rebuilding {indexDefs.Count} indexes... ");
                foreach (var def in indexDefs)
                {
                    await using var rec = conn.CreateCommand();
                    rec.CommandText = def + ";";
                    rec.CommandTimeout = 1800;
                    await rec.ExecuteNonQueryAsync(ct);
                }
            }

            await using var release = conn.CreateCommand();
            release.CommandText = "RELEASE SAVEPOINT " + savepoint + ";";
            await release.ExecuteNonQueryAsync(ct);

            var elapsed = (DateTime.UtcNow - started).TotalSeconds;
            Console.WriteLine($"{status} {rows:N0} rows [{elapsed:F1}s]");
            report.Tables.Add(new TableResult(map.Source.Name, map.Target.Name, status, rows, null));
        }
        catch (Exception ex) when (ex is not OperationCanceledException)
        {
            await using var rollback = conn.CreateCommand();
            rollback.CommandText = "ROLLBACK TO SAVEPOINT " + savepoint + ";";
            await rollback.ExecuteNonQueryAsync(ct);
            Console.WriteLine($"FAILED: {ex.Message}");
            report.Tables.Add(new TableResult(map.Source.Name, map.Target.Name, "failed", 0, ex.Message));
        }
    }

    /// <summary>Idempotent set-based upsert with legacy primary keys preserved.</summary>
    public static string BuildUpsert(TableMap map, string legacySchema)
    {
        if (map.Columns.Count == 0)
            throw new MigrationException($"Table '{map.Target.Name}' has no mappable staging columns.");

        var insertCols = map.Columns.Select(c => Quote(c.Target.Name));
        var selectCols = map.Columns.Select(c => c.SelectExpression + " AS " + Quote(c.Target.Name));
        var pkExprs = map.Target.PrimaryKey.Select(name =>
            map.Columns.FirstOrDefault(c => c.Target.Name == name)?.SelectExpression
            ?? throw new MigrationException(
                $"Table '{map.Target.Name}': primary key column '{name}' is not mapped from staging."));

        var inner = "SELECT DISTINCT ON (" + string.Join(", ", pkExprs) + ") " + string.Join(", ", selectCols) +
                    " FROM " + Quote(legacySchema) + "." + Quote(map.Source.Name) + " e" +
                    " ORDER BY " + string.Join(", ", pkExprs);

        var pkSet = new HashSet<string>(map.Target.PrimaryKey, StringComparer.Ordinal);
        var nonPk = map.Columns.Where(c => !pkSet.Contains(c.Target.Name)).ToList();

        var conflict = "ON CONFLICT (" + string.Join(", ", map.Target.PrimaryKey.Select(Quote)) + ")";
        var action = nonPk.Count > 0
            ? " DO UPDATE SET " + string.Join(", ",
                nonPk.Select(c => Quote(c.Target.Name) + " = EXCLUDED." + Quote(c.Target.Name)))
            : " DO NOTHING";

        return "INSERT INTO public." + Quote(map.Target.Name) + " (" + string.Join(", ", insertCols) + ")\n" +
               "SELECT * FROM (" + inner + ") d\n" + conflict + action + ";";
    }

    /// <summary>Plain set-based INSERT for staging tables whose target has no primary key.</summary>
    public static string BuildInsert(TableMap map, string legacySchema)
    {
        var insertCols = map.Columns.Select(c => Quote(c.Target.Name));
        var selectCols = map.Columns.Select(c => c.SelectExpression);
        return "INSERT INTO public." + Quote(map.Target.Name) + " (" + string.Join(", ", insertCols) + ")\n" +
               "SELECT " + string.Join(", ", selectCols) + " FROM " +
               Quote(legacySchema) + "." + Quote(map.Source.Name) + " e;";
    }

    /// <summary>
    /// Children referencing a txnumber with no header get flagged synthetic stub headers so foreign
    /// integrity and totals remain auditable (478 TxSalePerson / 6 TxDetails orphans).
    /// </summary>
    private async Task CreateStubHeadersAsync(
        NpgsqlConnection conn, long runId, IReadOnlyList<StagingTable> staged,
        TransformReport report, CancellationToken ct)
    {
        var header = staged.FirstOrDefault(t => t.CanonicalName == "txheader");
        var headerTx = header?.Columns.FirstOrDefault(c => c.CanonicalName == "txnumber");
        if (header is null || headerTx is null)
            return;

        var children = staged
            .Where(t => t.CanonicalName != "txheader"
                        && TransactionChildren.Contains(t.CanonicalName)
                        && t.Columns.Any(c => c.CanonicalName == "txnumber"))
            .ToList();
        if (children.Count == 0)
            return;

        var unions = children.Select(child =>
        {
            var txnum = child.Columns.First(c => c.CanonicalName == "txnumber").Name;
            var ctrl = child.Columns.FirstOrDefault(c => c.CanonicalName == "controlnumber")?.Name;
            var date = child.Columns.FirstOrDefault(c => c.CanonicalName == "dateofentry")?.Name;
            var ctrlExpr = ctrl is null ? "NULL::text" : "NULLIF(BTRIM(" + Quote(ctrl) + "), '')";
            var dateExpr = date is null
                ? "NULL::timestamp"
                : "CASE WHEN " + Quote(date) + " ~ '^[0-9]{4}-' THEN LEFT(" + Quote(date) + ", 19)::timestamp ELSE NULL END";
            return "SELECT BTRIM(" + Quote(txnum) + ") AS txnumber, " + ctrlExpr + " AS control_number, " +
                   dateExpr + " AS date_of_entry FROM " + Quote(config.LegacySchema) + "." + Quote(child.Name);
        });

        // NOTE: use an explicit LEFT JOIN anti-pattern, not NOT IN: the planner turns NOT IN
        // into a per-row SubPlan (1.2M rows x 547K rows = catastrophic).
        var headers = "headers AS (SELECT DISTINCT UPPER(" + Quote(headerTx.Name) + ") AS k FROM " +
            Quote(config.LegacySchema) + "." + Quote(header.Name) +
            " WHERE " + Quote(headerTx.Name) + " IS NOT NULL),";
        var missing = "child AS (" + string.Join(" UNION ALL ", unions) + "), " + headers +
            "missing AS (" +
            "SELECT c.txnumber, MAX(c.control_number) AS control_number, MIN(c.date_of_entry) AS date_of_entry " +
            "FROM child c LEFT JOIN headers h ON UPPER(c.txnumber) = h.k " +
            "WHERE c.txnumber IS NOT NULL AND c.txnumber <> '' AND h.k IS NULL " +
            "GROUP BY UPPER(c.txnumber), c.txnumber)";

        await using (var insert = conn.CreateCommand())
        {
            insert.CommandText =
                "WITH " + missing + "\n" +
                "INSERT INTO public.tx_header (control_number, tx_type, tx_number, date_of_entry, " + SyntheticColumn + ")\n" +
                "SELECT COALESCE(m.control_number, ''), UPPER(LEFT(m.txnumber, 2)), m.txnumber," +
                " COALESCE(m.date_of_entry, TIMESTAMP '1899-12-30 00:00:00'), TRUE\n" +
                "FROM (SELECT MIN(txnumber) AS txnumber, MAX(control_number) AS control_number," +
                " MIN(date_of_entry) AS date_of_entry FROM missing GROUP BY UPPER(txnumber)) m\n" +
                "ON CONFLICT (tx_number) DO NOTHING;";
            insert.CommandTimeout = 900;
            report.Anomalies.Add(("missing_header_stub", "txheader", "synthetic headers inserted", insert.ExecuteNonQuery()));
        }

        await using (var sample = conn.CreateCommand())
        {
            sample.CommandText =
                "WITH " + missing + "\n" +
                "INSERT INTO " + Quote(config.MigrationSchema) + ".anomaly_quarantine (run_id, source_table, pk, kind, detail)\n" +
                "SELECT " + runId + ", 'txheader', t.txnumber, 'missing_header_stub'," +
                " 'orphaned child rows reference this missing transaction header'\n" +
                "FROM (SELECT DISTINCT txnumber FROM missing LIMIT 1000) t;";
            sample.CommandTimeout = 900;
            await sample.ExecuteNonQueryAsync(ct);
        }

        await using var count = conn.CreateCommand();
        count.CommandText = "SELECT count(*) FROM public.tx_header WHERE " + SyntheticColumn + ";";
        var stubTotal = Convert.ToInt64(await count.ExecuteScalarAsync(ct) ?? 0L);
        report.Anomalies.Add(("missing_header_total", "tx_header", "synthetic headers present", (int)stubTotal));
    }

    /// <summary>Advance every public-schema sequence to at least the migrated maximum id (task 6.1).</summary>
    public static async Task AdvanceSequencesAsync(NpgsqlConnection conn, TransformReport report, CancellationToken ct)
    {
        var sequences = new List<(string Table, string Column, string Sequence)>();
        await using (var cmd = conn.CreateCommand())
        {
            cmd.CommandText = """
                SELECT t.relname, a.attname, s.oid::regclass::text
                FROM pg_class s
                JOIN pg_depend d ON d.objid = s.oid AND d.deptype = 'a'
                JOIN pg_class t ON t.oid = d.refobjid AND t.relkind = 'r'
                JOIN pg_attribute a ON a.attrelid = t.oid AND a.attnum = d.refobjsubid
                JOIN pg_namespace n ON n.oid = t.relnamespace
                WHERE s.relkind = 'S' AND n.nspname = 'public'
                ORDER BY t.relname;
                """;
            await using var reader = await cmd.ExecuteReaderAsync(ct);
            while (await reader.ReadAsync(ct))
                sequences.Add((reader.GetString(0), reader.GetString(1), reader.GetString(2)));
        }

        foreach (var (table, column, sequence) in sequences)
        {
            await using var cmd = conn.CreateCommand();
            var seqLiteral = "'" + sequence.Replace("'", "''") + "'";
            cmd.CommandText = "SELECT setval(" + seqLiteral + "::regclass," +
                              " GREATEST(COALESCE((SELECT MAX(" + Quote(column) + ") FROM public." + Quote(table) + "), 1), 1));";
            await cmd.ExecuteScalarAsync(ct);
            report.SequenceActions.Add($"setval {sequence} -> max(public.{table}.{column})");
        }
    }

    /// <summary>
    /// Advance Preference and PrefTxNumber control numbers for alphanumeric transaction prefixes
    /// by parsing numeric suffixes with a regular expression (task 6.2).
    /// </summary>
    private async Task AdvanceControlNumbersAsync(NpgsqlConnection conn, TransformReport report, CancellationToken ct)
    {
        var stagedNames = await GetStagedTableNamesAsync(conn, ct);
        if (!stagedNames.Contains("txheader"))
        {
            report.SequenceActions.Add("pref advancement skipped: legacy.txheader not staged");
            return;
        }

        // Max derived from the FINAL target state (including synthetic stub numbers), not just
        // the staged headers, so counters also clear orphan-driven synthetic transaction numbers.
        const string suffix = "(SUBSTRING(BTRIM(e.tx_number) FROM '([0-9]+)$'))::numeric(19)";
        await using (var cmd = conn.CreateCommand())
        {
            cmd.CommandText =
                "WITH src AS (" +
                " SELECT UPPER(LEFT(BTRIM(e.tx_number), 2)) AS pfx, MAX(" + suffix + ") AS mx" +
                " FROM public.tx_header e" +
                " WHERE e.tx_number ~ '[0-9]+$' GROUP BY 1)" +
                " UPDATE public.pref_tx_number p" +
                " SET tx_next_number = LEAST(GREATEST(p.tx_next_number::bigint, FLOOR(s.mx) + 1), 2147483647)::integer" +
                " FROM src s WHERE s.pfx = BTRIM(p.tx_prefix) AND s.mx >= p.tx_next_number;";
            var updated = await cmd.ExecuteNonQueryAsync(ct);
            report.SequenceActions.Add($"pref_tx_number rows advanced: {updated}");
        }

        var invCte = stagedNames.Contains("invtstheader")
            ? "inv AS (SELECT COALESCE(MAX(" + Quote("id") + ")::numeric, 0) AS m FROM " + Quote(config.LegacySchema) + ".invtstheader)"
            : "inv AS (SELECT 0 AS m)";

        await using (var cmd = conn.CreateCommand())
        {
            cmd.CommandText =
                "WITH mx AS (" +
                " SELECT COALESCE(MAX(CASE WHEN UPPER(LEFT(BTRIM(e.tx_number),2))='RC' THEN " + suffix + " END), 0) AS rc," +
                "        COALESCE(MAX(CASE WHEN UPPER(LEFT(BTRIM(e.tx_number),2))='SA' THEN " + suffix + " END), 0) AS sa" +
                " FROM public.tx_header e WHERE e.tx_number ~ '[0-9]+$')," +
                " " + invCte +
                " UPDATE public.preference p SET" +
                " next_invoice_number = GREATEST(p.next_invoice_number, FLOOR(mx.rc) + 1)::integer," +
                " next_sales_order_number = GREATEST(p.next_sales_order_number, FLOOR(mx.sa) + 1)::integer," +
                " next_invt_control_number = GREATEST(p.next_invt_control_number, inv.m + 1)::integer" +
                " FROM mx, inv;";
            await cmd.ExecuteNonQueryAsync(ct);
            report.SequenceActions.Add("preference counters advanced (invoice RC, sales order SA, inventory control)");
        }
    }

    public static async Task<HashSet<string>> GetStagedTableNamesAsync(
        NpgsqlConnection conn, CancellationToken ct, string schema = "legacy")
    {
        var names = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        await using var cmd = conn.CreateCommand();
        cmd.CommandText = "SELECT table_name FROM information_schema.tables WHERE table_schema = :schema AND table_type = 'BASE TABLE';";
        cmd.Parameters.AddWithValue("schema", schema);
        await using var reader = await cmd.ExecuteReaderAsync(ct);
        while (await reader.ReadAsync(ct))
            names.Add(reader.GetString(0));
        return names;
    }

    /// <summary>Tables at or above this staged row count get secondary indexes dropped/rebuilt around the load.</summary>
    public const int BulkIndexDropThreshold = 50_000;

    private static async Task<long> ScalarLongAsync(NpgsqlConnection conn, string sql, CancellationToken ct)
    {
        await using var cmd = conn.CreateCommand();
        cmd.CommandText = sql;
        cmd.CommandTimeout = 300;
        return Convert.ToInt64(await cmd.ExecuteScalarAsync(ct) ?? 0L);
    }

    /// <summary>
    /// Returns and drops the non-constraint secondary indexes of a target table so the bulk load
    /// does not maintain them row by row. Safe because everything runs inside the caller's
    /// transaction/savepoint: a failure restores both data and index definitions.
    /// </summary>
    public static async Task<List<string>> DropSecondaryIndexesAsync(NpgsqlConnection conn, string table, CancellationToken ct)
    {
        var definitions = new List<string>();
        var names = new List<string>();
        await using (var cmd = conn.CreateCommand())
        {
            cmd.CommandText = """
                SELECT i.indexname, i.indexdef
                FROM pg_indexes i
                JOIN pg_class ci ON ci.relname = i.indexname AND ci.relkind = 'i'
                JOIN pg_index x ON x.indexrelid = ci.oid
                WHERE i.schemaname = 'public' AND i.tablename = :table
                  AND NOT x.indisprimary
                  AND NOT EXISTS (SELECT 1 FROM pg_constraint con WHERE con.conindid = ci.oid);
                """;
            cmd.Parameters.AddWithValue("table", table);
            await using var reader = await cmd.ExecuteReaderAsync(ct);
            while (await reader.ReadAsync(ct))
            {
                names.Add(reader.GetString(0));
                definitions.Add(reader.GetString(1));
            }
        }

        foreach (var name in names)
        {
            await using var drop = conn.CreateCommand();
            drop.CommandText = "DROP INDEX public." + Quote(name) + ";";
            await drop.ExecuteNonQueryAsync(ct);
        }

        return definitions;
    }
}



