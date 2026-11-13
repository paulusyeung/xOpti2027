using Microsoft.EntityFrameworkCore;
using xOpti.Application.Reference;
using xOpti.Infrastructure.Persistence;

namespace xOpti.Infrastructure.Repositories;

/// <summary>Read-only reference directory over the migrated public tables.</summary>
public sealed class EfReferenceDirectory(XOptiDbContext context) : IReferenceDirectory
{
    public async Task<IReadOnlyList<ReferenceItemDto>> PageAsync(
        ReferenceKind kind,
        string? search,
        string? afterKey,
        int limit,
        CancellationToken cancellationToken)
    {
        var retired = await context.EntityRetirements.AsNoTracking()
            .Where(row => row.EntityType == kind.ToString())
            .Select(row => row.EntityKey)
            .ToListAsync(cancellationToken);

        var rows = await FetchAsync(kind, search, afterKey, limit + retired.Count, cancellationToken);
        return retired.Count == 0
            ? rows
            : rows.Where(row => !retired.Contains(row.Key, StringComparer.Ordinal)).Take(limit).ToList();
    }

    private Task<IReadOnlyList<ReferenceItemDto>> FetchAsync(
        ReferenceKind kind,
        string? search,
        string? afterKey,
        int limit,
        CancellationToken cancellationToken) =>
        kind switch
        {
            ReferenceKind.City => CitiesAsync(search, afterKey, limit, cancellationToken),
            ReferenceKind.Province => ProvincesAsync(search, afterKey, limit, cancellationToken),
            ReferenceKind.Country => CountriesAsync(search, afterKey, limit, cancellationToken),
            ReferenceKind.Department => DepartmentsAsync(search, afterKey, limit, cancellationToken),
            ReferenceKind.Class => ClassesAsync(search, afterKey, limit, cancellationToken),
            ReferenceKind.Category => CategoriesAsync(search, afterKey, limit, cancellationToken),
            ReferenceKind.Brand => BrandsAsync(search, afterKey, limit, cancellationToken),
            ReferenceKind.Material => MaterialsAsync(search, afterKey, limit, cancellationToken),
            ReferenceKind.TaxMethod => TaxMethodsAsync(search, afterKey, limit, cancellationToken),
            ReferenceKind.PaymentMethod => PaymentMethodsAsync(search, afterKey, limit, cancellationToken),
            _ => Task.FromResult<IReadOnlyList<ReferenceItemDto>>(Array.Empty<ReferenceItemDto>()),
        };

    private async Task<IReadOnlyList<ReferenceItemDto>> CitiesAsync(
        string? search, string? afterKey, int limit, CancellationToken ct)
    {
        var query = context.Cities.AsNoTracking();
        if (!string.IsNullOrWhiteSpace(search))
        {
            var term = $"%{search.Trim()}%";
            query = query.Where(city => EF.Functions.ILike(city.CityName, term));
        }

        if (int.TryParse(afterKey, out var afterCode))
        {
            query = query.Where(city => city.Code > afterCode);
        }

        var rows = await query.OrderBy(city => city.Code).Take(limit).ToListAsync(ct);
        return rows.Select(city => new ReferenceItemDto(
            nameof(ReferenceKind.City),
            city.Code.ToString(),
            city.CityName,
            $"{city.ProvinceCode}/{city.CountryCode}")).ToList();
    }

    private async Task<IReadOnlyList<ReferenceItemDto>> ProvincesAsync(
        string? search, string? afterKey, int limit, CancellationToken ct)
    {
        var query = context.Provinces.AsNoTracking();
        if (!string.IsNullOrWhiteSpace(search))
        {
            var term = $"%{search.Trim()}%";
            query = query.Where(row => EF.Functions.ILike(row.ProvinceName, term));
        }

        if (!string.IsNullOrEmpty(afterKey))
        {
            query = query.Where(row => row.ProvinceCode.CompareTo(afterKey) > 0);
        }

        var rows = await query.OrderBy(row => row.ProvinceCode).Take(limit).ToListAsync(ct);
        return rows.Select(row => new ReferenceItemDto(
            nameof(ReferenceKind.Province), row.ProvinceCode, row.ProvinceName)).ToList();
    }

