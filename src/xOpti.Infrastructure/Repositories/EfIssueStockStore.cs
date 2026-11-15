using Microsoft.EntityFrameworkCore;
using xOpti.Application.Inventory.IssueStock;
using xOpti.Domain.Rules;
using xOpti.Domain.Values;
using xOpti.Infrastructure.Persistence;
using xOpti.Infrastructure.Persistence.Entities;

namespace xOpti.Infrastructure.Repositories;

public sealed class EfIssueStockStore(XOptiDbContext context) : IIssueStockStore
{
    public async Task<string?> CostingCodeAsync(string sku, CancellationToken ct) =>
        await (from inventory in context.InventoryItems.AsNoTracking()
               join category in context.Categories.AsNoTracking()
                   on new { inventory.DepartmentCode, inventory.ClassCode, inventory.CategoryCode }
                   equals new { DepartmentCode = category.DepartmentCode, ClassCode = category.ClassCode, CategoryCode = category.CategoryCode }
               where inventory.Sku == sku
               select category.CostingMethod).SingleOrDefaultAsync(ct);

    public async Task<IReadOnlyList<CostLayer>> LayersAsync(string sku, CancellationToken ct)
    {
        var lots = await context.LotRecords.AsNoTracking()
            .Where(row => row.Sku == sku && row.QtyOnHand > 0)
            .OrderBy(row => row.DateReceived).ThenBy(row => row.LotNo)
            .ToListAsync(ct);
        var layers = new List<CostLayer>();
        for (var index = 0; index < lots.Count; index++)
        {
            var lot = lots[index];
            var created = CostLayer.Create(lot.LotNo, lot.DateReceived, index,
                lot.UnitAmountPurchased, Quantity.From(lot.QtyOnHand));
            if (created.IsSuccess) layers.Add(created.Value);
        }

        return layers;
    }

    public async Task<Money> FallbackCostAsync(string sku, CancellationToken ct) =>
        (await context.InventoryItems.AsNoTracking().SingleAsync(row => row.Sku == sku, ct)).AverageCost;

    public Task<string> NextControlNumberAsync(CancellationToken ct) =>
        ControlNumberSequencer.NextAsync(context, ct);

    public async Task PostAsync(string txNumber, string controlNumber, string sku, string branchCode,
        int quantity, IReadOnlyList<LayerConsumption> consumptions, int deficitQuantity,
        string? deficitLotNo, string method, string reason, CancellationToken ct)
    {
        var now = DateTimeOffset.UtcNow;
        var totalCost = consumptions.Sum(row => row.Cost.Amount);
        context.TxHeaders.Add(new TxHeader
        {
            ControlNumber = controlNumber,
            TxType = TransactionType.StockAdjustment,
            TxNumber = txNumber,
            DateOfEntry = now,
            DateOfCreation = now,
            Particulars = "Issue: " + reason,
            TotalQty = -quantity,
            TotalCost = Money.From(totalCost),
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
            Qty = -quantity,
            UnitCost = Money.From(quantity == 0 ? 0 : decimal.Round(totalCost / quantity, 4)),
            Amount = Money.From(totalCost),
            Remarks = method,
        });

        foreach (var consumption in consumptions)
        {
            var lot = await context.LotRecords.SingleAsync(row => row.Sku == sku && row.LotNo == consumption.SourceDocument, ct);
            lot.QtyOnHand -= (int)consumption.Quantity.Value;
            lot.QtyUsed += (int)consumption.Quantity.Value;
        }

        var inventory = await context.InventoryItems.SingleAsync(row => row.Sku == sku, ct);
        if (deficitQuantity > 0 && deficitLotNo is not null)
        {
            context.LotRecords.Add(new InvtLotRecord
            {
                Sku = sku, LotNo = deficitLotNo, DateReceived = now, SupplierCode = string.Empty,
                QtyPurchased = 0, QtyUsed = 0, QtyOnHand = -deficitQuantity,
                UnitAmountPurchased = inventory.AverageCost,
                TotalAmountPurchased = Money.From(decimal.Round(inventory.AverageCost.Amount * deficitQuantity, 4)),
            });
        }

        inventory.QtyTotalOnHand -= quantity;
        inventory.DateLastIssued = now;
        var branch = await context.BranchInventory.SingleAsync(
            row => row.BranchCode == branchCode && row.Sku == sku, ct);
        branch.QtyOnHand -= quantity;
        await context.SaveChangesAsync(ct);
    }
}
