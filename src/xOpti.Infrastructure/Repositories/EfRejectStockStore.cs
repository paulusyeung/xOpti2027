using Microsoft.EntityFrameworkCore;
using xOpti.Application.Purchasing.RejectStock;
using xOpti.Domain.Values;
using xOpti.Infrastructure.Persistence;
using xOpti.Infrastructure.Persistence.Entities;

namespace xOpti.Infrastructure.Repositories;

public sealed class EfRejectStockStore(XOptiDbContext context) : IRejectStockStore
{
    public async Task<int> AvailableQuantityAsync(string sku, string lotNo, CancellationToken ct)
    {
        var lot = await context.LotRecords.AsNoTracking()
            .SingleOrDefaultAsync(row => row.Sku == sku && row.LotNo == lotNo, ct);
        return lot?.QtyOnHand ?? 0;
    }

    public Task<string> NextInventoryControlNumberAsync(CancellationToken ct) =>
        ControlNumberSequencer.NextAsync(context, ct);

    public async Task PostAsync(RejectPosting posting, CancellationToken ct)
    {
        var now = DateTimeOffset.UtcNow;
        context.TxHeaders.Add(new TxHeader
        {
            ControlNumber = posting.ControlNumber,
            TxType = TransactionType.StockRejected,
            TxNumber = posting.TxNumber,
            DateOfEntry = now,
            DateOfCreation = now,
            SupplierCode = posting.SupplierCode,
            RefNumber = posting.OriginalTxNumber,
            TotalCost = Money.From(-posting.TotalCost),
            TotalSale = Money.From(-posting.TotalCost),
            TaxA = Money.From(-decimal.Round(posting.Lines.Sum(l => l.GstAmount), 4)),
            TaxB = Money.From(-decimal.Round(posting.Lines.Sum(l => l.PstAmount), 4)),
            GrossSale = Money.From(-decimal.Round(posting.TotalCost + posting.TotalTax, 4)),
            TotalAmount = Money.From(-decimal.Round(posting.TotalCost + posting.TotalTax, 4)),
            TotalQty = -posting.TotalQuantity,
            Status = "0",
        });

        for (var index = 0; index < posting.Lines.Count; index++)
        {
            var line = posting.Lines[index];
            var amount = decimal.Round(line.UnitCost * line.Quantity, 4);
            context.TxDetails.Add(new TxDetail
            {
                ControlNumber = posting.ControlNumber,
                TxType = TransactionType.StockRejected,
                TxNumber = posting.TxNumber,
                DateOfEntry = now,
                RowNo = index + 1,
                Sku = line.Sku,
                Qty = -line.Quantity,
                UnitAmount = Money.From(line.UnitCost),
                UnitCost = Money.From(line.UnitCost),
                Amount = Money.From(-amount),
                TaxCode = line.TaxCode,
            });

            var lot = await context.LotRecords.SingleAsync(
                row => row.Sku == line.Sku && row.LotNo == line.LotNo, ct);
            lot.QtyOnHand -= line.Quantity;
            lot.QtyUsed += line.Quantity;

            var inventory = await context.InventoryItems.SingleAsync(row => row.Sku == line.Sku, ct);
            inventory.QtyTotalOnHand -= line.Quantity;
            inventory.DateLastIssued = now;

            var branch = await context.BranchInventory.SingleAsync(
                row => row.BranchCode == posting.BranchCode && row.Sku == line.Sku, ct);
            branch.QtyOnHand -= line.Quantity;
        }

        await context.SaveChangesAsync(ct);
    }
}
