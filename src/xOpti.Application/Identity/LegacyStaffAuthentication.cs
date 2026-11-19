namespace xOpti.Application.Identity;

public sealed record LegacyStaffIdentity(
    string StaffCode, string? DisplayName, string? JobTitle, int SecurityLevel, string? Role);

public interface ILegacyStaffAuthenticator
{
    Task<LegacyStaffIdentity?> AuthenticateAsync(
        string staffCode, string password, CancellationToken ct);
}

public static class LegacyStaffRoleMap
{
    /// <summary>
    /// Maps the legacy staff.job_title code to the closest approved application
    /// role. Unknown titles fall back to the signed security-level matrix; a
    /// staff member with neither is denied instead of receiving permissions.
    /// </summary>
    public static string? RoleFor(string? jobTitle)
    {
        var code = jobTitle?.Trim();
        return code switch
        {
            "101" => "admin",
            "300" or "302" or "303" => "manager",
            "200" or "202" => "optician",
            "100" or "102" => "clerk",
            _ => null,
        };
    }
}
