using Microsoft.Extensions.DependencyInjection;
using xOpti.Infrastructure;
using xOpti.Infrastructure.Bootstrap;
using xOpti.Infrastructure.Identity;
using xOpti.Infrastructure.Tests.Support;

namespace xOpti.Infrastructure.Tests.Bootstrap;

[Collection("postgres")]
public class SchemaDriftTests(PostgresFixture fixture)
{
    private static async Task<string> BootstrappedDatabaseAsync(PostgresFixture fixture)
    {
        var connectionString = await fixture.CreateEmptyDatabaseAsync();
        await using var services = new ServiceCollection()
            .AddXOptiInfrastructure(new InfrastructureOptions { ConnectionString = connectionString })
            .AddXOptiIdentity()
            .BuildServiceProvider();

        await SchemaBootstrap.RunAsync(services, new SchemaBootstrapOptions
        {
            ConnectionString = connectionString,
            SchemaFilePath = PostgresFixture.SchemaFilePath(),
            Version = SchemaScript.BaselineVersion,
            ExpectedChecksum = SchemaScript.ComputeChecksum(PostgresFixture.SchemaFilePath()),
        });

        return connectionString;
    }

    [Fact]
    public void Parser_FindsEveryTableAndTheKnownColumnCount()
    {
        var expected = SchemaDrift.Parse(PostgresFixture.SchemaFilePath());

        Assert.Equal(73, expected.Count);
        Assert.Equal(28, expected["public.tx_header"].Count);
        Assert.True(expected["public.tx_header"]["control_number"].NotNull);
        Assert.Equal("character varying", expected["public.tx_header"]["control_number"].Type);
        Assert.Equal("timestamp without time zone", expected["public.tx_header"]["date_of_entry"].Type);
        Assert.False(expected["public.tx_header"]["ref_number"].NotNull);
    }

    [Fact]
    public async Task BootstrappedDatabase_HasNoDrift()
    {
        var connectionString = await BootstrappedDatabaseAsync(fixture);

        var differences = await SchemaDrift.CompareAsync(connectionString, PostgresFixture.SchemaFilePath());

        Assert.Empty(differences);
    }

    [Fact]
    public async Task InjectedColumn_IsReported_ByTableAndColumn()
    {
        var connectionString = await BootstrappedDatabaseAsync(fixture);

        await using (var connection = new Npgsql.NpgsqlConnection(connectionString))
        {
            await connection.OpenAsync();
            await using var command = connection.CreateCommand();
            command.CommandText = "ALTER TABLE public.branch ADD COLUMN drift_probe text";
            await command.ExecuteNonQueryAsync();
        }

        var differences = await SchemaDrift.CompareAsync(connectionString, PostgresFixture.SchemaFilePath());

        Assert.Contains(differences, difference =>
            difference.Contains("public.branch.drift_probe", StringComparison.Ordinal)
            && difference.Contains("not in xopti-schema.sql", StringComparison.Ordinal));
    }
}
