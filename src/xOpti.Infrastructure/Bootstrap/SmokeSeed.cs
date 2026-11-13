using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using xOpti.Infrastructure.Identity;
using xOpti.Infrastructure.Persistence;
using xOpti.Infrastructure.Persistence.Entities;

namespace xOpti.Infrastructure.Bootstrap;

/// <summary>
/// Development/smoke accounts and branches for the compose smoke stack and the
/// E2E suite. Never call this on a production database: the CLI mode refuses
/// unless <c>XOPTI_ALLOW_SMOKE_SEED=1</c> is set.
/// </summary>
public static class SmokeSeed
{
    public const string DefaultPassword = "Test#Passw0rd1!";

    public static async Task ApplyAsync(
        IServiceProvider services,
        string password = DefaultPassword,
        CancellationToken cancellationToken = default)
    {
        await using var scope = services.CreateAsyncScope();
        var context = scope.ServiceProvider.GetRequiredService<XOptiDbContext>();
        var roles = scope.ServiceProvider.GetRequiredService<RoleManager<XoptiRole>>();
        var users = scope.ServiceProvider.GetRequiredService<UserManager<XoptiUser>>();

        foreach (var role in RolePermissionMatrix.KnownRoles)
        {
            if (!await roles.RoleExistsAsync(role))
            {
                var created = await roles.CreateAsync(new XoptiRole { Name = role });
                if (!created.Succeeded)
                {
                    throw new SchemaBootstrapException(
                        $"Could not seed role '{role}': {string.Join("; ", created.Errors.Select(e => e.Description))}");
                }
            }
        }

        for (var i = 1; i <= 7; i++)
        {
            var code = $"0{i}";
            if (!await context.Branches.AnyAsync(b => b.BranchCode == code, cancellationToken))
            {
                context.Branches.Add(new Branch
                {
                    BranchCode = code,
                    BranchName = $"Branch {i}",
                    City = "Richmond",
                });
            }
        }

        await context.SaveChangesAsync(cancellationToken);

        foreach (var (name, role) in new[]
                 {
                     ("manager", RolePermissionMatrix.Manager),
                     ("clerk", RolePermissionMatrix.Clerk),
                     ("purchasing", RolePermissionMatrix.Purchasing),
                     ("admin", RolePermissionMatrix.Admin),
                 })
        {
            if (await users.FindByNameAsync(name) is not null)
            {
                continue;
            }

            var user = new XoptiUser { UserName = name, DisplayName = name };
            var created = await users.CreateAsync(user, password);
            if (!created.Succeeded)
            {
                throw new SchemaBootstrapException(
                    $"Could not seed user '{name}': {string.Join("; ", created.Errors.Select(e => e.Description))}");
            }

            await users.AddToRoleAsync(user, role);
            user.ResetRequired = false;
            await users.UpdateAsync(user);
        }
    }
}
