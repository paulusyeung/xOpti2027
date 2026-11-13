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

        mb.Entity<SchemaBaseline>(e =>
        {
            e.ToTable("schema_baseline", "platform");
            e.HasKey(x => x.Id);
            // Single-row table: the id is supplied by the bootstrap, not a sequence.
            e.Property(x => x.Id).ValueGeneratedNever();
            e.Property(x => x.Version).HasMaxLength(64).IsRequired();
            e.Property(x => x.Checksum).HasMaxLength(64).IsRequired();
            e.Property(x => x.AppliedAt);
            e.Property(x => x.AppliedBy).HasMaxLength(128).IsRequired();
        });

        mb.Entity<EntityRetirement>(e =>
        {
            e.ToTable("entity_retirement", "platform");
            e.HasKey(x => new { x.EntityType, x.EntityKey });
            e.Property(x => x.EntityType).HasMaxLength(32);
            e.Property(x => x.EntityKey).HasMaxLength(40);
            e.Property(x => x.Reason).HasMaxLength(500).IsRequired();
            e.Property(x => x.RetiredBy).HasMaxLength(64);
            e.Property(x => x.RetiredAt);
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
