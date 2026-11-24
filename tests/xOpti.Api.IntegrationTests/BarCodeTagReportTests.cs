using System.Net;
using System.Text;
using Microsoft.EntityFrameworkCore;
using xOpti.Api.IntegrationTests.Support;

namespace xOpti.Api.IntegrationTests;

[Collection("api")]
public sealed class BarCodeTagReportTests(ApiPostgresFixture fixture)
{
    private async Task<TestClient> SignInAsync(string user)
    {
        var client = new TestClient(new XOptiApiFactory(fixture));
        await client.FetchCsrfTokenAsync();
        var outcome = await client.SignInAsync(user, SeedData.Password);
        Assert.Equal(HttpStatusCode.OK, outcome.Status);
        return client;
    }

    private async Task SeedAsync()
    {
        await using var context = fixture.NewContext();
        await context.Database.ExecuteSqlRawAsync("""
            INSERT INTO public.brand (brand_code, brand_description)
            VALUES ('BT1', 'Test Brand') ON CONFLICT (brand_code) DO NOTHING;

            INSERT INTO public.class (department, class_code, class_name)
            VALUES ('BT', 'B1', 'Test Class')
            ON CONFLICT (department, class_code) DO NOTHING;

            INSERT INTO public.category
                (department_code, class_code, category_code, category_name,
                 costing_method, inventory_method, tax_method)
            VALUES ('BT', 'B1', 'B1', 'Test Category', '1', '1', '1')
            ON CONFLICT (department_code, class_code, category_code) DO NOTHING;

            INSERT INTO public.inventory
                (department_code, class_code, category_code, supplier_code, brand_code,
                 sku, name, model, color, size, average_cost, qty_total_on_hand)
            VALUES
                ('BT', 'B1', 'B1', 'S001', 'BT1', 'BCTAG001', 'Test Frame',
                 'MODEL-1', 'BLACK', '52', 10, 2)
            ON CONFLICT (sku) DO UPDATE SET model = excluded.model;

            INSERT INTO public.retail_price (sku, retail_price)
            VALUES ('BCTAG001', 199.50)
            ON CONFLICT (sku) DO UPDATE SET retail_price = excluded.retail_price;

            DELETE FROM public.bar_code_pool WHERE tx_number = 'SR00000002';
            INSERT INTO public.bar_code_pool (id, tx_number, date_of_entry, sku, qty)
            VALUES
                ((SELECT COALESCE(MAX(id), 0) + 1 FROM public.bar_code_pool),
                 'SR00000002', now(), 'BCTAG001', 1),
                ((SELECT COALESCE(MAX(id), 0) + 2 FROM public.bar_code_pool),
                 'SR00000002', now(), 'BCTAG001', 1);
            """);
    }

    [Fact]
    public async Task Print_ReturnsPdfWithOnePagePerLabel()
    {
        await SeedAsync();
        using var manager = await SignInAsync("manager");

        var response = await manager.PostAsync("/api/v1/special-reports/bar-code-tag/print", new
        {
            fromNumber = "2",
            toNumber = "2",
            duplicate = false,
            reason = "report test",
        });

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        Assert.Equal("application/pdf", response.Content.Headers.ContentType?.MediaType);
        Assert.Contains("SR00000002-SR00000002-barcode-tags.pdf",
            response.Content.Headers.ContentDisposition?.FileNameStar ?? string.Empty);

        var bytes = await response.Content.ReadAsByteArrayAsync();
        Assert.Equal("%PDF", Encoding.ASCII.GetString(bytes, 0, 4));
        Assert.True(bytes.Length > 1000, "PDF should contain two label pages");
    }
}
