using System.Net;
using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using xOpti.Api.IntegrationTests.Support;

namespace xOpti.Api.IntegrationTests;

[Collection("api")]
public sealed class StockTakePostingTests(ApiPostgresFixture fixture)
{
    private async Task<TestClient> ManagerAsync()
    {
        var client = new TestClient(new XOptiApiFactory(fixture));
        await client.FetchCsrfTokenAsync();
        Assert.Equal(HttpStatusCode.OK, (await client.SignInAsync("manager", SeedData.Password)).Status);
        return client;
    }

    [Fact]
    public async Task ApprovedVariances_PostAsOneReferencedSJ_AndCannotPostTwice()
    {
        using var manager = await ManagerAsync();
        var create = await manager.PostAsync("/api/v1/inventory/stock-takes", new
        {
            name = "Post variances", branchCode = (string?)null, reason = "posting test",
        });
        using var createBody = JsonDocument.Parse(await create.Content.ReadAsStringAsync());
        var headerId = createBody.RootElement.GetProperty("id").GetInt32();

        int before;
        await using (var context = fixture.NewContext())
        {
            before = (await context.InventoryItems.SingleAsync(row => row.Sku == "30110359")).QtyTotalOnHand;
        }

        var count = await manager.PostAsync($"/api/v1/inventory/stock-takes/{headerId}/counts", new
        {
            csv = "sku,qty\n30110359,2", dryRun = false, reason = "counted",
        });
        Assert.Equal(HttpStatusCode.OK, count.StatusCode);

        var notApproved = await manager.PostAsync($"/api/v1/inventory/stock-takes/{headerId}/post", new
        {
            reason = "too early",
        });
        Assert.Equal(HttpStatusCode.BadRequest, notApproved.StatusCode);

        await manager.PostAsync($"/api/v1/inventory/stock-takes/{headerId}/approve", new { reason = "approved" });
        var post = await manager.PostAsync($"/api/v1/inventory/stock-takes/{headerId}/post", new
        {
            reason = "post approved variance",
        });
        Assert.Equal(HttpStatusCode.OK, post.StatusCode);
        using var postBody = JsonDocument.Parse(await post.Content.ReadAsStringAsync());
        var txNumber = postBody.RootElement.GetProperty("txNumber").GetString()!;
        Assert.StartsWith("SJ", txNumber);

        await using (var context = fixture.NewContext())
        {
            var expectedDelta = 2 - before;
            Assert.Equal(before + expectedDelta,
                (await context.InventoryItems.SingleAsync(row => row.Sku == "30110359")).QtyTotalOnHand);
            var header = await context.TxHeaders.SingleAsync(row => row.TxNumber == txNumber);
            Assert.Equal($"STK{headerId}", header.RefNumber);
            Assert.Equal((short)3, (await context.StockTakeHeaders.SingleAsync(row => row.Id == headerId)).Status ?? 0);
            Assert.True(await context.AuditLogs.AnyAsync(entry =>
                entry.EntityId == headerId.ToString() && entry.Action == "stocktake.post"));
        }

        var again = await manager.PostAsync($"/api/v1/inventory/stock-takes/{headerId}/post", new
        {
            reason = "repost",
        });
        Assert.Equal(HttpStatusCode.BadRequest, again.StatusCode);
    }
}
