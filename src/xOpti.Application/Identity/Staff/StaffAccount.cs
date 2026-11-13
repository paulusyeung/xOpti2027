using System.Text.Json;
using System.Text.Json.Serialization;
using xOpti.Application.Authorization;
using xOpti.Application.Ports;

namespace xOpti.Application.Identity.Staff;

/// <summary>
/// A staff identity as administered by the security slice. PII fields (email,
/// phone) are present on the model so the projection can decide whether to
/// emit them; they must never reach a caller without <c>staff:pii</c>.
/// </summary>
public sealed record StaffAccount(
    string Id,
    string UserName,
    string? DisplayName,
    int LegacyLevel,
    IReadOnlyList<string> Roles,
    string? BranchCode,
    bool ResetRequired,
    bool Disabled,
    string? Email,
    string? PhoneNumber);

/// <summary>Response shape for staff administration (PII already projected).</summary>
public sealed record StaffAccountDto(
    string Id,
    string UserName,
    string? DisplayName,
    int LegacyLevel,
    IReadOnlyList<string> Roles,
    string? BranchCode,
    bool ResetRequired,
    bool Disabled,
    [property: JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)] string? Email,
    [property: JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)] string? PhoneNumber)
{
    public StaffAccountDto WithoutPii() => this with { Email = null, PhoneNumber = null };
}

/// <summary>Response for commands that issue a one-time reset token.</summary>
public sealed record StaffCredentialsDto(StaffAccountDto Account, string ResetToken);

/// <summary>Input for creating a staff account; no password is ever accepted.</summary>
public sealed record NewStaffAccount(
    string UserName,
    string? DisplayName,
    string Role,
    string? BranchCode);

/// <summary>
/// Persistence port for the staff identity lifecycle. Implementations use the
/// Identity stores; every mutating method bumps the security stamp so existing
/// sessions are invalidated on their next request.
/// </summary>
public interface IStaffAccountStore
{
    Task<StaffAccount?> FindByIdAsync(string userId, CancellationToken cancellationToken);

    Task<bool> UserNameExistsAsync(string userName, CancellationToken cancellationToken);

    Task<bool> BranchExistsAsync(string branchCode, CancellationToken cancellationToken);

    Task<IReadOnlyList<StaffAccount>> GetPageAfterAsync(
        string? afterUserName,
        int limit,
        CancellationToken cancellationToken);

    Task<(StaffAccount Account, string ResetToken)> CreateAsync(
        NewStaffAccount account,
        CancellationToken cancellationToken);

    Task<StaffAccount> SetDisabledAsync(
        StaffAccount account,
        bool disabled,
        CancellationToken cancellationToken);

    Task<StaffAccount> SetRoleAsync(
        StaffAccount account,
        string role,
        CancellationToken cancellationToken);

    Task<StaffAccount> SetBranchAsync(
        StaffAccount account,
        string? branchCode,
        CancellationToken cancellationToken);

    Task<(StaffAccount Account, string ResetToken)> ForceResetAsync(
        StaffAccount account,
        CancellationToken cancellationToken);
}

/// <summary>Read-only role catalogue from the versioned permission matrix.</summary>
public interface IRoleCatalogue
{
    IReadOnlyList<string> KnownRoles { get; }

    bool Exists(string role);
}

/// <summary>One projection rule for staff responses and audit snapshots.</summary>
public static class StaffProjection
{
    public static StaffAccountDto ToDto(StaffAccount account, ICurrentPrincipal principal)
    {
        var dto = new StaffAccountDto(
            account.Id,
            account.UserName,
            account.DisplayName,
            account.LegacyLevel,
            account.Roles,
            account.BranchCode,
            account.ResetRequired,
            account.Disabled,
            account.Email,
            account.PhoneNumber);

        return principal.HasPermission(PermissionNames.StaffPii) ? dto : dto.WithoutPii();
    }

    /// <summary>
    /// Allow-listed audit payload: identity and access state only. Email, phone,
    /// password material, and other PII are deliberately excluded.
    /// </summary>
    public static string AuditSnapshot(StaffAccount account) =>
        JsonSerializer.Serialize(new
        {
            account.UserName,
            account.DisplayName,
            account.LegacyLevel,
            Roles = account.Roles,
            account.BranchCode,
            account.ResetRequired,
            account.Disabled,
        });
}
