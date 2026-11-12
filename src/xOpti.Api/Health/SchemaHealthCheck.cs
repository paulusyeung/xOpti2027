using Microsoft.Extensions.Diagnostics.HealthChecks;
using xOpti.Infrastructure.Bootstrap;

namespace xOpti.Api.Health;

/// <summary>
/// Caches the schema-baseline verdict briefly so request gating does not hit
/// PostgreSQL on every call, while still noticing a restored or upgraded
/// database within a few seconds.
/// </summary>
public sealed class SchemaReadinessProbe(IConfiguration configuration, IHostEnvironment environment)
{
    private static readonly TimeSpan CacheTtl = TimeSpan.FromSeconds(5);

    private readonly SemaphoreSlim _gate = new(1, 1);
    private DateTimeOffset _checkedAt = DateTimeOffset.MinValue;
    private SchemaStatusResult _last = new(false, "Schema has not been checked yet.");

    public string? SchemaFilePath { get; } = SchemaScript.ResolvePath(
        configuration["XOptiApi:SchemaFile"],
        environment.ContentRootPath);

    public string? ConnectionString { get; } = configuration.GetConnectionString("XOptiDatabase");

    public async Task<SchemaStatusResult> CheckAsync(CancellationToken cancellationToken)
    {
        if (DateTimeOffset.UtcNow - _checkedAt < CacheTtl)
        {
            return _last;
        }

        await _gate.WaitAsync(cancellationToken);
        try
        {
            if (DateTimeOffset.UtcNow - _checkedAt < CacheTtl)
            {
                return _last;
            }

            _last = await SchemaStatus.CheckAsync(ConnectionString, SchemaFilePath, cancellationToken);
            _checkedAt = DateTimeOffset.UtcNow;
            return _last;
        }
        finally
        {
            _gate.Release();
        }
    }
}

/// <summary>Readiness check for the recorded schema baseline (tag: ready).</summary>
public sealed class SchemaBaselineHealthCheck(SchemaReadinessProbe probe) : IHealthCheck
{
    public async Task<HealthCheckResult> CheckHealthAsync(
        HealthCheckContext context,
        CancellationToken cancellationToken = default)
    {
        var status = await probe.CheckAsync(cancellationToken);
        return status.Ready
            ? HealthCheckResult.Healthy(status.Detail)
            : HealthCheckResult.Unhealthy(status.Detail);
    }
}
