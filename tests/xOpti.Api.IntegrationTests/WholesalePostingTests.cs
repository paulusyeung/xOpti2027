using System.Net;
using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using xOpti.Api.IntegrationTests.Support;
using xOpti.Domain.Values;
using xOpti.Infrastructure.Persistence.Entities;

namespace xOpti.Api.IntegrationTests;

[Collection("api")]
public sealed class WholesalePostingTests(ApiPostgresFixture fixture)
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
        var customerId = Random.Shared.Next(980000, 989999);
        var sku1 = "WP" + Random.Shared.Next(10000000, 99999999);
        var sku2 = "WP" + Random.Shared.Next(10000000, 99999999);
        await using var seed = fixture.NewContext();
        seed.Customers.Add(new Customer
        {
            Id = customerId, FullName = "Wholesale Posting Customer",
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
                SupplierCode = "0001", BrandCode = "0001", Name = "Wholesale posting item",
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

    private static async Task<string> CreateDraftAsync(TestClient manager,
        XOptiApiFactory factory, int customerId, string sku1, string sku2)
    {
        await BodyAsync(await manager.PostAsync("/api/v1/wholesale/price-lists", new
        {
            input = new
            {
                code = "A",
                name = "Wholesale posting list",
                items = new[]
                {
                    new { sku = sku1, price = 10.0000m },
                    new { sku = sku2, price = 15.0000m },
                },
            },
            reason = "seed posting prices",
        }), factory, HttpStatusCode.OK);
        var created = await BodyAsync(await manager.PostAsync("/api/v1/wholesale/invoices", new
        {
            customerId,
            staffCode = "0007",
            lines = new[]
            {
                new { sku = sku1, quantity = 2, unitAmount = 10.0000m, discountAmount = 0m,
                    taxCode = "B", overrideReason = (string?)null, description = "posting item" },
                new { sku = sku2, quantity = 1, unitAmount = 15.0000m, discountAmount = 0m,
                    taxCode = "B", overrideReason = (string?)null, description = "posting item" },
            },
            tenders = Array.Empty<object>(),
            shipping = new
            {
                shippingMethod = "Courier", shipToName = "Dock", shipToAddress = "1 Way",
                shippingInstructions = (string?)null, purchaseOrderNumber = "PO-2",
                dueDate = (string?)null,
            },
            reason = "posting draft",
        }, idempotencyKey: "wc-post-draft-" + Guid.NewGuid().ToString("N")),
            factory, HttpStatusCode.Created);
        return created.GetProperty("txNumber").GetString()!;
    }

    [Fact]
    public async Task PostInvoice_IssuesInventoryRecordsPaymentsAndReplaysIdempotently()
    {
        var (customerId, sku1, sku2) = await SeedAsync();
        var factory = new XOptiApiFactory(fixture);
        using var manager = new TestClient(factory);
        await manager.FetchCsrfTokenAsync();
        await manager.SignInAsync("manager", SeedData.Password);
        var txNumber = await CreateDraftAsync(manager, factory, customerId, sku1, sku2);

        var key = "wc-post-" + Guid.NewGuid().ToString("N");
        var posted = await BodyAsync(await manager.PostAsync(
            $"/api/v1/wholesale/invoices/{txNumber}/post", new
            {
                tenders = new[] { new { method = "C", amount = 39.2000m, reference = (string?)null } },
                reason = "post wholesale invoice",
            }, idempotencyKey: key), factory, HttpStatusCode.OK);
        Assert.Equal("posted", posted.GetProperty("status").GetString());
        Assert.Equal(39.2000m, posted.GetProperty("paid").GetDecimal());
        Assert.NotNull(posted.GetProperty("postedAt").GetString());

        await using (var verify = fixture.NewContext())
        {
            var header = await verify.TxHeaders.SingleAsync(row => row.TxNumber == txNumber);
            Assert.False(string.IsNullOrWhiteSpace(header.ControlNumber));
            Assert.Equal(8, header.ControlNumber.Length);
            Assert.Equal(39.2000m, header.ThisPaid.Amount);
            var lines = await verify.TxDetails.Where(row => row.TxNumber == txNumber)
                .OrderBy(row => row.RowNo).ToListAsync();
            Assert.All(lines, row => Assert.Equal(header.ControlNumber, row.ControlNumber));
            Assert.All(lines, row => Assert.Equal(5.0000m, row.UnitCost.Amount));
            Assert.Equal(1, await verify.TxPayments.CountAsync(row => row.TxNumber == txNumber));
            Assert.Equal(23, (await verify.InventoryItems.SingleAsync(row => row.Sku == sku1))
                .QtyTotalOnHand);
            Assert.Equal(24, (await verify.InventoryItems.SingleAsync(row => row.Sku == sku2))
                .QtyTotalOnHand);
            Assert.Equal(23, (await verify.BranchInventory.SingleAsync(row =>
                row.BranchCode == "01" && row.Sku == sku1)).QtyOnHand);
            Assert.Equal("posted", (await verify.WholesaleDocuments.SingleAsync(row =>
                row.TxNumber == txNumber)).Status);
            Assert.True(await verify.AuditLogs.AnyAsync(row =>
                row.Action == "wholesale.invoice.post" && row.EntityId == txNumber));
        }

        var replay = await BodyAsync(await manager.PostAsync(
            $"/api/v1/wholesale/invoices/{txNumber}/post", new
            {
                tenders = new[] { new { method = "C", amount = 39.2000m, reference = (string?)null } },
                reason = "post wholesale invoice",
            }, idempotencyKey: key), factory, HttpStatusCode.OK);
        Assert.Equal(txNumber, replay.GetProperty("txNumber").GetString());

        await using (var verify = fixture.NewContext())
        {
            Assert.Equal(23, (await verify.InventoryItems.SingleAsync(row => row.Sku == sku1))
                .QtyTotalOnHand);
            Assert.Equal(1, await verify.TxPayments.CountAsync(row => row.TxNumber == txNumber));
        }

        var second = await manager.PostAsync($"/api/v1/wholesale/invoices/{txNumber}/post", new
        {
            tenders = Array.Empty<object>(),
            reason = "post twice",
        }, idempotencyKey: "wc-post-twice-" + Guid.NewGuid().ToString("N"));
        Assert.Equal(HttpStatusCode.BadRequest, second.StatusCode);
    }

    [Fact]
    public async Task Backorders_WhenEnabled_TrackRemainingQuantityAndOpenOnPosting()
    {
        var (customerId, sku1, _) = await SeedAsync();
        var factory = new XOptiApiFactory(fixture, new Dictionary<string, string?>
        {
            ["XOptiApi:WholesaleBackordersEnabled"] = "true",
        });
        using var manager = new TestClient(factory);
        await manager.FetchCsrfTokenAsync();
        await manager.SignInAsync("manager", SeedData.Password);
        await BodyAsync(await manager.PostAsync("/api/v1/wholesale/price-lists", new
        {
            input = new
            {
                code = "A", name = "Backorder list",
                items = new[] { new { sku = sku1, price = 10.0000m } },
            },
            reason = "seed backorder price",
        }), factory, HttpStatusCode.OK);

        var created = await BodyAsync(await manager.PostAsync("/api/v1/wholesale/invoices", new
        {
            customerId,
            staffCode = "0007",
            lines = new[]
            {
                new { sku = sku1, quantity = 1, unitAmount = 10.0000m, discountAmount = 0m,
                    taxCode = "B", overrideReason = (string?)null,
                    description = "partial shipment", backorderQuantity = 2 },
            },
            tenders = Array.Empty<object>(),
            shipping = new
            {
                shippingMethod = "Courier", shipToName = "Dock", shipToAddress = "1 Way",
                shippingInstructions = (string?)null, purchaseOrderNumber = (string?)null,
                dueDate = (string?)null,
            },
            reason = "partial shipment draft",
        }, idempotencyKey: "wc-backorder-" + Guid.NewGuid().ToString("N")),
            factory, HttpStatusCode.Created);
        var txNumber = created.GetProperty("txNumber").GetString()!;
        var line = created.GetProperty("lines").EnumerateArray().Single();
        Assert.Equal(1, line.GetProperty("quantity").GetInt32());
        Assert.Equal(2, line.GetProperty("backorderQuantity").GetInt32());
        Assert.Equal(10.0000m, created.GetProperty("totalSale").GetDecimal());
        Assert.Equal(11.2000m, created.GetProperty("totalAmount").GetDecimal());

        var draftBackorders = await BodyAsync(await manager.GetAsync(
            $"/api/v1/wholesale/invoices/{txNumber}/backorders"), factory, HttpStatusCode.OK);
        var draftRow = draftBackorders.EnumerateArray().Single();
        Assert.Equal(3, draftRow.GetProperty("orderedQuantity").GetInt32());
        Assert.Equal(2, draftRow.GetProperty("remainingQuantity").GetInt32());
        Assert.Equal("draft", draftRow.GetProperty("status").GetString());

        await BodyAsync(await manager.PostAsync(
            $"/api/v1/wholesale/invoices/{txNumber}/post", new
            {
                tenders = new[] { new { method = "C", amount = 11.2000m, reference = (string?)null } },
                reason = "post partial shipment",
            }, idempotencyKey: "wc-backorder-post-" + Guid.NewGuid().ToString("N")),
            factory, HttpStatusCode.OK);

        var postedBackorders = await BodyAsync(await manager.GetAsync(
            $"/api/v1/wholesale/invoices/{txNumber}/backorders"), factory, HttpStatusCode.OK);
        var postedRow = postedBackorders.EnumerateArray().Single();
        Assert.Equal("open", postedRow.GetProperty("status").GetString());
        Assert.Equal(2, postedRow.GetProperty("remainingQuantity").GetInt32());

        await using var verify = fixture.NewContext();
        Assert.Equal(24, (await verify.InventoryItems.SingleAsync(row =>
            row.Sku == sku1)).QtyTotalOnHand);
    }

    [Fact]
    public async Task Backorders_WhenDisabled_RejectPartialShipment()
    {
        var (customerId, sku1, _) = await SeedAsync();
        var factory = new XOptiApiFactory(fixture);
        using var manager = new TestClient(factory);
        await manager.FetchCsrfTokenAsync();
        await manager.SignInAsync("manager", SeedData.Password);
        await BodyAsync(await manager.PostAsync("/api/v1/wholesale/price-lists", new
        {
            input = new
            {
                code = "A", name = "No backorder list",
                items = new[] { new { sku = sku1, price = 10.0000m } },
            },
            reason = "seed no-backorder price",
        }), factory, HttpStatusCode.OK);

        var response = await manager.PostAsync("/api/v1/wholesale/invoices", new
        {
            customerId,
            staffCode = "0007",
            lines = new[]
            {
                new { sku = sku1, quantity = 1, unitAmount = 10.0000m, discountAmount = 0m,
                    taxCode = "B", overrideReason = (string?)null,
                    description = "partial", backorderQuantity = 2 },
            },
            tenders = Array.Empty<object>(),
            shipping = new
            {
                shippingMethod = "Courier", shipToName = "Dock", shipToAddress = "1 Way",
                shippingInstructions = (string?)null, purchaseOrderNumber = (string?)null,
                dueDate = (string?)null,
            },
            reason = "backorder disabled",
        }, idempotencyKey: "wc-backorder-off-" + Guid.NewGuid().ToString("N"));
        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
        Assert.Contains("disabled", await response.Content.ReadAsStringAsync());
    }

    [Fact]
    public async Task Reprint_PreservesOriginalPricesAndIsAudited()
    {
        var (customerId, sku1, sku2) = await SeedAsync();
        var factory = new XOptiApiFactory(fixture);
        using var manager = new TestClient(factory);
        await manager.FetchCsrfTokenAsync();
        await manager.SignInAsync("manager", SeedData.Password);
        var txNumber = await CreateDraftAsync(manager, factory, customerId, sku1, sku2);
        await BodyAsync(await manager.PostAsync(
            $"/api/v1/wholesale/invoices/{txNumber}/post", new
            {
                tenders = new[] { new { method = "C", amount = 39.2000m, reference = (string?)null } },
                reason = "post for reprint",
            }, idempotencyKey: "wc-reprint-post-" + Guid.NewGuid().ToString("N")),
            factory, HttpStatusCode.OK);

        await BodyAsync(await manager.PostAsync("/api/v1/wholesale/price-lists", new
        {
            input = new
            {
                code = "A",
                name = "Repriced wholesale list",
                items = new[]
                {
                    new { sku = sku1, price = 99.0000m },
                    new { sku = sku2, price = 99.0000m },
                },
            },
            reason = "reprice after posting",
        }), factory, HttpStatusCode.OK);

        var invoice = await BodyAsync(await manager.GetAsync(
            $"/api/v1/wholesale/invoices/{txNumber}"), factory, HttpStatusCode.OK);
        var firstLine = invoice.GetProperty("lines").EnumerateArray().First();
        Assert.Equal(10.0000m, firstLine.GetProperty("unitAmount").GetDecimal());
        Assert.Equal(10.0000m, firstLine.GetProperty("listUnitPrice").GetDecimal());

        var render = await BodyAsync(await manager.GetAsync(
            $"/api/v1/wholesale/invoices/{txNumber}/render"), factory, HttpStatusCode.OK);
        Assert.False(render.GetProperty("duplicate").GetBoolean());
        Assert.Equal(39.2000m, render.GetProperty("invoice").GetProperty("totalAmount").GetDecimal());

        var print = await manager.PostAsync($"/api/v1/wholesale/invoices/{txNumber}/prints", new
        {
            reprint = true, terminalCode = "01", reason = "customer requested duplicate",
        });
        Assert.Equal(HttpStatusCode.OK, print.StatusCode);
        Assert.Contains("-duplicate.pdf",
            print.Content.Headers.ContentDisposition?.FileName ?? string.Empty);
        Assert.Equal("%PDF", System.Text.Encoding.ASCII.GetString(
            (await print.Content.ReadAsByteArrayAsync())[..4]));

        var original = await manager.PostAsync($"/api/v1/wholesale/invoices/{txNumber}/prints", new
        {
            reprint = false, terminalCode = "01", reason = "original print",
        });
        Assert.Equal(HttpStatusCode.OK, original.StatusCode);

        await using var verify = fixture.NewContext();
        Assert.True(await verify.AuditLogs.AnyAsync(row =>
            row.Action == "wholesale.invoice.reprint" && row.EntityId == txNumber));
        Assert.True(await verify.AuditLogs.AnyAsync(row =>
            row.Action == "wholesale.invoice.print" && row.EntityId == txNumber));
    }

    [Fact]
    public async Task ForcedFailureDuringPosting_RollsBackInventoryControlNumberPaymentsAndStatus()
    {
        var (customerId, sku1, sku2) = await SeedAsync();
        var factory = new XOptiApiFactory(fixture);
        using var manager = new TestClient(factory);
        await manager.FetchCsrfTokenAsync();
        await manager.SignInAsync("manager", SeedData.Password);
        var txNumber = await CreateDraftAsync(manager, factory, customerId, sku1, sku2);

        int counterBefore;
        await using (var before = fixture.NewContext())
        {
            counterBefore = (await before.PrefTxNumbers.SingleAsync(row =>
                row.TxPrefix == "WC")).TxNextNumber;
            await before.BranchInventory.Where(row => row.Sku == sku2).ExecuteDeleteAsync();
            await before.InventoryItems.Where(row => row.Sku == sku2).ExecuteDeleteAsync();
        }

        var failed = await manager.PostAsync($"/api/v1/wholesale/invoices/{txNumber}/post", new
        {
            tenders = new[] { new { method = "C", amount = 10.0000m, reference = (string?)null } },
            reason = "forced failure",
        }, idempotencyKey: "wc-post-fail-" + Guid.NewGuid().ToString("N"));
        Assert.Equal(HttpStatusCode.InternalServerError, failed.StatusCode);

        await using var verify = fixture.NewContext();
        Assert.Equal(counterBefore, (await verify.PrefTxNumbers.SingleAsync(row =>
            row.TxPrefix == "WC")).TxNextNumber);
        Assert.Equal(25, (await verify.InventoryItems.SingleAsync(row => row.Sku == sku1))
            .QtyTotalOnHand);
        Assert.Equal(25, (await verify.BranchInventory.SingleAsync(row =>
            row.BranchCode == "01" && row.Sku == sku1)).QtyOnHand);
        Assert.Equal(0, await verify.TxPayments.CountAsync(row => row.TxNumber == txNumber));
        Assert.Equal(string.Empty,
            (await verify.TxHeaders.SingleAsync(row => row.TxNumber == txNumber)).ControlNumber);
        Assert.Equal("draft", (await verify.WholesaleDocuments.SingleAsync(row =>
            row.TxNumber == txNumber)).Status);
        Assert.False(await verify.AuditLogs.AnyAsync(row =>
            row.Action == "wholesale.invoice.post" && row.EntityId == txNumber));
    }
}
