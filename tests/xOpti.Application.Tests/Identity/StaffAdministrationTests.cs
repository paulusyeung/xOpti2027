using Microsoft.Extensions.DependencyInjection;
using xOpti.Application.Authorization;
using xOpti.Application.Common;
using xOpti.Application.Identity.Staff;
using xOpti.Application.Pipeline;
using xOpti.Application.Ports;
using xOpti.Application.Tests.Support;

namespace xOpti.Application.Tests.Identity;

public class StaffAdministrationTests
{
    private static (IRequestDispatcher Dispatcher, FakeStaffAccountStore Store, FakeAuditRecorder Audit) Build(
        FakePrincipal principal,
        FakeStaffAccountStore? store = null,
        FakeAuditRecorder? audit = null)
    {
        store ??= new FakeStaffAccountStore();
        audit ??= new FakeAuditRecorder();

        var services = new ServiceCollection();
        services.AddXOptiApplication();
        services.AddSingleton<ICurrentPrincipal>(principal);
        services.AddSingleton<IUnitOfWork>(new FakeUnitOfWork());
        services.AddSingleton<IIdempotencyStore>(new FakeIdempotencyStore());
        services.AddSingleton<IStaffAccountStore>(store);
        services.AddSingleton<IAuditRecorder>(audit);
        services.AddSingleton<IRoleCatalogue>(new FakeRoleCatalogue());

        return (services.BuildServiceProvider().GetRequiredService<IRequestDispatcher>(), store, audit);
    }

    private static FakePrincipal Admin() => new(PermissionNames.MasterDataMaintain);

    private static StaffAccount Existing(string id = "u1", bool disabled = false, string[]? roles = null) =>
        new(id, "existing", "Existing Staff", 3, roles ?? new[] { "optician" }, "01", false, disabled,
            "private@example.com", "604-555-0199");

    [Fact]
    public async Task MutationWithoutTheStaffPermission_IsDeniedBeforeAnyWork()
    {
        var (dispatcher, store, audit) = Build(new FakePrincipal());

        var error = await Assert.ThrowsAsync<AuthorizationFailedException>(
            () => dispatcher.DispatchAsync(new DisableStaffCommand("u1", "left the company")));

        Assert.Equal(PermissionNames.MasterDataMaintain, error.Permission);
        Assert.Equal(0, store.SecurityStampChanges);
        Assert.Empty(audit.Records);
    }

    [Fact]
    public async Task CreateStaff_IssuesResetToken_AuditsOnce_AndMasksPii()
    {
        var (dispatcher, store, audit) = Build(Admin());

        var result = await dispatcher.DispatchAsync(
            new CreateStaffCommand("new.user", "New User", "clerk", "01", "new hire"));

        Assert.False(string.IsNullOrWhiteSpace(result.ResetToken));
        Assert.True(result.Account.ResetRequired);
        Assert.Equal(new[] { "clerk" }, result.Account.Roles);
        Assert.Null(result.Account.Email); // no staff:pii
        Assert.Null(result.Account.PhoneNumber);

        var record = Assert.Single(audit.Records);
        Assert.Equal("staff.create", record.Action);
        Assert.Equal("StaffAccount", record.EntityType);
        Assert.Equal("new.user", record.EntityId);
        Assert.Contains("new hire", record.Details);
        Assert.DoesNotContain("private@example.com", record.Details);
        Assert.DoesNotContain("604-555-0199", record.Details);
        Assert.Single(store.Accounts);
    }

    [Fact]
    public async Task StaffPiiPermission_RevealsContactFields()
    {
        var (dispatcher, _, _) = Build(new FakePrincipal(
            PermissionNames.MasterDataMaintain, PermissionNames.StaffPii));

        var result = await dispatcher.DispatchAsync(
            new CreateStaffCommand("pii.user", "PII User", "clerk", "01", "new hire"));

        Assert.Equal("private@example.com", result.Account.Email);
        Assert.Equal("604-555-0199", result.Account.PhoneNumber);
    }

    [Fact]
    public async Task DisableAndEnable_InvalidateSessions_AndAuditBeforeAndAfter()
    {
        var store = new FakeStaffAccountStore();
        var existing = Existing();
        store.Accounts[existing.Id] = existing;
        var (dispatcher, _, audit) = Build(Admin(), store);

        var disabled = await dispatcher.DispatchAsync(new DisableStaffCommand(existing.Id, "left the company"));
        Assert.True(disabled.Disabled);
        Assert.Equal(1, store.SecurityStampChanges);

        var enabled = await dispatcher.DispatchAsync(new EnableStaffCommand(existing.Id, "returned"));
        Assert.False(enabled.Disabled);
        Assert.Equal(2, store.SecurityStampChanges);

        Assert.Equal(2, audit.Records.Count);
        Assert.All(audit.Records, record =>
        {
            Assert.Contains("\"reason\"", record.Details);
            Assert.Contains("\"before\"", record.Details);
            Assert.Contains("\"after\"", record.Details);
            Assert.DoesNotContain("private@example.com", record.Details);
        });
    }

