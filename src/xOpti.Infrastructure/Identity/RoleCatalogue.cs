using xOpti.Application.Identity.Staff;

namespace xOpti.Infrastructure.Identity;

/// <summary>Exposes the versioned permission matrix roles to Application validators.</summary>
public sealed class RoleCatalogue : IRoleCatalogue
{
    public IReadOnlyList<string> KnownRoles => RolePermissionMatrix.KnownRoles;

    public bool Exists(string role) => RolePermissionMatrix.IsKnownRole(role);
}
