using xOpti.Domain.Common;

namespace xOpti.Domain.Values;

/// <summary>
/// A costing lot layer: source document, unit cost, received and remaining
/// quantity. Positive layers are immutable and reject over-consumption.
/// Deficit layers (negative remaining) represent stock sold before receipt
/// and are cleared only via <see cref="Reconcile"/>.
/// </summary>
public sealed record CostLayer
{
    public string SourceDocument { get; }

    public DateTimeOffset ReceivedOn { get; }

    public long Sequence { get; }

    public Money UnitCost { get; }

    public Quantity ReceivedQuantity { get; }

    public Quantity RemainingQuantity { get; init; }

    public bool IsDeficit { get; init; }

    private CostLayer(
        string sourceDocument,
        DateTimeOffset receivedOn,
        long sequence,
        Money unitCost,
        Quantity receivedQuantity,
        Quantity remainingQuantity,
        bool isDeficit)
    {
        SourceDocument = sourceDocument;
        ReceivedOn = receivedOn;
        Sequence = sequence;
        UnitCost = unitCost;
        ReceivedQuantity = receivedQuantity;
        RemainingQuantity = remainingQuantity;
        IsDeficit = isDeficit;
    }

    public static Result<CostLayer> Create(
        string sourceDocument,
        DateTimeOffset receivedOn,
        long sequence,
        Money unitCost,
        Quantity receivedQuantity)
    {
        if (string.IsNullOrWhiteSpace(sourceDocument))
        {
            return Result<CostLayer>.Failure("Cost layer requires a source document.");
        }

        if (receivedQuantity.IsNegative)
        {
            return Result<CostLayer>.Failure("Received quantity must not be negative; use a deficit layer.");
        }

        return Result<CostLayer>.Success(new CostLayer(
            sourceDocument.Trim(), receivedOn, sequence, unitCost,
            receivedQuantity, receivedQuantity, isDeficit: false));
    }

    /// <summary>
    /// Create a deficit layer for stock sold before receipt: remaining quantity
    /// is negative (the shortfall) at the standard/fallback cost.
    /// </summary>
    public static Result<CostLayer> CreateDeficit(
        string sourceDocument,
        DateTimeOffset receivedOn,
        long sequence,
        Money unitCost,
        Quantity shortfall)
    {
        if (string.IsNullOrWhiteSpace(sourceDocument))
        {
            return Result<CostLayer>.Failure("Cost layer requires a source document.");
        }

        if (shortfall.IsZero || !shortfall.IsNegative)
        {
            return Result<CostLayer>.Failure("Deficit layer requires a negative shortfall quantity.");
        }

        return Result<CostLayer>.Success(new CostLayer(
            sourceDocument.Trim(), receivedOn, sequence, unitCost,
            Quantity.Zero, shortfall, isDeficit: true));
    }

    /// <summary>
    /// Consume from a positive layer. Returns a NEW layer with reduced remaining
    /// quantity; over-consumption fails and the original instance is unchanged.
    /// Deficit layers cannot be directly consumed.
    /// </summary>
    public Result<CostLayer> Consume(Quantity quantity)
    {
        if (IsDeficit)
        {
            return Result<CostLayer>.Failure(
                $"Deficit layer '{SourceDocument}' is cleared by reconciliation, not by consumption.");
        }

        if (quantity.IsNegative)
        {
            return Result<CostLayer>.Failure("Consumption quantity must not be negative.");
        }

        if (quantity > RemainingQuantity)
        {
            return Result<CostLayer>.Failure(
                $"Cannot consume {quantity} from layer '{SourceDocument}' with {RemainingQuantity} remaining.");
        }

        return Result<CostLayer>.Success(this with
        {
            RemainingQuantity = RemainingQuantity.Subtract(quantity),
        });
    }

    /// <summary>
    /// Apply received stock against a deficit layer; the layer is fully covered
    /// when remaining quantity reaches zero.
    /// </summary>
    public Result<CostLayer> Reconcile(Quantity received)
    {
        if (!IsDeficit)
        {
            return Result<CostLayer>.Failure("Only deficit layers are reconciled by receipt.");
        }

        if (received.IsNegative)
        {
            return Result<CostLayer>.Failure("Reconciling receipt quantity must not be negative.");
        }

        var newRemaining = RemainingQuantity.Add(received);
        if (newRemaining > Quantity.Zero)
        {
            return Result<CostLayer>.Failure(
                $"Receipt of {received} over-covers deficit layer '{SourceDocument}' ({RemainingQuantity}).");
        }

        return Result<CostLayer>.Success(this with
        {
            RemainingQuantity = newRemaining,
            IsDeficit = newRemaining.IsNegative,
        });
    }

    /// <summary>Weight of the layer for FIFO/LIFO ordering.</summary>
    public int CompareOrder(CostLayer other)
    {
        var byDate = ReceivedOn.CompareTo(other.ReceivedOn);
        return byDate != 0 ? byDate : Sequence.CompareTo(other.Sequence);
    }
}
