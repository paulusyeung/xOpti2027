using xOpti.Infrastructure.Platform;
using System.Security.Claims;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using xOpti.Application.Authorization;
using xOpti.Application.Ports;
using xOpti.Domain.Values;
using xOpti.Infrastructure.Persistence;
using xOpti.Infrastructure.Persistence.Entities;
using xOpti.Infrastructure.Tests.Support;

namespace xOpti.Infrastructure.Tests;

[Collection("postgres")]
public class ControlNumberAllocatorTests(PostgresFixture fixture)
{
    [Fact]
    public async Task FiftyConcurrent_AllocationsAreDistinctAndIncreasing()
    {
        var results = await Task.WhenAll(Enumerable.Range(1, 50).Select(async _ =>
        {
            await using var ctx = fixture.NewContext();
            var allocator = new xOpti.Infrastructure.PostgresControlNumberAllocator(ctx);
            return await allocator.AllocateAsync(TransactionType.RetailInvoice, CancellationToken.None);
        }));

        var sequences = results.Select(c => (int)c.Sequence).OrderBy(s => s).ToList();

        Assert.Equal(50, sequences.Distinct().Count());

        // Seeded at 1000: contiguous monotonic block, no lost updates.
        var first = sequences[0];
        Assert.Equal(Enumerable.Range(first, 50), sequences);

        // Row holds the high-water value above all allocated numbers.
        await using var verify = fixture.NewContext();
        var row = await verify.PrefTxNumbers.SingleAsync(p => p.TxPrefix == "RC");
        Assert.True(row.TxNextNumber >= sequences[^1]);
    }

    [Fact]
    public async Task CountersStaySynchronized_PerFamily()
    {
        await using var ctx = fixture.NewContext();
        var allocator = new xOpti.Infrastructure.PostgresControlNumberAllocator(ctx);

        var before = await ctx.PrefTxNumbers.SingleAsync(p => p.TxPrefix == "WC");
        var number = await allocator.AllocateAsync(TransactionType.WholesaleInvoice, CancellationToken.None);

        await using var verify = fixture.NewContext();
        var after = await verify.PrefTxNumbers.SingleAsync(p => p.TxPrefix == "WC");
        Assert.Equal(before.TxNextNumber + 1, after.TxNextNumber);
        Assert.Equal(after.TxNextNumber, number.Sequence);
        Assert.Equal("WC", number.Family.ToLegacyCode());
    }

    [Fact]
    public async Task FailingPosting_DoesNotConsumeNumber()
    {
        await using var ctx = fixture.NewContext();
        var uow = new xOpti.Infrastructure.EfUnitOfWork(ctx);

        var before = await ctx.PrefTxNumbers.SingleAsync(p => p.TxPrefix == "SR");

        await Assert.ThrowsAsync<InvalidOperationException>(async () =>
            await uow.ExecuteInTransactionAsync<int>(async ct =>
            {
                var allocator = new xOpti.Infrastructure.PostgresControlNumberAllocator(ctx);
                await allocator.AllocateAsync(TransactionType.StockReceived, ct);
                throw new InvalidOperationException("posting failed");
            }, CancellationToken.None));

        await using var verify = fixture.NewContext();
        var after = await verify.PrefTxNumbers.SingleAsync(p => p.TxPrefix == "SR");
        Assert.Equal(before.TxNextNumber, after.TxNextNumber);
    }
}

[Collection("postgres")]
public class IdempotencyStoreTests(PostgresFixture fixture)
{
    private static DbIdempotencyStore NewStore(XOptiDbContext ctx, TimeSpan? retention = null) =>
        new(ctx, new xOpti.Infrastructure.Platform.IdempotencyStoreOptions(retention ?? TimeSpan.FromHours(24)));

