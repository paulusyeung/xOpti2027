using System.Net;
using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using xOpti.Api.IntegrationTests.Support;
using xOpti.Application.Inventory.TransferStock;
using xOpti.Application.Ports;
using xOpti.Infrastructure;

namespace xOpti.Api.IntegrationTests;

[Collection("api")]
public sealed class TransferStockTests(ApiPostgresFixture fixture)
{
    private async Task<TestClient> ManagerAsync()
    {
        var client = new TestClient(new XOptiApiFactory(fixture));
        await client.FetchCsrfTokenAsync();
        Assert.Equal(HttpStatusCode.OK, (await client.SignInAsync("manager", SeedData.Password)).Status);
        return client;
    }

    private async Task SeedAsync(string sku)
    {
        await using var context = fixture.NewContext();
        await context.Database.ExecuteSqlRawAsync("""
            INSERT INTO public.preference (serial_number, number_of_user, platform, product_name,
                user_name, owner_name, branch_number, pst_number, gst_number,
                next_invt_control_number, next_invt_sku, next_invoice_number, next_sales_order_number)
            VALUES ('0000000001', 1, 'xOpti', 'Synergy', 'Operator', 'Owner', '0001', '', '', 400, 1, 1, 1)
            ON CONFLICT (serial_number) DO NOTHING;
            """);
        await context.Database.ExecuteSqlInterpolatedAsync($"""
            INSERT INTO public.branch_inventory (branch_code, sku, qty_on_hand)
            VALUES ('01', {sku}, 10), ('02', {sku}, 2)
            ON CONFLICT (branch_code, sku) DO UPDATE SET qty_on_hand = EXCLUDED.qty_on_hand;
            """);
    }

    [Fact]
    public async Task Transfer_PostsPairedMovementsSharingOneIdentifier()
    {
        var sku = "30110359";
        await SeedAsync(sku);
        using var manager = await ManagerAsync();

        var response = await manager.PostAsync("/api/v1/inventory/transfers", new
        {
            sku, fromBranch = "01", toBranch = "02", quantity = 3, reason = "branch transfer",
        }, idempotencyKey: "tr-" + Guid.NewGuid().ToString("N"));
        Assert.Equal(HttpStatusCode.Created, response.StatusCode);
        using var body = JsonDocument.Parse(await response.Content.ReadAsStringAsync());
        var transferId = body.RootElement.GetProperty("transferId").GetString()!;
        var source = body.RootElement.GetProperty("sourceTxNumber").GetString()!;
        var destination = body.RootElement.GetProperty("destinationTxNumber").GetString()!;

        await using var context = fixture.NewContext();
        Assert.Equal(7, (await context.BranchInventory.SingleAsync(row => row.BranchCode == "01" && row.Sku == sku)).QtyOnHand);
        Assert.Equal(5, (await context.BranchInventory.SingleAsync(row => row.BranchCode == "02" && row.Sku == sku)).QtyOnHand);
        Assert.Equal(2, await context.TxHeaders.CountAsync(row => row.TrackingNumber == transferId));
        Assert.Contains(source, new[] { source, destination });
        Assert.True(await context.AuditLogs.AnyAsync(row => row.EntityId == transferId && row.Action == "stock.transfer"));
    }

    [Fact]
    public async Task ForcedDestinationFailure_RollsBackTheSourceDecrease()
    {
        var sku = "30110359";
        await SeedAsync(sku);

        var services = new ServiceCollection();
        services.AddXOptiInfrastructure(new InfrastructureOptions { ConnectionString = fixture.ConnectionString });
        await using var provider = services.BuildServiceProvider();
        using var scope = provider.CreateScope();
        var uow = scope.ServiceProvider.GetRequiredService<IUnitOfWork>();
        var store = scope.ServiceProvider.GetRequiredService<ITransferStore>();

        await Assert.ThrowsAsync<InvalidOperationException>(() =>
            uow.ExecuteInTransactionAsync<object?>(async ct =>
            {
                await store.PostAsync(new TransferPosting("TRFAIL0001", "SJ99990001", "SJ99990002",
                    "00000999", sku, "01", "02", 4, "forced failure"), ct);
                throw new InvalidOperationException("forced destination failure");
            }, CancellationToken.None));

        await using var verify = fixture.NewContext();
        Assert.Equal(10, (await verify.BranchInventory.SingleAsync(row => row.BranchCode == "01" && row.Sku == sku)).QtyOnHand);
        Assert.Equal(2, (await verify.BranchInventory.SingleAsync(row => row.BranchCode == "02" && row.Sku == sku)).QtyOnHand);
        Assert.False(await verify.TxHeaders.AnyAsync(row => row.TrackingNumber == "TRFAIL0001"));
    }
}
