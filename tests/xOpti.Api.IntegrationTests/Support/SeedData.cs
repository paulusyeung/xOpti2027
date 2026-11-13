using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using xOpti.Infrastructure;
using xOpti.Infrastructure.Identity;
using xOpti.Infrastructure.Persistence;
using xOpti.Infrastructure.Persistence.Entities;

namespace xOpti.Api.IntegrationTests.Support;

/// <summary>
/// Reference data and accounts for an API database that already has the
/// migrated schema. Shared by the Testcontainers fixture and the opt-in smoke run
/// (XOPTI_SMOKE_CONNECTION). Idempotent: existing rows are left unchanged.
/// </summary>
public static class SeedData
{
    public const string Password = "Test#Passw0rd1!";

    public static async Task ApplyAsync(string connectionString)
    {
        var options = new Microsoft.EntityFrameworkCore.DbContextOptionsBuilder<XOptiDbContext>()
            .UseNpgsql(connectionString)
            .UseSnakeCaseNamingConvention()
            .Options;

        await using (var ctx = new XOptiDbContext(options))
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

        await SeedUsersAsync(connectionString);
    }

    private static async Task SeedUsersAsync(string connectionString)
    {
        var services = new ServiceCollection();
        services.AddXOptiInfrastructure(new InfrastructureOptions { ConnectionString = connectionString });
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
                     ("purchasing", RolePermissionMatrix.Purchasing),
                     ("admin", RolePermissionMatrix.Admin),
                     ("locked-target", RolePermissionMatrix.Clerk),
                     ("unlocked-reset", RolePermissionMatrix.Clerk),
                 })
        {
            var existing = await users.FindByNameAsync(name);
            if (existing is null)
            {
                var user = new XoptiUser
                {
                    UserName = name,
                    DisplayName = name,
                    Email = $"{name}@example.test",
                    PhoneNumber = "604-555-0100",
                    DefaultBranchCode = "01",
                };
                await users.CreateAsync(user, Password);
                await users.AddToRoleAsync(user, role);
                if (await users.FindByNameAsync(name) is { } u)
                {
                    u.ResetRequired = false;
                    await users.UpdateAsync(u);
                }
            }
        }
    }
}
