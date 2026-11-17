using System.Net;
using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using xOpti.Api.IntegrationTests.Support;
using xOpti.Infrastructure.Persistence.Entities;

namespace xOpti.Api.IntegrationTests;

[Collection("api")]
public sealed class PosFullDayRehearsalTests(ApiPostgresFixture fixture)
{
    private async Task<int> SeedAsync(string sku)
    {
        var customerId = Random.Shared.Next(200000, 299999);
        await using var seed = fixture.NewContext();
        await seed.Database.ExecuteSqlInterpolatedAsync($"""
            INSERT INTO public.customer (id, full_name) VALUES ({customerId}, 'Rehearsal Customer');
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
                3000, 1, 1, 1)
            ON CONFLICT (serial_number) DO UPDATE
            SET tax_a_rate = 5, tax_b_rate = 7, next_invt_control_number = 3000;
            DELETE FROM public.invt_lot_record WHERE sku = {sku};
            INSERT INTO public.inventory (sku, department_code, class_code, category_code,
                supplier_code, brand_code, name, qty_total_on_hand, average_cost,
                inventory_lot_flag, retail_price_flag, whole_sale_price_flag)
            VALUES ({sku}, '09', '09', '09', '0001', '0001', 'Rehearsal Frame', 20, 30.0000,
                true, true, false);
            INSERT INTO public.branch_inventory (branch_code, sku, qty_on_hand)
            VALUES ('01', {sku}, 20)
            ON CONFLICT (branch_code, sku) DO UPDATE SET qty_on_hand = 20;
            """);
        seed.LotRecords.Add(new InvtLotRecord
        {
            Sku = sku, LotNo = "DAYLOT", DateReceived = DateTimeOffset.UtcNow,
            SupplierCode = "0001", QtyPurchased = 20, QtyUsed = 0, QtyOnHand = 20,
            UnitAmountPurchased = xOpti.Domain.Values.Money.From(30m),
            TotalAmountPurchased = xOpti.Domain.Values.Money.From(600m),
        });
        seed.RetailPrices.Add(new RetailPrice { Sku = sku, RetailPriceValue = 50m });
        await seed.SaveChangesAsync();
        return customerId;
    }

    private static async Task<JsonElement> BodyAsync(HttpResponseMessage response, XOptiApiFactory factory,
        HttpStatusCode expected)
    {
        if (response.StatusCode != expected)
        {
            var exceptions = string.Join("\n", factory.Logs.Snapshot()
                .Where(entry => entry.Exception is not null)
                .Select(entry => entry.Exception!.ToString()));
            Assert.Fail($"{response.StatusCode}: {await response.Content.ReadAsStringAsync()}\n{exceptions}");
        }
        using var document = JsonDocument.Parse(await response.Content.ReadAsStringAsync());
        return document.RootElement.Clone();
    }

