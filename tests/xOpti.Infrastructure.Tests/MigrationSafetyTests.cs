using Microsoft.Extensions.DependencyInjection;
using xOpti.Infrastructure.Persistence;
using xOpti.Infrastructure.Tests.Support;

namespace xOpti.Infrastructure.Tests;

public class MigrationSafetyTests
{
    private static readonly string[] LegacyTables =
    {
        "tx_header", "tx_details", "tx_payment", "inventory", "invt_lot_record",
        "branch", "customer", "preference", "pref_tx_number", "staff", "users",
    };

    private static string MigrationSource()
    {
        var root = RepoRoot();
        var file = Directory.GetFiles(
            Path.Combine(root, "src", "xOpti.Infrastructure", "Persistence", "Migrations"),
            "*_InitialPlatformAndIdentity.cs").Single();

        // Only the Up() body: Down() legitimately drops app-owned tables.
        var full = File.ReadAllText(file);
        var upStart = full.IndexOf("protected override void Up(", StringComparison.Ordinal);
        var downStart = full.IndexOf("protected override void Down(", StringComparison.Ordinal);
        Assert.True(upStart >= 0 && downStart > upStart);
        return full[upStart..downStart];
    }

    private static string RepoRoot()
    {
        var dir = new DirectoryInfo(AppContext.BaseDirectory);
        while (dir is not null && !File.Exists(Path.Combine(dir.FullName, "xOpti.sln")))
        {
            dir = dir.Parent;
        }

        return dir!.FullName;
    }

    [Theory]
    [InlineData("asp_net_users")]
    [InlineData("asp_net_roles")]
    [InlineData("audit_log")]
    [InlineData("idempotency_record")]
    public void InitialMigration_CreatesAppOwnedTables(string table)
    {
        Assert.Contains($"name: \"{table}\"", MigrationSource());
        Assert.Contains("migrationBuilder.CreateTable(", MigrationSource());
    }

    [Fact]
    public void InitialMigration_EmitsNoStatementsForLegacyTables()
    {
        var source = MigrationSource();

        // The migration body contains no reference at all to migrated tables.
        foreach (var legacy in LegacyTables)
        {
            Assert.DoesNotContain($"\"{legacy}\"", source, StringComparison.Ordinal);
        }

        // And no destructive statements beyond the history INSERT.
        Assert.DoesNotContain("migrationBuilder.DropTable(", source, StringComparison.Ordinal);
        Assert.DoesNotContain("migrationBuilder.AlterTable(", source, StringComparison.Ordinal);
        Assert.DoesNotContain("migrationBuilder.AlterColumn(", source, StringComparison.Ordinal);
        Assert.DoesNotContain("migrationBuilder.Rename", source, StringComparison.Ordinal);
    }

    [Fact]
    public void LegacyTablesAreExcludedFromModelMigrations()
    {
        // ExcludeFromMigrations is part of the mapping contract; assert it is
        // declared for every legacy table by counting ToTable registrations.
        var mapping = File.ReadAllText(Path.Combine(RepoRoot(), "src", "xOpti.Infrastructure", "Persistence", "LegacyMapping.cs"));
        var excluded = LegacyTables.Count(t => mapping.Contains($"\"{t}\", t => t.ExcludeFromMigrations()"));
        Assert.Equal(LegacyTables.Length, excluded);
    }
}

[Collection("postgres")]
public class SchemaMigrationJobTests(PostgresFixture fixture)
{
    [Fact]
    public async Task Job_RunsTwice_OnLegacySeededDatabase_IdempotentlyAndNonDestructively()
    {
        var services = new ServiceCollection()
            .AddXOptiInfrastructure(new InfrastructureOptions { ConnectionString = fixture.ConnectionString })
            .BuildServiceProvider();

        // The fixture already applied migrations over the legacy-seeded schema;
        // re-running the one-shot job must be a no-op, and the legacy tables
        // must remain exactly as the migrated DDL defines them.
        await xOpti.Infrastructure.Jobs.SchemaMigrationJob.MigrateAsync(services);
        await xOpti.Infrastructure.Jobs.SchemaMigrationJob.MigrateAsync(services);

        await using var conn = new Npgsql.NpgsqlConnection(fixture.ConnectionString);
        await conn.OpenAsync();

        await using (var cmd = conn.CreateCommand())
        {
            cmd.CommandText = "SELECT count(*) FROM information_schema.columns WHERE table_schema='public' AND table_name='tx_header'";
            Assert.Equal(28L, Convert.ToInt64(await cmd.ExecuteScalarAsync()));
        }

        await using (var cmd = conn.CreateCommand())
        {
            cmd.CommandText = "SELECT count(*) FROM information_schema.tables WHERE table_schema='platform'";
            Assert.Equal(3L, Convert.ToInt64(await cmd.ExecuteScalarAsync()));
        }
    }
}
