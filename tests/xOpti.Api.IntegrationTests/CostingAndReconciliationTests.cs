using System.Net;
using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using xOpti.Api.IntegrationTests.Support;

namespace xOpti.Api.IntegrationTests;

[Collection("api")]
public sealed class CostingAndReconciliationTests(ApiPostgresFixture fixture)
{
    private async Task<TestClient> ManagerAsync()
    {
        var client = new TestClient(new XOptiApiFactory(fixture));
        await client.FetchCsrfTokenAsync();
        Assert.Equal(HttpStatusCode.OK, (await client.SignInAsync("manager", SeedData.Password)).Status);
        return client;
    }

    [Fact]
    public async Task LIFO_FIFO_Deficits_MethodValidation_AndReconciliationDrift()
    {
        var suffix = Guid.NewGuid().ToString("N")[..4].ToUpperInvariant();
        var lifo = "L" + suffix + "1";
        var fifo = "L" + suffix + "2";
        var deficit = "L" + suffix + "3";
        var invalid = "L" + suffix + "4";
        var drift = "L" + suffix + "5";

        await using (var seed = fixture.NewContext())
        {
            await seed.Database.ExecuteSqlRawAsync("""
                INSERT INTO public.supplier (supplier_code, supplier_name)
                VALUES ('0001', 'Cost Supplier') ON CONFLICT (supplier_code) DO NOTHING;
                INSERT INTO public.preference (serial_number, number_of_user, platform, product_name,
                    user_name, owner_name, branch_number, pst_number, gst_number,
                    next_invt_control_number, next_invt_sku, next_invoice_number, next_sales_order_number)
                VALUES ('0000000001', 1, 'xOpti', 'Synergy', 'Operator', 'Owner', '0001', '', '', 700, 1, 1, 1)
                ON CONFLICT (serial_number) DO NOTHING;
                """);

            await seed.Database.ExecuteSqlInterpolatedAsync($"""
                INSERT INTO public.category (department_code, class_code, category_code, category_name,
                    costing_method, inventory_method, tax_method) VALUES
                    ('11','11','11','FIFO','1','1','1'),
                    ('12','12','12','LIFO','2','2','2'),
                    ('19','19','19','Unsupported','9','9','9')
                ON CONFLICT (department_code, class_code, category_code) DO NOTHING;
                """);

            async Task SeedSku(string sku, string dept, int qty, params (string lot, int qty, decimal cost, DateTime date)[] lots)
            {
                await seed.Database.ExecuteSqlInterpolatedAsync($"""
                    INSERT INTO public.inventory (sku, department_code, class_code, category_code,
                        supplier_code, brand_code, name, qty_total_on_hand, average_cost,
                        inventory_lot_flag, retail_price_flag, whole_sale_price_flag)
                    VALUES ({sku}, {dept}, {dept}, {dept}, '0001', '0001', {sku}, {qty}, 4.3650, true, false, false);
                    INSERT INTO public.branch_inventory (branch_code, sku, qty_on_hand)
                    VALUES ('01', {sku}, {qty});
                    """);
                foreach (var (lot, lotQty, cost, date) in lots)
                {
                    await seed.Database.ExecuteSqlInterpolatedAsync($"""
                        INSERT INTO public.invt_lot_record (sku, lot_no, date_received, supplier_code,
                            qty_purchased, qty_used, qty_on_hand, unit_amount_purchased, total_amount_purchased)
                        VALUES ({sku}, {lot}, {date}, '0001', {lotQty}, 0, {lotQty}, {cost}, {cost * lotQty});
                        """);
                }
            }

            await SeedSku(lifo, "12", 26, ("OLDL", 24, 4.3650m, new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc)), ("NEWL", 2, 2.9400m, new DateTime(2026, 2, 1, 0, 0, 0, DateTimeKind.Utc)));
            await SeedSku(fifo, "11", 26, ("OLDF", 24, 4.3650m, new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc)), ("NEWF", 2, 4.2800m, new DateTime(2026, 2, 1, 0, 0, 0, DateTimeKind.Utc)));
            await SeedSku(deficit, "11", 72, ("DEFSRC", 72, 4.3650m, new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc)));
            await SeedSku(invalid, "19", 5, ("INVLD", 5, 1.0000m, new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc)));
            await SeedSku(drift, "11", 10, ("DRIFT", 18, 2.0000m, new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc)));
        }

        using var manager = await ManagerAsync();
        async Task<JsonElement> Issue(string sku, int quantity, string key)
        {
            var response = await manager.PostAsync("/api/v1/inventory/issues", new
            {
                sku, branchCode = "01", quantity, reason = "costing test",
            }, idempotencyKey: key);
            Assert.Equal(HttpStatusCode.Created, response.StatusCode);
            using var document = JsonDocument.Parse(await response.Content.ReadAsStringAsync());
            return document.RootElement.Clone();
        }

        var lifoResult = await Issue(lifo, 2, "lifo-" + suffix);
        Assert.Equal("Lifo", lifoResult.GetProperty("method").GetString());
        Assert.Equal(5.88m, lifoResult.GetProperty("totalCost").GetDecimal());
        Assert.Equal("NEWL", Assert.Single(lifoResult.GetProperty("consumptions").EnumerateArray())
            .GetProperty("lotNo").GetString());

        var fifoResult = await Issue(fifo, 26, "fifo-" + suffix);
        Assert.Equal("Fifo", fifoResult.GetProperty("method").GetString());
        Assert.Equal(113.32m, fifoResult.GetProperty("totalCost").GetDecimal());

        var deficitResult = await Issue(deficit, 80, "def-" + suffix);
        Assert.Equal(8, deficitResult.GetProperty("deficitQuantity").GetInt32());
        var deficitLot = deficitResult.GetProperty("deficitLotNo").GetString()!;
        var receipt = await manager.PostAsync("/api/v1/purchasing/receipts", new
        {
            supplierCode = "0001", branchCode = "01", reason = "reconcile deficit",
            lines = new[] { new { sku = deficit, lotNo = deficitLot, quantity = 8, unitCost = 4.3650m,
                gstAmount = 0m, pstAmount = 0m, taxCode = "N" } },
        }, idempotencyKey: "def-rec-" + suffix);
        Assert.Equal(HttpStatusCode.Created, receipt.StatusCode);

        await using (var context = fixture.NewContext())
        {
            Assert.Equal(0, (await context.LotRecords.SingleAsync(row =>
                row.Sku == deficit && row.LotNo == deficitLot)).QtyOnHand);
        }

        var unsupported = await manager.PostAsync("/api/v1/inventory/issues", new
        {
            sku = invalid, branchCode = "01", quantity = 1, reason = "bad method",
        }, idempotencyKey: "bad-" + suffix);
        Assert.Equal(HttpStatusCode.BadRequest, unsupported.StatusCode);
        Assert.Contains("not supported", await unsupported.Content.ReadAsStringAsync());

        var reconciliation = await manager.GetAsync("/api/v1/inventory/reconciliation");
        Assert.Equal(HttpStatusCode.OK, reconciliation.StatusCode);
        using var driftBody = JsonDocument.Parse(await reconciliation.Content.ReadAsStringAsync());
        var row = driftBody.RootElement.GetProperty("drifts").EnumerateArray()
            .Single(item => item.GetProperty("sku").GetString() == drift);
        Assert.Equal(-8, row.GetProperty("difference").GetInt32());
        Assert.Contains("DRIFT", row.GetProperty("affectedLots").EnumerateArray().Select(lot => lot.GetString()));

        await using (var verify = fixture.NewContext())
        {
            Assert.Equal(10, (await verify.InventoryItems.SingleAsync(item => item.Sku == drift)).QtyTotalOnHand);
        }
    }
}
