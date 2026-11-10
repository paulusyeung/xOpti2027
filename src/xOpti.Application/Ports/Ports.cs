namespace xOpti.Application.Ports;

/// <summary>
/// Executes work inside one explicit transaction: committed when the delegate
/// completes, rolled back on any failure. One use per command posting.
/// </summary>
public interface IUnitOfWork
{
    Task<T> ExecuteInTransactionAsync<T>(Func<CancellationToken, Task<T>> work, CancellationToken cancellationToken);
}

/// <summary>Time source for testable domain timestamps.</summary>
public interface IClock
{
    DateTimeOffset UtcNow { get; }
}

/// <summary>The acting user, branch, and resolved permission claims for the current request.</summary>
public interface ICurrentPrincipal
{
    string? UserId { get; }

    string? BranchCode { get; }

    bool HasPermission(string permission);
}

/// <summary>An append-only audit entry for financial and inventory changes.</summary>
public sealed record AuditRecord(
    string Action,
    string EntityType,
    string EntityId,
    string? Details);

/// <summary>Sink for audit entries; Infrastructure persists them out of band.</summary>
public interface IAuditRecorder
{
    Task RecordAsync(AuditRecord record, CancellationToken cancellationToken);
}

/// <summary>
/// Allocates the next legacy-prefixed control number for a transaction family,
/// race-safe in the backing store.
/// </summary>
public interface IControlNumberAllocator
{
    Task<Domain.Values.ControlNumber> AllocateAsync(
        Domain.Values.TransactionType family,
        CancellationToken cancellationToken);
}