    [Fact]
    public async Task ForceReset_SetsResetRequired_IssuesToken_AndInvalidatesSessions()
    {
        var store = new FakeStaffAccountStore();
        var existing = Existing();
        store.Accounts[existing.Id] = existing;
        var (dispatcher, _, audit) = Build(Admin(), store);

        var result = await dispatcher.DispatchAsync(
            new ForceStaffResetCommand(existing.Id, "forgot password"));

        Assert.True(result.Account.ResetRequired);
        Assert.False(string.IsNullOrWhiteSpace(result.ResetToken));
        Assert.Equal(1, store.SecurityStampChanges);
        Assert.Equal("staff.force-reset", Assert.Single(audit.Records).Action);
    }

    [Fact]
    public async Task ChangeRole_ReplacesRoles_AndInvalidatesSessions()
    {
        var store = new FakeStaffAccountStore();
        var existing = Existing(roles: new[] { "optician", "clerk" });
        store.Accounts[existing.Id] = existing;
        var (dispatcher, _, audit) = Build(Admin(), store);

        var result = await dispatcher.DispatchAsync(
            new ChangeStaffRoleCommand(existing.Id, "manager", "promotion"));

        Assert.Equal(new[] { "manager" }, result.Roles);
        Assert.Equal(1, store.SecurityStampChanges);
        var record = Assert.Single(audit.Records);
        Assert.Equal("staff.role-change", record.Action);
        Assert.Contains("optician", record.Details);
        Assert.Contains("manager", record.Details);
    }

    [Fact]
    public async Task SetBranch_ValidatesTheBranch_AndAudits()
    {
        var store = new FakeStaffAccountStore { BranchExists = false };
        var existing = Existing();
        store.Accounts[existing.Id] = existing;
        var (dispatcher, _, audit) = Build(Admin(), store);

        var error = await Assert.ThrowsAsync<DomainRuleException>(
            () => dispatcher.DispatchAsync(new SetStaffBranchCommand(existing.Id, "99", "transfer")));
        Assert.Contains("Branch '99' was not found", error.Message);
        Assert.Empty(audit.Records);

        store.BranchExists = true;
        var updated = await dispatcher.DispatchAsync(new SetStaffBranchCommand(existing.Id, "02", "transfer"));
        Assert.Equal("02", updated.BranchCode);
        Assert.Equal(1, store.SecurityStampChanges);
        Assert.Equal("staff.branch-scope", Assert.Single(audit.Records).Action);
    }

    [Theory]
    [InlineData("")]
    [InlineData("x")]
    public async Task LifecycleReason_IsValidated(string reason)
    {
        var store = new FakeStaffAccountStore();
        var existing = Existing();
        store.Accounts[existing.Id] = existing;
        var (dispatcher, _, audit) = Build(Admin(), store);

        await Assert.ThrowsAsync<ValidationFailedException>(
            () => dispatcher.DispatchAsync(new DisableStaffCommand(existing.Id, reason)));
        Assert.Empty(audit.Records);
        Assert.Equal(0, store.SecurityStampChanges);
    }

    [Fact]
    public async Task UnknownRole_IsAFieldValidationError()
    {
        var (dispatcher, store, _) = Build(Admin());

        var error = await Assert.ThrowsAsync<ValidationFailedException>(
            () => dispatcher.DispatchAsync(
                new CreateStaffCommand("new.user", "New User", "superuser", null, "new hire")));

        Assert.Contains(error.Errors, field => field.Field == "Role");
        Assert.Empty(store.Accounts);
    }

    [Fact]
    public async Task ListStaff_MasksPii_AndEncodesTheNextCursor()
    {
        var store = new FakeStaffAccountStore();
        store.Accounts["a"] = Existing("id-a") with { UserName = "alpha" };
        store.Accounts["b"] = Existing("id-b") with { UserName = "beta" };
        var (dispatcher, _, _) = Build(new FakePrincipal(PermissionNames.MasterDataMaintain), store);

        var page = await dispatcher.DispatchAsync(new ListStaffQuery(null, 1));

        Assert.Single(page.Items);
        Assert.Equal("alpha", page.Items[0].UserName);
        Assert.Null(page.Items[0].Email);
        Assert.NotNull(page.NextCursor);

        var next = await dispatcher.DispatchAsync(new ListStaffQuery(page.NextCursor, 1));
        Assert.Equal("beta", Assert.Single(next.Items).UserName);
    }
}
