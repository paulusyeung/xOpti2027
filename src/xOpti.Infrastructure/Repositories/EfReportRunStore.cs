using xOpti.Application.Reporting;
using xOpti.Infrastructure.Persistence;
using xOpti.Infrastructure.Persistence.Entities;

namespace xOpti.Infrastructure.Repositories;

public sealed class EfReportRunStore(XOptiDbContext context) : IReportRunStore
{
    public async Task RecordAsync(string catalogueId, string? actor, string? branch,
        IReadOnlyDictionary<string, string?> parameters, bool duplicate, int rowCount,
        bool truncated, CancellationToken ct)
    {
        context.ReportRuns.Add(new ReportRun
        {
            CatalogueId = catalogueId,
            Actor = actor,
            Branch = branch,
            ParametersJson = System.Text.Json.JsonSerializer.Serialize(parameters),
            GeneratedAt = DateTimeOffset.UtcNow,
            Duplicate = duplicate,
            RowCount = rowCount,
            Truncated = truncated,
        });
        await context.SaveChangesAsync(ct);
    }
}
