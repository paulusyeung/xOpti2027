using Microsoft.EntityFrameworkCore;
using xOpti.Application.Reporting;
using xOpti.Infrastructure.Persistence;

namespace xOpti.Infrastructure.Repositories;

/// <summary>
/// Reads bar-code pool rows for a stock-received transaction. One pool row is
/// one physical label, matching the legacy Crystal report's Details section.
/// The joins mirror the legacy report SQL: inventory, retail price, category,
/// brand and class must all exist for a label to be printed.
/// </summary>
public sealed class EfBarCodeTagStore(XOptiDbContext context) : IBarCodeTagStore
{
    public async Task<IReadOnlyList<BarCodeTagLabel>> GetLabelsAsync(
        string fromTxNumber,
        string toTxNumber,
        CancellationToken cancellationToken)
    {
        var query =
            from pool in context.BarCodePool.AsNoTracking()
            where pool.TxNumber.CompareTo(fromTxNumber) >= 0
                  && pool.TxNumber.CompareTo(toTxNumber) <= 0
            join item in context.InventoryItems.AsNoTracking()
                on pool.Sku equals item.Sku
            join price in context.RetailPrices.AsNoTracking()
                on pool.Sku equals price.Sku
            join category in context.Categories.AsNoTracking()
                on new { item.DepartmentCode, item.ClassCode, item.CategoryCode }
                equals new { category.DepartmentCode, category.ClassCode, category.CategoryCode }
            join brand in context.Brands.AsNoTracking()
                on item.BrandCode equals brand.BrandCode
            join cls in context.Classes.AsNoTracking()
                on new { Department = category.DepartmentCode, Class = category.ClassCode }
                equals new { Department = cls.Department, Class = cls.ClassCode }
            // Legacy Crystal emits rows grouped by category (department/class/
            // category) then SKU; duplicates from separate pool rows stay adjacent.
            orderby item.DepartmentCode, item.ClassCode, item.CategoryCode, pool.Sku, pool.Id
            select new BarCodeTagLabel(
                pool.Sku,
                brand.BrandDescription,
                item.Color,
                item.Size,
                price.RetailPriceValue,
                item.Model,
                cls.ClassName);

        return await query.ToListAsync(cancellationToken);
    }
}
