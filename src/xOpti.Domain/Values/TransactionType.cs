namespace xOpti.Domain.Values;

/// <summary>
/// Closed legacy transaction taxonomy from eOptical 6.1.184 (AppOLTP.bas / README).
/// Legacy codes are two-character, uppercase, case-sensitive.
/// </summary>
public enum TransactionType
{
    StockReceived,
    StockRejected,
    StockAdjustment,
    RetailInvoice,
    RetailRefund,
    WholesaleInvoice,
    WholesaleReturn,
    SalesOrder,
}

public static class TransactionTypeCodes
{
    private static readonly Dictionary<TransactionType, string> ToCode = new()
    {
        [TransactionType.StockReceived] = "SR",
        [TransactionType.StockRejected] = "RJ",
        [TransactionType.StockAdjustment] = "SJ",
        [TransactionType.RetailInvoice] = "RC",
        [TransactionType.RetailRefund] = "RS",
        [TransactionType.WholesaleInvoice] = "WC",
        [TransactionType.WholesaleReturn] = "WR",
        [TransactionType.SalesOrder] = "SA",
    };

    private static readonly Dictionary<string, TransactionType> FromCode =
        ToCode.ToDictionary(pair => pair.Value, pair => pair.Key);

    public static IReadOnlyCollection<string> AllCodes { get; } = ToCode.Values.ToList();

    public static string ToLegacyCode(this TransactionType type) => ToCode[type];

    public static bool TryParseFromCode(string? code, out TransactionType type)
    {
        type = default;
        if (code is null)
        {
            return false;
        }

        // Tolerant of legacy padding/trailing whitespace, not of case.
        return FromCode.TryGetValue(code.Trim(), out type);
    }
}
