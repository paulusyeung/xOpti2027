using Microsoft.EntityFrameworkCore;
using xOpti.Application.Inventory.Reconciliation;
using xOpti.Infrastructure.Persistence;

namespace xOpti.Infrastructure.Repositories;

public sealed class EfInventoryReconciliationStore(XOptiDbContext context) : IInventoryReconciliationStore
{
    public async Task<InventoryReconciliationDto> CheckAsync(CancellationToken ct)
    {
        var inventory = await context.InventoryItems.AsNoTracking()
            .Select(row => new { row.Sku, row.QtyTotalOnHand }).ToListAsync(ct);
        var lots = await context.LotRecords.AsNoTracking()
            .GroupBy(row => row.Sku)
            .Select(group => new { Sku = group.Key, Quantity = group.Sum(row => row.QtyOnHand) })
            .ToDictionaryAsync(row => row.Sku, row => row.Quantity, ct);
        var lotKeys = await context.LotRecords.AsNoTracking()
            .GroupBy(row => row.Sku)
            .Select(group => new
            {
                Sku = group.Key,
                Affected = group.Where(row => row.QtyOnHand != 0)
                    .Select(row => row.LotNo).ToList(),
            })
            .ToDictionaryAsync(row => row.Sku, row => row.Affected, ct);

        var drifts = inventory
            .Select(row => new
            {
                row.Sku,
                Inventory = row.QtyTotalOnHand,
                Lots = lots.GetValueOrDefault(row.Sku, 0),
            })
            .Where(row => row.Inventory != row.Lots)
            .Select(row => new ReconciliationRowDto(row.Sku, row.Inventory, row.Lots,
                row.Inventory - row.Lots, lotKeys.GetValueOrDefault(row.Sku) ?? new List<string>()))
            .ToList();

        return new InventoryReconciliationDto(inventory.Count, drifts);
    }
}
