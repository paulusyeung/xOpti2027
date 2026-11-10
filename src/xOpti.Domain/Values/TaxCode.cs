namespace xOpti.Domain.Values;

/// <summary>
/// Legacy tax method codes are case-sensitive: 'g'/'p' differ from 'G'/'P'
/// (frmPriceWizard.frm).
/// </summary>
public enum TaxMethod
{
    /// <summary>'N' - tax exempt/excluded.</summary>
    Exempt,

    /// <summary>'B' - GST and PST both applied on the net base.</summary>
    GstPlusPst,

    /// <summary>'G' - GST only.</summary>
    GstOnly,

    /// <summary>'P' - PST only.</summary>
    PstOnly,

    /// <summary>'g' - GST is included in the quoted price.</summary>
    GstIncluded,

    /// <summary>'p' - PST is charged on top of GST.</summary>
    PstOnGst,
}

public static class TaxMethodCodes
{
    private static readonly Dictionary<TaxMethod, string> ToCode = new()
    {
        [TaxMethod.Exempt] = "N",
        [TaxMethod.GstPlusPst] = "B",
        [TaxMethod.GstOnly] = "G",
        [TaxMethod.PstOnly] = "P",
        [TaxMethod.GstIncluded] = "g",
        [TaxMethod.PstOnGst] = "p",
    };

    private static readonly Dictionary<string, TaxMethod> FromCode =
        ToCode.ToDictionary(pair => pair.Value, pair => pair.Key);

    public static string ToLegacyCode(this TaxMethod method) => ToCode[method];

    public static bool TryParseFromCode(string? code, out TaxMethod method)
    {
        method = default;
        return code is not null && FromCode.TryGetValue(code.Trim(), out method);
    }
}

/// <summary>
/// Tax method plus the caller-supplied rates that apply to a line.
/// Rates are decimal fractions (0.05 = 5%).
/// </summary>
public sealed record TaxCode
{
    public TaxMethod Method { get; }

    public decimal GstRate { get; }

    public decimal PstRate { get; }

    private TaxCode(TaxMethod method, decimal gstRate, decimal pstRate)
    {
        Method = method;
        GstRate = gstRate;
        PstRate = pstRate;
    }

    public static TaxCode Exempt() => new(TaxMethod.Exempt, 0m, 0m);

    public static Common.Result<TaxCode> Create(TaxMethod method, decimal gstRate, decimal pstRate)
    {
        if (gstRate < 0m || pstRate < 0m)
        {
            return Common.Result<TaxCode>.Failure("Tax rates must not be negative.");
        }

        if (method == TaxMethod.Exempt)
        {
            return Common.Result<TaxCode>.Success(new TaxCode(method, 0m, 0m));
        }

        if (method is not (TaxMethod.GstPlusPst or TaxMethod.PstOnGst) && gstRate > 0m && pstRate > 0m)
        {
            return Common.Result<TaxCode>.Failure($"Method '{method.ToLegacyCode()}' must not carry both GST and PST rates; use 'B' or 'p'.");
        }

        return Common.Result<TaxCode>.Success(new TaxCode(method, gstRate, pstRate));
    }
}
