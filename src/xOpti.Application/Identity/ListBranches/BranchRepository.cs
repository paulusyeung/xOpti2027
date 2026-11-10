using xOpti.Application.Common;
using xOpti.Domain.Entities;

namespace xOpti.Application.Identity.ListBranches;

/// <summary>Read model for a branch row in a listing.</summary>
public sealed record BranchDto(string BranchCode, string Name, string? City);

/// <summary>
/// Aggregate-oriented read port for branches. Returns domain types,
/// keyset-ordered by BranchCode; Infrastructure returns at most
/// <paramref name="limit"/> rows after the cursor.
/// </summary>
public interface IBranchRepository
{
    Task<IReadOnlyList<Branch>> GetPageAfterAsync(
        string? afterBranchCode,
        int limit,
        CancellationToken cancellationToken);
}
