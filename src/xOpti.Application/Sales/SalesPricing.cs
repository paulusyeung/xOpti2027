using xOpti.Application.Common;
using xOpti.Application.Pipeline;
using xOpti.Domain.Rules;
using xOpti.Domain.Values;

namespace xOpti.Application.Sales;

public sealed record PricingLineInput(
    string Sku, int Quantity, decimal UnitAmount, decimal DiscountAmount, string TaxCode);

public sealed record PricedLine(
    string Sku, int Quantity, decimal UnitAmount, decimal DiscountAmount,
    decimal Amount, string TaxCode, decimal TaxA, decimal TaxB);

public sealed record PricedDocument(
    IReadOnlyList<PricedLine> Lines, decimal TotalSale, decimal TaxA, decimal TaxB,
    decimal GrossSale, int TotalQty);

/// <summary>
/// Shared line pricing: post-markdown amount, per-component tax rounding, and
/// document totals. Used by orders, direct invoices, and exchange replacements
/// so all POS documents snapshot prices and taxes the same way.
/// </summary>
public static class SalesPricing
{
    public static PricedDocument Price(
        IReadOnlyList<PricingLineInput> lines, (double GstRate, double PstRate) rates)
    {
        var priced = new List<PricedLine>(lines.Count);
        foreach (var line in lines)
        {
            var lineGross = decimal.Round(line.UnitAmount * line.Quantity, 4);
            if (line.DiscountAmount > lineGross)
                throw new ValidationFailedException(new[]
                {
                    new ValidationFieldError("DiscountAmount", "over-line",
                        $"The discount on {line.Sku} cannot exceed the line amount."),
                });
            var amount = decimal.Round(lineGross - line.DiscountAmount, 4);
            var code = TaxCodeFor(line.TaxCode, rates);
            if (!code.IsSuccess)
                throw new ValidationFailedException(new[]
                {
                    new ValidationFieldError("TaxCode", "invalid-tax-configuration", code.Error),
                });
            var tax = TaxCalculator.Calculate(code.Value, Money.From(amount));
            if (!tax.IsSuccess)
                throw new ValidationFailedException(new[]
                {
                    new ValidationFieldError("TaxCode", "tax-calculation", tax.Error),
                });
            priced.Add(new PricedLine(line.Sku, line.Quantity, line.UnitAmount, line.DiscountAmount,
                amount, line.TaxCode, tax.Value.Gst.Amount, tax.Value.Pst.Amount));
        }

        var totalSale = decimal.Round(priced.Sum(row => row.Amount), 4);
        var taxA = decimal.Round(priced.Sum(row => row.TaxA), 4);
        var taxB = decimal.Round(priced.Sum(row => row.TaxB), 4);
        var gross = decimal.Round(totalSale + taxA + taxB, 4);
        return new PricedDocument(priced, totalSale, taxA, taxB, gross,
            priced.Sum(row => row.Quantity));
    }

    public static TaxMethod TaxMethodFor(string? code) => code switch
    {
        "N" => TaxMethod.Exempt,
        "B" => TaxMethod.GstPlusPst,
        "G" => TaxMethod.GstOnly,
        "P" => TaxMethod.PstOnly,
        "g" => TaxMethod.GstIncluded,
        "p" => TaxMethod.PstOnGst,
        _ => TaxMethod.Exempt,
    };

    private static xOpti.Domain.Common.Result<TaxCode> TaxCodeFor(
        string? code, (double GstRate, double PstRate) rates)
    {
        var gst = (decimal)rates.GstRate / 100m;
        var pst = (decimal)rates.PstRate / 100m;
        return TaxMethodFor(code) switch
        {
            TaxMethod.Exempt => TaxCode.Create(TaxMethod.Exempt, 0m, 0m),
            TaxMethod.GstOnly => TaxCode.Create(TaxMethod.GstOnly, gst, 0m),
            TaxMethod.PstOnly => TaxCode.Create(TaxMethod.PstOnly, 0m, pst),
            var method => TaxCode.Create(method, gst, pst),
        };
    }
}
