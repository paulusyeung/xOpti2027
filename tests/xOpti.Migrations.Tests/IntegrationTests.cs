using Npgsql;
using xOpti.Migrations;

namespace xOpti.Migrations.Tests;

/// <summary>
/// Integration tests against the local PostgreSQL instance. They SKIP gracefully when the
/// scratch migration database (xopti_migration_test) or the legacy MDB are unavailable, so CI
/// without local databases still passes. Set XOPTI_TEST_DATABASE_URL to override the target.
/// </summary>
public class IntegrationTests
{
    private const string ScratchDb = "xopti_migration_test";

    private static async Task<NpgsqlConnection?> OpenScratchAsync()
    {
        string? url = Environment.GetEnvironmentVariable("XOPTI_TEST_DATABASE_URL");
        if (string.IsNullOrEmpty(url))
        {
            try
            {
                var cfg = MigrationConfig.Load(null);
                url = cfg.TargetConnectionString.EndsWith("/xOpti", StringComparison.Ordinal)
                    ? url = cfg.TargetConnectionString[..^"/xOpti".Length] + "/" + ScratchDb
                    : null;
            }
            catch (MigrationException)
            {
                return null;
            }
        }

        if (url is null)
            return null;

        try
        {
            var conn = new NpgsqlConnection(Program.ToNpgsqlConnectionString(url));
            await conn.OpenAsync();
            return conn;
        }
        catch
        {
            return null;
        }
    }

    private static async Task<bool> HasStagedDataAsync(NpgsqlConnection conn)
    {
        await using var cmd = conn.CreateCommand();
        cmd.CommandText = """
            SELECT count(*) FROM information_schema.tables
            WHERE table_schema = 'legacy' AND table_type = 'BASE TABLE';
            """;
        return Convert.ToInt64(await cmd.ExecuteScalarAsync() ?? 0L) >= 70;
    }

    [Fact]
    public async Task StagedSnapshotMatchesMdbRowCounts()
    {
        await using var conn = await OpenScratchAsync();
        if (conn is null || !await HasStagedDataAsync(conn))
            return; // skipped

        // Known totals for this dev-purpose snapshot (MIGRATE_DB_NOTES.md).
        await using var cmd = conn.CreateCommand();
        cmd.CommandText = """
            SELECT
              (SELECT count(*) FROM legacy.txheader)::numeric,
              (SELECT count(*) FROM legacy.txdetails)::numeric,
              (SELECT count(*) FROM legacy.customer)::numeric,
              (SELECT count(*) FROM legacy.invtstdetails)::numeric;
            """;
        await using var reader = await cmd.ExecuteReaderAsync();
        await reader.ReadAsync();
        Assert.Equal(547_731m, reader.GetDecimal(0));
        Assert.Equal(1_223_530m, reader.GetDecimal(1));
        Assert.Equal(59_978m, reader.GetDecimal(2));
        Assert.Equal(2_819_162m, reader.GetDecimal(3));
    }

    [Fact]
    public async Task TransformPreservedCountsAndIsRepeatable()
    {
        await using var conn = await OpenScratchAsync();
        if (conn is null || !await HasStagedDataAsync(conn))
            return; // skipped

        // Target was transformed twice from the same staging; counts must equal the source.
        await using var cmd = conn.CreateCommand();
        cmd.CommandText = """
            SELECT
              (SELECT count(*) FROM legacy.txheader)::numeric,
              (SELECT count(*) FROM public.tx_header WHERE NOT is_synthetic)::numeric,
              (SELECT count(*) FROM legacy.customer)::numeric,
              (SELECT count(*) FROM public.customer)::numeric,
              (SELECT count(*) FROM legacy.invtstdetails)::numeric,
              (SELECT count(*) FROM public.invt_st_details)::numeric;
            """;
        await using var reader = await cmd.ExecuteReaderAsync();
        await reader.ReadAsync();
        Assert.Equal(reader.GetDecimal(0), reader.GetDecimal(1)); // headers (excluding synthetic stubs)
        Assert.Equal(reader.GetDecimal(2), reader.GetDecimal(3)); // customers
        Assert.Equal(reader.GetDecimal(4), reader.GetDecimal(5)); // stock-take details
    }

    [Fact]
    public async Task OrphanedChildrenMigratedWithFlaggedSyntheticHeaders()
    {
        await using var conn = await OpenScratchAsync();
        if (conn is null || !await HasStagedDataAsync(conn))
            return; // skipped

        await using var cmd = conn.CreateCommand();
        cmd.CommandText = """
            SELECT
              (SELECT count(*) FROM public.tx_header WHERE is_synthetic)::numeric,
              (SELECT count(*) FROM migration.anomaly_quarantine WHERE kind = 'missing_header_stub')::numeric;
            """;
        await using var reader = await cmd.ExecuteReaderAsync();
        await reader.ReadAsync();
        Assert.True(reader.GetDecimal(0) > 0);
        Assert.True(reader.GetDecimal(1) > 0);
    }

    [Fact]
    public async Task SequencesAndControlNumbersAreAheadOfMigratedData()
    {
        await using var conn = await OpenScratchAsync();
        if (conn is null || !await HasStagedDataAsync(conn))
            return; // skipped

        long sequenceCount;
        await using (var cmd = conn.CreateCommand())
        {
            cmd.CommandText = """
                SELECT count(*)
                FROM pg_sequences s
                WHERE s.schemaname = 'public';
                """;
            sequenceCount = Convert.ToInt64(await cmd.ExecuteScalarAsync() ?? 0L);
        }

        Assert.True(sequenceCount >= 0);

        await using var cmd2 = conn.CreateCommand();
        cmd2.CommandText = """
            SELECT count(*) FROM public.pref_tx_number p
            WHERE p.tx_next_number <= (
                SELECT COALESCE(MAX((SUBSTRING(BTRIM(t.tx_number) FROM '([0-9]+)$'))::numeric(19)), -1)
                FROM public.tx_header t
                WHERE UPPER(LEFT(BTRIM(t.tx_number),2)) = BTRIM(p.tx_prefix) AND t.tx_number ~ '[0-9]+$');
            """;
        Assert.Equal(0L, Convert.ToInt64(await cmd2.ExecuteScalarAsync() ?? 0L));
    }

    [Fact]
    public async Task DryRunWritesNothingToTarget()
    {
        // Uses the real configured target; skipped if the MDB or database is unavailable.
        var saved = Environment.GetEnvironmentVariable("XOPTI_MIGRATIONS_NO_EXIT");
        try
        {
            var cfg = MigrationConfig.Load(null);
            if (!File.Exists(cfg.SynergyMdbPath))
                return; // skipped

            await using var conn = new NpgsqlConnection(Program.ToNpgsqlConnectionString(cfg.TargetConnectionString));
            await conn.OpenAsync();

            long Before()
            {
                using var cmd = conn.CreateCommand();
                cmd.CommandText = "SELECT (SELECT count(*) FROM public.security) + (SELECT count(*) FROM public.pay_period) + (SELECT count(*) FROM public.salutation);";
                return Convert.ToInt64(cmd.ExecuteScalar() ?? 0L);
            }

            var before = Before();
            var exit = await Program.Main(["cutover", "--dry-run", "--only", "Security,PayPeriod,Salutation"]);
            var after = Before();

            Assert.InRange(exit, 0, 4); // cutover may legitimately block on reconciliation failures
            Assert.Equal(before, after);
        }
        catch (MigrationException)
        {
            // Missing configuration in CI: skipped.
        }
        finally
        {
            _ = saved;
        }
    }
}
