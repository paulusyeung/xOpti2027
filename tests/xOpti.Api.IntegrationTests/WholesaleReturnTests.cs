using System.Net;
using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using xOpti.Api.IntegrationTests.Support;
using xOpti.Domain.Values;
using xOpti.Infrastructure.Persistence.Entities;

namespace xOpti.Api.IntegrationTests;

[Collection("api")]
public sealed class WholesaleReturnTests(ApiPostgresFixture fixture)
{
    private static async Task<JsonElement> BodyAsync(HttpResponseMessage response,
        XOptiApiFactory factory, HttpStatusCode expected)
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

    private async Task<(int CustomerId, string Sku1, string Sku2)> SeedAsync()
    {
        var customerId = Random.Shared.Next(992000, 992999);
        var sku1 = "WR" + Random.Shared.Next(10000000, 99999999);
        var sku2 = "WR" + Random.Shared.Next(10000000, 99999999);
        await using var seed = fixture.NewContext();
        seed.Customers.Add(new Customer
        {
            Id = customerId, FullName = "Wholesale Return Customer",
            PaymentTerms = "NET30",
        });
        seed.WholesaleAccounts.Add(new WholesaleAccount
        {
            CustomerId = customerId, IsWholesale = true, PriceGrade = "A",
            TermsCode = "NET30", TermsDays = 30, CreditLimit = Money.From(50000m),
            TaxTreatment = "GST", CreatedAt = DateTimeOffset.UtcNow,
        });
        await seed.Database.ExecuteSqlInterpolatedAsync($"""
            INSERT INTO public.preference (serial_number, number_of_user, platform, product_name,
                user_name, owner_name, branch_number, pst_number, gst_number, tax_a_rate, tax_b_rate,
                next_invt_control_number, next_invt_sku, next_invoice_number, next_sales_order_number)
            VALUES ('0000000001', 1, 'xOpti', 'Synergy', 'Operator', 'Owner', '0001', '', '', 5, 7,
                1000, 1, 1, 1)
            ON CONFLICT (serial_number) DO UPDATE SET tax_a_rate = 5, tax_b_rate = 7;
            """);
        foreach (var sku in new[] { sku1, sku2 })
        {
            seed.InventoryItems.Add(new Inventory
            {
                Sku = sku, DepartmentCode = "09", ClassCode = "09", CategoryCode = "09",
                SupplierCode = "0001", BrandCode = "0001", Name = "Return item",
                QtyTotalOnHand = 25, AverageCost = Money.From(5m),
                InventoryLotFlag = true, RetailPriceFlag = true,
            });
            seed.BranchInventory.Add(new BranchInventory
            {
                BranchCode = "01", Sku = sku, QtyOnHand = 25,
            });
        }
        await seed.SaveChangesAsync();
        return (customerId, sku1, sku2);
    }

    private static async Task<string> CreatePostedInvoiceAsync(TestClient manager,
        XOptiApiFactory factory, int customerId, string sku1, string sku2)
    {
        await BodyAsync(await manager.PostAsync("/api/v1/wholesale/price-lists", new
        {
            input = new
            {
                code = "A", name = "Return list",
                items = new[]
                {
                    new { sku = sku1, price = 10.0000m },
                    new { sku = sku2, price = 15.0000m },
                },
            },
            reason = "seed return prices",
        }), factory, HttpStatusCode.OK);
        var created = await BodyAsync(await manager.PostAsync("/api/v1/wholesale/invoices", new
        {
            customerId,
            staffCode = "0007",
            lines = new[]
            {
                new { sku = sku1, quantity = 2, unitAmount = 10.0000m, discountAmount = 0m,
                    taxCode = "B", overrideReason = (string?)null, description = "return item",
                    backorderQuantity = 0 },
                new { sku = sku2, quantity = 1, unitAmount = 15.0000m, discountAmount = 0m,
                    taxCode = "B", overrideReason = (string?)null, description = "return item",
                    backorderQuantity = 0 },
            },
            tenders = Array.Empty<object>(),
            shipping = new
            {
                shippingMethod = "Courier", shipToName = "Dock", shipToAddress = "1 Way",
                shippingInstructions = (string?)null, purchaseOrderNumber = (string?)null,
                dueDate = (string?)null,
            },
            reason = "return test invoice",
        }, idempotencyKey: "wr-invoice-" + Guid.NewGuid().ToString("N")),
            factory, HttpStatusCode.Created);
        var txNumber = created.GetProperty("txNumber").GetString()!;
        await BodyAsync(await manager.PostAsync(
            $"/api/v1/wholesale/invoices/{txNumber}/post", new
            {
                tenders = new[] { new { method = "C", amount = 39.2000m, reference = (string?)null } },
                reason = "post return test invoice",
            }, idempotencyKey: "wr-invoice-post-" + Guid.NewGuid().ToString("N")),
            factory, HttpStatusCode.OK);
        return txNumber;
    }

