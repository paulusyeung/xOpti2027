using Microsoft.EntityFrameworkCore;
using xOpti.Application.Reference;
using xOpti.Infrastructure.Persistence;
using xOpti.Infrastructure.Persistence.Entities;

namespace xOpti.Infrastructure.Repositories;

/// <summary>Explicit per-kind reference mutations; no hard deletes are exposed.</summary>
public sealed class EfReferenceWriter(XOptiDbContext context) : IReferenceWriter
{
    public async Task<ReferenceRecord?> FindAsync(ReferenceKind kind, string key, CancellationToken ct)
    {
        switch (kind)
        {
            case ReferenceKind.City:
                if (!int.TryParse(key, out var cityCode)) return null;
                var city = await context.Cities.AsNoTracking().SingleOrDefaultAsync(x => x.Code == cityCode, ct);
                return city is null ? null : new ReferenceRecord(kind, key, city.CityName,
                    $"{city.ProvinceCode}/{city.CountryCode}", null, null, null, null, null, null);
            case ReferenceKind.Province:
                var province = await context.Provinces.AsNoTracking().SingleOrDefaultAsync(x => x.ProvinceCode == key, ct);
                return province is null ? null : new ReferenceRecord(kind, key, province.ProvinceName,
                    null, null, null, null, null, null, null);
            case ReferenceKind.Country:
                var country = await context.Countries.AsNoTracking().SingleOrDefaultAsync(x => x.CountryCode == key, ct);
                return country is null ? null : new ReferenceRecord(kind, key, country.CountryName,
                    null, null, null, null, null, null, null);
            case ReferenceKind.Department:
                var department = await context.Departments.AsNoTracking().SingleOrDefaultAsync(x => x.DepartmentCode == key, ct);
                return department is null ? null : new ReferenceRecord(kind, key,
                    department.DepartmentName ?? department.DepartmentCode, null, department.SummaryFlag,
                    null, null, null, null, null);
            case ReferenceKind.Class:
                var classParts = Split(key, 2);
                var classRow = await context.Classes.AsNoTracking().SingleOrDefaultAsync(
                    x => x.Department == classParts[0] && x.ClassCode == classParts[1], ct);
                return classRow is null ? null : new ReferenceRecord(kind, key,
                    classRow.ClassName ?? classRow.ClassCode, classRow.Department, classRow.SummaryFlag,
                    null, null, null, null, null);
            case ReferenceKind.Category:
                var categoryParts = Split(key, 3);
                var category = await context.Categories.AsNoTracking().SingleOrDefaultAsync(
                    x => x.DepartmentCode == categoryParts[0] && x.ClassCode == categoryParts[1]
                         && x.CategoryCode == categoryParts[2], ct);
                return category is null ? null : new ReferenceRecord(kind, key,
                    category.CategoryName ?? category.CategoryCode,
                    $"{categoryParts[0]}/{categoryParts[1]}", category.SummaryFlag,
                    category.CostingMethod, category.InventoryMethod, category.TaxMethod, null, null);
            case ReferenceKind.Brand:
                var brand = await context.Brands.AsNoTracking().SingleOrDefaultAsync(x => x.BrandCode == key, ct);
                return brand is null ? null : new ReferenceRecord(kind, key,
                    brand.BrandDescription ?? brand.BrandCode, null, null, null, null, null, null, null);
            case ReferenceKind.Material:
                var material = await context.Materials.AsNoTracking().SingleOrDefaultAsync(x => x.MaterialCode == key, ct);
                return material is null ? null : new ReferenceRecord(kind, key,
                    material.MaterialDescription ?? material.MaterialCode, null, null, null, null, null, null, null);
            case ReferenceKind.TaxMethod:
                var tax = await context.TaxMethods.AsNoTracking().SingleOrDefaultAsync(x => x.TaxCode == key, ct);
                return tax is null ? null : new ReferenceRecord(kind, key, tax.TaxName,
                    null, null, null, null, null, null, null);
            case ReferenceKind.PaymentMethod:
                var payment = await context.PaymentMethods.AsNoTracking().SingleOrDefaultAsync(x => x.PaymentCode == key, ct);
                return payment is null ? null : new ReferenceRecord(kind, key, payment.PaymentNameLong,
                    null, null, null, null, null, payment.PaymentNameShort, payment.ExchangeRate);
            default:
                return null;
        }
    }

