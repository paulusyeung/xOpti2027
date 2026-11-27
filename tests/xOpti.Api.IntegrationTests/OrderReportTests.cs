using System.Net;
using System.Text;
using Microsoft.EntityFrameworkCore;
using xOpti.Api.IntegrationTests.Support;

namespace xOpti.Api.IntegrationTests;

[Collection("api")]
public sealed class OrderReportTests(ApiPostgresFixture fixture)
{
    private async Task<TestClient> SignInAsync()
    {
        var client = new TestClient(new XOptiApiFactory(fixture));
        await client.FetchCsrfTokenAsync();
        Assert.Equal(HttpStatusCode.OK,
            (await client.SignInAsync("manager", SeedData.Password)).Status);
        return client;
    }

    private async Task<string> SeedAsync()
    {
        var suffix = Random.Shared.Next(100000, 999999).ToString();
        var tx = "SA" + suffix;
        var customerId = Random.Shared.Next(500000, 599999);
        await using var seed = fixture.NewContext();
        await seed.Database.ExecuteSqlInterpolatedAsync($"""
            INSERT INTO public.customer (id, full_name, home_phone)
            VALUES ({customerId}, 'Order Customer', '1234567')
            ON CONFLICT (id) DO NOTHING;
            INSERT INTO public.tx_header (control_number, tx_type, tx_number, date_of_entry,
                customer_id, second_date, ref_number, status, total_sale, tax_a, tax_b,
                gross_sale, total_amount, total_qty, this_paid, previous_paid, change)
            VALUES ('00009997', 'SA', {tx}, '2022-09-03', {customerId}, '2022-09-03',
                'PO123', '0', 100.0000, 5.0000, 7.0000, 112.0000, 112.0000, 1,
                12.0000, 0, 0);
            INSERT INTO public.tx_details (control_number, tx_type, tx_number, date_of_entry,
                row_no, sku, qty, unit_amount, mark_down_amount, amount, tax_code)
            VALUES ('00009997', 'SA', {tx}, '2022-09-03', 1, 'ORDTEST001',
                1, 100.0000, 0, 100.0000, 'B');
            INSERT INTO public.tx_payment (tx_number, payment_line_no, type, amount_tender,
                eq_amount, total_this_pay)
            VALUES ({tx}, 1, '0', 12.0000, 12.0000, 12.0000);
            """);
        return tx;
    }

    [Fact]
    public async Task Print_ReturnsOrderPdf()
    {
        var tx = await SeedAsync();
        using var manager = await SignInAsync();

        var response = await manager.PostAsync("/api/v1/special-reports/order/print", new
        {
            orderNumber = tx[2..], // bare number is prefixed with SA like the legacy InputBox
            reason = "report test",
        });

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        Assert.Equal("application/pdf", response.Content.Headers.ContentType?.MediaType);
        Assert.Contains($"{tx}-order.pdf",
            response.Content.Headers.ContentDisposition?.FileNameStar ?? string.Empty);
        var bytes = await response.Content.ReadAsByteArrayAsync();
        Assert.Equal("%PDF", Encoding.ASCII.GetString(bytes, 0, 4));
    }

    [Fact]
    public async Task Preview_ReturnsPdfInlineWithDescriptiveFileName()
    {
        var tx = await SeedAsync();
        using var manager = await SignInAsync();

        var response = await manager.GetAsync(
            $"/api/v1/special-reports/order/preview?orderNumber={tx}");

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        var disposition = response.Content.Headers.ContentDisposition;
        Assert.NotNull(disposition);
        Assert.Equal("inline", disposition.DispositionType);
        Assert.Contains($"{tx}-order.pdf", disposition.ToString());
    }

    [Fact]
    public async Task Print_UnknownOrder_ReturnsDomainError()
    {
        using var manager = await SignInAsync();

        var response = await manager.PostAsync("/api/v1/special-reports/order/print", new
        {
            orderNumber = "SA99999999",
            reason = "report test",
        });

        Assert.Equal(HttpStatusCode.UnprocessableEntity, response.StatusCode);
        Assert.Contains("No order found", await response.Content.ReadAsStringAsync());
    }
}
