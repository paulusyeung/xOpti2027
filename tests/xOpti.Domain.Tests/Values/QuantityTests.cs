using xOpti.Domain.Values;

namespace xOpti.Domain.Tests.Values;

public class QuantityTests
{
    [Fact]
    public void ValueEqualityAndHashing()
    {
        var a = Quantity.From(12.5m);
        var b = Quantity.From(12.5000m);
        Assert.Equal(a, b);
        Assert.Equal(a.GetHashCode(), b.GetHashCode());
        Assert.NotEqual(a, Quantity.From(12.51m));
    }

    [Fact]
    public void ArithmeticIsDecimalBased()
    {
        Assert.Equal(Quantity.From(0.3m), Quantity.From(0.1m) + Quantity.From(0.2m));
        Assert.Equal(Quantity.From(0.1m), Quantity.From(0.3m) - Quantity.From(0.2m));
        Assert.Equal(Quantity.From(3m), Quantity.From(1m) * 3);
    }

    [Fact]
    public void NonNegativeConstraint_ForStockContexts()
    {
        Assert.True(Quantity.From(5m).EnsureNonNegative("on-hand").IsSuccess);
        Assert.True(Quantity.Zero.EnsureNonNegative("on-hand").IsSuccess);

        var failure = Quantity.From(-1m).EnsureNonNegative("on-hand");
        Assert.False(failure.IsSuccess);
        Assert.Contains("on-hand", failure.Error);
    }

    [Fact]
    public void QuantityIsDistinctTypeFromMoney()
    {
        Assert.False(typeof(Quantity).IsAssignableFrom(typeof(Money)));
        Assert.False(typeof(Money).IsAssignableFrom(typeof(Quantity)));
    }
}
