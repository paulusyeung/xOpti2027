using System.Net;
using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using xOpti.Api.IntegrationTests.Support;
using xOpti.Domain.Values;
using xOpti.Infrastructure.Persistence.Entities;

namespace xOpti.Api.IntegrationTests;

[Collection("api")]
public sealed class WholesalePricingApiTests(ApiPostgresFixture fixture)
{
    private static async Task<JsonElement> BodyAsync(HttpResponseMessage response,
        XOptiApiFactory factory, HttpStatusCode expected)
    {
        if (response.StatusCode != expected)
        {
            var exceptions = string.Join("\n", factory.Logs.Snapshot()
                .Where(entry => entry.Exception is not null)
                .Select(entry => entry.Exception!.ToString()));
            Assert.Fail($"{response.StatusCode}: {await response.Content.ReadAsStringAsync()}\n{exceptions}");
        }
        using var document = JsonDocument.Parse(await response.Content.ReadAsStringAsync());
        return document.RootElement.Clone();
    }

    private async Task<(int CustomerId, string Sku, string Code)> SeedAsync(
        string code = "A")
    {
        var customerId = Random.Shared.Next(960000, 969999);
        var sku = "WP" + Random.Shared.Next(10000000, 99999999);
        await using var seed = fixture.NewContext();
        seed.Customers.Add(new Customer { Id = customerId, FullName = "Price API Customer" });
        seed.WholesaleAccounts.Add(new WholesaleAccount
        {
            CustomerId = customerId,
            IsWholesale = true,
            PriceGrade = code,
            TermsCode = "NET30",
            TermsDays = 30,
            CreditLimit = Money.From(5000m),
            TaxTreatment = "EXEMPT",
            CreatedAt = DateTimeOffset.UtcNow,
        });
        await seed.SaveChangesAsync();
        return (customerId, sku, code);
    }

    [Fact]
    public async Task PublishQuoteOverrideAndPermissions_WorkThroughTheApi()
    {
        var (customerId, sku, code) = await SeedAsync();
        var factory = new XOptiApiFactory(fixture);
        using var manager = new TestClient(factory);
        await manager.FetchCsrfTokenAsync();
        await manager.SignInAsync("manager", SeedData.Password);

        var published = await BodyAsync(await manager.PostAsync("/api/v1/wholesale/price-lists",
            new
            {
                input = new
                {
                    code,
                    name = "API wholesale list",
                    items = new[] { new { sku, price = 14.4444m } },
                },
                reason = "publish test list",
            }), factory, HttpStatusCode.OK);
        Assert.True(published.GetProperty("version").GetInt32() > 0);

        var quote = await BodyAsync(await manager.GetAsync(
            $"/api/v1/wholesale/customers/{customerId}/price?sku={sku}"),
            factory, HttpStatusCode.OK);
        Assert.Equal(14.4444m, quote.GetProperty("listUnitPrice").GetDecimal());
        Assert.Equal(14.4444m, quote.GetProperty("appliedUnitPrice").GetDecimal());
        Assert.False(quote.GetProperty("isOverride").GetBoolean());

        var overridden = await BodyAsync(await manager.GetAsync(
            $"/api/v1/wholesale/customers/{customerId}/price?sku={sku}"
            + "&unitPrice=12.3456&overrideReason=volume%20discount"),
            factory, HttpStatusCode.OK);
        Assert.True(overridden.GetProperty("isOverride").GetBoolean());
        Assert.Equal(12.3456m, overridden.GetProperty("appliedUnitPrice").GetDecimal());
        Assert.Equal("volume discount", overridden.GetProperty("overrideReason").GetString());

        var missingReason = await manager.GetAsync(
            $"/api/v1/wholesale/customers/{customerId}/price?sku={sku}&unitPrice=11.0000");
        Assert.Equal(HttpStatusCode.BadRequest, missingReason.StatusCode);
        Assert.Contains("reason", await missingReason.Content.ReadAsStringAsync(),
            StringComparison.OrdinalIgnoreCase);

        await using var verify = fixture.NewContext();
        Assert.True(await verify.AuditLogs.AnyAsync(row =>
            row.Action == "wholesale.price-list.publish"
            && row.EntityType == "WholesalePriceList"));
        Assert.True(await verify.AuditLogs.AnyAsync(row =>
            row.Action == "wholesale.price.override"
            && row.EntityId == $"{customerId}:{sku}"));

        using var clerk = new TestClient(factory);
        await clerk.FetchCsrfTokenAsync();
        await clerk.SignInAsync("clerk", SeedData.Password);
        Assert.Equal(HttpStatusCode.Forbidden,
            (await clerk.GetAsync("/api/v1/wholesale/price-lists")).StatusCode);
        Assert.Equal(HttpStatusCode.Forbidden,
            (await clerk.GetAsync(
                $"/api/v1/wholesale/customers/{customerId}/price?sku={sku}")).StatusCode);
        Assert.Equal(HttpStatusCode.Forbidden,
            (await clerk.PostAsync("/api/v1/wholesale/price-lists", new
            {
                input = new
                {
                    code,
                    name = "Clerk list",
                    items = new[] { new { sku, price = 1m } },
                },
                reason = "clerk cannot publish",
            })).StatusCode);
    }

    [Fact]
    public async Task MissingPriceListForGrade_BlocksQuotingWithClearConfigurationError()
    {
        var (customerId, sku, _) = await SeedAsync("C");
        await using (var reset = fixture.NewContext())
        {
            var ids = await reset.WholesalePriceLists
                .Where(row => row.Code == "C").Select(row => row.Id).ToListAsync();
            await reset.WholesalePriceListItems.Where(row => ids.Contains(row.PriceListId))
                .ExecuteDeleteAsync();
            await reset.WholesalePriceLists.Where(row => ids.Contains(row.Id))
                .ExecuteDeleteAsync();
        }
        var factory = new XOptiApiFactory(fixture);
        using var manager = new TestClient(factory);
        await manager.FetchCsrfTokenAsync();
        await manager.SignInAsync("manager", SeedData.Password);

        var response = await manager.GetAsync(
            $"/api/v1/wholesale/customers/{customerId}/price?sku={sku}");
        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
        Assert.Contains("price list", await response.Content.ReadAsStringAsync(),
            StringComparison.OrdinalIgnoreCase);
    }
}
