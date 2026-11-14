using System.Net;
using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using xOpti.Api.IntegrationTests.Support;

namespace xOpti.Api.IntegrationTests;

[Collection("api")]
public sealed class CatalogueAdministrationTests(ApiPostgresFixture fixture)
{
    private async Task<TestClient> SignInAsync(string user)
    {
        var client = new TestClient(new XOptiApiFactory(fixture));
        await client.FetchCsrfTokenAsync();
        Assert.Equal(HttpStatusCode.OK, (await client.SignInAsync(user, SeedData.Password)).Status);
        return client;
    }

    private static async Task<JsonElement> BodyAsync(HttpResponseMessage response)
    {
        using var document = JsonDocument.Parse(await response.Content.ReadAsStringAsync());
        return document.RootElement.Clone();
    }

    [Fact]
    public async Task SkuLifecycle_PricesAndBarcode_AreValidatedAndAuditable()
    {
        using var manager = await SignInAsync("manager");
        var sku = "9" + Guid.NewGuid().ToString("N")[..8];

        await using (var seed = fixture.NewContext())
        {
            await seed.Database.ExecuteSqlRawAsync("""
                INSERT INTO public.category (department_code, class_code, category_code, category_name,
                    costing_method, inventory_method, tax_method)
                VALUES ('01', '01', '01', 'Default', '1', '1', '1')
                ON CONFLICT (department_code, class_code, category_code) DO NOTHING;
                INSERT INTO public.supplier (supplier_code, supplier_name)
                VALUES ('0001', 'Seed Supplier') ON CONFLICT (supplier_code) DO NOTHING;
                INSERT INTO public.brand (brand_code, brand_description)
                VALUES ('0001', 'Seed Brand') ON CONFLICT (brand_code) DO NOTHING;
                """);
        }


        var create = await manager.PostAsync("/api/v1/admin/skus", new
        {
            sku,
            name = "Integration Frame",
            departmentCode = "01",
            classCode = "01",
            categoryCode = "01",
            supplierCode = "0001",
            brandCode = "0001",
            lotTracked = true,
            retailPriceFlag = true,
            wholesalePriceFlag = false,
            reason = "create sku",
        });
        Assert.Equal(HttpStatusCode.Created, create.StatusCode);

        var duplicate = await manager.PostAsync("/api/v1/admin/skus", new
        {
            sku = " " + sku.ToLowerInvariant() + " ",
            name = "Duplicate",
            departmentCode = "01",
            classCode = "01",
            categoryCode = "01",
            supplierCode = "0001",
            brandCode = "0001",
            reason = "duplicate sku",
        });
        Assert.Equal(HttpStatusCode.BadRequest, duplicate.StatusCode);
        Assert.Contains(
            (await BodyAsync(duplicate)).GetProperty("errors").EnumerateArray()
                .Select(error => error.GetProperty("field").GetString()),
            field => field == "Sku");

        var update = await manager.PutAsync($"/api/v1/admin/skus/{sku}", new
        {
            name = "Renamed Frame",
            departmentCode = "01",
            classCode = "01",
            categoryCode = "01",
            supplierCode = "0001",
            brandCode = "0001",
            lotTracked = true,
            retailPriceFlag = true,
            wholesalePriceFlag = true,
            reason = "rename sku",
        });
        Assert.Equal(HttpStatusCode.OK, update.StatusCode);
        Assert.Equal("Renamed Frame", (await BodyAsync(update)).GetProperty("name").GetString());

        long transactionsBefore;
        await using (var context = fixture.NewContext())
        {
            transactionsBefore = await context.TxHeaders.LongCountAsync();
        }

        var price = await manager.PutAsync($"/api/v1/admin/skus/{sku}/prices", new
        {
            retailPrice = 115.5678m,
            leastSellingPrice = 99.9900m,
            gradeA = 88.1234m,
            reason = "price change",
        });
        Assert.Equal(HttpStatusCode.OK, price.StatusCode);
        var priceBody = await BodyAsync(price);
        Assert.Equal(115.5678m, priceBody.GetProperty("retailPrice").GetDecimal());
        Assert.Equal(88.1234m, priceBody.GetProperty("gradeA").GetDecimal());

        var invalid = await manager.PutAsync($"/api/v1/admin/skus/{sku}/prices", new
        {
            retailPrice = 1.23456m,
            reason = "too precise",
        });
        Assert.Equal(HttpStatusCode.BadRequest, invalid.StatusCode);

        await using (var context = fixture.NewContext())
        {
            Assert.Equal(transactionsBefore, await context.TxHeaders.LongCountAsync());
            Assert.True(await context.AuditLogs.AnyAsync(row =>
                row.EntityId == sku && row.Action == "sku.price-change"
                && row.Details!.Contains("115.5678")));
            await context.Database.ExecuteSqlInterpolatedAsync(
                $"UPDATE public.inventory SET qty_total_on_hand = 5 WHERE sku = {sku}");
        }

        var retireBlocked = await manager.PostAsync($"/api/v1/admin/skus/{sku}/retire", new
        {
            reason = "obsolete",
            confirmOnHand = false,
        });
        Assert.Equal(HttpStatusCode.BadRequest, retireBlocked.StatusCode);
        Assert.Contains(
            (await BodyAsync(retireBlocked)).GetProperty("errors").EnumerateArray()
                .Select(error => error.GetProperty("field").GetString()),
            field => field == "ConfirmOnHand");

        var barcode = await manager.PostAsync($"/api/v1/admin/skus/{sku}/barcode", new { reason = "tag" });
        Assert.Equal(HttpStatusCode.OK, barcode.StatusCode);
        var tag = await BodyAsync(barcode);
        Assert.Equal(sku, tag.GetProperty("barcode").GetString());
        Assert.False(tag.GetProperty("reprint").GetBoolean());

        var duplicateTag = await manager.PostAsync($"/api/v1/admin/skus/{sku}/barcode", new { reason = "tag again" });
        Assert.Equal(HttpStatusCode.BadRequest, duplicateTag.StatusCode);

        var reprint = await BodyAsync(await manager.GetAsync($"/api/v1/admin/skus/{sku}/barcode"));
        Assert.True(reprint.GetProperty("reprint").GetBoolean());
        Assert.Equal(tag.GetProperty("labelText").GetString(), reprint.GetProperty("labelText").GetString());

        var retire = await manager.PostAsync($"/api/v1/admin/skus/{sku}/retire", new
        {
            reason = "obsolete",
            confirmOnHand = true,
        });
        Assert.Equal(HttpStatusCode.OK, retire.StatusCode);

        var list = await manager.GetAsync($"/api/v1/admin/skus?search={sku}");
        using var listBody = JsonDocument.Parse(await list.Content.ReadAsStringAsync());
        Assert.Empty(listBody.RootElement.GetProperty("items").EnumerateArray());
    }

    [Fact]
    public async Task Catalogue_RequiresInventoryPermission()
    {
        using var clerk = await SignInAsync("clerk");

        Assert.Equal(HttpStatusCode.Forbidden,
            (await clerk.GetAsync("/api/v1/admin/skus")).StatusCode);
        Assert.Equal(HttpStatusCode.Forbidden,
            (await clerk.GetAsync("/api/v1/admin/skus/30110359/prices")).StatusCode);
    }
}
