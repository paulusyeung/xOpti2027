using System.Net;
using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using xOpti.Api.IntegrationTests.Support;

namespace xOpti.Api.IntegrationTests;

[Collection("api")]
public sealed class SupplierDocumentTests(ApiPostgresFixture fixture)
{
    private async Task<TestClient> ManagerAsync()
    {
        var client = new TestClient(new XOptiApiFactory(fixture));
        await client.FetchCsrfTokenAsync();
        Assert.Equal(HttpStatusCode.OK, (await client.SignInAsync("manager", SeedData.Password)).Status);
        return client;
    }

    [Fact]
    public async Task SupplierDocuments_ActivityAndSummaryMismatch()
    {
        await using (var seed = fixture.NewContext())
        {
            await seed.Database.ExecuteSqlRawAsync("""
                INSERT INTO public.supplier (supplier_code, supplier_name)
                VALUES ('0001', 'Doc Supplier') ON CONFLICT (supplier_code) DO NOTHING;
                INSERT INTO public.preference (serial_number, number_of_user, platform, product_name,
                    user_name, owner_name, branch_number, pst_number, gst_number,
                    next_invt_control_number, next_invt_sku, next_invoice_number, next_sales_order_number)
                VALUES ('0000000001', 1, 'xOpti', 'Synergy', 'Operator', 'Owner', '0001', '', '', 800, 1, 1, 1)
                ON CONFLICT (serial_number) DO NOTHING;
                DELETE FROM public.supplier_summary WHERE supplier_code = '0001';
                INSERT INTO public.supplier_summary (supplier_code, year, month, first_date_of_month,
                    qty_purchased, amt_purchased, qty_rejected, amt_rejected)
                VALUES ('0001', 2026, 11, '2026-11-01', 1, 999.0000, 0, 0);
                """);
            await seed.Database.ExecuteSqlInterpolatedAsync($"""
                INSERT INTO public.branch_inventory (branch_code, sku, qty_on_hand)
                VALUES ('01', '30110359', 10)
                ON CONFLICT (branch_code, sku) DO UPDATE SET qty_on_hand = 10;
                """);
        }

        using var manager = await ManagerAsync();
        var sku = "30110359";
        var lot = "DOC" + Guid.NewGuid().ToString("N")[..6];
        var sr = await manager.PostAsync("/api/v1/purchasing/receipts", new
        {
            supplierCode = "0001", branchCode = "01", reason = "doc test",
            lines = new[] { new { sku, lotNo = lot, quantity = 4, unitCost = 4.3650m,
                gstAmount = 0.20m, pstAmount = 0.30m, taxCode = "B" } },
        }, idempotencyKey: "doc-sr-" + Guid.NewGuid().ToString("N"));
        Assert.Equal(HttpStatusCode.Created, sr.StatusCode);
        using var srBody = JsonDocument.Parse(await sr.Content.ReadAsStringAsync());
        var srNumber = srBody.RootElement.GetProperty("txNumber").GetString()!;

        var document = await manager.GetAsync($"/api/v1/purchasing/documents/{srNumber}");
        Assert.Equal(HttpStatusCode.OK, document.StatusCode);
        using var documentBody = JsonDocument.Parse(await document.Content.ReadAsStringAsync());
        Assert.Equal("SR", documentBody.RootElement.GetProperty("txType").GetString());
        Assert.True(documentBody.RootElement.GetProperty("reprint").GetBoolean());
        var line = Assert.Single(documentBody.RootElement.GetProperty("lines").EnumerateArray());
        Assert.Equal(4, line.GetProperty("qty").GetInt32());

        var rj = await manager.PostAsync("/api/v1/purchasing/rejections", new
        {
            supplierCode = "0001", branchCode = "01", originalTxNumber = srNumber,
            reason = "return doc test",
            lines = new[] { new { sku, lotNo = lot, quantity = 1, unitCost = 4.3650m,
                gstAmount = 0.05m, pstAmount = 0.07m, taxCode = "B" } },
        }, idempotencyKey: "doc-rj-" + Guid.NewGuid().ToString("N"));
        Assert.Equal(HttpStatusCode.Created, rj.StatusCode);
        using var rjBody = JsonDocument.Parse(await rj.Content.ReadAsStringAsync());
        var rjNumber = rjBody.RootElement.GetProperty("txNumber").GetString()!;

        var rjDocument = await manager.GetAsync($"/api/v1/purchasing/documents/{rjNumber}");
        using var rjDocumentBody = JsonDocument.Parse(await rjDocument.Content.ReadAsStringAsync());
        Assert.Equal(-4.365m, rjDocumentBody.RootElement.GetProperty("totalCost").GetDecimal());
        Assert.Equal(-0.05m, rjDocumentBody.RootElement.GetProperty("taxA").GetDecimal());

        var activity = await manager.GetAsync(
            "/api/v1/purchasing/suppliers/0001/activity?from=2026-11-01&to=2026-11-30");
        Assert.Equal(HttpStatusCode.OK, activity.StatusCode);
        using var activityBody = JsonDocument.Parse(await activity.Content.ReadAsStringAsync());
        Assert.True(activityBody.RootElement.GetProperty("receiptCost").GetDecimal() >= 17.46m);
        Assert.True(activityBody.RootElement.GetProperty("returnCost").GetDecimal() >= 4.365m);
        Assert.Contains(srNumber,
            activityBody.RootElement.GetProperty("documentNumbers").EnumerateArray().Select(d => d.GetString()));
        Assert.Contains(activityBody.RootElement.GetProperty("mismatches").EnumerateArray(),
            mismatch => mismatch.GetString()!.Contains(srNumber));

        await using (var verify = fixture.NewContext())
        {
            Assert.Equal(999.0000m, (await verify.SupplierSummaries.SingleAsync(row =>
                row.SupplierCode == "0001" && row.Year == 2026 && row.Month == 11)).AmountPurchased);
            Assert.True(await verify.AuditLogs.CountAsync(row =>
                row.Action == "supplier-document.reprint" && row.EntityId == srNumber) >= 1);
        }
    }
}
