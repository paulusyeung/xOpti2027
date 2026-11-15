using Microsoft.EntityFrameworkCore;
using xOpti.Application.Inventory.Summaries;
using xOpti.Infrastructure.Persistence;

namespace xOpti.Infrastructure.Repositories;

public sealed class EfSummaryStore(XOptiDbContext context) : ISummaryStore
{
    public async Task<InventorySummariesDto> BuildAsync(DateOnly from, DateOnly to, CancellationToken ct)
    {
        var start = new DateTimeOffset(from.ToDateTime(TimeOnly.MinValue), TimeSpan.Zero);
        var end = new DateTimeOffset(to.ToDateTime(TimeOnly.MaxValue), TimeSpan.Zero);

        var lines = await (from detail in context.TxDetails.AsNoTracking()
                           join inventory in context.InventoryItems.AsNoTracking()
                               on detail.Sku equals inventory.Sku
                           where detail.DateOfEntry >= start && detail.DateOfEntry <= end
                           select new
                           {
                               detail.Sku, detail.Qty, detail.Amount,
                               inventory.DepartmentCode, inventory.ClassCode, inventory.CategoryCode,
                           }).ToListAsync(ct);

        IReadOnlyList<SummaryRowDto> Group(Func<dynamic, string> key) => lines
            .GroupBy(line => key(line))
            .Select(group => new SummaryRowDto(group.Key, group.Sum(line => line.Qty),
                group.Sum(line => line.Amount.Amount), group.Count()))
            .OrderBy(row => row.Key, StringComparer.Ordinal)
            .ToList();

        return new InventorySummariesDto(from, to, new[]
        {
            new SummaryGroupDto("Inventory", Group(line => line.Sku)),
            new SummaryGroupDto("Category", Group(line => $"{line.DepartmentCode}/{line.ClassCode}/{line.CategoryCode}")),
            new SummaryGroupDto("Class", Group(line => $"{line.DepartmentCode}/{line.ClassCode}")),
            new SummaryGroupDto("Department", Group(line => line.DepartmentCode)),
        });
    }
}
