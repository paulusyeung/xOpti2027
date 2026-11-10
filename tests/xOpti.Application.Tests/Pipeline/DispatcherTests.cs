using FluentValidation;
using Microsoft.Extensions.DependencyInjection;
using xOpti.Application;
using xOpti.Application.Authorization;
using xOpti.Application.Common;
using xOpti.Application.Pipeline;
using xOpti.Application.Ports;
using xOpti.Application.Tests.Support;

namespace xOpti.Application.Tests.Pipeline;

public static class TestProviders
{
    public static ServiceProvider Build(
        FakePrincipal principal,
        FakeUnitOfWork uow,
        FakeIdempotencyStore store,
        FakeExecutionLog log)
    {
        var services = new ServiceCollection();
        services.AddXOptiApplication();
        services.AddScoped<ICurrentPrincipal>(_ => principal);
        services.AddSingleton<IUnitOfWork>(uow);
        services.AddSingleton<IIdempotencyStore>(store);
        services.AddSingleton(log);
        services.AddTransient<IRequestHandler<SampleCommand, string>, RecordingCommandHandler>();
        services.AddTransient<IRequestHandler<SampleQuery, string>, RecordingQueryHandler>();
        services.AddTransient<IRequestHandler<GuardedCommand, string>, GuardedCommandHandler>();
        services.AddTransient<IRequestHandler<DualGuardCommand, string>, DualGuardCommandHandler>();
        services.AddTransient<IValidator<SampleCommand>, SampleCommandValidator>();
        return services.BuildServiceProvider();
    }

    public static ServiceProvider BuildDefaults(out FakePrincipal principal, out FakeUnitOfWork uow, out FakeIdempotencyStore store, out FakeExecutionLog log)
    {
        principal = new FakePrincipal();
        uow = new FakeUnitOfWork();
        store = new FakeIdempotencyStore();
        log = new FakeExecutionLog();
        return Build(principal, uow, store, log);
    }
}

public class DispatcherTests
{
    private sealed record UnregisteredQuery : IQuery<string>;

    [Fact]
    public async Task RegisteredRequest_ExecutesExactlyOneHandler()
    {
        var provider = TestProviders.BuildDefaults(out _, out _, out _, out var log);
        var dispatcher = provider.GetRequiredService<IRequestDispatcher>();

        var result = await dispatcher.DispatchAsync(new SampleQuery("x"));

        Assert.Equal("queried", result);
        Assert.Equal(1, log.QueriesExecuted);
    }

    [Fact]
    public async Task UnknownRequestType_ThrowsDistinctUnsupportedError()
    {
        var provider = TestProviders.BuildDefaults(out _, out _, out _, out _);
        var dispatcher = provider.GetRequiredService<IRequestDispatcher>();

        var error = await Assert.ThrowsAsync<UnsupportedRequestException>(
            () => dispatcher.DispatchAsync(new UnregisteredQuery()));
        Assert.Equal(typeof(UnregisteredQuery), error.RequestType);
    }

    [Fact]
    public async Task NonRequestObject_ThrowsUnsupportedError()
    {
        var provider = TestProviders.BuildDefaults(out _, out _, out _, out _);
        var dispatcher = provider.GetRequiredService<IRequestDispatcher>();

        await Assert.ThrowsAsync<UnsupportedRequestException>(
            () => dispatcher.DispatchAsync("just a string"));
    }

    [Fact]
    public async Task CancellationToken_PropagatesToHandler()
    {
        var provider = TestProviders.BuildDefaults(out _, out _, out _, out _);
        var dispatcher = provider.GetRequiredService<IRequestDispatcher>();
        using var cts = new CancellationTokenSource();

        await dispatcher.DispatchAsync(new SampleQuery("x"), cts.Token);

        Assert.Equal(cts.Token, RecordingQueryHandler.LastTokenSeen);
    }
}

public class ValidationBehaviorTests
{
    [Fact]
    public async Task InvalidCommand_DoesNotReachHandlerOrTransaction()
    {
        var provider = TestProviders.BuildDefaults(out _, out var uow, out _, out var log);
        var dispatcher = provider.GetRequiredService<IRequestDispatcher>();

        var error = await Assert.ThrowsAsync<ValidationFailedException>(() =>
            dispatcher.DispatchAsync(new SampleCommand("needs-validation-failure")));

        Assert.Equal("IdemKey", Assert.Single(error.Errors).Field);
        Assert.Equal(0, log.CommandsExecuted);
        Assert.Equal(0, uow.Started);
    }

    [Fact]
    public async Task ValidCommand_PassesThrough()
    {
        var provider = TestProviders.BuildDefaults(out _, out _, out _, out _);
        var dispatcher = provider.GetRequiredService<IRequestDispatcher>();

        var result = await dispatcher.DispatchAsync(new SampleCommand("k1"));

        Assert.StartsWith("posted:", result);
    }
}

public class TransactionBehaviorTests
{
    [Fact]
    public async Task SuccessfulCommand_RunsInsideOneTransaction()
    {
        var provider = TestProviders.BuildDefaults(out _, out var uow, out _, out _);
        var dispatcher = provider.GetRequiredService<IRequestDispatcher>();

        await dispatcher.DispatchAsync(new SampleCommand("k1"));

        Assert.Equal(1, uow.Started);
        Assert.Equal(1, uow.Committed);
        Assert.Equal(0, uow.RolledBack);
    }

    [Fact]
    public async Task FailingCommand_RollsBackAndSurfacesError()
    {
        var provider = TestProviders.BuildDefaults(out _, out var uow, out _, out _);
        var dispatcher = provider.GetRequiredService<IRequestDispatcher>();

        await Assert.ThrowsAsync<InvalidOperationException>(() =>
            dispatcher.DispatchAsync(new SampleCommand("k1", ShouldFail: true)));

        Assert.Equal(1, uow.Started);
        Assert.Equal(0, uow.Committed);
        Assert.Equal(1, uow.RolledBack);
    }

    [Fact]
    public async Task Query_DoesNotOpenTransaction()
    {
        var provider = TestProviders.BuildDefaults(out _, out var uow, out _, out _);
        var dispatcher = provider.GetRequiredService<IRequestDispatcher>();

        await dispatcher.DispatchAsync(new SampleQuery("x"));

        Assert.Equal(0, uow.Started);
    }
}