    private static object ReturnBody(string invoiceNumber, int quantity, bool restock = true,
        string? dispositionReason = null, int originalRowNo = 1) => new
    {
        originalInvoiceNumber = invoiceNumber,
        staffCode = "0007",
        lines = new[] { new { originalRowNo, quantity, restock, dispositionReason } },
        tenders = Array.Empty<object>(),
        reason = "wholesale return create",
    };

    private static async Task<string> CreateReturnDraftAsync(TestClient manager,
        XOptiApiFactory factory, string invoice, int quantity = 1, string? sku = null)
    {
        var created = await BodyAsync(await manager.PostAsync("/api/v1/wholesale/returns",
            ReturnBody(invoice, quantity),
            idempotencyKey: "wr-draft-" + Guid.NewGuid().ToString("N")),
            factory, HttpStatusCode.Created);
        _ = sku;
        return created.GetProperty("txNumber").GetString()!;
    }

    [Fact]
    public async Task PostReturn_RestocksInventoryRecordsRefundAndReplaysIdempotently()
    {
        var (customerId, sku1, sku2) = await SeedAsync();
        var factory = new XOptiApiFactory(fixture);
        using var manager = new TestClient(factory);
        await manager.FetchCsrfTokenAsync();
        await manager.SignInAsync("manager", SeedData.Password);
        var invoice = await CreatePostedInvoiceAsync(manager, factory, customerId, sku1, sku2);
        var returnNumber = await CreateReturnDraftAsync(manager, factory, invoice, 1);

        var key = "wr-post-" + Guid.NewGuid().ToString("N");
        var posted = await BodyAsync(await manager.PostAsync(
            $"/api/v1/wholesale/returns/{returnNumber}/post", new
            {
                tenders = new[] { new { method = "C", amount = 11.2000m, reference = (string?)null } },
                reason = "post wholesale return",
            }, idempotencyKey: key), factory, HttpStatusCode.OK);
        Assert.Equal("posted", posted.GetProperty("status").GetString());
        Assert.Equal(11.2000m, posted.GetProperty("refunded").GetDecimal());
        Assert.Equal(invoice, posted.GetProperty("originalInvoiceNumber").GetString());

        await using (var verify = fixture.NewContext())
        {
            var header = await verify.TxHeaders.SingleAsync(row => row.TxNumber == returnNumber);
            Assert.Equal(8, header.ControlNumber.Length);
            Assert.Equal(-11.2000m, header.ThisPaid.Amount);
            Assert.Equal(24, (await verify.InventoryItems.SingleAsync(row =>
                row.Sku == sku1)).QtyTotalOnHand);
            Assert.Equal(24, (await verify.BranchInventory.SingleAsync(row =>
                row.BranchCode == "01" && row.Sku == sku1)).QtyOnHand);
            var payment = await verify.TxPayments.SingleAsync(row =>
                row.TxNumber == returnNumber);
            Assert.Equal(-11.2000m, payment.TotalThisPay.Amount);
            Assert.Equal("posted", (await verify.WholesaleDocuments.SingleAsync(row =>
                row.TxNumber == returnNumber)).Status);
            Assert.True(await verify.AuditLogs.AnyAsync(row =>
                row.Action == "wholesale.return.post" && row.EntityId == returnNumber));
        }

        var replay = await BodyAsync(await manager.PostAsync(
            $"/api/v1/wholesale/returns/{returnNumber}/post", new
            {
                tenders = new[] { new { method = "C", amount = 11.2000m, reference = (string?)null } },
                reason = "post wholesale return",
            }, idempotencyKey: key), factory, HttpStatusCode.OK);
        Assert.Equal(returnNumber, replay.GetProperty("txNumber").GetString());

        await using (var verify = fixture.NewContext())
        {
            Assert.Equal(24, (await verify.InventoryItems.SingleAsync(row =>
                row.Sku == sku1)).QtyTotalOnHand);
            Assert.Equal(1, await verify.TxPayments.CountAsync(row =>
                row.TxNumber == returnNumber));
        }

        var twice = await manager.PostAsync($"/api/v1/wholesale/returns/{returnNumber}/post", new
        {
            tenders = Array.Empty<object>(),
            reason = "post twice",
        }, idempotencyKey: "wr-twice-" + Guid.NewGuid().ToString("N"));
        Assert.Equal(HttpStatusCode.BadRequest, twice.StatusCode);
    }

