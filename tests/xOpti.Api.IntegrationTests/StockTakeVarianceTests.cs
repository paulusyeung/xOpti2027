using System.Net;
using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using xOpti.Api.IntegrationTests.Support;

namespace xOpti.Api.IntegrationTests;

[Collection("api")]
public sealed class StockTakeVarianceTests(ApiPostgresFixture fixture)
{
    private async Task<TestClient> ManagerAsync()
    {
        var client = new TestClient(new XOptiApiFactory(fixture));
        await client.FetchCsrfTokenAsync();
        Assert.Equal(HttpStatusCode.OK, (await client.SignInAsync("manager", SeedData.Password)).Status);
        return client;
    }

    [Fact]
    public async Task VarianceApproval_DoesNotChangeInventory()
    {
        using var manager = await ManagerAsync();
        var create = await manager.PostAsync("/api/v1/inventory/stock-takes", new
        {
            name = "Variance test", branchCode = (string?)null, reason = "variance review",
        });
        using var createBody = JsonDocument.Parse(await create.Content.ReadAsStringAsync());
        var headerId = createBody.RootElement.GetProperty("id").GetInt32();

        int before;
        await using (var context = fixture.NewContext())
        {
            before = (await context.InventoryItems.SingleAsync(row => row.Sku == "30110359")).QtyTotalOnHand;
        }

        await manager.PostAsync($"/api/v1/inventory/stock-takes/{headerId}/counts", new
        {
            csv = "sku,qty\n30110359,3", dryRun = false, reason = "counted",
        });

        var variances = await manager.GetAsync($"/api/v1/inventory/stock-takes/{headerId}/variances");
        Assert.Equal(HttpStatusCode.OK, variances.StatusCode);
        using var varianceBody = JsonDocument.Parse(await variances.Content.ReadAsStringAsync());
        var row = varianceBody.RootElement.GetProperty("rows").EnumerateArray()
            .Single(item => item.GetProperty("sku").GetString() == "30110359");
        Assert.Equal(3, row.GetProperty("countedQty").GetInt32());
        Assert.True(row.GetProperty("difference").GetDecimal() != 0);

        await using (var context = fixture.NewContext())
        {
            Assert.Equal(before, (await context.InventoryItems.SingleAsync(item => item.Sku == "30110359")).QtyTotalOnHand);
        }

        var approve = await manager.PostAsync($"/api/v1/inventory/stock-takes/{headerId}/approve", new
        {
            reason = "approved variance",
        });
        Assert.Equal(HttpStatusCode.OK, approve.StatusCode);
        using var approveBody = JsonDocument.Parse(await approve.Content.ReadAsStringAsync());
        Assert.Equal(2, approveBody.RootElement.GetProperty("status").GetInt32());

        await using (var verify = fixture.NewContext())
        {
            Assert.Equal(before, (await verify.InventoryItems.SingleAsync(item => item.Sku == "30110359")).QtyTotalOnHand);
            Assert.True(await verify.AuditLogs.AnyAsync(entry =>
                entry.EntityId == headerId.ToString() && entry.Action == "stocktake.approve"));
        }
    }
}
