using Microsoft.EntityFrameworkCore;
using xOpti.Application.Inventory.Catalogue;
using xOpti.Infrastructure.Persistence;
using xOpti.Infrastructure.Persistence.Entities;

namespace xOpti.Infrastructure.Repositories;

public sealed class EfCatalogueStore(XOptiDbContext context) : ICatalogueStore
{
    public async Task<CatalogueItemDto?> FindAsync(string sku, CancellationToken ct)
    {
        var row = await context.InventoryItems.AsNoTracking().SingleOrDefaultAsync(x => x.Sku == sku, ct);
        return row is null ? null : Map(row);
    }

    public async Task<CatalogueItemDto?> FindForSelectionAsync(string sku, CancellationToken ct)
    {
        var retired = await context.EntityRetirements.AnyAsync(
            row => row.EntityType == "Inventory" && row.EntityKey == sku, ct);
        return retired ? null : await FindAsync(sku, ct);
    }

    public async Task<IReadOnlyList<CatalogueItemDto>> PageAsync(
        string? search, string? afterSku, int limit, CancellationToken ct)
    {
        var retired = context.EntityRetirements
            .Where(row => row.EntityType == "Inventory")
            .Select(row => row.EntityKey);
        var query = context.InventoryItems.AsNoTracking().Where(row => !retired.Contains(row.Sku));
        if (!string.IsNullOrWhiteSpace(search))
        {
            var term = $"%{search.Trim()}%";
            query = query.Where(row =>
                EF.Functions.ILike(row.Name ?? string.Empty, term) || EF.Functions.ILike(row.Sku, term));
        }

        if (!string.IsNullOrEmpty(afterSku))
        {
            query = query.Where(row => row.Sku.CompareTo(afterSku) > 0);
        }

        var rows = await query.OrderBy(row => row.Sku).Take(limit).ToListAsync(ct);
        return rows.Select(Map).ToList();
    }

    public Task<bool> SkuExistsAsync(string sku, CancellationToken ct) =>
        context.InventoryItems.AnyAsync(row => row.Sku == sku, ct);

    public Task<bool> CategoryExistsAsync(string department, string @class, string category, CancellationToken ct) =>
        context.Categories.AnyAsync(row =>
            row.DepartmentCode == department && row.ClassCode == @class && row.CategoryCode == category, ct);

    public Task<bool> SupplierExistsAsync(string code, CancellationToken ct) =>
        context.Suppliers.AnyAsync(row => row.SupplierCode == code, ct);

    public Task<bool> BrandExistsAsync(string code, CancellationToken ct) =>
        context.Brands.AnyAsync(row => row.BrandCode == code, ct);

    public async Task CreateAsync(CatalogueItemDto item, CancellationToken ct)
    {
        context.InventoryItems.Add(new Inventory
        {
            Sku = item.Sku,
            Name = item.Name,
            DepartmentCode = item.DepartmentCode,
            ClassCode = item.ClassCode,
            CategoryCode = item.CategoryCode,
            SupplierCode = item.SupplierCode,
            BrandCode = item.BrandCode,
            MaterialCode = item.MaterialCode,
            InventoryLotFlag = item.LotTracked,
            RetailPriceFlag = item.RetailPriceFlag,
            WholesalePriceFlag = item.WholesalePriceFlag,
            QtyTotalOnHand = item.QtyOnHand,
        });
        await context.SaveChangesAsync(ct);
    }

    public async Task UpdateAsync(CatalogueItemDto item, CancellationToken ct)
    {
        var row = await context.InventoryItems.SingleAsync(x => x.Sku == item.Sku, ct);
        row.Name = item.Name;
        row.DepartmentCode = item.DepartmentCode;
        row.ClassCode = item.ClassCode;
        row.CategoryCode = item.CategoryCode;
        row.SupplierCode = item.SupplierCode;
        row.BrandCode = item.BrandCode;
        row.MaterialCode = item.MaterialCode;
        row.InventoryLotFlag = item.LotTracked;
        row.RetailPriceFlag = item.RetailPriceFlag;
        row.WholesalePriceFlag = item.WholesalePriceFlag;
        await context.SaveChangesAsync(ct);
    }

