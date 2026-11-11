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
/// Role -> permission-claim matrix implementing the authorization-model
/// vocabulary. Unknown roles resolve to the default-deny set (no permissions),
/// never to full access.
/// </summary>
public static class RolePermissionMatrix
{
    public const string Clerk = "clerk";
    public const string Optician = "optician";
    public const string Purchasing = "purchasing";
    public const string Manager = "manager";
    public const string Admin = "admin";

    public static readonly IReadOnlyList<string> KnownRoles = new[] { Clerk, Optician, Purchasing, Manager, Admin };

    public static IReadOnlyList<string> PermissionsFor(IEnumerable<string> roles)
    {
        var set = new HashSet<string>();
        foreach (var role in roles)
        {
            foreach (var permission in ForRole(role))
            {
                set.Add(permission);
            }
        }

        return set.ToList();
    }

    private static IEnumerable<string> ForRole(string role) => role switch
    {
        Clerk => new[] { PermissionNames.SalesOrderCreate },
        Optician => new[] { PermissionNames.SalesOrderCreate, PermissionNames.SalesInvoicePost, PermissionNames.PrescriptionEnter, PermissionNames.PrescriptionView },
        Purchasing => new[] { PermissionNames.InventoryReceive, PermissionNames.InventoryAdjust, PermissionNames.WholesaleInvoicePost },
        Manager => new[]
        {
            PermissionNames.SalesOrderCreate, PermissionNames.SalesInvoicePost, PermissionNames.SalesPriceOverride,
            PermissionNames.PrescriptionEnter, PermissionNames.PrescriptionView,
            PermissionNames.InventoryReceive, PermissionNames.InventoryAdjust, PermissionNames.WholesaleInvoicePost,
            PermissionNames.CostView, PermissionNames.ReportFinancial, PermissionNames.MasterDataMaintain,
        },
        Admin => PermissionNames.All,
        // Default-deny: no permission claims for unmapped roles.
        _ => Array.Empty<string>(),
    };
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
        services.AddDataProtection();
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

        return identity;
    }
}
