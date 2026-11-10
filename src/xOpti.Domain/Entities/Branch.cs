namespace xOpti.Domain.Entities;

/// <summary>
/// A store branch. Identity/session and every audited record carry a
/// branch attribution (see MIGRATION_NOTES audit rules).
/// </summary>
public sealed record Branch(string BranchCode, string Name, string? City = null)
{
    public static Common.Result<Branch> Create(string? branchCode, string? name, string? city = null)
    {
        if (string.IsNullOrWhiteSpace(branchCode))
        {
            return Common.Result<Branch>.Failure("Branch code is required.");
        }

        if (string.IsNullOrWhiteSpace(name))
        {
            return Common.Result<Branch>.Failure("Branch name is required.");
        }

        return Common.Result<Branch>.Success(new Branch(branchCode.Trim(), name.Trim(), city?.Trim()));
    }
}
