using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using xOpti.Infrastructure.Identity;
using xOpti.Infrastructure.Persistence;
using xOpti.Infrastructure.Persistence.Entities;

namespace xOpti.Infrastructure.Bootstrap;

/// <summary>
/// Development/smoke accounts and branches for the compose smoke stack and the
/// E2E suite. Never call this on a production database: the CLI mode refuses
/// unless <c>XOPTI_ALLOW_SMOKE_SEED=1</c> is set.
/// </summary>
public static class SmokeSeed
{
    public const string DefaultPassword = "Test#Passw0rd1!";

    public static async Task ApplyAsync(
        IServiceProvider services,
        string password = DefaultPassword,
        CancellationToken cancellationToken = default)
    {
        await using var scope = services.CreateAsyncScope();
        var context = scope.ServiceProvider.GetRequiredService<XOptiDbContext>();
        var roles = scope.ServiceProvider.GetRequiredService<RoleManager<XoptiRole>>();
        var users = scope.ServiceProvider.GetRequiredService<UserManager<XoptiUser>>();

        foreach (var role in RolePermissionMatrix.KnownRoles)
        {
            if (!await roles.RoleExistsAsync(role))
            {
                var created = await roles.CreateAsync(new XoptiRole { Name = role });
                if (!created.Succeeded)
                {
                    throw new SchemaBootstrapException(
                        $"Could not seed role '{role}': {string.Join("; ", created.Errors.Select(e => e.Description))}");
                }
            }
        }

        for (var i = 1; i <= 7; i++)
        {
            var code = $"0{i}";
            if (!await context.Branches.AnyAsync(b => b.BranchCode == code, cancellationToken))
            {
                context.Branches.Add(new Branch
                {
                    BranchCode = code,
                    BranchName = $"Branch {i}",
                    City = "Richmond",
                });
            }
        }

        // Demo reference/inventory data so stock screens and E2E flows work
        // on a disposable stack.
        if (!await context.Categories.AnyAsync(c => c.DepartmentCode == "01" && c.ClassCode == "01"
            && c.CategoryCode == "01", cancellationToken))
        {
            context.Categories.Add(new Category
            {
                DepartmentCode = "01", ClassCode = "01", CategoryCode = "01",
                CategoryName = "Demo", CostingMethod = "1", InventoryMethod = "1", TaxMethod = "1",
            });
        }

        if (!await context.Suppliers.AnyAsync(supplier => supplier.SupplierCode == "0001", cancellationToken))
        {
            context.Suppliers.Add(new Supplier { SupplierCode = "0001", SupplierName = "Demo Supplier" });
        }

        if (!await context.Brands.AnyAsync(brand => brand.BrandCode == "0001", cancellationToken))
        {
            context.Brands.Add(new Brand { BrandCode = "0001", BrandDescription = "Demo Brand" });
        }

        if (!await context.InventoryItems.AnyAsync(item => item.Sku == "30110359", cancellationToken))
        {
            context.InventoryItems.Add(new Inventory
            {
                Sku = "30110359", DepartmentCode = "01", ClassCode = "01", CategoryCode = "01",
                SupplierCode = "0001", BrandCode = "0001", Name = "Demo Frame",
                QtyTotalOnHand = 10, RetailPriceFlag = true, InventoryLotFlag = true,
            });
        }

        if (!await context.BranchInventory.AnyAsync(row => row.BranchCode == "01" && row.Sku == "30110359",
            cancellationToken))
        {
            context.BranchInventory.Add(new BranchInventory
            {
                BranchCode = "01", Sku = "30110359", QtyOnHand = 10,
            });
        }

        if (!await context.Preferences.AnyAsync(cancellationToken))
        {
            context.Preferences.Add(new Preference
            {
                SerialNumber = "0000000001", Platform = "xOpti", ProductName = "Synergy",
                UserName = "Operator", OwnerName = "Owner", BranchNumber = "0001",
                GstNumber = string.Empty, PstNumber = string.Empty,
                NextInvtControlNumber = 1000, NextInvtSku = 1,
                NextInvoiceNumber = 1, NextSalesOrderNumber = 1,
            });
        }

        foreach (var prefix in new[] { "RC", "RS", "SR", "RJ", "SJ", "WC", "WR", "SA", "LA", "PR", "QT", "TN", "TU" })
        {
            if (!await context.PrefTxNumbers.AnyAsync(row => row.TxPrefix == prefix, cancellationToken))
            {
                context.PrefTxNumbers.Add(new PrefTxNumber
                {
                    TxPrefix = prefix, TxNextNumber = 1000, Description = prefix + " smoke counter",
                });
            }
        }

        await context.SaveChangesAsync(cancellationToken);

        foreach (var (name, role) in new[]
                 {
                     ("manager", RolePermissionMatrix.Manager),
                     ("clerk", RolePermissionMatrix.Clerk),
                     ("purchasing", RolePermissionMatrix.Purchasing),
                     ("admin", RolePermissionMatrix.Admin),
                 })
        {
            if (await users.FindByNameAsync(name) is not null)
            {
                continue;
            }

            var user = new XoptiUser
            {
                UserName = name, DisplayName = name, DefaultBranchCode = "01",
            };
            var created = await users.CreateAsync(user, password);
            if (!created.Succeeded)
            {
                throw new SchemaBootstrapException(
                    $"Could not seed user '{name}': {string.Join("; ", created.Errors.Select(e => e.Description))}");
            }

            await users.AddToRoleAsync(user, role);
            user.ResetRequired = false;
            await users.UpdateAsync(user);
        }
    }
}
