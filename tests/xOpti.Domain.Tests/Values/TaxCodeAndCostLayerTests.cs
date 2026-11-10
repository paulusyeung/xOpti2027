using xOpti.Domain.Values;

namespace xOpti.Domain.Tests.Values;

public class TaxCodeTests
{
    [Theory]
    [InlineData("N", TaxMethod.Exempt)]
    [InlineData("B", TaxMethod.GstPlusPst)]
    [InlineData("G", TaxMethod.GstOnly)]
    [InlineData("P", TaxMethod.PstOnly)]
    [InlineData("g", TaxMethod.GstIncluded)]
    [InlineData("p", TaxMethod.PstOnGst)]
    public void Legacy_codes_round_trip_with_case_sensitivity(string code, TaxMethod expected)
    {
        Assert.True(TaxMethodCodes.TryParseFromCode(code, out var parsed));
        Assert.Equal(expected, parsed);
        Assert.Equal(code, parsed.ToLegacyCode());
    }

    [Fact]
    public void Lowercase_g_is_not_uppercase_G()
    {
        Assert.True(TaxMethodCodes.TryParseFromCode("g", out var included));
        Assert.True(TaxMethodCodes.TryParseFromCode("G", out var only));
        Assert.NotEqual(included, only);
        Assert.False(TaxMethodCodes.TryParseFromCode("b", out _));
    }

    [Fact]
    public void Rates_carrier_validates()
    {
        Assert.True(TaxCode.Create(TaxMethod.GstPlusPst, 0.05m, 0.08m).IsSuccess);
        Assert.True(TaxCode.Create(TaxMethod.PstOnGst, 0.05m, 0.08m).IsSuccess);
        Assert.False(TaxCode.Create(TaxMethod.GstOnly, 0.05m, 0.08m).IsSuccess);
        Assert.False(TaxCode.Create(TaxMethod.GstOnly, -0.05m, 0m).IsSuccess);

        var exempt = TaxCode.Exempt();
        Assert.Equal(TaxMethod.Exempt, exempt.Method);
        Assert.Equal(0m, exempt.GstRate);
    }
}

public class CostLayerTests
{
    private static CostLayer PositiveLayer(Quantity received, decimal unitCost = 10m) =>
        CostLayer.Create("SR00001111", DateTimeOffset.UnixEpoch, 1, Money.From(unitCost), received).Value;

    [Fact]
    public void Partial_consumption_reduces_remaining()
    {
        var layer = PositiveLayer(Quantity.From(5m));

        var consumed = layer.Consume(Quantity.From(2m));

        Assert.True(consumed.IsSuccess);
        Assert.Equal(Quantity.From(3m), consumed.Value.RemainingQuantity);
        Assert.Equal(Quantity.From(2m), layer.ReceivedQuantity.Subtract(consumed.Value.RemainingQuantity));
    }

    [Fact]
    public void Over_consumption_is_rejected_and_layer_unchanged()
    {
        var layer = PositiveLayer(Quantity.From(3m));

        var failure = layer.Consume(Quantity.From(5m));

        Assert.False(failure.IsSuccess);
        Assert.Contains("Cannot consume", failure.Error);
        Assert.Equal(Quantity.From(3m), layer.RemainingQuantity);
    }

    [Fact]
    public void Failed_consumption_returns_immutability()
    {
        var layer = PositiveLayer(Quantity.From(4m));

        var failure = layer.Consume(Quantity.From(10m));
        Assert.False(failure.IsSuccess);

        var ok = layer.Consume(Quantity.From(4m));
        Assert.True(ok.IsSuccess);
        Assert.Equal(Quantity.Zero, ok.Value.RemainingQuantity);
    }

    [Fact]
    public void Deficit_layer_represents_unreceipted_sales()
    {
        var deficit = CostLayer.CreateDeficit(
            "RC00000500", DateTimeOffset.UnixEpoch, 9, Money.From(14.00m), Quantity.From(-3m));

        Assert.True(deficit.IsSuccess);
        Assert.True(deficit.Value.IsDeficit);
        Assert.Equal(Quantity.From(-3m), deficit.Value.RemainingQuantity);
        Assert.Equal(Money.From(14.00m), deficit.Value.UnitCost);
    }

    [Fact]
    public void Deficit_layer_rejects_direct_consumption()
    {
        var deficit = CostLayer.CreateDeficit(
            "RC00000500", DateTimeOffset.UnixEpoch, 9, Money.From(14.00m), Quantity.From(-3m)).Value;

        Assert.False(deficit.Consume(Quantity.From(1m)).IsSuccess);
    }

    [Fact]
    public void Deficit_layer_cleared_by_reconciliation()
    {
        var deficit = CostLayer.CreateDeficit(
            "RC00000500", DateTimeOffset.UnixEpoch, 9, Money.From(14.00m), Quantity.From(-3m)).Value;

        var partial = deficit.Reconcile(Quantity.From(2m));
        Assert.True(partial.IsSuccess);
        Assert.True(partial.Value.IsDeficit);
        Assert.Equal(Quantity.From(-1m), partial.Value.RemainingQuantity);

        var cleared = partial.Value.Reconcile(Quantity.From(1m));
        Assert.True(cleared.IsSuccess);
        Assert.False(cleared.Value.IsDeficit);
        Assert.Equal(Quantity.Zero, cleared.Value.RemainingQuantity);

        var overCovered = deficit.Reconcile(Quantity.From(5m));
        Assert.False(overCovered.IsSuccess);
    }

    [Fact]
    public void Positive_layer_requires_non_negative_receipt()
    {
        Assert.False(CostLayer.Create("SR1", DateTimeOffset.UnixEpoch, 1, Money.Zero, Quantity.From(-2m)).IsSuccess);
        Assert.False(CostLayer.CreateDeficit("SR1", DateTimeOffset.UnixEpoch, 1, Money.Zero, Quantity.From(2m)).IsSuccess);
    }

    [Fact]
    public void Ordering_uses_received_date_then_sequence()
    {
        var epoch = new DateTimeOffset(2000, 1, 1, 0, 0, 0, TimeSpan.Zero);
        var older = CostLayer.Create("A", epoch, 1, Money.Zero, Quantity.From(1m)).Value;
        var sameDateLaterSeq = CostLayer.Create("A", epoch, 2, Money.Zero, Quantity.From(1m)).Value;
        var newer = CostLayer.Create("A", epoch.AddDays(1), 1, Money.Zero, Quantity.From(1m)).Value;

        Assert.True(older.CompareOrder(newer) < 0);
        Assert.True(older.CompareOrder(sameDateLaterSeq) < 0);
    }
}
