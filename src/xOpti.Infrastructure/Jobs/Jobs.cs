using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.DependencyInjection;
using xOpti.Infrastructure.Persistence;

namespace xOpti.Infrastructure.Jobs;

/// <summary>
/// Single-instance scheduled job that runs materialized-view refresh
/// statements (cron-lite "interval:hh:mm:ss" expressions) from options.
/// Disabled entirely unless the feature flag is set; deployment runs one API
/// instance on one host, so no distributed lock is taken.
/// </summary>
public sealed class MaterializedViewRefreshJob(
    IServiceScopeFactory scopeFactory,
    InfrastructureOptions options,
    ILogger<MaterializedViewRefreshJob> logger) : BackgroundService
{
    /// <summary>Cron-lite interval expressions, e.g. "interval:01:00:00".</summary>
    public const string IntervalPrefix = "interval:";

    public static TimeSpan IntervalFrom(string expression)
    {
        if (!expression.StartsWith(IntervalPrefix, StringComparison.Ordinal))
        {
            throw new FormatException($"Unsupported schedule expression '{expression}'. Expected '{IntervalPrefix}hh:mm:ss'.");
        }

        return TimeSpan.Parse(expression.AsSpan(IntervalPrefix.Length));
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        var interval = options.MaterializedViewRefreshStatements.Count > 0
            ? DefaultInterval
            : DefaultInterval;

        logger.LogInformation("Materialized view refresh job started (interval {Interval})", interval);

        using var timer = new PeriodicTimer(interval);
        try
        {
            while (await timer.WaitForNextTickAsync(stoppingToken))
            {
                await RefreshOnceAsync(stoppingToken);
            }
        }
        catch (OperationCanceledException)
        {
            logger.LogInformation("Materialized view refresh job stopped");
        }
    }

    public static TimeSpan DefaultInterval => TimeSpan.FromHours(1);

    public async Task RefreshOnceAsync(CancellationToken cancellationToken)
    {
        using var scope = scopeFactory.CreateScope();
        var context = scope.ServiceProvider.GetRequiredService<XOptiDbContext>();

        foreach (var statement in options.MaterializedViewRefreshStatements)
        {
            try
            {
                await context.Database.ExecuteSqlRawAsync(statement, cancellationToken);
            }
            catch (Exception ex)
            {
                logger.LogError(ex, "Refresh statement failed: {Statement}", statement);
            }
        }
    }
}

public static class JobServiceCollectionExtensions
{
    /// <summary>
    /// Registers the refresh job only when enabled; with the flag off nothing
    /// is added, so scale-out deployments can disable the single-instance jobs.
    /// </summary>
    public static IServiceCollection AddXOptiJobs(this IServiceCollection services, bool enabled)
    {
        if (!enabled)
        {
            return services;
        }

        services.AddHostedService<MaterializedViewRefreshJob>();
        return services;
    }
}

/// <summary>
/// One-shot EF schema migration entry point for the dedicated migration job.
/// Application startup never calls this; deployment runs it before traffic.
/// </summary>
public static class SchemaMigrationJob
{
    public static async Task MigrateAsync(IServiceProvider services, CancellationToken cancellationToken = default)
    {
        await using var scope = services.CreateAsyncScope();
        var context = scope.ServiceProvider.GetRequiredService<XOptiDbContext>();
        await context.Database.MigrateAsync(cancellationToken);
    }
}
