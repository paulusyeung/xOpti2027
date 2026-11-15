using Microsoft.EntityFrameworkCore;
using xOpti.Application.Inventory.StockTake;
using xOpti.Infrastructure.Persistence;
using xOpti.Infrastructure.Persistence.Entities;

namespace xOpti.Infrastructure.Repositories;

public sealed class EfStockTakeStore(XOptiDbContext context) : IStockTakeStore, IStockTakeCountStore
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

    public Task<bool> FrozenHeaderExistsAsync(int headerId, CancellationToken ct) =>
        context.StockTakeHeaders.AnyAsync(row => row.Id == headerId && row.Status == 1, ct);

    public Task<bool> SkuInSnapshotAsync(int headerId, string sku, CancellationToken ct) =>
        context.StockTakeDetails.AnyAsync(row => row.HeaderId == headerId && row.Sku == sku, ct);

    public async Task UpsertCountAsync(int headerId, string sku, int qty, CancellationToken ct)
    {
        var row = await context.StockTakeImports
            .SingleOrDefaultAsync(item => item.HeaderId == headerId && item.Sku == sku, ct);
        if (row is null)
        {
            context.StockTakeImports.Add(new InvtSTImport
            {
                HeaderId = headerId, Sku = sku, Qty = qty, Status = 1,
            });
        }
        else
        {
            row.Qty = qty;
            row.Status = 1;
        }

        await context.SaveChangesAsync(ct);
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
