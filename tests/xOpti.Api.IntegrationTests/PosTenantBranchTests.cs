using System.Net;
using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using xOpti.Api.IntegrationTests.Support;
using xOpti.Infrastructure.Persistence.Entities;

namespace xOpti.Api.IntegrationTests;

[Collection("api")]
public sealed class PosTenantBranchTests(ApiPostgresFixture fixture)
{
    private async Task<int> SeedAsync(string sku)
    {
        var customerId = Random.Shared.Next(100000, 199999);
        await using var seed = fixture.NewContext();
        await seed.Database.ExecuteSqlInterpolatedAsync($"""
            INSERT INTO public.customer (id, full_name) VALUES ({customerId}, 'Branch Customer');
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
                4000, 1, 1, 1)
            ON CONFLICT (serial_number) DO UPDATE
            SET tax_a_rate = 5, tax_b_rate = 7, next_invt_control_number = 4000;
            DELETE FROM public.invt_lot_record WHERE sku = {sku};
            INSERT INTO public.inventory (sku, department_code, class_code, category_code,
                supplier_code, brand_code, name, qty_total_on_hand, average_cost,
                inventory_lot_flag, retail_price_flag, whole_sale_price_flag)
            VALUES ({sku}, '09', '09', '09', '0001', '0001', 'Branch Frame', 10, 30.0000,
                true, true, false);
            INSERT INTO public.branch_inventory (branch_code, sku, qty_on_hand)
            VALUES ('01', {sku}, 10), ('02', {sku}, 5);
            """);
        seed.LotRecords.Add(new InvtLotRecord
        {
            Sku = sku, LotNo = "BRANCHLOT", DateReceived = DateTimeOffset.UtcNow,
            SupplierCode = "0001", QtyPurchased = 10, QtyUsed = 0, QtyOnHand = 10,
            UnitAmountPurchased = xOpti.Domain.Values.Money.From(30m),
            TotalAmountPurchased = xOpti.Domain.Values.Money.From(300m),
        });
        seed.RetailPrices.Add(new RetailPrice { Sku = sku, RetailPriceValue = 50m });
        await seed.SaveChangesAsync();
        return customerId;
    }

    private static async Task<JsonElement> BodyAsync(
        HttpResponseMessage response, XOptiApiFactory factory, HttpStatusCode expected)
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
    public async Task SaleUsesTheDrawerBranchInventory_AndBranchQueriesStaySeparate()
    {
        var sku = "99000016";
        var customerId = await SeedAsync(sku);
        var businessDate = DateOnly.FromDateTime(DateTime.UtcNow);
        var factory = new XOptiApiFactory(fixture);
        using var manager = new TestClient(factory);
        await manager.FetchCsrfTokenAsync();
        await manager.SignInAsync("manager", SeedData.Password);

        var opened = await BodyAsync(await manager.PostAsync("/api/v1/cash/sessions", new
        {
            branchCode = "02", terminalCode = "01", openingFloat = 0m, reason = "branch two drawer",
        }), factory, HttpStatusCode.Created);
        var sessionId = opened.GetProperty("id").GetInt64();

        var branchTwoOpen = await BodyAsync(
            await manager.GetAsync("/api/v1/cash/sessions/open?branchCode=02"),
            factory, HttpStatusCode.OK);
        Assert.Contains(branchTwoOpen.EnumerateArray(),
            row => row.GetProperty("id").GetInt64() == sessionId);
        var branchOneOpen = await BodyAsync(
            await manager.GetAsync("/api/v1/cash/sessions/open?branchCode=01"),
            factory, HttpStatusCode.OK);
        Assert.DoesNotContain(branchOneOpen.EnumerateArray(),
            row => row.GetProperty("id").GetInt64() == sessionId);

        var sale = await BodyAsync(await manager.PostAsync("/api/v1/sales/invoices", new
        {
            customerId, staffCode = "0007", sessionId, reason = "branch two sale",
            lines = new[] { new { sku, quantity = 1, unitAmount = 50m, discountAmount = 0m,
                taxCode = "B" } },
            tenders = new[] { new { method = "C", amount = 56m, reference = (string?)null } },
        }, idempotencyKey: "branch-sale-" + Guid.NewGuid().ToString("N")),
            factory, HttpStatusCode.Created);
        var invoiceNumber = sale.GetProperty("txNumber").GetString()!;

        await using (var verify = fixture.NewContext())
        {
            Assert.Equal(9, (await verify.InventoryItems.SingleAsync(row => row.Sku == sku)).QtyTotalOnHand);
            Assert.Equal(10, (await verify.BranchInventory.SingleAsync(
                row => row.BranchCode == "01" && row.Sku == sku)).QtyOnHand);
            Assert.Equal(4, (await verify.BranchInventory.SingleAsync(
                row => row.BranchCode == "02" && row.Sku == sku)).QtyOnHand);
        }

        var branchTwoJournal = await BodyAsync(await manager.GetAsync(
            $"/api/v1/cash/journal?branchCode=02&businessDate={businessDate:yyyy-MM-dd}"),
            factory, HttpStatusCode.OK);
        Assert.Contains(branchTwoJournal.GetProperty("documents").EnumerateArray(),
            row => row.GetProperty("txNumber").GetString() == invoiceNumber);
        var branchOneJournal = await BodyAsync(await manager.GetAsync(
            $"/api/v1/cash/journal?branchCode=01&businessDate={businessDate:yyyy-MM-dd}"),
            factory, HttpStatusCode.OK);
        Assert.DoesNotContain(branchOneJournal.GetProperty("documents").EnumerateArray(),
            row => row.GetProperty("txNumber").GetString() == invoiceNumber);

        await using var schema = fixture.NewContext();
        var tenantColumns = await schema.Database
            .SqlQuery<int>($"SELECT count(*)::int AS \"Value\" FROM information_schema.columns WHERE column_name IN ('tenant_id', 'company_id')")
            .SingleAsync();
        Assert.Equal(0, tenantColumns);
    }
}
