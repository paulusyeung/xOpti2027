using System.Net;
using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using xOpti.Api.IntegrationTests.Support;

namespace xOpti.Api.IntegrationTests;

[Collection("api")]
public sealed class AvailabilityAndMovementTests(ApiPostgresFixture fixture)
{
    private async Task<TestClient> SignInAsync(string user)
    {
        var client = new TestClient(new XOptiApiFactory(fixture));
        await client.FetchCsrfTokenAsync();
        Assert.Equal(HttpStatusCode.OK, (await client.SignInAsync(user, SeedData.Password)).Status);
        return client;
    }

    [Fact]
    public async Task AvailabilityAndMovements_ReflectMigratedRows_AndRequireInventoryPermission()
    {
        var sku = "5" + Guid.NewGuid().ToString("N")[..8];
        await using (var context = fixture.NewContext())
        {
            await context.Database.ExecuteSqlInterpolatedAsync($"""
                INSERT INTO public.inventory (sku, department_code, class_code, category_code,
                    supplier_code, brand_code, name, qty_total_on_hand,
                    inventory_lot_flag, retail_price_flag, whole_sale_price_flag)
                VALUES ({sku}, '01', '01', '01', '0001', '0001', 'Availability Probe', 8, true, false, false);

                INSERT INTO public.branch_inventory (branch_code, sku, qty_on_hand)
                VALUES ('01', {sku}, 5), ('02', {sku}, 3);

                INSERT INTO public.invt_lot_record (sku, lot_no, date_received, supplier_code,
                    qty_purchased, qty_used, qty_on_hand, unit_amount_purchased, total_amount_purchased)
                VALUES ({sku}, 'LOT-A', '2026-11-01', '0001', 10, 2, 8, 4.3650, 43.6500);
                """);

            await context.Database.ExecuteSqlInterpolatedAsync($"""
                INSERT INTO public.tx_header (control_number, tx_type, tx_number, date_of_entry)
                VALUES ('00000001', 'SR', 'SR00000001', '2026-11-01');
                INSERT INTO public.tx_details (control_number, tx_type, tx_number, date_of_entry,
                    row_no, sku, qty, unit_amount, unit_cost, amount, tax_code)
                VALUES ('00000001', 'SR', 'SR00000001', '2026-11-01', 1, {sku}, 10, 4.3650, 4.3650, 43.6500, 'N');
                """);
        }

        using var manager = await SignInAsync("manager");
        var availability = await manager.GetAsync($"/api/v1/inventory/{sku}/availability");
        Assert.Equal(HttpStatusCode.OK, availability.StatusCode);
        using var availabilityBody = JsonDocument.Parse(await availability.Content.ReadAsStringAsync());
        Assert.Equal(8, availabilityBody.RootElement.GetProperty("qtyTotalOnHand").GetInt32());
        Assert.Equal(2, availabilityBody.RootElement.GetProperty("branches").GetArrayLength());
        Assert.Equal("LOT-A", Assert.Single(
            availabilityBody.RootElement.GetProperty("lots").EnumerateArray())
            .GetProperty("lotNo").GetString());

        var movements = await manager.GetAsync($"/api/v1/inventory/{sku}/movements");
        Assert.Equal(HttpStatusCode.OK, movements.StatusCode);
        using var movementsBody = JsonDocument.Parse(await movements.Content.ReadAsStringAsync());
        var movement = Assert.Single(movementsBody.RootElement.GetProperty("items").EnumerateArray());
        Assert.Equal("SR", movement.GetProperty("txType").GetString());
        Assert.Equal(10, movement.GetProperty("qty").GetInt32());

        using var clerk = await SignInAsync("clerk");
        Assert.Equal(HttpStatusCode.Forbidden,
            (await clerk.GetAsync($"/api/v1/inventory/{sku}/availability")).StatusCode);
    }
}
