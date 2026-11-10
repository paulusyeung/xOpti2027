using System.Runtime.CompilerServices;
using Npgsql;

namespace xOpti.Migrations;

/// <summary>
/// Field-level normalization applied while streaming rows into staging:
/// substitutes the invalid Access date 1900-01-00 with 1899-12-30.
/// </summary>
public static class StreamNormalizer
{
    public static string FixDateDefect(string value) =>
        value.Contains("1900-01-00", StringComparison.Ordinal)
            ? value.Replace("1900-01-00", "1899-12-30", StringComparison.Ordinal)
            : value;

    public static int CountDateDefects(IReadOnlyList<string?> row)
    {
        var count = 0;
        foreach (var field in row)
            if (field is not null && field.Contains("1900-01-00", StringComparison.Ordinal))
                count++;
        return count;
    }
}

/// <summary>
/// Creates the legacy staging schema with source-shaped, TEXT-typed columns and streams
/// every MDB table directly into PostgreSQL COPY (binary format) without intermediate files.
/// </summary>
public sealed class StagingLoader(MigrationConfig config)
{
    private NpgsqlConnection Connection { get; set; } = null!;

    public async Task PrepareAsync(NpgsqlConnection connection, CancellationToken ct = default)
    {
        Connection = connection;
        await using (var cmd = connection.CreateCommand())
        {
            cmd.CommandText = $"DROP SCHEMA IF EXISTS {Q(config.LegacySchema)} CASCADE;";
            await cmd.ExecuteNonQueryAsync(ct);
            cmd.CommandText = $"CREATE SCHEMA {Q(config.LegacySchema)};";
            await cmd.ExecuteNonQueryAsync(ct);
        }
    }

    public async Task<int> CreateTableAsync(StagingTable table, CancellationToken ct = default)
    {
        var columns = string.Join(", ", table.Columns.Select(c => $"{Q(c.Name)} text"));
        await using var cmd = Connection.CreateCommand();
        cmd.CommandText = $"CREATE TABLE {Q(config.LegacySchema)}.{Q(table.Name)} ({columns});";
        await cmd.ExecuteNonQueryAsync(ct);
        return table.Columns.Count;
    }

    /// <summary>
    /// Streams rows from the MDB into the staging table with COPY FROM STDIN (FORMAT binary).
    /// Returns the number of rows loaded and the count of date defects substituted.
    /// </summary>
    public async Task<(long Rows, long DateFixes)> LoadTableAsync(
        string mdbTableName, StagingTable table, CancellationToken ct = default)
    {
        var columnList = string.Join(", ", table.Columns.Select(c => Q(c.Name)));
        var copySql = $"COPY {Q(config.LegacySchema)}.{Q(table.Name)} ({columnList}) FROM STDIN (FORMAT binary)";

        long rows = 0;
        long dateFixes = 0;

        await using (var importer = await Connection.BeginBinaryImportAsync(copySql, ct))
        {
            await foreach (var row in MdbTools.ExportRowsAsync(config.SynergyMdbPath, mdbTableName, ct))
            {
                if (row.Count != table.Columns.Count)
                    throw new MigrationException(
                        $"Table '{mdbTableName}': expected {table.Columns.Count} columns, got {row.Count} on row {rows + 1}.");

                await importer.StartRowAsync(ct);
                foreach (var field in row)
                {
                    if (field is null)
                    {
                        await importer.WriteNullAsync(ct);
                    }
                    else
                    {
                        if (field.Contains("1900-01-00", StringComparison.Ordinal))
                        {
                            dateFixes++;
                            await importer.WriteAsync(StreamNormalizer.FixDateDefect(field), ct);
                        }
                        else
                        {
                            await importer.WriteAsync(field, ct);
                        }
                    }
                }

                rows++;
            }

            await importer.CompleteAsync(ct);
        }

        return (rows, dateFixes);
    }

    internal static string Q(string identifier) => "\"" + identifier.Replace("\"", "\"\"") + "\"";
}
