using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using xOpti.Infrastructure.Identity;
using xOpti.Infrastructure.Persistence.Entities;

namespace xOpti.Infrastructure.Persistence;

public class XOptiDbContext(DbContextOptions<XOptiDbContext> options)
    : IdentityDbContext<XoptiUser, XoptiRole, string>(options)
{
    public DbSet<TxHeader> TxHeaders => Set<TxHeader>();

    public DbSet<TxDetail> TxDetails => Set<TxDetail>();

    public DbSet<TxPayment> TxPayments => Set<TxPayment>();

    public DbSet<Inventory> InventoryItems => Set<Inventory>();

    public DbSet<InvtLotRecord> LotRecords => Set<InvtLotRecord>();

    public DbSet<Branch> Branches => Set<Branch>();

    public DbSet<Customer> Customers => Set<Customer>();

    public DbSet<Preference> Preferences => Set<Preference>();

    public DbSet<PrefTxNumber> PrefTxNumbers => Set<PrefTxNumber>();

    public DbSet<AuditLog> AuditLogs => Set<AuditLog>();

    public DbSet<IdempotencyRecord> IdempotencyRecords => Set<IdempotencyRecord>();

    public DbSet<SchemaBaseline> SchemaBaselines => Set<SchemaBaseline>();

    public DbSet<Identity.LegacyStaffRow> LegacyStaff => Set<Identity.LegacyStaffRow>();

    public DbSet<Identity.LegacyUserRow> LegacyUsers => Set<Identity.LegacyUserRow>();

    protected override void OnModelCreating(ModelBuilder builder)
    {
        base.OnModelCreating(builder);
        IdentityTables(builder);
        LegacyMapping.Configure(builder);
        PlatformMapping.Configure(builder);
    }

    /// <summary>App-owned Identity tables follow the snake_case contract (asp_net_*).</summary>
    private static void IdentityTables(ModelBuilder builder)
    {
        builder.Entity<XoptiUser>(entity =>
        {
            entity.ToTable("asp_net_users");
            entity.Property(user => user.DisplayName).HasMaxLength(100);
            entity.Property(user => user.DefaultBranchCode).HasMaxLength(3);
        });
        builder.Entity<XoptiRole>().ToTable("asp_net_roles");
        builder.Entity<IdentityUserRole<string>>().ToTable("asp_net_user_roles");
        builder.Entity<IdentityUserClaim<string>>().ToTable("asp_net_user_claims");
        builder.Entity<IdentityUserLogin<string>>().ToTable("asp_net_user_logins");
        builder.Entity<IdentityRoleClaim<string>>().ToTable("asp_net_role_claims");
        builder.Entity<IdentityUserToken<string>>().ToTable("asp_net_user_tokens");
    }
}
