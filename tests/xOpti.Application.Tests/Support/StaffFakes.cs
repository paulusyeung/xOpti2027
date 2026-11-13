using xOpti.Application.Identity.Staff;
using xOpti.Application.Ports;

namespace xOpti.Application.Tests.Support;

public sealed class FakeAuditRecorder : IAuditRecorder
{
    public List<AuditRecord> Records { get; } = new();

    public Task RecordAsync(AuditRecord record, CancellationToken cancellationToken)
    {
        Records.Add(record);
        return Task.CompletedTask;
    }
}

public sealed class FakeRoleCatalogue : IRoleCatalogue
{
    public static readonly string[] Roles = { "clerk", "optician", "purchasing", "manager", "admin" };

    public IReadOnlyList<string> KnownRoles => Roles;

    public string Version => "test";

    public bool Signed => false;

    public string? SignedBy => null;

    public string? ApprovedOn => null;

    public IReadOnlyList<(int MinLevel, string Role)> LevelRules => new[] { (1, "clerk") };

    public IReadOnlyList<string> AllPermissions => xOpti.Application.Authorization.PermissionNames.All;

    public IReadOnlyList<string> UnassignedPermissions => new[] { "customer:pii" };

    public IReadOnlyList<string> ParityGaps => Array.Empty<string>();

    public IReadOnlyList<string> PermissionsForRole(string role) =>
        role == "admin" ? xOpti.Application.Authorization.PermissionNames.All : Array.Empty<string>();

    public bool Exists(string role) => Roles.Contains(role);
}

public sealed class FakeStaffAccountStore : IStaffAccountStore
{
    public Dictionary<string, StaffAccount> Accounts { get; } = new(StringComparer.Ordinal);

    public bool BranchExists { get; set; } = true;

    /// <summary>Number of mutations that must invalidate existing sessions.</summary>
    public int SecurityStampChanges { get; private set; }

    public Task<StaffAccount?> FindByIdAsync(string userId, CancellationToken cancellationToken) =>
        Task.FromResult(Accounts.GetValueOrDefault(userId));

    public Task<bool> UserNameExistsAsync(string userName, CancellationToken cancellationToken) =>
        Task.FromResult(Accounts.Values.Any(a => a.UserName == userName));

    public Task<bool> BranchExistsAsync(string branchCode, CancellationToken cancellationToken) =>
        Task.FromResult(BranchExists);

    public Task<IReadOnlyList<StaffAccount>> GetPageAfterAsync(
        string? afterUserName,
        int limit,
        CancellationToken cancellationToken)
    {
        var rows = Accounts.Values
            .Where(a => afterUserName is null || string.Compare(a.UserName, afterUserName, StringComparison.Ordinal) > 0)
            .OrderBy(a => a.UserName, StringComparer.Ordinal)
            .Take(limit)
            .ToList();
        return Task.FromResult<IReadOnlyList<StaffAccount>>(rows);
    }

    public Task<(StaffAccount Account, string ResetToken)> CreateAsync(
        NewStaffAccount account,
        CancellationToken cancellationToken)
    {
        var created = new StaffAccount(
            Guid.NewGuid().ToString("N"),
            account.UserName,
            account.DisplayName,
            LegacyLevel: -1,
            new[] { account.Role },
            account.BranchCode,
            ResetRequired: true,
            Disabled: false,
            Email: "private@example.com",
            PhoneNumber: "604-555-0199");
        Accounts[created.Id] = created;
        return Task.FromResult((created, "reset-token"));
    }

    public Task<StaffAccount> SetDisabledAsync(StaffAccount account, bool disabled, CancellationToken cancellationToken) =>
        Mutate(account, account with { Disabled = disabled, ResetRequired = account.ResetRequired });

    public Task<StaffAccount> SetRoleAsync(StaffAccount account, string role, CancellationToken cancellationToken) =>
        Mutate(account, account with { Roles = new[] { role } });

    public Task<StaffAccount> SetBranchAsync(StaffAccount account, string? branchCode, CancellationToken cancellationToken) =>
        Mutate(account, account with { BranchCode = branchCode });

    public Task<(StaffAccount Account, string ResetToken)> ForceResetAsync(
        StaffAccount account,
        CancellationToken cancellationToken)
    {
        var updated = Mutate(account, account with { ResetRequired = true }).GetAwaiter().GetResult();
        return Task.FromResult((updated, "reset-token"));
    }

    private Task<StaffAccount> Mutate(StaffAccount account, StaffAccount updated)
    {
        SecurityStampChanges++;
        Accounts[updated.Id] = updated;
        return Task.FromResult(updated);
    }
}