    [Fact]
    public async Task FirstAcquire_Succeeds_AndSavedResultReplays()
    {
        await using var ctx = fixture.NewContext();
        var store = NewStore(ctx);

        var acquired = await store.TryAcquireAsync("sale-abc", CancellationToken.None);
        Assert.Equal(IdempotencyAcquisition.Acquired, acquired.Outcome);

        await store.SaveResultAsync("sale-abc", (object)"posted:42", CancellationToken.None);

        await using var ctx2 = fixture.NewContext();
        var replayed = await NewStore(ctx2).TryAcquireAsync("sale-abc", CancellationToken.None);
        Assert.Equal(IdempotencyAcquisition.Replayed, replayed.Outcome);
        Assert.Equal("posted:42", replayed.CachedResult);
    }

    [Fact]
    public async Task ConcurrentLease_SecondIsRejectedAsInFlight()
    {
        await using var ctx = fixture.NewContext();
        var store = NewStore(ctx);

        var first = await store.TryAcquireAsync("dup", CancellationToken.None);
        Assert.Equal(IdempotencyAcquisition.Acquired, first.Outcome);

        await using var ctx2 = fixture.NewContext();
        var second = await NewStore(ctx2).TryAcquireAsync("dup", CancellationToken.None);
        Assert.Equal(IdempotencyAcquisition.InProgress, second.Outcome);
    }

    [Fact]
    public async Task ReleasedLease_CanBeReacquired()
    {
        await using var ctx = fixture.NewContext();
        var store = NewStore(ctx);

        await store.TryAcquireAsync("retry", CancellationToken.None);
        await store.ReleaseAsync("retry", CancellationToken.None);

        await using var ctx2 = fixture.NewContext();
        var again = await NewStore(ctx2).TryAcquireAsync("retry", CancellationToken.None);
        Assert.Equal(IdempotencyAcquisition.Acquired, again.Outcome);
    }

    [Fact]
    public async Task ExpiredLease_IsEvictedByNewAcquisition()
    {
        await using (var ctx = fixture.NewContext())
        {
            ctx.IdempotencyRecords.Add(new IdempotencyRecord
            {
                Key = "expired-1",
                Status = "completed",
                Payload = "\"old\"",
                ResultType = typeof(string).AssemblyQualifiedName,
                CreatedAt = DateTimeOffset.UtcNow.AddDays(-2),
                ExpiresAt = DateTimeOffset.UtcNow.AddDays(-1),
            });
            await ctx.SaveChangesAsync();
        }

        await using var ctx2 = fixture.NewContext();
        var store = NewStore(ctx2, TimeSpan.FromHours(24));
        var acquired = await store.TryAcquireAsync("expired-1", CancellationToken.None);

        Assert.Equal(IdempotencyAcquisition.Acquired, acquired.Outcome);
    }
}

[Collection("postgres")]
public class AuditInterceptorTests(PostgresFixture fixture)
{
    private ServiceProvider BuildProvider()
    {
        var services = new ServiceCollection();
        services.AddXOptiInfrastructure(new InfrastructureOptions { ConnectionString = fixture.ConnectionString });
        services.AddScoped<ICurrentPrincipal>(_ => new xOpti.Infrastructure.ClaimsCurrentPrincipal(
            new ClaimsPrincipal(new ClaimsIdentity(new[]
            {
                new Claim(ClaimTypes.NameIdentifier, "staff-9"),
                new Claim(xOpti.Infrastructure.ClaimsCurrentPrincipal.BranchClaimType, "01"),
            }))));
        return services.BuildServiceProvider();
    }

