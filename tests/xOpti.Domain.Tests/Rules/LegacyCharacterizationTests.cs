using System.Globalization;
using System.Text;
using xOpti.Domain.Rules;
using xOpti.Domain.Values;

namespace xOpti.Domain.Tests.Rules;

/// <summary>
/// Characterization tests reproducing legacy-computed outputs from exported
/// production rows (tests/xOpti.Domain.Tests/Data, provenance in Data/README.md).
/// </summary>
public class LegacyCharacterizationTests
{
    private static string DataPath(string file) =>
        Path.Combine(AppContext.BaseDirectory, "Data", file);

    private static IEnumerable<Dictionary<string, string>> ReadCsv(string file)
    {
        using var reader = new StreamReader(DataPath(file), Encoding.UTF8);
        using var csv = new Microsoft.VisualBasic.FileIO.TextFieldParser(reader);
        csv.Delimiters = new[] { "," };
        csv.HasFieldsEnclosedInQuotes = true;
        var header = csv.ReadFields()!.Select(h => h.Trim()).ToArray();
        while (!csv.EndOfData)
        {
            var fields = csv.ReadFields()!.Select(f => f.Trim()).ToArray();
            yield return header.Zip(fields, (k, v) => (k, v)).ToDictionary(p => p.k, p => p.v);
        }
    }

    private static decimal D(string value) => decimal.Parse(value, CultureInfo.InvariantCulture);

    private static DateTimeOffset Date(string legacy) =>
        DateTimeOffset.ParseExact(legacy, "M/d/yy HH:mm:ss", CultureInfo.InvariantCulture);

    [Fact]
    public void TaxCharacterization_reproduces_legacy_tax_amounts_and_totals()
    {
        var rows = ReadCsv("tax_lines_sample.csv").ToList();
        Assert.NotEmpty(rows);

        foreach (var row in rows)
        {
            var method = TaxMethodCodes.TryParseFromCode(row["tax_code"], out var m)
                ? m
                : throw new Xunit.Sdk.XunitException($"Unknown tax code {row["tax_code"]}");
            var code = TaxCode.Create(method, D(row["gst_rate"]), D(row["pst_rate"])).Value;

            var result = TaxCalculator.Calculate(code, Money.From(D(row["line_amount"])));

            Assert.True(result.IsSuccess, $"{row["control_number"]}: {result.Error}");
            Assert.Equal(Money.From(D(row["legacy_gst"])), result.Value.Gst);
            Assert.Equal(Money.From(D(row["legacy_pst"])), result.Value.Pst);
            Assert.Equal(Money.From(D(row["legacy_gross"])), result.Value.Gross);
        }
    }

    private sealed record LegacyLot(string LotNo, DateTimeOffset ReceivedOn, string SupplierCode, decimal QtyOnHand, decimal UnitCost);

    private static List<LegacyLot> LotsFor(string sku) =>
        ReadCsv("lots_sample.csv")
            .Where(r => r["SKU"] == sku)
            .Select(r => new LegacyLot(r["LotNo"], Date(r["DateReceived"]), r["SupplierCode"], D(r["QtyOnHand"]), D(r["UnitAmountPurchased"])))
            .ToList();

    private static CostLayer ToLayer(LegacyLot lot) =>
        lot.QtyOnHand >= 0
            ? CostLayer.Create(lot.LotNo, lot.ReceivedOn, 0, Money.From(lot.UnitCost), Quantity.From(lot.QtyOnHand)).Value
            : CostLayer.CreateDeficit(lot.LotNo, lot.ReceivedOn, 0, Money.From(lot.UnitCost), Quantity.From(lot.QtyOnHand)).Value;

    [Fact]
    public void LotsCharacterization_legacy_data_contains_deficit_layers_from_sold_before_receipt()
    {
        var lots = LotsFor("00000008");
        Assert.Contains(lots, l => l.QtyOnHand == -64m);

        var deficit = ToLayer(lots.Single(l => l.QtyOnHand == -64m));
        Assert.True(deficit.IsDeficit);
        Assert.Equal(Quantity.From(-64m), deficit.RemainingQuantity);
    }

