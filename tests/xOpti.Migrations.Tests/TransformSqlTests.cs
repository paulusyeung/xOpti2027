using xOpti.Migrations;

namespace xOpti.Migrations.Tests;

public class TransformSqlTests
{
    private static TableMap SimpleMap()
    {
        var source = new StagingTable("salutation", [
            new StagingColumn("salutation", "VARCHAR (4)"),
            new StagingColumn("description", "VARCHAR (40)"),
            new StagingColumn("summaryflag", "BOOLEAN"),
        ]);
        var target = new TargetTable
        {
            Name = "salutation",
            Columns = [
                new TargetColumn("salutation", "character varying", 4, false),
                new TargetColumn("description", "character varying", 40, true),
                new TargetColumn("summary_flag", "boolean", null, true),
            ],
            PrimaryKey = ["salutation"],
        };
        return SchemaMapper.Build(source, target);
    }

    [Fact]
    public void UpsertIsIdempotentSql_DeterministicAndConflictOnPk()
    {
        var map = SimpleMap();
        var sql1 = TransformRunner.BuildUpsert(map, "legacy");
        var sql2 = TransformRunner.BuildUpsert(map, "legacy");

        Assert.Equal(sql1, sql2); // same inputs => same statement (deterministic plan)
        Assert.Contains("INSERT INTO public.\"salutation\"", sql1);
        Assert.Contains("FROM \"legacy\".\"salutation\" e", sql1);
        Assert.Contains("ON CONFLICT (\"salutation\") DO UPDATE", sql1);
        Assert.Contains("DISTINCT ON", sql1);          // in-source duplicate collapse
        Assert.Contains("\"description\" = EXCLUDED.\"description\"", sql1);
        Assert.DoesNotContain("SET \"salutation\" = EXCLUDED", sql1); // key never self-updated
    }

    [Fact]
    public void InsertForNoPrimaryKeyTablesHasNoConflictClause()
    {
        var source = new StagingTable("paste errors", [new StagingColumn("field0", "TEXT")]);
        var target = new TargetTable
        {
            Name = "paste_errors",
            Columns = [new TargetColumn("field0", "text", null, true)],
            PrimaryKey = [],
        };
        var map = SchemaMapper.Build(source, target);
        var sql = TransformRunner.BuildInsert(map, "legacy");
        Assert.DoesNotContain("ON CONFLICT", sql);
        Assert.Contains("\"legacy\".\"paste errors\"", sql);
    }

    [Fact]
    public void UpsertFailsFastWhenPrimaryKeyColumnMissingFromStaging()
    {
        var source = new StagingTable("salutation", [new StagingColumn("description", "VARCHAR (40)")]);
        var target = new TargetTable
        {
            Name = "salutation",
            Columns = [
                new TargetColumn("salutation", "character varying", 4, false),
                new TargetColumn("description", "character varying", 40, true),
            ],
            PrimaryKey = ["salutation"],
        };
        var map = SchemaMapper.Build(source, target);
        Assert.Throws<MigrationException>(() => TransformRunner.BuildUpsert(map, "legacy"));
    }

    [Fact]
    public void TransformOrderIsMasterDataFirst()
    {
        var groups = TransformRunner.OrderGroups;
        var txGroupIndex = Array.FindIndex(groups, g => g.Contains("txheader"));
        var customerIndex = Array.FindIndex(groups, g => g.Contains("customer"));
        var inventoryIndex = Array.FindIndex(groups, g => g.Contains("inventory"));
        var summaryIndex = Array.FindIndex(groups, g => g.Contains("invtsummary"));

        Assert.True(customerIndex < inventoryIndex);
        Assert.True(inventoryIndex < txGroupIndex);
        Assert.True(txGroupIndex < summaryIndex);
    }

    [Fact]
    public void BulkIndexThresholdCoversLargeTables() =>
        Assert.True(TransformRunner.BulkIndexDropThreshold <= 100_000);
}

public class ConfigurationTests
{
    [Fact]
    public void UriConnectionStringIsNormalizedWithPercentEncodedPassword()
    {
        var result = Program.ToNpgsqlConnectionString(
            "postgresql://postgres:pg%40secret@localhost:5432/xOpti");
        var builder = new Npgsql.NpgsqlConnectionStringBuilder(result);
        Assert.Equal("localhost", builder.Host);
        Assert.Equal(5432, builder.Port);
        Assert.Equal("xOpti", builder.Database);
        Assert.Equal("postgres", builder.Username);
        Assert.Equal("pg@secret", builder.Password);
    }

    [Fact]
    public void KeyValueConnectionStringPassesThrough()
    {
        var result = Program.ToNpgsqlConnectionString("Host=db;Database=xOpti;Username=sara;Password=pw");
        var builder = new Npgsql.NpgsqlConnectionStringBuilder(result);
        Assert.Equal("db", builder.Host);
        Assert.Equal("xOpti", builder.Database);
    }

    [Fact]
    public void MissingRequiredValuesFailWithClearError()
    {
        var saved = (
            Environment.GetEnvironmentVariable("SYNERGY_MDB"),
            Environment.GetEnvironmentVariable("XOPTI_DATABASE_URL"));
        try
        {
            Environment.SetEnvironmentVariable("SYNERGY_MDB", "");
            Environment.SetEnvironmentVariable("XOPTI_DATABASE_URL", "");
            var ex = Assert.Throws<MigrationException>(
                () => MigrationConfig.Load("/nonexistent/dir/.env", 0.01m));
            Assert.Contains("SYNERGY_MDB", ex.Message);
            Assert.Contains("XOPTI_DATABASE_URL", ex.Message);
        }
        finally
        {
            Environment.SetEnvironmentVariable("SYNERGY_MDB", saved.Item1);
            Environment.SetEnvironmentVariable("XOPTI_DATABASE_URL", saved.Item2);
        }
    }

    [Fact]
    public void UnknownCommandFailsWithHelp()
    {
        var ex = Assert.Throws<MigrationException>(() => CommandLine.Parse(["frobnicate"]));
        Assert.Contains("--help", ex.Message);
    }

    [Theory]
    [InlineData("extract")]
    [InlineData("stage")]
    [InlineData("transform")]
    [InlineData("reconcile")]
    [InlineData("sync")]
    [InlineData("cutover")]
    public void AllCommandsAreAccepted(string command)
    {
        var options = CommandLine.Parse([command]);
        Assert.Equal(command, options.Command);
        Assert.Contains(command.ToLowerInvariant(), CommandLine.Help);
    }
}
