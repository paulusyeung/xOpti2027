using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Testcontainers.PostgreSql;
using xOpti.Infrastructure;
using xOpti.Infrastructure.Identity;
using xOpti.Infrastructure.Persistence;
using xOpti.Infrastructure.Persistence.Entities;

namespace xOpti.Api.IntegrationTests.Support;

/// <summary>
/// One Testcontainers PostgreSQL database shared by the API collection.
/// Seeded with the migrated schema (tools/legacy-migration/schema), EF
/// migrations, pref counters, seven branches, and manager/clerk accounts.
/// </summary>
public sealed class ApiPostgresFixture : IAsyncLifetime
{
    private readonly PostgreSqlContainer _container = new PostgreSqlBuilder("postgres:17-alpine").Build();

    public string ConnectionString => _container.GetConnectionString();

    public string SessionCookieName => "xopti.session";

    public async Task InitializeAsync()
    {
        await _container.StartAsync();

        await using (var conn = new Npgsql.NpgsqlConnection(ConnectionString))
        {
            await conn.OpenAsync();
            var script = string.Join('\n', File.ReadLines(SchemaPath()).Where(l => !l.StartsWith(@"\")));
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = script;
            await cmd.ExecuteNonQueryAsync();
        }

        await using (var ctx = NewContext())
        {
            await ctx.Database.MigrateAsync();
        }

        await SeedData.ApplyAsync(ConnectionString);
    }

    public async Task DisposeAsync() => await _container.DisposeAsync();

    public XOptiDbContext NewContext()
    {
        var options = new DbContextOptionsBuilder<XOptiDbContext>()
            .UseNpgsql(ConnectionString)
            .UseSnakeCaseNamingConvention()
            .Options;
        return new XOptiDbContext(options);
    }

    public int PrefCounter(string prefix)
    {
        using var ctx = NewContext();
        return ctx.PrefTxNumbers.AsNoTracking().Single(p => p.TxPrefix == prefix).TxNextNumber;
    }

    private static string SchemaPath()
    {
        var dir = new DirectoryInfo(AppContext.BaseDirectory);
        while (dir is not null && !File.Exists(Path.Combine(dir.FullName, "xOpti.sln")))
        {
            dir = dir.Parent;
        }

        return Path.Combine(dir!.FullName, "tools", "legacy-migration", "schema", "xopti-schema.sql");
    }
}

/// <summary>
/// Minimal-API factory wired to the shared container database.
/// </summary>
public sealed class XOptiApiFactory : WebApplicationFactory<Program>
{
    private readonly ApiPostgresFixture _fixture;
    private readonly Dictionary<string, string?> _overrides;

    public XOptiApiFactory(ApiPostgresFixture fixture, Dictionary<string, string?>? overrides = null)
    {
        _fixture = fixture;
        _overrides = overrides ?? new();
    }

    protected override void ConfigureWebHost(Microsoft.AspNetCore.Hosting.IWebHostBuilder builder)
    {
        var settings = new Dictionary<string, string?>(_overrides)
        {
            ["ConnectionStrings:XOptiDatabase"] = _fixture.ConnectionString,
            ["XOptiApi:FileStorageRoot"] = Path.Combine(Path.GetTempPath(), "xopti-api-files-" + Guid.NewGuid().ToString("N")[..8]),
            ["XOptiApi:JobsEnabled"] = "false",
            ["XOptiApi:SessionIdle"] = "00:20:00",
        };

        builder.UseSetting("ConnectionStrings:XOptiDatabase", _fixture.ConnectionString);
        builder.UseSetting("XOptiApi:FileStorageRoot", settings["XOptiApi:FileStorageRoot"]);
        builder.UseSetting("XOptiApi:JobsEnabled", "false");

        foreach (var (key, value) in _overrides)
        {
            builder.UseSetting(key, value);
        }

        base.ConfigureWebHost(builder);
    }
}
