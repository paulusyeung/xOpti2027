using System.Net;
using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using xOpti.Api.IntegrationTests.Support;
using xOpti.Infrastructure.Persistence.Entities;

namespace xOpti.Api.IntegrationTests;

[Collection("api")]
public sealed class OpticalOrderTests(ApiPostgresFixture fixture)
{
    private static object Eye(decimal sphere, decimal cylinder, int axis) => new
    {
        sphere, cylinder, axis, pd = 32m, add = 2m, prism = 0m,
        @base = 0m, segHeight = 0m, oc = 0m, vd = 12m,
    };

    private static object Lens(long? versionId) => new
    {
        lineNumber = 1, prescriptionVersionId = versionId,
        right = Eye(1.25m, -0.5m, 90), left = Eye(-1.75m, -1.25m, 85),
        rightStyle = "SV", leftStyle = "SV", type = "Single vision",
        hardening = "Standard", material = "CR", coating = "AR", tint = "Clear",
        others = "", hardCoat = true, arCoat = true, uv = true,
    };

    private static object Frame() => new
    {
        lineNumber = 1, supply = true, enclosed = false, follow = false, lenses = true,
        mode = "Full rim", color = "Black", eyeSize = "52", bridge = 18, temple = 140,
        r1 = "", r2 = "", r3 = "", a = "52", b = "40", specialInstruction = "lab note",
    };

    private async Task<(TestClient Client, XOptiApiFactory Factory, int CustomerId, string Sku)>
        SetupAsync(string? terminalMode = null)
    {
        var sku = "OL" + Random.Shared.Next(10000000, 99999999);
        var customerId = Random.Shared.Next(920000, 929999);
        await using (var seed = fixture.NewContext())
        {
            seed.Customers.Add(new Customer { Id = customerId, FullName = "Optical Customer" });
            seed.Database.ExecuteSqlInterpolated($"""
                INSERT INTO public.category (department_code, class_code, category_code, category_name,
                    costing_method, inventory_method, tax_method) VALUES ('09','09','09','POS','1','1','B')
                ON CONFLICT (department_code, class_code, category_code) DO NOTHING;
                DELETE FROM public.invt_lot_record WHERE sku = {sku};
                INSERT INTO public.inventory (sku, department_code, class_code, category_code,
                    supplier_code, brand_code, name, qty_total_on_hand, average_cost,
                    inventory_lot_flag, retail_price_flag, whole_sale_price_flag)
                VALUES ({sku}, '09','09','09', '0001', '0001', 'Optical Frame', 10, 20.0000,
                    true, true, false);
                INSERT INTO public.branch_inventory (branch_code, sku, qty_on_hand)
                VALUES ('01', {sku}, 10)
                ON CONFLICT (branch_code, sku) DO UPDATE SET qty_on_hand = 10;
                """);
            seed.Database.ExecuteSqlInterpolated($"""
                INSERT INTO public.preference (serial_number, number_of_user, platform, product_name,
                    user_name, owner_name, branch_number, pst_number, gst_number, tax_a_rate, tax_b_rate,
                    next_invt_control_number, next_invt_sku, next_invoice_number, next_sales_order_number)
                VALUES ('0000000001', 1, 'xOpti', 'Synergy', 'Operator', 'Owner', '0001', '', '', 5, 7,
                    1000, 1, 1, 1)
                ON CONFLICT (serial_number) DO UPDATE SET tax_a_rate = 5, tax_b_rate = 7;
                """);
            seed.LotRecords.Add(new InvtLotRecord
            {
                Sku = sku, LotNo = "OLLOT", DateReceived = DateTimeOffset.UtcNow,
                SupplierCode = "0001", QtyPurchased = 10, QtyUsed = 0, QtyOnHand = 10,
                UnitAmountPurchased = xOpti.Domain.Values.Money.From(20m),
                TotalAmountPurchased = xOpti.Domain.Values.Money.From(200m),
            });
            seed.RetailPrices.Add(new RetailPrice { Sku = sku, RetailPriceValue = 50m });
            await seed.SaveChangesAsync();
        }

        var overrides = terminalMode is null
            ? null
            : new Dictionary<string, string?> { ["XOptiApi:RequirePrescriptionVerification"] = terminalMode };
        var factory = new XOptiApiFactory(fixture, overrides);
        var client = new TestClient(factory);
        await client.FetchCsrfTokenAsync();
        await client.SignInAsync("manager", SeedData.Password);
        return (client, factory, customerId, sku);
    }

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

    private static async Task<string> CreateOrderAsync(TestClient client, XOptiApiFactory factory,
        int customerId, string sku)
    {
        var order = await BodyAsync(await client.PostAsync("/api/v1/sales/orders", new
        {
            customerId, staffCode = "0007", depositAmount = 0m, reason = "optical order",
            lines = new[] { new { sku, quantity = 1, unitAmount = 50m, discountAmount = 0m,
                taxCode = "B" } },
        }, idempotencyKey: "optical-order-" + Guid.NewGuid().ToString("N")),
            factory, HttpStatusCode.Created);
        return order.GetProperty("txNumber").GetString()!;
    }

