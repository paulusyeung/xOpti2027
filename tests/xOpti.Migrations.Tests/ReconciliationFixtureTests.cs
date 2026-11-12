using System.Globalization;
using System.Text.Json;
using xOpti.Migrations;

namespace xOpti.Migrations.Tests;

/// <summary>
/// Exercises the reconciliation report contract against a committed fixture:
/// PASS/FAIL aggregation, money-tolerance detail, CSV quoting, and the
/// Markdown/CSV round trip used by the cutover gate. No database required.
/// </summary>
public class ReconciliationFixtureTests
{
    private static string RepoRoot()
    {
        var dir = new DirectoryInfo(AppContext.BaseDirectory);
        while (dir is not null && !File.Exists(Path.Combine(dir.FullName, "xOpti.sln")))
        {
            dir = dir.Parent;
        }

        return dir!.FullName;
    }

    private static string FixturePath() =>
        Path.Combine(RepoRoot(), "tests", "xOpti.Migrations.Tests", "Fixtures", "reconciliation-fixture.csv");

    private static ReconcileReport LoadReport()
    {
        var lines = File.ReadAllLines(FixturePath());
        var report = new ReconcileReport();
        foreach (var line in lines.Skip(1))
        {
            var fields = ParseCsv(line);
            Assert.Equal(6, fields.Count);
            report.Rows.Add(new CheckRow(fields[0], fields[1], fields[2], fields[3], fields[4], fields[5]));
        }

        return report;
    }

    [Fact]
    public void Fixture_ReportsTheExpectedPassAndFailCounts()
    {
        var report = LoadReport();

        Assert.Equal(6, report.Rows.Count);
        Assert.Equal(1, report.FailCount);
        Assert.False(report.Passed);
        Assert.Equal("FAIL", report.Rows.Single(r => r.Check == "aggregate" && r.Scope == "tx_details.amount").Status);
    }

    [Fact]
    public void Writer_RoundTripsTheFixture_WithQuotedDetail()
    {
        var report = LoadReport();
        var directory = Path.Combine(Path.GetTempPath(), "xopti-reconcile-" + Guid.NewGuid().ToString("N")[..8]);
        try
        {
            var config = new MigrationConfig
            {
                SynergyMdbPath = "unused.mdb",
                TargetConnectionString = "Host=unused",
                ReportsDirectory = directory,
                RepositoryRoot = RepoRoot(),
            };

            var (markdownPath, csvPath) = ReconcileReportWriter.Write(
                config,
                report,
                "reconcile",
                dryRun: true,
                new SourceFingerprint("fixture.mdb", new string('a', 64), 70));

            var markdown = File.ReadAllText(markdownPath);
            Assert.Contains("**FAIL** (1 failing checks)", markdown, StringComparison.Ordinal);
            Assert.Contains("| aggregate | tx_details.amount | 88321.10 | 88321.16 | FAIL |", markdown, StringComparison.Ordinal);

            var csv = File.ReadAllLines(csvPath);
            Assert.Equal(7, csv.Length);
            Assert.Contains("\"two cents over tolerance, see note\"", csv[4], StringComparison.Ordinal);

            // The CSV carries the same verdict the cutover gate reads.
            Assert.Equal(report.Rows.Count, csv.Length - 1);
        }
        finally
        {
            if (Directory.Exists(directory))
            {
                Directory.Delete(directory, recursive: true);
            }
        }
    }

    private static List<string> ParseCsv(string line)
    {
        var fields = new List<string>();
        var current = new System.Text.StringBuilder();
        var quoted = false;
        for (var i = 0; i < line.Length; i++)
        {
            var ch = line[i];
            if (quoted)
            {
                if (ch == '"' && i + 1 < line.Length && line[i + 1] == '"')
                {
                    current.Append('"');
                    i++;
                }
                else if (ch == '"')
                {
                    quoted = false;
                }
                else
                {
                    current.Append(ch);
                }
            }
            else if (ch == '"')
            {
                quoted = true;
            }
            else if (ch == ',')
            {
                fields.Add(current.ToString());
                current.Clear();
            }
            else
            {
                current.Append(ch);
            }
        }

        fields.Add(current.ToString());
        return fields;
    }
}