    [Fact]
    public async Task ReturnReprint_IsAuditedAndPreservesCredit()
    {
        var (customerId, sku1, sku2) = await SeedAsync();
        var factory = new XOptiApiFactory(fixture);
        using var manager = new TestClient(factory);
        await manager.FetchCsrfTokenAsync();
        await manager.SignInAsync("manager", SeedData.Password);
        var invoice = await CreatePostedInvoiceAsync(manager, factory, customerId, sku1, sku2);
        var returnNumber = await CreateReturnDraftAsync(manager, factory, invoice, 1);
        await BodyAsync(await manager.PostAsync(
            $"/api/v1/wholesale/returns/{returnNumber}/post", new
            {
                tenders = new[] { new { method = "C", amount = 11.2000m, reference = (string?)null } },
                reason = "post before reprint",
            }, idempotencyKey: "wr-reprint-post-" + Guid.NewGuid().ToString("N")),
            factory, HttpStatusCode.OK);

        var render = await BodyAsync(await manager.GetAsync(
            $"/api/v1/wholesale/returns/{returnNumber}/render"), factory, HttpStatusCode.OK);
        Assert.False(render.GetProperty("duplicate").GetBoolean());
        Assert.Equal(-11.2000m,
            render.GetProperty("return").GetProperty("totalAmount").GetDecimal());

        var print = await manager.PostAsync($"/api/v1/wholesale/returns/{returnNumber}/prints", new
        {
            reprint = true, terminalCode = "01", reason = "customer duplicate",
        });
        Assert.Equal(HttpStatusCode.OK, print.StatusCode);
        Assert.Contains("-duplicate.pdf",
            print.Content.Headers.ContentDisposition?.FileName ?? string.Empty);
        Assert.Equal("%PDF", System.Text.Encoding.ASCII.GetString(
            (await print.Content.ReadAsByteArrayAsync())[..4]));

        await using var verify = fixture.NewContext();
        Assert.True(await verify.AuditLogs.AnyAsync(row =>
            row.Action == "wholesale.return.reprint" && row.EntityId == returnNumber));
    }

    [Fact]
    public async Task WriteOffDisposition_LeavesInventoryAndCreditsCustomerAudibly()
    {
        var (customerId, sku1, sku2) = await SeedAsync();
        var factory = new XOptiApiFactory(fixture);
        using var manager = new TestClient(factory);
        await manager.FetchCsrfTokenAsync();
        await manager.SignInAsync("manager", SeedData.Password);
        var invoice = await CreatePostedInvoiceAsync(manager, factory, customerId, sku1, sku2);

        var draft = await BodyAsync(await manager.PostAsync("/api/v1/wholesale/returns", new
        {
            originalInvoiceNumber = invoice,
            staffCode = "0007",
            lines = new[]
            {
                new { originalRowNo = 1, quantity = 1, restock = false,
                    dispositionReason = "damaged in transit" },
            },
            tenders = Array.Empty<object>(),
            reason = "write-off return draft",
        }, idempotencyKey: "wr-writeoff-draft-" + Guid.NewGuid().ToString("N")),
            factory, HttpStatusCode.Created);
        var returnNumber = draft.GetProperty("txNumber").GetString()!;
        Assert.False(draft.GetProperty("lines").EnumerateArray().Single()
            .GetProperty("restock").GetBoolean());

        var posted = await BodyAsync(await manager.PostAsync(
            $"/api/v1/wholesale/returns/{returnNumber}/post", new
            {
                tenders = new[] { new { method = "C", amount = 11.2000m, reference = (string?)null } },
                reason = "post write-off",
            }, idempotencyKey: "wr-writeoff-post-" + Guid.NewGuid().ToString("N")),
            factory, HttpStatusCode.OK);
        Assert.Equal(-11.2000m, posted.GetProperty("totalAmount").GetDecimal());
        Assert.Equal(11.2000m, posted.GetProperty("refunded").GetDecimal());

        await using var verify = fixture.NewContext();
        Assert.Equal(23, (await verify.InventoryItems.SingleAsync(row =>
            row.Sku == sku1)).QtyTotalOnHand);
        Assert.Equal(23, (await verify.BranchInventory.SingleAsync(row =>
            row.BranchCode == "01" && row.Sku == sku1)).QtyOnHand);
        Assert.False(await verify.LotRecords.AnyAsync(row =>
            row.Sku == sku1 && row.LotNo.StartsWith("RS")));
        Assert.Equal(1, await verify.TxPayments.CountAsync(row =>
            row.TxNumber == returnNumber));
        var audit = await verify.AuditLogs.SingleAsync(row =>
            row.Action == "wholesale.return.post" && row.EntityId == returnNumber);
        Assert.Contains("damaged in transit", audit.Details);
        Assert.Contains("\"Restock\":false", audit.Details);
    }

