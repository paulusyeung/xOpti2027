using System.Net;
using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using xOpti.Api.IntegrationTests.Support;
using xOpti.Infrastructure.Persistence.Entities;

namespace xOpti.Api.IntegrationTests;

[Collection("api")]
public sealed class CashManagementTests(ApiPostgresFixture fixture)
{
    private async Task<TestClient> SignedInAsync(string user = "manager")
    {
        var client = new TestClient(new XOptiApiFactory(fixture));
        await client.FetchCsrfTokenAsync();
        Assert.Equal(HttpStatusCode.OK, (await client.SignInAsync(user, SeedData.Password)).Status);
        return client;
    }

    private static async Task<JsonElement> ExpectAsync(
        HttpResponseMessage response, HttpStatusCode expected, XOptiApiFactory factory)
    {
        if (response.StatusCode != expected)
        {
            var exceptions = string.Join("\n", factory.Logs.Snapshot()
                .Where(entry => entry.Exception is not null)
                .Select(entry => entry.Exception!.ToString()));
            Assert.Fail($"Expected {expected} but got {response.StatusCode}: " +
                $"{await response.Content.ReadAsStringAsync()}\n{exceptions}");
        }
        using var document = JsonDocument.Parse(await response.Content.ReadAsStringAsync());
        return document.RootElement.Clone();
    }

    private async Task<int> SeedSaleDataAsync(string sku)
    {
        var customerId = Random.Shared.Next(400000, 499999);
        await using var seed = fixture.NewContext();
        await seed.Database.ExecuteSqlInterpolatedAsync($"""
            INSERT INTO public.customer (id, full_name) VALUES ({customerId}, 'Cash Customer');
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
                1000, 1, 1, 1)
            ON CONFLICT (serial_number) DO UPDATE SET tax_a_rate = 5, tax_b_rate = 7;
            DELETE FROM public.invt_lot_record WHERE sku = {sku};
            INSERT INTO public.inventory (sku, department_code, class_code, category_code,
                supplier_code, brand_code, name, qty_total_on_hand, average_cost,
                inventory_lot_flag, retail_price_flag, whole_sale_price_flag)
            VALUES ({sku}, '09', '09', '09', '0001', '0001', 'Cash Frame', 10, 30.0000,
                true, true, false)
            ON CONFLICT (sku) DO UPDATE SET qty_total_on_hand = 10;
            INSERT INTO public.branch_inventory (branch_code, sku, qty_on_hand)
            VALUES ('01', {sku}, 10)
            ON CONFLICT (branch_code, sku) DO UPDATE SET qty_on_hand = 10;
            """);
        seed.LotRecords.Add(new InvtLotRecord
        {
            Sku = sku, LotNo = "CASHLOT", DateReceived = DateTimeOffset.UtcNow,
            SupplierCode = "0001", QtyPurchased = 10, QtyUsed = 0, QtyOnHand = 10,
            UnitAmountPurchased = xOpti.Domain.Values.Money.From(30m),
            TotalAmountPurchased = xOpti.Domain.Values.Money.From(300m),
        });
        var price = await seed.RetailPrices.SingleOrDefaultAsync(row => row.Sku == sku);
        if (price is null)
            seed.RetailPrices.Add(new RetailPrice { Sku = sku, RetailPriceValue = 50m });
        else
            price.RetailPriceValue = 50m;
        await seed.SaveChangesAsync();
        return customerId;
    }

