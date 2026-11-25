using System.Net;
using System.Text;
using Microsoft.EntityFrameworkCore;
using xOpti.Api.IntegrationTests.Support;

namespace xOpti.Api.IntegrationTests;

[Collection("api")]
public sealed class ClaimReceiptReportTests(ApiPostgresFixture fixture)
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
        var number = Random.Shared.Next(400000, 499999);
        var tx = $"RC{number:D8}";
        var customerId = Random.Shared.Next(700000, 799999);
        await using var seed = fixture.NewContext();
        await seed.Database.ExecuteSqlInterpolatedAsync($"""
            INSERT INTO public.department (department_code, department_name)
            VALUES ('CT', 'Test Claim Dept') ON CONFLICT (department_code) DO NOTHING;
            INSERT INTO public.class (department, class_code, class_name)
            VALUES ('CT', 'C1', 'Frame') ON CONFLICT (department, class_code) DO NOTHING;
            INSERT INTO public.category
                (department_code, class_code, category_code, category_name,
                 costing_method, inventory_method, tax_method)
            VALUES ('CT', 'C1', 'C1', 'Test Claim Category', '1', '1', '1')
            ON CONFLICT (department_code, class_code, category_code) DO NOTHING;
            INSERT INTO public.brand (brand_code, brand_description)
            VALUES ('CT1', 'Test Claim Brand') ON CONFLICT (brand_code) DO NOTHING;
            INSERT INTO public.inventory
                (department_code, class_code, category_code, supplier_code, brand_code,
                 sku, name, model, color, size)
            VALUES ('CT', 'C1', 'C1', 'S001', 'CT1', 'BCCLAIM001', 'Test Frame',
                    'MODEL-1', 'BLACK', '52')
            ON CONFLICT (sku) DO NOTHING;
            INSERT INTO public.customer (id, first_name, last_name, full_name)
            VALUES ({customerId}, 'Steven', 'Lee', 'Lee Steven')
            ON CONFLICT (id) DO NOTHING;
            INSERT INTO public.tx_header (control_number, tx_type, tx_number, date_of_entry,
                customer_id, status, total_sale, total_amount, total_qty)
            VALUES ('00009999', 'RC', {tx}, '2000-01-01', {customerId}, '0',
                228.0000, 110.0000, 1);
            INSERT INTO public.tx_details (control_number, tx_type, tx_number, date_of_entry,
                row_no, sku, qty, unit_amount, unit_cost, amount, tax_code)
            VALUES ('00009999', 'RC', {tx}, '2000-01-01', 1, 'BCCLAIM001',
                1, 228.0000, 100.0000, 110.0000, 'B');
            INSERT INTO public.tx_sale_person (tx_number, sales_row_no, staff_code)
            VALUES ({tx}, 1, '115');
            """);
        return tx;
    }

    [Fact]
    public async Task Print_ReturnsPdfWithLegacyClaimTotals()
    {
        var tx = await SeedAsync();
        using var manager = await SignInAsync();

        var response = await manager.PostAsync("/api/v1/special-reports/claim-receipt/print", new
        {
            orderInvoiceNumber = tx[2..], // bare number is zero-padded like the legacy InputBox
            reason = "report test",
        });

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        Assert.Equal("application/pdf", response.Content.Headers.ContentType?.MediaType);
        Assert.Contains($"{tx}-claims-receipt.pdf",
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
            $"/api/v1/special-reports/claim-receipt/preview?orderInvoiceNumber=RC{tx[2..].TrimStart('0')}");

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        Assert.Equal("application/pdf", response.Content.Headers.ContentType?.MediaType);
        var disposition = response.Content.Headers.ContentDisposition;
        Assert.NotNull(disposition);
        Assert.Equal("inline", disposition.DispositionType);
        Assert.Contains($"{tx}-claims-receipt.pdf", disposition.ToString());
    }

    [Fact]
    public async Task Print_UnknownOrderNumber_ReturnsDomainError()
    {
        using var manager = await SignInAsync();

        var response = await manager.PostAsync("/api/v1/special-reports/claim-receipt/print", new
        {
            orderInvoiceNumber = "RC99999999",
            reason = "report test",
        });

        Assert.Equal(HttpStatusCode.UnprocessableEntity, response.StatusCode);
        var body = await response.Content.ReadAsStringAsync();
        Assert.Contains("No claim receipt found", body);
    }
}
