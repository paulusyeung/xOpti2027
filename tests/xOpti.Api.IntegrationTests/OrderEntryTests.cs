using System.Net;
using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using xOpti.Api.IntegrationTests.Support;

namespace xOpti.Api.IntegrationTests;

[Collection("api")]
public sealed class OrderEntryTests(ApiPostgresFixture fixture)
{
    private async Task<TestClient> ManagerAsync()
    {
        var client = new TestClient(new XOptiApiFactory(fixture));
        await client.FetchCsrfTokenAsync();
        Assert.Equal(HttpStatusCode.OK, (await client.SignInAsync("manager", SeedData.Password)).Status);
        return client;
    }

    private static async Task<JsonElement> BodyAsync(HttpResponseMessage response)
    {
        using var document = JsonDocument.Parse(await response.Content.ReadAsStringAsync());
        return document.RootElement.Clone();
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
        return await BodyAsync(response);
    }

    [Fact]
    public async Task OrderLifecycle_LinesValidation_ConversionWithDeposit_AndIdempotentRetry()
    {
        var customerId = Random.Shared.Next(700000, 799999);
        await using (var seed = fixture.NewContext())
        {
            await seed.Database.ExecuteSqlInterpolatedAsync($"""
                INSERT INTO public.customer (id, full_name) VALUES ({customerId}, 'POS Customer');
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
                INSERT INTO public.inventory (sku, department_code, class_code, category_code,
                    supplier_code, brand_code, name, qty_total_on_hand, average_cost,
                    inventory_lot_flag, retail_price_flag, whole_sale_price_flag)
                VALUES ('99000001', '09', '09', '09', '0001', '0001', 'POS Frame', 10, 30.0000, true, false, false)
                ON CONFLICT (sku) DO UPDATE SET qty_total_on_hand = 10;
                INSERT INTO public.branch_inventory (branch_code, sku, qty_on_hand)
                VALUES ('01', '99000001', 10)
                ON CONFLICT (branch_code, sku) DO UPDATE SET qty_on_hand = 10;
                """);
            if (!await seed.LotRecords.AnyAsync(row => row.Sku == "99000001" && row.LotNo == "POSLOT"))
            {
                seed.LotRecords.Add(new xOpti.Infrastructure.Persistence.Entities.InvtLotRecord
                {
                    Sku = "99000001", LotNo = "POSLOT",
                    DateReceived = DateTimeOffset.UtcNow, SupplierCode = "0001",
                    QtyPurchased = 10, QtyUsed = 0, QtyOnHand = 10,
                    UnitAmountPurchased = xOpti.Domain.Values.Money.From(30m),
                    TotalAmountPurchased = xOpti.Domain.Values.Money.From(300m),
                });
                await seed.SaveChangesAsync();
            }
        }

        var factory = new XOptiApiFactory(fixture);
        using var manager = new TestClient(factory);
        await manager.FetchCsrfTokenAsync();
        await manager.SignInAsync("manager", SeedData.Password);
        var create = await manager.PostAsync("/api/v1/sales/orders", new
        {
            customerId,
            staffCode = "0007",
            depositAmount = 20m,
            reason = "order test",
            lines = new[] { new { sku = "99000001", quantity = 2, unitAmount = 50.0m,
                taxCode = "B", discountAmount = 0m } },
        }, idempotencyKey: "ord-" + Guid.NewGuid().ToString("N"));
        var order = await ExpectAsync(create, HttpStatusCode.Created, factory);

        var context = await ExpectAsync(
            await manager.GetAsync("/api/v1/sales/order-entry/context"), HttpStatusCode.OK, factory);
        Assert.Equal(5, context.GetProperty("taxARate").GetDouble());
        Assert.Equal(7, context.GetProperty("taxBRate").GetDouble());

        var customers = await ExpectAsync(
            await manager.GetAsync($"/api/v1/sales/customers?search={customerId}"),
            HttpStatusCode.OK, factory);
        Assert.Contains(customers.EnumerateArray(),
            row => row.GetProperty("id").GetInt32() == customerId);

        var items = await ExpectAsync(
            await manager.GetAsync("/api/v1/sales/items?search=99000001"),
            HttpStatusCode.OK, factory);
        var item = items.EnumerateArray().Single(row => row.GetProperty("sku").GetString() == "99000001");
        Assert.Equal("B", item.GetProperty("taxCode").GetString());
        var orderNumber = order.GetProperty("txNumber").GetString()!;
        Assert.Equal("Order", order.GetProperty("kind").GetString());
        Assert.Equal("Open", order.GetProperty("statusLabel").GetString());
        Assert.Equal(20m, order.GetProperty("paid").GetDecimal());
        Assert.Equal(92m, order.GetProperty("balance").GetDecimal());

        var invalid = await manager.PostAsync("/api/v1/sales/orders", new
        {
            customerId, staffCode = "0007", depositAmount = 0m, reason = "invalid line",
            lines = new[] { new { sku = "99000001", quantity = 0, unitAmount = 50.0m, taxCode = "B",
                discountAmount = 0m } },
        }, idempotencyKey: "bad-" + Guid.NewGuid().ToString("N"));
        Assert.Equal(HttpStatusCode.BadRequest, invalid.StatusCode);

        var unknownCustomer = await manager.PostAsync("/api/v1/sales/orders", new
        {
            customerId = 99999999, staffCode = "0007", depositAmount = 0m, reason = "unknown customer",
            lines = new[] { new { sku = "99000001", quantity = 1, unitAmount = 50.0m, taxCode = "B",
                discountAmount = 0m } },
        }, idempotencyKey: "bad-customer-" + Guid.NewGuid().ToString("N"));
        Assert.Equal(HttpStatusCode.BadRequest, unknownCustomer.StatusCode);

        var unknownSku = await manager.PostAsync("/api/v1/sales/orders", new
        {
            customerId, staffCode = "0007", depositAmount = 0m, reason = "unknown sku",
            lines = new[] { new { sku = "NO-SUCH-SKU", quantity = 1, unitAmount = 50.0m, taxCode = "B",
                discountAmount = 0m } },
        }, idempotencyKey: "bad-sku-" + Guid.NewGuid().ToString("N"));
        Assert.Equal(HttpStatusCode.BadRequest, unknownSku.StatusCode);

        var overDiscount = await manager.PostAsync("/api/v1/sales/orders", new
        {
            customerId, staffCode = "0007", depositAmount = 0m, reason = "discount too large",
            lines = new[] { new { sku = "99000001", quantity = 1, unitAmount = 10.0m, taxCode = "B",
                discountAmount = 11m } },
        }, idempotencyKey: "bad-discount-" + Guid.NewGuid().ToString("N"));
        Assert.Equal(HttpStatusCode.BadRequest, overDiscount.StatusCode);

        var overDeposit = await manager.PostAsync("/api/v1/sales/orders", new
        {
            customerId, staffCode = "0007", depositAmount = 1000m, reason = "deposit too large",
            lines = new[] { new { sku = "99000001", quantity = 1, unitAmount = 10.0m, taxCode = "B",
                discountAmount = 0m } },
        }, idempotencyKey: "bad-deposit-" + Guid.NewGuid().ToString("N"));
        Assert.Equal(HttpStatusCode.BadRequest, overDeposit.StatusCode);

        var update = await manager.PutAsync($"/api/v1/sales/orders/{orderNumber}", new
        {
            customerId, staffCode = "0007", depositAmount = 20m, reason = "update order",
            lines = new[] { new { sku = "99000001", quantity = 1, unitAmount = 50.0m, taxCode = "B",
                discountAmount = 5m } },
        });
        var updated = await ExpectAsync(update, HttpStatusCode.OK, factory);
        Assert.Equal(1, updated.GetProperty("totalQty").GetInt32());
        var updatedLine = updated.GetProperty("lines").EnumerateArray().Single();
        Assert.Equal(5m, updatedLine.GetProperty("discountAmount").GetDecimal());
        Assert.Equal(45m, updatedLine.GetProperty("amount").GetDecimal());

        await using (var beforeInvoice = fixture.NewContext())
        {
            Assert.Equal(10, (await beforeInvoice.InventoryItems.SingleAsync(
                row => row.Sku == "99000001")).QtyTotalOnHand);
        }

        var shortTender = await manager.PostAsync($"/api/v1/sales/orders/{orderNumber}/convert", new
        {
            reason = "wrong tender", tenders = new[] { new { method = "C", amount = 1.0m,
                reference = (string?)null } },
        }, idempotencyKey: "conv-short-" + Guid.NewGuid().ToString("N"));
        Assert.Equal(HttpStatusCode.BadRequest, shortTender.StatusCode);

        var convertKey = "conv-" + Guid.NewGuid().ToString("N");
        var convert = await manager.PostAsync($"/api/v1/sales/orders/{orderNumber}/convert", new
        {
            reason = "invoice order",
            tenders = new[] { new { method = "C", amount = 30.4m, reference = (string?)null } },
        }, idempotencyKey: convertKey);
        var invoice = await ExpectAsync(convert, HttpStatusCode.OK, factory);
        var invoiceNumber = invoice.GetProperty("txNumber").GetString()!;
        Assert.StartsWith("RC", invoiceNumber);
        Assert.Equal("Invoice", invoice.GetProperty("kind").GetString());

        var retry = await manager.PostAsync($"/api/v1/sales/orders/{orderNumber}/convert", new
        {
            reason = "retry", tenders = new[] { new { method = "C", amount = 30.4m, reference = (string?)null } },
        }, idempotencyKey: convertKey);
        Assert.Equal(invoiceNumber, (await BodyAsync(retry)).GetProperty("txNumber").GetString());

        var second = await manager.PostAsync("/api/v1/sales/orders", new
        {
            customerId, staffCode = "0007", depositAmount = 0m, reason = "cancel me",
            lines = new[] { new { sku = "99000001", quantity = 1, unitAmount = 10.0m, taxCode = "N",
                discountAmount = 0m } },
        }, idempotencyKey: "cancel-" + Guid.NewGuid().ToString("N"));
        var secondNumber = (await BodyAsync(second)).GetProperty("txNumber").GetString()!;
        var cancel = await manager.PostAsync($"/api/v1/sales/orders/{secondNumber}/cancel", new
        {
            reason = "customer changed mind",
        });
        Assert.Equal(HttpStatusCode.OK, cancel.StatusCode);

        await using var verify = fixture.NewContext();
        var orderHeader = await verify.TxHeaders.SingleAsync(row => row.TxNumber == orderNumber);
        Assert.Equal("3", orderHeader.Status);
        Assert.Equal(invoiceNumber, orderHeader.RefNumber);
        Assert.Equal("2", (await verify.TxHeaders.SingleAsync(row => row.TxNumber == secondNumber)).Status);

        var invoiceHeader = await verify.TxHeaders.SingleAsync(row => row.TxNumber == invoiceNumber);
        Assert.Equal(orderNumber, invoiceHeader.RefNumber);
        Assert.Equal(50.4m, invoiceHeader.TotalAmount.Amount);
        var invoiceLine = await verify.TxDetails.SingleAsync(row => row.TxNumber == invoiceNumber);
        Assert.Equal(30m, invoiceLine.UnitCost.Amount);
        Assert.Equal(1, invoiceLine.Qty);
        var tenders = await verify.TxPayments.Where(row => row.TxNumber == invoiceNumber)
            .OrderBy(row => row.PaymentLineNo).ToListAsync();
        Assert.Equal(new[] { "D", "C" }, tenders.Select(row => row.Type));
        Assert.Equal(20m, tenders[0].AmountTender.Amount);
        Assert.Equal(30.4m, tenders[1].AmountTender.Amount);

        Assert.True(await verify.AuditLogs.AnyAsync(row =>
            row.Action == "order.create" && row.EntityId == orderNumber));
        Assert.True(await verify.AuditLogs.AnyAsync(row =>
            row.Action == "order.update" && row.EntityId == orderNumber));
        Assert.True(await verify.AuditLogs.AnyAsync(row =>
            row.Action == "order.convert" && row.EntityId == invoiceNumber));
        Assert.True(await verify.AuditLogs.AnyAsync(row =>
            row.Action == "order.cancel" && row.EntityId == secondNumber));

        var inventory = await verify.InventoryItems.SingleAsync(row => row.Sku == "99000001");
        Assert.Equal(9, inventory.QtyTotalOnHand);
        var lot = await verify.LotRecords.SingleAsync(row => row.Sku == "99000001" && row.LotNo == "POSLOT");
        Assert.Equal(9, lot.QtyOnHand);
    }

