using System.Net;
using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using xOpti.Api.IntegrationTests.Support;

namespace xOpti.Api.IntegrationTests;

[Collection("api")]
public sealed class StockTakeCountImportTests(ApiPostgresFixture fixture)
{
    private async Task<TestClient> ManagerAsync()
    {
        var client = new TestClient(new XOptiApiFactory(fixture));
        await client.FetchCsrfTokenAsync();
        Assert.Equal(HttpStatusCode.OK, (await client.SignInAsync("manager", SeedData.Password)).Status);
        return client;
    }

    [Fact]
    public async Task CountImport_RejectsInvalidRows_AndDryRunWritesNothing()
    {
        using var manager = await ManagerAsync();
        var create = await manager.PostAsync("/api/v1/inventory/stock-takes", new
        {
            name = "Count import", branchCode = (string?)null, reason = "monthly count",
        });
        Assert.Equal(HttpStatusCode.Created, create.StatusCode);
        using var createBody = JsonDocument.Parse(await create.Content.ReadAsStringAsync());
        var headerId = createBody.RootElement.GetProperty("id").GetInt32();

        var invalid = await manager.PostAsync($"/api/v1/inventory/stock-takes/{headerId}/counts", new
        {
            csv = "sku,qty\nNOPE999,4", dryRun = true, reason = "invalid count",
        });
        var invalidBody = await invalid.Content.ReadAsStringAsync();
        Assert.Contains("not in the frozen snapshot", invalidBody);

        await using (var context = fixture.NewContext())
        {
            Assert.Equal(0, await context.StockTakeImports.CountAsync(row => row.HeaderId == headerId));
        }

        var dryRun = await manager.PostAsync($"/api/v1/inventory/stock-takes/{headerId}/counts", new
        {
            csv = "sku,qty\n30110359,4", dryRun = true, reason = "dry run",
        });
        Assert.Equal(HttpStatusCode.OK, dryRun.StatusCode);
        using var dryBody = JsonDocument.Parse(await dryRun.Content.ReadAsStringAsync());
        Assert.Equal(1, dryBody.RootElement.GetProperty("accepted").GetInt32());
        await using (var context = fixture.NewContext())
        {
            Assert.Equal(0, await context.StockTakeImports.CountAsync(row => row.HeaderId == headerId));
        }

        var confirm = await manager.PostAsync($"/api/v1/inventory/stock-takes/{headerId}/counts", new
        {
            csv = "sku,qty\n30110359,4", dryRun = false, reason = "confirmed count",
        });
        using var confirmBody = JsonDocument.Parse(await confirm.Content.ReadAsStringAsync());
        Assert.Equal(1, confirmBody.RootElement.GetProperty("accepted").GetInt32());
        await using (var verify = fixture.NewContext())
        {
            var row = await verify.StockTakeImports.SingleAsync(item => item.HeaderId == headerId);
            Assert.Equal(4, row.Qty);
            Assert.True(await verify.AuditLogs.AnyAsync(entry =>
                entry.EntityId == headerId.ToString() && entry.Action == "stocktake.count-import"));
        }
    }
}