    public async Task<bool> ExistsAsync(ReferenceKind kind, string key, CancellationToken ct)
    {
        switch (kind)
        {
            case ReferenceKind.City:
                return int.TryParse(key, out var code) && await context.Cities.AnyAsync(x => x.Code == code, ct);
            case ReferenceKind.Province:
                return await context.Provinces.AnyAsync(x => x.ProvinceCode == key, ct);
            case ReferenceKind.Country:
                return await context.Countries.AnyAsync(x => x.CountryCode == key, ct);
            case ReferenceKind.Department:
                return await context.Departments.AnyAsync(x => x.DepartmentCode == key, ct);
            case ReferenceKind.Class:
                var c = Split(key, 2);
                return await context.Classes.AnyAsync(x => x.Department == c[0] && x.ClassCode == c[1], ct);
            case ReferenceKind.Category:
                var cat = Split(key, 3);
                return await context.Categories.AnyAsync(
                    x => x.DepartmentCode == cat[0] && x.ClassCode == cat[1] && x.CategoryCode == cat[2], ct);
            case ReferenceKind.Brand:
                return await context.Brands.AnyAsync(x => x.BrandCode == key, ct);
            case ReferenceKind.Material:
                return await context.Materials.AnyAsync(x => x.MaterialCode == key, ct);
            case ReferenceKind.TaxMethod:
                return await context.TaxMethods.AnyAsync(x => x.TaxCode == key, ct);
            case ReferenceKind.PaymentMethod:
                return await context.PaymentMethods.AnyAsync(x => x.PaymentCode == key, ct);
            default:
                return false;
        }
    }

    public async Task<int> CountReferencesAsync(ReferenceKind kind, string key, CancellationToken ct)
    {
        var parts = Split(key);
        switch (kind)
        {
            case ReferenceKind.Department:
                return await context.Categories.CountAsync(x => x.DepartmentCode == key, ct);
            case ReferenceKind.Class:
                return parts.Length == 2
                    ? await context.Categories.CountAsync(
                        x => x.DepartmentCode == parts[0] && x.ClassCode == parts[1], ct)
                    : 0;
            case ReferenceKind.Category:
                return parts.Length == 3
                    ? await context.InventoryItems.CountAsync(
                        x => x.DepartmentCode == parts[0] && x.ClassCode == parts[1]
                             && x.CategoryCode == parts[2], ct)
                    : 0;
            case ReferenceKind.Brand:
                return await context.InventoryItems.CountAsync(x => x.BrandCode == key, ct);
            case ReferenceKind.Material:
                return await context.InventoryItems.CountAsync(x => x.MaterialCode == key, ct);
            case ReferenceKind.TaxMethod:
                return await context.Categories.CountAsync(x => x.TaxMethod == key, ct);
            case ReferenceKind.PaymentMethod:
                var paymentCode = key.Length > 0 ? key[..1] : key;
                return await context.TxPayments.CountAsync(x => x.Type == paymentCode, ct);
            // City/province/country references live in the supplier/doctor
            // directories added by task 3.4; until then no blocking references.
            default:
                return 0;
        }
    }

    public async Task CreateAsync(ReferenceMutation m, CancellationToken ct)
    {
        switch (m.Kind)
        {
            case ReferenceKind.City:
                var cityParent = Split(m.Parent ?? string.Empty, 2);
                context.Cities.Add(new City
                {
                    Code = int.Parse(m.Key), CityName = m.Name,
                    ProvinceCode = cityParent[0], CountryCode = cityParent[1],
                });
                break;
            case ReferenceKind.Province:
                context.Provinces.Add(new Province { ProvinceCode = m.Key, ProvinceName = m.Name });
                break;
            case ReferenceKind.Country:
                context.Countries.Add(new Country { CountryCode = m.Key, CountryName = m.Name });
                break;
            case ReferenceKind.Department:
                context.Departments.Add(new Department
                {
                    DepartmentCode = m.Key, DepartmentName = m.Name, SummaryFlag = m.SummaryFlag,
                });
                break;
            case ReferenceKind.Class:
                var classKey = Split(m.Key, 2);
                context.Classes.Add(new Class
                {
                    Department = classKey[0], ClassCode = classKey[1], ClassName = m.Name,
                    SummaryFlag = m.SummaryFlag,
                });
                break;
            case ReferenceKind.Category:
                var categoryKey = Split(m.Key, 3);
                context.Categories.Add(new Category
                {
                    DepartmentCode = categoryKey[0], ClassCode = categoryKey[1], CategoryCode = categoryKey[2],
                    CategoryName = m.Name, CostingMethod = m.CostingMethod ?? "1",
                    InventoryMethod = m.InventoryMethod ?? "1", TaxMethod = m.TaxMethod ?? "1",
                    SummaryFlag = m.SummaryFlag,
                });
                break;
            case ReferenceKind.Brand:
                context.Brands.Add(new Brand { BrandCode = m.Key, BrandDescription = m.Name });
                break;
            case ReferenceKind.Material:
                context.Materials.Add(new Material { MaterialCode = m.Key, MaterialDescription = m.Name });
                break;
            case ReferenceKind.TaxMethod:
                context.TaxMethods.Add(new TaxMethod { TaxCode = m.Key, TaxName = m.Name });
                break;
            case ReferenceKind.PaymentMethod:
                context.PaymentMethods.Add(new PaymentMethod
                {
                    PaymentCode = m.Key, PaymentNameShort = m.PaymentNameShort ?? m.Key,
                    PaymentNameLong = m.Name, ExchangeRate = m.ExchangeRate ?? 1,
                });
                break;
        }

        await context.SaveChangesAsync(ct);
    }

