using xOpti.Domain.Rules;
using xOpti.Domain.Values;

namespace xOpti.Domain.Tests.Rules;

public class TaxCalculatorTests
{
    [Fact]
    public void Method_N_produces_zero_tax()
    {
        var result = TaxCalculator.Calculate(TaxCode.Exempt(), Money.From(100.00m));

        Assert.True(result.IsSuccess);
        Assert.Equal(Money.Zero, result.Value.Gst);
        Assert.Equal(Money.Zero, result.Value.Pst);
        Assert.Equal(Money.From(100.00m), result.Value.Gross);
    }

    [Fact]
    public void Method_B_adds_both_taxes()
    {
        var code = TaxCode.Create(TaxMethod.GstPlusPst, 0.05m, 0.08m).Value;

        var result = TaxCalculator.Calculate(code, Money.From(100.00m));

        Assert.True(result.IsSuccess);
        Assert.Equal(Money.From(5.00m), result.Value.Gst);
        Assert.Equal(Money.From(8.00m), result.Value.Pst);
        Assert.Equal(Money.From(113.00m), result.Value.Gross);
    }

    [Fact]
    public void Method_G_and_P_apply_single_tax()
    {
        var gstOnly = TaxCode.Create(TaxMethod.GstOnly, 0.07m, 0m).Value;
        var pstOnly = TaxCode.Create(TaxMethod.PstOnly, 0m, 0.07m).Value;

        var g = TaxCalculator.Calculate(gstOnly, Money.From(16.82m));
        Assert.True(g.IsSuccess);
        Assert.Equal(Money.From(1.18m), g.Value.Gst);
        Assert.Equal(Money.Zero, g.Value.Pst);
        Assert.Equal(Money.From(18.00m), g.Value.Gross);

        var p = TaxCalculator.Calculate(pstOnly, Money.From(72.00m));
        Assert.True(p.IsSuccess);
        Assert.Equal(Money.Zero, p.Value.Gst);
        Assert.Equal(Money.From(5.04m), p.Value.Pst);
        Assert.Equal(Money.From(77.04m), p.Value.Gross);
    }

    [Fact]
    public void Method_g_extracts_included_gst()
    {
        var code = TaxCode.Create(TaxMethod.GstIncluded, 0.05m, 0m).Value;

        var result = TaxCalculator.Calculate(code, Money.From(105.00m));

        Assert.True(result.IsSuccess);
        Assert.Equal(Money.From(5.00m), result.Value.Gst);
        Assert.Equal(Money.From(100.00m), result.Value.Net);
        Assert.Equal(Money.From(105.00m), result.Value.Gross);
    }

    [Fact]
    public void Method_p_stacks_pst_on_gst_inclusive_base()
    {
        var code = TaxCode.Create(TaxMethod.PstOnGst, 0.05m, 0.08m).Value;

        var result = TaxCalculator.Calculate(code, Money.From(100.00m));

        Assert.True(result.IsSuccess);
        Assert.Equal(Money.From(5.00m), result.Value.Gst);
        Assert.Equal(Money.From(8.40m), result.Value.Pst);
        Assert.Equal(Money.From(113.40m), result.Value.Gross);
    }

    [Fact]
    public void Rejects_negative_base()
    {
        Assert.False(TaxCalculator.Calculate(TaxCode.Exempt(), Money.From(-1m)).IsSuccess);
    }
}
