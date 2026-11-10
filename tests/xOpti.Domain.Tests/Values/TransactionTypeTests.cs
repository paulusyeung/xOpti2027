using xOpti.Domain.Values;

namespace xOpti.Domain.Tests.Values;

public class TransactionTypeTests
{
    [Theory]
    [InlineData("SR", TransactionType.StockReceived)]
    [InlineData("RJ", TransactionType.StockRejected)]
    [InlineData("SJ", TransactionType.StockAdjustment)]
    [InlineData("RC", TransactionType.RetailInvoice)]
    [InlineData("RS", TransactionType.RetailRefund)]
    [InlineData("WC", TransactionType.WholesaleInvoice)]
    [InlineData("WR", TransactionType.WholesaleReturn)]
    [InlineData("SA", TransactionType.SalesOrder)]
    public void All_legacy_codes_parse(string code, TransactionType expected)
    {
        Assert.True(TransactionTypeCodes.TryParseFromCode(code, out var parsed));
        Assert.Equal(expected, parsed);
        Assert.Equal(code, parsed.ToLegacyCode());
    }

    [Theory]
    [InlineData("ZZ")]
    [InlineData("rc")]
    [InlineData("S")]
    [InlineData("SRX")]
    [InlineData("")]
    [InlineData(null)]
    public void Unknown_codes_are_rejected(string? code)
    {
        Assert.False(TransactionTypeCodes.TryParseFromCode(code, out _));
    }

    [Fact]
    public void Parsing_is_tolerant_of_legacy_padding()
    {
        Assert.True(TransactionTypeCodes.TryParseFromCode("  RC ", out var parsed));
        Assert.Equal(TransactionType.RetailInvoice, parsed);
    }

    [Fact]
    public void Taxonomy_is_closed_at_eight_types()
    {
        Assert.Equal(8, Enum.GetValues<TransactionType>().Length);
        Assert.Equal(8, TransactionTypeCodes.AllCodes.Count);
    }
}
