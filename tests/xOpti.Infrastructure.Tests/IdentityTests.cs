using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using xOpti.Application.Authorization;
using xOpti.Application.Ports;
using xOpti.Infrastructure.Identity;
using xOpti.Infrastructure.Persistence;
using xOpti.Infrastructure.Tests.Support;

namespace xOpti.Infrastructure.Tests;

[Collection("postgres")]
public class IdentityTests(PostgresFixture fixture)
{
    private ServiceProvider BuildProvider()
    {
        var services = new ServiceCollection();
        services.AddXOptiInfrastructure(new InfrastructureOptions { ConnectionString = fixture.ConnectionString });
        services.AddXOptiIdentity(lockoutMaxFailedAccessAttempts: 5);
        services.AddDataProtection();
        services.AddScoped<ICurrentPrincipal>(_ => new ClaimsCurrentPrincipal(
            new System.Security.Claims.ClaimsPrincipal()));
        return services.BuildServiceProvider();
    }

    [Fact]
    public async Task Lockout_EnforcesThreshold()
    {
        var provider = BuildProvider();
        using var scope = provider.CreateScope();
        var users = scope.ServiceProvider.GetRequiredService<UserManager<XoptiUser>>();

        var user = new XoptiUser { UserName = "lockout-" + Guid.NewGuid().ToString("N")[..8] };
        Assert.True((await users.CreateAsync(user, "Str0ngPassw0rd!")).Succeeded);

        for (var i = 0; i < 5; i++)
        {
            await users.AccessFailedAsync(user);
        }

        Assert.True(await users.IsLockedOutAsync(user));

        // Lockout state is recorded on the user; only policy expiry/unlock clears it.
        var refreshed = await users.FindByNameAsync(user.UserName);
        Assert.NotNull(refreshed!.LockoutEnd!.Value);
        Assert.True(refreshed.LockoutEnd > DateTimeOffset.UtcNow);
    }

    [Fact]
    public async Task Passwords_UseModernHash_AndValidateAgainstIt()
    {
        var provider = BuildProvider();
        using var scope = provider.CreateScope();
        var users = scope.ServiceProvider.GetRequiredService<UserManager<XoptiUser>>();

        var user = new XoptiUser { UserName = "hash-" + Guid.NewGuid().ToString("N")[..8] };
        await users.CreateAsync(user);
        await users.AddPasswordAsync(user, "Modern#Passw0rd1");

        Assert.True(await users.CheckPasswordAsync(user, "Modern#Passw0rd1"));
        Assert.False(await users.CheckPasswordAsync(user, "legacy1"));
        Assert.False(await users.CheckPasswordAsync(user, string.Empty));
    }

    [Fact]
    public async Task RoleClaims_MatchSeededMatrix_IncludingDefaultDeny()
    {
        var provider = BuildProvider();
        using var scope = provider.CreateScope();
        var users = scope.ServiceProvider.GetRequiredService<UserManager<XoptiUser>>();

        var suffix = Guid.NewGuid().ToString("N")[..8];
        foreach (var (role, userName) in new[]
                 {
                     (RolePermissionMatrix.Manager, "mgr-" + suffix),
                     (RolePermissionMatrix.Clerk, "clk-" + suffix),
                     ("unmapped-role", "unm-" + suffix),
                 })
        {
            if (!await scope.ServiceProvider.GetRequiredService<RoleManager<XoptiRole>>().RoleExistsAsync(role))
            {
                await scope.ServiceProvider.GetRequiredService<RoleManager<XoptiRole>>()
                    .CreateAsync(new XoptiRole { Name = role });
            }

            var u = new XoptiUser { UserName = userName };
            await users.CreateAsync(u);
            await users.AddToRoleAsync(u, role);
        }

        var issuer = scope.ServiceProvider.GetRequiredService<IPermissionClaimsIssuer>();

        var managerClaims = issuer.ClaimsForRoles(new[] { RolePermissionMatrix.Manager })
            .Select(c => c.Value).ToHashSet();
        Assert.Contains(PermissionNames.CostView, managerClaims);
        Assert.Contains(PermissionNames.ReportFinancial, managerClaims);

        var clerkClaims = issuer.ClaimsForRoles(new[] { RolePermissionMatrix.Clerk })
            .Select(c => c.Value).ToHashSet();
        Assert.DoesNotContain(PermissionNames.CostView, clerkClaims);
        Assert.DoesNotContain(PermissionNames.ReportFinancial, clerkClaims);

        // Default-deny: an unmapped/legacy level yields no permission claims.
        Assert.Empty(issuer.ClaimsForRoles(new[] { "unmapped-role" }));
    }

    [Fact]
    public async Task Seeder_NeverCarriesLegacyPasswords_ButResetFlowActivates()
    {
        var staffCode = "Z" + Guid.NewGuid().ToString("N")[..3];

        // Insert a legacy staff row (read-only table) with plaintext legacy password.
        await using (var ctx = fixture.NewContext())
        {
            var conn = ctx.Database.GetDbConnection();
            await conn.OpenAsync();
            await using var cmd = (Npgsql.NpgsqlCommand)conn.CreateCommand();
            cmd.CommandText = """
                INSERT INTO public.staff (staff_code, staff_full_name, job_title, job_status,
                    job_nature, security_level, password, date_hired, sin, home_city)
                VALUES (@c, 'Test Staff', '01', 'A', '1', 6, 'legacypw', '2000-01-01', '000000001', 0)
                ON CONFLICT (staff_code) DO NOTHING
                """;
            cmd.Parameters.AddWithValue("c", staffCode);
            await cmd.ExecuteNonQueryAsync();
        }

        var provider = BuildProvider();
        using var scope = provider.CreateScope();
        var seeder = ActivatorUtilities.CreateInstance<LegacyUserSeeder>(scope.ServiceProvider);
        var users = scope.ServiceProvider.GetRequiredService<UserManager<XoptiUser>>();

        var report = await seeder.SeedAsync();
        Assert.True(report.Seeded >= 1);

        var seeded = await users.FindByNameAsync(staffCode);
        Assert.NotNull(seeded);
        Assert.True(seeded!.ResetRequired);

        // Legacy password material can never authenticate.
        Assert.False(await users.CheckPasswordAsync(seeded, "legacypw"));
        Assert.False(await users.CheckPasswordAsync(seeded, string.Empty));

        // Admin-issued reset activates the account against the modern hash.
        var token = await users.GeneratePasswordResetTokenAsync(seeded);
        var reset = await seeder.CompleteResetAsync(seeded, token, "New#Strong1Pass");
        Assert.True(reset.Succeeded);

        var activated = await users.FindByNameAsync(staffCode);
        Assert.False(activated!.ResetRequired);
        Assert.True(await users.CheckPasswordAsync(activated, "New#Strong1Pass"));
        Assert.False(await users.CheckPasswordAsync(activated, "legacypw"));

        // The legacy value is nowhere in the Identity store.
        await using var verify = fixture.NewContext();
        var stored = await verify.Set<XoptiUser>().SingleAsync(u => u.UserName == staffCode);
        Assert.DoesNotContain("legacypw", stored.PasswordHash ?? string.Empty);

        // Seeding again skips existing accounts (idempotent).
        var second = await seeder.SeedAsync();
        Assert.True(second.Skipped >= 1);
    }
}
