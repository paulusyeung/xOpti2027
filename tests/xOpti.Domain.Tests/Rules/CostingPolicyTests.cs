using xOpti.Domain.Rules;
using xOpti.Domain.Values;

namespace xOpti.Domain.Tests.Rules;

public class CostingPolicyTests
{
    private static CostLayer Layer(string doc, string date, long seq, decimal unitCost, decimal remaining) =>
        CostLayer.Create(doc, DateTimeOffset.Parse(date), seq, Money.From(unitCost), Quantity.From(remaining)).Value;

    private static readonly DateTimeOffset D1 = new(2020, 1, 1, 0, 0, 0, TimeSpan.Zero);
    private static readonly DateTimeOffset D2 = new(2021, 1, 1, 0, 0, 0, TimeSpan.Zero);
    private static readonly DateTimeOffset D3 = new(2022, 1, 1, 0, 0, 0, TimeSpan.Zero);

    [Fact]
    public void Lifo_consumes_newest_layer_first()
    {
        var layers = new[]
        {
            Layer("A", "2020-01-01", 1, 10m, 5m),
            Layer("B", "2021-01-01", 2, 12m, 5m),
            Layer("C", "2022-01-01", 3, 14m, 3m),
        };

        var result = CostingPolicy.Issue(layers, "RC00000001", Quantity.From(3m), CategoryCostingMethod.Lifo, Money.From(14m));

        Assert.True(result.IsSuccess);
        Assert.Single(result.Value.Consumptions);
        Assert.Equal("C", result.Value.Consumptions[0].SourceDocument);
        Assert.Equal(Money.From(14m), result.Value.Consumptions[0].UnitCost);
        Assert.Equal(Money.From(42m), result.Value.TotalCost);
    }

    [Fact]
    public void Lifo_spawns_to_next_older_layer_when_newest_depleted()
    {
        var layers = new[]
        {
            Layer("A", "2020-01-01", 1, 10m, 5m),
            Layer("C", "2022-01-01", 3, 14m, 3m),
        };

        var result = CostingPolicy.Issue(layers, "RC1", Quantity.From(4m), CategoryCostingMethod.Lifo, Money.From(99m));

        Assert.True(result.IsSuccess);
        Assert.Equal(new[] { "C", "A" }, result.Value.Consumptions.Select(c => c.SourceDocument));
        Assert.Equal(Money.From(42m + 10m), result.Value.TotalCost);
    }

    [Fact]
    public void Fifo_consumes_oldest_layer_first()
    {
        var layers = new[]
        {
            Layer("A", "2020-01-01", 1, 4.365m, 24m),
            Layer("B", "1999-02-23", 2, 4.365m, 24m),
        };

        var result = CostingPolicy.Issue(layers, "RC1", Quantity.From(30m), CategoryCostingMethod.Fifo, Money.From(5m));

        Assert.True(result.IsSuccess);
        Assert.Equal(new[] { "B", "A" }, result.Value.Consumptions.Select(c => c.SourceDocument));
        Assert.Equal(Quantity.From(24m), result.Value.Consumptions[0].Quantity);
        Assert.Equal(Quantity.From(6m), result.Value.Consumptions[1].Quantity);
        Assert.Null(result.Value.DeficitLayer);
    }

    [Fact]
    public void Average_blends_remaining_layer_costs()
    {
        var layers = new[]
        {
            Layer("A", "2020-01-01", 1, 10m, 10m),
            Layer("B", "2021-01-01", 2, 12m, 10m),
            Layer("C", "2022-01-01", 3, 14m, 10m),
        };

        var result = CostingPolicy.Issue(layers, "RC1", Quantity.From(6m), CategoryCostingMethod.Average, Money.From(50m));

        Assert.True(result.IsSuccess);
        var blended = result.Value.Consumptions[0].UnitCost;
        Assert.Equal(Money.From(12m), blended);
        Assert.Equal(Money.From(72m), result.Value.TotalCost);
        Assert.All(result.Value.Consumptions, c => Assert.Equal(blended, c.UnitCost));
    }

