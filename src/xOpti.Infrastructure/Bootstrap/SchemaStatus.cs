using Microsoft.Extensions.DependencyInjection;
using Npgsql;
using xOpti.Infrastructure.Persistence;
using xOpti.Infrastructure.Persistence.Entities;

namespace xOpti.Infrastructure.Bootstrap;

/// <summary>Readiness of the database schema baseline.</summary>
public sealed record SchemaStatusResult(bool Ready, string Detail);

/// <summary>
/// Compares the database's recorded schema baseline with the approved rebuild
/// script. Used by the readiness probe and the request gate, so both agree.
/// </summary>
public static class SchemaStatus
{
    public static async Task<SchemaStatusResult> CheckAsync(
        string? connectionString,
        string? schemaFilePath,
        CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(connectionString))
        {
            return new SchemaStatusResult(false, "ConnectionStrings:XOptiDatabase is not configured.");
        }

        if (string.IsNullOrWhiteSpace(schemaFilePath) || !File.Exists(schemaFilePath))
        {
            return new SchemaStatusResult(
                false,
                "The schema baseline file is missing; set XOptiApi:SchemaFile to the deployed xopti-schema.sql.");
        }

        string expectedChecksum;
        try
        {
            expectedChecksum = SchemaScript.ComputeChecksum(schemaFilePath);
        }
        catch (IOException exception)
        {
            return new SchemaStatusResult(false, $"Schema baseline file unreadable: {exception.Message}");
        }

        try
        {
            await using var connection = new NpgsqlConnection(Persistence.ConnectionStrings.ToNpgsql(connectionString));
            await connection.OpenAsync(cancellationToken);

            await using (var command = connection.CreateCommand())
            {
                command.CommandText = "SELECT to_regclass('platform.schema_baseline') IS NOT NULL";
                command.CommandTimeout = 3;
                if (await command.ExecuteScalarAsync(cancellationToken) is not true)
                {
                    return new SchemaStatusResult(
                        false,
                        "platform.schema_baseline is missing; run the bootstrap command against this database.");
                }
            }

            await using var read = connection.CreateCommand();
            read.CommandText = "SELECT version, checksum FROM platform.schema_baseline WHERE id = 1";
            read.CommandTimeout = 3;
            await using var reader = await read.ExecuteReaderAsync(cancellationToken);
            if (!await reader.ReadAsync(cancellationToken))
            {
                return new SchemaStatusResult(false, "platform.schema_baseline has no row.");
            }

            var version = reader.GetString(0);
            var actualChecksum = reader.GetString(1);
            if (!string.Equals(actualChecksum, expectedChecksum, StringComparison.OrdinalIgnoreCase))
            {
                return new SchemaStatusResult(
                    false,
                    $"Schema baseline {version} does not match the deployed script "
                    + $"(expected {Short(expectedChecksum)}, found {Short(actualChecksum)}); "
                    + "run the approved upgrade or restore the matching script.");
            }

            return new SchemaStatusResult(true, $"Schema baseline {version} matches.");
        }
        catch (Exception exception) when (exception is NpgsqlException or InvalidOperationException or TimeoutException)
        {
            return new SchemaStatusResult(false, "Schema baseline probe failed: " + exception.Message);
        }
    }

    private static string Short(string checksum) =>
        checksum.Length <= 12 ? checksum : checksum[..12];
}
