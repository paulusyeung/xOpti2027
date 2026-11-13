using xOpti.Application.Identity.Staff;

namespace xOpti.Infrastructure.Identity;

/// <summary>Exposes the versioned permission matrix roles to Application validators.</summary>
public sealed class RoleCatalogue : IRoleCatalogue
{
    public IReadOnlyList<string> KnownRoles => RolePermissionMatrix.KnownRoles;

    public string Version => RolePermissionMatrix.Current.Version;

    public bool Signed => RolePermissionMatrix.Current.Signed;

    public string? SignedBy => RolePermissionMatrix.Current.SignedBy;

    public string? ApprovedOn => RolePermissionMatrix.Current.ApprovedOn;

    public IReadOnlyList<(int MinLevel, string Role)> LevelRules =>
        RolePermissionMatrix.Current.LevelRules.Select(rule => (rule.MinLevel, rule.Role)).ToList();

    public IReadOnlyList<string> AllPermissions => xOpti.Application.Authorization.PermissionNames.All;

    public IReadOnlyList<string> UnassignedPermissions =>
        RolePermissionMatrix.Current.UnassignedPermissions.Select(entry => entry.Permission).ToList();

    public IReadOnlyList<string> ParityGaps =>
        RolePermissionMatrix.Current.ParityGaps.Where(gap => gap is not null).Select(gap => gap!).ToList();

    public IReadOnlyList<string> PermissionsForRole(string role) => RolePermissionMatrix.PermissionsForRole(role);

    public bool Exists(string role) => RolePermissionMatrix.IsKnownRole(role);
}