    [Fact]
    public async Task DrawerLifecycle_AssociatesSales_CountsMovements_Close_AndFinalize()
    {
        var sku = "99000012";
        var customerId = await SeedSaleDataAsync(sku);
        var businessDate = DateOnly.FromDateTime(DateTime.UtcNow);
        var factory = new XOptiApiFactory(fixture);
        using var manager = new TestClient(factory);
        await manager.FetchCsrfTokenAsync();
        await manager.SignInAsync("manager", SeedData.Password);

        var opened = await ExpectAsync(await manager.PostAsync("/api/v1/cash/sessions", new
        {
            branchCode = "01", terminalCode = "01", openingFloat = 100m, reason = "open drawer",
        }), HttpStatusCode.Created, factory);
        var sessionId = opened.GetProperty("id").GetInt64();
        Assert.Equal("open", opened.GetProperty("status").GetString());
        Assert.Equal(100m, opened.GetProperty("expectedCash").GetDecimal());

        var duplicate = await manager.PostAsync("/api/v1/cash/sessions", new
        {
            branchCode = "01", terminalCode = "01", openingFloat = 50m, reason = "duplicate",
        });
        Assert.Equal(HttpStatusCode.BadRequest, duplicate.StatusCode);

        var sale = await ExpectAsync(await manager.PostAsync("/api/v1/sales/invoices", new
        {
            customerId,
            staffCode = "0007",
            sessionId,
            reason = "cash sale on drawer",
            lines = new[] { new { sku, quantity = 1, unitAmount = 50m, discountAmount = 0m, taxCode = "B" } },
            tenders = new[] { new { method = "C", amount = 56m, reference = (string?)null } },
        }, idempotencyKey: "cash-sale-" + Guid.NewGuid().ToString("N")),
            HttpStatusCode.Created, factory);
        var invoiceNumber = sale.GetProperty("txNumber").GetString()!;

        var afterSale = await ExpectAsync(
            await manager.GetAsync($"/api/v1/cash/sessions/{sessionId}"),
            HttpStatusCode.OK, factory);
        Assert.Equal(156m, afterSale.GetProperty("session").GetProperty("expectedCash").GetDecimal());

        var paidOut = await ExpectAsync(await manager.PostAsync(
            $"/api/v1/cash/sessions/{sessionId}/movements", new
            {
                kind = "paid-out", amount = 5m, reason = "petty cash",
                destinationReference = "EXP-1",
            }), HttpStatusCode.OK, factory);
        Assert.Equal(151m, paidOut.GetProperty("session").GetProperty("expectedCash").GetDecimal());

        var suspended = await ExpectAsync(await manager.PostAsync(
            $"/api/v1/cash/sessions/{sessionId}/suspend", new { reason = "break" }),
            HttpStatusCode.OK, factory);
        Assert.Equal("suspended", suspended.GetProperty("status").GetString());
        var resumed = await ExpectAsync(await manager.PostAsync(
            $"/api/v1/cash/sessions/{sessionId}/resume", new { reason = "back" }),
            HttpStatusCode.OK, factory);
        Assert.Equal("open", resumed.GetProperty("status").GetString());

        var countContext = await ExpectAsync(
            await manager.GetAsync($"/api/v1/cash/sessions/{sessionId}/count-context"),
            HttpStatusCode.OK, factory);
        Assert.Equal(151m, countContext.GetProperty("expectedCash").GetDecimal());
        Assert.False(countContext.GetProperty("blind").GetBoolean());

        var count = await ExpectAsync(await manager.PostAsync(
            $"/api/v1/cash/sessions/{sessionId}/counts", new
            {
                kind = "interim", amount = 151m, reason = "spot count",
            }), HttpStatusCode.OK, factory);
        Assert.Equal(0m, count.GetProperty("counts").EnumerateArray().Last()
            .GetProperty("variance").GetDecimal());

        var noReason = await manager.PostAsync($"/api/v1/cash/sessions/{sessionId}/close", new
        {
            countedCash = 145m, varianceReason = (string?)null, reason = "close drawer",
        });
        Assert.Equal(HttpStatusCode.BadRequest, noReason.StatusCode);

        var closed = await ExpectAsync(await manager.PostAsync(
            $"/api/v1/cash/sessions/{sessionId}/close", new
            {
                countedCash = 145m, varianceReason = "miscounted", reason = "close drawer",
            }), HttpStatusCode.OK, factory);
        Assert.Equal("closed", closed.GetProperty("status").GetString());
        Assert.Equal(151m, closed.GetProperty("expectedCash").GetDecimal());
        Assert.Equal(-6m, closed.GetProperty("variance").GetDecimal());

        var second = await ExpectAsync(await manager.PostAsync("/api/v1/cash/sessions", new
        {
            branchCode = "01", terminalCode = "02", openingFloat = 0m, reason = "second terminal",
        }), HttpStatusCode.Created, factory);
        var secondId = second.GetProperty("id").GetInt64();

        var blocked = await manager.PostAsync("/api/v1/cash/daily-closes", new
        {
            branchCode = "01", businessDate, reason = "finalize day",
        });
        Assert.Equal(HttpStatusCode.BadRequest, blocked.StatusCode);
        Assert.Contains("02", await blocked.Content.ReadAsStringAsync());

        await ExpectAsync(await manager.PostAsync($"/api/v1/cash/sessions/{secondId}/close", new
        {
            countedCash = 0m, varianceReason = (string?)null, reason = "close empty drawer",
        }), HttpStatusCode.OK, factory);

        var final = await ExpectAsync(await manager.PostAsync("/api/v1/cash/daily-closes", new
        {
            branchCode = "01", businessDate, reason = "finalize day",
        }), HttpStatusCode.OK, factory);
        Assert.Equal("final", final.GetProperty("status").GetString());
        Assert.Equal(50m, final.GetProperty("totalSales").GetDecimal());
        Assert.Equal(0m, final.GetProperty("totalRefunds").GetDecimal());
        Assert.Equal(2.5m, final.GetProperty("taxA").GetDecimal());
        Assert.Equal(3.5m, final.GetProperty("taxB").GetDecimal());
        Assert.Equal(56m, final.GetProperty("cashTenders").GetDecimal());
        Assert.Equal(5m, final.GetProperty("paidOut").GetDecimal());
        Assert.Equal(151m, final.GetProperty("expectedCash").GetDecimal());
        Assert.Equal(145m, final.GetProperty("countedCash").GetDecimal());
        Assert.Equal(-6m, final.GetProperty("variance").GetDecimal());
        Assert.Contains(final.GetProperty("documents").EnumerateArray(),
            document => document.GetProperty("txNumber").GetString() == invoiceNumber);
        Assert.Equal(2, final.GetProperty("sessions").GetArrayLength());

        var journal = await ExpectAsync(
            await manager.GetAsync($"/api/v1/cash/journal?branchCode=01&businessDate={businessDate:yyyy-MM-dd}"),
            HttpStatusCode.OK, factory);
        Assert.Equal("final", journal.GetProperty("status").GetString());
        Assert.Equal(151m, journal.GetProperty("expectedCash").GetDecimal());

        var repeat = await manager.PostAsync("/api/v1/cash/daily-closes", new
        {
            branchCode = "01", businessDate, reason = "finalize again",
        });
        Assert.Equal(HttpStatusCode.BadRequest, repeat.StatusCode);
        Assert.Contains("already finalized", await repeat.Content.ReadAsStringAsync());

        await using var verify = fixture.NewContext();
        Assert.Equal(1, await verify.CashSessionTransactions.CountAsync(row =>
            row.SessionId == sessionId && row.TxNumber == invoiceNumber));
        Assert.Equal(1, await verify.CashDailyCloses.CountAsync(row =>
            row.BranchCode == "01" && row.BusinessDate == businessDate));
    }

