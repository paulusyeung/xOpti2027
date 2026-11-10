using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using xOpti.Infrastructure.Persistence;

namespace xOpti.Infrastructure.Identity;

/// <summary>
/// One-shot seeding of app Identity accounts from the legacy staff/users rows.
/// Legacy password material (plaintext `staff.password` / legacy
/// `users.hashed_password`) is NEVER copied: accounts are created without a
/// password and flagged ResetRequired until an admin-issued reset completes.
/// </summary>
public sealed class LegacyUserSeeder(
    XOptiDbContext context,
    UserManager<XoptiUser> users,
    RoleManager<XoptiRole> roles)
{
    public async Task<SeedingReport> SeedAsync(CancellationToken cancellationToken = default)
    {
        foreach (var role in RolePermissionMatrix.KnownRoles)
        {
            if (!await roles.RoleExistsAsync(role))
            {
                await roles.CreateAsync(new XoptiRole { Name = role, Description = "Mapped from legacy security matrix" });
            }
        }

        var report = new SeedingReport();

        foreach (var staff in await context.LegacyStaff.AsNoTracking().ToListAsync(cancellationToken))
        {
            var userName = staff.StaffCode;
            if (await users.FindByNameAsync(userName) is not null)
            {
                report.Skipped++;
                continue;
            }

            var user = new XoptiUser
            {
                UserName = userName,
                DisplayName = staff.StaffFullName,
                LegacyLevel = staff.SecurityLevel,
                ResetRequired = true,
                EmailConfirmed = false,
            };

            var result = await users.CreateAsync(user);
            if (!result.Succeeded)
            {
                report.Failed.Add($"{userName}: {string.Join(';', result.Errors.Select(e => e.Code))}");
                continue;
            }

            await users.AddToRoleAsync(user, RoleForLevel(staff.SecurityLevel));
            report.Seeded++;
        }

        foreach (var legacy in await context.LegacyUsers.AsNoTracking().ToListAsync(cancellationToken))
        {
            var userName = $"legacy-{legacy.Id}";
            if (legacy.Email is null || await users.FindByNameAsync(userName) is not null)
            {
                report.Skipped++;
                continue;
            }

            var user = new XoptiUser
            {
                UserName = userName,
                Email = legacy.Email,
                LegacyLevel = -1,
                ResetRequired = true,
            };

            var result = await users.CreateAsync(user);
            if (!result.Succeeded)
            {
                report.Failed.Add($"{userName}: {string.Join(';', result.Errors.Select(e => e.Code))}");
                continue;
            }

            await users.AddToRoleAsync(user, RolePermissionMatrix.Clerk);
            report.Seeded++;
        }

        return report;
    }

    /// <summary>
    /// Completes the forced-reset activation: verifies an admin-issued token,
    /// sets a modern hashed password, and clears the reset flag.
    /// </summary>
    public async Task<IdentityResult> CompleteResetAsync(
        XoptiUser user, string resetToken, string newPassword, CancellationToken cancellationToken = default)
    {
        var result = await users.ResetPasswordAsync(user, resetToken, newPassword);
        if (result.Succeeded)
        {
            user.ResetRequired = false;
            await users.UpdateAsync(user);
        }

        return result;
    }

    private static string RoleForLevel(int level) => level switch
    {
        >= 7 => RolePermissionMatrix.Admin,
        >= 5 => RolePermissionMatrix.Manager,
        >= 3 => RolePermissionMatrix.Optician,
        _ => RolePermissionMatrix.Clerk,
    };

    public sealed record SeedingReport
    {
        public int Seeded { get; set; }

        public int Skipped { get; set; }

        public List<string> Failed { get; } = new();
    }
}

/// <summary>Read-only projection of migrated public.staff (no password column mapped).</summary>
public class LegacyStaffRow
{
    public string StaffCode { get; set; } = string.Empty;

    public string? StaffFullName { get; set; }

    public int SecurityLevel { get; set; }
}

/// <summary>Read-only projection of migrated public.users (no hashed_password mapped).</summary>
public class LegacyUserRow
{
    public int Id { get; set; }

    public string? Email { get; set; }

    public bool IsActive { get; set; }
}
