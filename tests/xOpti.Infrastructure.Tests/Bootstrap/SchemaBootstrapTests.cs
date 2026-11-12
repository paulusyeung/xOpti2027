using Microsoft.Extensions.DependencyInjection;
using xOpti.Infrastructure;
using xOpti.Infrastructure.Bootstrap;
using xOpti.Infrastructure.Identity;
using xOpti.Infrastructure.Tests.Support;

namespace xOpti.Infrastructure.Tests.Bootstrap;

[Collection("postgres")]
public class SchemaBootstrapTests(PostgresFixture fixture)
{
    private static ServiceProvider BuildServices(string connectionString) =>
        new ServiceCollection()
            .AddXOptiInfrastructure(new InfrastructureOptions { ConnectionString = connectionString })
            .AddXOptiIdentity()
            .BuildServiceProvider();

    private static SchemaBootstrapOptions Options(
        string connectionString,
        string? checksum = null,
        string version = SchemaScript.BaselineVersion) =>
        new()
        {
            ConnectionString = connectionString,
            SchemaFilePath = PostgresFixture.SchemaFilePath(),
            Version = version,
            ExpectedChecksum = checksum ?? SchemaScript.ComputeChecksum(PostgresFixture.SchemaFilePath()),
        };

    [Fact]
    public async Task Bootstrap_SucceedsTwice_AndRecordsTheBaseline()
    {
        var connectionString = await fixture.CreateEmptyDatabaseAsync();
        await using var services = BuildServices(connectionString);

        var first = await SchemaBootstrap.RunAsync(services, Options(connectionString));
        Assert.Equal(SchemaBootstrapOutcome.Bootstrapped, first.Outcome);

        var second = await SchemaBootstrap.RunAsync(services, Options(connectionString));
        Assert.Equal(SchemaBootstrapOutcome.AlreadyCurrent, second.Outcome);

        await using var connection = new Npgsql.NpgsqlConnection(connectionString);
        await connection.OpenAsync();

        Assert.Equal(1L, await ScalarAsync(connection, "SELECT count(*) FROM platform.schema_baseline"));
        Assert.Equal(
            SchemaScript.BaselineVersion,
            (string?)await ScalarAsync(connection, "SELECT version FROM platform.schema_baseline WHERE id = 1"));
        Assert.Equal(
            Options(connectionString).ExpectedChecksum,
            (string?)await ScalarAsync(connection, "SELECT checksum FROM platform.schema_baseline WHERE id = 1"));

        // Reference seed data is present and exactly the documented set.
        Assert.Equal(7L, await ScalarAsync(connection, "SELECT count(*) FROM public.pref_tx_number"));
        Assert.Equal(5L, await ScalarAsync(connection, "SELECT count(*) FROM public.asp_net_roles"));
        Assert.Equal(1L, await ScalarAsync(
            connection,
            "SELECT count(*) FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace "
            + "WHERE n.nspname = 'public' AND c.relname = 'tx_header' AND c.relkind = 'r'"));
    }

    [Fact]
    public async Task Bootstrap_WithIncompatibleBaseline_FailsAndChangesNothing()
    {
        var connectionString = await fixture.CreateEmptyDatabaseAsync();
        await using var services = BuildServices(connectionString);
        await SchemaBootstrap.RunAsync(services, Options(connectionString));

        var exception = await Assert.ThrowsAsync<SchemaBaselineMismatchException>(
            () => SchemaBootstrap.RunAsync(
                services,
                Options(connectionString, checksum: "0000000000000000000000000000000000000000000000000000000000000000")));

        Assert.Contains("No changes were made", exception.Message);

        await using var connection = new Npgsql.NpgsqlConnection(connectionString);
        await connection.OpenAsync();
        Assert.Equal(
            Options(connectionString).ExpectedChecksum,
            (string?)await ScalarAsync(connection, "SELECT checksum FROM platform.schema_baseline WHERE id = 1"));
        Assert.Equal(7L, await ScalarAsync(connection, "SELECT count(*) FROM public.pref_tx_number"));
        Assert.Equal(5L, await ScalarAsync(connection, "SELECT count(*) FROM public.asp_net_roles"));
    }

    [Fact]
    public async Task Bootstrap_RefusesToOverwriteAnUnrecordedSchema()
    {
        var connectionString = await fixture.CreateEmptyDatabaseAsync();
        await using var services = BuildServices(connectionString);

        // Simulate a database restored from a legacy migration run: schema
        // present, no baseline row.
        await using (var connection = new Npgsql.NpgsqlConnection(connectionString))
        {
            await connection.OpenAsync();
            await using var command = connection.CreateCommand();
            command.CommandText = SchemaScript.ReadExecutable(PostgresFixture.SchemaFilePath());
            command.CommandTimeout = 0;
            await command.ExecuteNonQueryAsync();
        }

        var exception = await Assert.ThrowsAsync<SchemaBootstrapException>(
            () => SchemaBootstrap.RunAsync(services, Options(connectionString)));
        Assert.Contains("Refusing to bootstrap over existing data", exception.Message);

        await using var verify = new Npgsql.NpgsqlConnection(connectionString);
        await verify.OpenAsync();
        Assert.Equal(0L, await ScalarAsync(
            verify, "SELECT count(*) FROM pg_class WHERE relname = 'schema_baseline'"));
    }

    [Fact]
    public async Task SchemaStatus_ReportsMissingThenMatchingThenOutdated()
    {
        var connectionString = await fixture.CreateEmptyDatabaseAsync();
        var schemaPath = PostgresFixture.SchemaFilePath();

        var missing = await SchemaStatus.CheckAsync(connectionString, schemaPath);
        Assert.False(missing.Ready);
        Assert.Contains("platform.schema_baseline is missing", missing.Detail);

        await using var services = BuildServices(connectionString);
        await SchemaBootstrap.RunAsync(services, Options(connectionString));

        var current = await SchemaStatus.CheckAsync(connectionString, schemaPath);
        Assert.True(current.Ready);

        var tampered = Path.Combine(Path.GetTempPath(), $"xopti-schema-{Guid.NewGuid():N}.sql");
        await File.WriteAllTextAsync(tampered, await File.ReadAllTextAsync(schemaPath) + "\n-- drift probe\n");
        try
        {
            var outdated = await SchemaStatus.CheckAsync(connectionString, tampered);
            Assert.False(outdated.Ready);
            Assert.Contains("does not match the deployed script", outdated.Detail);
        }
        finally
        {
            File.Delete(tampered);
        }
    }

    private static async Task<object?> ScalarAsync(Npgsql.NpgsqlConnection connection, string sql)
    {
        await using var command = connection.CreateCommand();
        command.CommandText = sql;
        return await command.ExecuteScalarAsync();
    }
}