    [Fact]
    public async Task ForcedFailureDuringReturnPosting_RollsBackRestockControlAndPayments()
    {
        var (customerId, sku1, sku2) = await SeedAsync();
        var factory = new XOptiApiFactory(fixture);
        using var manager = new TestClient(factory);
        await manager.FetchCsrfTokenAsync();
        await manager.SignInAsync("manager", SeedData.Password);
        var invoice = await CreatePostedInvoiceAsync(manager, factory, customerId, sku1, sku2);

        var draft = await BodyAsync(await manager.PostAsync("/api/v1/wholesale/returns", new
        {
            originalInvoiceNumber = invoice,
            staffCode = "0007",
            lines = new[]
            {
                new { originalRowNo = 1, quantity = 1, restock = true,
                    dispositionReason = (string?)null },
                new { originalRowNo = 2, quantity = 1, restock = true,
                    dispositionReason = (string?)null },
            },
            tenders = Array.Empty<object>(),
            reason = "two-line return draft",
        }, idempotencyKey: "wr-fail-draft-" + Guid.NewGuid().ToString("N")),
            factory, HttpStatusCode.Created);
        var returnNumber = draft.GetProperty("txNumber").GetString()!;

        int counterBefore;
        await using (var before = fixture.NewContext())
        {
            counterBefore = (await before.PrefTxNumbers.SingleAsync(row =>
                row.TxPrefix == "WR")).TxNextNumber;
            await before.BranchInventory.Where(row => row.Sku == sku2).ExecuteDeleteAsync();
            await before.InventoryItems.Where(row => row.Sku == sku2).ExecuteDeleteAsync();
        }

        var failed = await manager.PostAsync($"/api/v1/wholesale/returns/{returnNumber}/post", new
        {
            tenders = new[] { new { method = "C", amount = 5.0000m, reference = (string?)null } },
            reason = "forced return failure",
        }, idempotencyKey: "wr-fail-post-" + Guid.NewGuid().ToString("N"));
        Assert.Equal(HttpStatusCode.InternalServerError, failed.StatusCode);

        await using var verify = fixture.NewContext();
        Assert.Equal(counterBefore, (await verify.PrefTxNumbers.SingleAsync(row =>
            row.TxPrefix == "WR")).TxNextNumber);
        Assert.Equal(23, (await verify.InventoryItems.SingleAsync(row =>
            row.Sku == sku1)).QtyTotalOnHand);
        Assert.Equal(23, (await verify.BranchInventory.SingleAsync(row =>
            row.BranchCode == "01" && row.Sku == sku1)).QtyOnHand);
        Assert.Equal(0, await verify.TxPayments.CountAsync(row =>
            row.TxNumber == returnNumber));
        Assert.Equal(string.Empty, (await verify.TxHeaders.SingleAsync(row =>
            row.TxNumber == returnNumber)).ControlNumber);
        Assert.Equal("draft", (await verify.WholesaleDocuments.SingleAsync(row =>
            row.TxNumber == returnNumber)).Status);
        Assert.False(await verify.AuditLogs.AnyAsync(row =>
            row.Action == "wholesale.return.post" && row.EntityId == returnNumber));
    }

