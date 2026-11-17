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

        mb.Entity<TxSOrderCont>(e =>
        {
            e.ToTable("tx_s_order_cont", t => t.ExcludeFromMigrations());
            e.HasKey(x => new { x.TxNumber, x.LineNumber });
            e.Property(x => x.TxNumber).HasColumnName("tx_number");
            e.Property(x => x.LineNumber).HasColumnName("line_number");
            e.Property(x => x.IssuedOn).HasColumnName("issued_on").HasConversion(Converters.UtcTimestampNullable);
            e.Property(x => x.IssuedBy).HasColumnName("issued_by");
            foreach (var (property, column) in new (string, string)[]
                     {
                         ("RightSphere","right_sphere"),("RightCylinder","right_cylinder"),
                         ("RightAxis","right_axis"),("RightKReadingV","right_k_reading_v"),
                         ("RightKReadingH","right_k_reading_h"),("RightPalp","right_palp"),
                         ("RightCorn","right_corn"),("RightPupil","right_pupil"),
                         ("LeftSphere","left_sphere"),("LeftCylinder","left_cylinder"),
                         ("LeftAxis","left_axis"),("LeftKReadingV","left_k_reading_v"),
                         ("LeftKReadingH","left_k_reading_h"),("LeftPalp","left_palp"),
                         ("LeftCorn","left_corn"),("LeftPupil","left_pupil"),
                     })
            {
                e.Property(property switch
                {
                    "RightAxis" => typeof(int), "LeftAxis" => typeof(int), _ => typeof(double),
                }, property).HasColumnName(column);
            }
            e.Property(x => x.History).HasColumnName("history");
            e.Property(x => x.Medical).HasColumnName("medical");
            e.Property(x => x.Allergy).HasColumnName("allergy");
            e.Property(x => x.Reason).HasColumnName("reason");
            e.Property(x => x.Evaluation).HasColumnName("evaluation");
            e.Property(x => x.Test).HasColumnName("test");
            e.Property(x => x.SpecialInstruction).HasColumnName("special_instruction");
        });

        mb.Entity<TxSOrderFrame>(e =>
        {
            e.ToTable("tx_s_order_frame", t => t.ExcludeFromMigrations());
            e.HasKey(x => new { x.TxNumber, x.LineNumber });
            e.Property(x => x.TxNumber).HasColumnName("tx_number");
            e.Property(x => x.LineNumber).HasColumnName("line_number");
            e.Property(x => x.Supply).HasColumnName("supply");
            e.Property(x => x.Enclosed).HasColumnName("enclosed");
            e.Property(x => x.Follow).HasColumnName("follow");
            e.Property(x => x.Lenses).HasColumnName("lenses");
            e.Property(x => x.Mode).HasColumnName("mode");
            e.Property(x => x.Color).HasColumnName("color");
            e.Property(x => x.EyeSize).HasColumnName("eye_size");
            e.Property(x => x.Bridge).HasColumnName("bridge");
            e.Property(x => x.Temple).HasColumnName("temple");
            e.Property(x => x.R1).HasColumnName("r1");
            e.Property(x => x.R2).HasColumnName("r2");
            e.Property(x => x.R3).HasColumnName("r3");
            e.Property(x => x.A).HasColumnName("a");
            e.Property(x => x.B).HasColumnName("b");
            e.Property(x => x.SpecialInstruction).HasColumnName("special_instruction");
        });

        mb.Entity<TxSOrderLens>(e =>
        {
            e.ToTable("tx_s_order_lens", t => t.ExcludeFromMigrations());
            e.HasKey(x => new { x.TxNumber, x.LineNumber });
            e.Property(x => x.TxNumber).HasColumnName("tx_number");
            e.Property(x => x.LineNumber).HasColumnName("line_number");
            e.Property(x => x.IssuedOn).HasColumnName("issued_on").HasConversion(Converters.UtcTimestampNullable);
            e.Property(x => x.IssuedBy).HasColumnName("issued_by");
            foreach (var (property, column) in new (string, string)[]
                     {
                         ("RightSphere","right_sphere"),("RightCylinder","right_cylinder"),
                         ("RightAxis","right_axis"),("RightPdDist","right_pd_dist"),
                         ("RightPdNear","right_pd_near"),("RightPrism","right_prism"),
                         ("RightAdd","right_add"),("RightPupil","right_pupil"),
                         ("RightSegHt","right_seg_ht"),("RightOc","right_oc"),
                         ("RightBase","right_base"),("RightVd","right_vd"),
                         ("LeftSphere","left_sphere"),("LeftCylinder","left_cylinder"),
                         ("LeftAxis","left_axis"),("LeftPdDist","left_pd_dist"),
                         ("LeftPdNear","left_pd_near"),("LeftPrism","left_prism"),
                         ("LeftAdd","left_add"),("LeftPupil","left_pupil"),
                         ("LeftSegHt","left_seg_ht"),("LeftOc","left_oc"),
                         ("LeftBase","left_base"),("LeftVd","left_vd"),
                     })
            {
                e.Property(property switch
                {
                    "RightAxis" => typeof(int), "LeftAxis" => typeof(int), _ => typeof(double),
                }, property).HasColumnName(column);
            }
            e.Property(x => x.RightStyle).HasColumnName("right_style");
            e.Property(x => x.LeftStyle).HasColumnName("left_style");
            e.Property(x => x.Type).HasColumnName("type");
            e.Property(x => x.Hardening).HasColumnName("hardening");
            e.Property(x => x.Material).HasColumnName("material");
            e.Property(x => x.Coating).HasColumnName("coating");
            e.Property(x => x.Tint).HasColumnName("tint");
            e.Property(x => x.Others).HasColumnName("others");
            e.Property(x => x.HardCoat).HasColumnName("hard_coat");
            e.Property(x => x.ArCoat).HasColumnName("ar_coat");
            e.Property(x => x.Uv).HasColumnName("uv");
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
