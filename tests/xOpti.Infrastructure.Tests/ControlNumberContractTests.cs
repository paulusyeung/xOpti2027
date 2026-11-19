using Microsoft.EntityFrameworkCore;
using xOpti.Domain.Values;
using xOpti.Infrastructure.Persistence;
using xOpti.Infrastructure.Persistence.Entities;
using xOpti.Infrastructure.Tests.Support;

namespace xOpti.Infrastructure.Tests;

[Collection("postgres")]
public class ControlNumberContractTests(PostgresFixture fixture)
{
    [Fact]
    public async Task Allocator_ReturnsStoredNextNumber_ThenAdvances()
    {
        await using (var seed = fixture.NewContext())
        {
            var row = await seed.PrefTxNumbers.SingleAsync(item => item.TxPrefix == "RC");
            row.TxNextNumber = 5000;
            await seed.SaveChangesAsync();
        }

        await using var context = fixture.NewContext();
        var allocator = new PostgresControlNumberAllocator(context);
        var allocated = await allocator.AllocateAsync(TransactionType.RetailInvoice, default);
        Assert.Equal("RC00005000", allocated.Value);

        await using var verify = fixture.NewContext();
        Assert.Equal(5001, (await verify.PrefTxNumbers.SingleAsync(
            item => item.TxPrefix == "RC")).TxNextNumber);
    }

}
