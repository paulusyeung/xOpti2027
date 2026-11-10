using System.Text.Json;
using Npgsql;

namespace xOpti.Migrations;

public sealed record ExtractedTable(string Name, long Rows, long DateFixes, TimeSpan Duration);

public sealed record ExtractResult(IReadOnlyList<ExtractedTable> Tables, SourceFingerprint Source)
{
    public long TotalRows => Tables.Sum(t => t.Rows);
    public long TotalDateFixes => Tables.Sum(t => t.DateFixes);
}

/// <summary>
/// Streams the entire MDB into the PostgreSQL legacy staging schema: one streaming
/// mdb-export process per table piped directly into COPY (no intermediate CSV files),
/// recording per-column MDB types so transforms can apply type-aware normalization later.
/// </summary>
public sealed class ExtractionRunner(MigrationConfig config)
{
    public const string ColumnMetadataTable = "_mdb_columns";

    public async Task<ExtractResult> ExtractAsync(
        NpgsqlConnection conn, HashSet<string>? only, SourceFingerprint source, CancellationToken ct = default)
    {
        var loader = new StagingLoader(config);
        await loader.PrepareAsync(conn, ct);

        var schemaTables = await MdbTools.ReadSchemaAsync(config.SynergyMdbPath, ct);
        var originals = (await MdbTools.ListTablesAsync(config.SynergyMdbPath, ct))
            .ToDictionary(t => NameNormalizer.Canonical(t), StringComparer.OrdinalIgnoreCase);

        await using (var meta = conn.CreateCommand())
        {
            meta.CommandText = $"CREATE TABLE {SchemaMapper.Quote(config.LegacySchema)}." +
                               $"{SchemaMapper.Quote(ColumnMetadataTable)} (source_table text, column_name text, sql_type text, ordinal int);";
            await meta.ExecuteNonQueryAsync(ct);
        }

        var results = new List<ExtractedTable>();
        foreach (var table in schemaTables)
        {
            if (only is not null && !only.Contains(table.CanonicalName))
                continue;
            if (!originals.TryGetValue(table.CanonicalName, out var original))
                throw new MigrationException($"Staging table '{table.Name}' has no matching mdb-tables entry.");

            await loader.CreateTableAsync(table, ct);
            await RecordColumnMetadataAsync(conn, table, ct);

            var started = DateTime.UtcNow;
            var (rows, dateFixes) = await loader.LoadTableAsync(original, table, ct);
            var elapsed = DateTime.UtcNow - started;

            Console.WriteLine($"  staged {table.Name} ({original}): {rows:N0} rows, {dateFixes} date defects fixed [{elapsed.TotalSeconds:F1}s]");
            results.Add(new ExtractedTable(table.Name, rows, dateFixes, elapsed));
        }

        return new ExtractResult(results, source);
    }

    private async Task RecordColumnMetadataAsync(NpgsqlConnection conn, StagingTable table, CancellationToken ct)
    {
        var ordinal = 0;
        foreach (var column in table.Columns)
        {
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = $"INSERT INTO {SchemaMapper.Quote(config.LegacySchema)}." +
                              $"{SchemaMapper.Quote(ColumnMetadataTable)} VALUES (@t, @c, @s, @o);";
            cmd.Parameters.AddWithValue("t", table.Name);
            cmd.Parameters.AddWithValue("c", column.Name);
            cmd.Parameters.AddWithValue("s", column.SqlType);
            cmd.Parameters.AddWithValue("o", ordinal++);
            await cmd.ExecuteNonQueryAsync(ct);
        }
    }

    /// <summary>Rebuilds staging table metadata (with real MDB types) from the recorded column table.</summary>
    public static async Task<List<StagingTable>> ReadStagedMetadataAsync(
        NpgsqlConnection conn, string legacySchema, CancellationToken ct = default)
    {
        var byTable = new SortedDictionary<string, List<StagingColumn>>(StringComparer.Ordinal);
        await using var cmd = conn.CreateCommand();
        cmd.CommandText = $"SELECT source_table, column_name, sql_type FROM {SchemaMapper.Quote(legacySchema)}." +
                          $"{SchemaMapper.Quote(ColumnMetadataTable)} ORDER BY source_table, ordinal;";
        await using var reader = await cmd.ExecuteReaderAsync(ct);
        while (await reader.ReadAsync(ct))
        {
            if (!byTable.TryGetValue(reader.GetString(0), out var cols))
                byTable[reader.GetString(0)] = cols = [];
            cols.Add(new StagingColumn(reader.GetString(1), reader.GetString(2)));
        }

        return byTable.Select(kv => new StagingTable(kv.Key, kv.Value)).ToList();
    }