    [Fact]
    public void Deficit_allocated_when_layers_depleted()
    {
        var layers = new[]
        {
            Layer("A", "2020-01-01", 1, 10m, 2m),
        };

        var result = CostingPolicy.Issue(layers, "RC00000007", Quantity.From(5m), CategoryCostingMethod.Fifo, Money.From(14m));

        Assert.True(result.IsSuccess);
        Assert.Equal(Quantity.From(3m), result.Value.DeficitQuantity);
        Assert.NotNull(result.Value.DeficitLayer);
        Assert.True(result.Value.DeficitLayer!.IsDeficit);
        Assert.Equal(Quantity.From(-3m), result.Value.DeficitLayer.RemainingQuantity);
        Assert.Equal(Money.From(14m), result.Value.DeficitLayer.UnitCost);
        Assert.Equal(Money.From(20m + 42m), result.Value.TotalCost);
    }

    [Fact]
    public void Zero_available_stock_still_completes_via_deficit()
    {
        var result = CostingPolicy.Issue(Array.Empty<CostLayer>(), "RC1", Quantity.From(3m), CategoryCostingMethod.Fifo, Money.From(8m));

        Assert.True(result.IsSuccess);
        Assert.Empty(result.Value.Consumptions);
        Assert.Equal(Quantity.From(3m), result.Value.DeficitQuantity);
        Assert.Equal(Money.From(24m), result.Value.TotalCost);
    }

    [Fact]
    public void Negative_or_zero_issue_quantity_rejected()
    {
        Assert.False(CostingPolicy.Issue(Array.Empty<CostLayer>(), "RC1", Quantity.Zero, CategoryCostingMethod.Fifo, Money.Zero).IsSuccess);
        Assert.False(CostingPolicy.Issue(Array.Empty<CostLayer>(), "RC1", Quantity.From(-1m), CategoryCostingMethod.Fifo, Money.Zero).IsSuccess);
    }

    [Fact]
    public void Existing_deficit_layers_are_not_consumed()
    {
        var deficit = CostLayer.CreateDeficit("RC1", D1, 1, Money.From(5m), Quantity.From(-2m)).Value;
        var positive = Layer("A", "2020-01-01", 1, 10m, 5m);

        var result = CostingPolicy.Issue(new[] { deficit, positive }, "RC2", Quantity.From(3m), CategoryCostingMethod.Fifo, Money.From(99m));

        Assert.True(result.IsSuccess);
        Assert.Equal(Quantity.Zero, result.Value.DeficitQuantity);
        Assert.Single(result.Value.Consumptions);
        Assert.Equal("A", result.Value.Consumptions[0].SourceDocument);
    }

    [Theory]
    [InlineData("2", CategoryCostingMethod.Lifo)]
    [InlineData(null, CategoryCostingMethod.Fifo)]
    [InlineData("", CategoryCostingMethod.Fifo)]
    [InlineData("0", CategoryCostingMethod.Fifo)]
    [InlineData("1", CategoryCostingMethod.Average)]
    public void Legacy_category_code_mapping(string? code, CategoryCostingMethod expectedNonTwo)
    {
        var result = CostingMethodResolver.FromLegacyCode(code, expectedNonTwo);
        var isLifo = code?.Trim() == "2";
        Assert.Equal(isLifo ? CategoryCostingMethod.Lifo : expectedNonTwo, result);
    }

    [Fact]
    public void Tie_break_by_sequence_when_dates_equal()
    {
        var layers = new[]
        {
            Layer("B2", "2022-01-01", 2, 12m, 5m),
            Layer("B1", "2022-01-01", 1, 10m, 5m),
        };

        var fifo = CostingPolicy.Issue(layers, "RC1", Quantity.From(2m), CategoryCostingMethod.Fifo, Money.From(50m));
        Assert.Equal("B1", fifo.Value.Consumptions[0].SourceDocument);

        var lifo = CostingPolicy.Issue(layers, "RC1", Quantity.From(2m), CategoryCostingMethod.Lifo, Money.From(50m));
        Assert.Equal("B2", lifo.Value.Consumptions[0].SourceDocument);
    }
}