    public async Task RetireAsync(string sku, string reason, string? actor, CancellationToken ct)
    {
        var existing = await context.EntityRetirements.FindAsync(new object[] { "Inventory", sku }, ct);
        if (existing is null)
        {
            context.EntityRetirements.Add(new EntityRetirement
            {
                EntityType = "Inventory", EntityKey = sku, Reason = reason,
                RetiredBy = actor, RetiredAt = DateTimeOffset.UtcNow,
            });
        }
        else
        {
            existing.Reason = reason;
            existing.RetiredBy = actor;
            existing.RetiredAt = DateTimeOffset.UtcNow;
        }

        await context.SaveChangesAsync(ct);
    }

    public async Task<SkuPricesDto> GetPricesAsync(string sku, CancellationToken ct)
    {
        var retail = await context.RetailPrices.AsNoTracking().SingleOrDefaultAsync(x => x.Sku == sku, ct);
        var wholesale = await context.WholesalePrices.AsNoTracking().SingleOrDefaultAsync(x => x.Sku == sku, ct);
        return new SkuPricesDto(sku,
            retail?.RetailPriceValue, retail?.LeastSellingPrice, retail?.RetailMarkdownAmount,
            retail?.RetailMarkdownPercent, wholesale?.SuggestedRetailPrice,
            wholesale?.GradeA, wholesale?.GradeB, wholesale?.GradeC);
    }

    public async Task SetPricesAsync(SkuPricesDto prices, CancellationToken ct)
    {
        var retail = await context.RetailPrices.SingleOrDefaultAsync(x => x.Sku == prices.Sku, ct);
        if (retail is null)
        {
            context.RetailPrices.Add(new RetailPrice
            {
                Sku = prices.Sku, RetailPriceValue = prices.RetailPrice,
                LeastSellingPrice = prices.LeastSellingPrice,
                RetailMarkdownAmount = prices.RetailMarkdownAmount,
                RetailMarkdownPercent = prices.RetailMarkdownPercent,
            });
        }
        else
        {
            retail.RetailPriceValue = prices.RetailPrice;
            retail.LeastSellingPrice = prices.LeastSellingPrice;
            retail.RetailMarkdownAmount = prices.RetailMarkdownAmount;
            retail.RetailMarkdownPercent = prices.RetailMarkdownPercent;
        }

        var wholesale = await context.WholesalePrices.SingleOrDefaultAsync(x => x.Sku == prices.Sku, ct);
        if (wholesale is null)
        {
            context.WholesalePrices.Add(new WholesalePrice
            {
                Sku = prices.Sku, SuggestedRetailPrice = prices.SuggestedRetailPrice,
                GradeA = prices.GradeA, GradeB = prices.GradeB, GradeC = prices.GradeC,
            });
        }
        else
        {
            wholesale.SuggestedRetailPrice = prices.SuggestedRetailPrice;
            wholesale.GradeA = prices.GradeA;
            wholesale.GradeB = prices.GradeB;
            wholesale.GradeC = prices.GradeC;
        }

        await context.SaveChangesAsync(ct);
    }

    public async Task<BarcodeTagDto?> FindTagAsync(string sku, CancellationToken ct)
    {
        var row = await context.BarCodePool.AsNoTracking()
            .Where(x => x.Sku == sku).OrderByDescending(x => x.Id).FirstOrDefaultAsync(ct);
        return row is null ? null : new BarcodeTagDto(row.TxNumber, row.Sku, row.TxNumber, false);
    }

    public async Task<BarcodeTagDto> CreateTagAsync(string sku, CancellationToken ct)
    {
        var next = (await context.BarCodePool.MaxAsync(row => (int?)row.Id, ct) ?? 0) + 1;
        var barcode = sku;
        context.BarCodePool.Add(new BarCodePool
        {
            Id = next, TxNumber = barcode, Sku = sku,
            DateOfEntry = DateTime.UtcNow, Qty = 1,
        });
        await context.SaveChangesAsync(ct);
        return new BarcodeTagDto(barcode, sku, barcode, false);
    }

    private static CatalogueItemDto Map(Inventory row) => new(
        row.Sku, row.Name, row.DepartmentCode, row.ClassCode, row.CategoryCode,
        row.SupplierCode, row.BrandCode, row.MaterialCode, row.InventoryLotFlag,
        row.RetailPriceFlag, row.WholesalePriceFlag, row.QtyTotalOnHand);
}
