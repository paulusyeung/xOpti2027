using System.Globalization;
using System.Text;
using Npgsql;

namespace xOpti.Migrations;

public sealed record CheckRow(string Check, string Scope, string? Expected, string? Actual, string Status, string? Detail);

public sealed class ReconcileReport
{
    public List<CheckRow> Rows { get; } = [];
    public bool Passed => !Rows.Any(r => r.Status == "FAIL");
    public int FailCount => Rows.Count(r => r.Status == "FAIL");
}

internal sealed record AggregateCheck(
    string Label,
    string LegacyTable,
    string LegacyKey,
    string LegacyValue,
    string TargetTable,
    string TargetKey,
    string TargetValue,
    string? TargetFilter = null);

/// <summary>
/// Read-only reconciliation: row counts, financial aggregates, inventory quantity/cost by SKU and
/// lot, order status counts, sequences, and control numbers, compared between the staged legacy
/// snapshot and the migrated target within a configured money tolerance.
/// </summary>
public sealed class ReconcileRunner(MigrationConfig config)
{
    private const int SampleLimit = 50;
    private string Tol => config.Tolerance.ToString("0.############", CultureInfo.InvariantCulture);

    public async Task<ReconcileReport> RunAsync(
        NpgsqlConnection conn, IReadOnlyDictionary<string, TargetTable> catalog, CancellationToken ct = default)
    {
        var report = new ReconcileReport();
        // Real MDB types matter for expression parity with the transform (e.g. REAL line numbers
        // are rounded on load); read them from the recorded staging metadata, not information_schema.
        var staged = await ExtractionRunner.ReadStagedMetadataAsync(conn, config.LegacySchema, ct);
        if (staged.Count == 0)
        {
            report.Rows.Add(new CheckRow("staging", "legacy schema", "tables", "0", "FAIL",
                "nothing staged; run extract first"));
            return report;
        }

        var pairs = staged
            .Select(s => (Source: s, Target: SchemaMapper.FindTarget(s, catalog)))
            .Where(p => p.Target is not null)
            .Select(p => (p.Source, Target: p.Target!))
            .ToList();

        await CountChecksAsync(pairs, conn, report, ct);
        await TargetOnlyChecksAsync(pairs, conn, report, ct);
        await AggregateChecksAsync(conn, report, ct);
        await InventoryChecksAsync(conn, report, ct);
        await SequenceChecksAsync(conn, report, ct);
        await ControlNumberChecksAsync(conn, report, ct);
        await AnomalySummaryAsync(conn, report, ct);
        return report;
    }

    public static async Task<List<StagingTable>> LoadStagedTablesAsync(NpgsqlConnection conn, CancellationToken ct)
    {
        var byTable = new SortedDictionary<string, List<StagingColumn>>(StringComparer.Ordinal);
        await using var cmd = conn.CreateCommand();
        cmd.CommandText = """
            SELECT t.table_name, c.column_name
            FROM information_schema.tables t
            JOIN information_schema.columns c USING (table_schema, table_name)
            WHERE t.table_schema = 'legacy' AND t.table_type = 'BASE TABLE'
            ORDER BY t.table_name, c.ordinal_position;
            """;
        await using var reader = await cmd.ExecuteReaderAsync(ct);
        while (await reader.ReadAsync(ct))
        {
            if (!byTable.TryGetValue(reader.GetString(0), out var cols))
                byTable[reader.GetString(0)] = cols = [];
            cols.Add(new StagingColumn(reader.GetString(1), "text"));
        }

        return byTable.Select(kv => new StagingTable(kv.Key, kv.Value)).ToList();
    }

