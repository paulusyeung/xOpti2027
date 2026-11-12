using System.Collections.Concurrent;
using System.Collections.Immutable;
using Microsoft.Extensions.Logging;

namespace xOpti.Api.IntegrationTests.Support;

/// <summary>Captures structured log entries for assertions without a log server.</summary>
public sealed class CapturingLoggerProvider : ILoggerProvider
{
    private static readonly AsyncLocal<ImmutableStack<object>> ScopeStack = new();

    public ConcurrentQueue<CapturedLog> Entries { get; } = new();

    public ILogger CreateLogger(string categoryName) => new CapturingLogger(this, categoryName);

    public void Dispose()
    {
    }

    public IReadOnlyList<CapturedLog> Snapshot() => Entries.ToArray();

    private sealed class CapturingLogger(CapturingLoggerProvider owner, string category) : ILogger
    {
        public IDisposable BeginScope<TState>(TState state) where TState : notnull
        {
            var previous = ScopeStack.Value ?? ImmutableStack<object>.Empty;
            ScopeStack.Value = previous.Push(state);
            return new Scope(previous);
        }

        public bool IsEnabled(LogLevel logLevel) => true;

        public void Log<TState>(
            LogLevel logLevel,
            EventId eventId,
            TState state,
            Exception? exception,
            Func<TState, Exception?, string> formatter)
        {
            var correlationId = (ScopeStack.Value ?? ImmutableStack<object>.Empty)
                .Select(scope => scope as IReadOnlyDictionary<string, object>)
                .Where(scope => scope is not null)
                .Select(scope => scope!.TryGetValue("CorrelationId", out var value) ? value?.ToString() : null)
                .FirstOrDefault(value => value is not null);

            owner.Entries.Enqueue(new CapturedLog(
                category, logLevel, formatter(state, exception), correlationId, exception));
        }

        private sealed class Scope(ImmutableStack<object> previous) : IDisposable
        {
            public void Dispose() => ScopeStack.Value = previous;
        }
    }
}

public sealed record CapturedLog(
    string Category,
    LogLevel Level,
    string Message,
    string? CorrelationId,
    Exception? Exception);
