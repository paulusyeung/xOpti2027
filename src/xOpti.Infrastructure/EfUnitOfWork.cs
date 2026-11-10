using Microsoft.EntityFrameworkCore;
using xOpti.Application.Ports;
using xOpti.Infrastructure.Persistence;

namespace xOpti.Infrastructure;

/// <summary>
/// DbContext-backed unit of work. Honors an already-open ambient transaction
/// (no nested re-open): an outer command scope commits once.
/// </summary>
public sealed class EfUnitOfWork(XOptiDbContext context) : IUnitOfWork
{
    public async Task<T> ExecuteInTransactionAsync<T>(Func<CancellationToken, Task<T>> work, CancellationToken cancellationToken)
    {
        if (context.Database.CurrentTransaction is not null)
        {
            return await work(cancellationToken);
        }

        await using var transaction = await context.Database.BeginTransactionAsync(cancellationToken);
        try
        {
            var result = await work(cancellationToken);
            await context.SaveChangesAsync(cancellationToken);
            await transaction.CommitAsync(cancellationToken);
            return result;
        }
        catch
        {
            await transaction.RollbackAsync(cancellationToken);
            throw;
        }
    }
}

public sealed class SystemClock : IClock
{
    public DateTimeOffset UtcNow => DateTimeOffset.UtcNow;
}
