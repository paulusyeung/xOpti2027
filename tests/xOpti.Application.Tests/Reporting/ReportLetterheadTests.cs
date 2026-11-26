using xOpti.Application.Reporting;
using xOpti.Application.Settings;

namespace xOpti.Application.Tests.Reporting;

public static class ReportLetterheadTests
{
    [Fact]
    public static void From_Preferences_UsesConfiguredShopIdentity()
    {
        var preferences = new PreferencesDto(
            "1", "p", "product", "Configured Optical", "12 Main Street",
            "Configured Holdings Ltd", "2 Other Road", "896634235", "PST1",
            0, 0, 0, 0, "(604) 111-2222", "(604) 333-4444", null, null,
            11, "VANCOUVER", "BC", "V6E 1B2", "CA", "CANADA");

        var letterhead = ReportLetterheadDto.From(preferences);

        Assert.Equal("Configured Optical", letterhead.ShopName);
        Assert.Equal("Configured Holdings Ltd", letterhead.LegalName);
        Assert.Equal("12 Main Street, VANCOUVER, BC CANADA V6E 1B2", letterhead.Address);
        Assert.Equal("(604) 111-2222", letterhead.Phone);
        Assert.Equal("(604) 333-4444", letterhead.Fax);
        Assert.Equal("R-896634235", letterhead.GstNumber);
        Assert.Equal("Configured Optical", letterhead.TitleName);
    }

    [Fact]
    public static void From_BlankPreferences_FallsBackToLegacyDefaults()
    {
        var preferences = new PreferencesDto(
            "1", "p", "product", "", null, "", null, null, null, 0, 0, 0, 0);

        var letterhead = ReportLetterheadDto.From(preferences);

        Assert.Equal("THE OPTICAL CENTRE ROBSON", letterhead.ShopName);
        Assert.Equal("(604) 699-9368", letterhead.Phone);
        Assert.Equal("R-896634235", letterhead.GstNumber);
    }
}
