using Microsoft.EntityFrameworkCore;
using xOpti.Application.Inventory.StockTake;
using xOpti.Infrastructure.Persistence;
using xOpti.Infrastructure.Persistence.Entities;

namespace xOpti.Infrastructure.Repositories;

public sealed class EfStockTakeStore(XOptiDbContext context) : IStockTakeStore
{
    public async Task<int> NextHeaderIdAsync(CancellationToken ct) =>
        (await context.StockTakeHeaders.MaxAsync(row => (int?)row.Id, ct) ?? 0) + 1;

    public async Task<IReadOnlyList<StockTakeSnapshotRow>> SnapshotAsync(
        string? branchCode, CancellationToken ct)
    {
        if (!string.IsNullOrWhiteSpace(branchCode))
        {
            var branch = await context.BranchInventory.AsNoTracking()
                .Where(row => row.BranchCode == branchCode)
                .Join(context.InventoryItems.AsNoTracking(),
                    inventory => inventory.Sku, item => item.Sku,
                    (inventory, item) => new StockTakeSnapshotRow(
                        inventory.Sku, inventory.QtyOnHand, item.AverageCost.Amount))
                .ToListAsync(ct);
            return branch;
        }

        return await context.InventoryItems.AsNoTracking()
            .OrderBy(row => row.Sku)
            .Select(row => new StockTakeSnapshotRow(
                row.Sku, row.QtyTotalOnHand, row.AverageCost.Amount))
            .ToListAsync(ct);
    }

    public async Task CreateAsync(StockTakeSnapshot snapshot, DateTimeOffset frozenAt, CancellationToken ct)
    {
        context.StockTakeHeaders.Add(new InvtSTHeader
        {
            Id = snapshot.HeaderId, Name = snapshot.Name, Status = 1, DateOfCreation = DateTime.SpecifyKind(frozenAt.UtcDateTime, DateTimeKind.Unspecified),
        });
        foreach (var row in snapshot.Rows)
        {
            context.StockTakeDetails.Add(new InvtSTDetail
            {
                HeaderId = snapshot.HeaderId, Sku = row.Sku,
                ComputerQty = row.ComputerQty, PhysicalQty = null,
                DiffQty = null, AverageCost = row.AverageCost,
            });
        }

        await context.SaveChangesAsync(ct);
    }
}
