using xOpti.Domain.Common;
using xOpti.Domain.Values;

namespace xOpti.Domain.Rules;

/// <summary>
/// Result of a line tax calculation. Net is the tax base, Gross the payable total.
/// </summary>
public sealed record TaxBreakdown(Money Net, Money Gst, Money Pst, Money Gross);

/// <summary>
/// Pure implementation of the legacy tax methods (frmPriceWizard.frm):
/// N exempt, B GST+PST, G GST only, P PST only, g GST included in price,
/// p PST charged on top of GST. Rounding is per-component at an explicit
/// scale (legacy behavior: each tax component is rounded to 2 dp, then summed).
/// </summary>
public static class TaxCalculator
{
    public static Result<TaxBreakdown> Calculate(
        TaxCode code,
        Money amount,
        int scale = 2,
        MidpointRounding rounding = MidpointRounding.AwayFromZero)
    {
        if (scale is < 0 or > Money.StorageScale)
        {
            return Result<TaxBreakdown>.Failure($"Tax scale must be between 0 and {Money.StorageScale}.");
        }

        if (amount.IsNegative)
        {
            return Result<TaxBreakdown>.Failure("Tax base amount must not be negative (use refund semantics instead).");
        }

        var zero = Money.Zero;

        switch (code.Method)
        {
            case TaxMethod.Exempt:
                return Result<TaxBreakdown>.Success(new TaxBreakdown(amount, zero, zero, amount));

            case TaxMethod.GstPlusPst:
            {
                var gst = amount.Multiply(code.GstRate, rounding).Round(scale, rounding);
                var pst = amount.Multiply(code.PstRate, rounding).Round(scale, rounding);
                return Result<TaxBreakdown>.Success(new TaxBreakdown(amount, gst, pst, amount + gst + pst));
            }

            case TaxMethod.GstOnly:
            {
                var gst = amount.Multiply(code.GstRate, rounding).Round(scale, rounding);
                return Result<TaxBreakdown>.Success(new TaxBreakdown(amount, gst, zero, amount + gst));
            }

            case TaxMethod.PstOnly:
            {
                var pst = amount.Multiply(code.PstRate, rounding).Round(scale, rounding);
                return Result<TaxBreakdown>.Success(new TaxBreakdown(amount, zero, pst, amount + pst));
            }

            case TaxMethod.GstIncluded:
            {
                // Amount is GST-inclusive: extract the included component.
                var net = Money.From(amount.Amount / (1m + code.GstRate)).Round(scale, rounding);
                var gst = amount - net;
                return Result<TaxBreakdown>.Success(new TaxBreakdown(net, gst, zero, amount));
            }

            case TaxMethod.PstOnGst:
            {
                var gst = amount.Multiply(code.GstRate, rounding).Round(scale, rounding);
                var pst = (amount + gst).Multiply(code.PstRate, rounding).Round(scale, rounding);
                return Result<TaxBreakdown>.Success(new TaxBreakdown(amount, gst, pst, amount + gst + pst));
            }

            default:
                return Result<TaxBreakdown>.Failure($"Unsupported tax method '{code.Method}'.");
        }
    }
}