    [Fact]
    public async Task CreateAndUpdateReturn_GuardsQuantityAndAmountAndTracksDisposition()
    {
        var (customerId, sku1, sku2) = await SeedAsync();
        var factory = new XOptiApiFactory(fixture);
        using var manager = new TestClient(factory);
        await manager.FetchCsrfTokenAsync();
        await manager.SignInAsync("manager", SeedData.Password);
        var invoice = await CreatePostedInvoiceAsync(manager, factory, customerId, sku1, sku2);

        var returnable = await BodyAsync(await manager.GetAsync(
            $"/api/v1/wholesale/invoices/{invoice}/returnable"), factory, HttpStatusCode.OK);
        var line = returnable.GetProperty("lines").EnumerateArray()
            .Single(row => row.GetProperty("sku").GetString() == sku1);
        Assert.Equal(2, line.GetProperty("originalQuantity").GetInt32());
        Assert.Equal(2, line.GetProperty("availableQuantity").GetInt32());
        Assert.Equal(22.4000m, line.GetProperty("availableAmount").GetDecimal());

        var created = await BodyAsync(await manager.PostAsync("/api/v1/wholesale/returns",
            ReturnBody(invoice, 1),
            idempotencyKey: "wr-create-" + Guid.NewGuid().ToString("N")),
            factory, HttpStatusCode.Created);
        var txNumber = created.GetProperty("txNumber").GetString()!;
        Assert.StartsWith("WR", txNumber);
        Assert.Equal("draft", created.GetProperty("status").GetString());
        Assert.Equal(-11.2000m, created.GetProperty("totalAmount").GetDecimal());
        var returnLine = created.GetProperty("lines").EnumerateArray().Single();
        Assert.Equal(-10.0000m, returnLine.GetProperty("amount").GetDecimal());
        Assert.Equal(-0.5000m, returnLine.GetProperty("taxA").GetDecimal());
        Assert.Equal(-0.7000m, returnLine.GetProperty("taxB").GetDecimal());
        Assert.True(returnLine.GetProperty("restock").GetBoolean());

        var over = await manager.PostAsync("/api/v1/wholesale/returns",
            ReturnBody(invoice, 2),
            idempotencyKey: "wr-over-" + Guid.NewGuid().ToString("N"));
        Assert.Equal(HttpStatusCode.BadRequest, over.StatusCode);
        Assert.Contains("only 1", await over.Content.ReadAsStringAsync());

        var updated = await BodyAsync(await manager.PutAsync(
            $"/api/v1/wholesale/returns/{txNumber}", new
            {
                originalInvoiceNumber = invoice,
                staffCode = "0007",
                lines = new[] { new { originalRowNo = 1, quantity = 2, restock = false,
                    dispositionReason = "damaged in transit" } },
                tenders = Array.Empty<object>(),
                reason = "return updated to full quantity",
            }), factory, HttpStatusCode.OK);
        Assert.Equal(-22.4000m, updated.GetProperty("totalAmount").GetDecimal());
        Assert.False(updated.GetProperty("lines").EnumerateArray().Single()
            .GetProperty("restock").GetBoolean());
        Assert.Equal("damaged in transit", updated.GetProperty("lines").EnumerateArray().Single()
            .GetProperty("dispositionReason").GetString());

        var exhausted = await manager.PostAsync("/api/v1/wholesale/returns",
            ReturnBody(invoice, 1),
            idempotencyKey: "wr-exhausted-" + Guid.NewGuid().ToString("N"));
        Assert.Equal(HttpStatusCode.BadRequest, exhausted.StatusCode);
        Assert.Contains("only 0", await exhausted.Content.ReadAsStringAsync());

        var noReason = await manager.PostAsync("/api/v1/wholesale/returns",
            ReturnBody(invoice, 1, restock: false, originalRowNo: 2),
            idempotencyKey: "wr-no-reason-" + Guid.NewGuid().ToString("N"));
        Assert.Equal(HttpStatusCode.BadRequest, noReason.StatusCode);
        Assert.Contains("reason", await noReason.Content.ReadAsStringAsync(),
            StringComparison.OrdinalIgnoreCase);

        await using var verify = fixture.NewContext();
        Assert.True(await verify.TxHeaders.AnyAsync(row =>
            row.TxNumber == txNumber && row.TxType == TransactionType.WholesaleReturn));
        Assert.Single(await verify.WholesaleReturnLines.Where(row =>
            row.ReturnTxNumber == txNumber).ToListAsync());
        Assert.True(await verify.AuditLogs.AnyAsync(row =>
            row.Action == "wholesale.return.create" && row.EntityId == txNumber));
        Assert.True(await verify.AuditLogs.AnyAsync(row =>
            row.Action == "wholesale.return.update" && row.EntityId == txNumber));
    }
}
