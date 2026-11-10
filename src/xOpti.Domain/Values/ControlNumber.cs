using System.Text.RegularExpressions;

namespace xOpti.Domain.Values;

/// <summary>
/// Legacy prefixed control number (txnumber style, e.g. RC00023371).
/// Family prefixes follow the closed transaction taxonomy.
/// </summary>
public readonly record struct ControlNumber : IComparable<ControlNumber>
{
    private static readonly Regex Pattern = new(
        @"^(?<family>[A-Z]{2})(?<sequence>\d{1,12})$",
        RegexOptions.Compiled);

    public TransactionType Family { get; }

    public long Sequence { get; }

    public string Value { get; }

    private ControlNumber(TransactionType family, long sequence, string value)
    {
        Family = family;
        Sequence = sequence;
        Value = value;
    }

    public static bool TryParse(string? raw, out ControlNumber controlNumber)
    {
        controlNumber = default;
        if (raw is null)
        {
            return false;
        }

        var match = Pattern.Match(raw.Trim());
        if (!match.Success)
        {
            return false;
        }

        if (!TransactionTypeCodes.TryParseFromCode(match.Groups["family"].Value, out var family))
        {
            return false;
        }

        var sequence = long.Parse(match.Groups["sequence"].Value);
        controlNumber = new ControlNumber(family, sequence, match.Value);
        return true;
    }

    public static ControlNumber Create(TransactionType family, long sequence)
    {
        ArgumentOutOfRangeException.ThrowIfNegativeOrZero(sequence);
        var prefix = family.ToLegacyCode();
        return new ControlNumber(family, sequence, $"{prefix}{sequence:00000000}");
    }

    /// <summary>
    /// True when this number is the strict successor-or-later of <paramref name="previous"/>
    /// within the same family; cross-family comparisons are meaningless.
    /// </summary>
    public bool Follows(ControlNumber previous) =>
        Family == previous.Family && Sequence > previous.Sequence;

    public static Common.Result<int> CompareWithinFamily(ControlNumber left, ControlNumber right)
    {
        if (left.Family != right.Family)
        {
            return Common.Result<int>.Failure(
                $"Cannot compare control numbers across families ({left.Family.ToLegacyCode()} vs {right.Family.ToLegacyCode()}).");
        }

        return Common.Result<int>.Success(left.Sequence.CompareTo(right.Sequence));
    }

    public int CompareTo(ControlNumber other)
    {
        var byFamily = string.CompareOrdinal(Family.ToLegacyCode(), other.Family.ToLegacyCode());
        return byFamily != 0 ? byFamily : Sequence.CompareTo(other.Sequence);
    }

    public override string ToString() => Value;
}
