using System.Globalization;

namespace xOpti.Domain.Values;

/// <summary>
/// Decimal quantity distinct from money. Quantities may be negative in transit
/// contexts (adjustments, reversals) but stock-on-hand contexts must assert
/// non-negativity via <see cref="EnsureNonNegative"/>.
/// </summary>
public readonly struct Quantity : IEquatable<Quantity>, IComparable<Quantity>
{
    private readonly decimal _value;

    private Quantity(decimal value)
    {
        _value = Math.Round(value, 4, MidpointRounding.AwayFromZero);
    }

    public static Quantity Zero => new(0m);

    public static Quantity From(decimal value) => new(value);

    public decimal Value => _value;

    public bool IsZero => _value == 0m;

    public bool IsNegative => _value < 0m;

    public Quantity Add(Quantity other) => new(_value + other._value);

    public Quantity Subtract(Quantity other) => new(_value - other._value);

    public Quantity Negate() => new(-_value);

    public static Quantity operator +(Quantity left, Quantity right) => left.Add(right);

    public static Quantity operator -(Quantity left, Quantity right) => left.Subtract(right);

    public static Quantity operator *(Quantity quantity, int factor) => new(quantity._value * factor);

    public static Quantity operator -(Quantity quantity) => quantity.Negate();

    public Common.Result<Quantity> EnsureNonNegative(string context) =>
        _value < 0m
            ? Common.Result<Quantity>.Failure($"Quantity for '{context}' must not be negative but was {_value.ToString(CultureInfo.InvariantCulture)}.")
            : Common.Result<Quantity>.Success(this);

    public bool Equals(Quantity other) => _value == other._value;

    public override bool Equals(object? obj) => obj is Quantity other && Equals(other);

    public override int GetHashCode() => _value.GetHashCode();

    public int CompareTo(Quantity other) => _value.CompareTo(other._value);

    public static bool operator ==(Quantity left, Quantity right) => left.Equals(right);

    public static bool operator !=(Quantity left, Quantity right) => !left.Equals(right);

    public static bool operator <(Quantity left, Quantity right) => left.CompareTo(right) < 0;

    public static bool operator >(Quantity left, Quantity right) => left.CompareTo(right) > 0;

    public static bool operator <=(Quantity left, Quantity right) => left.CompareTo(right) <= 0;

    public static bool operator >=(Quantity left, Quantity right) => left.CompareTo(right) >= 0;

    public override string ToString() => _value.ToString(CultureInfo.InvariantCulture);
}
