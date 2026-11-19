using System.Security.Cryptography;
using System.Text;
using Microsoft.EntityFrameworkCore;
using xOpti.Application.Identity;
using xOpti.Infrastructure.Persistence;

namespace xOpti.Infrastructure.Identity;

/// <summary>
/// Legacy credential check against public.staff (staff_code/password), matching
/// IsSecurityPassed in the Access application. The plaintext legacy password is
/// verified in memory and is never copied into the Identity password hash.
/// </summary>
public sealed class LegacyStaffAuthenticator(XOptiDbContext context)
    : ILegacyStaffAuthenticator
{
    public async Task<LegacyStaffIdentity?> AuthenticateAsync(
        string staffCode, string password, CancellationToken ct)
    {
        if (string.IsNullOrWhiteSpace(staffCode) || string.IsNullOrEmpty(password))
            return null;

        var normalized = staffCode.Trim();
        var staff = await context.LegacyStaff.AsNoTracking()
            .SingleOrDefaultAsync(row => row.StaffCode.ToLower() == normalized.ToLower(), ct);
        if (staff is null || string.IsNullOrEmpty(staff.Password))
            return null;

        if (!FixedTimeEquals(staff.Password, password))
            return null;

        var role = LegacyStaffRoleMap.RoleFor(staff.JobTitle)
            ?? RolePermissionMatrix.RoleForLevel(staff.SecurityLevel);
        return new LegacyStaffIdentity(staff.StaffCode, staff.StaffFullName,
            staff.JobTitle, staff.SecurityLevel, role);
    }

    private static bool FixedTimeEquals(string stored, string supplied)
    {
        var left = Encoding.UTF8.GetBytes(stored);
        var right = Encoding.UTF8.GetBytes(supplied);
        return left.Length == right.Length
            && CryptographicOperations.FixedTimeEquals(left, right);
    }
}
