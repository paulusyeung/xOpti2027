using System.Net;
using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using xOpti.Api.IntegrationTests.Support;
using xOpti.Infrastructure.Persistence.Entities;

namespace xOpti.Api.IntegrationTests;

[Collection("api")]
public sealed class PosConcurrencyTests(ApiPostgresFixture fixture)
{
    private async Task<int> SeedAsync(string sku)
    {
        var customerId = Random.Shared.Next(300000, 399999);
        await using var seed = fixture.NewContext();
        await seed.Database.ExecuteSqlInterpolatedAsync($"""
            INSERT INTO public.customer (id, full_name) VALUES ({customerId}, 'Concurrent POS');
            INSERT INTO public.supplier (supplier_code, supplier_name)
            VALUES ('0001', 'POS Supplier') ON CONFLICT (supplier_code) DO NOTHING;
            INSERT INTO public.category (department_code, class_code, category_code, category_name,
                costing_method, inventory_method, tax_method) VALUES ('09','09','09','POS','1','1','B')
            ON CONFLICT (department_code, class_code, category_code) DO NOTHING;
            INSERT INTO public.brand (brand_code, brand_description)
            VALUES ('0001', 'POS Brand') ON CONFLICT (brand_code) DO NOTHING;
            INSERT INTO public.preference (serial_number, number_of_user, platform, product_name,
                user_name, owner_name, branch_number, pst_number, gst_number, tax_a_rate, tax_b_rate,
                next_invt_control_number, next_invt_sku, next_invoice_number, next_sales_order_number)
            VALUES ('0000000001', 1, 'xOpti', 'Synergy', 'Operator', 'Owner', '0001', '', '', 5, 7,
                2000, 1, 1, 1)
            ON CONFLICT (serial_number) DO UPDATE
            SET tax_a_rate = 5, tax_b_rate = 7, next_invt_control_number = 2000;
            DELETE FROM public.invt_lot_record WHERE sku = {sku};
            INSERT INTO public.inventory (sku, department_code, class_code, category_code,
                supplier_code, brand_code, name, qty_total_on_hand, average_cost,
                inventory_lot_flag, retail_price_flag, whole_sale_price_flag)
            VALUES ({sku}, '09', '09', '09', '0001', '0001', 'Concurrent POS Frame', 100, 30.0000,
                true, true, false);
            INSERT INTO public.branch_inventory (branch_code, sku, qty_on_hand)
            VALUES ('01', {sku}, 100), ('05', {sku}, 100)
            ON CONFLICT (branch_code, sku) DO UPDATE SET qty_on_hand = 100;
            """);
        seed.LotRecords.Add(new InvtLotRecord
        {
            Sku = sku, LotNo = "CONCLOT", DateReceived = DateTimeOffset.UtcNow,
            SupplierCode = "0001", QtyPurchased = 100, QtyUsed = 0, QtyOnHand = 100,
            UnitAmountPurchased = xOpti.Domain.Values.Money.From(30m),
            TotalAmountPurchased = xOpti.Domain.Values.Money.From(3000m),
        });
        seed.RetailPrices.Add(new RetailPrice { Sku = sku, RetailPriceValue = 50m });
        await seed.SaveChangesAsync();
        return customerId;
    }

    [Fact]
    public async Task ConcurrentTerminalSales_KeepInventoryAndCountersExact()
    {
        var sku = "9900" + Random.Shared.Next(100000, 999999);
        var customerId = await SeedAsync(sku);
        var factory = new XOptiApiFactory(fixture);
        using var manager = new TestClient(factory);
        await manager.FetchCsrfTokenAsync();
        await manager.SignInAsync("manager", SeedData.Password);

        var terminals = new[] { "11", "12" };
        var sessionIds = new List<long>();
        foreach (var terminal in terminals)
        {
            var opened = await manager.PostAsync("/api/v1/cash/sessions", new
            {
                branchCode = "05", terminalCode = terminal, openingFloat = 0m,
                reason = "concurrency drawer",
            });
            Assert.Equal(HttpStatusCode.Created, opened.StatusCode);
            using var body = JsonDocument.Parse(await opened.Content.ReadAsStringAsync());
            sessionIds.Add(body.RootElement.GetProperty("id").GetInt64());
        }

        var responses = await Task.WhenAll(Enumerable.Range(0, 8).Select(async index =>
        {
            var response = await manager.PostAsync("/api/v1/sales/invoices", new
            {
                customerId,
                staffCode = "0007",
                sessionId = sessionIds[index % sessionIds.Count],
                reason = "concurrent sale",
                lines = new[] { new { sku, quantity = 1, unitAmount = 50m, discountAmount = 0m,
                    taxCode = "B" } },
                tenders = new[] { new { method = "C", amount = 56m, reference = (string?)null } },
            }, idempotencyKey: $"pos-conc-{sku}-{index}");
            if (response.StatusCode != HttpStatusCode.Created)
            {
                var exceptions = string.Join("\n", factory.Logs.Snapshot()
                    .Where(entry => entry.Exception is not null)
                    .Select(entry => entry.Exception!.ToString()));
                Assert.Fail($"{response.StatusCode}: {await response.Content.ReadAsStringAsync()}\n{exceptions}");
            }
            using var document = JsonDocument.Parse(await response.Content.ReadAsStringAsync());
            return document.RootElement.Clone();
        }));

        var numbers = responses.Select(row => row.GetProperty("txNumber").GetString()!).ToList();
        var controls = responses.Select(row => row.GetProperty("controlNumber").GetString()!).ToList();
        Assert.Equal(8, numbers.Distinct().Count());
        Assert.Equal(8, controls.Distinct().Count());
        Assert.All(numbers, number => Assert.StartsWith("RC", number));

        await using (var verify = fixture.NewContext())
        {
            var inventory = await verify.InventoryItems.SingleAsync(row => row.Sku == sku);
            Assert.Equal(92, inventory.QtyTotalOnHand);
            Assert.True(inventory.QtyTotalOnHand >= 0);
            Assert.Equal(92, (await verify.LotRecords.SingleAsync(
                row => row.Sku == sku && row.LotNo == "CONCLOT")).QtyOnHand);
            Assert.Equal(92, (await verify.BranchInventory.SingleAsync(
                row => row.BranchCode == "05" && row.Sku == sku)).QtyOnHand);
            Assert.Equal(8, await verify.TxHeaders.CountAsync(row =>
                row.CustomerId == customerId && row.TxType == xOpti.Domain.Values.TransactionType.RetailInvoice));
            Assert.Equal(2, await verify.CashSessionTransactions
                .Where(row => sessionIds.Contains(row.SessionId))
                .Select(row => row.SessionId).Distinct().CountAsync());
        }

        foreach (var sessionId in sessionIds)
        {
            var detail = await manager.GetAsync($"/api/v1/cash/sessions/{sessionId}");
            using var body = JsonDocument.Parse(await detail.Content.ReadAsStringAsync());
            Assert.Equal(224m, body.RootElement.GetProperty("session")
                .GetProperty("expectedCash").GetDecimal());
        }

        var reconciliation = await manager.GetAsync("/api/v1/inventory/reconciliation");
        using var drift = JsonDocument.Parse(await reconciliation.Content.ReadAsStringAsync());
        Assert.DoesNotContain(drift.RootElement.GetProperty("drifts").EnumerateArray(),
            row => row.GetProperty("sku").GetString() == sku);
    }
}