    private async Task CountChecksAsync(
        List<(StagingTable Source, TargetTable Target)> pairs,
        NpgsqlConnection conn, ReconcileReport report, CancellationToken ct)
    {
        foreach (var (source, target) in pairs)
        {
            var legacy = await ScalarLongAsync(conn, $"SELECT count(*) FROM legacy.{Q(source.Name)};", ct);
            var actual = await ScalarLongAsync(conn, $"SELECT count(*) FROM public.{Q(target.Name)};", ct);

            // tx_header may legitimately hold synthetic stub rows for orphaned children.
            var offset = target.Name == "tx_header"
                ? await ScalarLongAsync(conn,
                    $"SELECT count(*) FROM public.tx_header WHERE {TransformRunner.SyntheticColumn};", ct)
                : 0;

            var status = legacy + offset == actual ? "PASS" : "FAIL";
            report.Rows.Add(new CheckRow("row-count", $"{source.Name} -> {target.Name}",
                legacy.ToString(CultureInfo.InvariantCulture),
                (actual - offset).ToString(CultureInfo.InvariantCulture) + (offset > 0 ? $" (+{offset} synthetic)" : ""),
                status, status == "PASS" ? null : $"difference {actual - legacy}"));
        }
    }

    /// <summary>Target rows with no staged legacy counterpart (previously-reported target-side defects).</summary>
    private async Task TargetOnlyChecksAsync(
        List<(StagingTable Source, TargetTable Target)> pairs,
        NpgsqlConnection conn, ReconcileReport report, CancellationToken ct)
    {
        foreach (var (source, target) in pairs)
        {
            if (target.PrimaryKey.Count == 0)
                continue;

            var map = SchemaMapper.Build(source, target);
            var pkExprs = target.PrimaryKey
                .Select(name => map.Columns.FirstOrDefault(c => c.Target.Name == name)?.SelectExpression)
                .ToList();
            if (pkExprs.Any(e => e is null))
                continue;

            // NOT EXISTS on primary-key equality: hash-antijoin-able (IS NOT DISTINCT FROM is
            // not hashable and NOT IN becomes a per-row SubPlan on multi-million row tables),
            // and it does not depend on any non-key staging column being non-null.
            var exists = string.Join(" AND ", target.PrimaryKey.Select((pk, i) =>
                $"({pkExprs[i]}) = tgt.{Q(pk)}"));
            var syntheticFilter = target.Name == "tx_header" && await ColumnExistsAsync(conn, "public", "tx_header", TransformRunner.SyntheticColumn, ct)
                ? $"WHERE NOT tgt.{TransformRunner.SyntheticColumn} "
                : "WHERE true ";

            var count = await ScalarLongAsync(conn,
                $"SELECT count(*) FROM public.{Q(target.Name)} tgt {syntheticFilter}" +
                $"AND NOT EXISTS (SELECT 1 FROM legacy.{Q(source.Name)} e WHERE {exists});", ct);
            if (count > 0)
                report.Rows.Add(new CheckRow("target-only-rows", target.Name, "0",
                    count.ToString(CultureInfo.InvariantCulture), "FAIL",
                    "target rows have no staged legacy counterpart; delete or investigate (exception workbook)"));
        }
    }

    /// <summary>True when public.tx_header carries the synthetic flag (created by transform).</summary>
    private static async Task<bool> HasSyntheticColumnAsync(NpgsqlConnection conn, CancellationToken ct)
    {
        await using var cmd = conn.CreateCommand();
        cmd.CommandText = "SELECT count(*) FROM information_schema.columns WHERE table_schema='public' AND table_name='tx_header' AND column_name=@c;";
        cmd.Parameters.AddWithValue("c", TransformRunner.SyntheticColumn);
        return Convert.ToInt64(await cmd.ExecuteScalarAsync(ct) ?? 0L) > 0;
    }

