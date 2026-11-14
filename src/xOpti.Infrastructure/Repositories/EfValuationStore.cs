using Microsoft.EntityFrameworkCore;
using xOpti.Application.Inventory.Valuation;
using xOpti.Infrastructure.Persistence;
using xOpti.Domain.Values;

namespace xOpti.Infrastructure.Repositories;

public sealed class EfValuationStore(XOptiDbContext context) : IValuationStore
{
    public async Task<InventoryValuationDto?> GetAsync(string sku, CancellationToken ct)
    {
        var inventory = await context.InventoryItems.AsNoTracking()
            .SingleOrDefaultAsync(row => row.Sku == sku, ct);
        if (inventory is null) return null;

        var lotRows = await context.LotRecords.AsNoTracking()
            .Where(row => row.Sku == sku)
            .OrderBy(row => row.DateReceived).ThenBy(row => row.LotNo)
            .ToListAsync(ct);

        var lots = lotRows.Select(row =>
        {
            var unit = row.UnitAmountPurchased;
            var extended = Money.From(decimal.Round(unit.Amount * row.QtyOnHand, 4));
            return new LotValuationDto(row.LotNo, row.QtyOnHand, unit, extended);
        }).ToList();

        var extendedTotal = Money.From(decimal.Round(
            lots.Sum(lot => lot.ExtendedCost?.Amount ?? 0m), 4));

        return new InventoryValuationDto(
            sku, inventory.QtyTotalOnHand, lots, inventory.AverageCost, extendedTotal);
    }
}
