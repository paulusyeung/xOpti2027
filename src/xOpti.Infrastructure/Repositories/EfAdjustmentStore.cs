using Microsoft.EntityFrameworkCore;
using xOpti.Application.Inventory.AdjustStock;
using xOpti.Domain.Values;
using xOpti.Infrastructure.Persistence;
using xOpti.Infrastructure.Persistence.Entities;

namespace xOpti.Infrastructure.Repositories;

public sealed class EfAdjustmentStore(XOptiDbContext context) : IAdjustmentStore
{
    public async Task<int> OnHandAsync(string sku, string branchCode, CancellationToken ct) =>
        await context.BranchInventory.AsNoTracking()
            .Where(row => row.BranchCode == branchCode && row.Sku == sku)
            .Select(row => row.QtyOnHand)
            .SingleOrDefaultAsync(ct);

    public async Task<string> NextInventoryControlNumberAsync(CancellationToken ct)
    {
        var preference = await context.Preferences.OrderBy(row => row.SerialNumber).FirstOrDefaultAsync(ct);
        if (preference is null) return "00000001";
        preference.NextInvtControlNumber += 1;
        await context.SaveChangesAsync(ct);
        return preference.NextInvtControlNumber.ToString("D8");
    }

    public async Task PostAsync(AdjustmentPosting posting, CancellationToken ct)
    {
        var now = DateTimeOffset.UtcNow;
        context.TxHeaders.Add(new TxHeader
        {
            ControlNumber = posting.ControlNumber,
            TxType = TransactionType.StockAdjustment,
            TxNumber = posting.TxNumber,
            DateOfEntry = now,
            DateOfCreation = now,
            Particulars = posting.ReasonCode,
            TotalQty = posting.QuantityDelta,
            Status = "0",
        });
        context.TxDetails.Add(new TxDetail
        {
            ControlNumber = posting.ControlNumber,
            TxType = TransactionType.StockAdjustment,
            TxNumber = posting.TxNumber,
            DateOfEntry = now,
            RowNo = 1,
            Sku = posting.Sku,
            Qty = posting.QuantityDelta,
            Remarks = posting.ReasonCode,
        });

        var inventory = await context.InventoryItems.SingleAsync(row => row.Sku == posting.Sku, ct);
        inventory.QtyTotalOnHand += posting.QuantityDelta;
        if (posting.QuantityDelta < 0) inventory.DateLastIssued = now;

        var branch = await context.BranchInventory.SingleOrDefaultAsync(
            row => row.BranchCode == posting.BranchCode && row.Sku == posting.Sku, ct);
        if (branch is null)
        {
            context.BranchInventory.Add(new BranchInventory
            {
                BranchCode = posting.BranchCode, Sku = posting.Sku, QtyOnHand = posting.QuantityDelta,
            });
        }
        else
        {
            branch.QtyOnHand += posting.QuantityDelta;
        }

        if (posting.QuantityDelta > 0)
        {
            context.LotRecords.Add(new InvtLotRecord
            {
                Sku = posting.Sku,
                LotNo = ("ADJ" + posting.ControlNumber)[..Math.Min(10, 3 + posting.ControlNumber.Length)],
                DateReceived = now,
                SupplierCode = string.Empty,
                QtyPurchased = posting.QuantityDelta,
                QtyUsed = 0,
                QtyOnHand = posting.QuantityDelta,
                UnitAmountPurchased = inventory.AverageCost,
                TotalAmountPurchased = Money.From(
                    decimal.Round(inventory.AverageCost.Amount * posting.QuantityDelta, 4)),
            });
        }
        else
        {
            var lot = await context.LotRecords
                .Where(row => row.Sku == posting.Sku && row.QtyOnHand > 0)
                .OrderBy(row => row.DateReceived).ThenBy(row => row.LotNo)
                .FirstOrDefaultAsync(ct);
            if (lot is not null)
            {
                lot.QtyOnHand += posting.QuantityDelta;
                lot.QtyUsed -= posting.QuantityDelta;
            }
        }

        await context.SaveChangesAsync(ct);
    }
}
