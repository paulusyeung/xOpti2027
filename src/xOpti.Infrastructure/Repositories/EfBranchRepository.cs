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

    public async Task<Domain.Entities.Branch?> FindByCodeAsync(string branchCode, CancellationToken cancellationToken)
    {
        var row = await context.Branches.FirstOrDefaultAsync(b => b.BranchCode == branchCode, cancellationToken);
        return row is null ? null : new Domain.Entities.Branch(row.BranchCode, row.BranchName, row.City);
    }

    /// <summary>
    /// Updates the tracked row; the xmin concurrency token makes a lost race
    /// throw DbUpdateConcurrencyException for the caller's transaction scope.
    /// </summary>
    public async Task<Domain.Entities.Branch> RenameAsync(
        Domain.Entities.Branch branch,
        string newName,
        string? expectedCurrentName,
        CancellationToken cancellationToken)
    {
        var row = await context.Branches.SingleAsync(b => b.BranchCode == branch.BranchCode, cancellationToken);

        if (expectedCurrentName is not null)
        {
            // Assert the caller's snapshot: the UPDATE compares the original
            // value, so a lost race matches zero rows and EF throws
            // DbUpdateConcurrencyException.
            context.Entry(row).Property(nameof(Persistence.Entities.Branch.BranchName)).OriginalValue = expectedCurrentName;
        }

        row.BranchName = newName;
        await context.SaveChangesAsync(cancellationToken);
        return new Domain.Entities.Branch(row.BranchCode, row.BranchName, row.City);
    }
}
