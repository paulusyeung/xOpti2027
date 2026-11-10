using xOpti.Domain.Values;

namespace xOpti.Domain.Tests.Values;

public class IdentifierTests
{
    [Theory]
    [InlineData("RC000123", TransactionType.RetailInvoice, 123)]
    [InlineData("RC00023371", TransactionType.RetailInvoice, 23371)]
    [InlineData("RS00000002", TransactionType.RetailRefund, 2)]
    [InlineData("SR00045678", TransactionType.StockReceived, 45678)]
    [InlineData("RJ00045679", TransactionType.StockRejected, 45679)]
    [InlineData("SJ00045680", TransactionType.StockAdjustment, 45680)]
    [InlineData("WC00099999", TransactionType.WholesaleInvoice, 99999)]
    [InlineData("WR00012345", TransactionType.WholesaleReturn, 12345)]
    [InlineData("SA00000001", TransactionType.SalesOrder, 1)]
    public void ControlNumber_parses_all_legacy_families(string raw, TransactionType family, long sequence)
    {
        Assert.True(ControlNumber.TryParse(raw, out var parsed));
        Assert.Equal(family, parsed.Family);
        Assert.Equal(sequence, parsed.Sequence);
    }

    [Theory]
    [InlineData("XX000123")]
    [InlineData("RC")]
    [InlineData("12345")]
    [InlineData("rc000123")]
    [InlineData("RC0001 23")]
    [InlineData(null)]
    public void ControlNumber_rejects_unknown_or_malformed(string? raw)
    {
        Assert.False(ControlNumber.TryParse(raw, out _));
    }

    [Fact]
    public void ControlNumber_value_equality()
    {
        Assert.True(ControlNumber.TryParse("RC000123", out var a));
        Assert.True(ControlNumber.TryParse("RC000123", out var b));
        Assert.Equal(a, b);
        Assert.Equal(a.GetHashCode(), b.GetHashCode());
    }

    [Fact]
    public void Sku_create_validates_length_and_whitespace()
    {
        var ok = Sku.Create("  30110359  ");
        Assert.True(ok.IsSuccess);
        Assert.Equal("30110359", ok.Value.Value);

        Assert.False(Sku.Create(null).IsSuccess);
        Assert.False(Sku.Create("12345678901234").IsSuccess);
    }

    [Fact]
    public void Sku_value_equality_and_hashing()
    {
        var a = Sku.Create("30110359").Value;
        var b = Sku.Create("30110359").Value;
        Assert.Equal(a, b);
        Assert.Equal(a.GetHashCode(), b.GetHashCode());
    }

    [Fact]
    public void Lot_binds_quantity_to_identity_and_provenance()
    {
        var lot = Lot.Create("00025877", "SUP1", new DateTimeOffset(1998, 6, 2, 0, 0, 0, TimeSpan.Zero), Quantity.From(10m));
        Assert.True(lot.IsSuccess);
        Assert.Equal("00025877", lot.Value.LotNumber);
        Assert.Equal("SUP1", lot.Value.SupplierCode);
        Assert.Equal(Quantity.From(10m), lot.Value.Quantity);
    }

    [Fact]
    public void Lot_adjustment_never_goes_negative()
    {
        var lot = Lot.Create("L1", null, DateTimeOffset.UnixEpoch, Quantity.From(3m)).Value;

        var failure = lot.Adjust(Quantity.From(-4m));
        Assert.False(failure.IsSuccess);
        Assert.Contains("below zero", failure.Error);

        var ok = lot.Adjust(Quantity.From(-3m));
        Assert.True(ok.IsSuccess);
        Assert.Equal(Quantity.Zero, ok.Value.Quantity);
        Assert.Equal(Quantity.From(3m), lot.Quantity);
    }

    [Fact]
    public void Rx_validates_axis_and_power_pairing()
    {
        var badAxis = RxLens.Create(RxPower.Right, 2.00m, -1.25m, 181);
        Assert.False(badAxis.IsSuccess);

        var right = RxLens.Create(RxPower.Right, 2.00m, -1.25m, 90, 1.50m);
        var left = RxLens.Create(RxPower.Left, 2.25m, -1.00m, 85, 1.50m);
        Assert.True(right.IsSuccess);
        Assert.True(left.IsSuccess);

        var rx = Rx.Create(right.Value, left.Value, DateTimeOffset.UnixEpoch);
        Assert.True(rx.IsSuccess);

        var reversed = Rx.Create(left.Value, left.Value, DateTimeOffset.UnixEpoch);
        Assert.False(reversed.IsSuccess);
    }
}
