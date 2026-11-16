using xOpti.Application.Common;
using xOpti.Application.Pipeline;
using xOpti.Application.Ports;

namespace xOpti.Application.Sales;

/// <summary>
/// A manual price change or an above-threshold discount that must be
/// permissioned and audited. Original/Applied are unit prices for a price
/// override and percentages for a discount override.
/// </summary>
public sealed record PriceOverrideNote(
    string Sku, string Kind, decimal Original, decimal Applied, decimal ThresholdPercent);

/// <summary>
/// Validates POS lines against the catalogue price and the configured
/// discount threshold. Callers resolve missing unit prices first, then pass
/// the current retail prices by SKU.
/// </summary>
public static class PriceOverrideRules
{
    public const string PriceKind = "price";
    public const string DiscountKind = "discount";

    public static IReadOnlyList<PriceOverrideNote> Validate(
        IReadOnlyList<PricingLineInput> lines,
        IReadOnlyDictionary<string, decimal?> retailPrices,
        bool canOverride,
        decimal thresholdPercent)
    {
        var threshold = decimal.Round(Math.Max(0m, thresholdPercent), 4);
        var notes = new List<PriceOverrideNote>();

        foreach (var line in lines)
        {
            var retail = retailPrices.GetValueOrDefault(line.Sku);
            if (retail is not null && decimal.Round(retail.Value, 4) != decimal.Round(line.UnitAmount, 4))
            {
                if (!canOverride)
                    throw new ValidationFailedException(new[]
                    {
                        new ValidationFieldError("UnitAmount", "price-override-denied",
                            $"Changing the price of {line.Sku} requires the price-override permission; "
                            + $"the current price is {retail.Value:0.00}."),
                    });
                notes.Add(new PriceOverrideNote(line.Sku, PriceKind, retail.Value, line.UnitAmount, threshold));
            }

            var lineGross = line.UnitAmount * line.Quantity;
            if (line.DiscountAmount > 0 && lineGross > 0)
            {
                var percent = decimal.Round(line.DiscountAmount / lineGross * 100m, 4);
                if (percent > threshold)
                {
                    if (!canOverride)
                        throw new ValidationFailedException(new[]
                        {
                            new ValidationFieldError("DiscountAmount", "discount-override-denied",
                                $"A {percent:0.##}% discount on {line.Sku} exceeds the permitted "
                                + $"{threshold:0.##}% threshold; the price-override permission is required."),
                        });
                    notes.Add(new PriceOverrideNote(line.Sku, DiscountKind, threshold, percent, threshold));
                }
            }
        }

        return notes;
    }

    public static async Task RecordAuditAsync(
        IAuditRecorder audit, string txNumber, IReadOnlyList<PriceOverrideNote> notes,
        string reason, CancellationToken ct)
    {
        foreach (var note in notes)
        {
            await audit.RecordAsync(new AuditRecord(
                note.Kind == PriceKind ? "sales.price-override" : "sales.discount-override",
                "TxHeader", txNumber,
                System.Text.Json.JsonSerializer.Serialize(new
                {
                    sku = note.Sku, original = note.Original, applied = note.Applied,
                    threshold = note.ThresholdPercent, reason,
                })), ct);
        }
    }

    public static bool CanOverride(ICurrentPrincipal principal) =>
        principal.HasPermission(Authorization.PermissionNames.SalesPriceOverride);
}
