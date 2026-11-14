using System.Net;
using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using xOpti.Api.IntegrationTests.Support;

namespace xOpti.Api.IntegrationTests;

[Collection("api")]
public sealed class InventoryValuationTests(ApiPostgresFixture fixture)
{
    private async Task<TestClient> SignInAsync(string user)
    {
        var client = new TestClient(new XOptiApiFactory(fixture));
        await client.FetchCsrfTokenAsync();
        Assert.Equal(HttpStatusCode.OK, (await client.SignInAsync(user, SeedData.Password)).Status);
        return client;
    }

    [Fact]
    public async Task Valuation_OmitsCostsWithoutCostView()
    {
        var sku = "4" + Guid.NewGuid().ToString("N")[..8];
        await using (var context = fixture.NewContext())
        {
            await context.Database.ExecuteSqlInterpolatedAsync($"""
                INSERT INTO public.inventory (sku, department_code, class_code, category_code,
                    supplier_code, brand_code, name, qty_total_on_hand, average_cost,
                    inventory_lot_flag, retail_price_flag, whole_sale_price_flag)
                VALUES ({sku}, '01', '01', '01', '0001', '0001', 'Valuation Probe', 4, 7.7142, true, false, false);

                INSERT INTO public.invt_lot_record (sku, lot_no, date_received, supplier_code,
                    qty_purchased, qty_used, qty_on_hand, unit_amount_purchased, total_amount_purchased)
                VALUES ({sku}, 'VAL-LOT', '2026-11-01', '0001', 4, 0, 4, 4.3650, 17.4600);
                """);
        }

        using var manager = await SignInAsync("manager");
        var visible = await manager.GetAsync($"/api/v1/inventory/{sku}/valuation");
        Assert.Equal(HttpStatusCode.OK, visible.StatusCode);
        using var visibleBody = JsonDocument.Parse(await visible.Content.ReadAsStringAsync());
        Assert.Equal(4, visibleBody.RootElement.GetProperty("qtyOnHand").GetInt32());
        Assert.Equal(7.7142m, visibleBody.RootElement.GetProperty("averageCost").GetProperty("amount").GetDecimal());
        Assert.Equal(17.46m, visibleBody.RootElement.GetProperty("extendedCost").GetProperty("amount").GetDecimal());
        Assert.Equal(4.3650m, Assert.Single(
            visibleBody.RootElement.GetProperty("lots").EnumerateArray()).GetProperty("unitCost").GetProperty("amount").GetDecimal());

        using var purchasing = await SignInAsync("purchasing");
        var hidden = await purchasing.GetAsync($"/api/v1/inventory/{sku}/valuation");
        Assert.Equal(HttpStatusCode.OK, hidden.StatusCode);
        using var hiddenBody = JsonDocument.Parse(await hidden.Content.ReadAsStringAsync());
        Assert.Equal(4, hiddenBody.RootElement.GetProperty("qtyOnHand").GetInt32());
        Assert.False(hiddenBody.RootElement.TryGetProperty("averageCost", out _));
        Assert.False(hiddenBody.RootElement.TryGetProperty("extendedCost", out _));
        Assert.False(Assert.Single(hiddenBody.RootElement.GetProperty("lots").EnumerateArray())
            .TryGetProperty("unitCost", out _));
    }
}
