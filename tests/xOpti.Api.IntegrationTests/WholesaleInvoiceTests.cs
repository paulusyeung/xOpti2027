using System.Net;
using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using xOpti.Api.IntegrationTests.Support;
using xOpti.Domain.Values;
using xOpti.Infrastructure.Persistence.Entities;

namespace xOpti.Api.IntegrationTests;

[Collection("api")]
public sealed class WholesaleInvoiceTests(ApiPostgresFixture fixture)
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
        var customerId = Random.Shared.Next(970000, 979999);
        var sku1 = "WI" + Random.Shared.Next(10000000, 99999999);
        var sku2 = "WI" + Random.Shared.Next(10000000, 99999999);
        await using var seed = fixture.NewContext();
        seed.Customers.Add(new Customer
        {
            Id = customerId, FullName = "Wholesale Invoice Customer",
            PaymentTerms = "NET30",
        });
        seed.WholesaleAccounts.Add(new WholesaleAccount
        {
            CustomerId = customerId, IsWholesale = true, PriceGrade = "A",
            TermsCode = "NET30", TermsDays = 30, CreditLimit = Money.From(50000m),
            TaxTreatment = "GST", RepresentativeStaffCode = null,
            CreatedAt = DateTimeOffset.UtcNow,
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
                SupplierCode = "0001", BrandCode = "0001", Name = "Wholesale item " + sku,
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

    private static object Shipping(string method = "Courier") => new
    {
        shippingMethod = method,
        shipToName = "Receiving Dock",
        shipToAddress = "10 Wholesale Way",
        shippingInstructions = "Call on arrival",
        purchaseOrderNumber = "PO-1001",
        dueDate = (string?)null,
    };

    private static object Line(string sku, int quantity, decimal? unitAmount,
        decimal discount = 0m, string taxCode = "B", string? overrideReason = null) => new
    {
        sku, quantity, unitAmount, discountAmount = discount, taxCode, overrideReason,
        description = "wholesale item",
    };

    private static object InvoiceBody(int customerId, string sku1, string sku2) => new
    {
        customerId,
        staffCode = "0007",
        lines = new[]
        {
            Line(sku1, 2, 10.0000m),
            Line(sku2, 1, 12.0000m, taxCode: "N", overrideReason: "volume discount"),
        },
        tenders = new[] { new { method = "C", amount = 10.0000m, reference = (string?)null } },
        shipping = Shipping(),
        reason = "wholesale invoice create",
    };

    [Fact]
    public async Task CreateAndUpdateDraftInvoice_ComputesPricesTaxesShippingAndTenders()
    {
        var (customerId, sku1, sku2) = await SeedAsync();
        var factory = new XOptiApiFactory(fixture);
        using var manager = new TestClient(factory);
        await manager.FetchCsrfTokenAsync();
        await manager.SignInAsync("manager", SeedData.Password);

        await BodyAsync(await manager.PostAsync("/api/v1/wholesale/price-lists", new
        {
            input = new
            {
                code = "A",
                name = "Wholesale invoice list",
                items = new[]
                {
                    new { sku = sku1, price = 10.0000m },
                    new { sku = sku2, price = 15.0000m },
                },
            },
            reason = "seed invoice prices",
        }), factory, HttpStatusCode.OK);

        var created = await BodyAsync(await manager.PostAsync("/api/v1/wholesale/invoices",
            InvoiceBody(customerId, sku1, sku2),
            idempotencyKey: "wc-create-" + Guid.NewGuid().ToString("N")),
            factory, HttpStatusCode.Created);
        var txNumber = created.GetProperty("txNumber").GetString()!;
        Assert.StartsWith("WC", txNumber);
        Assert.Equal("draft", created.GetProperty("status").GetString());
        Assert.Equal(32.0000m, created.GetProperty("totalSale").GetDecimal());
        Assert.Equal(1.0000m, created.GetProperty("taxA").GetDecimal());
        Assert.Equal(1.4000m, created.GetProperty("taxB").GetDecimal());
        Assert.Equal(34.4000m, created.GetProperty("totalAmount").GetDecimal());
        Assert.Equal(10.0000m, created.GetProperty("paid").GetDecimal());
        Assert.Equal("NET30", created.GetProperty("termsCode").GetString());
        Assert.Equal("Courier", created.GetProperty("shippingMethod").GetString());
        Assert.Equal("Receiving Dock", created.GetProperty("shipToName").GetString());
        Assert.Equal("PO-1001", created.GetProperty("purchaseOrderNumber").GetString());
        Assert.Equal(DateOnly.FromDateTime(DateTime.UtcNow).AddDays(30).ToString("yyyy-MM-dd"),
            created.GetProperty("dueDate").GetString());

        var lines = created.GetProperty("lines").EnumerateArray().ToList();
        Assert.Equal(2, lines.Count);
        Assert.Equal(10.0000m, lines[0].GetProperty("unitAmount").GetDecimal());
        Assert.False(lines[0].GetProperty("isOverride").GetBoolean());
        Assert.Equal(12.0000m, lines[1].GetProperty("unitAmount").GetDecimal());
        Assert.True(lines[1].GetProperty("isOverride").GetBoolean());
        Assert.Equal("volume discount", lines[1].GetProperty("overrideReason").GetString());
        Assert.Equal(15.0000m, lines[1].GetProperty("listUnitPrice").GetDecimal());

        var updated = await BodyAsync(await manager.PutAsync(
            $"/api/v1/wholesale/invoices/{txNumber}", new
            {
                customerId,
                staffCode = "0007",
                lines = new[]
                {
                    Line(sku1, 3, 10.0000m),
                    Line(sku2, 1, 12.0000m, taxCode: "N", overrideReason: "volume discount"),
                },
                tenders = new[] { new { method = "C", amount = 20.0000m, reference = (string?)null } },
                shipping = Shipping("Pickup"),
                reason = "wholesale invoice update",
            }), factory, HttpStatusCode.OK);
        Assert.Equal(42.0000m, updated.GetProperty("totalSale").GetDecimal());
        Assert.Equal(1.5000m, updated.GetProperty("taxA").GetDecimal());
        Assert.Equal(2.1000m, updated.GetProperty("taxB").GetDecimal());
        Assert.Equal(45.6000m, updated.GetProperty("totalAmount").GetDecimal());
        Assert.Equal(20.0000m, updated.GetProperty("paid").GetDecimal());
        Assert.Equal("Pickup", updated.GetProperty("shippingMethod").GetString());

        var fetched = await BodyAsync(await manager.GetAsync(
            $"/api/v1/wholesale/invoices/{txNumber}"), factory, HttpStatusCode.OK);
        Assert.Equal(3, fetched.GetProperty("lines").EnumerateArray().First()
            .GetProperty("quantity").GetInt32());

        var list = await BodyAsync(await manager.GetAsync(
            $"/api/v1/wholesale/invoices?customerId={customerId}&status=draft"),
            factory, HttpStatusCode.OK);
        Assert.Contains(list.GetProperty("items").EnumerateArray(),
            row => row.GetProperty("txNumber").GetString() == txNumber);

        await using var verify = fixture.NewContext();
        Assert.Equal(TransactionType.WholesaleInvoice,
            (await verify.TxHeaders.SingleAsync(row => row.TxNumber == txNumber)).TxType);
        Assert.Equal(2, await verify.WholesaleDocumentLines.CountAsync(row =>
            row.TxNumber == txNumber));
        Assert.True(await verify.AuditLogs.AnyAsync(row =>
            row.Action == "wholesale.invoice.create" && row.EntityId == txNumber));
        Assert.True(await verify.AuditLogs.AnyAsync(row =>
            row.Action == "wholesale.invoice.update" && row.EntityId == txNumber));
        Assert.True(await verify.AuditLogs.AnyAsync(row =>
            row.Action == "wholesale.price.override" && row.EntityId == txNumber));
    }

    [Fact]
    public async Task IdempotentCreate_ReplaysAndValidationRejectsBadPaymentsPermissions()
    {
        var (customerId, sku1, sku2) = await SeedAsync();
        var factory = new XOptiApiFactory(fixture);
        using var manager = new TestClient(factory);
        await manager.FetchCsrfTokenAsync();
        await manager.SignInAsync("manager", SeedData.Password);
        await BodyAsync(await manager.PostAsync("/api/v1/wholesale/price-lists", new
        {
            input = new
            {
                code = "A",
                name = "Wholesale invoice list",
                items = new[]
                {
                    new { sku = sku1, price = 10.0000m },
                    new { sku = sku2, price = 15.0000m },
                },
            },
            reason = "seed invoice prices",
        }), factory, HttpStatusCode.OK);

        var key = "wc-replay-" + Guid.NewGuid().ToString("N");
        var first = await BodyAsync(await manager.PostAsync("/api/v1/wholesale/invoices",
            InvoiceBody(customerId, sku1, sku2), idempotencyKey: key),
            factory, HttpStatusCode.Created);
        var replay = await BodyAsync(await manager.PostAsync("/api/v1/wholesale/invoices",
            InvoiceBody(customerId, sku1, sku2), idempotencyKey: key),
            factory, HttpStatusCode.Created);
        Assert.Equal(first.GetProperty("txNumber").GetString(),
            replay.GetProperty("txNumber").GetString());

        var unknownMethod = await manager.PostAsync("/api/v1/wholesale/invoices", new
        {
            customerId,
            staffCode = "0007",
            lines = new[] { Line(sku1, 1, 10.0000m) },
            tenders = new[] { new { method = "Z", amount = 1.0000m, reference = (string?)null } },
            shipping = Shipping(),
            reason = "bad payment method",
        }, idempotencyKey: "wc-bad-tender-" + Guid.NewGuid().ToString("N"));
        Assert.Equal(HttpStatusCode.BadRequest, unknownMethod.StatusCode);

        var overTotal = await manager.PostAsync("/api/v1/wholesale/invoices", new
        {
            customerId,
            staffCode = "0007",
            lines = new[] { Line(sku1, 1, 10.0000m) },
            tenders = new[] { new { method = "C", amount = 500.0000m, reference = (string?)null } },
            shipping = Shipping(),
            reason = "over total tender",
        }, idempotencyKey: "wc-over-tender-" + Guid.NewGuid().ToString("N"));
        Assert.Equal(HttpStatusCode.BadRequest, overTotal.StatusCode);

        var missingSku = await manager.PostAsync("/api/v1/wholesale/invoices", new
        {
            customerId,
            staffCode = "0007",
            lines = new[] { Line("ZZ99999999", 1, 10.0000m) },
            tenders = Array.Empty<object>(),
            shipping = Shipping(),
            reason = "unknown sku",
        }, idempotencyKey: "wc-missing-sku-" + Guid.NewGuid().ToString("N"));
        Assert.Equal(HttpStatusCode.BadRequest, missingSku.StatusCode);

        using var purchasing = new TestClient(factory);
        await purchasing.FetchCsrfTokenAsync();
        await purchasing.SignInAsync("purchasing", SeedData.Password);
        var unauthorizedOverride = await purchasing.PostAsync("/api/v1/wholesale/invoices", new
        {
            customerId,
            staffCode = "0007",
            lines = new[] { Line(sku2, 1, 12.0000m, overrideReason: "discount") },
            tenders = Array.Empty<object>(),
            shipping = Shipping(),
            reason = "override without permission",
        }, idempotencyKey: "wc-denied-override-" + Guid.NewGuid().ToString("N"));
        Assert.Equal(HttpStatusCode.BadRequest, unauthorizedOverride.StatusCode);
        Assert.Contains("price-override permission",
            await unauthorizedOverride.Content.ReadAsStringAsync());

        using var clerk = new TestClient(factory);
        await clerk.FetchCsrfTokenAsync();
        await clerk.SignInAsync("clerk", SeedData.Password);
        Assert.Equal(HttpStatusCode.Forbidden,
            (await clerk.GetAsync("/api/v1/wholesale/invoices")).StatusCode);
        Assert.Equal(HttpStatusCode.Forbidden,
            (await clerk.PostAsync("/api/v1/wholesale/invoices",
                InvoiceBody(customerId, sku1, sku2),
                idempotencyKey: "wc-clerk-" + Guid.NewGuid().ToString("N"))).StatusCode);
    }
}
