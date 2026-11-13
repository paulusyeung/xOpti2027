using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using xOpti.Application.Common;
using xOpti.Application.Identity.Staff;
using xOpti.Infrastructure.Persistence;

namespace xOpti.Infrastructure.Identity;

/// <summary>
/// Identity-store implementation of the staff lifecycle. Every mutating method
/// updates the security stamp so existing cookie sessions fail validation on
/// their next request (the cookie handler rejects the principal).
/// </summary>
public sealed class EfStaffAccountStore(
    XOptiDbContext context,
    UserManager<XoptiUser> users,
    RoleManager<XoptiRole> roles) : IStaffAccountStore
{
    public async Task<StaffAccount?> FindByIdAsync(string userId, CancellationToken cancellationToken)
    {
        var user = await users.FindByIdAsync(userId);
        return user is null ? null : await MapAsync(user);
    }

    public async Task<bool> UserNameExistsAsync(string userName, CancellationToken cancellationToken) =>
        await users.FindByNameAsync(userName) is not null;

    public async Task<bool> BranchExistsAsync(string branchCode, CancellationToken cancellationToken) =>
        await context.Branches.AsNoTracking().AnyAsync(branch => branch.BranchCode == branchCode, cancellationToken);

    public async Task<IReadOnlyList<StaffAccount>> GetPageAfterAsync(
        string? afterUserName,
        int limit,
        CancellationToken cancellationToken)
    {
        var query = context.Users.AsNoTracking();
        if (!string.IsNullOrEmpty(afterUserName))
        {
            query = query.Where(user => user.UserName != null && user.UserName.CompareTo(afterUserName) > 0);
        }

        var rows = await query
            .OrderBy(user => user.UserName)
            .Take(limit)
            .ToListAsync(cancellationToken);

        var accounts = new List<StaffAccount>(rows.Count);
        foreach (var user in rows)
        {
            accounts.Add(await MapAsync(user));
        }

        return accounts;
    }

    public async Task<(StaffAccount Account, string ResetToken)> CreateAsync(
        NewStaffAccount account,
        CancellationToken cancellationToken)
    {
        if (!RolePermissionMatrix.IsKnownRole(account.Role))
        {
            throw new DomainRuleException($"Role '{account.Role}' is not part of the approved permission matrix.");
        }

        var user = new XoptiUser
        {
            UserName = account.UserName,
            DisplayName = account.DisplayName,
            LegacyLevel = -1,
            ResetRequired = true,
            Disabled = false,
            DefaultBranchCode = string.IsNullOrWhiteSpace(account.BranchCode) ? null : account.BranchCode,
        };

        var created = await users.CreateAsync(user);
        if (!created.Succeeded)
        {
            throw new DomainRuleException(
                $"Could not create staff account: {string.Join("; ", created.Errors.Select(e => e.Description))}");
        }

        var roleResult = await users.AddToRoleAsync(user, account.Role);
        if (!roleResult.Succeeded)
        {
            throw new DomainRuleException(
                $"Could not assign role '{account.Role}': {string.Join("; ", roleResult.Errors.Select(e => e.Description))}");
        }

        var token = await users.GeneratePasswordResetTokenAsync(user);
        return (await MapAsync(user), token);
    }

    public async Task<StaffAccount> SetDisabledAsync(
        StaffAccount account,
        bool disabled,
        CancellationToken cancellationToken)
    {
        var user = await RequireAsync(account);
        user.Disabled = disabled;
        if (!disabled)
        {
            user.LockoutEnd = null;
            user.AccessFailedCount = 0;
        }

        await PersistAndInvalidateAsync(user);
        return await MapAsync(user);
    }

    public async Task<StaffAccount> SetRoleAsync(
        StaffAccount account,
        string role,
        CancellationToken cancellationToken)
    {
        if (!RolePermissionMatrix.IsKnownRole(role))
        {
            throw new DomainRuleException($"Role '{role}' is not part of the approved permission matrix.");
        }

        var user = await RequireAsync(account);
        var current = await users.GetRolesAsync(user);
        foreach (var existing in current)
        {
            var removal = await users.RemoveFromRoleAsync(user, existing);
            if (!removal.Succeeded)
            {
                throw new DomainRuleException(
                    $"Could not remove role '{existing}': {string.Join("; ", removal.Errors.Select(e => e.Description))}");
            }
        }

        var added = await users.AddToRoleAsync(user, role);
        if (!added.Succeeded)
        {
            throw new DomainRuleException(
                $"Could not assign role '{role}': {string.Join("; ", added.Errors.Select(e => e.Description))}");
        }

        await users.UpdateSecurityStampAsync(user);
        return await MapAsync(user);
    }

    public async Task<StaffAccount> SetBranchAsync(
        StaffAccount account,
        string? branchCode,
        CancellationToken cancellationToken)
    {
        var user = await RequireAsync(account);
        user.DefaultBranchCode = string.IsNullOrWhiteSpace(branchCode) ? null : branchCode;
        await PersistAndInvalidateAsync(user);
        return await MapAsync(user);
    }

    public async Task<(StaffAccount Account, string ResetToken)> ForceResetAsync(
        StaffAccount account,
        CancellationToken cancellationToken)
    {
        var user = await RequireAsync(account);
        user.ResetRequired = true;
        await PersistAndInvalidateAsync(user);

        // Generate the token after the stamp changes so the token matches the
        // invalidated session state.
        var token = await users.GeneratePasswordResetTokenAsync(user);
        return (await MapAsync(user), token);
    }

    private async Task<XoptiUser> RequireAsync(StaffAccount account)
    {
        var user = await users.FindByIdAsync(account.Id);
        return user ?? throw new DomainRuleException($"Staff account '{account.UserName}' was not found.");
    }

    private async Task PersistAndInvalidateAsync(XoptiUser user)
    {
        var updated = await users.UpdateAsync(user);
        if (!updated.Succeeded)
        {
            throw new DomainRuleException(
                $"Could not update staff account: {string.Join("; ", updated.Errors.Select(e => e.Description))}");
        }

        await users.UpdateSecurityStampAsync(user);
    }

    private async Task<StaffAccount> MapAsync(XoptiUser user)
    {
        var assigned = await users.GetRolesAsync(user);
        return new StaffAccount(
            user.Id,
            user.UserName ?? string.Empty,
            user.DisplayName,
            user.LegacyLevel,
            assigned.OrderBy(role => role, StringComparer.Ordinal).ToList(),
            user.DefaultBranchCode,
            user.ResetRequired,
            user.Disabled,
            user.Email,
            user.PhoneNumber);
    }
}
