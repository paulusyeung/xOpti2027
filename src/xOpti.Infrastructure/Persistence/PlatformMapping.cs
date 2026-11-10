using Microsoft.EntityFrameworkCore;
using xOpti.Infrastructure.Persistence.Entities;

namespace xOpti.Infrastructure.Persistence;

/// <summary>App-owned tables (included in EF migrations, additive-only).</summary>
public static class PlatformMapping
{
    public static void Configure(ModelBuilder mb)
    {
        mb.Entity<AuditLog>(e =>
        {
            e.ToTable("audit_log", "platform");
            e.HasKey(x => x.Id);
            e.Property(x => x.Id).UseIdentityAlwaysColumn();
            e.Property(x => x.OccurredAt);
            e.Property(x => x.Details).HasMaxLength(4000);
            e.Property(x => x.Action).HasMaxLength(64).IsRequired();
            e.Property(x => x.EntityType).HasMaxLength(128).IsRequired();
            e.Property(x => x.EntityId).HasMaxLength(64).IsRequired();
            e.Property(x => x.ActorUserId).HasMaxLength(64);
            e.Property(x => x.ActorBranch).HasMaxLength(3);
        });

        mb.Entity<IdempotencyRecord>(e =>
        {
            e.ToTable("idempotency_record", "platform");
            e.HasKey(x => x.Key);
            e.Property(x => x.Key).HasMaxLength(128);
            e.Property(x => x.Status).HasMaxLength(16);
            e.Property(x => x.ResultType).HasMaxLength(256);
        });
    }
}
