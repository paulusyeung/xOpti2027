using System.Net;
using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using xOpti.Api.IntegrationTests.Support;
using xOpti.Domain.Values;
using xOpti.Infrastructure.Persistence.Entities;

namespace xOpti.Api.IntegrationTests;

[Collection("api")]
public sealed class WholesaleConcurrencyTests(ApiPostgresFixture fixture)
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

    private async Task<(int CustomerId, string Sku)> SeedAsync()
    {
        var customerId = Random.Shared.Next(994000, 994999);
        var sku = "CW" + Random.Shared.Next(10000000, 99999999);
        await using var seed = fixture.NewContext();
        seed.Customers.Add(new Customer { Id = customerId, FullName = "Concurrent Wholesale" });
        seed.WholesaleAccounts.Add(new WholesaleAccount
        {
            CustomerId = customerId, IsWholesale = true, PriceGrade = "A",
            TermsCode = "NET30", TermsDays = 30, CreditLimit = Money.From(100000m),
            TaxTreatment = "GST", CreatedAt = DateTimeOffset.UtcNow,
        });
        await seed.Database.ExecuteSqlInterpolatedAsync($"""
            INSERT INTO public.category (department_code, class_code, category_code, category_name,
                costing_method, inventory_method, tax_method) VALUES ('09','09','09','Wholesale','1','1','B')
            ON CONFLICT (department_code, class_code, category_code) DO NOTHING;
            INSERT INTO public.preference (serial_number, number_of_user, platform, product_name,
                user_name, owner_name, branch_number, pst_number, gst_number, tax_a_rate, tax_b_rate,
                next_invt_control_number, next_invt_sku, next_invoice_number, next_sales_order_number)
            VALUES ('0000000001', 1, 'xOpti', 'Synergy', 'Operator', 'Owner', '0001', '', '', 5, 7,
                5000, 1, 1, 1)
            ON CONFLICT (serial_number) DO UPDATE
            SET tax_a_rate = 5, tax_b_rate = 7, next_invt_control_number = 5000;
            DELETE FROM public.invt_lot_record WHERE sku = {sku};
            INSERT INTO public.inventory (sku, department_code, class_code, category_code,
                supplier_code, brand_code, name, qty_total_on_hand, average_cost,
                inventory_lot_flag, retail_price_flag, whole_sale_price_flag)
            VALUES ({sku}, '09','09','09', '0001', '0001', 'Concurrent Wholesale Item',
                100, 5.0000, true, true, true);
            INSERT INTO public.branch_inventory (branch_code, sku, qty_on_hand)
            VALUES ('01', {sku}, 100) ON CONFLICT (branch_code, sku)
            DO UPDATE SET qty_on_hand = 100;
            """);
        seed.LotRecords.Add(new InvtLotRecord
        {
            Sku = sku, LotNo = "CWSLOT", DateReceived = DateTimeOffset.UtcNow,
            SupplierCode = "0001", QtyPurchased = 100, QtyUsed = 0, QtyOnHand = 100,
            UnitAmountPurchased = Money.From(5m), TotalAmountPurchased = Money.From(500m),
        });
        await seed.SaveChangesAsync();
        return (customerId, sku);
    }

    private static object InvoiceBody(int customerId, string sku, int quantity = 1) => new
    {
        customerId,
        staffCode = "0007",
        lines = new[]
        {
            new { sku, quantity, unitAmount = 10.0000m, discountAmount = 0m,
                taxCode = "B", overrideReason = (string?)null, description = "concurrent",
                backorderQuantity = 0 },
        },
        tenders = Array.Empty<object>(),
        shipping = new
        {
            shippingMethod = "Courier", shipToName = "Dock", shipToAddress = "1 Way",
            shippingInstructions = (string?)null, purchaseOrderNumber = (string?)null,
            dueDate = (string?)null,
        },
        reason = "concurrent wholesale invoice",
    };

    [Fact]
    public async Task ConcurrentInvoicesAndReturns_HaveUniqueNumbersExactStockAndNoDoubleCredit()
    {
        var (customerId, sku) = await SeedAsync();
        var factory = new XOptiApiFactory(fixture);
        using var manager = new TestClient(factory);
        await manager.FetchCsrfTokenAsync();
        await manager.SignInAsync("manager", SeedData.Password);
        await BodyAsync(await manager.PostAsync("/api/v1/wholesale/price-lists", new
        {
            input = new
            {
                code = "A", name = "Concurrency list",
                items = new[] { new { sku, price = 10.0000m } },
            },
            reason = "concurrent prices",
        }), factory, HttpStatusCode.OK);

        var invoices = await Task.WhenAll(Enumerable.Range(0, 6).Select(async index =>
            await BodyAsync(await manager.PostAsync("/api/v1/wholesale/invoices",
                InvoiceBody(customerId, sku),
                idempotencyKey: $"cw-inv-{sku}-{index}"),
                factory, HttpStatusCode.Created)));
        var invoiceNumbers = invoices.Select(row => row.GetProperty("txNumber").GetString()!).ToList();
        Assert.Equal(6, invoiceNumbers.Distinct().Count());

        await Task.WhenAll(invoiceNumbers.Select((number, index) => Task.Run(async () =>
            await BodyAsync(await manager.PostAsync(
                $"/api/v1/wholesale/invoices/{number}/post", new
                {
                    tenders = new[] { new { method = "C", amount = 11.2000m,
                        reference = (string?)null } },
                    reason = "concurrent invoice post",
                }, idempotencyKey: $"cw-inv-post-{index}-{Guid.NewGuid():N}"),
                factory, HttpStatusCode.OK))));

        await using (var verify = fixture.NewContext())
        {
            var controls = await verify.TxHeaders
                .Where(row => invoiceNumbers.Contains(row.TxNumber))
                .Select(row => row.ControlNumber).ToListAsync();
            Assert.Equal(6, controls.Distinct().Count());
            Assert.All(controls, control => Assert.False(string.IsNullOrWhiteSpace(control)));
            Assert.Equal(94, (await verify.InventoryItems.SingleAsync(row =>
                row.Sku == sku)).QtyTotalOnHand);
            Assert.Equal(94, (await verify.BranchInventory.SingleAsync(row =>
                row.BranchCode == "01" && row.Sku == sku)).QtyOnHand);
            Assert.Equal(6, await verify.TxPayments.CountAsync(row =>
                invoiceNumbers.Contains(row.TxNumber)));
        }

        var bulk = await BodyAsync(await manager.PostAsync("/api/v1/wholesale/invoices",
            InvoiceBody(customerId, sku, 6),
            idempotencyKey: "cw-bulk-" + Guid.NewGuid().ToString("N")),
            factory, HttpStatusCode.Created);
        var bulkNumber = bulk.GetProperty("txNumber").GetString()!;
        await BodyAsync(await manager.PostAsync(
            $"/api/v1/wholesale/invoices/{bulkNumber}/post", new
            {
                tenders = new[] { new { method = "C", amount = 67.2000m,
                    reference = (string?)null } },
                reason = "post bulk invoice",
            }, idempotencyKey: "cw-bulk-post-" + Guid.NewGuid().ToString("N")),
            factory, HttpStatusCode.OK);

        var returnResponses = await Task.WhenAll(Enumerable.Range(0, 9).Select(async index =>
            await manager.PostAsync("/api/v1/wholesale/returns", new
            {
                originalInvoiceNumber = bulkNumber,
                staffCode = "0007",
                lines = new[]
                {
                    new { originalRowNo = 1, quantity = 1, restock = true,
                        dispositionReason = (string?)null },
                },
                tenders = Array.Empty<object>(),
                reason = "concurrent return",
            }, idempotencyKey: $"cw-ret-{index}-{Guid.NewGuid():N}")));
        var successes = returnResponses.Where(row => row.StatusCode == HttpStatusCode.Created)
            .ToList();
        var rejected = returnResponses.Where(row => row.StatusCode == HttpStatusCode.BadRequest)
            .ToList();
        Assert.Equal(6, successes.Count);
        Assert.Equal(3, rejected.Count);
        var returnNumbers = new List<string>();
        foreach (var response in successes)
        {
            using var body = JsonDocument.Parse(await response.Content.ReadAsStringAsync());
            returnNumbers.Add(body.RootElement.GetProperty("txNumber").GetString()!);
        }
        Assert.Equal(6, returnNumbers.Distinct().Count());

        await Task.WhenAll(returnNumbers.Select((number, index) => Task.Run(async () =>
            await BodyAsync(await manager.PostAsync(
                $"/api/v1/wholesale/returns/{number}/post", new
                {
                    tenders = new[] { new { method = "C", amount = 11.2000m,
                        reference = (string?)null } },
                    reason = "concurrent return post",
                }, idempotencyKey: $"cw-ret-post-{index}-{Guid.NewGuid():N}"),
                factory, HttpStatusCode.OK))));

        await using (var verify = fixture.NewContext())
        {
            var controls = await verify.TxHeaders
                .Where(row => returnNumbers.Contains(row.TxNumber))
                .Select(row => row.ControlNumber).ToListAsync();
            Assert.Equal(6, controls.Distinct().Count());
            Assert.Equal(94, (await verify.InventoryItems.SingleAsync(row =>
                row.Sku == sku)).QtyTotalOnHand);
            Assert.Equal(94, (await verify.BranchInventory.SingleAsync(row =>
                row.BranchCode == "01" && row.Sku == sku)).QtyOnHand);
            Assert.Equal(6, await verify.TxPayments.CountAsync(row =>
                returnNumbers.Contains(row.TxNumber)));
            var credits = (await verify.TxHeaders
                .Where(row => returnNumbers.Contains(row.TxNumber))
                .Select(row => row.TotalAmount)
                .ToListAsync()).Sum(row => row.Amount);
            Assert.Equal(-67.2000m, credits);
            Assert.Equal(6, await verify.WholesaleReturnLines.CountAsync(row =>
                returnNumbers.Contains(row.ReturnTxNumber)));
        }
    }
}
