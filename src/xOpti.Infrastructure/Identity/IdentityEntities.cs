using Microsoft.AspNetCore.Identity;

namespace xOpti.Infrastructure.Identity;

public class XoptiUser : IdentityUser
{
    public string? DisplayName { get; set; }

    /// <summary>Legacy SecurityLevel the account was seeded from; -1 when none.</summary>
    public int LegacyLevel { get; set; } = -1;

    /// <summary>True until the account has completed a password reset.</summary>
    public bool ResetRequired { get; set; }

    /// <summary>Administratively disabled; existing sessions are rejected on next request.</summary>
    public bool Disabled { get; set; }

    /// <summary>Default branch claim; null when the account is not branch-scoped.</summary>
    public string? DefaultBranchCode { get; set; }
}

public class XoptiRole : IdentityRole
{
    public string? Description { get; set; }
}
