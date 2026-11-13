using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.DependencyInjection;
using xOpti.Application.Identity.Staff;
using xOpti.Infrastructure;
using xOpti.Infrastructure.Identity;
using xOpti.Infrastructure.Tests.Support;

namespace xOpti.Infrastructure.Tests;

[Collection("postgres")]
public class StaffAccountStoreTests(PostgresFixture fixture)
{
    private ServiceProvider BuildProvider()
    {
        var services = new ServiceCollection();
        services.AddXOptiInfrastructure(new InfrastructureOptions { ConnectionString = fixture.ConnectionString });
        services.AddXOptiIdentity();
        return services.BuildServiceProvider();
    }

    private static async Task EnsureRolesAsync(IServiceProvider provider)
    {
        var roles = provider.GetRequiredService<RoleManager<XoptiRole>>();
        foreach (var role in RolePermissionMatrix.KnownRoles)
        {
            if (!await roles.RoleExistsAsync(role))
            {
                await roles.CreateAsync(new XoptiRole { Name = role });
            }
        }
    }

    [Fact]
    public async Task CreateIssuesResetToken_AndResetActivatesTheAccount()
    {
        await using var provider = BuildProvider();
        await EnsureRolesAsync(provider);
        using var scope = provider.CreateScope();
        var store = scope.ServiceProvider.GetRequiredService<IStaffAccountStore>();
        var users = scope.ServiceProvider.GetRequiredService<UserManager<XoptiUser>>();

        var userName = "admin-" + Guid.NewGuid().ToString("N")[..6];
        var (account, token) = await store.CreateAsync(
            new NewStaffAccount(userName, "Store Test", "optician", "01"), CancellationToken.None);

        Assert.True(account.ResetRequired);
        Assert.Equal(new[] { "optician" }, account.Roles);
        Assert.Equal("01", account.BranchCode);

        var user = await users.FindByIdAsync(account.Id);
        Assert.NotNull(user);
        var reset = await users.ResetPasswordAsync(user!, token, "New#Strong1Pass");
        Assert.True(reset.Succeeded);
        user!.ResetRequired = false;
        await users.UpdateAsync(user);
        Assert.True(await users.CheckPasswordAsync(user, "New#Strong1Pass"));
    }

    [Fact]
    public async Task DisableRoleAndBranchChanges_BumpTheSecurityStamp()
    {
        await using var provider = BuildProvider();
        await EnsureRolesAsync(provider);
        using var scope = provider.CreateScope();
        var store = scope.ServiceProvider.GetRequiredService<IStaffAccountStore>();
        var users = scope.ServiceProvider.GetRequiredService<UserManager<XoptiUser>>();

        var userName = "stamp-" + Guid.NewGuid().ToString("N")[..6];
        var (account, _) = await store.CreateAsync(
            new NewStaffAccount(userName, "Stamp Test", "clerk", null), CancellationToken.None);

        string? Stamp() => users.FindByIdAsync(account.Id).GetAwaiter().GetResult()!.SecurityStamp;

        var before = Stamp();
        var disabled = await store.SetDisabledAsync(account, true, CancellationToken.None);
        Assert.True(disabled.Disabled);
        var afterDisable = Stamp();
        Assert.NotEqual(before, afterDisable);

        var roleChanged = await store.SetRoleAsync(disabled, "manager", CancellationToken.None);
        Assert.Equal(new[] { "manager" }, roleChanged.Roles);
        Assert.NotEqual(afterDisable, Stamp());

        var scoped = await store.SetBranchAsync(roleChanged, "02", CancellationToken.None);
        Assert.Equal("02", scoped.BranchCode);

        var (reset, token) = await store.ForceResetAsync(scoped, CancellationToken.None);
        Assert.True(reset.ResetRequired);
        Assert.False(string.IsNullOrWhiteSpace(token));
    }
}
