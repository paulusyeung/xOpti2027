using Microsoft.EntityFrameworkCore;
using xOpti.Application.Identity.Staff;
using xOpti.Infrastructure.Persistence;

namespace xOpti.Infrastructure.Identity;

/// <summary>Reads the migrated public.staff directory without exposing credentials.</summary>
public sealed class EfLegacyStaffDirectory(XOptiDbContext context) : ILegacyStaffDirectory
{
    public async Task<IReadOnlyList<LegacyStaffDto>> PageAsync(
        string? search,
        string? afterCode,
        int limit,
        CancellationToken cancellationToken)
    {
        var term = string.IsNullOrWhiteSpace(search) ? null : $"%{search.Trim()}%";

        var query =
            from staff in context.LegacyStaff.AsNoTracking()
            join title in context.JobTitles.AsNoTracking()
                on staff.JobTitle equals title.JobTitleCode into titles
            from title in titles.DefaultIfEmpty()
            where afterCode == null || staff.StaffCode.CompareTo(afterCode) > 0
            where term == null
                || EF.Functions.ILike(staff.StaffCode, term)
                || EF.Functions.ILike(staff.FirstName ?? string.Empty, term)
                || EF.Functions.ILike(staff.LastName ?? string.Empty, term)
                || EF.Functions.ILike(staff.JobTitle ?? string.Empty, term)
                || EF.Functions.ILike(title == null ? string.Empty : title.JobTitleName, term)
            orderby staff.StaffCode
            select new LegacyStaffDto(
                staff.StaffCode,
                staff.FirstName,
                staff.LastName,
                staff.JobTitle,
                title == null ? null : title.JobTitleName);

        return await query.Take(limit).ToListAsync(cancellationToken);
    }
}
