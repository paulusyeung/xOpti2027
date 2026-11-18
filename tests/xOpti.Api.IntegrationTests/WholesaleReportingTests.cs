using System.Net;
using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using xOpti.Api.IntegrationTests.Support;
using xOpti.Domain.Values;
using xOpti.Infrastructure.Persistence.Entities;

namespace xOpti.Api.IntegrationTests;

[Collection("api")]
public sealed class WholesaleReportingTests(ApiPostgresFixture fixture)
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

    private async Task<int> SeedAccountAsync(string? sku = null)
    {
        var customerId = Random.Shared.Next(993000, 993999);
        await using var seed = fixture.NewContext();
        seed.Customers.Add(new Customer { Id = customerId, FullName = "Wholesale Report Customer" });
        seed.WholesaleAccounts.Add(new WholesaleAccount
        {
            CustomerId = customerId, IsWholesale = true, PriceGrade = "A",
            TermsCode = "NET30", TermsDays = 30, CreditLimit = Money.From(5000m),
            TaxTreatment = "GST", CreatedAt = DateTimeOffset.UtcNow,
        });
        if (sku is not null)
        {
            seed.InventoryItems.Add(new Inventory
            {
                Sku = sku, DepartmentCode = "09", ClassCode = "09", CategoryCode = "09",
                SupplierCode = "0001", BrandCode = "0001", Name = "Report item",
                QtyTotalOnHand = 10, AverageCost = Money.From(5m),
                InventoryLotFlag = true, RetailPriceFlag = true,
            });
        }
        await seed.SaveChangesAsync();
        return customerId;
    }

    [Fact]
    public async Task PackingList_HidesPricesByDefaultAndPrintsWithAudit()
    {
        var sku = "PL" + Random.Shared.Next(10000000, 99999999);
        var customerId = await SeedAccountAsync(sku);
        var invoice = "WC" + Random.Shared.Next(10000000, 99999999);
        var now = DateTimeOffset.UtcNow;
        await using (var seed = fixture.NewContext())
        {
            seed.TxHeaders.Add(new TxHeader
            {
                TxNumber = invoice, ControlNumber = "00002001",
                TxType = TransactionType.WholesaleInvoice, DateOfEntry = now,
                DateOfCreation = now, CustomerId = customerId, Particulars = "Packing",
                TotalSale = Money.From(20m), TaxA = Money.From(1m), TaxB = Money.From(1.4m),
                GrossSale = Money.From(22.4m), TotalAmount = Money.From(22.4m),
                TotalQty = 1, ThisPaid = Money.From(22.4m), Status = "0",
            });
            seed.TxDetails.Add(new TxDetail
            {
                ControlNumber = "00002001", TxType = TransactionType.WholesaleInvoice,
                TxNumber = invoice, DateOfEntry = now, RowNo = 1, Sku = sku, Qty = 1,
                UnitAmount = Money.From(20m), UnitCost = Money.From(5m),
                MarkDownAmount = Money.Zero, Amount = Money.From(20m), TaxCode = "B",
                Remarks = "packing item",
            });
            seed.TxPayments.Add(new TxPayment
            {
                TxNumber = invoice, PaymentLineNo = 1, Type = "C",
                AmountTender = Money.From(22.4m), EqAmount = Money.From(22.4m),
                TotalThisPay = Money.From(22.4m),
            });
            seed.WholesaleDocuments.Add(new WholesaleDocument
            {
                TxNumber = invoice, Kind = "invoice", Status = "posted",
                TermsCode = "NET30", TermsDays = 30, ShippingMethod = "Courier",
                ShipToName = "Receiving Dock", ShipToAddress = "10 Wholesale Way",
                ShippingInstructions = "Call on arrival", PurchaseOrderNumber = "PO-PACK",
                CreatedAt = now, PostedAt = now, PostedBy = "seed",
            });
            seed.WholesaleDocumentLines.Add(new WholesaleDocumentLine
            {
                TxNumber = invoice, RowNo = 1, PriceListCode = "A", PriceListVersion = 1,
                ListUnitPrice = Money.From(20m), AppliedUnitPrice = Money.From(20m),
                TaxA = Money.From(1m), TaxB = Money.From(1.4m), IsOverride = false,
                CreatedAt = now,
            });
            seed.WholesaleBackorders.Add(new WholesaleBackorder
            {
                OriginalTxNumber = invoice, OriginalRowNo = 1, CustomerId = customerId,
                Sku = sku, OrderedQuantity = 2, ShippedQuantity = 1, RemainingQuantity = 1,
                Status = "open", CreatedAt = now,
            });
            await seed.SaveChangesAsync();
        }

        var factory = new XOptiApiFactory(fixture);
        using var manager = new TestClient(factory);
        await manager.FetchCsrfTokenAsync();
        await manager.SignInAsync("manager", SeedData.Password);

        var hidden = await BodyAsync(await manager.GetAsync(
            $"/api/v1/wholesale/invoices/{invoice}/packing-list"), factory, HttpStatusCode.OK);
        Assert.False(hidden.GetProperty("includesPrices").GetBoolean());
        Assert.Equal("Receiving Dock", hidden.GetProperty("shipToName").GetString());
        Assert.Equal("PO-PACK", hidden.GetProperty("purchaseOrderNumber").GetString());
        var line = hidden.GetProperty("lines").EnumerateArray().Single();
        Assert.Equal(1, line.GetProperty("quantity").GetInt32());
        Assert.Equal(1, line.GetProperty("backorderQuantity").GetInt32());
        Assert.Equal(JsonValueKind.Null, line.GetProperty("unitAmount").ValueKind);

        var shown = await BodyAsync(await manager.GetAsync(
            $"/api/v1/wholesale/invoices/{invoice}/packing-list?includePrices=true"),
            factory, HttpStatusCode.OK);
        Assert.True(shown.GetProperty("includesPrices").GetBoolean());
        Assert.Equal(20m, shown.GetProperty("lines").EnumerateArray().Single()
            .GetProperty("unitAmount").GetDecimal());

        using var purchasing = new TestClient(factory);
        await purchasing.FetchCsrfTokenAsync();
        await purchasing.SignInAsync("purchasing", SeedData.Password);
        var denied = await purchasing.GetAsync(
            $"/api/v1/wholesale/invoices/{invoice}/packing-list?includePrices=true");
        Assert.Equal(HttpStatusCode.BadRequest, denied.StatusCode);
        Assert.Contains("price-visibility", await denied.Content.ReadAsStringAsync());

        var print = await manager.PostAsync(
            $"/api/v1/wholesale/invoices/{invoice}/packing-list/prints", new
            {
                includePrices = false, reprint = true, terminalCode = "01",
                reason = "packing duplicate",
            });
        Assert.Equal(HttpStatusCode.OK, print.StatusCode);
        Assert.Contains("-packing-duplicate.pdf",
            print.Content.Headers.ContentDisposition?.FileName ?? string.Empty);

        await using var verify = fixture.NewContext();
        Assert.True(await verify.AuditLogs.AnyAsync(row =>
            row.Action == "wholesale.packing-list.reprint" && row.EntityId == invoice));
    }

    [Fact]
    public async Task BalanceAndStatement_ReconcileInvoicesReturnsAndPayments()
    {
        var customerId = await SeedAccountAsync();
        var invoice = "WC" + Random.Shared.Next(10000000, 99999999);
        var returnNumber = "WR" + Random.Shared.Next(10000000, 99999999);
        var now = DateTimeOffset.UtcNow;
        await using (var seed = fixture.NewContext())
        {
            seed.TxHeaders.Add(new TxHeader
            {
                TxNumber = invoice, ControlNumber = "00003001",
                TxType = TransactionType.WholesaleInvoice, DateOfEntry = now,
                DateOfCreation = now, CustomerId = customerId, Particulars = "Statement",
                TotalSale = Money.From(40m), TaxA = Money.From(2m), TaxB = Money.From(2.8m),
                GrossSale = Money.From(44.8m), TotalAmount = Money.From(44.8m),
                TotalQty = 2, ThisPaid = Money.From(44.8m), Status = "0",
            });
            seed.TxDetails.Add(new TxDetail
            {
                ControlNumber = "00003001", TxType = TransactionType.WholesaleInvoice,
                TxNumber = invoice, DateOfEntry = now, RowNo = 1, Sku = "STMT1", Qty = 2,
                UnitAmount = Money.From(20m), Amount = Money.From(40m), TaxCode = "B",
            });
            seed.TxPayments.Add(new TxPayment
            {
                TxNumber = invoice, PaymentLineNo = 1, Type = "C",
                AmountTender = Money.From(44.8m), EqAmount = Money.From(44.8m),
                TotalThisPay = Money.From(44.8m),
            });
            seed.WholesaleDocuments.Add(new WholesaleDocument
            {
                TxNumber = invoice, Kind = "invoice", Status = "posted",
                TermsCode = "NET30", TermsDays = 30, CreatedAt = now,
                PostedAt = now, PostedBy = "seed",
            });

            seed.TxHeaders.Add(new TxHeader
            {
                TxNumber = returnNumber, ControlNumber = "00003002",
                TxType = TransactionType.WholesaleReturn, DateOfEntry = now,
                DateOfCreation = now, CustomerId = customerId, TrackingNumber = invoice,
                Particulars = "Statement return", TotalSale = Money.From(-20m),
                TaxA = Money.From(-1m), TaxB = Money.From(-1.4m),
                GrossSale = Money.From(-22.4m), TotalAmount = Money.From(-22.4m),
                TotalQty = -1, ThisPaid = Money.From(-22.4m), Status = "0",
            });
            seed.TxDetails.Add(new TxDetail
            {
                ControlNumber = "00003002", TxType = TransactionType.WholesaleReturn,
                TxNumber = returnNumber, DateOfEntry = now, RowNo = 1, Sku = "STMT1",
                Qty = -1, UnitAmount = Money.From(20m), Amount = Money.From(-20m),
                TaxCode = "B",
            });
            seed.TxPayments.Add(new TxPayment
            {
                TxNumber = returnNumber, PaymentLineNo = 1, Type = "C",
                AmountTender = Money.From(-22.4m), EqAmount = Money.From(-22.4m),
                TotalThisPay = Money.From(-22.4m),
            });
            seed.WholesaleDocuments.Add(new WholesaleDocument
            {
                TxNumber = returnNumber, Kind = "return", Status = "posted",
                OriginalInvoiceNumber = invoice, TermsCode = "NET30", TermsDays = 30,
                CreatedAt = now, PostedAt = now, PostedBy = "seed",
            });
            await seed.SaveChangesAsync();
        }

        var factory = new XOptiApiFactory(fixture);
        using var manager = new TestClient(factory);
        await manager.FetchCsrfTokenAsync();
        await manager.SignInAsync("manager", SeedData.Password);
        var today = DateOnly.FromDateTime(DateTime.UtcNow);
        var from = today.AddDays(-1);
        var to = today.AddDays(1);

        var balance = await BodyAsync(await manager.GetAsync(
            $"/api/v1/wholesale/customers/{customerId}/balance"), factory, HttpStatusCode.OK);
        Assert.Equal(44.8m, balance.GetProperty("invoiced").GetDecimal());
        Assert.Equal(-22.4m, balance.GetProperty("returned").GetDecimal());
        Assert.Equal(22.4m, balance.GetProperty("payments").GetDecimal());
        Assert.Equal(0m, balance.GetProperty("balance").GetDecimal());
        Assert.False(balance.GetProperty("overCreditLimit").GetBoolean());

        var statement = await BodyAsync(await manager.GetAsync(
            $"/api/v1/wholesale/customers/{customerId}/statement"
            + $"?from={from:yyyy-MM-dd}&to={to:yyyy-MM-dd}"),
            factory, HttpStatusCode.OK);
        Assert.Equal(0m, statement.GetProperty("openingBalance").GetDecimal());
        Assert.Equal(44.8m, statement.GetProperty("invoiced").GetDecimal());
        Assert.Equal(-22.4m, statement.GetProperty("returned").GetDecimal());
        Assert.Equal(22.4m, statement.GetProperty("payments").GetDecimal());
        Assert.Equal(0m, statement.GetProperty("closingBalance").GetDecimal());
        Assert.Equal(4, statement.GetProperty("items").GetArrayLength());

        var print = await manager.PostAsync(
            $"/api/v1/wholesale/customers/{customerId}/statement/prints", new
            {
                from = from.ToString("yyyy-MM-dd"), to = to.ToString("yyyy-MM-dd"),
                reprint = true, terminalCode = "01", reason = "statement duplicate",
            });
        Assert.Equal(HttpStatusCode.OK, print.StatusCode);
        Assert.Equal("application/pdf", print.Content.Headers.ContentType?.MediaType);
        Assert.Contains("-duplicate.pdf",
            print.Content.Headers.ContentDisposition?.FileName ?? string.Empty);

        await using var verify = fixture.NewContext();
        Assert.True(await verify.AuditLogs.AnyAsync(row =>
            row.Action == "wholesale.statement.reprint"
            && row.EntityId == customerId.ToString()));
    }
}
