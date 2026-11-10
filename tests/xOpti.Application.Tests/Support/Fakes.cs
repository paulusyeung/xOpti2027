using System.Collections.Concurrent;
using FluentValidation;
using xOpti.Application.Authorization;
using xOpti.Application.Common;
using xOpti.Application.Pipeline;
using xOpti.Application.Ports;

namespace xOpti.Application.Tests.Support;

public sealed class FakeUnitOfWork : IUnitOfWork
{
    public int Started { get; private set; }

    public int Committed { get; private set; }

    public int RolledBack { get; private set; }

    public async Task<T> ExecuteInTransactionAsync<T>(Func<CancellationToken, Task<T>> work, CancellationToken cancellationToken)
    {
        Started++;
        try
        {
            var result = await work(cancellationToken).ConfigureAwait(false);
            Committed++;
            return result;
        }
        catch
        {
            RolledBack++;
            throw;
        }
    }
}

public sealed class FakePrincipal : ICurrentPrincipal
{
    private readonly HashSet<string> _permissions;

    public FakePrincipal(params string[] permissions)
    {
        _permissions = new HashSet<string>(permissions);
    }

    public string? UserId => "tester";

    public string? BranchCode => "01";

    public bool HasPermission(string permission) => _permissions.Contains(permission);
}

public sealed class FakeIdempotencyStore : IIdempotencyStore
{
    private readonly ConcurrentDictionary<string, Entry> _entries = new();

    public int AcquireCalls { get; private set; }

    public bool IsReserved(string key) => _entries.ContainsKey(key);

    public Task<IdempotencyReservation> TryAcquireAsync(string key, CancellationToken cancellationToken)
    {
        AcquireCalls++;
        var entry = _entries.GetOrAdd(key, _ => new Entry());
        lock (entry)
        {
            if (entry.Completed)
            {
                return Task.FromResult(new IdempotencyReservation(IdempotencyAcquisition.Replayed, entry.Result));
            }

            if (entry.InProgress)
            {
                return Task.FromResult(new IdempotencyReservation(IdempotencyAcquisition.InProgress));
            }

            entry.InProgress = true;
            return Task.FromResult(new IdempotencyReservation(IdempotencyAcquisition.Acquired));
        }
    }

    public Task SaveResultAsync(string key, object result, CancellationToken cancellationToken)
    {
        if (_entries.TryGetValue(key, out var entry))
        {
            lock (entry)
            {
                entry.InProgress = false;
                entry.Completed = true;
                entry.Result = result;
            }
        }

        return Task.CompletedTask;
    }

    public Task ReleaseAsync(string key, CancellationToken cancellationToken)
    {
        if (_entries.TryGetValue(key, out var entry))
        {
            lock (entry)
            {
                entry.InProgress = false;
                entry.Completed = false;
                entry.Result = null;
            }
        }

        return Task.CompletedTask;
    }

    private sealed class Entry
    {
        public bool InProgress;

        public bool Completed;

        public object? Result;
    }
}

public sealed class SystemClock : IClock
{
    public DateTimeOffset UtcNow { get; set; } = new(2026, 1, 1, 0, 0, 0, TimeSpan.Zero);
}

// ----- test requests -----

public sealed record SampleQuery(string? Marker) : IQuery<string>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => Array.Empty<string>();
}

public sealed record SampleCommand(string? IdemKey, bool ShouldFail = false)
    : ICommand<string>, IRequiresIdempotencyKey, IHasPermissions
{
    public string? IdempotencyKey => IdemKey;

    public IReadOnlyList<string> RequiredPermissions => Array.Empty<string>();
}

public sealed record GuardedCommand(string Permission)
    : ICommand<string>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { Permission };
}

public sealed class RecordingCommandHandler(FakeExecutionLog log) : IRequestHandler<SampleCommand, string>
{
    public Task<string> Handle(SampleCommand request, CancellationToken cancellationToken)
    {
        log.CommandsExecuted++;
        if (request.ShouldFail)
        {
            throw new InvalidOperationException("handler blew up mid-write");
        }

        return Task.FromResult("posted:" + log.CommandsExecuted);
    }
}

public sealed class RecordingQueryHandler(FakeExecutionLog log) : IRequestHandler<SampleQuery, string>
{
    public static CancellationToken LastTokenSeen { get; private set; }

    public Task<string> Handle(SampleQuery request, CancellationToken cancellationToken)
    {
        LastTokenSeen = cancellationToken;
        log.QueriesExecuted++;
        return Task.FromResult("queried");
    }
}

public sealed class GuardedCommandHandler(FakeExecutionLog log) : IRequestHandler<GuardedCommand, string>
{
    public Task<string> Handle(GuardedCommand request, CancellationToken cancellationToken)
    {
        log.GuardedExecuted++;
        return Task.FromResult("guarded");
    }
}

public sealed class FakeExecutionLog
{
    public int CommandsExecuted;

    public int QueriesExecuted;

    public int GuardedExecuted;

    public int ValidationsRun;
}

/// <summary>A validator for SampleCommand that fails when the key is the sentinel value.</summary>
public sealed class SampleCommandValidator : FluentValidation.AbstractValidator<SampleCommand>
{
    public SampleCommandValidator()
    {
        RuleFor(x => x.IdemKey)
            .NotEqual("needs-validation-failure")
            .WithMessage("simulated-field-error");
    }
}
