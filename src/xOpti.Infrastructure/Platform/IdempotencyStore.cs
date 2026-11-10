using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using xOpti.Application.Ports;
using xOpti.Infrastructure.Persistence;
using xOpti.Infrastructure.Persistence.Entities;

namespace xOpti.Infrastructure.Platform;

public sealed record IdempotencyStoreOptions(TimeSpan Retention);

/// <summary>
/// PostgreSQL-backed idempotency store. TryAcquireAsync performs an atomic
/// insert-or-conflict lease: concurrent requests for the same live key lose
/// the lease (InProgress) and cannot double-execute the posting.
/// </summary>
public sealed class DbIdempotencyStore(XOptiDbContext context, IdempotencyStoreOptions options) : IIdempotencyStore
{
    public async Task<IdempotencyReservation> TryAcquireAsync(string key, CancellationToken cancellationToken)
    {
        var now = DateTimeOffset.UtcNow;

        // Purge the expired lease for this key first (retention expiry).
        var expired = await context.IdempotencyRecords
            .Where(r => r.Key == key && r.ExpiresAt <= now)
            .ExecuteDeleteAsync(cancellationToken);

        try
        {
            context.IdempotencyRecords.Add(new IdempotencyRecord
            {
                Key = key,
                Status = "in-progress",
                CreatedAt = now,
                ExpiresAt = now.Add(options.Retention),
            });
            await context.SaveChangesAsync(cancellationToken);
            return new IdempotencyReservation(IdempotencyAcquisition.Acquired);
        }
        catch (DbUpdateException)
        {
            context.Entry(context.IdempotencyRecords.Local.Single(r => r.Key == key)).State = EntityState.Detached;
        }

        var existing = await context.IdempotencyRecords.AsNoTracking().SingleAsync(r => r.Key == key, cancellationToken);
        if (existing.Status == "completed" && existing.ExpiresAt > now)
        {
            var cached = DeserializeResult(existing.Payload, existing.ResultType);
            return new IdempotencyReservation(IdempotencyAcquisition.Replayed, cached);
        }

        return new IdempotencyReservation(IdempotencyAcquisition.InProgress);
    }

    public async Task SaveResultAsync(string key, object result, CancellationToken cancellationToken)
    {
        var record = await context.IdempotencyRecords.SingleAsync(r => r.Key == key, cancellationToken);
        record.Status = "completed";
        record.Payload = JsonSerializer.Serialize(result);
        record.ResultType = result.GetType().AssemblyQualifiedName;
        record.ExpiresAt = DateTimeOffset.UtcNow.Add(options.Retention);
        await context.SaveChangesAsync(cancellationToken);
    }

    public async Task ReleaseAsync(string key, CancellationToken cancellationToken)
    {
        await context.IdempotencyRecords
            .Where(r => r.Key == key && r.Status == "in-progress")
            .ExecuteDeleteAsync(cancellationToken);
    }

    private static object? DeserializeResult(string? payload, string? resultType)
    {
        if (payload is null)
        {
            return null;
        }

        var type = resultType is null ? null : Type.GetType(resultType);
        return type is not null
            ? JsonSerializer.Deserialize(payload, type)
            : payload;
    }
}

/// <summary>
/// Application-level audit sink writing to platform.audit_log. The interceptor
/// handles automatic entity-change auditing; this port remains for explicit
/// semantic entries from handlers.
/// </summary>
public sealed class DbAuditRecorder(XOptiDbContext context, IClock clock, ICurrentPrincipal principal) : IAuditRecorder
{
    public async Task RecordAsync(AuditRecord record, CancellationToken cancellationToken)
    {
        context.AuditLogs.Add(new AuditLog
        {
            OccurredAt = clock.UtcNow,
            ActorUserId = principal.UserId,
            ActorBranch = principal.BranchCode,
            Action = record.Action,
            EntityType = record.EntityType,
            EntityId = record.EntityId,
            Details = record.Details,
        });

        await context.SaveChangesAsync(cancellationToken);
    }
}
