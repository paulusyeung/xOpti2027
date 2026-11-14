using System.Net;
using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using xOpti.Api.IntegrationTests.Support;

namespace xOpti.Api.IntegrationTests;

[Collection("api")]
public sealed class RejectStockTests(ApiPostgresFixture fixture)
{
    private async Task<TestClient> ManagerAsync()
    {
        var client = new TestClient(new XOptiApiFactory(fixture));
        await client.FetchCsrfTokenAsync();
        Assert.Equal(HttpStatusCode.OK, (await client.SignInAsync("manager", SeedData.Password)).Status);
        return client;
    }

    [Fact]
    public async Task Rejection_GuardsAvailableQuantity_AndReferencesTheReceipt()
    {
        await using (var context = fixture.NewContext())
        {
            await context.Database.ExecuteSqlRawAsync("""
                INSERT INTO public.supplier (supplier_code, supplier_name)
                VALUES ('0001', 'Reject Supplier') ON CONFLICT (supplier_code) DO NOTHING;
                INSERT INTO public.preference (serial_number, number_of_user, platform, product_name,
                    user_name, owner_name, branch_number, pst_number, gst_number,
                    next_invt_control_number, next_invt_sku, next_invoice_number, next_sales_order_number)
                VALUES ('0000000001', 1, 'xOpti', 'Synergy', 'Operator', 'Owner', '0001', '', '', 200, 1, 1, 1)
                ON CONFLICT (serial_number) DO NOTHING;
                """);
        }

        using var manager = await ManagerAsync();
        var sku = "30110359";
        var lotNo = "RJT" + Guid.NewGuid().ToString("N")[..6];

        var receipt = await manager.PostAsync("/api/v1/purchasing/receipts", new
        {
            supplierCode = "0001", branchCode = "01", reason = "receipt for rejection",
            lines = new[] { new { sku, lotNo, quantity = 5, unitCost = 4.3650m,
                gstAmount = 0m, pstAmount = 0m, taxCode = "N" } },
        }, idempotencyKey: "sr-rj-" + Guid.NewGuid().ToString("N"));
        Assert.Equal(HttpStatusCode.Created, receipt.StatusCode);
        using var receiptBody = JsonDocument.Parse(await receipt.Content.ReadAsStringAsync());
        var original = receiptBody.RootElement.GetProperty("txNumber").GetString()!;

        int before;
        await using (var context = fixture.NewContext())
        {
            before = (await context.InventoryItems.SingleAsync(row => row.Sku == sku)).QtyTotalOnHand;
        }

        var over = await manager.PostAsync("/api/v1/purchasing/rejections", new
        {
            supplierCode = "0001", branchCode = "01", originalTxNumber = original,
            reason = "over return",
            lines = new[] { new { sku, lotNo, quantity = 6, unitCost = 4.3650m,
                gstAmount = 0m, pstAmount = 0m, taxCode = "N" } },
        }, idempotencyKey: "rj-over-" + Guid.NewGuid().ToString("N"));
        Assert.Equal(HttpStatusCode.BadRequest, over.StatusCode);
        Assert.Contains("5 unit(s) available", await over.Content.ReadAsStringAsync());

        var rejection = await manager.PostAsync("/api/v1/purchasing/rejections", new
        {
            supplierCode = "0001", branchCode = "01", originalTxNumber = original,
            reason = "damaged stock",
            lines = new[] { new { sku, lotNo, quantity = 2, unitCost = 4.3650m,
                gstAmount = 0m, pstAmount = 0m, taxCode = "N" } },
        }, idempotencyKey: "rj-" + Guid.NewGuid().ToString("N"));
        Assert.Equal(HttpStatusCode.Created, rejection.StatusCode);
        using var rejectionBody = JsonDocument.Parse(await rejection.Content.ReadAsStringAsync());
        var rjNumber = rejectionBody.RootElement.GetProperty("txNumber").GetString()!;
        Assert.StartsWith("RJ", rjNumber);
        Assert.Equal(original, rejectionBody.RootElement.GetProperty("originalTxNumber").GetString());

        await using (var context = fixture.NewContext())
        {
            var inventory = await context.InventoryItems.SingleAsync(row => row.Sku == sku);
            Assert.Equal(before - 2, inventory.QtyTotalOnHand);
            var header = await context.TxHeaders.SingleAsync(row => row.TxNumber == rjNumber);
            Assert.Equal(original, header.RefNumber);
            Assert.Equal(-2, header.TotalQty);
            Assert.Equal(3, (await context.LotRecords.SingleAsync(row => row.Sku == sku && row.LotNo == lotNo)).QtyOnHand);
        }
    }
}
