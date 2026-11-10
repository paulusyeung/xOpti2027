using System.Linq.Expressions;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.ChangeTracking;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using xOpti.Domain.Values;
using xOpti.Infrastructure.Persistence.Entities;

namespace xOpti.Infrastructure.Persistence;

/// <summary>
/// All mapping for the pre-migrated legacy tables. Every table uses
/// ExcludeFromMigrations so EF scaffolding never emits DDL for them.
/// </summary>
public static class LegacyMapping
{
    public static void Configure(ModelBuilder mb)
    {
        mb.Entity<TxHeader>(e =>
        {
            e.ToTable("tx_header", t => t.ExcludeFromMigrations());
            e.HasKey(x => x.TxNumber);
            e.Property(x => x.TxNumber).HasColumnName("tx_number");
            e.Property(x => x.ControlNumber).HasColumnName("control_number");
            e.Property(x => x.TxType).HasColumnName("tx_type").HasConversion(Converters.TxTypeCode);
            e.Property(x => x.DateOfEntry).HasColumnName("date_of_entry").HasConversion(Converters.UtcTimestamp);
            e.Property(x => x.DateOfCreation).HasColumnName("date_of_creation").HasConversion(Converters.UtcTimestampNullable);
            e.Property(x => x.RefNumber).HasColumnName("ref_number");
            e.Property(x => x.CustomerId).HasColumnName("customer_id");
            e.Property(x => x.SupplierCode).HasColumnName("supplier_code");
            e.Property(x => x.Particulars).HasColumnName("particulars");
            MoneyProp(e, x => x.TotalCost, "total_cost");
            MoneyProp(e, x => x.TotalSale, "total_sale");
            MoneyProp(e, x => x.TaxA, "tax_a");
            MoneyProp(e, x => x.TaxB, "tax_b");
            MoneyProp(e, x => x.TaxC, "tax_c");
            MoneyProp(e, x => x.GrossSale, "gross_sale");
            MoneyProp(e, x => x.SalesDiscount, "sales_discount");
            MoneyProp(e, x => x.TotalAmount, "total_amount");
            e.Property(x => x.TotalQty).HasColumnName("total_qty");
            MoneyProp(e, x => x.ThisPaid, "this_paid");
            e.Property(x => x.Status).HasColumnName("status");
            e.HasMany(x => x.Details)
                .WithOne()
                .HasForeignKey("TxNumber", "TxType", "DateOfEntry")
                .HasPrincipalKey(x => new { x.TxNumber, x.TxType, x.DateOfEntry });
            AddXminConcurrency(e);
        });

        mb.Entity<TxDetail>(e =>
        {
            e.ToTable("tx_details", t => t.ExcludeFromMigrations());
            e.HasKey(x => new { x.TxType, x.TxNumber, x.DateOfEntry, x.RowNo });
            e.Property(x => x.TxType).HasColumnName("tx_type").HasConversion(Converters.TxTypeCode);
            e.Property(x => x.TxNumber).HasColumnName("tx_number");
            e.Property(x => x.DateOfEntry).HasColumnName("date_of_entry").HasConversion(Converters.UtcTimestamp);
            e.Property(x => x.RowNo).HasColumnName("row_no");
            e.Property(x => x.Sku).HasColumnName("sku");
            e.Property(x => x.Remarks).HasColumnName("remarks");
            e.Property(x => x.Qty).HasColumnName("qty");
            MoneyProp(e, x => x.UnitAmount, "unit_amount");
            MoneyProp(e, x => x.UnitCost, "unit_cost");
            MoneyProp(e, x => x.Amount, "amount");
            e.Property(x => x.TaxCode).HasColumnName("tax_code");
        });

        mb.Entity<TxPayment>(e =>
        {
            e.ToTable("tx_payment", t => t.ExcludeFromMigrations());
            e.HasKey(x => new { x.TxNumber, x.PaymentLineNo, x.Type });
            e.Property(x => x.TxNumber).HasColumnName("tx_number");
            e.Property(x => x.PaymentLineNo).HasColumnName("payment_line_no");
            e.Property(x => x.Type).HasColumnName("type");
            e.Property(x => x.CardNumber).HasColumnName("card_number");
            MoneyProp(e, x => x.AmountTender, "amount_tender");
            MoneyProp(e, x => x.EqAmount, "eq_amount");
            MoneyProp(e, x => x.TotalThisPay, "total_this_pay");
        });

        mb.Entity<Inventory>(e =>
        {
            e.ToTable("inventory", t => t.ExcludeFromMigrations());
            e.HasKey(x => x.Sku);
            e.Property(x => x.Sku).HasColumnName("sku");
            e.Property(x => x.DepartmentCode).HasColumnName("department_code");
            e.Property(x => x.ClassCode).HasColumnName("class_code");
            e.Property(x => x.CategoryCode).HasColumnName("category_code");
            e.Property(x => x.SupplierCode).HasColumnName("supplier_code");
            e.Property(x => x.BrandCode).HasColumnName("brand_code");
            e.Property(x => x.Name).HasColumnName("name");
            MoneyProp(e, x => x.AverageCost, "average_cost");
            e.Property(x => x.QtyTotalOnHand).HasColumnName("qty_total_on_hand");
            e.Property(x => x.DateLastIssued).HasColumnName("date_last_issued").HasConversion(Converters.UtcTimestampNullable);
            e.Property(x => x.RetailPriceFlag).HasColumnName("retail_price_flag");
            e.Property(x => x.InventoryLotFlag).HasColumnName("inventory_lot_flag");
            AddXminConcurrency(e);
        });

        mb.Entity<InvtLotRecord>(e =>
        {
            e.ToTable("invt_lot_record", t => t.ExcludeFromMigrations());
            e.HasKey(x => new { x.Sku, x.LotNo });
            e.Property(x => x.Sku).HasColumnName("sku");
            e.Property(x => x.LotNo).HasColumnName("lot_no");
            e.Property(x => x.DateReceived).HasColumnName("date_received").HasConversion(Converters.UtcTimestamp);
            e.Property(x => x.SupplierCode).HasColumnName("supplier_code");
            e.Property(x => x.QtyPurchased).HasColumnName("qty_purchased");
            e.Property(x => x.QtyUsed).HasColumnName("qty_used");
            e.Property(x => x.QtyOnHand).HasColumnName("qty_on_hand");
            MoneyProp(e, x => x.UnitAmountPurchased, "unit_amount_purchased");
            MoneyProp(e, x => x.TotalAmountPurchased, "total_amount_purchased");
            AddXminConcurrency(e);
        });

        mb.Entity<Branch>(e =>
        {
            e.ToTable("branch", t => t.ExcludeFromMigrations());
            e.HasKey(x => x.BranchCode);
            e.Property(x => x.BranchCode).HasColumnName("branch_code");
            e.Property(x => x.BranchName).HasColumnName("branch_name");
            e.Property(x => x.City).HasColumnName("city");
            e.Property(x => x.Phone).HasColumnName("phone");
            AddXminConcurrency(e);
        });

        mb.Entity<Customer>(e =>
        {
            e.ToTable("customer", t => t.ExcludeFromMigrations());
            e.HasKey(x => x.Id);
            e.Property(x => x.Id).HasColumnName("id").ValueGeneratedNever();
            e.Property(x => x.VipCode).HasColumnName("vip_code");
            e.Property(x => x.FullName).HasColumnName("full_name");
            e.Property(x => x.Email).HasColumnName("email");
            e.Property(x => x.HomePhone).HasColumnName("home_phone");
            MoneyProp(e, x => x.CreditLimit, "credit_limit");
            AddXminConcurrency(e);
        });

        mb.Entity<Preference>(e =>
        {
            e.ToTable("preference", t => t.ExcludeFromMigrations());
            e.HasKey(x => x.SerialNumber);
            e.Property(x => x.SerialNumber).HasColumnName("serial_number");
            e.Property(x => x.Platform).HasColumnName("platform");
            e.Property(x => x.ProductName).HasColumnName("product_name");
            e.Property(x => x.UserName).HasColumnName("user_name");
            e.Property(x => x.OwnerName).HasColumnName("owner_name");
            e.Property(x => x.TaxARate).HasColumnName("tax_a_rate");
            e.Property(x => x.TaxBRate).HasColumnName("tax_b_rate");
            e.Property(x => x.NextInvoiceNumber).HasColumnName("next_invoice_number");
        });

        mb.Entity<PrefTxNumber>(e =>
        {
            e.ToTable("pref_tx_number", t => t.ExcludeFromMigrations());
            e.HasKey(x => x.TxPrefix);
            e.Property(x => x.TxPrefix).HasColumnName("tx_prefix");
            e.Property(x => x.TxNextNumber).HasColumnName("tx_next_number");
            e.Property(x => x.Description).HasColumnName("description");
            e.Property(x => x.Value).HasColumnName("value");
        });

        mb.Entity<Identity.LegacyStaffRow>(e =>
        {
            e.ToTable("staff", t => t.ExcludeFromMigrations());
            e.HasKey(x => x.StaffCode);
            e.Property(x => x.StaffCode).HasColumnName("staff_code");
            e.Property(x => x.StaffFullName).HasColumnName("staff_full_name");
            e.Property(x => x.SecurityLevel).HasColumnName("security_level");
        });

        mb.Entity<Identity.LegacyUserRow>(e =>
        {
            e.ToTable("users", t => t.ExcludeFromMigrations());
            e.HasKey(x => x.Id);
            e.Property(x => x.Id).HasColumnName("id");
            e.Property(x => x.Email).HasColumnName("email");
            e.Property(x => x.IsActive).HasColumnName("is_active");
        });
    }

    /// <summary>
    /// PostgreSQL provides xmin on every row. Mapped as a shadow concurrency
    /// token; never written by INSERT/UPDATE, compared in the WHERE clause.
    /// </summary>
    private static void AddXminConcurrency<TEntity>(EntityTypeBuilder<TEntity> e)
        where TEntity : class
    {
        var xmin = e.Property<uint>("xmin");
        xmin.HasColumnType("xid");
        xmin.IsRowVersion();
        xmin.Metadata.SetValueComparer(new ValueComparer<uint>((a, b) => a == b, v => v.GetHashCode(), v => v));
    }

    private static void MoneyProp<TEntity>(
        EntityTypeBuilder<TEntity> e,
        Expression<Func<TEntity, Money>> property,
        string column)
        where TEntity : class
    {
        e.Property(property).HasColumnName(column).HasConversion(Converters.MoneyDecimal);
    }
}
