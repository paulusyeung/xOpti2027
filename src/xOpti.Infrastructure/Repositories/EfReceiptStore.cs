using Microsoft.EntityFrameworkCore;
using xOpti.Application.Purchasing.ReceiveStock;
using xOpti.Domain.Values;
using xOpti.Infrastructure.Persistence;
using xOpti.Infrastructure.Persistence.Entities;

namespace xOpti.Infrastructure.Repositories;

public sealed class EfReceiptStore(XOptiDbContext context) : IReceiptStore
{
    public Task<bool> SupplierExistsAsync(string supplierCode, CancellationToken ct) =>
        context.Suppliers.AnyAsync(row => row.SupplierCode == supplierCode, ct);

    public Task<bool> BranchExistsAsync(string branchCode, CancellationToken ct)
    {
        var retired = context.EntityRetirements
            .Where(row => row.EntityType == "Branch").Select(row => row.EntityKey);
        return context.Branches.AnyAsync(row =>
            row.BranchCode == branchCode && !retired.Contains(row.BranchCode), ct);
    }

    public async Task<IReadOnlyList<string>> MissingSkusAsync(
        IEnumerable<string> skus, CancellationToken ct)
    {
        var requested = skus.Distinct(StringComparer.OrdinalIgnoreCase).ToList();
        var found = await context.InventoryItems.AsNoTracking()
            .Where(row => requested.Contains(row.Sku))
            .Select(row => row.Sku)
            .ToListAsync(ct);
        var known = found.ToHashSet(StringComparer.OrdinalIgnoreCase);
        return requested.Where(sku => !known.Contains(sku)).ToList();
    }

    public Task<string> NextInventoryControlNumberAsync(CancellationToken ct) =>
        ControlNumberSequencer.NextAsync(context, ct);

    public async Task PostAsync(ReceiptPosting posting, CancellationToken ct)
    {
        var now = DateTimeOffset.UtcNow;
        context.TxHeaders.Add(new TxHeader
        {
            ControlNumber = posting.ControlNumber,
            TxType = TransactionType.StockReceived,
            TxNumber = posting.TxNumber,
            DateOfEntry = now,
            DateOfCreation = now,
            SupplierCode = posting.SupplierCode,
            TotalCost = Money.From(posting.TotalCost),
            TotalSale = Money.From(posting.TotalCost),
            TaxA = Money.From(decimal.Round(posting.Lines.Sum(l => l.GstAmount), 4)),
            TaxB = Money.From(decimal.Round(posting.Lines.Sum(l => l.PstAmount), 4)),
            GrossSale = Money.From(decimal.Round(posting.TotalCost + posting.TotalTax, 4)),
            TotalAmount = Money.From(decimal.Round(posting.TotalCost + posting.TotalTax, 4)),
            TotalQty = posting.TotalQuantity,
            Status = "0",
        });

        for (var index = 0; index < posting.Lines.Count; index++)
        {
            var line = posting.Lines[index];
            var amount = decimal.Round(line.UnitCost * line.Quantity, 4);
            context.TxDetails.Add(new TxDetail
            {
                ControlNumber = posting.ControlNumber,
                TxType = TransactionType.StockReceived,
                TxNumber = posting.TxNumber,
                DateOfEntry = now,
                RowNo = index + 1,
                Sku = line.Sku,
                Qty = line.Quantity,
                UnitAmount = Money.From(line.UnitCost),
                UnitCost = Money.From(line.UnitCost),
                Amount = Money.From(amount),
                TaxCode = line.TaxCode,
            });

            var lot = await context.LotRecords.SingleOrDefaultAsync(
                row => row.Sku == line.Sku && row.LotNo == line.LotNo, ct);
            if (lot is null)
            {
                context.LotRecords.Add(new InvtLotRecord
                {
                    Sku = line.Sku,
                    LotNo = line.LotNo,
                    DateReceived = now,
                    SupplierCode = posting.SupplierCode,
                    QtyPurchased = line.Quantity,
                    QtyUsed = 0,
                    QtyOnHand = line.Quantity,
                    UnitAmountPurchased = Money.From(line.UnitCost),
                    TotalAmountPurchased = Money.From(amount),
                });
            }
            else
            {
                lot.QtyPurchased += line.Quantity;
                lot.QtyOnHand += line.Quantity;
                lot.TotalAmountPurchased += Money.From(amount);
            }

            var inventory = await context.InventoryItems.SingleAsync(row => row.Sku == line.Sku, ct);
            var onHand = inventory.QtyTotalOnHand;
            if (onHand + line.Quantity > 0 && inventory.AverageCost.Amount > 0)
            {
                var blended = (amount + inventory.AverageCost.Amount * onHand) / (onHand + line.Quantity);
                inventory.AverageCost = Money.From(decimal.Round(Math.Abs(blended), 4));
            }
            else
            {
                inventory.AverageCost = Money.From(line.UnitCost);
            }

            inventory.QtyTotalOnHand += line.Quantity;
            inventory.DateLastReceived = now;

            var branch = await context.BranchInventory.SingleOrDefaultAsync(
                row => row.BranchCode == posting.BranchCode && row.Sku == line.Sku, ct);
            if (branch is null)
            {
                context.BranchInventory.Add(new BranchInventory
                {
                    BranchCode = posting.BranchCode, Sku = line.Sku, QtyOnHand = line.Quantity,
                });
            }
            else
            {
                branch.QtyOnHand += line.Quantity;
            }
        }

        await context.SaveChangesAsync(ct);
    }
}
