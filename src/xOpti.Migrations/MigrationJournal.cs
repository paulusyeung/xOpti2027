using System.Security.Cryptography;
using Npgsql;

namespace xOpti.Migrations;

public sealed record SourceFingerprint(string Path, string Sha256, int TableCount);

public static class SourceValidator
{
    /// <summary>
    /// Ensures the legacy MDB exists, is readable by mdbtools, and fingerprints it (SHA-256) so
    /// callers can prove the source was untouched (read-only guarantee, task 2.2).
    /// </summary>
    public static async Task<SourceFingerprint> FingerprintAsync(string path, CancellationToken ct = default)
    {
        var full = Path.GetFullPath(path);
        if (!File.Exists(full))
            throw new MigrationException($"Legacy source MDB not found: {full}");

        var tables = await MdbTools.ListTablesAsync(full, ct);
        if (tables.Length == 0)
            throw new MigrationException($"mdb-tables returned no tables for {full} (encrypted or workgroup-secured?).");

        await using var stream = new FileStream(full, FileMode.Open, FileAccess.Read, FileShare.Read, 1024 * 1024);
        using var sha = SHA256.Create();
        var hash = Convert.ToHexString(await sha.ComputeHashAsync(stream, ct)).ToLowerInvariant();

        return new SourceFingerprint(full, hash, tables.Length);
    }

    public static async Task VerifyUnchangedAsync(SourceFingerprint before, CancellationToken ct = default)
    {
        var tables = await MdbTools.ListTablesAsync(before.Path, ct);
        await using var stream = new FileStream(before.Path, FileMode.Open, FileAccess.Read, FileShare.Read, 1024 * 1024);
        using var sha = SHA256.Create();
        var hash = Convert.ToHexString(await sha.ComputeHashAsync(stream, ct)).ToLowerInvariant();

        if (hash != before.Sha256 || tables.Length != before.TableCount)
            throw new MigrationException(
                $"Source MDB changed during the run ({before.TableCount} -> {tables.Length} tables, hash differs). Aborting.");
    }
}

/// <summary>run_log + anomaly_quarantine bookkeeping (spec: runs record source path and counts).</summary>
public static class MigrationJournal
{
    public static async Task EnsureSchemaAsync(NpgsqlConnection conn, string schema, CancellationToken ct = default)
    {
        await using var cmd = conn.CreateCommand();
        cmd.CommandText = $"""
            CREATE SCHEMA IF NOT EXISTS {schema};
            CREATE TABLE IF NOT EXISTS {schema}.run_log (
                id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
                command text NOT NULL,
                mode text NOT NULL,
                source_path text,
                source_sha256 text,
                started_at timestamptz NOT NULL DEFAULT now(),
                ended_at timestamptz,
                outcome text,
                details jsonb
            );
            CREATE TABLE IF NOT EXISTS {schema}.anomaly_quarantine (
                id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
                run_id bigint,
                source_table text,
                pk text,
                kind text,
                detail text,
                created_at timestamptz NOT NULL DEFAULT now()
            );
            """;
        await cmd.ExecuteNonQueryAsync(ct);
    }

    public static async Task<long> StartRunAsync(
        NpgsqlConnection conn, string schema, string command, bool dryRun,
        SourceFingerprint source, CancellationToken ct = default)
    {
        await using var cmd = conn.CreateCommand();
        cmd.CommandText = $"INSERT INTO {schema}.run_log (command, mode, source_path, source_sha256)" +
                          " VALUES (@c, @m, @p, @h) RETURNING id;";
        cmd.Parameters.AddWithValue("c", command);
        cmd.Parameters.AddWithValue("m", dryRun ? "dry-run" : "write");
        cmd.Parameters.AddWithValue("p", source.Path);
        cmd.Parameters.AddWithValue("h", source.Sha256);
        return Convert.ToInt64(await cmd.ExecuteScalarAsync(ct) ?? throw new MigrationException("run_log insert failed"));
    }

    public static async Task EndRunAsync(
        NpgsqlConnection conn, string schema, long runId, string outcome, string detailsJson, CancellationToken ct = default)
    {
        await using var cmd = conn.CreateCommand();
        cmd.CommandText = $"UPDATE {schema}.run_log SET ended_at = now(), outcome = @o, details = @d::jsonb WHERE id = @r;";
        cmd.Parameters.AddWithValue("o", outcome);
        cmd.Parameters.AddWithValue("d", detailsJson);
        cmd.Parameters.AddWithValue("r", runId);
        await cmd.ExecuteNonQueryAsync(ct);
    }
}
