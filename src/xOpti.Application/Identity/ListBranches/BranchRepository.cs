using xOpti.Application.Common;
using xOpti.Domain.Entities;

namespace xOpti.Application.Identity.ListBranches;

/// <summary>Read model for a branch row in a listing.</summary>
public sealed record BranchDto(string BranchCode, string Name, string? City);

/// <summary>
/// Aggregate-oriented port for branches. Returns domain types,
/// keyset-ordered by BranchCode; Infrastructure returns at most
/// <paramref name="limit"/> rows after the cursor.
/// Updates run inside the caller's unit of work; a lost concurrency race
/// surfaces as the persistence layer's concurrency failure.
/// </summary>
public interface IBranchRepository
{
    Task<IReadOnlyList<Branch>> GetPageAfterAsync(
        string? afterBranchCode,
        int limit,
        CancellationToken cancellationToken);

    Task<Branch?> FindByCodeAsync(string branchCode, CancellationToken cancellationToken);

    /// <summary>
    /// Renames a branch. When <paramref name="expectedCurrentName"/> is given,
    /// the caller asserts the value it loaded; a mismatch must surface as the
    /// persistence layer's concurrency failure, never a silent overwrite.
    /// </summary>
    Task<Branch> RenameAsync(
        Branch branch,
        string newName,
        string? expectedCurrentName,
        CancellationToken cancellationToken);
}
