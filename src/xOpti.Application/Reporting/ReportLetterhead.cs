using xOpti.Application.Settings;

namespace xOpti.Application.Reporting;

/// <summary>
/// Shop identity printed in report headers and on bar-code labels. Values come
/// from the existing public.preference row, so no schema change is required.
/// </summary>
public sealed record ReportLetterheadDto(
    string ShopName,
    string LegalName,
    string Address,
    string Phone,
    string Fax,
    string GstNumber,
    string TitleName)
{
    /// <summary>
    /// Legacy Crystal defaults are used only when a preference value is blank,
    /// so an incompletely configured database still produces a usable report.
    /// </summary>
    public static ReportLetterheadDto From(PreferencesDto preferences) => new(
        Pick(preferences.UserName, "THE OPTICAL CENTRE ROBSON"),
        Pick(preferences.OwnerName, "THE OPTICAL INTERNATIONAL INVESTMENT COMPANY LTD."),
        ComposeAddress(preferences),
        Pick(preferences.UserPhone, "(604) 699-9368"),
        Pick(preferences.UserFax, "(604) 899-9367"),
        FormatGst(preferences.GstNumber),
        Pick(preferences.UserName, "The Optical Centre, Richmond"));

    /// <summary>
    /// Builds one letterhead line from the street address and the legacy city,
    /// province, country and postal-code columns. City and country codes are
    /// resolved to names by IPreferencesStore.
    /// </summary>
    private static string ComposeAddress(PreferencesDto preferences)
    {
        var parts = new List<string>();
        Add(parts, preferences.UserAddress);
        Add(parts, preferences.UserCityName);

        var region = new List<string>();
        Add(region, preferences.UserProvince);
        var country = string.IsNullOrWhiteSpace(preferences.UserCountryName)
            ? preferences.UserCountryCode
            : preferences.UserCountryName;
        Add(region, country);
        Add(region, preferences.UserPostalCode);
        if (region.Count > 0) parts.Add(string.Join(" ", region));
        return parts.Count == 0
            ? "1190 ROBSON STREET, VANCOUVER, B.C. CANADA V6E 1B2"
            : string.Join(", ", parts);
    }

    private static void Add(List<string> parts, string? value)
    {
        if (!string.IsNullOrWhiteSpace(value)) parts.Add(value.Trim());
    }

    private static string Pick(string? value, string fallback) =>
        string.IsNullOrWhiteSpace(value) ? fallback : value.Trim();

    private static string FormatGst(string? value)
    {
        var gst = Pick(value, "R-896634235");
        return gst.StartsWith("R-", StringComparison.OrdinalIgnoreCase) ? gst : $"R-{gst}";
    }
}