    private async Task<IReadOnlyList<ReferenceItemDto>> CountriesAsync(
        string? search, string? afterKey, int limit, CancellationToken ct)
    {
        var query = context.Countries.AsNoTracking();
        if (!string.IsNullOrWhiteSpace(search))
        {
            var term = $"%{search.Trim()}%";
            query = query.Where(row => EF.Functions.ILike(row.CountryName, term));
        }

        if (!string.IsNullOrEmpty(afterKey))
        {
            query = query.Where(row => row.CountryCode.CompareTo(afterKey) > 0);
        }

        var rows = await query.OrderBy(row => row.CountryCode).Take(limit).ToListAsync(ct);
        return rows.Select(row => new ReferenceItemDto(
            nameof(ReferenceKind.Country), row.CountryCode, row.CountryName)).ToList();
    }

    private async Task<IReadOnlyList<ReferenceItemDto>> DepartmentsAsync(
        string? search, string? afterKey, int limit, CancellationToken ct)
    {
        var query = context.Departments.AsNoTracking();
        if (!string.IsNullOrWhiteSpace(search))
        {
            var term = $"%{search.Trim()}%";
            query = query.Where(row => EF.Functions.ILike(row.DepartmentName ?? string.Empty, term));
        }

        if (!string.IsNullOrEmpty(afterKey))
        {
            query = query.Where(row => row.DepartmentCode.CompareTo(afterKey) > 0);
        }

        var rows = await query.OrderBy(row => row.DepartmentCode).Take(limit).ToListAsync(ct);
        return rows.Select(row => new ReferenceItemDto(
            nameof(ReferenceKind.Department), row.DepartmentCode, row.DepartmentName ?? row.DepartmentCode)).ToList();
    }

    private async Task<IReadOnlyList<ReferenceItemDto>> ClassesAsync(
        string? search, string? afterKey, int limit, CancellationToken ct)
    {
        var (afterDepartment, afterClass) = Split(afterKey);
        var query = context.Classes.AsNoTracking();
        if (!string.IsNullOrWhiteSpace(search))
        {
            var term = $"%{search.Trim()}%";
            query = query.Where(row => EF.Functions.ILike(row.ClassName ?? string.Empty, term));
        }

        if (afterDepartment is not null)
        {
            query = query.Where(row =>
                row.Department.CompareTo(afterDepartment) > 0
                || (row.Department == afterDepartment && row.ClassCode.CompareTo(afterClass) > 0));
        }

        var rows = await query
            .OrderBy(row => row.Department).ThenBy(row => row.ClassCode)
            .Take(limit).ToListAsync(ct);
        return rows.Select(row => new ReferenceItemDto(
            nameof(ReferenceKind.Class),
            $"{row.Department}/{row.ClassCode}",
            row.ClassName ?? row.ClassCode,
            row.Department)).ToList();
    }

    private async Task<IReadOnlyList<ReferenceItemDto>> CategoriesAsync(
        string? search, string? afterKey, int limit, CancellationToken ct)
    {
        var parts = (afterKey ?? string.Empty).Split('/');
        string? afterDepartment = parts.Length == 3 ? parts[0] : null;
        string? afterClass = parts.Length == 3 ? parts[1] : null;
        string? afterCategory = parts.Length == 3 ? parts[2] : null;

        var query = context.Categories.AsNoTracking();
        if (!string.IsNullOrWhiteSpace(search))
        {
            var term = $"%{search.Trim()}%";
            query = query.Where(row => EF.Functions.ILike(row.CategoryName ?? string.Empty, term));
        }

        if (afterDepartment is not null)
        {
            query = query.Where(row =>
                row.DepartmentCode.CompareTo(afterDepartment) > 0
                || (row.DepartmentCode == afterDepartment && row.ClassCode.CompareTo(afterClass) > 0)
                || (row.DepartmentCode == afterDepartment && row.ClassCode == afterClass
                    && row.CategoryCode.CompareTo(afterCategory) > 0));
        }

        var rows = await query
            .OrderBy(row => row.DepartmentCode).ThenBy(row => row.ClassCode).ThenBy(row => row.CategoryCode)
            .Take(limit).ToListAsync(ct);
        return rows.Select(row => new ReferenceItemDto(
            nameof(ReferenceKind.Category),
            $"{row.DepartmentCode}/{row.ClassCode}/{row.CategoryCode}",
            row.CategoryName ?? row.CategoryCode,
            $"{row.DepartmentCode}/{row.ClassCode}",
            $"costing {row.CostingMethod}, inventory {row.InventoryMethod}, tax {row.TaxMethod}")).ToList();
    }

