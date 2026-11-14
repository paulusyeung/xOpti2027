using Microsoft.EntityFrameworkCore;
using xOpti.Application.Reference;
using xOpti.Infrastructure.Persistence;
using xOpti.Infrastructure.Persistence.Entities;

namespace xOpti.Infrastructure.Repositories;

public sealed class EfPartyDirectory(XOptiDbContext context) : IPartyDirectory
{
    public async Task<IReadOnlyList<SupplierDto>> PageSuppliersAsync(
        string? search, string? afterKey, int limit, CancellationToken ct)
    {
        var retired = context.EntityRetirements
            .Where(row => row.EntityType == "Supplier").Select(row => row.EntityKey);
        var query = context.Suppliers.AsNoTracking().Where(row => !retired.Contains(row.SupplierCode));
        if (!string.IsNullOrWhiteSpace(search))
        {
            var term = $"%{search.Trim()}%";
            query = query.Where(row =>
                EF.Functions.ILike(row.SupplierName ?? string.Empty, term)
                || EF.Functions.ILike(row.SupplierCode, term));
        }

        if (!string.IsNullOrEmpty(afterKey))
        {
            query = query.Where(row => row.SupplierCode.CompareTo(afterKey) > 0);
        }

        var rows = await query.OrderBy(row => row.SupplierCode).Take(limit).ToListAsync(ct);
        return rows.Select(row => new SupplierDto(row.SupplierCode, row.SupplierName, row.CityCode,
            row.Province, row.Country, row.Phone, row.ContactPerson, row.CreditLimit, row.PaymentTerms)).ToList();
    }

    public async Task<IReadOnlyList<DoctorDto>> PageDoctorsAsync(
        string? search, string? afterKey, int limit, CancellationToken ct)
    {
        var retired = context.EntityRetirements
            .Where(row => row.EntityType == "Doctor").Select(row => row.EntityKey);
        var query = context.Doctors.AsNoTracking()
            .Where(row => !retired.Contains(row.Id.ToString()));
        if (!string.IsNullOrWhiteSpace(search))
        {
            var term = $"%{search.Trim()}%";
            query = query.Where(row => EF.Functions.ILike(row.DoctorName ?? string.Empty, term));
        }

        if (int.TryParse(afterKey, out var afterId))
        {
            query = query.Where(row => row.Id > afterId);
        }

        var rows = await query.OrderBy(row => row.Id).Take(limit).ToListAsync(ct);
        return rows.Select(row => new DoctorDto(row.Id, row.DoctorName, row.Address, row.CityCode,
            row.Province, row.Country, row.Phone, row.PostalCode)).ToList();
    }

    public async Task<IReadOnlyList<SupplierContactDto>> ContactsAsync(string supplierCode, CancellationToken ct)
    {
        var rows = await context.SupplierContacts.AsNoTracking()
            .Where(row => row.SupCode == supplierCode)
            .OrderBy(row => row.LastName).ThenBy(row => row.FirstName)
            .ToListAsync(ct);
        return rows.Select(row => new SupplierContactDto(row.SupCode, row.FirstName, row.Initial,
            row.LastName, row.FullName, row.JobTitle, row.PhoneGeneralVoice, row.PhoneMobile)).ToList();
    }

    public Task<bool> SupplierExistsAsync(string code, CancellationToken ct) =>
        context.Suppliers.AnyAsync(row => row.SupplierCode == code, ct);

    public Task<bool> ContactExistsAsync(
        string code, string first, string initial, string last, CancellationToken ct) =>
        context.SupplierContacts.AnyAsync(row =>
            row.SupCode == code && row.FirstName == first && row.Initial == initial && row.LastName == last, ct);

    public async Task CreateSupplierAsync(SupplierDto supplier, CancellationToken ct)
    {
        context.Suppliers.Add(new Supplier
        {
            SupplierCode = supplier.SupplierCode,
            SupplierName = supplier.Name,
            CityCode = supplier.CityCode,
            Province = supplier.Province,
            Country = supplier.Country,
            Phone = supplier.Phone,
            ContactPerson = supplier.ContactPerson,
            CreditLimit = supplier.CreditLimit,
            PaymentTerms = supplier.PaymentTerms,
        });
        await context.SaveChangesAsync(ct);
    }

    public async Task CreateDoctorAsync(DoctorDto doctor, CancellationToken ct)
    {
        context.Doctors.Add(new Doctor
        {
            Id = doctor.Id,
            DoctorName = doctor.Name,
            Address = doctor.Address,
            CityCode = doctor.CityCode,
            Province = doctor.Province,
            Country = doctor.Country,
            Phone = doctor.Phone,
            PostalCode = doctor.PostalCode,
        });
        await context.SaveChangesAsync(ct);
    }

    public async Task CreateContactAsync(SupplierContactDto contact, CancellationToken ct)
    {
        context.SupplierContacts.Add(new SupplierContact
        {
            SupCode = contact.SupplierCode,
            FirstName = contact.FirstName,
            Initial = contact.Initial,
            LastName = contact.LastName,
            FullName = contact.FullName,
            JobTitle = contact.JobTitle,
            PhoneGeneralVoice = contact.Phone,
        });
        await context.SaveChangesAsync(ct);
    }

    public async Task<int> NextDoctorIdAsync(CancellationToken ct) =>
        (await context.Doctors.MaxAsync(row => (int?)row.Id, ct) ?? 0) + 1;

    public Task<bool> BranchExistsAsync(string code, CancellationToken ct) =>
        context.Branches.AnyAsync(row => row.BranchCode == code, ct);

    public Task<int> BranchCountAsync(CancellationToken ct)
    {
        var retired = context.EntityRetirements
            .Where(row => row.EntityType == "Branch")
            .Select(row => row.EntityKey);
        return context.Branches.CountAsync(row => !retired.Contains(row.BranchCode), ct);
    }

    public Task<int> StaffScopedToBranchAsync(string code, CancellationToken ct) =>
        context.Users.CountAsync(user => user.DefaultBranchCode == code, ct);

    public Task<int> BranchInventoryRowsAsync(string code, CancellationToken ct) =>
        context.BranchInventory.CountAsync(row => row.BranchCode == code, ct);

    public async Task RetireBranchAsync(string code, string reason, string? actor, CancellationToken ct)
    {
        var existing = await context.EntityRetirements.FindAsync(new object[] { "Branch", code }, ct);
        if (existing is null)
        {
            context.EntityRetirements.Add(new EntityRetirement
            {
                EntityType = "Branch", EntityKey = code, Reason = reason,
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
}
