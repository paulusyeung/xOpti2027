using xOpti.Infrastructure.Tests.Support;

namespace xOpti.Infrastructure.Tests;

[Collection("postgres")]
public class ContainerSmokeTests(PostgresFixture fixture)
{
    [Fact]
    public async Task SeededSchemaExposesMigratedLegacyTables()
    {
        await using var conn = new Npgsql.NpgsqlConnection(fixture.ConnectionString);
        await conn.OpenAsync();

        await using var cmd = conn.CreateCommand();
        cmd.CommandText = """
            SELECT count(*) FROM information_schema.tables
            WHERE table_schema = 'public' AND table_type = 'BASE TABLE'
            """;

        var count = Convert.ToInt64(await cmd.ExecuteScalarAsync());
        Assert.True(count >= 70, $"expected >=70 legacy tables, found {count}");
    }
}

[CollectionDefinition("postgres")]
public class PostgresCollection : ICollectionFixture<PostgresFixture>
{
}