    [Fact]
    public async Task BlindCount_HidesExpectedUntilACountIsSubmitted()
    {
        var factory = new XOptiApiFactory(fixture,
            new Dictionary<string, string?> { ["XOptiApi:BlindCashCount"] = "true" });
        using var manager = new TestClient(factory);
        await manager.FetchCsrfTokenAsync();
        await manager.SignInAsync("manager", SeedData.Password);

        var opened = await ExpectAsync(await manager.PostAsync("/api/v1/cash/sessions", new
        {
            branchCode = "01", terminalCode = "09", openingFloat = 50m, reason = "blind open",
        }), HttpStatusCode.Created, factory);
        var sessionId = opened.GetProperty("id").GetInt64();

        var hidden = await ExpectAsync(
            await manager.GetAsync($"/api/v1/cash/sessions/{sessionId}/count-context"),
            HttpStatusCode.OK, factory);
        Assert.True(hidden.GetProperty("blind").GetBoolean());
        Assert.Equal(JsonValueKind.Null, hidden.GetProperty("expectedCash").ValueKind);

        await ExpectAsync(await manager.PostAsync($"/api/v1/cash/sessions/{sessionId}/counts", new
        {
            kind = "interim", amount = 50m, reason = "blind count",
        }), HttpStatusCode.OK, factory);

        var revealed = await ExpectAsync(
            await manager.GetAsync($"/api/v1/cash/sessions/{sessionId}/count-context"),
            HttpStatusCode.OK, factory);
        Assert.False(revealed.GetProperty("blind").GetBoolean());
        Assert.Equal(50m, revealed.GetProperty("expectedCash").GetDecimal());

        await ExpectAsync(await manager.PostAsync($"/api/v1/cash/sessions/{sessionId}/close", new
        {
            countedCash = 50m, varianceReason = (string?)null, reason = "blind close",
        }), HttpStatusCode.OK, factory);
    }

