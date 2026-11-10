using System.Reflection;
using xOpti.Domain.Values;

namespace xOpti.Domain.Tests.Values;

public class MoneyTests
{
    [Fact]
    public void RoundTrip_PreservesFourDecimalPrecision()
    {
        var money = Money.From(1234.5678m);
        Assert.Equal(1234.5678m, money.Amount);
        Assert.Equal(money, Money.From(1234.5678m));
    }

    [Fact]
    public void Constructor_NormalizesToStorageScale()
    {
        Assert.Equal(Money.From(1.2346m), Money.From(1.23455m));
        Assert.Equal(1.2346m, Money.From(1.23455m).Amount);
    }

    [Fact]
    public void Equality_IgnoresTrailingZeros()
    {
        Assert.Equal(Money.From(6.26m), Money.From(6.2600m));
        Assert.Equal(Money.From(6.26m).GetHashCode(), Money.From(6.2600m).GetHashCode());
    }

    [Fact]
    public void Allocate_DistributesRemainderDeterministicallyAndSumsExactly()
    {
        var shares = Money.From(100.00m).Allocate(3, decimals: 2);

        Assert.Equal(3, shares.Length);
        Assert.Equal(Money.From(33.34m), shares[0]);
        Assert.Equal(Money.From(33.33m), shares[1]);
        Assert.Equal(Money.From(33.33m), shares[2]);
        Assert.Equal(Money.From(100.00m), shares[0] + shares[1] + shares[2]);
    }

    [Fact]
    public void Allocate_IsRepeatable()
    {
        var first = Money.From(0.10m).Allocate(4);
        var second = Money.From(0.10m).Allocate(4);
        Assert.Equal(first.Select(m => m.Amount), second.Select(m => m.Amount));
    }

    [Fact]
    public void Round_UsesExplicitScaleAndMode()
    {
        Assert.Equal(Money.From(2.68m), Money.From(2.675m).Round(2, MidpointRounding.AwayFromZero));
        Assert.Equal(Money.From(2.68m), Money.From(2.675m).Round(2, MidpointRounding.ToEven));
        Assert.Equal(Money.From(2.69m), Money.From(2.685m).Round(2, MidpointRounding.AwayFromZero));
        Assert.Equal(Money.From(2.68m), Money.From(2.685m).Round(2, MidpointRounding.ToEven));
    }

    [Fact]
    public void ArithmeticIsDecimalBased()
    {
        Assert.Equal(Money.From(0.3m), Money.From(0.1m) + Money.From(0.2m));
        Assert.Equal(Money.From(1.1300m), Money.From(100.00m).Multiply(0.0113m, MidpointRounding.AwayFromZero));
    }

    [Fact]
    public void PublicApi_RejectsFloatingPointConstruction()
    {
        var floatingPointTypes = new[] { typeof(double), typeof(float) };

        var offenders = typeof(Money)
            .GetMembers(BindingFlags.Public | BindingFlags.Static | BindingFlags.Instance)
            .SelectMany(member => member switch
            {
                MethodBase methodBase => methodBase.GetParameters().Select(p => p.ParameterType),
                PropertyInfo property => new[] { property.PropertyType },
                _ => Enumerable.Empty<Type>()
            })
            .Where(type => floatingPointTypes.Contains(type))
            .ToList();

        Assert.Empty(offenders);
    }
}
