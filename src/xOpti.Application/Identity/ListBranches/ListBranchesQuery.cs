using xOpti.Domain.Entities;

namespace xOpti.Application.Identity.ListBranches;

/// <summary>
/// Reference vertical slice: list branches with keyset pagination.
/// Cursor encodes the last returned BranchCode; pages are ordered by BranchCode.
/// </summary>
public sealed record ListBranchesQuery(string? Cursor, int PageSize)
    : Common.IQuery<Common.PagedResult<BranchDto>>,
      Common.IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => Array.Empty<string>();

    public string? AfterBranchCode => Cursor is null ? null : Common.KeysetCursor.Decode(Cursor);
}
