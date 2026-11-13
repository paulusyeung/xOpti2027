using Microsoft.EntityFrameworkCore;
using xOpti.Application.Inventory.GetInventorySummary;
using xOpti.Infrastructure.Persistence;

namespace xOpti.Infrastructure.Repositories;

/// <summary>Read-only inventory summary projection (cost masking happens above).</summary>
public sealed class EfInventorySummaryRepository(XOptiDbContext context) : IInventorySummaryRepository
{
    public async Task<InventorySummary?> FindBySkuAsync(string sku, CancellationToken cancellationToken)
    {
        var inventory = await context.InventoryItems
            .AsNoTracking()
            .SingleOrDefaultAsync(item => item.Sku == sku, cancellationToken);

        return inventory is null
            ? null
            : new InventorySummary(
            inventory.Sku,
            inventory.Name,
            inventory.QtyTotalOnHand,
            inventory.InventoryLotFlag,
                inventory.AverageCost);
    }
}
