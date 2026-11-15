using System.Net;
using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using xOpti.Api.IntegrationTests.Support;

namespace xOpti.Api.IntegrationTests;

[Collection("api")]
public sealed class InventoryConcurrencyTests(ApiPostgresFixture fixture)
{
    private async Task<TestClient> ManagerAsync()
    {
        var client = new TestClient(new XOptiApiFactory(fixture));
        await client.FetchCsrfTokenAsync();
        Assert.Equal(HttpStatusCode.OK, (await client.SignInAsync("manager", SeedData.Password)).Status);
        return client;
    }

    private static string BodyString(JsonElement element, string name) =>
        element.GetProperty(name).GetString()!;

    [Fact]
    public async Task ConcurrentPosting_HasNoLostUpdatesOrDuplicateNumbers()
    {
        var sku = "2" + Guid.NewGuid().ToString("N")[..8];
        await using (var seed = fixture.NewContext())
        {
            await seed.Database.ExecuteSqlRawAsync("""
                INSERT INTO public.supplier (supplier_code, supplier_name)
                VALUES ('0001', 'Concurrency Supplier') ON CONFLICT (supplier_code) DO NOTHING;
                INSERT INTO public.preference (serial_number, number_of_user, platform, product_name,
                    user_name, owner_name, branch_number, pst_number, gst_number,
                    next_invt_control_number, next_invt_sku, next_invoice_number, next_sales_order_number)
                VALUES ('0000000001', 1, 'xOpti', 'Synergy', 'Operator', 'Owner', '0001', '', '', 900, 1, 1, 1)
                ON CONFLICT (serial_number) DO UPDATE SET next_invt_control_number = 900;
                INSERT INTO public.category (department_code, class_code, category_code, category_name,
                    costing_method, inventory_method, tax_method) VALUES ('21','21','21','Conc','1','1','1')
                ON CONFLICT (department_code, class_code, category_code) DO NOTHING;
                """);
            await seed.Database.ExecuteSqlInterpolatedAsync($"""
                INSERT INTO public.inventory (sku, department_code, class_code, category_code,
                    supplier_code, brand_code, name, qty_total_on_hand, average_cost,
                    inventory_lot_flag, retail_price_flag, whole_sale_price_flag)
                VALUES ({sku}, '21', '21', '21', '0001', '0001', 'Concurrency', 100, 1.0000, true, false, false);
                INSERT INTO public.branch_inventory (branch_code, sku, qty_on_hand)
                VALUES ('01', {sku}, 100), ('02', {sku}, 0);
                INSERT INTO public.invt_lot_record (sku, lot_no, date_received, supplier_code,
                    qty_purchased, qty_used, qty_on_hand, unit_amount_purchased, total_amount_purchased)
                VALUES ({sku}, 'BASE', '2026-01-01', '0001', 100, 0, 100, 1.0000, 100.0000);
                """);
        }

        var factory = new XOptiApiFactory(fixture);
        using var manager = new TestClient(factory);
        await manager.FetchCsrfTokenAsync();
        await manager.SignInAsync("manager", SeedData.Password);
        var controlNumbers = new List<string>();
        var documentNumbers = new List<string>();

        var receipts = await Task.WhenAll(Enumerable.Range(0, 4).Select(async index =>
        {
            var response = await manager.PostAsync("/api/v1/purchasing/receipts", new
            {
                supplierCode = "0001", branchCode = "01", reason = "concurrent receipt",
                lines = new[] { new { sku, lotNo = $"CR{index}", quantity = 1, unitCost = 1.0m,
                    gstAmount = 0m, pstAmount = 0m, taxCode = "N" } },
            }, idempotencyKey: "cr-" + sku + index);
            if (response.StatusCode != HttpStatusCode.Created)
            {
                var exceptions = string.Join("\n", factory.Logs.Snapshot()
                    .Where(entry => entry.Exception is not null)
                    .Select(entry => entry.Exception!.ToString()));
                Assert.Fail($"{response.StatusCode}: {await response.Content.ReadAsStringAsync()}\n{exceptions}");
            }
            using var body = JsonDocument.Parse(await response.Content.ReadAsStringAsync());
            return body.RootElement.Clone();
        }));
        controlNumbers.AddRange(receipts.Select(row => BodyString(row, "controlNumber")));
        documentNumbers.AddRange(receipts.Select(row => BodyString(row, "txNumber")));

        var adjustments = await Task.WhenAll(Enumerable.Range(0, 4).Select(async index =>
        {
            var response = await manager.PostAsync("/api/v1/inventory/adjustments", new
            {
                sku, branchCode = "01", quantityDelta = 1, reasonCode = "FOUND",
                reason = "concurrent adjustment", allowNegative = false,
            }, idempotencyKey: "ca-" + sku + index);
            if (response.StatusCode != HttpStatusCode.Created)
            {
                var exceptions = string.Join("\n", factory.Logs.Snapshot()
                    .Where(entry => entry.Exception is not null)
                    .Select(entry => entry.Exception!.ToString()));
                Assert.Fail($"{response.StatusCode}: {await response.Content.ReadAsStringAsync()}\n{exceptions}");
            }
            using var body = JsonDocument.Parse(await response.Content.ReadAsStringAsync());
            return body.RootElement.Clone();
        }));
        controlNumbers.AddRange(adjustments.Select(row => BodyString(row, "controlNumber")));
        documentNumbers.AddRange(adjustments.Select(row => BodyString(row, "txNumber")));

        var issues = await Task.WhenAll(Enumerable.Range(0, 4).Select(async index =>
        {
            var response = await manager.PostAsync("/api/v1/inventory/issues", new
            {
                sku, branchCode = "01", quantity = 1, reason = "concurrent issue",
            }, idempotencyKey: "ci-" + sku + index);
            if (response.StatusCode != HttpStatusCode.Created)
            {
                var exceptions = string.Join("\n", factory.Logs.Snapshot()
                    .Where(entry => entry.Exception is not null)
                    .Select(entry => entry.Exception!.ToString()));
                Assert.Fail($"{response.StatusCode}: {await response.Content.ReadAsStringAsync()}\n{exceptions}");
            }
            using var body = JsonDocument.Parse(await response.Content.ReadAsStringAsync());
            return body.RootElement.Clone();
        }));
        documentNumbers.AddRange(issues.Select(row => BodyString(row, "txNumber")));

        var transfers = await Task.WhenAll(Enumerable.Range(0, 2).Select(async index =>
        {
            var response = await manager.PostAsync("/api/v1/inventory/transfers", new
            {
                sku, fromBranch = "01", toBranch = "02", quantity = 1, reason = "concurrent transfer",
            }, idempotencyKey: "ct-" + sku + index);
            if (response.StatusCode != HttpStatusCode.Created)
            {
                var exceptions = string.Join("\n", factory.Logs.Snapshot()
                    .Where(entry => entry.Exception is not null)
                    .Select(entry => entry.Exception!.ToString()));
                Assert.Fail($"{response.StatusCode}: {await response.Content.ReadAsStringAsync()}\n{exceptions}");
            }
            using var body = JsonDocument.Parse(await response.Content.ReadAsStringAsync());
            return body.RootElement.Clone();
        }));
        documentNumbers.AddRange(transfers.Select(row => BodyString(row, "sourceTxNumber")));
        documentNumbers.AddRange(transfers.Select(row => BodyString(row, "destinationTxNumber")));

        Assert.Equal(controlNumbers.Count, controlNumbers.Distinct().Count());
        Assert.Equal(documentNumbers.Count, documentNumbers.Distinct().Count());

        await using (var verify = fixture.NewContext())
        {
            Assert.Equal(104, (await verify.InventoryItems.SingleAsync(row => row.Sku == sku)).QtyTotalOnHand);
            Assert.Equal(102, (await verify.BranchInventory.SingleAsync(row => row.BranchCode == "01" && row.Sku == sku)).QtyOnHand);
            Assert.Equal(2, (await verify.BranchInventory.SingleAsync(row => row.BranchCode == "02" && row.Sku == sku)).QtyOnHand);
        }

        var reconciliation = await manager.GetAsync("/api/v1/inventory/reconciliation");
        using var drift = JsonDocument.Parse(await reconciliation.Content.ReadAsStringAsync());
        Assert.DoesNotContain(drift.RootElement.GetProperty("drifts").EnumerateArray(),
            row => row.GetProperty("sku").GetString() == sku);
        var lotCount = await fixture.NewContext().Database
            .SqlQuery<int>($"SELECT count(*)::int AS \"Value\" FROM public.invt_lot_record WHERE sku = {sku}")
            .SingleAsync();
        Assert.True(lotCount > 0);
    }
}
