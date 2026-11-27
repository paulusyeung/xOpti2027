using xOpti.Application.Reporting;

namespace xOpti.Application.Tests.Reporting;

public static class InvoiceTaxPeriodTests
{
    private static InvoiceReport At(int year, int month, int day) => new(
        "RC00000001",
        new DateTimeOffset(year, month, day, 12, 0, 0, TimeSpan.Zero),
        null, null, "Customer", null, null, null, null, null, null, null, null,
        Array.Empty<InvoiceReportLine>(), Array.Empty<InvoiceReportPayment>(),
        100m, 5m, 7m, 112m, 0m, 0m);

    [Fact]
    public static void BeforeHst_UsesGstAndPst()
    {
        var report = At(2010, 6, 30);

        Assert.False(report.UsesHst);
        Assert.Equal("G.S.T.:", report.TaxALabel);
        Assert.Equal("P.S.T.:", report.TaxBLabel);
        Assert.Equal(5m, report.TaxAAmount);
        Assert.Equal(7m, report.TaxBAmount);
    }

    [Theory]
    [InlineData(2010, 7, 1)]
    [InlineData(2012, 3, 15)]
    [InlineData(2015, 3, 31)]
    public static void DuringHst_CombinesTaxes(int year, int month, int day)
    {
        var report = At(year, month, day);

        Assert.True(report.UsesHst);
        Assert.Equal("H.S.T.:", report.TaxALabel);
        Assert.Equal(string.Empty, report.TaxBLabel);
        Assert.Equal(12m, report.TaxAAmount);
        Assert.Equal(0m, report.TaxBAmount);
    }

    [Theory]
    [InlineData(2015, 4, 1)]
    [InlineData(2016, 5, 18)]
    public static void AfterHst_RestoresGstAndPst(int year, int month, int day)
    {
        var report = At(year, month, day);

        Assert.False(report.UsesHst);
        Assert.Equal("G.S.T.:", report.TaxALabel);
        Assert.Equal("P.S.T.:", report.TaxBLabel);
        Assert.Equal(5m, report.TaxAAmount);
        Assert.Equal(7m, report.TaxBAmount);
    }
}
