using Microsoft.EntityFrameworkCore.Storage.ValueConversion;
using xOpti.Domain.Values;

namespace xOpti.Infrastructure.Persistence;

public static class Converters
{
    /// <summary>Money <-> numeric(19,4). Never float; four-decimal fidelity.</summary>
    public static readonly ValueConverter<Money, decimal> MoneyDecimal = new(
        m => m.Amount,
        d => Money.From(d));

    /// <summary>
    /// Legacy timestamp columns are `timestamp without time zone`. We always
    /// write UTC and always read back as a UTC-anchored instant, so absolute
    /// time round-trips with no local-time loss. App-owned tables use real
    /// timestamptz and skip this converter.
    /// </summary>
    public static readonly ValueConverter<DateTimeOffset, DateTime> UtcTimestamp = new(
        v => v.UtcDateTime,
        v => ReadTimestamp(v));

    public static readonly ValueConverter<DateTimeOffset?, DateTime?> UtcTimestampNullable = new(
        v => v == null ? null : v.Value.UtcDateTime,
        v => v == null ? null : ReadTimestamp(v.Value));

    /// <summary>TransactionType <-> legacy two-letter code ('RC', 'SR', ...).</summary>
    public static readonly ValueConverter<TransactionType, string> TxTypeCode = new(
        t => t.ToLegacyCode(),
        s => ReadTxType(s));

    private static DateTimeOffset ReadTimestamp(DateTime v) =>
        new(DateTime.SpecifyKind(v, DateTimeKind.Unspecified), TimeSpan.Zero);

    private static TransactionType ReadTxType(string s) =>
        TransactionTypeCodes.TryParseFromCode(s, out var t)
            ? t
            : throw new InvalidOperationException($"Unknown legacy tx type code '{s}'.");
}
