using xOpti.Domain.Common;
using xOpti.Domain.Values;

namespace xOpti.Domain.Rules;

/// <summary>
/// Inventory costing method per category. Legacy AppOLTP.bas treats code "2"
/// as LIFO (FindLast) and everything else as Average/FIFO (FindFirst).
/// </summary>
public enum CategoryCostingMethod
{
    Fifo,
    Average,
    Lifo,
}

public static class CostingMethodResolver
{
    public const string LifoLegacyCode = "2";

    public static CategoryCostingMethod FromLegacyCode(
        string? legacyCode,
        CategoryCostingMethod nonLifoDefault = CategoryCostingMethod.Fifo)
    {
        return string.Equals(legacyCode?.Trim(), LifoLegacyCode, StringComparison.Ordinal)
            ? CategoryCostingMethod.Lifo
            : nonLifoDefault;
    }
}

/// <summary>One line of an issue: quantity taken from a named layer at a unit cost.</summary>
public sealed record LayerConsumption(string SourceDocument, Quantity Quantity, Money UnitCost, Money Cost);

/// <summary>
/// Outcome of costing an inventory issue. DeficitQuantity/DeficitLayer capture
/// stock sold before receipt so POS can complete; they are cleared later by
/// <see cref="CostLayer.Reconcile"/>.
/// </summary>
public sealed record IssueResult(
    IReadOnlyList<LayerConsumption> Consumptions,
    Money TotalCost,
    Quantity DeficitQuantity,
    CostLayer? DeficitLayer);

/// <summary>
/// Cost-layer consumption ordering per category costing method, with
/// deficit allocation when on-hand layers are depleted.
/// </summary>
public static class CostingPolicy
{
    public static Result<IssueResult> Issue(
        IReadOnlyList<CostLayer> layers,
        string issueDocument,
        Quantity quantity,
        CategoryCostingMethod method,
        Money fallbackCost,
        int costScale = Money.StorageScale,
        MidpointRounding rounding = MidpointRounding.AwayFromZero)
    {
        if (quantity.IsZero || quantity.IsNegative)
        {
            return Result<IssueResult>.Failure("Issue quantity must be positive.");
        }

        if (string.IsNullOrWhiteSpace(issueDocument))
        {
            return Result<IssueResult>.Failure("Issue requires a source document identifier.");
        }

        if (costScale is < 0 or > Money.StorageScale)
        {
            return Result<IssueResult>.Failure($"Cost scale must be between 0 and {Money.StorageScale}.");
        }

        var available = layers
            .Where(l => !l.IsDeficit && l.RemainingQuantity > Quantity.Zero)
            .ToList();

        var ordered = method switch
        {
            CategoryCostingMethod.Lifo => available.OrderByDescending(l => l, CostLayerOrder.Instance).ToList(),
            _ => available.OrderBy(l => l, CostLayerOrder.Instance).ToList(),
        };

        var orderedPositive = method == CategoryCostingMethod.Lifo
            ? available.OrderBy(l => l, CostLayerOrder.Instance).ToList()
            : ordered;

        var onHand = orderedPositive.Aggregate(Quantity.Zero, (acc, l) => acc.Add(l.RemainingQuantity));
        var blended = method == CategoryCostingMethod.Average
            ? ComputeBlendedUnitCost(orderedPositive, onHand, costScale, rounding)
            : (Money?)null;

        var need = quantity;
        var consumptions = new List<LayerConsumption>();

        foreach (var layer in ordered)
        {
            if (need.IsZero)
            {
                break;
            }

            var take = need < layer.RemainingQuantity ? need : layer.RemainingQuantity;
            var unitCost = blended ?? layer.UnitCost;
            var cost = unitCost.Multiply(take.Value, rounding).Round(costScale, rounding);
            consumptions.Add(new LayerConsumption(layer.SourceDocument, take, unitCost, cost));
            need = need.Subtract(take);
        }

        CostLayer? deficitLayer = null;
        if (!need.IsZero)
        {
            deficitLayer = CostLayer.CreateDeficit(
                issueDocument,
                DateTimeOffset.UtcNow,
                long.MaxValue,
                fallbackCost,
                need.Negate()).Value;
        }

        var total = consumptions.Aggregate(Money.Zero, (acc, c) => acc + c.Cost);
        if (deficitLayer is not null)
        {
            total = total + fallbackCost.Multiply(need.Value, rounding).Round(costScale, rounding);
        }

        return Result<IssueResult>.Success(new IssueResult(
            consumptions, total, need, deficitLayer));
    }

    private static Money ComputeBlendedUnitCost(
        IReadOnlyList<CostLayer> layers,
        Quantity onHand,
        int costScale,
        MidpointRounding rounding)
    {
        if (onHand.IsZero)
        {
            return Money.Zero;
        }

        decimal value = 0m;
        foreach (var layer in layers)
        {
            value += layer.RemainingQuantity.Value * layer.UnitCost.Amount;
        }

        return Money.From(value / onHand.Value).Round(costScale, rounding);
    }

    private sealed class CostLayerOrder : IComparer<CostLayer>
    {
        public static readonly CostLayerOrder Instance = new();

        public int Compare(CostLayer? x, CostLayer? y)
        {
            if (x is null && y is null)
            {
                return 0;
            }

            if (x is null)
            {
                return -1;
            }

            if (y is null)
            {
                return 1;
            }

            return x.CompareOrder(y);
        }
    }
}
