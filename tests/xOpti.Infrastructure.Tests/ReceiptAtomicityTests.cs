using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using xOpti.Application.Ports;
using xOpti.Application.Purchasing.ReceiveStock;
using xOpti.Infrastructure;
using xOpti.Infrastructure.Persistence;
using xOpti.Infrastructure.Tests.Support;

namespace xOpti.Infrastructure.Tests;

[Collection("postgres")]
public class ReceiptAtomicityTests(PostgresFixture fixture)
{
    [Fact]
    public async Task ForcedFailure_RollsBackBothLotAndInventoryTotals()
    {
        var sku = "A" + Guid.NewGuid().ToString("N")[..8].ToUpperInvariant();
        var txNumber = "SR" + Guid.NewGuid().ToString("N")[..8];
        const string lotNo = "ATOMIC01";

        await using (var seed = fixture.NewContext())
        {
            await seed.Database.ExecuteSqlRawAsync("""
                INSERT INTO public.supplier (supplier_code, supplier_name)
                VALUES ('0001', 'Atomic Supplier') ON CONFLICT (supplier_code) DO NOTHING;
                """);
            await seed.Database.ExecuteSqlInterpolatedAsync($"""
                INSERT INTO public.inventory (sku, department_code, class_code, category_code,
                    supplier_code, brand_code, name, qty_total_on_hand,
                    inventory_lot_flag, retail_price_flag, whole_sale_price_flag)
                VALUES ({sku}, '01', '01', '01', '0001', '0001', 'Atomic', 3, true, false, false)
                ON CONFLICT (sku) DO NOTHING;
                """);
        }

        var services = new ServiceCollection();
        services.AddXOptiInfrastructure(new InfrastructureOptions { ConnectionString = fixture.ConnectionString });
        await using var provider = services.BuildServiceProvider();

        using (var scope = provider.CreateScope())
        {
            var uow = scope.ServiceProvider.GetRequiredService<IUnitOfWork>();
            var store = scope.ServiceProvider.GetRequiredService<IReceiptStore>();

            await Assert.ThrowsAsync<InvalidOperationException>(() =>
                uow.ExecuteInTransactionAsync<object?>(async ct =>
                {
                    await store.PostAsync(new ReceiptPosting(
                        txNumber, "00000999", "0001", "01",
                        new[] { new ReceiveStockLine(sku, lotNo, 5, 4.3650m, 0m, 0m, "N") },
                        21.8250m, 0m, 5), ct);
                    throw new InvalidOperationException("forced posting failure");
                }, CancellationToken.None));
        }

        await using var verify = fixture.NewContext();
        var inventory = await verify.InventoryItems.SingleAsync(row => row.Sku == sku);
        Assert.Equal(3, inventory.QtyTotalOnHand); // unchanged
        Assert.False(await verify.LotRecords.AnyAsync(row => row.Sku == sku && row.LotNo == lotNo));
        Assert.False(await verify.TxHeaders.AnyAsync(row => row.TxNumber == txNumber));
        Assert.False(await verify.BranchInventory.AnyAsync(row => row.Sku == sku));
    }
}
