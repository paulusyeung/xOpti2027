namespace xOpti.Domain.Values;

/// <summary>
/// A stock lot: quantity bound to a lot identifier with supplier/receipt provenance.
/// Lot quantity is a stock context and must never be negative.
/// </summary>
public sealed record Lot
{
    public string LotNumber { get; }

    public string? SupplierCode { get; }

    public DateTimeOffset ReceivedOn { get; }

    public Quantity Quantity { get; }

    private Lot(string lotNumber, string? supplierCode, DateTimeOffset receivedOn, Quantity quantity)
    {
        LotNumber = lotNumber;
        SupplierCode = supplierCode;
        ReceivedOn = receivedOn;
        Quantity = quantity;
    }

    public static Common.Result<Lot> Create(
        string? lotNumber,
        string? supplierCode,
        DateTimeOffset receivedOn,
        Quantity quantity)
    {
        if (string.IsNullOrWhiteSpace(lotNumber))
        {
            return Common.Result<Lot>.Failure("Lot number is required.");
        }

        var nonNegative = quantity.EnsureNonNegative("lot quantity");
        if (!nonNegative.IsSuccess)
        {
            return Common.Result<Lot>.Failure(nonNegative.Error);
        }

        return Common.Result<Lot>.Success(new Lot(lotNumber.Trim(), TrimOrNull(supplierCode), receivedOn, quantity));
    }

    /// <summary>
    /// Apply an adjustment; the result may not drive lot quantity below zero.
    /// </summary>
    public Common.Result<Lot> Adjust(Quantity delta)
    {
        var adjusted = Quantity.Add(delta);
        if (adjusted.IsNegative)
        {
            return Common.Result<Lot>.Failure(
                $"Adjustment of {delta} on lot '{LotNumber}' would drive quantity below zero.");
        }

        return Common.Result<Lot>.Success(
            new Lot(LotNumber, SupplierCode, ReceivedOn, adjusted));
    }

    private static string? TrimOrNull(string? value) =>
        string.IsNullOrWhiteSpace(value) ? null : value.Trim();
}
