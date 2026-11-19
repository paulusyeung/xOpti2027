using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using xOpti.Infrastructure.Persistence;

namespace xOpti.Infrastructure.Jobs;

public sealed class ReportReadModelRefresher(
    XOptiDbContext context, ILogger<ReportReadModelRefresher> logger)
    : xOpti.Application.Reporting.IReportReadModelRefresher
{
    public static readonly string[] Models =
    {
        "sales_by_cost", "sales_by_lsp", "orders_in_progress", "category_summary",
    };

    public Task RefreshAsync(CancellationToken ct) => RefreshOnceAsync(ct);

    public async Task RefreshOnceAsync(CancellationToken ct)
    {
        var started = DateTimeOffset.UtcNow;
        foreach (var model in Models)
        {
            var state = await context.ReadModelStates
                .SingleOrDefaultAsync(row => row.ModelKey == model, ct);
            if (state is null)
            {
                state = new Persistence.Entities.ReadModelState { ModelKey = model };
                context.ReadModelStates.Add(state);
            }
            state.RefreshStartedAt = started;
            await context.SaveChangesAsync(ct);
            try
            {
                await context.Database.ExecuteSqlRawAsync(
                    $"REFRESH MATERIALIZED VIEW reporting.mv_olap_{model}", ct);
                state.AsOf = DateTimeOffset.UtcNow;
                state.RefreshCompletedAt = state.AsOf;
                state.LastError = null;
            }
            catch (Exception ex)
            {
                state.LastError = ex.Message.Length > 1000
                    ? ex.Message[..1000] : ex.Message;
                logger.LogError(ex, "Reporting read-model refresh failed for {Model}", model);
            }
            await context.SaveChangesAsync(ct);
        }
    }
}

public sealed class ReportingRefreshJob(
    IServiceScopeFactory scopeFactory,
    ILogger<ReportingRefreshJob> logger) : BackgroundService
{
    public static TimeSpan Interval => TimeSpan.FromHours(1);

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        using (var scope = scopeFactory.CreateScope())
        {
            var refresher = scope.ServiceProvider.GetRequiredService<ReportReadModelRefresher>();
            await refresher.RefreshOnceAsync(stoppingToken);
        }
        using var timer = new PeriodicTimer(Interval);
        try
        {
            while (await timer.WaitForNextTickAsync(stoppingToken))
            {
                using var scope = scopeFactory.CreateScope();
                var refresher = scope.ServiceProvider.GetRequiredService<ReportReadModelRefresher>();
                await refresher.RefreshOnceAsync(stoppingToken);
            }
        }
        catch (OperationCanceledException)
        {
            logger.LogInformation("Reporting refresh job stopped");
        }
    }
}
