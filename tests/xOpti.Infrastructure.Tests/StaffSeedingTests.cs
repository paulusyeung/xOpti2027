using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using xOpti.Application.Ports;
using xOpti.Infrastructure;
using xOpti.Infrastructure.Identity;
using xOpti.Infrastructure.Persistence;
using xOpti.Infrastructure.Tests.Support;

namespace xOpti.Infrastructure.Tests;

[Collection("postgres")]
public class StaffSeedingTests(PostgresFixture fixture)
{
    private ServiceProvider BuildProvider()
    {
        var services = new ServiceCollection();
        services.AddXOptiInfrastructure(new InfrastructureOptions { ConnectionString = fixture.ConnectionString });
        services.AddXOptiIdentity();
        services.AddScoped<ICurrentPrincipal>(_ => new ClaimsCurrentPrincipal(new System.Security.Claims.ClaimsPrincipal()));
        return services.BuildServiceProvider();
    }

    [Fact]
    public async Task EveryLegacyStaffAccount_IsMapped_AndUnmappedLevelsAreDefaultDenied()
    {
        var suffix = Guid.NewGuid().ToString("N")[..2].ToUpperInvariant();
        var levels = new (int Level, string? ExpectedRole)[]
        {
            (2, RolePermissionMatrix.Clerk),
            (3, RolePermissionMatrix.Optician),
            (5, RolePermissionMatrix.Manager),
            (7, RolePermissionMatrix.Admin),
            (0, null), // no rule: default-deny
        };

        await using (var context = fixture.NewContext())
        {
            var connection = context.Database.GetDbConnection();
            await connection.OpenAsync();
            foreach (var (level, _) in levels)
            {
                await using var command = (Npgsql.NpgsqlCommand)connection.CreateCommand();
                command.CommandText = """
                    INSERT INTO public.staff (staff_code, staff_full_name, job_title, job_status,
                        job_nature, security_level, password, date_hired, sin, home_city)
                    VALUES (@code, @name, '01', 'A', '1', @level, 'legacypw', '2000-01-01', '000000001', 0)
                    ON CONFLICT (staff_code) DO NOTHING
                    """;
                command.Parameters.AddWithValue("code", $"L{level}{suffix}"); // staff_code is varchar(4)
                command.Parameters.AddWithValue("name", $"Level {level} staff");
                command.Parameters.AddWithValue("level", level);
                await command.ExecuteNonQueryAsync();
            }
        }

        await using var provider = BuildProvider();
        using var scope = provider.CreateScope();
        var seeder = ActivatorUtilities.CreateInstance<LegacyUserSeeder>(scope.ServiceProvider);
        var users = scope.ServiceProvider.GetRequiredService<UserManager<XoptiUser>>();
        var roles = scope.ServiceProvider.GetRequiredService<RoleManager<XoptiRole>>();

        await seeder.SeedAsync();

        // Every legacy staff row has an Identity account with the mapped role,
        // and unmapped levels carry no business role.
        foreach (var (level, expectedRole) in levels)
        {
            var user = await users.FindByNameAsync($"L{level}{suffix}");
            Assert.NotNull(user);
            Assert.Equal(level, user!.LegacyLevel);
            Assert.True(user.ResetRequired);
            Assert.False(await users.CheckPasswordAsync(user, "legacypw"));

            var assigned = await users.GetRolesAsync(user);
            if (expectedRole is null)
            {
                Assert.Empty(assigned);
            }
            else
            {
                Assert.Equal(new[] { expectedRole }, assigned);
                Assert.True(await roles.RoleExistsAsync(expectedRole));
            }
        }

        var unmapped = await users.FindByNameAsync($"L0{suffix}");
        Assert.Empty(await users.GetRolesAsync(unmapped!));

        // Force-reset activation still works for a mapped account.
        var target = await users.FindByNameAsync($"L3{suffix}");
        var token = await users.GeneratePasswordResetTokenAsync(target!);
        Assert.True((await seeder.CompleteResetAsync(target!, token, "New#Strong1Pass")).Succeeded);
        var activated = await users.FindByNameAsync($"L3{suffix}");
        Assert.False(activated!.ResetRequired);
        Assert.True(await users.CheckPasswordAsync(activated, "New#Strong1Pass"));
        Assert.False(await users.CheckPasswordAsync(activated, "legacypw"));
    }
}
