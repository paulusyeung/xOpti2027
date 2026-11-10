using xOpti.Application.Common;
using xOpti.Domain.Entities;

namespace xOpti.Application.Identity.ListBranches;

/// <summary>
/// Fetches limit+1 rows to detect a next page; the extra row is not returned.
/// Stable key ordering by BranchCode comes from the repository port.
/// </summary>
public sealed class ListBranchesQueryHandler(IBranchRepository branches)
    : IRequestHandler<ListBranchesQuery, PagedResult<BranchDto>>
{
    public async Task<PagedResult<BranchDto>> Handle(
        ListBranchesQuery request,
        CancellationToken cancellationToken)
    {
        var rows = await branches.GetPageAfterAsync(
            request.AfterBranchCode,
            request.PageSize + 1,
            cancellationToken);

        var hasMore = rows.Count > request.PageSize;
        var page = hasMore ? rows.Take(request.PageSize).ToList() : rows.ToList();

        var nextCursor = hasMore
            ? KeysetCursor.Encode(page[^1].BranchCode)
            : (string?)null;

        var items = page.Select(Map).ToList();
        return new PagedResult<BranchDto>(items, nextCursor);
    }

    private static BranchDto Map(Branch branch) =>
        new(branch.BranchCode, branch.Name, branch.City);
}