    private async Task<IReadOnlyList<ReferenceItemDto>> BrandsAsync(
        string? search, string? afterKey, int limit, CancellationToken ct)
    {
        var query = context.Brands.AsNoTracking();
        if (!string.IsNullOrWhiteSpace(search))
        {
            var term = $"%{search.Trim()}%";
            query = query.Where(row => EF.Functions.ILike(row.BrandDescription ?? string.Empty, term));
        }

        if (!string.IsNullOrEmpty(afterKey))
        {
            query = query.Where(row => row.BrandCode.CompareTo(afterKey) > 0);
        }

        var rows = await query.OrderBy(row => row.BrandCode).Take(limit).ToListAsync(ct);
        return rows.Select(row => new ReferenceItemDto(
            nameof(ReferenceKind.Brand), row.BrandCode, row.BrandDescription ?? row.BrandCode)).ToList();
    }

    private async Task<IReadOnlyList<ReferenceItemDto>> MaterialsAsync(
        string? search, string? afterKey, int limit, CancellationToken ct)
    {
        var query = context.Materials.AsNoTracking();
        if (!string.IsNullOrWhiteSpace(search))
        {
            var term = $"%{search.Trim()}%";
            query = query.Where(row => EF.Functions.ILike(row.MaterialDescription ?? string.Empty, term));
        }

        if (!string.IsNullOrEmpty(afterKey))
        {
            query = query.Where(row => row.MaterialCode.CompareTo(afterKey) > 0);
        }

        var rows = await query.OrderBy(row => row.MaterialCode).Take(limit).ToListAsync(ct);
        return rows.Select(row => new ReferenceItemDto(
            nameof(ReferenceKind.Material), row.MaterialCode, row.MaterialDescription ?? row.MaterialCode)).ToList();
    }

    private async Task<IReadOnlyList<ReferenceItemDto>> TaxMethodsAsync(
        string? search, string? afterKey, int limit, CancellationToken ct)
    {
        var query = context.TaxMethods.AsNoTracking();
        if (!string.IsNullOrWhiteSpace(search))
        {
            var term = $"%{search.Trim()}%";
            query = query.Where(row => EF.Functions.ILike(row.TaxName, term));
        }

        if (!string.IsNullOrEmpty(afterKey))
        {
            query = query.Where(row => row.TaxCode.CompareTo(afterKey) > 0);
        }

        var rows = await query.OrderBy(row => row.TaxCode).Take(limit).ToListAsync(ct);
        return rows.Select(row => new ReferenceItemDto(
            nameof(ReferenceKind.TaxMethod), row.TaxCode, row.TaxName)).ToList();
    }

    private async Task<IReadOnlyList<ReferenceItemDto>> PaymentMethodsAsync(
        string? search, string? afterKey, int limit, CancellationToken ct)
    {
        var query = context.PaymentMethods.AsNoTracking();
        if (!string.IsNullOrWhiteSpace(search))
        {
            var term = $"%{search.Trim()}%";
            query = query.Where(row =>
                EF.Functions.ILike(row.PaymentNameLong, term)
                || EF.Functions.ILike(row.PaymentNameShort, term));
        }

        if (!string.IsNullOrEmpty(afterKey))
        {
            query = query.Where(row => row.PaymentCode.CompareTo(afterKey) > 0);
        }

        var rows = await query.OrderBy(row => row.PaymentCode).Take(limit).ToListAsync(ct);
        return rows.Select(row => new ReferenceItemDto(
            nameof(ReferenceKind.PaymentMethod),
            row.PaymentCode,
            row.PaymentNameLong,
            Detail: $"{row.PaymentNameShort} rate {row.ExchangeRate}")).ToList();
    }

    private static (string? Department, string Class) Split(string? key)
    {
        if (string.IsNullOrEmpty(key))
        {
            return (null, string.Empty);
        }

        var parts = key.Split('/', 2);
        return parts.Length == 2 ? (parts[0], parts[1]) : (null, string.Empty);
    }
}