    public static string ToDetailsJson(ExtractResult result) => JsonSerializer.Serialize(new
    {
        source = result.Source.Path,
        sha256 = result.Source.Sha256,
        totalRows = result.TotalRows,
        dateFixes = result.TotalDateFixes,
        tables = result.Tables.Select(t => new { t.Name, t.Rows, t.DateFixes, seconds = Math.Round(t.Duration.TotalSeconds, 1) }),
    });
}

/// <summary>
/// Validates the staged snapshot against the PascalCase reference mirror (Synergy5) when a
/// DATABASE_URL reference connection is available; read-only.
/// </summary>
public static class StageValidator
{
    public static async Task<(int Passed, int Failed)> ValidateAsync(NpgsqlConnection target, MigrationConfig config, CancellationToken ct = default)
    {
        NpgsqlConnection? reference = null;
        if (!string.IsNullOrWhiteSpace(config.ReferenceConnectionString))
        {
            reference = new NpgsqlConnection(Program.ToNpgsqlConnectionString(config.ReferenceConnectionString));
            await reference.OpenAsync(ct);
        }

        try
        {
            var staged = await ReconcileRunner.LoadStagedTablesAsync(target, ct);
            if (staged.Count == 0)
                throw new MigrationException(
                    "No tables found in the legacy staging schema. Run 'extract' first " +
                    "(and note that a dry run rolls its staging back).");
            var referenceCounts = reference is null
                ? null
                : await LoadReferenceCountsAsync(reference, ct);

            Console.WriteLine($"{"table",-32} {"staged",14} {"reference",14} status");
            var passed = 0;
            var failed = 0;

            foreach (var table in staged)
            {
                var count = await ScalarLongAsync(target,
                    $"SELECT count(*) FROM {SchemaMapper.Quote(config.LegacySchema)}.{SchemaMapper.Quote(table.Name)};", ct);
                long? expected = referenceCounts?.GetValueOrDefault(table.CanonicalName);

                string status = expected is null ? "NO-REFERENCE" : expected == count ? "PASS" : "FAIL";
                if (status == "PASS" || status == "NO-REFERENCE") passed++;
                else failed++;

                Console.WriteLine($"{table.Name,-32} {count,14:N0} {expected?.ToString("N0") ?? "-",14} {status}");
            }

            return (passed, failed);
        }
        finally
        {
            if (reference is not null) await reference.DisposeAsync();
        }
    }

    private static async Task<Dictionary<string, long>> LoadReferenceCountsAsync(NpgsqlConnection conn, CancellationToken ct)
    {
        var counts = new Dictionary<string, long>(StringComparer.OrdinalIgnoreCase);
        await using var cmd = conn.CreateCommand();
        cmd.CommandText = "SELECT table_name FROM information_schema.tables WHERE table_schema='public' AND table_type='BASE TABLE';";
        var names = new List<string>();
        await using (var reader = await cmd.ExecuteReaderAsync(ct))
            while (await reader.ReadAsync(ct))
                names.Add(reader.GetString(0));

        foreach (var name in names)
        {
            var count = await ScalarLongAsync(conn, $"SELECT count(*) FROM public.{SchemaMapper.Quote(name)};", ct);
            counts[NameNormalizer.Canonical(name)] = count;
        }

        return counts;
    }

    private static async Task<long> ScalarLongAsync(NpgsqlConnection conn, string sql, CancellationToken ct)
    {
        await using var cmd = conn.CreateCommand();
        cmd.CommandText = sql;
        cmd.CommandTimeout = 300;
        return Convert.ToInt64(await cmd.ExecuteScalarAsync(ct) ?? 0L);
    }
}