    [Fact]
    public async Task InventoryLotAdjustment_ProducesOneAuditEntry_WithBeforeAfterAndAttribution()
    {
        var provider = BuildProvider();

        await using (var scope = provider.CreateAsyncScope())
        {
            var ctx = scope.ServiceProvider.GetRequiredService<XOptiDbContext>();
            if (!await ctx.LotRecords.AnyAsync(l => l.Sku == "30110998"))
            {
                ctx.LotRecords.Add(new InvtLotRecord
                {
                    Sku = "30110998",
                    LotNo = "SR00009998",
                    DateReceived = DateTimeOffset.UtcNow,
                    SupplierCode = "0001",
                    QtyPurchased = 10,
                    QtyOnHand = 10,
                    UnitAmountPurchased = Money.From(4.365m),
                });
                await ctx.SaveChangesAsync();
            }
        }

        await using (var scope = provider.CreateAsyncScope())
        {
            var ctx = scope.ServiceProvider.GetRequiredService<XOptiDbContext>();
            var lot = await ctx.LotRecords.SingleAsync(l => l.Sku == "30110998");
            lot.QtyOnHand = 6;
            await ctx.SaveChangesAsync();
        }

        await using var verify = provider.CreateAsyncScope();
        var vctx = verify.ServiceProvider.GetRequiredService<XOptiDbContext>();
        var entries = await vctx.AuditLogs
            .Where(a => a.EntityType == nameof(InvtLotRecord)
                     && a.EntityId.Contains("30110998")
                     && a.Action == "update")
            .ToListAsync();

        Assert.Single(entries);
        var entry = entries[0];
        Assert.Equal("staff-9", entry.ActorUserId);
        Assert.Equal("01", entry.ActorBranch);
        Assert.Equal("update", entry.Action);
        Assert.Contains("6", entry.Details);
        Assert.Contains("10", entry.Details);
    }

    [Fact]
    public async Task CustomerPiiColumns_AreExcludedFromAuditPayloads()
    {
        var provider = BuildProvider();

        await using (var scope = provider.CreateAsyncScope())
        {
            var ctx = scope.ServiceProvider.GetRequiredService<XOptiDbContext>();
            if (!await ctx.Customers.AnyAsync(c => c.Id == 999001))
            {
                ctx.Customers.Add(new Customer
                {
                    Id = 999001,
                    FullName = "Test Person",
                    Email = "before@example.com",
                    HomePhone = "604-555-0100",
                    CreditLimit = Money.From(100m),
                });
                await ctx.SaveChangesAsync();
            }
        }

        await using (var scope = provider.CreateAsyncScope())
        {
            var ctx = scope.ServiceProvider.GetRequiredService<XOptiDbContext>();
            var customer = await ctx.Customers.SingleAsync(c => c.Id == 999001);
            customer.Email = "after@example.com";
            customer.HomePhone = "604-555-9999";
            customer.CreditLimit = Money.From(250m);
            await ctx.SaveChangesAsync();
        }

        await using var verify = provider.CreateAsyncScope();
        var vctx = verify.ServiceProvider.GetRequiredService<XOptiDbContext>();
        var entries = await vctx.AuditLogs
            .Where(a => a.EntityType == nameof(Customer) && a.EntityId == "999001")
            .ToListAsync();

        Assert.NotEmpty(entries);
        var details = string.Join('\n', entries.Select(e => e.Details));
        Assert.Contains("CreditLimit", details);
        Assert.DoesNotContain("after@example.com", details);
        Assert.DoesNotContain("555-9999", details);
    }
}

public class PrincipalAdapterTests
{
    [Fact]
    public void ExtractsPermissionsBranchAndUserId()
    {
        var identity = new ClaimsIdentity(new[]
        {
            new Claim(ClaimTypes.NameIdentifier, "u1"),
            new Claim(xOpti.Infrastructure.ClaimsCurrentPrincipal.BranchClaimType, "02"),
            new Claim(xOpti.Infrastructure.ClaimsCurrentPrincipal.PermissionClaimType, PermissionNames.CostView),
            new Claim(xOpti.Infrastructure.ClaimsCurrentPrincipal.PermissionClaimType, PermissionNames.SalesInvoicePost),
        });

        var principal = new xOpti.Infrastructure.ClaimsCurrentPrincipal(new ClaimsPrincipal(identity));

        Assert.Equal("u1", principal.UserId);
        Assert.Equal("02", principal.BranchCode);
        Assert.True(principal.HasPermission(PermissionNames.CostView));
        Assert.True(principal.HasPermission("sales:invoice-post"));
        Assert.False(principal.HasPermission(PermissionNames.InventoryAdjust));
    }

    [Fact]
    public void SystemClock_IsUtc()
    {
        var clock = new xOpti.Infrastructure.SystemClock();
        Assert.Equal(TimeSpan.Zero, clock.UtcNow.Offset);
        Assert.True(clock.UtcNow <= DateTimeOffset.UtcNow);
    }
}
