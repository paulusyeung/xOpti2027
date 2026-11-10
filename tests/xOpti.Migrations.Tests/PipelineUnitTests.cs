using xOpti.Migrations;

namespace xOpti.Migrations.Tests;

public class NameNormalizerTests
{
    [Theory]
    [InlineData("tx_number", "txnumber")]
    [InlineData("TxNumber", "txnumber")]
    [InlineData("bar_code_pool", "barcodepool")]
    [InlineData("Paste Errors", "pasteerrors")]
    [InlineData("Z_DefaultClass", "zdefaultclass")]
    public void CanonicalStripsCaseAndSeparators(string input, string expected) =>
        Assert.Equal(expected, NameNormalizer.Canonical(input));

    [Fact]
    public void KnownRenamesMapLegacyTyposToTargetColumns()
    {
        Assert.Equal("platform", NameNormalizer.KnownColumnRenames[("preference", "paltform")]);
        Assert.Equal("right_base", NameNormalizer.KnownColumnRenames[("txsorderlens", "rigthbase")]);
        Assert.Equal("right_oc", NameNormalizer.KnownColumnRenames[("txsorderlens", "rigthoc")]);
    }

    [Fact]
    public void TableMappingMatchesPascalCaseSourceToSnakeTarget()
    {
        var source = new StagingTable("bar_code_pool", [new StagingColumn("txnumber", "VARCHAR (10)")]);
        var target = new TargetTable
        {
            Name = "bar_code_pool",
            Columns = [new TargetColumn("tx_number", "character varying", 10, true)],
            PrimaryKey = ["id"],
        };
        Assert.NotNull(target);
        Assert.Equal(source.CanonicalName, target.CanonicalName);
    }
}

public class RecordParserTests
{
    private const char Sep = (char)0x1F;
    private static string L(params string[] fields) => string.Join(Sep, fields);

    [Fact]
    public void ParsesSimpleRow()
    {
        var parser = new RecordParser();
        var rows = parser.Append("\"a\"" + Sep + "1" + Sep + "\"b c\"\n").Concat(parser.Complete()).ToList();
        Assert.Single(rows);
        Assert.Equal(["a", "1", "b c"], rows[0].ToArray());
    }

    [Fact]
    public void UnquotedNullMarkerBecomesNull()
    {
        var parser = new RecordParser();
        var row = parser.Append("\"x\"" + Sep + "\\N\n").Single();
        Assert.Equal("x", row[0]);
        Assert.Null(row[1]);
    }

    [Fact]
    public void QuotedFieldMayContainSeparatorNewlinesAndQuotes()
    {
        var parser = new RecordParser();
        var chunk = "\"multi\nline\"" + Sep + "\"say \"\"hi\"\"\"" + Sep + "9\n";
        var row = parser.Append(chunk).Single();
        Assert.Equal("multi\nline", row[0]);
        Assert.Equal("say \"hi\"", row[1]);
        Assert.Equal("9", row[2]);
    }

    [Fact]
    public void EmptyQuotedFieldIsEmptyStringNotnull()
    {
        var parser = new RecordParser();
        var row = parser.Append("\"\"\n").Single();
        Assert.Equal(string.Empty, row[0]);
    }

    [Fact]
    public void SplitsAcrossChunkBoundaries()
    {
        var parser = new RecordParser();
        var full = "\"ab\"" + Sep + "\"cd\"\n" + "\"ef\"" + Sep + "\\N\n";
        var rows = new List<IReadOnlyList<string?>>();
        foreach (var c in full)
            rows.AddRange(parser.Append(c.ToString()));
        rows.AddRange(parser.Complete());
        Assert.Equal(2, rows.Count);
        Assert.Equal(["ab", "cd"], rows[0].ToArray());
        Assert.Equal(["ef", null], rows[1].ToArray());
    }

    [Fact]
    public void BooleanMinusOneIsPassedThroughAsText()
    {
        var parser = new RecordParser();
        var row = parser.Append("-1" + Sep + "0\n").Single();
        Assert.Equal("-1", row[0]);
        Assert.Equal("0", row[1]);
    }
}

public class StreamNormalizerTests
{
    [Fact]
    public void ReplacesInvalidAccessDateWithValidDate() =>
        Assert.Equal("1899-12-30 10:00:00", StreamNormalizer.FixDateDefect("1900-01-00 10:00:00"));

    [Fact]
    public void CountsDateDefectsPerField()
    {
        IReadOnlyList<string?> row = ["ok", "1900-01-00", null, "1900-01-00 12:00:00"];
        Assert.Equal(2, StreamNormalizer.CountDateDefects(row));
    }
}

public class SchemaMapperExpressionTests
{
    private static string Expr(string sourceType, string targetCol, string target) =>
        SchemaMapper.BuildExpression(new StagingColumn(sourceCol(sourceCol(target)), sourceType),
            new TargetColumn(targetCol, target, null, true));

    private static string sourceCol(string target) => target.Replace("_", "");

    [Fact]
    public void BooleanFromAccessFlags()
    {
        var expr = Expr("BOOLEAN", "summary_flag", "boolean");
        Assert.Contains("'-1'", expr);
        Assert.Contains("THEN TRUE", expr);
        Assert.Contains("THEN FALSE", expr);
    }

    [Fact]
    public void RealLineNumbersAreIntegerRounded()
    {
        var expr = Expr("REAL", "row_no", "double precision");
        Assert.StartsWith("ROUND(", expr);
        Assert.Contains("::integer::double precision", expr);
    }

    [Fact]
    public void OtherRealColumnsStayFloat()
    {
        var expr = Expr("REAL", "sphere", "double precision");
        Assert.DoesNotContain("ROUND", expr);
        Assert.Contains("::double precision", expr);
    }

    [Fact]
    public void MoneyCastsToNumericAndAbsorbsFloatDrift()
    {
        var expr = Expr("NUMERIC(15,2)", "total_amount", "numeric");
        Assert.Contains("NULLIF(BTRIM", expr);
        Assert.EndsWith("::numeric", expr);

        var intExpr = Expr("INTEGER", "qty", "integer");
        Assert.Contains("::numeric", intExpr); // numeric hop rounds 1.00000004-style drift
    }

    [Fact]
    public void TimestampsAreCastWithTrimNullif()
    {
        var expr = Expr("TIMESTAMP", "date_of_entry", "timestamp without time zone");
        Assert.Contains("NULLIF(BTRIM", expr);
        Assert.Contains("::timestamp without time zone", expr);
    }

    [Fact]
    public void VarcharKeepsRawTextAndHonoursLength()
    {
        var col = new TargetColumn("sku", "character varying", 13, true);
        var expr = SchemaMapper.BuildExpression(new StagingColumn("sku", "VARCHAR (13)"), col);
        Assert.Contains("::varchar(13)", expr);
    }

    [Fact]
    public void TableBuildMapsRenamedTypoColumns()
    {
        var source = new StagingTable("txsorderlens", [
            new StagingColumn("rigthbase", "REAL"),
            new StagingColumn("rigthoc", "REAL"),
        ]);
        var target = new TargetTable
        {
            Name = "tx_s_order_lens",
            Columns = [
                new TargetColumn("right_base", "double precision", null, true),
                new TargetColumn("right_oc", "double precision", null, true),
            ],
            PrimaryKey = [],
        };
        var map = SchemaMapper.Build(source, target);
        Assert.Equal(2, map.Columns.Count);
        Assert.Equal(["right_base", "right_oc"], map.Columns.Select(c => c.Target.Name).ToArray());
    }
}
