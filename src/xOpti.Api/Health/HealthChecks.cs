using Microsoft.Extensions.Diagnostics.HealthChecks;
using Npgsql;
using xOpti.Api;
using xOpti.Infrastructure;

namespace xOpti.Api.Health;

/// <summary>Connects and issues SELECT 1 against the configured database.</summary>
public sealed class XOptiDbHealthCheck(IConfiguration configuration, ApiOptions? options = null) : IHealthCheck
{
    public async Task<HealthCheckResult> CheckHealthAsync(
        HealthCheckContext context,
        CancellationToken cancellationToken = default)
    {
        var connectionString = configuration.GetConnectionString("XOptiDatabase");
        if (string.IsNullOrWhiteSpace(connectionString))
        {
            return HealthCheckResult.Unhealthy("ConnectionStrings:XOptiDatabase is not configured.");
        }

        try
        {
            await using var connection = new NpgsqlConnection(
                Infrastructure.Persistence.ConnectionStrings.ToNpgsql(connectionString));
            await connection.OpenAsync(cancellationToken);
            await using var command = connection.CreateCommand();
            command.CommandText = "SELECT 1";
            command.CommandTimeout = 3;
            await command.ExecuteScalarAsync(cancellationToken);
            return HealthCheckResult.Healthy("Database reachable.");
        }
        catch (Exception exception) when (exception is PostgresException or NpgsqlException or InvalidOperationException or TimeoutException)
        {
            return HealthCheckResult.Unhealthy("Database probe failed.", exception);
        }
    }
}

/// <summary>Proves the file volume is mounted and writable.</summary>
public sealed class FileVolumeHealthCheck(IConfiguration configuration) : IHealthCheck
{
    public Task<HealthCheckResult> CheckHealthAsync(
        HealthCheckContext context,
        CancellationToken cancellationToken = default)
    {
        var root = configuration.GetValue<string>("XOptiApi:FileStorageRoot") ?? "/var/lib/xopti/files";

        try
        {
            Directory.CreateDirectory(root);
            var probe = Path.Combine(root, ".health-probe");
            File.WriteAllText(probe, DateTimeOffset.UtcNow.ToString("O"));
            File.Delete(probe);
            return Task.FromResult(HealthCheckResult.Healthy($"File volume writable at {root}."));
        }
        catch (Exception exception)
        {
            return Task.FromResult(HealthCheckResult.Unhealthy($"File volume not writable at {root}.", exception));
        }
    }
}
