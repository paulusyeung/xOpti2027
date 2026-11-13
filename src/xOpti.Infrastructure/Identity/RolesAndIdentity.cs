using System.Security.Claims;
using Microsoft.AspNetCore.DataProtection;
using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.DependencyInjection.Extensions;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using xOpti.Application.Authorization;

namespace xOpti.Infrastructure.Identity;

/// <summary>
/// Role -> permission-claim matrix backed by the versioned
/// <c>permissions.v1.json</c> file (see <see cref="PermissionMatrix"/>).
/// Unknown roles and unmapped levels resolve to default-deny, never full access.
/// </summary>
public static class RolePermissionMatrix
{
    public const string Clerk = "clerk";
    public const string Optician = "optician";
    public const string Purchasing = "purchasing";
    public const string Manager = "manager";
    public const string Admin = "admin";

    private static readonly Lazy<PermissionMatrix> Loaded = new(() =>
        PermissionMatrix.LoadDefault(Environment.GetEnvironmentVariable("XOPTI_PERMISSIONS_FILE")));

    public static PermissionMatrix Current => Loaded.Value;

    public static IReadOnlyList<string> KnownRoles => Current.KnownRoles;

    public static IReadOnlyList<string> PermissionsFor(IEnumerable<string> roles) => Current.PermissionsFor(roles);

    public static IReadOnlyList<string> PermissionsForRole(string role) => Current.PermissionsForRole(role);

    public static string? RoleForLevel(int level) => Current.RoleForLevel(level);

    public static bool IsKnownRole(string role) => Current.IsKnownRole(role);
}

/// <summary>Adds Identity stores with the hardening options the notes require.</summary>
public static class IdentityServiceCollectionExtensions
{
    public static IServiceCollection AddXOptiIdentity(
        this IServiceCollection services,
        int lockoutMaxFailedAccessAttempts = 5,
        TimeSpan? lockoutWindow = null,
        TimeSpan? sessionIdleTimeout = null)
    {
        var builder = services.AddIdentityCore<XoptiUser>(options =>
            {
                options.Lockout.MaxFailedAccessAttempts = lockoutMaxFailedAccessAttempts;
                options.Lockout.DefaultLockoutTimeSpan = lockoutWindow ?? TimeSpan.FromMinutes(15);
                options.Lockout.AllowedForNewUsers = true;

                options.Password.RequiredLength = 10;
                options.Password.RequireDigit = true;
                options.Password.RequireUppercase = true;
                options.Password.RequireLowercase = true;
                options.Password.RequireNonAlphanumeric = false;

                options.User.AllowedUserNameCharacters =
                    "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789._-";
            })
            .AddRoles<XoptiRole>()
            .AddEntityFrameworkStores<Persistence.XOptiDbContext>();

        services.AddScoped<IPermissionClaimsIssuer, PermissionClaimsIssuer>();

        // Class libraries must wire the reset/confirm token providers explicitly
        // (AddDefaultTokenProviders is an ASP.NET startup helper).
        // Persist the key ring when a directory is configured, so cookie sessions
        // and CSRF tokens survive restarts and can run on more than one instance.
        var keyDirectory = Environment.GetEnvironmentVariable("XOPTI_DATA_PROTECTION_KEYS");
        var dataProtection = services.AddDataProtection();
        if (!string.IsNullOrWhiteSpace(keyDirectory))
        {
            Directory.CreateDirectory(keyDirectory);
            dataProtection.PersistKeysToFileSystem(new DirectoryInfo(keyDirectory));
        }
        services.Configure<DataProtectionTokenProviderOptions>(o => o.TokenLifespan = TimeSpan.FromHours(1));
        services.AddLogging();
        builder.AddTokenProvider<DataProtectorTokenProvider<XoptiUser>>(TokenOptions.DefaultProvider);
        builder.AddTokenProvider<DataProtectorTokenProvider<XoptiUser>>(TokenOptions.DefaultEmailProvider);
        builder.AddSignInManager();

        // Must run after AddSignInManager/AddRoles so Identity's default
        // factory registration is replaced, not shadowed.
        services.Replace(ServiceDescriptor.Scoped<IUserClaimsPrincipalFactory<XoptiUser>, PermissionClaimsPrincipalFactory>());


        return services;
    }
}

/// <summary>Issues the permission claims that a session principal must carry.</summary>
public interface IPermissionClaimsIssuer
{
    IReadOnlyList<Claim> ClaimsForRoles(IEnumerable<string> roles);
}

public sealed class PermissionClaimsIssuer : IPermissionClaimsIssuer
{
    public IReadOnlyList<Claim> ClaimsForRoles(IEnumerable<string> roles) =>
        RolePermissionMatrix.PermissionsFor(roles)
            .Select(p => new Claim("xopti:permission", p))
            .ToList();
}

/// <summary>
/// Adds the mapped permission claims to the sign-in principal so the cookie
/// session carries the authorization-model vocabulary.
/// </summary>
public sealed class PermissionClaimsPrincipalFactory(
    UserManager<XoptiUser> userManager,
    RoleManager<XoptiRole> roleManager,
    Microsoft.Extensions.Options.IOptions<IdentityOptions> options)
    : UserClaimsPrincipalFactory<XoptiUser, XoptiRole>(userManager, roleManager, options)
{
    protected override async Task<System.Security.Claims.ClaimsIdentity> GenerateClaimsAsync(XoptiUser user)
    {
        var identity = await base.GenerateClaimsAsync(user);

        var roles = await UserManager.GetRolesAsync(user);
        foreach (var permission in RolePermissionMatrix.PermissionsFor(roles))
        {
            identity.AddClaim(new System.Security.Claims.Claim(
                ClaimsCurrentPrincipal.PermissionClaimType, permission));
        }

        if (!string.IsNullOrWhiteSpace(user.DefaultBranchCode))
        {
            identity.AddClaim(new System.Security.Claims.Claim(
                ClaimsCurrentPrincipal.BranchClaimType, user.DefaultBranchCode));
        }

        return identity;
    }
}