    [Fact]
    public async Task FullDay_OrdersInvoicesRefundsSplitTendersCashSessions_Reconcile()
    {
        var sku = "99000015";
        var customerId = await SeedAsync(sku);
        var businessDate = DateOnly.FromDateTime(DateTime.UtcNow);
        var factory = new XOptiApiFactory(fixture);
        using var manager = new TestClient(factory);
        await manager.FetchCsrfTokenAsync();
        await manager.SignInAsync("manager", SeedData.Password);

        var sessionNumbers = new List<long>();
        foreach (var terminal in new[] { "01", "02" })
        {
            var opened = await BodyAsync(await manager.PostAsync("/api/v1/cash/sessions", new
            {
                branchCode = "01", terminalCode = terminal, openingFloat = 100m,
                reason = "rehearsal drawer",
            }), factory, HttpStatusCode.Created);
            sessionNumbers.Add(opened.GetProperty("id").GetInt64());
        }

        var order = await BodyAsync(await manager.PostAsync("/api/v1/sales/orders", new
        {
            customerId, staffCode = "0007", depositAmount = 20m, reason = "rehearsal order",
            lines = new[] { new { sku, quantity = 2, unitAmount = 50m, discountAmount = 0m,
                taxCode = "B" } },
        }, idempotencyKey: "day-order-" + Guid.NewGuid().ToString("N")),
            factory, HttpStatusCode.Created);
        var orderNumber = order.GetProperty("txNumber").GetString()!;

        var converted = await BodyAsync(await manager.PostAsync(
            $"/api/v1/sales/orders/{orderNumber}/convert", new
            {
                sessionId = sessionNumbers[0],
                reason = "rehearsal conversion",
                tenders = new[] { new { method = "C", amount = 92m, reference = (string?)null } },
            }, idempotencyKey: "day-convert-" + Guid.NewGuid().ToString("N")),
            factory, HttpStatusCode.OK);
        var orderInvoice = converted.GetProperty("txNumber").GetString()!;

        var direct = await BodyAsync(await manager.PostAsync("/api/v1/sales/invoices", new
        {
            customerId, staffCode = "0007", sessionId = sessionNumbers[1],
            reason = "rehearsal split tender",
            lines = new[] { new { sku, quantity = 2, unitAmount = 50m, discountAmount = 0m,
                taxCode = "B" } },
            tenders = new[]
            {
                new { method = "C", amount = 60m, reference = (string?)null },
                new { method = "K", amount = 52m, reference = "AUTH-DAY" },
            },
        }, idempotencyKey: "day-direct-" + Guid.NewGuid().ToString("N")),
            factory, HttpStatusCode.Created);
        var directInvoice = direct.GetProperty("txNumber").GetString()!;

        var refund = await BodyAsync(await manager.PostAsync("/api/v1/sales/refunds", new
        {
            originalTxNumber = directInvoice, staffCode = "0007", sessionId = sessionNumbers[1],
            reason = "rehearsal partial refund",
            lines = new[] { new { originalRowNo = 1, quantity = 1, restock = false } },
            replacements = Array.Empty<object>(),
            refundTenders = new[] { new { method = "C", amount = 56m, reference = (string?)null,
                originalPaymentLineNo = 1d } },
            saleTenders = Array.Empty<object>(),
        }, idempotencyKey: "day-refund-" + Guid.NewGuid().ToString("N")),
            factory, HttpStatusCode.Created);
        var refundNumber = refund.GetProperty("txNumber").GetString()!;

        await BodyAsync(await manager.PostAsync(
            $"/api/v1/cash/sessions/{sessionNumbers[0]}/movements", new
            {
                kind = "paid-in", amount = 10m, reason = "float top-up",
                destinationReference = (string?)null,
            }), factory, HttpStatusCode.OK);
        await BodyAsync(await manager.PostAsync(
            $"/api/v1/cash/sessions/{sessionNumbers[0]}/movements", new
            {
                kind = "pickup", amount = 20m, reason = "midday pickup",
                destinationReference = "SAFE-1",
            }), factory, HttpStatusCode.OK);
        await BodyAsync(await manager.PostAsync(
            $"/api/v1/cash/sessions/{sessionNumbers[1]}/movements", new
            {
                kind = "deposit", amount = 5m, reason = "bank deposit",
                destinationReference = "BANK-1",
            }), factory, HttpStatusCode.OK);

        await BodyAsync(await manager.PostAsync(
            $"/api/v1/cash/sessions/{sessionNumbers[0]}/close", new
            {
                countedCash = 182m, varianceReason = (string?)null, reason = "close terminal 01",
            }), factory, HttpStatusCode.OK);
        await BodyAsync(await manager.PostAsync(
            $"/api/v1/cash/sessions/{sessionNumbers[1]}/close", new
            {
                countedCash = 99m, varianceReason = (string?)null, reason = "close terminal 02",
            }), factory, HttpStatusCode.OK);

        var close = await BodyAsync(await manager.PostAsync("/api/v1/cash/daily-closes", new
        {
            branchCode = "01", businessDate, reason = "full-day rehearsal",
        }), factory, HttpStatusCode.OK);

        Assert.Equal(200m, close.GetProperty("totalSales").GetDecimal());
        Assert.Equal(50m, close.GetProperty("totalRefunds").GetDecimal());
        Assert.Equal(7.5m, close.GetProperty("taxA").GetDecimal());
        Assert.Equal(10.5m, close.GetProperty("taxB").GetDecimal());
        Assert.Equal(96m, close.GetProperty("cashTenders").GetDecimal());
        Assert.Equal(52m, close.GetProperty("cardTenders").GetDecimal());
        Assert.Equal(10m, close.GetProperty("paidIn").GetDecimal());
        Assert.Equal(0m, close.GetProperty("paidOut").GetDecimal());
        Assert.Equal(20m, close.GetProperty("pickups").GetDecimal());
        Assert.Equal(5m, close.GetProperty("deposits").GetDecimal());
        Assert.Equal(281m, close.GetProperty("expectedCash").GetDecimal());
        Assert.Equal(281m, close.GetProperty("countedCash").GetDecimal());
        Assert.Equal(0m, close.GetProperty("variance").GetDecimal());
        Assert.Equal(3, close.GetProperty("documents").GetArrayLength());
        Assert.Contains(close.GetProperty("documents").EnumerateArray(),
            row => row.GetProperty("txNumber").GetString() == orderInvoice);
        Assert.Contains(close.GetProperty("documents").EnumerateArray(),
            row => row.GetProperty("txNumber").GetString() == directInvoice);
        Assert.Contains(close.GetProperty("documents").EnumerateArray(),
            row => row.GetProperty("txNumber").GetString() == refundNumber);
        Assert.Equal("final", close.GetProperty("status").GetString());

        var journal = await BodyAsync(await manager.GetAsync(
            $"/api/v1/cash/journal?branchCode=01&businessDate={businessDate:yyyy-MM-dd}"),
            factory, HttpStatusCode.OK);
        Assert.Equal(281m, journal.GetProperty("expectedCash").GetDecimal());
        Assert.Equal(3, journal.GetProperty("documents").GetArrayLength());

        var repeat = await manager.PostAsync("/api/v1/cash/daily-closes", new
        {
            branchCode = "01", businessDate, reason = "rehearsal repeat",
        });
        Assert.Equal(HttpStatusCode.BadRequest, repeat.StatusCode);

        await using var verify = fixture.NewContext();
        Assert.Equal(16, (await verify.InventoryItems.SingleAsync(row => row.Sku == sku)).QtyTotalOnHand);
        Assert.Equal("3", (await verify.TxHeaders.SingleAsync(
            row => row.TxNumber == orderNumber)).Status);
        Assert.Equal(orderInvoice, (await verify.TxHeaders.SingleAsync(
            row => row.TxNumber == orderNumber)).RefNumber);
        Assert.Equal(1, await verify.CashSessionTransactions.CountAsync(
            row => row.TxNumber == orderInvoice && row.SessionId == sessionNumbers[0]));
        Assert.Equal(2, await verify.CashSessionTransactions.CountAsync(
            row => row.SessionId == sessionNumbers[1]));
    }
}