    private async Task AggregateChecksAsync(NpgsqlConnection conn, ReconcileReport report, CancellationToken ct)
    {
        var h = "NOT " + TransformRunner.SyntheticColumn;
        var headerFilter = await HasSyntheticColumnAsync(conn, ct) ? h : null;
        var stagedNames = await TransformRunner.GetStagedTableNamesAsync(conn, ct, config.LegacySchema);

        var checks = new AggregateCheck[]
        {
            new("tx_header.total_amount by type", "txheader", "BTRIM(txtype)",
                "SUM(NULLIF(BTRIM(totalamount),'')::numeric)", "tx_header", "tx_type",
                "COALESCE(SUM(total_amount),0)", headerFilter),
            new("tx_header.gross_sale by type", "txheader", "BTRIM(txtype)",
                "SUM(NULLIF(BTRIM(grosssale),'')::numeric)", "tx_header", "tx_type",
                "COALESCE(SUM(gross_sale),0)", headerFilter),
            new("tx_header.tax by type", "txheader", "BTRIM(txtype)",
                "SUM(COALESCE(NULLIF(BTRIM(taxa),'')::numeric,0)+COALESCE(NULLIF(BTRIM(taxb),'')::numeric,0)+COALESCE(NULLIF(BTRIM(taxc),'')::numeric,0))",
                "tx_header", "tx_type",
                "COALESCE(SUM(tax_a),0)+COALESCE(SUM(tax_b),0)+COALESCE(SUM(tax_c),0)", headerFilter),
            new("tx_header.refunds.total (RS+WR)", "txheader", "'all'",
                "SUM(CASE WHEN BTRIM(txtype) IN ('RS','WR') THEN NULLIF(BTRIM(totalamount),'')::numeric END)",
                "tx_header", "'all'",
                "SUM(CASE WHEN tx_type IN ('RS','WR') THEN total_amount END)", headerFilter),
            new("tx_payment.tender by type", "txpayment", "BTRIM(type)",
                "SUM(NULLIF(BTRIM(amounttender),'')::numeric)", "tx_payment", "type",
                "COALESCE(SUM(amount_tender),0)"),
            new("tx_payment.total_paid", "txpayment", "'all'",
                "SUM(NULLIF(BTRIM(totalthispay),'')::numeric)", "tx_payment", "'all'",
                "COALESCE(SUM(total_this_pay),0)"),
            new("tx_details.qty", "txdetails", "'all'",
                "SUM(NULLIF(BTRIM(qty),'')::numeric)", "tx_details", "'all'", "COALESCE(SUM(qty),0)"),
            new("tx_details.amount", "txdetails", "'all'",
                "SUM(NULLIF(BTRIM(amount),'')::numeric)", "tx_details", "'all'", "COALESCE(SUM(amount),0)"),
            new("customer_accounts.purchased (AR)", "customeraccounts", "'all'",
                "SUM(NULLIF(BTRIM(ttlamtpurchased),'')::numeric)", "customer_accounts", "'all'",
                "COALESCE(SUM(ttl_amt_purchased),0)"),
            new("customer_accounts.refunds (AR)", "customeraccounts", "'all'",
                "SUM(NULLIF(BTRIM(ttlamtrefund),'')::numeric)", "customer_accounts", "'all'",
                "COALESCE(SUM(ttl_amt_refund),0)"),
        };

        foreach (var check in checks)
        {
            if (!stagedNames.Contains(check.LegacyTable))
                continue; // subset run: table not staged
            await MoneyCheckAsync(conn, report, check, ct);
        }

        if (stagedNames.Contains("txheader"))
            await StatusCountCheckAsync(conn, report, headerFilter, ct);
    }

