using System.Text.RegularExpressions;
using Testcontainers.PostgreSql;
using xOpti.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace xOpti.Infrastructure.Tests.Support;

/// <summary>
/// Shared Testcontainers PostgreSQL fixture. Seeds the schema from
/// tools/legacy-migration/schema/xopti-schema.sql (the same rebuild path the
/// migration runbook uses) and applies app-owned EF migrations, then reuses
/// the container across the test collection.
/// </summary>
public sealed class PostgresFixture : IAsyncLifetime
{
    private readonly PostgreSqlContainer _container = new PostgreSqlBuilder("postgres:17-alpine")
        .WithUsername("postgres")
        .WithPassword("postgres")
        .WithDatabase("xopti_test")
        .Build();

    public string ConnectionString => _container.GetConnectionString();

    public async Task InitializeAsync()
    {
        await _container.StartAsync();

        await using (var conn = new Npgsql.NpgsqlConnection(ConnectionString))
        {
            await conn.OpenAsync();
            var script = LoadSchemaScript();
            await using (var cmd = conn.CreateCommand())
            {
                cmd.CommandText = script;
                await cmd.ExecuteNonQueryAsync();
            }
        }

        await using var ctx = NewContext();
        await ctx.Database.MigrateAsync();

        await SeedAsync(ctx);
    }

    public async Task DisposeAsync() => await _container.DisposeAsync();

    /// <summary>
    /// Creates a separate, empty database in the shared container so bootstrap
    /// tests start from nothing without paying for another container.
    /// </summary>
    public async Task<string> CreateEmptyDatabaseAsync()
    {
        var name = "xopti_bootstrap_" + Guid.NewGuid().ToString("N")[..12];
        await using (var connection = new Npgsql.NpgsqlConnection(ConnectionString))
        {
            await connection.OpenAsync();
            await using var command = connection.CreateCommand();
            command.CommandText = $"CREATE DATABASE \"{name}\"";
            await command.ExecuteNonQueryAsync();
        }

        var builder = new Npgsql.NpgsqlConnectionStringBuilder(ConnectionString) { Database = name };
        return builder.ConnectionString;
    }

    public static string SchemaFilePath()
    {
        var root = FindRepoRoot();
        return Path.Combine(root, "tools", "legacy-migration", "schema", "xopti-schema.sql");
    }

    public XOptiDbContext NewContext()
    {
        var options = new DbContextOptionsBuilder<XOptiDbContext>()
            .UseNpgsql(ConnectionString)
            .UseSnakeCaseNamingConvention()
            .Options;
        return new XOptiDbContext(options);
    }

    private static string LoadSchemaScript()
    {
        var root = FindRepoRoot();
        var path = Path.Combine(root, "tools", "legacy-migration", "schema", "xopti-schema.sql");
        var lines = File.ReadLines(path)
            .Where(l => !l.StartsWith(@"\"))
            .ToList();
        return string.Join('\n', lines);
    }

    private static string FindRepoRoot()
    {
        var dir = new DirectoryInfo(AppContext.BaseDirectory);
        while (dir is not null && !File.Exists(Path.Combine(dir.FullName, "xOpti.sln")))
        {
            dir = dir.Parent;
        }

        return dir?.FullName ?? throw new DirectoryNotFoundException("xOpti.sln not found above the test output directory.");
    }

    private static async Task SeedAsync(XOptiDbContext ctx)
    {
        foreach (var prefix in new[] { "RC", "RS", "SR", "RJ", "SJ", "WC" })
        {
            if (!await ctx.PrefTxNumbers.AnyAsync(x => x.TxPrefix == prefix))
            {
                ctx.PrefTxNumbers.Add(new Persistence.Entities.PrefTxNumber
                {
                    TxPrefix = prefix,
                    TxNextNumber = 1000,
                    Description = prefix + " seeded for tests",
                });
            }
        }

        if (!await ctx.Branches.AnyAsync())
        {
            for (var i = 1; i <= 7; i++)
            {
                ctx.Branches.Add(new Persistence.Entities.Branch
                {
                    BranchCode = $"0{i}",
                    BranchName = $"Branch {i}",
                    City = "Richmond",
                });
            }
        }

        await ctx.SaveChangesAsync();
    }
}
