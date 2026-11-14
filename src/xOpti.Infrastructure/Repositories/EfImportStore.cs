using Microsoft.EntityFrameworkCore;
using xOpti.Application.Settings;
using xOpti.Infrastructure.Persistence;
using xOpti.Infrastructure.Persistence.Entities;

namespace xOpti.Infrastructure.Repositories;

public sealed class EfImportStore(XOptiDbContext context) : IImportStore
{
    public Task<bool> ExistsAsync(ImportKind kind, string key, CancellationToken ct) => kind switch
    {
        ImportKind.Sku => context.InventoryItems.AnyAsync(row => row.Sku == key, ct),
        ImportKind.Supplier => context.Suppliers.AnyAsync(row => row.SupplierCode == key, ct),
        _ => context.Brands.AnyAsync(row => row.BrandCode == key, ct),
    };

    public async Task UpsertAsync(ImportKind kind, IReadOnlyDictionary<string, string> row, CancellationToken ct)
    {
        switch (kind)
        {
            case ImportKind.Sku:
                var sku = row["sku"];
                var inventory = await context.InventoryItems.SingleOrDefaultAsync(x => x.Sku == sku, ct);
                if (inventory is null)
                {
                    inventory = new Inventory { Sku = sku };
                    context.InventoryItems.Add(inventory);
                }

                inventory.Name = row.GetValueOrDefault("name");
                inventory.DepartmentCode = row.GetValueOrDefault("departmentCode", "01");
                inventory.ClassCode = row.GetValueOrDefault("classCode", "01");
                inventory.CategoryCode = row.GetValueOrDefault("categoryCode", "01");
                inventory.SupplierCode = row.GetValueOrDefault("supplierCode", "0001");
                inventory.BrandCode = row.GetValueOrDefault("brandCode", "0001");
                break;
            case ImportKind.Supplier:
                var code = row["supplierCode"];
                var supplier = await context.Suppliers.SingleOrDefaultAsync(x => x.SupplierCode == code, ct);
                if (supplier is null)
                {
                    supplier = new Supplier { SupplierCode = code };
                    context.Suppliers.Add(supplier);
                }

                supplier.SupplierName = row.GetValueOrDefault("name");
                break;
            default:
                var brandCode = row["brandCode"];
                var brand = await context.Brands.SingleOrDefaultAsync(x => x.BrandCode == brandCode, ct);
                if (brand is null)
                {
                    brand = new Brand { BrandCode = brandCode };
                    context.Brands.Add(brand);
                }

                brand.BrandDescription = row.GetValueOrDefault("name");
                break;
        }

        await context.SaveChangesAsync(ct);
    }
}
