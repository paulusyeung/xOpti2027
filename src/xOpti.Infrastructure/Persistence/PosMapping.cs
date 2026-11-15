using Microsoft.EntityFrameworkCore;
using xOpti.Infrastructure.Persistence.Entities;

namespace xOpti.Infrastructure.Persistence;

/// <summary>POS side tables not covered by LegacyMapping; excluded from migrations.</summary>
public static class PosMapping
{
    public static void Configure(ModelBuilder mb)
    {
        mb.Entity<TxSalePerson>(e =>
        {
            e.ToTable("tx_sale_person", t => t.ExcludeFromMigrations());
            e.HasKey(x => new { x.TxNumber, x.SalesRowNo });
            e.Property(x => x.TxNumber).HasColumnName("tx_number");
            e.Property(x => x.SalesRowNo).HasColumnName("sales_row_no");
            e.Property(x => x.StaffCode).HasColumnName("staff_code");
        });

        mb.Entity<TxSOrderAdd>(e =>
        {
            e.ToTable("tx_s_order_add", t => t.ExcludeFromMigrations());
            e.HasKey(x => new { x.TxNumber, x.LineNumber });
            e.Property(x => x.TxNumber).HasColumnName("tx_number");
            e.Property(x => x.LineNumber).HasColumnName("line_number");
            e.Property(x => x.Supplier).HasColumnName("supplier");
            e.Property(x => x.Brand).HasColumnName("brand");
            e.Property(x => x.Model).HasColumnName("model");
        });

        mb.Entity<TxSOrderExtra>(e =>
        {
            e.ToTable("tx_s_order_extra", t => t.ExcludeFromMigrations());
            e.HasKey(x => x.TxNumber);
            e.Property(x => x.TxNumber).HasColumnName("tx_number");
            e.Property(x => x.Redo).HasColumnName("redo");
            e.Property(x => x.Warranty).HasColumnName("warranty");
            e.Property(x => x.Mail).HasColumnName("mail");
            e.Property(x => x.Msd).HasColumnName("msd");
            e.Property(x => x.Remarks).HasColumnName("remarks");
        });
    }
}
