using System.Net;
using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using xOpti.Api.IntegrationTests.Support;

namespace xOpti.Api.IntegrationTests;

[Collection("api")]
public sealed class ReceiveStockTests(ApiPostgresFixture fixture)
{
    private async Task<TestClient> ManagerAsync()
    {
        var client = new TestClient(new XOptiApiFactory(fixture));
        await client.FetchCsrfTokenAsync();
        Assert.Equal(HttpStatusCode.OK, (await client.SignInAsync("manager", SeedData.Password)).Status);
        return client;
    }

    [Fact]
    public async Task Receipt_PostsOnce_PersistsLotAndInventory_AndIsIdempotent()
    {
        await using (var context = fixture.NewContext())
        {
            await context.Database.ExecuteSqlRawAsync("""
                INSERT INTO public.supplier (supplier_code, supplier_name)
                VALUES ('0001', 'Seed Supplier') ON CONFLICT (supplier_code) DO NOTHING;
                INSERT INTO public.preference (serial_number, number_of_user, platform, product_name,
                    user_name, owner_name, branch_number, pst_number, gst_number,
                    next_invt_control_number, next_invt_sku, next_invoice_number, next_sales_order_number)
                VALUES ('0000000001', 1, 'xOpti', 'Synergy', 'Operator', 'Owner', '0001', '', '', 100, 1, 1, 1)
                ON CONFLICT (serial_number) DO NOTHING;
                """);
        }

        var sku = "30110359";
        int before;
        await using (var context = fixture.NewContext())
        {
            before = (await context.InventoryItems.SingleAsync(row => row.Sku == sku)).QtyTotalOnHand;
        }

        var factory = new XOptiApiFactory(fixture);
        using var manager = new TestClient(factory);
        await manager.FetchCsrfTokenAsync();
        Assert.Equal(HttpStatusCode.OK, (await manager.SignInAsync("manager", SeedData.Password)).Status);
        var key = "sr-" + Guid.NewGuid().ToString("N");
        var body = new
        {
            supplierCode = "0001",
            branchCode = "01",
            reason = "receive stock",
            lines = new[]
            {
                new { sku, lotNo = "RT" + key[..8], quantity = 5, unitCost = 4.3650m,
                    gstAmount = 0.22m, pstAmount = 0.31m, taxCode = "B" },
            },
        };

        var first = await manager.PostAsync("/api/v1/purchasing/receipts", body, idempotencyKey: key);
        if (first.StatusCode != HttpStatusCode.Created)
        {
            var exceptions = string.Join("\n", factory.Logs.Snapshot()
                .Where(entry => entry.Exception is not null)
                .Select(entry => entry.Exception!.ToString()));
            Assert.Fail($"{first.StatusCode}: {await first.Content.ReadAsStringAsync()}\n{exceptions}");
        }
        using var firstBody = JsonDocument.Parse(await first.Content.ReadAsStringAsync());
        var txNumber = firstBody.RootElement.GetProperty("txNumber").GetString()!;
        Assert.StartsWith("SR", txNumber);
        Assert.Equal(21.825m, firstBody.RootElement.GetProperty("totalCost").GetDecimal());
        Assert.Equal(0.53m, firstBody.RootElement.GetProperty("totalTax").GetDecimal());

        var controlNumber = firstBody.RootElement.GetProperty("controlNumber").GetString()!;
        Assert.Equal(8, controlNumber.Length);

        var replay = await manager.PostAsync("/api/v1/purchasing/receipts", body, idempotencyKey: key);
        Assert.Equal(HttpStatusCode.Created, replay.StatusCode);
        using var replayBody = JsonDocument.Parse(await replay.Content.ReadAsStringAsync());
        Assert.Equal(txNumber, replayBody.RootElement.GetProperty("txNumber").GetString());

        await using (var context = fixture.NewContext())
        {
            var inventory = await context.InventoryItems.SingleAsync(row => row.Sku == sku);
            Assert.Equal(before + 5, inventory.QtyTotalOnHand); // replayed once, not twice
            Assert.True(await context.LotRecords.AnyAsync(row => row.Sku == sku && row.QtyPurchased >= 5));
            var header = await context.TxHeaders.SingleAsync(row => row.TxNumber == txNumber);
            Assert.Equal("21.8250", header.TotalCost.Amount.ToString("0.0000"));
            Assert.True(await context.AuditLogs.AnyAsync(row =>
                row.EntityId == txNumber && row.Action == "stock.receive"));
        }

        var invalid = await manager.PostAsync("/api/v1/purchasing/receipts", new
        {
            supplierCode = "0001", branchCode = "01", reason = "bad line",
            lines = new[] { new { sku, lotNo = "BAD", quantity = 0, unitCost = 1m,
                gstAmount = 0m, pstAmount = 0m, taxCode = "N" } },
        }, idempotencyKey: "sr-bad-" + Guid.NewGuid().ToString("N"));
        Assert.Equal(HttpStatusCode.BadRequest, invalid.StatusCode);
    }
}
