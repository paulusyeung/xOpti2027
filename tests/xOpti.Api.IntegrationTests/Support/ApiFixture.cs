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

        await using (var ctx = NewContext())
        {
            foreach (var prefix in new[] { "RC", "RS", "SR", "RJ", "SJ", "WC" })
            {
                if (!await ctx.PrefTxNumbers.AnyAsync(x => x.TxPrefix == prefix))
                {
                    ctx.PrefTxNumbers.Add(new PrefTxNumber
                    {
                        TxPrefix = prefix,
                        TxNextNumber = 1000,
                        Description = prefix + " seeded for API tests",
                    });
                }
            }

            for (var i = 1; i <= 7; i++)
            {
                var code = $"0{i}";
                if (!await ctx.Branches.AnyAsync(b => b.BranchCode == code))
                {
                    ctx.Branches.Add(new Branch { BranchCode = code, BranchName = $"Branch {i}", City = "Richmond" });
                }
            }

            if (!await ctx.InventoryItems.AnyAsync(i => i.Sku == "30110359"))
            {
                ctx.InventoryItems.Add(new Inventory
                {
                    Sku = "30110359",
                    DepartmentCode = "01",
                    ClassCode = "01",
                    CategoryCode = "01",
                    SupplierCode = "0001",
                    BrandCode = "0001",
                    Name = "Test Frame",
                    QtyTotalOnHand = 10,
                    RetailPriceFlag = true,
                });
            }

            await ctx.SaveChangesAsync();
        }

        await SeedUsersAsync();
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

    private async Task SeedUsersAsync()
    {
        var services = new ServiceCollection();
        services.AddXOptiInfrastructure(new InfrastructureOptions { ConnectionString = ConnectionString });
        services.AddXOptiIdentity();
        var provider = services.BuildServiceProvider();

        using var scope = provider.CreateScope();
        var users = scope.ServiceProvider.GetRequiredService<UserManager<XoptiUser>>();
        var roles = scope.ServiceProvider.GetRequiredService<RoleManager<XoptiRole>>();

        foreach (var role in RolePermissionMatrix.KnownRoles)
        {
            if (!await roles.RoleExistsAsync(role))
            {
                await roles.CreateAsync(new XoptiRole { Name = role });
            }
        }

        foreach (var (name, role) in new[]
                 {
                     ("manager", RolePermissionMatrix.Manager),
                     ("clerk", RolePermissionMatrix.Clerk),
                     ("locked-target", RolePermissionMatrix.Clerk),
                     ("unlocked-reset", RolePermissionMatrix.Clerk),
                 })
        {
            var existing = await users.FindByNameAsync(name);
            if (existing is null)
            {
                var user = new XoptiUser { UserName = name, DisplayName = name };
                await users.CreateAsync(user, "Test#Passw0rd1!");
                await users.AddToRoleAsync(user, role);
                if (await users.FindByNameAsync(name) is { } u)
                {
                    u.ResetRequired = false;
                    await users.UpdateAsync(u);
                }
            }
        }
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
