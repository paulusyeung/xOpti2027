using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Npgsql;
using xOpti.Infrastructure.Identity;
using xOpti.Infrastructure.Persistence;
using xOpti.Infrastructure.Persistence.Entities;

namespace xOpti.Infrastructure.Bootstrap;

public sealed record SchemaBootstrapOptions
{
    public required string ConnectionString { get; init; }

    public required string SchemaFilePath { get; init; }

    /// <summary>Human-readable baseline label recorded next to the checksum.</summary>
    public required string Version { get; init; }

    /// <summary>SHA-256 of the approved script; computed by the caller from the file.</summary>
    public required string ExpectedChecksum { get; init; }

    public string AppliedBy { get; init; } = "xopti-api --bootstrap";
}

public enum SchemaBootstrapOutcome
{
    Bootstrapped,
    AlreadyCurrent,
}

public sealed record SchemaBootstrapResult(
    SchemaBootstrapOutcome Outcome,
    string Version,
    string Checksum);

/// <summary>The database holds a different baseline; nothing was changed.</summary>
public sealed class SchemaBaselineMismatchException(string message) : Exception(message);

/// <summary>The database is in a state the bootstrap refuses to overwrite.</summary>
public sealed class SchemaBootstrapException(string message) : Exception(message);

/// <summary>
/// Fresh-database bootstrap: applies the approved schema rebuild script, then
/// app-owned EF migrations, then reference seed data, and records the baseline.
///
/// The operation is idempotent: a database already carrying the same checksum is
/// left untouched. A different checksum fails before any DDL, so an incompatible
/// baseline can never partially change a database.
/// </summary>
public static class SchemaBootstrap
{
    private const long AdvisoryLockKey = 584_700_320;

    public static async Task<SchemaBootstrapResult> RunAsync(
        IServiceProvider services,
        SchemaBootstrapOptions options,
        CancellationToken cancellationToken = default)
    {
        if (!File.Exists(options.SchemaFilePath))
        {
            throw new SchemaBootstrapException($"Schema script not found: {options.SchemaFilePath}");
        }

        await using var scope = services.CreateAsyncScope();
        var context = scope.ServiceProvider.GetRequiredService<XOptiDbContext>();

        await using var connection = new NpgsqlConnection(ConnectionStrings.ToNpgsql(options.ConnectionString));
        await connection.OpenAsync(cancellationToken);
        await ExecuteAsync(connection, $"SELECT pg_advisory_lock({AdvisoryLockKey})", cancellationToken);

        try
        {
            var existing = await ReadBaselineAsync(connection, cancellationToken);
            if (existing is not null)
            {
                if (!string.Equals(existing.Value.Checksum, options.ExpectedChecksum, StringComparison.OrdinalIgnoreCase))
                {
                    throw new SchemaBaselineMismatchException(
                        $"Database baseline {existing.Value.Version} ({Short(existing.Value.Checksum)}) does not match "
                        + $"the approved script {options.Version} ({Short(options.ExpectedChecksum)}). "
                        + "No changes were made; run the approved upgrade or restore the matching schema script.");
                }

                return new SchemaBootstrapResult(
                    SchemaBootstrapOutcome.AlreadyCurrent, existing.Value.Version, existing.Value.Checksum);
            }

            if (await ObjectExistsAsync(connection, "public.tx_header", cancellationToken))
            {
                throw new SchemaBootstrapException(
                    "The database already contains the xOpti schema but has no platform.schema_baseline row. "
                    + "Refusing to bootstrap over existing data. If this is a partially provisioned database, "
                    + "recreate it empty and bootstrap again; otherwise record the baseline explicitly.");
            }

            await ExecuteAsync(connection, SchemaScript.ReadExecutable(options.SchemaFilePath), cancellationToken);
            await context.Database.MigrateAsync(cancellationToken);
            await ReferenceDataSeeder.ApplyAsync(services, cancellationToken);

            context.SchemaBaselines.Add(new SchemaBaseline
            {
                Id = 1,
                Version = options.Version,
                Checksum = options.ExpectedChecksum,
                AppliedAt = DateTimeOffset.UtcNow,
                AppliedBy = options.AppliedBy,
            });
            await context.SaveChangesAsync(cancellationToken);

            return new SchemaBootstrapResult(
                SchemaBootstrapOutcome.Bootstrapped, options.Version, options.ExpectedChecksum);
        }
        finally
        {
            await ExecuteAsync(connection, $"SELECT pg_advisory_unlock({AdvisoryLockKey})", CancellationToken.None);
        }
    }

