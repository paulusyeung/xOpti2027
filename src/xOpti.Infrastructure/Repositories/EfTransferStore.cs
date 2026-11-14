using Microsoft.EntityFrameworkCore;
using xOpti.Application.Inventory.TransferStock;
using xOpti.Domain.Values;
using xOpti.Infrastructure.Persistence;
using xOpti.Infrastructure.Persistence.Entities;

namespace xOpti.Infrastructure.Repositories;

public sealed class EfTransferStore(XOptiDbContext context) : ITransferStore
{
    public Task<bool> BranchExistsAsync(string branchCode, CancellationToken ct)
    {
        var retired = context.EntityRetirements
            .Where(row => row.EntityType == "Branch").Select(row => row.EntityKey);
        return context.Branches.AnyAsync(row =>
            row.BranchCode == branchCode && !retired.Contains(row.BranchCode), ct);
    }

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

    public async Task PostAsync(TransferPosting posting, CancellationToken ct)
    {
        var now = DateTimeOffset.UtcNow;
        WriteHeader(posting.SourceTxNumber, posting.ControlNumber, posting.TransferId,
            posting.Sku, posting.FromBranch, -posting.Quantity, now, "Transfer out: " + posting.Reason);
        WriteHeader(posting.DestinationTxNumber, posting.ControlNumber, posting.TransferId,
            posting.Sku, posting.ToBranch, posting.Quantity, now, "Transfer in: " + posting.Reason);

        var source = await context.BranchInventory.SingleAsync(
            row => row.BranchCode == posting.FromBranch && row.Sku == posting.Sku, ct);
        source.QtyOnHand -= posting.Quantity;

        var destination = await context.BranchInventory.SingleOrDefaultAsync(
            row => row.BranchCode == posting.ToBranch && row.Sku == posting.Sku, ct);
        if (destination is null)
        {
            context.BranchInventory.Add(new BranchInventory
            {
                BranchCode = posting.ToBranch, Sku = posting.Sku, QtyOnHand = posting.Quantity,
            });
        }
        else
        {
            destination.QtyOnHand += posting.Quantity;
        }

        var inventory = await context.InventoryItems.SingleAsync(row => row.Sku == posting.Sku, ct);
        inventory.DateLastIssued = now;
        inventory.DateLastReceived = now;

        await context.SaveChangesAsync(ct);
    }

    private void WriteHeader(
        string txNumber, string controlNumber, string transferId,
        string sku, string branch, int quantity, DateTimeOffset now, string remarks)
    {
        context.TxHeaders.Add(new TxHeader
        {
            ControlNumber = controlNumber,
            TxType = TransactionType.StockAdjustment,
            TxNumber = txNumber,
            DateOfEntry = now,
            DateOfCreation = now,
            TrackingNumber = transferId,
            Particulars = remarks,
            TotalQty = quantity,
            Status = "0",
        });
        context.TxDetails.Add(new TxDetail
        {
            ControlNumber = controlNumber,
            TxType = TransactionType.StockAdjustment,
            TxNumber = txNumber,
            DateOfEntry = now,
            RowNo = 1,
            Sku = sku,
            Qty = quantity,
            Remarks = $"branch {branch}",
        });
    }
}