    private static async Task<long> SaveSpectacleAsync(TestClient client, XOptiApiFactory factory,
        int customerId)
    {
        var history = await BodyAsync(await client.PostAsync(
            $"/api/v1/customers/{customerId}/prescriptions/spectacle", new
            {
                issuedOn = DateTimeOffset.UtcNow,
                prescriberId = 1,
                right = Eye(1.25m, -0.5m, 90),
                left = Eye(-1.75m, -1.25m, 85),
                notes = "optical rx",
                reason = "optical order prescription",
            }), factory, HttpStatusCode.OK);
        return history.GetProperty("spectacle").EnumerateArray()
            .Last(row => row.GetProperty("source").GetString() == "app")
            .GetProperty("id").GetInt64();
    }

    [Fact]
    public async Task OpticalDetails_LinkPrescription_BlockConversionWithoutReference_AndTrackFulfillment()
    {
        var (client, factory, customerId, sku) = await SetupAsync();
        using var manager = client;
        var orderNumber = await CreateOrderAsync(client, factory, customerId, sku);

        var saved = await BodyAsync(await client.PutAsync(
            $"/api/v1/sales/orders/{orderNumber}/optical", new
            {
                frames = new[] { Frame() }, lenses = new[] { Lens(null) },
                contacts = Array.Empty<object>(), reason = "frame and lens",
            }), factory, HttpStatusCode.OK);
        Assert.Single(saved.GetProperty("frames").EnumerateArray());
        Assert.Equal("entered", saved.GetProperty("status").GetString());

        var blocked = await client.PostAsync($"/api/v1/sales/orders/{orderNumber}/convert", new
        {
            reason = "convert optical", tenders = new[] { new { method = "C", amount = 56m,
                reference = (string?)null } },
        }, idempotencyKey: "optical-convert-" + Guid.NewGuid().ToString("N"));
        Assert.Equal(HttpStatusCode.BadRequest, blocked.StatusCode);
        Assert.Contains("no prescription version", await blocked.Content.ReadAsStringAsync());

        var versionId = await SaveSpectacleAsync(client, factory, customerId);
        await BodyAsync(await client.PutAsync(
            $"/api/v1/sales/orders/{orderNumber}/optical", new
            {
                frames = new[] { Frame() }, lenses = new[] { Lens(versionId) },
                contacts = Array.Empty<object>(), reason = "frame and lens with rx",
            }), factory, HttpStatusCode.OK);

        foreach (var status in new[] { "ordered", "received", "dispensed" })
        {
            var updated = await BodyAsync(await client.PostAsync(
                $"/api/v1/sales/orders/{orderNumber}/optical/status", new
                {
                    status, reference = "LAB-" + status, notes = "status " + status,
                    reason = "fulfillment",
                }), factory, HttpStatusCode.OK);
            Assert.Equal(status, updated.GetProperty("status").GetString());
        }
        Assert.Equal(4, (await BodyAsync(await client.GetAsync(
            $"/api/v1/sales/orders/{orderNumber}/optical"), factory, HttpStatusCode.OK))
            .GetProperty("events").GetArrayLength());

        var badStatus = await client.PostAsync(
            $"/api/v1/sales/orders/{orderNumber}/optical/status", new
            {
                status = "received", reference = (string?)null, notes = (string?)null,
                reason = "backwards",
            });
        Assert.Equal(HttpStatusCode.BadRequest, badStatus.StatusCode);

        var converted = await BodyAsync(await client.PostAsync(
            $"/api/v1/sales/orders/{orderNumber}/convert", new
            {
                reason = "convert optical", tenders = new[] { new { method = "C", amount = 56m,
                    reference = (string?)null } },
            }, idempotencyKey: "optical-convert-ok-" + Guid.NewGuid().ToString("N")),
            factory, HttpStatusCode.OK);
        Assert.Equal("Invoice", converted.GetProperty("kind").GetString());
    }

    [Fact]
    public async Task VerificationPolicy_BlocksUnverifiedOpticalConversion()
    {
        var (client, factory, customerId, sku) = await SetupAsync("true");
        using var manager = client;
        var orderNumber = await CreateOrderAsync(client, factory, customerId, sku);
        var versionId = await SaveSpectacleAsync(client, factory, customerId);
        await BodyAsync(await client.PutAsync(
            $"/api/v1/sales/orders/{orderNumber}/optical", new
            {
                frames = Array.Empty<object>(), lenses = new[] { Lens(versionId) },
                contacts = Array.Empty<object>(), reason = "unverified lens",
            }), factory, HttpStatusCode.OK);

        var blocked = await client.PostAsync($"/api/v1/sales/orders/{orderNumber}/convert", new
        {
            reason = "convert unverified", tenders = new[] { new { method = "C", amount = 56m,
                reference = (string?)null } },
        }, idempotencyKey: "optical-unverified-" + Guid.NewGuid().ToString("N"));
        Assert.Equal(HttpStatusCode.BadRequest, blocked.StatusCode);
        Assert.Contains("not verified", await blocked.Content.ReadAsStringAsync());

        await BodyAsync(await client.PostAsync(
            $"/api/v1/customers/{customerId}/prescriptions/verify", new
            {
                type = "spectacle", versionId, note = "verified", reason = "verify for order",
            }), factory, HttpStatusCode.OK);

        await BodyAsync(await client.PostAsync($"/api/v1/sales/orders/{orderNumber}/convert", new
        {
            reason = "convert verified", tenders = new[] { new { method = "C", amount = 56m,
                reference = (string?)null } },
        }, idempotencyKey: "optical-verified-" + Guid.NewGuid().ToString("N")),
            factory, HttpStatusCode.OK);
    }
}
