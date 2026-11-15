using System.Net;
using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using xOpti.Api.IntegrationTests.Support;

namespace xOpti.Api.IntegrationTests;

[Collection("api")]
public sealed class SalesDocumentTests(ApiPostgresFixture fixture)
{
    private async Task<TestClient> ManagerAsync()
    {
        var client = new TestClient(new XOptiApiFactory(fixture));
        await client.FetchCsrfTokenAsync();
        Assert.Equal(HttpStatusCode.OK, (await client.SignInAsync("manager", SeedData.Password)).Status);
        return client;
    }

    [Fact]
    public async Task SalesDocumentProjections_IncludeCustomerLinesPaymentsAndStatus()
    {
        var tx = "SA" + Guid.NewGuid().ToString("N")[..8];
        var customerId = Random.Shared.Next(800000, 899999);
        await using (var seed = fixture.NewContext())
        {
            await seed.Database.ExecuteSqlInterpolatedAsync($"""
                INSERT INTO public.customer (id, full_name) VALUES ({customerId}, 'Projection Customer');
                INSERT INTO public.tx_header (control_number, tx_type, tx_number, date_of_entry,
                    customer_id, status, total_sale, tax_a, tax_b, gross_sale, total_amount, total_qty)
                VALUES ('00008888', 'SA', {tx}, '2026-11-10', {customerId}, '0',
                    100.0000, 5.0000, 7.0000, 112.0000, 112.0000, 2);
                INSERT INTO public.tx_details (control_number, tx_type, tx_number, date_of_entry,
                    row_no, sku, qty, unit_amount, unit_cost, amount, tax_code)
                VALUES ('00008888', 'SA', {tx}, '2026-11-10', 1, '30110359', 2, 50.0000, 30.0000, 100.0000, 'B');
                INSERT INTO public.tx_payment (tx_number, payment_line_no, type, amount_tender,
                    eq_amount, total_this_pay)
                VALUES ({tx}, 1, 'C', 20.0000, 20.0000, 20.0000);
                """);
        }

        using var manager = await ManagerAsync();
        var response = await manager.GetAsync($"/api/v1/sales/documents/{tx}");
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        using var body = JsonDocument.Parse(await response.Content.ReadAsStringAsync());
        Assert.Equal("Order", body.RootElement.GetProperty("kind").GetString());
        Assert.Equal("Projection Customer", body.RootElement.GetProperty("customerName").GetString());
        Assert.Equal("Open", body.RootElement.GetProperty("statusLabel").GetString());
        Assert.Equal(20m, body.RootElement.GetProperty("paid").GetDecimal());
        Assert.Equal(92m, body.RootElement.GetProperty("balance").GetDecimal());
        Assert.Equal("30110359", Assert.Single(body.RootElement.GetProperty("lines").EnumerateArray())
            .GetProperty("sku").GetString());
        Assert.Equal("C", Assert.Single(body.RootElement.GetProperty("payments").EnumerateArray())
            .GetProperty("type").GetString());

        var list = await manager.GetAsync($"/api/v1/sales/documents?customerId={customerId}&status=0");
        using var listBody = JsonDocument.Parse(await list.Content.ReadAsStringAsync());
        Assert.Contains(listBody.RootElement.GetProperty("items").EnumerateArray(),
            item => item.GetProperty("txNumber").GetString() == tx);
    }
}
