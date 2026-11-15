using Microsoft.EntityFrameworkCore;
using xOpti.Application.Inventory.StockTake;
using xOpti.Domain.Values;
using xOpti.Infrastructure.Persistence;
using xOpti.Infrastructure.Persistence.Entities;

namespace xOpti.Infrastructure.Repositories;

public sealed class EfStockTakeStore(XOptiDbContext context) : IStockTakeStore, IStockTakeCountStore, IStockTakeVarianceStore, IStockTakePostingStore
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

    public async Task<StockTakeVarianceDto?> GetAsync(int headerId, CancellationToken ct)
    {
        var header = await context.StockTakeHeaders.AsNoTracking().SingleOrDefaultAsync(row => row.Id == headerId, ct);
        if (header is null) return null;
        var counts = await context.StockTakeImports.AsNoTracking()
            .Where(row => row.HeaderId == headerId)
            .ToDictionaryAsync(row => row.Sku, row => row.Qty, ct);
        var details = await context.StockTakeDetails.AsNoTracking()
            .Where(row => row.HeaderId == headerId).OrderBy(row => row.Sku).ToListAsync(ct);
        var rows = details.Select(row =>
        {
            var counted = counts.TryGetValue(row.Sku, out var qty) ? qty : (int?)null;
            return new VarianceRowDto(row.Sku, (decimal?)row.ComputerQty, counted,
                counted is null ? null : counted - (decimal?)row.ComputerQty, row.AverageCost);
        }).ToList();
        return new StockTakeVarianceDto(header.Id, header.Name, header.Status ?? 0, rows);
    }

    public async Task ApproveAsync(int headerId, CancellationToken ct)
    {
        var header = await context.StockTakeHeaders.SingleAsync(row => row.Id == headerId, ct);
        header.Status = 2;
        header.DateOfUpdate = DateTime.SpecifyKind(DateTime.UtcNow, DateTimeKind.Unspecified);
        var details = await context.StockTakeDetails.Where(row => row.HeaderId == headerId).ToListAsync(ct);
        var counts = await context.StockTakeImports.Where(row => row.HeaderId == headerId)
            .ToDictionaryAsync(row => row.Sku, row => row.Qty, ct);
        foreach (var detail in details)
        {
            if (counts.TryGetValue(detail.Sku, out var counted))
            {
                detail.PhysicalQty = counted;
                detail.DiffQty = counted - detail.ComputerQty;
            }
        }

        await context.SaveChangesAsync(ct);
    }

    public Task<bool> IsApprovedAsync(int headerId, CancellationToken ct) =>
        context.StockTakeHeaders.AnyAsync(row => row.Id == headerId && row.Status == 2, ct);

    public Task<string> NextInventoryControlNumberAsync(CancellationToken ct) =>
        ControlNumberSequencer.NextAsync(context, ct);

    public async Task PostAsync(int headerId, string txNumber, string controlNumber,
        IReadOnlyList<StockTakeAdjustmentRow> rows, CancellationToken ct)
    {
        var now = DateTimeOffset.UtcNow;
        var header = await context.StockTakeHeaders.SingleAsync(row => row.Id == headerId, ct);
        header.Status = 3;
        header.DateOfUpdate = DateTime.SpecifyKind(DateTime.UtcNow, DateTimeKind.Unspecified);

        context.TxHeaders.Add(new TxHeader
        {
            ControlNumber = controlNumber,
            TxType = TransactionType.StockAdjustment,
            TxNumber = txNumber,
            DateOfEntry = now,
            DateOfCreation = now,
            RefNumber = $"STK{headerId}",
            Particulars = "Stock-take variance",
            TotalQty = rows.Sum(row => row.Difference),
            Status = "0",
        });

        var rowNo = 1;
        foreach (var row in rows)
        {
            context.TxDetails.Add(new TxDetail
            {
                ControlNumber = controlNumber,
                TxType = TransactionType.StockAdjustment,
                TxNumber = txNumber,
                DateOfEntry = now,
                RowNo = rowNo++,
                Sku = row.Sku,
                Qty = row.Difference,
                Remarks = $"STK{headerId}",
            });

            var inventory = await context.InventoryItems.SingleAsync(item => item.Sku == row.Sku, ct);
            inventory.QtyTotalOnHand += row.Difference;
        }

        await context.SaveChangesAsync(ct);
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
