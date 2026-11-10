using Microsoft.Extensions.DependencyInjection;
using xOpti.Application.Authorization;
using xOpti.Application.Common;
using xOpti.Application.Pipeline;
using xOpti.Application.Tests.Support;

namespace xOpti.Application.Tests.Pipeline;

public class BehaviorOrderTests
{
    [Fact]
    public void ConfiguredChainIsPermissionValidationIdempotencyTransaction()
    {
        var provider = TestProviders.BuildDefaults(out _, out _, out _, out _);

        var behaviors = provider
            .GetServices<IBehavior<SampleCommand, string>>()
            .Select(b => b.GetType().Name)
            .ToList();

        Assert.Equal(
            new[] { "PermissionBehavior`2", "ValidationBehavior`2", "IdempotencyBehavior`2", "TransactionBehavior`2" },
            behaviors);
    }

    [Fact]
    public async Task PermissionRunsBeforeIdempotencyAndTransaction()
    {
        var principal = new FakePrincipal(); // no permissions
        var store = new FakeIdempotencyStore();
        var uow = new FakeUnitOfWork();
        var provider = TestProviders.Build(principal, uow, store, new FakeExecutionLog());
        var dispatcher = provider.GetRequiredService<IRequestDispatcher>();

        await Assert.ThrowsAsync<AuthorizationFailedException>(() =>
            dispatcher.DispatchAsync(new DualGuardCommand("k1", PermissionNames.ReportFinancial)));

        Assert.Equal(0, store.AcquireCalls);
        Assert.Equal(0, uow.Started);
    }

    [Fact]
    public async Task PermissionGrantedThenIdempotencyThenTransactionRun()
    {
        var principal = new FakePrincipal(PermissionNames.ReportFinancial);
        var store = new FakeIdempotencyStore();
        var uow = new FakeUnitOfWork();
        var provider = TestProviders.Build(principal, uow, store, new FakeExecutionLog());
        var dispatcher = provider.GetRequiredService<IRequestDispatcher>();

        var result = await dispatcher.DispatchAsync(new DualGuardCommand("k1", PermissionNames.ReportFinancial));

        Assert.Equal("dual", result);
        Assert.Equal(1, store.AcquireCalls);
        Assert.Equal(1, uow.Started);
    }

    [Fact]
    public async Task ValidationRunsBeforeIdempotencyAndTransaction()
    {
        var provider = TestProviders.BuildDefaults(out _, out var uow, out var store, out var log);
        var dispatcher = provider.GetRequiredService<IRequestDispatcher>();

        await Assert.ThrowsAsync<ValidationFailedException>(() =>
            dispatcher.DispatchAsync(new SampleCommand("needs-validation-failure")));

        Assert.Equal(0, store.AcquireCalls);
        Assert.Equal(0, uow.Started);
        Assert.Equal(0, log.CommandsExecuted);
    }
}
