namespace xOpti.Application.Ports;

/// <summary>Outcome of atomically reserving an idempotency key.</summary>
public enum IdempotencyAcquisition
{
    /// <summary>The key was unused; this submission owns execution.</summary>
    Acquired,

    /// <summary>A previous submission completed; its stored result is returned.</summary>
    Replayed,

    /// <summary>A previous submission is still executing; concurrent duplicate must not run.</summary>
    InProgress,
}

/// <summary>Reservation outcome with the cached result when replaying.</summary>
public sealed record IdempotencyReservation(IdempotencyAcquisition Outcome, object? CachedResult = null);

/// <summary>
/// Keyed store backing replay-safe financial writes. TryAcquireAsync is an
/// atomic reservation; SaveResultAsync caches the committed outcome;
/// ReleaseAsync cancels a reservation after a failure.
/// </summary>
public interface IIdempotencyStore
{
    Task<IdempotencyReservation> TryAcquireAsync(string key, CancellationToken cancellationToken);

    Task SaveResultAsync(string key, object result, CancellationToken cancellationToken);

    Task ReleaseAsync(string key, CancellationToken cancellationToken);
}