    [Fact]
    public async Task ConcurrentOrders_AllocateDistinctNumbers_AndResumeFromOrderSearch()
    {
        var customerId = Random.Shared.Next(600000, 699999);
        var sku = "9" + Random.Shared.Next(10000000, 99999999);
        await using (var seed = fixture.NewContext())
        {
            await seed.Database.ExecuteSqlInterpolatedAsync($"""
                INSERT INTO public.customer (id, full_name) VALUES ({customerId}, 'Concurrent Customer');
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
                ON CONFLICT (serial_number) DO UPDATE
                SET tax_a_rate = 5, tax_b_rate = 7, next_invt_control_number = 1000;
                INSERT INTO public.inventory (sku, department_code, class_code, category_code,
                    supplier_code, brand_code, name, qty_total_on_hand, average_cost,
                    inventory_lot_flag, retail_price_flag, whole_sale_price_flag)
                VALUES ({sku}, '01', '01', '01', '0001', '0001', 'Concurrent Frame', 10, 30.0000,
                    true, false, false)
                ON CONFLICT (sku) DO UPDATE SET qty_total_on_hand = 10;
                """);
        }

        var factory = new XOptiApiFactory(fixture);
        using var manager = new TestClient(factory);
        await manager.FetchCsrfTokenAsync();
        await manager.SignInAsync("manager", SeedData.Password);

        var attempts = Enumerable.Range(0, 5).Select(index =>
            manager.PostAsync("/api/v1/sales/orders", new
            {
                customerId,
                staffCode = "0007",
                depositAmount = 0m,
                reason = $"concurrent {index}",
                lines = new[] { new { sku, quantity = 1, unitAmount = 10.0m, taxCode = "G",
                    discountAmount = 0m } },
            }, idempotencyKey: $"concurrent-{index}-{Guid.NewGuid():N}")).ToList();
        var responses = await Task.WhenAll(attempts);

        var orders = new List<JsonElement>();
        foreach (var response in responses) orders.Add(await ExpectAsync(response, HttpStatusCode.Created, factory));

        var numbers = orders.Select(order => order.GetProperty("txNumber").GetString()!).ToList();
        var controls = orders.Select(order => order.GetProperty("controlNumber").GetString()!).ToList();
        Assert.Equal(5, numbers.Distinct().Count());
        Assert.Equal(5, controls.Distinct().Count());
        Assert.All(numbers, number => Assert.StartsWith("SA", number));

        var search = await manager.GetAsync($"/api/v1/sales/orders?customerId={customerId}&status=0&pageSize=10");
        var page = await ExpectAsync(search, HttpStatusCode.OK, factory);
        var found = page.GetProperty("items").EnumerateArray()
            .Select(item => item.GetProperty("txNumber").GetString()!).ToList();
        Assert.Equal(numbers.OrderBy(number => number), found.OrderBy(number => number));

        var resume = await manager.PutAsync($"/api/v1/sales/orders/{numbers[0]}", new
        {
            customerId,
            staffCode = "0007",
            depositAmount = 0m,
            reason = "resume order",
            lines = new[] { new { sku, quantity = 3, unitAmount = 10.0m, taxCode = "G",
                discountAmount = 0m } },
        });
        await ExpectAsync(resume, HttpStatusCode.OK, factory);

        var resumed = await manager.GetAsync($"/api/v1/sales/documents/{numbers[0]}");
        var document = await ExpectAsync(resumed, HttpStatusCode.OK, factory);
        Assert.Equal(3, document.GetProperty("totalQty").GetInt32());
    }
}
