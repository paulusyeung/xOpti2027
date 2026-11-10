using Microsoft.Extensions.DependencyInjection;
using xOpti.Application.Common;
using xOpti.Application.Pipeline;
using xOpti.Application.Ports;
using xOpti.Application.Tests.Support;

namespace xOpti.Application.Tests.Pipeline;

public sealed record SlowCommand(string IdemKey) : ICommand<string>, IRequiresIdempotencyKey, IHasPermissions
{
    public string? IdempotencyKey => IdemKey;

    public IReadOnlyList<string> RequiredPermissions => Array.Empty<string>();

    public static TaskCompletionSource Gate = new(TaskCreationOptions.RunContinuationsAsynchronously);

    public static int Started;
}

public sealed class SlowCommandHandler : IRequestHandler<SlowCommand, string>
{
    public async Task<string> Handle(SlowCommand request, CancellationToken cancellationToken)
    {
        SlowCommand.Started++;
        await SlowCommand.Gate.Task;
        return "slow-posted";
    }
}

public class IdempotencyBehaviorTests
{
    private static ServiceProvider BuildWithSlow(out FakeIdempotencyStore store, out FakeUnitOfWork uow)
    {
        var services = new ServiceCollection();
        services.AddXOptiApplication();
        services.AddScoped<ICurrentPrincipal>(_ => new FakePrincipal());
        var u = new FakeUnitOfWork();
        var s = new FakeIdempotencyStore();
        services.AddSingleton<IUnitOfWork>(u);
        services.AddSingleton<IIdempotencyStore>(s);
        services.AddTransient<IRequestHandler<SlowCommand, string>, SlowCommandHandler>();
        uow = u;
        store = s;
        return services.BuildServiceProvider();
    }

    [Fact]
    public async Task MissingKey_IsRejectedBeforeExecution()
    {
        var provider = TestProviders.BuildDefaults(out _, out var uow, out var store, out var log);
        var dispatcher = provider.GetRequiredService<IRequestDispatcher>();

        var error = await Assert.ThrowsAsync<ValidationFailedException>(() =>
            dispatcher.DispatchAsync(new SampleCommand(null)));

        Assert.Contains("idempotency key", error.Errors[0].Message, StringComparison.OrdinalIgnoreCase);
        Assert.Equal(0, log.CommandsExecuted);
        Assert.Equal(0, uow.Started);
        Assert.Equal(0, store.AcquireCalls);
    }

    [Fact]
    public async Task Replay_ReturnsOriginalResult_WithoutReexecution()
    {
        var store = new FakeIdempotencyStore();
        await store.TryAcquireAsync("k1", CancellationToken.None);
        await store.SaveResultAsync("k1", "posted:1", CancellationToken.None);

        var provider = TestProviders.Build(new FakePrincipal(), new FakeUnitOfWork(), store, new FakeExecutionLog());
        var dispatcher = provider.GetRequiredService<IRequestDispatcher>();

        var result = await dispatcher.DispatchAsync(new SampleCommand("k1"));

        Assert.Equal("posted:1", result);
    }

    [Fact]
    public async Task ConcurrentDuplicate_ConflictWithoutDoublePosting()
    {
        SlowCommand.Gate = new TaskCompletionSource(TaskCreationOptions.RunContinuationsAsynchronously);
        SlowCommand.Started = 0;

        var provider = BuildWithSlow(out var store, out var uow);
        var dispatcher = provider.GetRequiredService<IRequestDispatcher>();

        var first = dispatcher.DispatchAsync(new SlowCommand("dup-key"));
        await WaitUntil(() => SlowCommand.Started == 1);

        var second = dispatcher.DispatchAsync(new SlowCommand("dup-key"));
        await Assert.ThrowsAsync<IdempotencyConflictException>(() => second);

        SlowCommand.Gate.SetResult();
        Assert.Equal("slow-posted", await first);

        Assert.Equal(1, uow.Started);
        var replay = await dispatcher.DispatchAsync(new SlowCommand("dup-key"));
        Assert.Equal("slow-posted", replay);
    }

    [Fact]
    public async Task FailedExecution_ReleasesReservationForRetry()
    {
        var provider = TestProviders.BuildDefaults(out _, out _, out var store, out var log);
        var dispatcher = provider.GetRequiredService<IRequestDispatcher>();

        await Assert.ThrowsAsync<InvalidOperationException>(() =>
            dispatcher.DispatchAsync(new SampleCommand("k-retry", ShouldFail: true)));

        // Reservation was released: a retry with the same key re-executes.
        var result = await dispatcher.DispatchAsync(new SampleCommand("k-retry"));
        Assert.Equal("posted:2", result);
        Assert.Equal(2, log.CommandsExecuted);
        Assert.True(store.IsReserved("k-retry"));
    }

    private static async Task WaitUntil(Func<bool> condition, int timeoutMs = 2000)
    {
        var start = Environment.TickCount;
        while (!condition())
        {
            if (Environment.TickCount - start > timeoutMs)
            {
                throw new TimeoutException("condition never became true");
            }

            await Task.Delay(10);
        }
    }
}