    private async Task MoneyCheckAsync(NpgsqlConnection conn, ReconcileReport report, AggregateCheck c, CancellationToken ct)
    {
        var isScalar = c.LegacyKey == "'all'";
        var where = c.TargetFilter is null ? "" : $"WHERE {c.TargetFilter}";

        if (isScalar)
        {
            var l = await ScalarDecimalAsync(conn,
                $"SELECT COALESCE({c.LegacyValue},0) FROM legacy.{Q(c.LegacyTable)};", ct);
            var t = await ScalarDecimalAsync(conn,
                $"SELECT COALESCE({c.TargetValue},0) FROM public.{Q(c.TargetTable)} {where};", ct);
            AddMoney(report, c.Label, "all", l, t);
            return;
        }

        var sql =
            $"WITH l AS (SELECT {c.LegacyKey} AS k, {c.LegacyValue} AS v FROM legacy.{Q(c.LegacyTable)} GROUP BY 1)," +
            $" t AS (SELECT {c.TargetKey}::text AS k, {c.TargetValue} AS v FROM public.{Q(c.TargetTable)} {where} GROUP BY 1)" +
            $" SELECT COALESCE(l.k, t.k) AS k, l.v AS lv, t.v AS tv FROM l FULL JOIN t ON l.k = t.k" +
            $" WHERE l.v IS DISTINCT FROM t.v;";
        await GroupedCheckAsync(conn, report, c.Label, sql, ct);
    }

