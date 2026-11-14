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

    public DbSet<EntityRetirement> EntityRetirements => Set<EntityRetirement>();

    public DbSet<City> Cities => Set<City>();

    public DbSet<Province> Provinces => Set<Province>();

    public DbSet<Country> Countries => Set<Country>();

    public DbSet<Department> Departments => Set<Department>();

    public DbSet<Class> Classes => Set<Class>();

    public DbSet<Category> Categories => Set<Category>();

    public DbSet<Brand> Brands => Set<Brand>();

    public DbSet<Material> Materials => Set<Material>();

    public DbSet<TaxMethod> TaxMethods => Set<TaxMethod>();

    public DbSet<PaymentMethod> PaymentMethods => Set<PaymentMethod>();

    public DbSet<Supplier> Suppliers => Set<Supplier>();

    public DbSet<SupplierContact> SupplierContacts => Set<SupplierContact>();

    public DbSet<Doctor> Doctors => Set<Doctor>();

    public DbSet<BranchInventory> BranchInventory => Set<BranchInventory>();

    public DbSet<RetailPrice> RetailPrices => Set<RetailPrice>();

    public DbSet<WholesalePrice> WholesalePrices => Set<WholesalePrice>();

    public DbSet<BarCodePool> BarCodePool => Set<BarCodePool>();

    public DbSet<Identity.LegacyStaffRow> LegacyStaff => Set<Identity.LegacyStaffRow>();

    public DbSet<Identity.LegacyUserRow> LegacyUsers => Set<Identity.LegacyUserRow>();

    protected override void OnModelCreating(ModelBuilder builder)
    {
        base.OnModelCreating(builder);
        IdentityTables(builder);
        LegacyMapping.Configure(builder);
        PlatformMapping.Configure(builder);
        ReferenceMapping.Configure(builder);
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