    private static async Task<(string Version, string Checksum)?> ReadBaselineAsync(
        NpgsqlConnection connection,
        CancellationToken cancellationToken)
    {
        if (!await ObjectExistsAsync(connection, "platform.schema_baseline", cancellationToken))
        {
            return null;
        }

        await using var command = connection.CreateCommand();
        command.CommandText = "SELECT version, checksum FROM platform.schema_baseline WHERE id = 1";
        await using var reader = await command.ExecuteReaderAsync(cancellationToken);
        if (!await reader.ReadAsync(cancellationToken))
        {
            return null;
        }

        return (reader.GetString(0), reader.GetString(1));
    }

    private static async Task<bool> ObjectExistsAsync(
        NpgsqlConnection connection,
        string qualifiedName,
        CancellationToken cancellationToken)
    {
        await using var command = connection.CreateCommand();
        command.CommandText = "SELECT to_regclass(@name) IS NOT NULL";
        command.Parameters.AddWithValue("name", qualifiedName);
        return await command.ExecuteScalarAsync(cancellationToken) is true;
    }

    private static async Task ExecuteAsync(
        NpgsqlConnection connection,
        string sql,
        CancellationToken cancellationToken)
    {
        await using var command = connection.CreateCommand();
        command.CommandText = sql;
        command.CommandTimeout = 0;
        await command.ExecuteNonQueryAsync(cancellationToken);
    }

    private static string Short(string checksum) =>
        checksum.Length <= 12 ? checksum : checksum[..12];
}

/// <summary>
/// Reference data a fresh database needs before it can serve traffic. Business
/// master data arrives through the legacy migration, so this only seeds the
/// transaction prefixes and identity roles the application itself requires.
/// </summary>
public static class ReferenceDataSeeder
{
    public static readonly IReadOnlyList<(string Prefix, string Description)> TransactionPrefixes =
    [
        ("RC", "Retail Invoice"),
        ("RS", "Restock, Refund"),
        ("SR", "Stock Received"),
        ("RJ", "Stock Rejected"),
        ("SJ", "Stock Adjustment"),
        ("WC", "Wholesales Invoice"),
        ("WR", "Wholesales Return"),
    ];

    public static async Task ApplyAsync(IServiceProvider services, CancellationToken cancellationToken = default)
    {
        await using var scope = services.CreateAsyncScope();
        var context = scope.ServiceProvider.GetRequiredService<XOptiDbContext>();

        var existing = await context.PrefTxNumbers
            .Select(row => row.TxPrefix)
            .ToListAsync(cancellationToken);
        var known = existing.ToHashSet(StringComparer.OrdinalIgnoreCase);

        foreach (var (prefix, description) in TransactionPrefixes)
        {
            if (known.Contains(prefix))
            {
                continue;
            }

            context.PrefTxNumbers.Add(new PrefTxNumber
            {
                TxPrefix = prefix,
                TxNextNumber = 1,
                Description = description,
                Value = "+ve",
            });
        }

        await context.SaveChangesAsync(cancellationToken);

        var roles = scope.ServiceProvider.GetService<RoleManager<XoptiRole>>();
        if (roles is null)
        {
            return;
        }

        foreach (var role in RolePermissionMatrix.KnownRoles)
        {
            if (!await roles.RoleExistsAsync(role))
            {
                var result = await roles.CreateAsync(new XoptiRole { Name = role });
                if (!result.Succeeded)
                {
                    throw new SchemaBootstrapException(
                        $"Could not seed role '{role}': {string.Join("; ", result.Errors.Select(e => e.Description))}");
                }
            }
        }
    }
}