    private void AddMoney(ReconcileReport report, string label, string scope, decimal l, decimal t)
    {
        var diff = l - t;
        var status = Math.Abs(diff) <= config.Tolerance ? "PASS" : "FAIL";
        report.Rows.Add(new CheckRow(label, scope,
            l.ToString("0.00##", CultureInfo.InvariantCulture),
            t.ToString("0.00##", CultureInfo.InvariantCulture),
            status, status == "PASS" ? null : $"diff {diff.ToString("0.00##", CultureInfo.InvariantCulture)}"));
    }

    /// <summary>Grouped rows from SQL: key, legacy value, target value; mismatched rows fail the check.</summary>
    private async Task GroupedCheckAsync(NpgsqlConnection conn, ReconcileReport report, string label, string sql, CancellationToken ct)
    {
        var mismatches = new List<(string Key, string Expected, string Actual)>();
        await using (var cmd = conn.CreateCommand())
        {
            cmd.CommandText = sql;
            cmd.CommandTimeout = 300;
            await using var reader = await cmd.ExecuteReaderAsync(ct);
            while (await reader.ReadAsync(ct))
            {
                var key = reader.IsDBNull(0) ? "(null)" : reader.GetValue(0).ToString() ?? "(null)";
                decimal? lv = reader.IsDBNull(1) ? null : Convert.ToDecimal(reader.GetValue(1), CultureInfo.InvariantCulture);
                decimal? tv = reader.IsDBNull(2) ? null : Convert.ToDecimal(reader.GetValue(2), CultureInfo.InvariantCulture);

                if (lv is decimal l && tv is decimal r && Math.Abs(l - r) <= config.Tolerance)
                    continue;
                mismatches.Add((key,
                    lv?.ToString("0.00##", CultureInfo.InvariantCulture) ?? "(missing)",
                    tv?.ToString("0.00##", CultureInfo.InvariantCulture) ?? "(missing)"));
            }
        }

        if (mismatches.Count == 0)
            report.Rows.Add(new CheckRow(label, "groups", "equal within tolerance", "equal", "PASS", null));
        else
            foreach (var m in mismatches.Take(SampleLimit))
                report.Rows.Add(new CheckRow(label, m.Key, m.Expected, m.Actual, "FAIL",
                    mismatches.Count > SampleLimit ? $"(showing {SampleLimit} of {mismatches.Count})" : null));
    }

    /// <summary>Order status counts by tx_type (spec: order status reconciliation).</summary>
    private async Task StatusCountCheckAsync(NpgsqlConnection conn, ReconcileReport report, string? headerFilter, CancellationToken ct)
    {
        var where = headerFilter is null ? "" : $"WHERE {headerFilter}";
        var sql =
            "WITH l AS (SELECT BTRIM(txtype) || '/' || COALESCE(BTRIM(status),'-') AS k, count(*)::numeric AS v" +
            " FROM legacy.txheader GROUP BY 1)," +
            $" t AS (SELECT tx_type || '/' || COALESCE(status,'-') AS k, count(*)::numeric AS v FROM public.tx_header {where} GROUP BY 1)" +
            " SELECT COALESCE(l.k, t.k) AS k, l.v AS lv, t.v AS tv FROM l FULL JOIN t ON l.k = t.k" +
            " WHERE l.v IS DISTINCT FROM t.v;";
        await GroupedCheckAsync(conn, report, "tx_header.status counts by type", sql, ct);
    }



    /// <summary>Inventory quantity and cost by SKU and lot (spec: inventory reconciliation).</summary>
    private async Task InventoryChecksAsync(NpgsqlConnection conn, ReconcileReport report, CancellationToken ct)
    {
        var stagedNames = await TransformRunner.GetStagedTableNamesAsync(conn, ct, config.LegacySchema);
        if (!stagedNames.Contains("inventory") || !stagedNames.Contains("invtlotrecord"))
            return;
        await RowLevelCheckAsync(conn, report, "inventory.qty by sku",
            "WITH l AS (SELECT BTRIM(sku) sku, NULLIF(BTRIM(qtytotalonhand),'')::numeric q FROM legacy.inventory)," +
            " t AS (SELECT BTRIM(sku) sku, qty_total_on_hand::numeric q FROM public.inventory)" +
            " SELECT COALESCE(l.sku, t.sku), l.q::text, t.q::text FROM l FULL JOIN t USING (sku)" +
            " WHERE COALESCE(l.q, -1e30) <> COALESCE(t.q, -1e30) LIMIT 51;", ct);

        await RowLevelCheckAsync(conn, report, "inventory.cost by sku",
            "WITH l AS (SELECT BTRIM(sku) sku, NULLIF(BTRIM(averagecost),'')::numeric c FROM legacy.inventory)," +
            " t AS (SELECT BTRIM(sku) sku, average_cost c FROM public.inventory)" +
            " SELECT COALESCE(l.sku, t.sku), l.c::text, t.c::text FROM l FULL JOIN t USING (sku)" +
            $" WHERE ABS(COALESCE(l.c, 0) - COALESCE(t.c, 0)) > {Tol} LIMIT 51;", ct);

        await RowLevelCheckAsync(conn, report, "inventory.qty by lot",
            "WITH l AS (SELECT BTRIM(sku) sku, BTRIM(lotno) lot, NULLIF(BTRIM(qtyonhand),'')::numeric q FROM legacy.invtlotrecord)," +
            " t AS (SELECT BTRIM(sku) sku, BTRIM(lot_no) lot, qty_on_hand::numeric q FROM public.invt_lot_record)" +
            " SELECT COALESCE(l.sku || '/' || l.lot, t.sku || '/' || t.lot), l.q::text, t.q::text" +
            " FROM l FULL JOIN t ON l.sku = t.sku AND l.lot = t.lot" +
            " WHERE COALESCE(l.q, -1e30) <> COALESCE(t.q, -1e30) LIMIT 51;", ct);

        await RowLevelCheckAsync(conn, report, "inventory.lot cost by lot",
            "WITH l AS (SELECT BTRIM(sku) sku, BTRIM(lotno) lot, NULLIF(BTRIM(totalamountpurchased),'')::numeric c FROM legacy.invtlotrecord)," +
            " t AS (SELECT BTRIM(sku) sku, BTRIM(lot_no) lot, total_amount_purchased c FROM public.invt_lot_record)" +
            " SELECT COALESCE(l.sku || '/' || l.lot, t.sku || '/' || t.lot), l.c::text, t.c::text" +
            " FROM l FULL JOIN t ON l.sku = t.sku AND l.lot = t.lot" +
            $" WHERE ABS(COALESCE(l.c, 0) - COALESCE(t.c, 0)) > {Tol} LIMIT 51;", ct);
    }

    /// <summary>Row-level diff checks return up to 51 rows; presence of rows means failure.</summary>
    private async Task RowLevelCheckAsync(NpgsqlConnection conn, ReconcileReport report, string label, string sql, CancellationToken ct)
    {
        var rows = new List<(string Key, string Expected, string Actual)>();
        await using (var cmd = conn.CreateCommand())
        {
            cmd.CommandText = sql;
            cmd.CommandTimeout = 300;
            await using var reader = await cmd.ExecuteReaderAsync(ct);
            while (await reader.ReadAsync(ct))
                rows.Add((reader.GetValue(0)?.ToString() ?? "(null)",
                    reader.IsDBNull(1) ? "(missing)" : reader.GetValue(1).ToString() ?? "",
                    reader.IsDBNull(2) ? "(missing)" : reader.GetValue(2).ToString() ?? ""));
        }

        if (rows.Count == 0)
            report.Rows.Add(new CheckRow(label, "rows", "equal", "equal", "PASS", null));
        else
        {
            var truncated = rows.Count > SampleLimit ? $"(showing {SampleLimit}, more exist)" : null;
            foreach (var r in rows.Take(SampleLimit))
                report.Rows.Add(new CheckRow(label, r.Key, r.Expected, r.Actual, "FAIL", truncated));
        }
    }

    /// <summary>Every public sequence must be ahead of its table's migrated maximum (task 6.1 evidence).</summary>
    private async Task SequenceChecksAsync(NpgsqlConnection conn, ReconcileReport report, CancellationToken ct)
    {
        var sequences = new List<(string Sequence, string Table, string Column)>();
        await using (var cmd = conn.CreateCommand())
        {
            cmd.CommandText = """
                SELECT s.oid::regclass::text, t.relname, a.attname
                FROM pg_class s
                JOIN pg_depend d ON d.objid = s.oid AND d.deptype = 'a'
                JOIN pg_class t ON t.oid = d.refobjid AND t.relkind = 'r'
                JOIN pg_attribute a ON a.attrelid = t.oid AND a.attnum = d.refobjsubid
                JOIN pg_namespace n ON n.oid = t.relnamespace
                WHERE s.relkind = 'S' AND n.nspname = 'public';
                """;
            await using var reader = await cmd.ExecuteReaderAsync(ct);
            while (await reader.ReadAsync(ct))
                sequences.Add((reader.GetString(0), reader.GetString(1), reader.GetString(2)));
        }

        foreach (var (sequence, table, column) in sequences)
        {
            var qualified = sequence.StartsWith("public.", StringComparison.Ordinal) ? sequence[7..] : sequence;
            var ok = await ScalarLongAsync(conn,
                "SELECT CASE WHEN last_value >= COALESCE((SELECT MAX(" + Q(column) + ") FROM public." + Q(table) + "), 0) THEN 1 ELSE 0 END" +
                " FROM pg_sequences WHERE schemaname = 'public' AND sequencename = " + Lit(SplitSeqName(qualified)) + ";", ct);
            report.Rows.Add(new CheckRow("sequence", $"{qualified} vs {table}.{column}", ">= max",
                ok == 1 ? "ok" : "behind", ok == 1 ? "PASS" : "FAIL",
                ok == 1 ? null : "run transform to advance sequences"));
        }
    }

    private static string SplitSeqName(string qualified)
    {
        var parts = qualified.Split('.');
        return parts[^1].Trim('"');
    }

    /// <summary>Control numbers must be strictly ahead of every migrated transaction number (task 6.2 evidence).</summary>
    private async Task ControlNumberChecksAsync(NpgsqlConnection conn, ReconcileReport report, CancellationToken ct)
    {
        if (!await TableExistsAsync(conn, "public", "pref_tx_number", ct))
            return;

        var sql =
            "WITH src AS (SELECT UPPER(LEFT(BTRIM(tx_number), 2)) AS pfx," +
            " MAX((SUBSTRING(BTRIM(tx_number) FROM '([0-9]+)$'))::numeric(19)) AS mx" +
            " FROM public.tx_header WHERE tx_number ~ '[0-9]+$' GROUP BY 1)" +
            " SELECT p.tx_prefix, p.tx_next_number::numeric, src.mx FROM public.pref_tx_number p" +
            " LEFT JOIN src ON src.pfx = BTRIM(p.tx_prefix)" +
            " WHERE src.mx IS NOT NULL AND src.mx >= p.tx_next_number::bigint;";
        await GroupedCheckAsync(conn, report, "control numbers ahead of migrated data", sql, ct);
    }

    private async Task AnomalySummaryAsync(NpgsqlConnection conn, ReconcileReport report, CancellationToken ct)
    {
        if (await ColumnExistsAsync(conn, "public", "tx_header", TransformRunner.SyntheticColumn, ct))
        {
            var stubs = await ScalarLongAsync(conn,
                $"SELECT count(*) FROM public.tx_header WHERE {TransformRunner.SyntheticColumn};", ct);
            report.Rows.Add(new CheckRow("anomalies.synthetic-headers", "tx_header", "reported",
                stubs.ToString(CultureInfo.InvariantCulture), stubs > 0 ? "INFO" : "PASS",
                "orphaned children migrated under flagged synthetic headers"));
        }

        if (await TableExistsAsync(conn, config.MigrationSchema, "anomaly_quarantine", ct))
        {
            var quarantined = await ScalarLongAsync(conn,
                $"SELECT count(*) FROM {Q(config.MigrationSchema)}.anomaly_quarantine;", ct);
            report.Rows.Add(new CheckRow("anomalies.quarantine-entries", config.MigrationSchema + ".anomaly_quarantine",
                "reported", quarantined.ToString(CultureInfo.InvariantCulture), quarantined > 0 ? "INFO" : "PASS", null));
        }
    }

    private static async Task<long> ScalarLongAsync(NpgsqlConnection conn, string sql, CancellationToken ct)
    {
        await using var cmd = conn.CreateCommand();
        cmd.CommandText = sql;
        cmd.CommandTimeout = 300;
        return Convert.ToInt64(await cmd.ExecuteScalarAsync(ct) ?? 0L);
    }

    private static async Task<decimal> ScalarDecimalAsync(NpgsqlConnection conn, string sql, CancellationToken ct)
    {
        await using var cmd = conn.CreateCommand();
        cmd.CommandText = sql;
        cmd.CommandTimeout = 300;
        var value = await cmd.ExecuteScalarAsync(ct);
        return value is null or DBNull ? 0m : Convert.ToDecimal(value, CultureInfo.InvariantCulture);
    }

    private static async Task<bool> TableExistsAsync(NpgsqlConnection conn, string schema, string table, CancellationToken ct)
    {
        await using var cmd = conn.CreateCommand();
        cmd.CommandText = "SELECT count(*) FROM information_schema.tables WHERE table_schema=@s AND table_name=@t AND table_type='BASE TABLE';";
        cmd.Parameters.AddWithValue("s", schema);
        cmd.Parameters.AddWithValue("t", table);
        return Convert.ToInt64(await cmd.ExecuteScalarAsync(ct) ?? 0L) > 0;
    }

    private static async Task<bool> ColumnExistsAsync(NpgsqlConnection conn, string schema, string table, string column, CancellationToken ct)
    {
        await using var cmd = conn.CreateCommand();
        cmd.CommandText = "SELECT count(*) FROM information_schema.columns WHERE table_schema=@s AND table_name=@t AND column_name=@c;";
        cmd.Parameters.AddWithValue("s", schema);
        cmd.Parameters.AddWithValue("t", table);
        cmd.Parameters.AddWithValue("c", column);
        return Convert.ToInt64(await cmd.ExecuteScalarAsync(ct) ?? 0L) > 0;
    }

    private static string Q(string identifier) => SchemaMapper.Quote(identifier);
    private static string Lit(string value) => "'" + value.Replace("'", "''") + "'";
}
