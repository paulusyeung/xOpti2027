using System.Net;
using System.Text;
using Microsoft.EntityFrameworkCore;
using xOpti.Api.IntegrationTests.Support;

namespace xOpti.Api.IntegrationTests;

[Collection("api")]
public sealed class InvoiceReportTests(ApiPostgresFixture fixture)
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
        var number = Random.Shared.Next(500000, 599999);
        var tx = $"RC{number:D8}";
        var customerId = Random.Shared.Next(600000, 699999);
        await using var seed = fixture.NewContext();
        await seed.Database.ExecuteSqlInterpolatedAsync($"""
            INSERT INTO public.customer (id, full_name, home_phone)
            VALUES ({customerId}, 'Invoice Customer', '1234567')
            ON CONFLICT (id) DO NOTHING;
            INSERT INTO public.tx_header (control_number, tx_type, tx_number, date_of_entry,
                customer_id, second_date, ref_number, status, total_sale, tax_a, tax_b,
                gross_sale, total_amount, total_qty, this_paid, previous_paid, change)
            VALUES ('00009998', 'RC', {tx}, '2001-05-19', {customerId}, '2001-05-13',
                'SA122480', '0', 55.0000, 0, 0, 55.0000, 55.0000, 1, 55.0000, 0, 0);
            INSERT INTO public.tx_details (control_number, tx_type, tx_number, date_of_entry,
                row_no, sku, qty, unit_amount, mark_down_amount, amount, tax_code)
            VALUES ('00009998', 'RC', {tx}, '2001-05-19', 1, 'INVTEST001',
                2, 35.0000, 7.5000, 55.0000, 'N');
            """);
        return tx;
    }

    [Fact]
    public async Task Print_ReturnsInvoicePdf()
    {
        var tx = await SeedAsync();
        using var manager = await SignInAsync();

        var response = await manager.PostAsync("/api/v1/special-reports/invoice/print", new
        {
            invoiceNumber = tx[2..],
            reason = "report test",
        });

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        Assert.Equal("application/pdf", response.Content.Headers.ContentType?.MediaType);
        Assert.Contains($"{tx}-invoice.pdf",
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
            $"/api/v1/special-reports/invoice/preview?invoiceNumber=RC{tx[2..].TrimStart('0')}");

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        var disposition = response.Content.Headers.ContentDisposition;
        Assert.NotNull(disposition);
        Assert.Equal("inline", disposition.DispositionType);
        Assert.Contains($"{tx}-invoice.pdf", disposition.ToString());
    }

    [Fact]
    public async Task Print_UnknownInvoice_ReturnsDomainError()
    {
        using var manager = await SignInAsync();

        var response = await manager.PostAsync("/api/v1/special-reports/invoice/print", new
        {
            invoiceNumber = "RC99999999",
            reason = "report test",
        });

        Assert.Equal(HttpStatusCode.UnprocessableEntity, response.StatusCode);
        Assert.Contains("No invoice found", await response.Content.ReadAsStringAsync());
    }
}
