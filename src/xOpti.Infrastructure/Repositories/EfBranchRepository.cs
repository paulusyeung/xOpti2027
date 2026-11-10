using Microsoft.EntityFrameworkCore;
using xOpti.Application.Identity.ListBranches;
using xOpti.Infrastructure.Persistence;

namespace xOpti.Infrastructure.Repositories;

/// <summary>Keyset-paged branch reads ordered by the stable legacy BranchCode key.</summary>
public sealed class EfBranchRepository(XOptiDbContext context) : IBranchRepository
{
    public async Task<IReadOnlyList<Domain.Entities.Branch>> GetPageAfterAsync(
        string? afterBranchCode,
        int limit,
        CancellationToken cancellationToken)
    {
        IQueryable<Persistence.Entities.Branch> query = context.Branches.AsNoTracking();

        if (afterBranchCode is not null)
        {
            query = query.Where(b => b.BranchCode.CompareTo(afterBranchCode) > 0);
        }

        var rows = await query
            .OrderBy(b => b.BranchCode)
            .Take(limit)
            .ToListAsync(cancellationToken);

        return rows
            .Select(b => new Domain.Entities.Branch(b.BranchCode, b.BranchName, b.City))
            .ToList();
    }
}