    [Fact]
    public void FifoCharacterization_consumes_real_legacy_layers_oldest_first()
    {
        var lots = LotsFor("00000008").Where(l => l.QtyOnHand > 0).ToList();
        Assert.Equal(3, lots.Count);

        var result = CostingPolicy.Issue(
            lots.Select(ToLayer).ToList(), "RC00000001", Quantity.From(26m),
            CategoryCostingMethod.Fifo, Money.From(4.365m));

        Assert.True(result.IsSuccess);
        Assert.Equal(new[] { "00041482", "00057404" }, result.Value.Consumptions.Select(c => c.SourceDocument));
        Assert.Equal(Quantity.From(24m), result.Value.Consumptions[0].Quantity);
        Assert.Equal(Money.From(4.365m), result.Value.Consumptions[0].UnitCost);
        Assert.Equal(Money.From(4.28m), result.Value.Consumptions[1].UnitCost);
        Assert.Equal(Money.From(104.76m + 4.28m * 2m), result.Value.TotalCost);
        Assert.Equal(Quantity.Zero, result.Value.DeficitQuantity);
    }

    [Fact]
    public void LifoCharacterization_consumes_real_legacy_layers_newest_first()
    {
        var lots = LotsFor("00000008").Where(l => l.QtyOnHand > 0).ToList();

        var result = CostingPolicy.Issue(
            lots.Select(ToLayer).ToList(), "RC00000002", Quantity.From(2m),
            CategoryCostingMethod.Lifo, Money.From(4.365m));

        Assert.True(result.IsSuccess);
        Assert.Equal("00142751", result.Value.Consumptions[0].SourceDocument);
        Assert.Equal(Money.From(2.94m), result.Value.Consumptions[0].UnitCost);
        Assert.Equal(Money.From(5.88m), result.Value.TotalCost);
    }

    [Fact]
    public void AverageCharacterization_blends_real_legacy_layer_costs()
    {
        var lots = LotsFor("00000008").Where(l => l.QtyOnHand > 0).ToList();

        var result = CostingPolicy.Issue(
            lots.Select(ToLayer).ToList(), "RC00000003", Quantity.From(10m),
            CategoryCostingMethod.Average, Money.From(4.365m));

        Assert.True(result.IsSuccess);
        // Weighted mean of 24@4.365, 24@4.28, 24@2.94 = 3.8617
        Assert.Equal(Money.From(3.8617m), result.Value.Consumptions[0].UnitCost);
        Assert.Equal(Money.From(38.617m), result.Value.TotalCost);
    }

    [Fact]
    public void SixLayerSkuCharacterization_fifo_across_real_receipt_spread()
    {
        var lots = LotsFor("00000551").Where(l => l.QtyOnHand > 0).ToList();
        Assert.Equal(6, lots.Count);

        var result = CostingPolicy.Issue(
            lots.Select(ToLayer).ToList(), "RC00000004", Quantity.From(3m),
            CategoryCostingMethod.Fifo, Money.From(2.5m));

        Assert.True(result.IsSuccess);
        Assert.Equal(new[] { "00188170", "00295453" }, result.Value.Consumptions.Select(c => c.SourceDocument));
        Assert.Equal(Money.From(7.9m * 2m + 2.0m), result.Value.TotalCost);
    }

    [Fact]
    public void DeficitCharacterization_sale_beyond_real_onhand_flags_deficit_not_abort()
    {
        var lots = LotsFor("00000008").Where(l => l.QtyOnHand > 0).ToList();

        var result = CostingPolicy.Issue(
            lots.Select(ToLayer).ToList(), "RC00000005", Quantity.From(80m),
            CategoryCostingMethod.Fifo, Money.From(4.365m));

        Assert.True(result.IsSuccess);
        Assert.Equal(Quantity.From(8m), result.Value.DeficitQuantity);
        Assert.NotNull(result.Value.DeficitLayer);
        Assert.Equal(Money.From(4.365m), result.Value.DeficitLayer!.UnitCost);
    }

    [Fact]
    public void DeficitReconciliationCharacterization_covers_legacy_deficit_by_receipt()
    {
        var deficit = ToLayer(LotsFor("00000008").Single(l => l.QtyOnHand == -64m));

        var partial = deficit.Reconcile(Quantity.From(60m));
        Assert.True(partial.IsSuccess);
        Assert.True(partial.Value.IsDeficit);

        var final = partial.Value.Reconcile(Quantity.From(4m));
        Assert.True(final.IsSuccess);
        Assert.False(final.Value.IsDeficit);
        Assert.Equal(Quantity.Zero, final.Value.RemainingQuantity);
    }
}
