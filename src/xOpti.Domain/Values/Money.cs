using System.Globalization;

namespace xOpti.Domain.Values;

/// <summary>
/// Fixed-scale money value object. Backed by <see cref="decimal"/> normalized to
/// four decimal places (the PostgreSQL numeric(19,4) contract). There is
/// deliberately no construction or arithmetic path that accepts double/float.
/// </summary>
public readonly struct Money : IEquatable<Money>, IComparable<Money>, IComparable
{
    public const int StorageScale = 4;

    private readonly decimal _amount;

    private Money(decimal amount)
    {
        _amount = Math.Round(amount, StorageScale, MidpointRounding.AwayFromZero);
    }

    public static Money Zero => new(0m);

    public decimal Amount => _amount;

    public static Money From(decimal amount) => new(amount);

    public Money Add(Money other) => new(_amount + other._amount);

    public Money Subtract(Money other) => new(_amount - other._amount);

    public static Money operator +(Money left, Money right) => left.Add(right);

    public static Money operator -(Money left, Money right) => left.Subtract(right);

    public static Money operator -(Money money) => new(-money._amount);

    /// <summary>
    /// Multiply by a dimensionless factor with an explicit rounding mode; never ambient.
    /// </summary>
    public Money Multiply(decimal factor, MidpointRounding rounding) =>
        new(Math.Round(_amount * factor, StorageScale, rounding));

    /// <summary>
    /// Round to an explicit decimal scale with an explicit rounding mode (display, tax, ...).
    /// </summary>
    public Money Round(int decimals, MidpointRounding rounding)
    {
        ArgumentOutOfRangeException.ThrowIfNegative(decimals);
        ArgumentOutOfRangeException.ThrowIfGreaterThan(decimals, StorageScale);
        return new(Math.Round(_amount, decimals, rounding));
    }

    /// <summary>
    /// Split this amount into <paramref name="parts"/> shares at the given decimal scale.
    /// Deterministic remainder rule: each share is the truncated quotient; the leftover
    /// units (at the target scale) are distributed one-per-share to the first shares,
    /// so the parts always sum exactly to the original amount.
    /// </summary>
    public Money[] Allocate(int parts, int decimals = 2)
    {
        ArgumentOutOfRangeException.ThrowIfLessThan(parts, 1);
        ArgumentOutOfRangeException.ThrowIfNegative(decimals);
        ArgumentOutOfRangeException.ThrowIfGreaterThan(decimals, StorageScale);

        decimal scaled = _amount * PowerOfTen(decimals);
        long units = (long)decimal.Truncate(scaled);
        long baseUnits = units / parts;
        long remainder = units - baseUnits * parts;

        var shares = new Money[parts];
        for (int i = 0; i < parts; i++)
        {
            long shareUnits = baseUnits + (i < Math.Abs(remainder) ? Math.Sign(remainder) : 0);
            shares[i] = new Money(shareUnits / PowerOfTen(decimals));
        }

        return shares;
    }

    private static decimal PowerOfTen(int power)
    {
        decimal result = 1m;
        for (int i = 0; i < power; i++)
        {
            result *= 10m;
        }

        return result;
    }

    public bool IsZero => _amount == 0m;

    public bool IsNegative => _amount < 0m;

    public bool Equals(Money other) => _amount == other._amount;

    public override bool Equals(object? obj) => obj is Money other && Equals(other);

    public override int GetHashCode() => _amount.GetHashCode();

    public int CompareTo(Money other) => _amount.CompareTo(other._amount);

    public int CompareTo(object? obj) => obj is Money other ? CompareTo(other)
        : throw new ArgumentException("Object is not a Money", nameof(obj));

    public static bool operator ==(Money left, Money right) => left.Equals(right);

    public static bool operator !=(Money left, Money right) => !left.Equals(right);

    public static bool operator <(Money left, Money right) => left.CompareTo(right) < 0;

    public static bool operator >(Money left, Money right) => left.CompareTo(right) > 0;

    public static bool operator <=(Money left, Money right) => left.CompareTo(right) <= 0;

    public static bool operator >=(Money left, Money right) => left.CompareTo(right) >= 0;

    public override string ToString() => _amount.ToString("0.0000", CultureInfo.InvariantCulture);
}
