using Microsoft.EntityFrameworkCore;
using xOpti.Domain.Rules;
using xOpti.Domain.Values;
using xOpti.Infrastructure.Persistence;
using xOpti.Infrastructure.Persistence.Entities;

namespace xOpti.Infrastructure.Repositories;

/// <summary>
/// Shared POS inventory posting: consume cost layers for a sale and restore
/// stock for an approved refund. Both run inside the caller's transaction.
/// </summary>
internal static class InventoryPosting
{
    public static async Task<decimal> ConsumeAsync(
        XOptiDbContext context, string sku, int quantity, string issueDocument,
        DateTimeOffset now, string branchCode, CancellationToken ct)
    {
        await LockAsync(context, sku, ct);
        var inventory = await context.InventoryItems.SingleAsync(row => row.Sku == sku, ct);
        var code = await (from item in context.InventoryItems.AsNoTracking()
                          join category in context.Categories.AsNoTracking()
                              on new { item.DepartmentCode, item.ClassCode, item.CategoryCode }
                              equals new { category.DepartmentCode, category.ClassCode, category.CategoryCode }
                          where item.Sku == sku
                          select category.CostingMethod).SingleOrDefaultAsync(ct);
        var method = code?.Trim() switch
        {
            "2" => CategoryCostingMethod.Lifo,
            "3" => CategoryCostingMethod.Average,
            _ => CategoryCostingMethod.Fifo,
        };

        var lots = await context.LotRecords.Where(row => row.Sku == sku && row.QtyOnHand > 0)
            .OrderBy(row => row.DateReceived).ThenBy(row => row.LotNo).ToListAsync(ct);
        var layers = lots.Select((lot, index) => CostLayer.Create(lot.LotNo, lot.DateReceived, index,
            lot.UnitAmountPurchased, Quantity.From(lot.QtyOnHand)).Value).ToList();
        var result = CostingPolicy.Issue(layers, issueDocument, Quantity.From(quantity), method,
            inventory.AverageCost);
        if (!result.IsSuccess)
        {
            throw new InvalidOperationException(result.Error);
        }

        foreach (var consumption in result.Value.Consumptions)
        {
            var lot = lots.Single(row => row.LotNo == consumption.SourceDocument);
            lot.QtyOnHand -= (int)consumption.Quantity.Value;
            lot.QtyUsed += (int)consumption.Quantity.Value;
        }

        var deficitQuantity = (int)result.Value.DeficitQuantity.Value;
        if (deficitQuantity > 0)
        {
            context.LotRecords.Add(new InvtLotRecord
            {
                Sku = sku, LotNo = "DEF" + issueDocument[^7..], DateReceived = now,
                SupplierCode = string.Empty, QtyPurchased = 0, QtyUsed = 0,
                QtyOnHand = -deficitQuantity, UnitAmountPurchased = inventory.AverageCost,
                TotalAmountPurchased = Money.From(decimal.Round(
                    inventory.AverageCost.Amount * deficitQuantity, 4)),
            });
        }

        ApplyOnHand(context, sku, -quantity, branchCode);
        inventory.DateLastIssued = now;
        return result.Value.TotalCost.Amount;
    }

    /// <summary>
    /// Restores refunded stock into a lot keyed by the refund document. The
    /// original invoice does not retain a lot reference per line, so the
    /// returned quantity gets a new cost layer at the original line cost.
    /// </summary>
    public static async Task RestockAsync(
        XOptiDbContext context, string sku, int quantity, decimal unitCost,
        string restockDocument, DateTimeOffset now, string branchCode, CancellationToken ct)
    {
        await LockAsync(context, sku, ct);
        var lotNo = "RS" + restockDocument[^8..];
        var existing = await context.LotRecords.SingleOrDefaultAsync(
            row => row.Sku == sku && row.LotNo == lotNo, ct);
        if (existing is null)
        {
            context.LotRecords.Add(new InvtLotRecord
            {
                Sku = sku, LotNo = lotNo, DateReceived = now, SupplierCode = string.Empty,
                QtyPurchased = 0, QtyUsed = 0, QtyOnHand = quantity,
                UnitAmountPurchased = Money.From(unitCost),
                TotalAmountPurchased = Money.From(decimal.Round(unitCost * quantity, 4)),
            });
        }
        else
        {
            existing.QtyOnHand += quantity;
            existing.TotalAmountPurchased = Money.From(decimal.Round(
                existing.TotalAmountPurchased.Amount + unitCost * quantity, 4));
        }

        ApplyOnHand(context, sku, quantity, branchCode);
        var inventory = await context.InventoryItems.SingleAsync(row => row.Sku == sku, ct);
        inventory.DateLastReceived = now;
    }

    /// <summary>Serializes stock mutations for a SKU within the caller's transaction.</summary>
    private static Task LockAsync(XOptiDbContext context, string sku, CancellationToken ct) =>
        context.Database.ExecuteSqlInterpolatedAsync(
            $"SELECT 1 FROM public.inventory WHERE sku = {sku} FOR UPDATE", ct);

    private static void ApplyOnHand(XOptiDbContext context, string sku, int delta, string branchCode)
    {
        var inventory = context.InventoryItems.Single(row => row.Sku == sku);
        inventory.QtyTotalOnHand += delta;
        var branch = context.BranchInventory.SingleOrDefault(row =>
            row.BranchCode == branchCode && row.Sku == sku);
        if (branch is not null) branch.QtyOnHand += delta;
    }
}
