using System.Net;
using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using xOpti.Api.IntegrationTests.Support;

namespace xOpti.Api.IntegrationTests;

[Collection("api")]
public sealed class StockDocumentReprintTests(ApiPostgresFixture fixture)
{
    private async Task<TestClient> ManagerAsync()
    {
        var client = new TestClient(new XOptiApiFactory(fixture));
        await client.FetchCsrfTokenAsync();
        Assert.Equal(HttpStatusCode.OK, (await client.SignInAsync("manager", SeedData.Password)).Status);
        return client;
    }

    [Fact]
    public async Task AdjustmentAndTransferReprints_AreIdenticalAndAudited()
    {
        var sku = "30110359";
        await using (var seed = fixture.NewContext())
        {
            await seed.Database.ExecuteSqlRawAsync("""
                INSERT INTO public.preference (serial_number, number_of_user, platform, product_name,
                    user_name, owner_name, branch_number, pst_number, gst_number,
                    next_invt_control_number, next_invt_sku, next_invoice_number, next_sales_order_number)
                VALUES ('0000000001', 1, 'xOpti', 'Synergy', 'Operator', 'Owner', '0001', '', '', 500, 1, 1, 1)
                ON CONFLICT (serial_number) DO NOTHING;
                """);
            await seed.Database.ExecuteSqlInterpolatedAsync($"""
                INSERT INTO public.branch_inventory (branch_code, sku, qty_on_hand)
                VALUES ('01', {sku}, 10), ('02', {sku}, 5)
                ON CONFLICT (branch_code, sku) DO UPDATE SET qty_on_hand = EXCLUDED.qty_on_hand;
                """);
        }

        using var manager = await ManagerAsync();
        var adjustment = await manager.PostAsync("/api/v1/inventory/adjustments", new
        {
            sku, branchCode = "01", quantityDelta = 2,
            reasonCode = "FOUND", reason = "found stock", allowNegative = false,
        }, idempotencyKey: "reprint-adj-" + Guid.NewGuid().ToString("N"));
        Assert.Equal(HttpStatusCode.Created, adjustment.StatusCode);
        using var adjustmentBody = JsonDocument.Parse(await adjustment.Content.ReadAsStringAsync());
        var txNumber = adjustmentBody.RootElement.GetProperty("txNumber").GetString()!;

        var first = await manager.GetAsync($"/api/v1/inventory/documents/{txNumber}");
        var second = await manager.GetAsync($"/api/v1/inventory/documents/{txNumber}");
        Assert.Equal(HttpStatusCode.OK, first.StatusCode);
        Assert.Equal(HttpStatusCode.OK, second.StatusCode);
        Assert.Equal(await first.Content.ReadAsStringAsync(), await second.Content.ReadAsStringAsync());

        using var document = JsonDocument.Parse(await first.Content.ReadAsStringAsync());
        Assert.True(document.RootElement.GetProperty("reprint").GetBoolean());
        Assert.Equal(txNumber, document.RootElement.GetProperty("txNumber").GetString());
        var line = Assert.Single(document.RootElement.GetProperty("lines").EnumerateArray());
        Assert.Equal(2, line.GetProperty("qty").GetInt32());

        await using (var context = fixture.NewContext())
        {
            Assert.True(await context.AuditLogs.CountAsync(row =>
                row.EntityId == txNumber && row.Action == "document.reprint") >= 2);
        }
    }
}
