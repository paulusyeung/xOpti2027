namespace xOpti.Infrastructure.Persistence.Entities;

/// <summary>App-owned append-only audit row (platform.audit_log).</summary>
public class AuditLog
{
    public long Id { get; set; }

    public DateTimeOffset OccurredAt { get; set; }

    public string? ActorUserId { get; set; }

    public string? ActorBranch { get; set; }

    public string Action { get; set; } = string.Empty;

    public string EntityType { get; set; } = string.Empty;

    public string EntityId { get; set; } = string.Empty;

    public string? Details { get; set; }
}

/// <summary>App-owned idempotency lease/result row (platform.idempotency_record).</summary>
public class IdempotencyRecord
{
    public string Key { get; set; } = string.Empty;

    /// <summary>in-progress | completed</summary>
    public string Status { get; set; } = string.Empty;

    public string? Payload { get; set; }

    public string? ResultType { get; set; }

    public DateTimeOffset CreatedAt { get; set; }

    public DateTimeOffset ExpiresAt { get; set; }
}
