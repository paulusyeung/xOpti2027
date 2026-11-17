using System.Net;
using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using xOpti.Api.IntegrationTests.Support;
using xOpti.Infrastructure.Persistence.Entities;

namespace xOpti.Api.IntegrationTests;

[Collection("api")]
public sealed class RetailSaleTests(ApiPostgresFixture fixture)
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

    private async Task<int> SeedAsync(
        string sku, int quantity = 10, decimal unitCost = 30m, decimal? retail = 50m)
    {
        var customerId = Random.Shared.Next(500000, 599999);
        await using var seed = fixture.NewContext();
        await seed.Database.ExecuteSqlInterpolatedAsync($"""
            INSERT INTO public.customer (id, full_name) VALUES ({customerId}, 'Retail Customer');
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
            VALUES ({sku}, '09', '09', '09', '0001', '0001', 'Retail Frame', {quantity},
                {unitCost}, true, true, false)
            ON CONFLICT (sku) DO UPDATE SET qty_total_on_hand = {quantity}, average_cost = {unitCost};
            INSERT INTO public.branch_inventory (branch_code, sku, qty_on_hand)
            VALUES ('01', {sku}, {quantity})
            ON CONFLICT (branch_code, sku) DO UPDATE SET qty_on_hand = {quantity};
            """);

        seed.LotRecords.Add(new InvtLotRecord
        {
            Sku = sku, LotNo = "RTLOT", DateReceived = DateTimeOffset.UtcNow,
            SupplierCode = "0001", QtyPurchased = quantity, QtyUsed = 0, QtyOnHand = quantity,
            UnitAmountPurchased = xOpti.Domain.Values.Money.From(unitCost),
            TotalAmountPurchased = xOpti.Domain.Values.Money.From(unitCost * quantity),
        });
        var price = await seed.RetailPrices.SingleOrDefaultAsync(row => row.Sku == sku);
        if (price is null)
            seed.RetailPrices.Add(new RetailPrice { Sku = sku, RetailPriceValue = retail });
        else
            price.RetailPriceValue = retail;
        await seed.SaveChangesAsync();
        return customerId;
    }

    private static object InvoiceBody(
        int customerId, string sku, int quantity = 1, decimal unitAmount = 50m,
        decimal discount = 0m, string method = "C", decimal? tender = null,
        string? reference = null) => new
    {
        customerId,
        staffCode = "0007",
        reason = "retail sale test",
        lines = new[] { new { sku, quantity, unitAmount, discountAmount = discount, taxCode = "B" } },
        tenders = new[] { new { method, amount = tender ?? unitAmount * quantity, reference } },
    };

    private static object RefundTender(decimal amount, double originalLine = 1) => new
    {
        method = "C", amount, reference = (string?)null, originalPaymentLineNo = originalLine,
    };

    [Fact]
    public async Task DirectInvoice_PostsCashChangeInventoryAudit_AndReprintKeepsSnapshots()
    {
        var sku = "99000002";
        var customerId = await SeedAsync(sku);
        var factory = new XOptiApiFactory(fixture);
        using var manager = new TestClient(factory);
        await manager.FetchCsrfTokenAsync();
        await manager.SignInAsync("manager", SeedData.Password);

        var create = await manager.PostAsync("/api/v1/sales/invoices",
            InvoiceBody(customerId, sku, quantity: 2, tender: 120m),
            idempotencyKey: "rc-" + Guid.NewGuid().ToString("N"));
        var invoice = await ExpectAsync(create, HttpStatusCode.Created, factory);
        var invoiceNumber = invoice.GetProperty("txNumber").GetString()!;
        Assert.StartsWith("RC", invoiceNumber);
        Assert.Equal("Invoice", invoice.GetProperty("kind").GetString());
        Assert.Equal(112m, invoice.GetProperty("totalAmount").GetDecimal());
        Assert.Equal(8m, invoice.GetProperty("change").GetDecimal());
        Assert.Equal(112m, invoice.GetProperty("paid").GetDecimal());
        Assert.Equal(0m, invoice.GetProperty("balance").GetDecimal());
        var line = invoice.GetProperty("lines").EnumerateArray().Single();
        Assert.Equal(30m, line.GetProperty("unitCost").GetDecimal());
        var tender = invoice.GetProperty("payments").EnumerateArray().Single();
        Assert.Equal(120m, tender.GetProperty("amountTender").GetDecimal());
        Assert.Equal(112m, tender.GetProperty("appliedAmount").GetDecimal());

        await using (var verify = fixture.NewContext())
        {
            Assert.Equal(8, (await verify.InventoryItems.SingleAsync(
                row => row.Sku == sku)).QtyTotalOnHand);
            Assert.Equal(8, (await verify.LotRecords.SingleAsync(
                row => row.Sku == sku && row.LotNo == "RTLOT")).QtyOnHand);
            var header = await verify.TxHeaders.SingleAsync(row => row.TxNumber == invoiceNumber);
            Assert.Equal(112m, header.ThisPaid.Amount);
            Assert.Equal(8m, header.Change.Amount);
            Assert.True(await verify.AuditLogs.AnyAsync(row =>
                row.Action == "retail.invoice" && row.EntityId == invoiceNumber));

            var price = await verify.RetailPrices.SingleAsync(row => row.Sku == sku);
            price.RetailPriceValue = 999m;
            var preference = await verify.Preferences.SingleAsync();
            preference.TaxARate = 10;
            preference.TaxBRate = 10;
            await verify.SaveChangesAsync();
        }

        var reprint = await ExpectAsync(
            await manager.GetAsync($"/api/v1/sales/documents/{invoiceNumber}"),
            HttpStatusCode.OK, factory);
        Assert.Equal(invoiceNumber, reprint.GetProperty("txNumber").GetString());
        Assert.Equal(5m, reprint.GetProperty("taxA").GetDecimal());
        Assert.Equal(7m, reprint.GetProperty("taxB").GetDecimal());
        Assert.Equal(112m, reprint.GetProperty("totalAmount").GetDecimal());
        Assert.Equal(50m, reprint.GetProperty("lines").EnumerateArray().Single()
            .GetProperty("unitAmount").GetDecimal());
        Assert.Equal(120m, reprint.GetProperty("payments").EnumerateArray().Single()
            .GetProperty("amountTender").GetDecimal());
    }

    [Fact]
    public async Task FailedPayment_RollsBackInvoiceInventoryAndControlNumber()
    {
        var sku = "99000003";
        var customerId = await SeedAsync(sku);
        var factory = new XOptiApiFactory(fixture);
        using var manager = new TestClient(factory);
        await manager.FetchCsrfTokenAsync();
        await manager.SignInAsync("manager", SeedData.Password);

        var counterBefore = 0;
        await using (var before = fixture.NewContext())
        {
            counterBefore = (await before.PrefTxNumbers.SingleAsync(
                row => row.TxPrefix == "RC")).TxNextNumber;
        }

        var response = await manager.PostAsync("/api/v1/sales/invoices",
            InvoiceBody(customerId, sku, method: "K", tender: 100m, reference: "AUTH-1"),
            idempotencyKey: "rollback-" + Guid.NewGuid().ToString("N"));
        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);

        await using var verify = fixture.NewContext();
        Assert.Equal(10, (await verify.InventoryItems.SingleAsync(
            row => row.Sku == sku)).QtyTotalOnHand);
        Assert.Equal(10, (await verify.LotRecords.SingleAsync(
            row => row.Sku == sku && row.LotNo == "RTLOT")).QtyOnHand);
        Assert.Equal(counterBefore, (await verify.PrefTxNumbers.SingleAsync(
            row => row.TxPrefix == "RC")).TxNextNumber);
        Assert.False(await verify.TxHeaders.AnyAsync(row =>
            row.CustomerId == customerId && row.TxType == xOpti.Domain.Values.TransactionType.RetailInvoice));
    }

    [Fact]
    public async Task PartialRefund_OverRefundExchange_AndFullyRefundedStatus()
    {
        var sku = "99000004";
        var customerId = await SeedAsync(sku);
        var factory = new XOptiApiFactory(fixture);
        using var manager = new TestClient(factory);
        await manager.FetchCsrfTokenAsync();
        await manager.SignInAsync("manager", SeedData.Password);

        var sale = await ExpectAsync(await manager.PostAsync("/api/v1/sales/invoices",
            InvoiceBody(customerId, sku, quantity: 3, tender: 168m),
            idempotencyKey: "rs-sale-" + Guid.NewGuid().ToString("N")),
            HttpStatusCode.Created, factory);
        var invoiceNumber = sale.GetProperty("txNumber").GetString()!;

        var refundable = await ExpectAsync(
            await manager.GetAsync($"/api/v1/sales/invoices/{invoiceNumber}/refundable"),
            HttpStatusCode.OK, factory);
        var refundableLine = refundable.GetProperty("lines").EnumerateArray().Single();
        Assert.Equal(3, refundableLine.GetProperty("refundableQuantity").GetInt32());
        Assert.Equal(7.5m, refundableLine.GetProperty("taxA").GetDecimal());
        Assert.Equal(10.5m, refundableLine.GetProperty("taxB").GetDecimal());

        var refund = await ExpectAsync(await manager.PostAsync("/api/v1/sales/refunds", new
        {
            originalTxNumber = invoiceNumber,
            staffCode = "0007",
            reason = "partial refund",
            lines = new[] { new { originalRowNo = 1, quantity = 1, restock = true } },
            replacements = Array.Empty<object>(),
            refundTenders = new[] { RefundTender(56m) },
            saleTenders = Array.Empty<object>(),
        }, idempotencyKey: "rs-partial-" + Guid.NewGuid().ToString("N")),
            HttpStatusCode.Created, factory);
        var refundNumber = refund.GetProperty("txNumber").GetString()!;
        Assert.StartsWith("RS", refundNumber);
        Assert.Equal("Refund", refund.GetProperty("kind").GetString());
        Assert.Equal(-50m, refund.GetProperty("totalSale").GetDecimal());
        Assert.Equal(-2.5m, refund.GetProperty("taxA").GetDecimal());
        Assert.Equal(-3.5m, refund.GetProperty("taxB").GetDecimal());
        Assert.Equal(-56m, refund.GetProperty("totalAmount").GetDecimal());
        Assert.Equal(-1, refund.GetProperty("totalQty").GetInt32());

        await using (var verify = fixture.NewContext())
        {
            Assert.Equal(8, (await verify.InventoryItems.SingleAsync(
                row => row.Sku == sku)).QtyTotalOnHand);
            Assert.Equal("0", (await verify.TxHeaders.SingleAsync(
                row => row.TxNumber == invoiceNumber)).Status);
            Assert.Equal(1, await verify.SalesRefundLines.CountAsync(row =>
                row.RefundTxNumber == refundNumber && row.OriginalRowNo == 1));
            Assert.Equal(56m, (await verify.SalesRefundTenders.SingleAsync(row =>
                row.RefundTxNumber == refundNumber)).Amount);
        }

        var afterPartial = await ExpectAsync(
            await manager.GetAsync($"/api/v1/sales/invoices/{invoiceNumber}/refundable"),
            HttpStatusCode.OK, factory);
        Assert.Equal(2, afterPartial.GetProperty("lines").EnumerateArray().Single()
            .GetProperty("refundableQuantity").GetInt32());
        Assert.Equal(2.5m, afterPartial.GetProperty("refundedTaxA").GetDecimal());

        var overRefund = await manager.PostAsync("/api/v1/sales/refunds", new
        {
            originalTxNumber = invoiceNumber,
            staffCode = "0007",
            reason = "too many units",
            lines = new[] { new { originalRowNo = 1, quantity = 3, restock = false } },
            replacements = Array.Empty<object>(),
            refundTenders = new[] { RefundTender(168m) },
            saleTenders = Array.Empty<object>(),
        }, idempotencyKey: "rs-over-" + Guid.NewGuid().ToString("N"));
        Assert.Equal(HttpStatusCode.BadRequest, overRefund.StatusCode);

        var exchange = await ExpectAsync(await manager.PostAsync("/api/v1/sales/refunds", new
        {
            originalTxNumber = invoiceNumber,
            staffCode = "0007",
            reason = "exchange remainder",
            lines = new[] { new { originalRowNo = 1, quantity = 2, restock = false } },
            replacements = new[]
            {
                new { sku, quantity = 1, unitAmount = 50m, discountAmount = 0m, taxCode = "B" },
            },
            refundTenders = new[] { RefundTender(56m) },
            saleTenders = Array.Empty<object>(),
        }, idempotencyKey: "rs-exchange-" + Guid.NewGuid().ToString("N")),
            HttpStatusCode.Created, factory);
        var exchangeNumber = exchange.GetProperty("txNumber").GetString()!;
        Assert.NotEqual(refundNumber, exchangeNumber);
        Assert.StartsWith("RS", exchangeNumber);
        Assert.Equal(-50m, exchange.GetProperty("totalSale").GetDecimal());
        Assert.Equal(-2.5m, exchange.GetProperty("taxA").GetDecimal());
        Assert.Equal(-3.5m, exchange.GetProperty("taxB").GetDecimal());
        Assert.Equal(-56m, exchange.GetProperty("totalAmount").GetDecimal());
        Assert.Equal(-1, exchange.GetProperty("totalQty").GetInt32());

        await using (var verify = fixture.NewContext())
        {
            Assert.Equal(7, (await verify.InventoryItems.SingleAsync(
                row => row.Sku == sku)).QtyTotalOnHand);
            Assert.Equal("1", (await verify.TxHeaders.SingleAsync(
                row => row.TxNumber == invoiceNumber)).Status);
            Assert.True(await verify.AuditLogs.AnyAsync(row =>
                row.Action == "retail.refund" && row.EntityId == refundNumber));
            Assert.True(await verify.AuditLogs.AnyAsync(row =>
                row.Action == "retail.refund" && row.EntityId == exchangeNumber));
        }

        var fullyRefunded = await ExpectAsync(
            await manager.GetAsync($"/api/v1/sales/invoices/{invoiceNumber}/refundable"),
            HttpStatusCode.OK, factory);
        Assert.All(fullyRefunded.GetProperty("lines").EnumerateArray(),
            line => Assert.Equal(0, line.GetProperty("refundableQuantity").GetInt32()));

        var reprint = await ExpectAsync(
            await manager.GetAsync($"/api/v1/sales/documents/{invoiceNumber}"),
            HttpStatusCode.OK, factory);
        Assert.Equal(168m, reprint.GetProperty("totalAmount").GetDecimal());
        Assert.Equal(150m, reprint.GetProperty("totalSale").GetDecimal());
    }

    [Fact]
    public async Task PriceOverrideAndDiscount_RequirePermission_AndAreAudited()
    {
        var sku = "99000005";
        var customerId = await SeedAsync(sku);
        var factory = new XOptiApiFactory(fixture);

        using var optician = new TestClient(factory);
        await optician.FetchCsrfTokenAsync();
        Assert.Equal(HttpStatusCode.OK,
            (await optician.SignInAsync("optician", SeedData.Password)).Status);

        var deniedPrice = await optician.PostAsync("/api/v1/sales/invoices",
            InvoiceBody(customerId, sku, unitAmount: 40m, tender: 44.8m),
            idempotencyKey: "deny-price-" + Guid.NewGuid().ToString("N"));
        Assert.Equal(HttpStatusCode.BadRequest, deniedPrice.StatusCode);
        Assert.Contains("price-override", await deniedPrice.Content.ReadAsStringAsync());

        var deniedDiscount = await optician.PostAsync("/api/v1/sales/invoices",
            InvoiceBody(customerId, sku, discount: 5m, tender: 50.4m),
            idempotencyKey: "deny-discount-" + Guid.NewGuid().ToString("N"));
        Assert.Equal(HttpStatusCode.BadRequest, deniedDiscount.StatusCode);
        Assert.Contains("discount-override", await deniedDiscount.Content.ReadAsStringAsync());

        await using (var verify = fixture.NewContext())
        {
            Assert.Equal(10, (await verify.InventoryItems.SingleAsync(
                row => row.Sku == sku)).QtyTotalOnHand);
        }

        using var manager = new TestClient(factory);
        await manager.FetchCsrfTokenAsync();
        await manager.SignInAsync("manager", SeedData.Password);
        var allowed = await ExpectAsync(await manager.PostAsync("/api/v1/sales/invoices",
            InvoiceBody(customerId, sku, unitAmount: 40m, discount: 5m, tender: 39.2m),
            idempotencyKey: "allow-override-" + Guid.NewGuid().ToString("N")),
            HttpStatusCode.Created, factory);
        var invoiceNumber = allowed.GetProperty("txNumber").GetString()!;
        Assert.Equal(39.2m, allowed.GetProperty("totalAmount").GetDecimal());

        await using var verifyAudit = fixture.NewContext();
        Assert.True(await verifyAudit.AuditLogs.AnyAsync(row =>
            row.Action == "sales.price-override" && row.EntityId == invoiceNumber
            && row.Details!.Contains("99000005")));
        Assert.True(await verifyAudit.AuditLogs.AnyAsync(row =>
            row.Action == "sales.discount-override" && row.EntityId == invoiceNumber
            && row.Details!.Contains("99000005")));
    }

    [Fact]
    public async Task SplitTender_WithCardReference_AndExactTotals()
    {
        var sku = "99000006";
        var customerId = await SeedAsync(sku);
        var factory = new XOptiApiFactory(fixture);
        using var manager = new TestClient(factory);
        await manager.FetchCsrfTokenAsync();
        await manager.SignInAsync("manager", SeedData.Password);

        var created = await ExpectAsync(await manager.PostAsync("/api/v1/sales/invoices", new
        {
            customerId,
            staffCode = "0007",
            reason = "split tender",
            lines = new[] { new { sku, quantity = 2, unitAmount = 50m, discountAmount = 0m, taxCode = "B" } },
            tenders = new[]
            {
                new { method = "C", amount = 50m, reference = (string?)null },
                new { method = "K", amount = 62m, reference = "AUTH-SPLIT" },
            },
        }, idempotencyKey: "split-" + Guid.NewGuid().ToString("N")),
            HttpStatusCode.Created, factory);

        Assert.Equal(112m, created.GetProperty("totalAmount").GetDecimal());
        Assert.Equal(112m, created.GetProperty("paid").GetDecimal());
        Assert.Equal(0m, created.GetProperty("balance").GetDecimal());
        Assert.Equal(2, created.GetProperty("payments").GetArrayLength());

        await using var verify = fixture.NewContext();
        var payments = await verify.TxPayments.Where(row =>
            row.TxNumber == created.GetProperty("txNumber").GetString()).OrderBy(row => row.PaymentLineNo)
            .ToListAsync();
        Assert.Equal(new[] { "C", "K" }, payments.Select(row => row.Type));
        Assert.Equal("AUTH-SPLIT", payments[1].AuthorizationCode);
        Assert.Null(payments[1].CardNumber);
    }

    [Fact]
    public async Task CardTender_RequiresManualReference_AndNeverStoresCardData()
    {
        var sku = "99000007";
        var customerId = await SeedAsync(sku);
        var factory = new XOptiApiFactory(fixture);
        using var manager = new TestClient(factory);
        await manager.FetchCsrfTokenAsync();
        await manager.SignInAsync("manager", SeedData.Password);

        var missingReference = await manager.PostAsync("/api/v1/sales/invoices",
            InvoiceBody(customerId, sku, method: "K", tender: 56m),
            idempotencyKey: "no-ref-" + Guid.NewGuid().ToString("N"));
        Assert.Equal(HttpStatusCode.BadRequest, missingReference.StatusCode);
        Assert.Contains("approval reference", await missingReference.Content.ReadAsStringAsync());

        const string cardNumber = "4111111111111111";
        var panReference = await manager.PostAsync("/api/v1/sales/invoices",
            InvoiceBody(customerId, sku, method: "K", tender: 56m, reference: cardNumber),
            idempotencyKey: "pan-ref-" + Guid.NewGuid().ToString("N"));
        Assert.Equal(HttpStatusCode.BadRequest, panReference.StatusCode);
        Assert.DoesNotContain(cardNumber, await panReference.Content.ReadAsStringAsync());

        var created = await manager.PostAsync("/api/v1/sales/invoices", new
        {
            customerId,
            staffCode = "0007",
            reason = "card sale",
            lines = new[] { new { sku, quantity = 1, unitAmount = 50m, discountAmount = 0m, taxCode = "B" } },
            tenders = new[] { new { method = "K", amount = 56m, reference = "AUTH-42",
                cardNumber } },
        }, idempotencyKey: "card-" + Guid.NewGuid().ToString("N"));
        var document = await ExpectAsync(created, HttpStatusCode.Created, factory);
        var invoiceNumber = document.GetProperty("txNumber").GetString()!;
        Assert.DoesNotContain(cardNumber, await created.Content.ReadAsStringAsync());

        await using var verify = fixture.NewContext();
        var payment = await verify.TxPayments.SingleAsync(row => row.TxNumber == invoiceNumber);
        Assert.Equal("AUTH-42", payment.AuthorizationCode);
        Assert.Null(payment.CardNumber);
        Assert.All(factory.Logs.Snapshot(),
            entry => Assert.DoesNotContain(cardNumber, entry.Message));
    }

    [Fact]
    public async Task TerminalDeclineAndTimeout_RejectsWithoutPosting()
    {
        var sku = "99000008";
        var customerId = await SeedAsync(sku);
        var factory = new XOptiApiFactory(fixture,
            new Dictionary<string, string?> { ["XOptiApi:PaymentTerminalMode"] = "simulated" });
        using var manager = new TestClient(factory);
        await manager.FetchCsrfTokenAsync();
        await manager.SignInAsync("manager", SeedData.Password);

        foreach (var (reference, expected) in new[]
                 {
                     ("SIM-DECL", "declined"),
                     ("SIM-TIME", "timed out"),
                 })
        {
            var response = await manager.PostAsync("/api/v1/sales/invoices",
                InvoiceBody(customerId, sku, method: "K", tender: 56m, reference: reference),
                idempotencyKey: "terminal-" + Guid.NewGuid().ToString("N"));
            Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
            Assert.Contains(expected, (await response.Content.ReadAsStringAsync()).ToLowerInvariant());
        }

        await using var verify = fixture.NewContext();
        Assert.Equal(10, (await verify.InventoryItems.SingleAsync(
            row => row.Sku == sku)).QtyTotalOnHand);
        Assert.False(await verify.TxHeaders.AnyAsync(row =>
            row.CustomerId == customerId && row.TxType == xOpti.Domain.Values.TransactionType.RetailInvoice));
    }

    [Fact]
    public async Task InvoiceAndRefund_ReplayOnDuplicateIdempotencyKey()
    {
        var sku = "99000009";
        var customerId = await SeedAsync(sku);
        var factory = new XOptiApiFactory(fixture);
        using var manager = new TestClient(factory);
        await manager.FetchCsrfTokenAsync();
        await manager.SignInAsync("manager", SeedData.Password);

        var body = InvoiceBody(customerId, sku, quantity: 1, tender: 56m);
        var key = "replay-" + Guid.NewGuid().ToString("N");
        var first = await ExpectAsync(await manager.PostAsync("/api/v1/sales/invoices", body, key),
            HttpStatusCode.Created, factory);
        var second = await ExpectAsync(await manager.PostAsync("/api/v1/sales/invoices", body, key),
            HttpStatusCode.Created, factory);
        Assert.Equal(first.GetProperty("txNumber").GetString(), second.GetProperty("txNumber").GetString());

        await using (var verify = fixture.NewContext())
        {
            Assert.Equal(9, (await verify.InventoryItems.SingleAsync(
                row => row.Sku == sku)).QtyTotalOnHand);
            Assert.Equal(1, await verify.TxHeaders.CountAsync(row =>
                row.CustomerId == customerId && row.TxType == xOpti.Domain.Values.TransactionType.RetailInvoice));
        }

        var refundBody = new
        {
            originalTxNumber = first.GetProperty("txNumber").GetString(),
            staffCode = "0007",
            reason = "replay refund",
            lines = new[] { new { originalRowNo = 1, quantity = 1, restock = false } },
            replacements = Array.Empty<object>(),
            refundTenders = new[] { RefundTender(56m) },
            saleTenders = Array.Empty<object>(),
        };
        var refundKey = "replay-refund-" + Guid.NewGuid().ToString("N");
        var refund1 = await ExpectAsync(await manager.PostAsync("/api/v1/sales/refunds", refundBody, refundKey),
            HttpStatusCode.Created, factory);
        var refund2 = await ExpectAsync(await manager.PostAsync("/api/v1/sales/refunds", refundBody, refundKey),
            HttpStatusCode.Created, factory);
        Assert.Equal(refund1.GetProperty("txNumber").GetString(), refund2.GetProperty("txNumber").GetString());

        await using var final = fixture.NewContext();
        Assert.Equal(1, await final.TxHeaders.CountAsync(row =>
            row.TxType == xOpti.Domain.Values.TransactionType.RetailRefund && row.CustomerId == customerId));
    }

    [Fact]
    public async Task OrderDeposit_IsIdempotent_AndRequiresCardReference()
    {
        var sku = "99000010";
        var customerId = await SeedAsync(sku);
        var factory = new XOptiApiFactory(fixture);
        using var manager = new TestClient(factory);
        await manager.FetchCsrfTokenAsync();
        await manager.SignInAsync("manager", SeedData.Password);

        var order = await ExpectAsync(await manager.PostAsync("/api/v1/sales/orders", new
        {
            customerId,
            staffCode = "0007",
            depositAmount = 20m,
            reason = "deposit order",
            lines = new[] { new { sku, quantity = 2, unitAmount = 50m, discountAmount = 0m, taxCode = "B" } },
        }, idempotencyKey: "deposit-order-" + Guid.NewGuid().ToString("N")),
            HttpStatusCode.Created, factory);
        var orderNumber = order.GetProperty("txNumber").GetString()!;

        var noReference = await manager.PostAsync($"/api/v1/sales/orders/{orderNumber}/deposits", new
        {
            amount = 10m, method = "K", reference = (string?)null, reason = "card deposit",
        }, idempotencyKey: "deposit-card-" + Guid.NewGuid().ToString("N"));
        Assert.Equal(HttpStatusCode.BadRequest, noReference.StatusCode);

        var key = "deposit-replay-" + Guid.NewGuid().ToString("N");
        var body = new { amount = 10m, method = "C", reference = (string?)null, reason = "cash deposit" };
        var first = await ExpectAsync(await manager.PostAsync(
            $"/api/v1/sales/orders/{orderNumber}/deposits", body, key), HttpStatusCode.OK, factory);
        var second = await ExpectAsync(await manager.PostAsync(
            $"/api/v1/sales/orders/{orderNumber}/deposits", body, key), HttpStatusCode.OK, factory);
        Assert.Equal(30m, first.GetProperty("paid").GetDecimal());
        Assert.Equal(30m, second.GetProperty("paid").GetDecimal());
        Assert.Equal(82m, second.GetProperty("balance").GetDecimal());

        await using var verify = fixture.NewContext();
        Assert.Equal(2, await verify.TxPayments.CountAsync(row => row.TxNumber == orderNumber));
        Assert.True(await verify.AuditLogs.AnyAsync(row =>
            row.Action == "order.deposit" && row.EntityId == orderNumber));
    }

    [Fact]
    public async Task RefundTender_CannotExceedTheOriginalPaymentBalance()
    {
        var sku = "99000011";
        var customerId = await SeedAsync(sku);
        var factory = new XOptiApiFactory(fixture);
        using var manager = new TestClient(factory);
        await manager.FetchCsrfTokenAsync();
        await manager.SignInAsync("manager", SeedData.Password);

        var sale = await ExpectAsync(await manager.PostAsync("/api/v1/sales/invoices", new
        {
            customerId,
            staffCode = "0007",
            reason = "split sale for tender limit",
            lines = new[] { new { sku, quantity = 1, unitAmount = 50m, discountAmount = 0m, taxCode = "B" } },
            tenders = new[]
            {
                new { method = "C", amount = 30m, reference = (string?)null },
                new { method = "K", amount = 26m, reference = "AUTH-LIMIT" },
            },
        }, idempotencyKey: "tender-limit-sale-" + Guid.NewGuid().ToString("N")),
            HttpStatusCode.Created, factory);
        var invoiceNumber = sale.GetProperty("txNumber").GetString()!;

        var response = await manager.PostAsync("/api/v1/sales/refunds", new
        {
            originalTxNumber = invoiceNumber,
            staffCode = "0007",
            reason = "tender over limit",
            lines = new[] { new { originalRowNo = 1, quantity = 1, restock = false } },
            replacements = Array.Empty<object>(),
            refundTenders = new[] { RefundTender(56m) },
            saleTenders = Array.Empty<object>(),
        }, idempotencyKey: "tender-limit-" + Guid.NewGuid().ToString("N"));
        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
        Assert.Contains("remains refundable", await response.Content.ReadAsStringAsync());

        await using var verify = fixture.NewContext();
        Assert.False(await verify.TxHeaders.AnyAsync(row =>
            row.TxType == xOpti.Domain.Values.TransactionType.RetailRefund
            && row.TrackingNumber == invoiceNumber));
    }

    [Fact]
    public async Task Reprint_MarksDuplicate_AuditsActorTerminalAndTime_AndDoesNotMutateTheDocument()
    {
        var sku = "99000014";
        var customerId = await SeedAsync(sku);
        var factory = new XOptiApiFactory(fixture);
        using var manager = new TestClient(factory);
        await manager.FetchCsrfTokenAsync();
        await manager.SignInAsync("manager", SeedData.Password);

        var sale = await ExpectAsync(await manager.PostAsync("/api/v1/sales/invoices",
            InvoiceBody(customerId, sku, quantity: 1, tender: 56m),
            idempotencyKey: "print-sale-" + Guid.NewGuid().ToString("N")),
            HttpStatusCode.Created, factory);
        var invoiceNumber = sale.GetProperty("txNumber").GetString()!;

        var firstPrint = await manager.PostAsync($"/api/v1/sales/documents/{invoiceNumber}/prints", new
        {
            reprint = false, format = "receipt", terminalCode = "01", reason = "print receipt",
        });
        Assert.Equal(HttpStatusCode.OK, firstPrint.StatusCode);
        Assert.Equal("application/pdf", firstPrint.Content.Headers.ContentType?.MediaType);
        Assert.Equal("%PDF", System.Text.Encoding.ASCII.GetString(
            (await firstPrint.Content.ReadAsByteArrayAsync())[..4]));

        var reprint = await manager.PostAsync($"/api/v1/sales/documents/{invoiceNumber}/prints", new
        {
            reprint = true, format = "receipt", terminalCode = "01", reason = "customer copy",
        });
        Assert.Equal(HttpStatusCode.OK, reprint.StatusCode);
        Assert.Contains("-duplicate.pdf",
            reprint.Content.Headers.ContentDisposition?.FileName ?? string.Empty);
        Assert.Equal("%PDF", System.Text.Encoding.ASCII.GetString(
            (await reprint.Content.ReadAsByteArrayAsync())[..4]));

        await using (var verify = fixture.NewContext())
        {
            var audit = await verify.AuditLogs.SingleAsync(row =>
                row.Action == "document.reprint" && row.EntityId == invoiceNumber);
            Assert.NotNull(audit.ActorUserId);
            Assert.NotNull(audit.ActorBranch);
            Assert.Contains("\"terminal\":\"01\"", audit.Details);
            Assert.NotNull(audit.OccurredAt);
        }

        var claim = await manager.PostAsync($"/api/v1/sales/documents/{invoiceNumber}/prints", new
        {
            reprint = false, format = "claim", terminalCode = "01", reason = "claim form",
        });
        Assert.Equal(HttpStatusCode.BadRequest, claim.StatusCode);
        Assert.Contains("claim layouts are not approved", await claim.Content.ReadAsStringAsync());

        var unchanged = await ExpectAsync(
            await manager.GetAsync($"/api/v1/sales/documents/{invoiceNumber}"),
            HttpStatusCode.OK, factory);
        Assert.Equal(56m, unchanged.GetProperty("totalAmount").GetDecimal());
        Assert.Equal(invoiceNumber, unchanged.GetProperty("txNumber").GetString());
    }
}
