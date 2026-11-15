using System.Net;
using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using xOpti.Api.IntegrationTests.Support;

namespace xOpti.Api.IntegrationTests;

[Collection("api")]
public sealed class StockTakeSnapshotTests(ApiPostgresFixture fixture)
{
    private async Task<TestClient> ManagerAsync()
    {
        var client = new TestClient(new XOptiApiFactory(fixture));
        await client.FetchCsrfTokenAsync();
        Assert.Equal(HttpStatusCode.OK, (await client.SignInAsync("manager", SeedData.Password)).Status);
        return client;
    }

    [Fact]
    public async Task FrozenSnapshot_MatchesOnHand_AndDoesNotChangeWithInventory()
    {
        var sku = "3" + Guid.NewGuid().ToString("N")[..8];
        await using (var seed = fixture.NewContext())
        {
            await seed.Database.ExecuteSqlInterpolatedAsync($"""
                INSERT INTO public.inventory (sku, department_code, class_code, category_code,
                    supplier_code, brand_code, name, qty_total_on_hand, average_cost,
                    inventory_lot_flag, retail_price_flag, whole_sale_price_flag)
                VALUES ({sku}, '01', '01', '01', '0001', '0001', 'Snapshot Probe', 7, 4.3650, false, false, false);
                """);
        }

        var factory = new XOptiApiFactory(fixture);
        using var manager = new TestClient(factory);
        await manager.FetchCsrfTokenAsync();
        await manager.SignInAsync("manager", SeedData.Password);
        var response = await manager.PostAsync("/api/v1/inventory/stock-takes", new
        {
            name = "Frozen count", branchCode = (string?)null, reason = "monthly count",
        });
        if (response.StatusCode != HttpStatusCode.Created)
        {
            var exceptions = string.Join("\n", factory.Logs.Snapshot()
                .Where(entry => entry.Exception is not null)
                .Select(entry => entry.Exception!.ToString()));
            Assert.Fail($"{response.StatusCode}: {await response.Content.ReadAsStringAsync()}\n{exceptions}");
        }
        using var body = JsonDocument.Parse(await response.Content.ReadAsStringAsync());
        var headerId = body.RootElement.GetProperty("id").GetInt32();
        Assert.True(body.RootElement.GetProperty("rowCount").GetInt32() >= 1);
        Assert.Equal(1, body.RootElement.GetProperty("status").GetInt32());

        decimal computerQty;
        await using (var context = fixture.NewContext())
        {
            computerQty = (decimal)(await context.StockTakeDetails.AsNoTracking()
                .SingleAsync(row => row.HeaderId == headerId && row.Sku == sku)).ComputerQty!;
        }
        Assert.Equal(7m, computerQty);

        await using (var change = fixture.NewContext())
        {
            await change.Database.ExecuteSqlInterpolatedAsync(
                $"UPDATE public.inventory SET qty_total_on_hand = 2 WHERE sku = {sku}");
        }

        await using (var verify = fixture.NewContext())
        {
            var frozen = await verify.StockTakeDetails.AsNoTracking()
                .SingleAsync(row => row.HeaderId == headerId && row.Sku == sku);
            Assert.Equal(7m, (decimal)frozen.ComputerQty!); // snapshot did not follow the change
            Assert.Null(frozen.PhysicalQty);
            Assert.True(await verify.AuditLogs.AnyAsync(row =>
                row.EntityId == headerId.ToString() && row.Action == "stocktake.freeze"));
        }
    }
}
