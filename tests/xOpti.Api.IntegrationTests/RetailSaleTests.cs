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
        decimal discount = 0m, string method = "C", decimal? tender = null) => new
    {
        customerId,
        staffCode = "0007",
        reason = "retail sale test",
        lines = new[] { new { sku, quantity, unitAmount, discountAmount = discount, taxCode = "B" } },
        tenders = new[] { new { method, amount = tender ?? unitAmount * quantity, reference = (string?)null } },
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
            InvoiceBody(customerId, sku, method: "K", tender: 100m),
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
}