    public async Task UpdateAsync(ReferenceMutation m, CancellationToken ct)
    {
        switch (m.Kind)
        {
            case ReferenceKind.City when int.TryParse(m.Key, out var code):
                (await context.Cities.SingleAsync(x => x.Code == code, ct)).CityName = m.Name;
                break;
            case ReferenceKind.Province:
                (await context.Provinces.SingleAsync(x => x.ProvinceCode == m.Key, ct)).ProvinceName = m.Name;
                break;
            case ReferenceKind.Country:
                (await context.Countries.SingleAsync(x => x.CountryCode == m.Key, ct)).CountryName = m.Name;
                break;
            case ReferenceKind.Department:
                var department = await context.Departments.SingleAsync(x => x.DepartmentCode == m.Key, ct);
                department.DepartmentName = m.Name;
                department.SummaryFlag = m.SummaryFlag;
                break;
            case ReferenceKind.Class:
                var classKey = Split(m.Key, 2);
                var classRow = await context.Classes.SingleAsync(
                    x => x.Department == classKey[0] && x.ClassCode == classKey[1], ct);
                classRow.ClassName = m.Name;
                classRow.SummaryFlag = m.SummaryFlag;
                break;
            case ReferenceKind.Category:
                var categoryKey = Split(m.Key, 3);
                var category = await context.Categories.SingleAsync(
                    x => x.DepartmentCode == categoryKey[0] && x.ClassCode == categoryKey[1]
                         && x.CategoryCode == categoryKey[2], ct);
                category.CategoryName = m.Name;
                category.CostingMethod = m.CostingMethod ?? category.CostingMethod;
                category.InventoryMethod = m.InventoryMethod ?? category.InventoryMethod;
                category.TaxMethod = m.TaxMethod ?? category.TaxMethod;
                category.SummaryFlag = m.SummaryFlag;
                break;
            case ReferenceKind.Brand:
                (await context.Brands.SingleAsync(x => x.BrandCode == m.Key, ct)).BrandDescription = m.Name;
                break;
            case ReferenceKind.Material:
                (await context.Materials.SingleAsync(x => x.MaterialCode == m.Key, ct)).MaterialDescription = m.Name;
                break;
            case ReferenceKind.TaxMethod:
                (await context.TaxMethods.SingleAsync(x => x.TaxCode == m.Key, ct)).TaxName = m.Name;
                break;
            case ReferenceKind.PaymentMethod:
                var payment = await context.PaymentMethods.SingleAsync(x => x.PaymentCode == m.Key, ct);
                payment.PaymentNameLong = m.Name;
                payment.PaymentNameShort = m.PaymentNameShort ?? payment.PaymentNameShort;
                payment.ExchangeRate = m.ExchangeRate ?? payment.ExchangeRate;
                break;
        }

        await context.SaveChangesAsync(ct);
    }

    public async Task RetireAsync(
        ReferenceKind kind, string key, string reason, string? actor, CancellationToken ct)
    {
        var type = kind.ToString();
        var existing = await context.EntityRetirements.FindAsync(new object[] { type, key }, ct);
        if (existing is null)
        {
            context.EntityRetirements.Add(new EntityRetirement
            {
                EntityType = type, EntityKey = key, Reason = reason,
                RetiredBy = actor, RetiredAt = DateTimeOffset.UtcNow,
            });
        }
        else
        {
            existing.Reason = reason;
            existing.RetiredBy = actor;
            existing.RetiredAt = DateTimeOffset.UtcNow;
        }

        await context.SaveChangesAsync(ct);
    }

    private static string[] Split(string key, int expected = 0)
    {
        var parts = key.Split('/');
        if (expected == 0 || parts.Length == expected) return parts;
        return parts.Concat(Enumerable.Repeat(string.Empty, expected)).Take(expected).ToArray();
    }
}