    [Fact]
    public async Task CashJournal_RequiresFinancialPermission()
    {
        var factory = new XOptiApiFactory(fixture);
        using var optician = new TestClient(factory);
        await optician.FetchCsrfTokenAsync();
        await optician.SignInAsync("optician", SeedData.Password);
        var businessDate = DateOnly.FromDateTime(DateTime.UtcNow);
        var response = await optician.GetAsync(
            $"/api/v1/cash/journal?branchCode=01&businessDate={businessDate:yyyy-MM-dd}");
        Assert.Equal(HttpStatusCode.Forbidden, response.StatusCode);
    }

    [Fact]
    public async Task RefundLinkedToSession_ReducesExpectedCash_AndReconcilesInJournal()
    {
        var sku = "99000013";
        var customerId = await SeedSaleDataAsync(sku);
        var businessDate = DateOnly.FromDateTime(DateTime.UtcNow);
        var factory = new XOptiApiFactory(fixture);
        using var manager = new TestClient(factory);
        await manager.FetchCsrfTokenAsync();
        await manager.SignInAsync("manager", SeedData.Password);

        var opened = await ExpectAsync(await manager.PostAsync("/api/v1/cash/sessions", new
        {
            branchCode = "02", terminalCode = "01", openingFloat = 0m, reason = "refund drawer",
        }), HttpStatusCode.Created, factory);
        var sessionId = opened.GetProperty("id").GetInt64();

        var sale = await ExpectAsync(await manager.PostAsync("/api/v1/sales/invoices", new
        {
            customerId, staffCode = "0007", sessionId, reason = "refund test sale",
            lines = new[] { new { sku, quantity = 2, unitAmount = 50m, discountAmount = 0m, taxCode = "B" } },
            tenders = new[] { new { method = "C", amount = 112m, reference = (string?)null } },
        }, idempotencyKey: "refund-session-sale-" + Guid.NewGuid().ToString("N")),
            HttpStatusCode.Created, factory);
        var invoiceNumber = sale.GetProperty("txNumber").GetString()!;

        var refund = await ExpectAsync(await manager.PostAsync("/api/v1/sales/refunds", new
        {
            originalTxNumber = invoiceNumber, staffCode = "0007", sessionId,
            reason = "refund on drawer",
            lines = new[] { new { originalRowNo = 1, quantity = 1, restock = false } },
            replacements = Array.Empty<object>(),
            refundTenders = new[] { new { method = "C", amount = 56m, reference = (string?)null,
                originalPaymentLineNo = 1d } },
            saleTenders = Array.Empty<object>(),
        }, idempotencyKey: "refund-session-" + Guid.NewGuid().ToString("N")),
            HttpStatusCode.Created, factory);
        Assert.StartsWith("RS", refund.GetProperty("txNumber").GetString());

        var session = await ExpectAsync(
            await manager.GetAsync($"/api/v1/cash/sessions/{sessionId}"),
            HttpStatusCode.OK, factory);
        Assert.Equal(56m, session.GetProperty("session").GetProperty("expectedCash").GetDecimal());

        await ExpectAsync(await manager.PostAsync($"/api/v1/cash/sessions/{sessionId}/close", new
        {
            countedCash = 56m, varianceReason = (string?)null, reason = "close refund drawer",
        }), HttpStatusCode.OK, factory);

        var final = await ExpectAsync(await manager.PostAsync("/api/v1/cash/daily-closes", new
        {
            branchCode = "02", businessDate, reason = "finalize refund day",
        }), HttpStatusCode.OK, factory);
        Assert.Equal(100m, final.GetProperty("totalSales").GetDecimal());
        Assert.Equal(50m, final.GetProperty("totalRefunds").GetDecimal());
        Assert.Equal(56m, final.GetProperty("cashTenders").GetDecimal());
        Assert.Equal(56m, final.GetProperty("expectedCash").GetDecimal());
        Assert.Equal(0m, final.GetProperty("variance").GetDecimal());
        Assert.Contains(final.GetProperty("documents").EnumerateArray(),
            document => document.GetProperty("txType").GetString() == "RS");
    }
}
