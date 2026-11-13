using Microsoft.EntityFrameworkCore;
using xOpti.Infrastructure.Persistence.Entities;

namespace xOpti.Infrastructure.Persistence;

/// <summary>
/// Mapping for the migrated reference tables. Every table is excluded from EF
/// migrations; the canonical DDL remains tools/legacy-migration/schema.
/// </summary>
public static class ReferenceMapping
{
    public static void Configure(ModelBuilder mb)
    {
        mb.Entity<City>(e =>
        {
            e.ToTable("city", t => t.ExcludeFromMigrations());
            e.HasKey(x => x.Code);
            e.Property(x => x.Code).HasColumnName("code");
            e.Property(x => x.CityName).HasColumnName("city_name");
            e.Property(x => x.ProvinceCode).HasColumnName("province_code");
            e.Property(x => x.CountryCode).HasColumnName("country_code");
            e.Property(x => x.CityPhoneCode).HasColumnName("city_phone_code");
        });

        mb.Entity<Province>(e =>
        {
            e.ToTable("province", t => t.ExcludeFromMigrations());
            e.HasKey(x => x.ProvinceCode);
            e.Property(x => x.ProvinceCode).HasColumnName("province_code");
            e.Property(x => x.ProvinceName).HasColumnName("province_name");
        });

        mb.Entity<Country>(e =>
        {
            e.ToTable("country", t => t.ExcludeFromMigrations());
            e.HasKey(x => x.CountryCode);
            e.Property(x => x.CountryCode).HasColumnName("country_code");
            e.Property(x => x.CountryName).HasColumnName("country_name");
            e.Property(x => x.CountryPhoneCode).HasColumnName("country_phone_code");
        });

        mb.Entity<Department>(e =>
        {
            e.ToTable("department", t => t.ExcludeFromMigrations());
            e.HasKey(x => x.DepartmentCode);
            e.Property(x => x.DepartmentCode).HasColumnName("department_code");
            e.Property(x => x.DepartmentName).HasColumnName("department_name");
            e.Property(x => x.SummaryFlag).HasColumnName("summary_flag");
        });

        mb.Entity<Class>(e =>
        {
            e.ToTable("class", t => t.ExcludeFromMigrations());
            e.HasKey(x => new { x.Department, x.ClassCode });
            e.Property(x => x.Department).HasColumnName("department");
            e.Property(x => x.ClassCode).HasColumnName("class_code");
            e.Property(x => x.ClassName).HasColumnName("class_name");
            e.Property(x => x.SummaryFlag).HasColumnName("summary_flag");
        });

        mb.Entity<Category>(e =>
        {
            e.ToTable("category", t => t.ExcludeFromMigrations());
            e.HasKey(x => new { x.DepartmentCode, x.ClassCode, x.CategoryCode });
            e.Property(x => x.DepartmentCode).HasColumnName("department_code");
            e.Property(x => x.ClassCode).HasColumnName("class_code");
            e.Property(x => x.CategoryCode).HasColumnName("category_code");
            e.Property(x => x.CategoryName).HasColumnName("category_name");
            e.Property(x => x.CostingMethod).HasColumnName("costing_method");
            e.Property(x => x.InventoryMethod).HasColumnName("inventory_method");
            e.Property(x => x.TaxMethod).HasColumnName("tax_method");
            e.Property(x => x.SummaryFlag).HasColumnName("summary_flag");
        });

        mb.Entity<Brand>(e =>
        {
            e.ToTable("brand", t => t.ExcludeFromMigrations());
            e.HasKey(x => x.BrandCode);
            e.Property(x => x.BrandCode).HasColumnName("brand_code");
            e.Property(x => x.BrandDescription).HasColumnName("brand_description");
        });

        mb.Entity<Material>(e =>
        {
            e.ToTable("material", t => t.ExcludeFromMigrations());
            e.HasKey(x => x.MaterialCode);
            e.Property(x => x.MaterialCode).HasColumnName("material_code");
            e.Property(x => x.MaterialDescription).HasColumnName("material_description");
        });

        mb.Entity<TaxMethod>(e =>
        {
            e.ToTable("tax_method", t => t.ExcludeFromMigrations());
            e.HasKey(x => x.TaxCode);
            e.Property(x => x.TaxCode).HasColumnName("tax_code");
            e.Property(x => x.TaxName).HasColumnName("tax_name");
        });

        mb.Entity<Supplier>(e =>
        {
            e.ToTable("supplier", t => t.ExcludeFromMigrations());
            e.HasKey(x => x.SupplierCode);
            e.Property(x => x.SupplierCode).HasColumnName("supplier_code");
            e.Property(x => x.SupplierName).HasColumnName("supplier_name");
            e.Property(x => x.CityCode).HasColumnName("city");
            e.Property(x => x.Province).HasColumnName("province");
            e.Property(x => x.Country).HasColumnName("country");
            e.Property(x => x.Phone).HasColumnName("phone_gen_voice");
            e.Property(x => x.ContactPerson).HasColumnName("contact_person");
            e.Property(x => x.CreditLimit).HasColumnName("credit_limit");
            e.Property(x => x.PaymentTerms).HasColumnName("payment_terms");
        });

        mb.Entity<SupplierContact>(e =>
        {
            e.ToTable("supplier_contact_person", t => t.ExcludeFromMigrations());
            e.HasKey(x => new { x.SupCode, x.FirstName, x.Initial, x.LastName });
            e.Property(x => x.SupCode).HasColumnName("sup_code");
            e.Property(x => x.FirstName).HasColumnName("first_name");
            e.Property(x => x.Initial).HasColumnName("initial");
            e.Property(x => x.LastName).HasColumnName("last_name");
            e.Property(x => x.FullName).HasColumnName("full_name");
            e.Property(x => x.JobTitle).HasColumnName("job_title");
            e.Property(x => x.PhoneGeneralVoice).HasColumnName("phone_general_voice");
            e.Property(x => x.PhoneMobile).HasColumnName("phone_mobile");
        });

        mb.Entity<Doctor>(e =>
        {
            e.ToTable("doctor", t => t.ExcludeFromMigrations());
            e.HasKey(x => x.Id);
            e.Property(x => x.Id).HasColumnName("id");
            e.Property(x => x.DoctorName).HasColumnName("doctor_name");
            e.Property(x => x.Address).HasColumnName("address");
            e.Property(x => x.CityCode).HasColumnName("city");
            e.Property(x => x.Province).HasColumnName("province");
            e.Property(x => x.Country).HasColumnName("country");
            e.Property(x => x.Phone).HasColumnName("phone");
            e.Property(x => x.PostalCode).HasColumnName("postal_code");
        });

        mb.Entity<BranchInventory>(e =>
        {
            e.ToTable("branch_inventory", t => t.ExcludeFromMigrations());
            e.HasKey(x => new { x.BranchCode, x.Sku });
            e.Property(x => x.BranchCode).HasColumnName("branch_code");
            e.Property(x => x.Sku).HasColumnName("sku");
            e.Property(x => x.QtyOnHand).HasColumnName("qty_on_hand");
        });

        mb.Entity<PaymentMethod>(e =>
        {
            e.ToTable("payment_methods", t => t.ExcludeFromMigrations());
            e.HasKey(x => x.PaymentCode);
            e.Property(x => x.PaymentCode).HasColumnName("payment_code");
            e.Property(x => x.PaymentNameShort).HasColumnName("payment_name_short");
            e.Property(x => x.PaymentNameLong).HasColumnName("payment_name_long");
            e.Property(x => x.ExchangeRate).HasColumnName("exchange_rate");
        });
    }
}
