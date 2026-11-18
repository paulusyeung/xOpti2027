using Microsoft.EntityFrameworkCore;
using xOpti.Application.Pipeline;
using xOpti.Application.Wholesale;
using xOpti.Domain.Values;
using xOpti.Infrastructure.Persistence;
using xOpti.Infrastructure.Persistence.Entities;
using xOpti.Infrastructure.Repositories;
using xOpti.Infrastructure.Tests.Support;

namespace xOpti.Infrastructure.Tests;

[Collection("postgres")]
public class WholesalePricingTests(PostgresFixture fixture)
{
    private async Task<int> SeedAsync(string priceGrade = "B")
    {
        var customerId = Random.Shared.Next(950000, 959999);
        await using var seed = fixture.NewContext();
        seed.Customers.Add(new Customer { Id = customerId, FullName = "Pricing Customer" });
        seed.WholesaleAccounts.Add(new WholesaleAccount
        {
            CustomerId = customerId,
            IsWholesale = true,
            PriceGrade = priceGrade,
            TermsCode = "NET30",
            TermsDays = 30,
            CreditLimit = Money.From(10000m),
            TaxTreatment = "EXEMPT",
            CreatedAt = DateTimeOffset.UtcNow,
        });
        await seed.SaveChangesAsync();
        return customerId;
    }

    [Fact]
    public async Task PublishedListVersions_SnapshotHistoricalLinePrices()
    {
        var customerId = await SeedAsync();
        const string sku = "WS9500000001";
        await using var context = fixture.NewContext();
        var store = new EfWholesalePricingStore(context);

        var first = await store.PublishAsync(new PublishWholesalePriceListInput(
            "B", "Wholesale grade B",
            new[] { new WholesalePriceItemInput(sku, 10.1111m) }), "manager", default);
        Assert.Equal(1, first.Version);
        Assert.Equal(10.1111m, Assert.Single(first.Items).Price);

        var quote = await store.QuoteAsync(customerId, sku, null, null, false, "clerk", default);
        Assert.Equal("B", quote.PriceListCode);
        Assert.Equal(1, quote.PriceListVersion);
        Assert.Equal(10.1111m, quote.AppliedUnitPrice);
        Assert.False(quote.IsOverride);

        await store.RecordDocumentLineAsync("WC95000001", 1, quote, default);

        var second = await store.PublishAsync(new PublishWholesalePriceListInput(
            "B", "Wholesale grade B",
            new[] { new WholesalePriceItemInput(sku, 12.2222m) }), "manager", default);
        Assert.Equal(2, second.Version);
        Assert.True(second.IsCurrent);

        var repriced = await store.QuoteAsync(customerId, sku, null, null, false,
            "clerk", default);
        Assert.Equal(2, repriced.PriceListVersion);
        Assert.Equal(12.2222m, repriced.AppliedUnitPrice);

        var snapshot = Assert.Single(await store.GetDocumentLinesAsync("WC95000001", default));
        Assert.Equal(1, snapshot.PriceListVersion);
        Assert.Equal(10.1111m, snapshot.ListUnitPrice);
        Assert.Equal(10.1111m, snapshot.AppliedUnitPrice);
        Assert.False(snapshot.IsOverride);
    }

    [Fact]
    public async Task Override_RequiresPermissionAndReason_AndIsRecorded()
    {
        var customerId = await SeedAsync("A");
        const string sku = "WS9500000002";
        await using var context = fixture.NewContext();
        var store = new EfWholesalePricingStore(context);
        await store.PublishAsync(new PublishWholesalePriceListInput(
            "A", "Wholesale grade A",
            new[] { new WholesalePriceItemInput(sku, 20.0000m) }), "manager", default);

        var denied = await Assert.ThrowsAsync<ValidationFailedException>(() =>
            store.QuoteAsync(customerId, sku, 18.0000m, "discount", false, "clerk", default));
        Assert.Contains(denied.Errors, error => error.Code == "price-override-denied");

        var missingReason = await Assert.ThrowsAsync<ValidationFailedException>(() =>
            store.QuoteAsync(customerId, sku, 18.0000m, null, true, "manager", default));
        Assert.Contains(missingReason.Errors, error => error.Code == "required");

        var quote = await store.QuoteAsync(customerId, sku, 18.0000m, "volume discount",
            true, "manager", default);
        Assert.True(quote.IsOverride);
        Assert.Equal(20.0000m, quote.ListUnitPrice);
        Assert.Equal(18.0000m, quote.AppliedUnitPrice);
        Assert.Equal("volume discount", quote.OverrideReason);
        Assert.Equal("manager", quote.OverrideBy);

        await store.RecordDocumentLineAsync("WC95000002", 1, quote, default);
        var snapshot = Assert.Single(await store.GetDocumentLinesAsync("WC95000002", default));
        Assert.True(snapshot.IsOverride);
        Assert.Equal(18.0000m, snapshot.AppliedUnitPrice);
        Assert.Equal("volume discount", snapshot.OverrideReason);
    }

    [Fact]
    public async Task LegacyGradeImport_CreatesCurrentListsFromWholesalePrice()
    {
        const string sku = "WS9500000003";
        await using (var seed = fixture.NewContext())
        {
            if (!await seed.WholesalePrices.AnyAsync(row => row.Sku == sku))
            {
                seed.WholesalePrices.Add(new WholesalePrice
                {
                    Sku = sku,
                    SuggestedRetailPrice = 30.0000m,
                    GradeA = 21.1111m,
                    GradeB = 22.2222m,
                    GradeC = 23.3333m,
                });
                await seed.SaveChangesAsync();
            }
        }

        await using (var reset = fixture.NewContext())
        {
            // This test owns the import path; other pricing tests may already
            // have published grade A/B/C lists in the shared fixture database.
            var ids = await reset.WholesalePriceLists
                .Where(row => row.Code == "A" || row.Code == "B" || row.Code == "C")
                .Select(row => row.Id).ToListAsync();
            await reset.WholesalePriceListItems.Where(row => ids.Contains(row.PriceListId))
                .ExecuteDeleteAsync();
            await reset.WholesalePriceLists.Where(row => ids.Contains(row.Id))
                .ExecuteDeleteAsync();
        }

        await using var context = fixture.NewContext();
        var store = new EfWholesalePricingStore(context);
        var created = await store.ImportLegacyGradesAsync("import", default);
        Assert.InRange(created, 0, 3);

        foreach (var (grade, expected) in new[]
                 {
                     ("A", 21.1111m), ("B", 22.2222m), ("C", 23.3333m),
                 })
        {
            var list = await store.GetCurrentAsync(grade, default);
            Assert.NotNull(list);
            var item = Assert.Single(list!.Items.Where(row => row.Sku == sku));
            Assert.Equal(expected, item.Price);
        }
    }
}
