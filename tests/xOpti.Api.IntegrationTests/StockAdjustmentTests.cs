using System.Net;
using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using xOpti.Api.IntegrationTests.Support;

namespace xOpti.Api.IntegrationTests;

[Collection("api")]
public sealed class StockAdjustmentTests(ApiPostgresFixture fixture)
{
    private async Task<TestClient> ManagerAsync()
    {
        var client = new TestClient(new XOptiApiFactory(fixture));
        await client.FetchCsrfTokenAsync();
        Assert.Equal(HttpStatusCode.OK, (await client.SignInAsync("manager", SeedData.Password)).Status);
        return client;
    }

    [Fact]
    public async Task Adjustments_PostBothDirections_AndBlockUnexpectedDeficits()
    {
        await using (var context = fixture.NewContext())
        {
            await context.Database.ExecuteSqlRawAsync("""
                INSERT INTO public.preference (serial_number, number_of_user, platform, product_name,
                    user_name, owner_name, branch_number, pst_number, gst_number,
                    next_invt_control_number, next_invt_sku, next_invoice_number, next_sales_order_number)
                VALUES ('0000000001', 1, 'xOpti', 'Synergy', 'Operator', 'Owner', '0001', '', '', 300, 1, 1, 1)
                ON CONFLICT (serial_number) DO NOTHING;
                """);
        }

        var sku = "30110359";
        await using (var seed = fixture.NewContext())
        {
            await seed.Database.ExecuteSqlInterpolatedAsync($"""
                INSERT INTO public.branch_inventory (branch_code, sku, qty_on_hand)
                VALUES ('01', {sku}, 10)
                ON CONFLICT (branch_code, sku) DO UPDATE SET qty_on_hand = 10;
                """);
        }

        const int before = 10; // seeded branch_inventory quantity above

        using var manager = await ManagerAsync();
        var positive = await manager.PostAsync("/api/v1/inventory/adjustments", new
        {
            sku, branchCode = "01", quantityDelta = 3,
            reasonCode = "FOUND", reason = "found stock", allowNegative = false,
        }, idempotencyKey: "adj-pos-" + Guid.NewGuid().ToString("N"));
        Assert.Equal(HttpStatusCode.Created, positive.StatusCode);
        using var positiveBody = JsonDocument.Parse(await positive.Content.ReadAsStringAsync());
        Assert.Equal(before + 3, positiveBody.RootElement.GetProperty("newOnHand").GetInt32());
        Assert.StartsWith("SJ", positiveBody.RootElement.GetProperty("txNumber").GetString());

        var blocked = await manager.PostAsync("/api/v1/inventory/adjustments", new
        {
            sku, branchCode = "01", quantityDelta = -(before + 10),
            reasonCode = "DAMAGE", reason = "too far", allowNegative = false,
        }, idempotencyKey: "adj-block-" + Guid.NewGuid().ToString("N"));
        Assert.Equal(HttpStatusCode.BadRequest, blocked.StatusCode);
        Assert.Contains("shortfall", await blocked.Content.ReadAsStringAsync());

        var negative = await manager.PostAsync("/api/v1/inventory/adjustments", new
        {
            sku, branchCode = "01", quantityDelta = -2,
            reasonCode = "DAMAGE", reason = "damaged stock", allowNegative = false,
        }, idempotencyKey: "adj-neg-" + Guid.NewGuid().ToString("N"));
        Assert.Equal(HttpStatusCode.Created, negative.StatusCode);

        await using (var context = fixture.NewContext())
        {
            Assert.Equal(before + 1,
                (await context.BranchInventory.SingleAsync(row =>
                    row.BranchCode == "01" && row.Sku == sku)).QtyOnHand);
            Assert.True(await context.AuditLogs.AnyAsync(row =>
                row.Action == "stock.adjust" && row.Details!.Contains("damaged stock")));
        }
    }
}
