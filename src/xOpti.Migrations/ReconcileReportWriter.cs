using System.Globalization;
using System.Text;

namespace xOpti.Migrations;

public static class ReconcileReportWriter
{
    public static (string MarkdownPath, string CsvPath) Write(
        MigrationConfig config, ReconcileReport report, string command, bool dryRun, SourceFingerprint source)
    {
        Directory.CreateDirectory(config.ReportsDirectory);
        var stamp = DateTime.UtcNow.ToString("yyyy-MM-dd HH:mm 'UTC'", CultureInfo.InvariantCulture);

        var md = new StringBuilder();
        md.AppendLine("# xOpti migration reconciliation report");
        md.AppendLine();
        md.AppendLine($"- Command: `{command}`{(dryRun ? " (dry run)" : "")} at {stamp}");
        md.AppendLine($"- Source: `{source.Path}` sha256 `{source.Sha256}` ({source.TableCount} tables)");
        md.AppendLine($"- Tolerance: {config.Tolerance.ToString("0.############", CultureInfo.InvariantCulture)}");
        md.AppendLine($"- Result: **{(report.Passed ? "PASS" : "FAIL")}** ({report.FailCount} failing checks)");
        md.AppendLine();
        md.AppendLine("| Check | Scope | Expected | Actual | Status | Detail |");
        md.AppendLine("| --- | --- | ---: | ---: | --- | --- |");
        foreach (var row in report.Rows)
            md.AppendLine($"| {Esc(row.Check)} | {Esc(row.Scope)} | {Esc(row.Expected)} | {Esc(row.Actual)} | {row.Status} | {Esc(row.Detail)} |");

        var mdPath = Path.Combine(config.ReportsDirectory, "reconciliation.md");
        File.WriteAllText(mdPath, md.ToString());

        var csvPath = Path.Combine(config.ReportsDirectory, "reconciliation-workbook.csv");
        using (var csv = new StreamWriter(csvPath))
        {
            csv.WriteLine("check,scope,expected,actual,status,detail");
            foreach (var row in report.Rows)
                csv.WriteLine(string.Join(',', Csv(row.Check), Csv(row.Scope), Csv(row.Expected), Csv(row.Actual), Csv(row.Status), Csv(row.Detail)));
        }

        WriteGate(config, report, command, dryRun, source);
        WriteExceptionWorkbook(config, report, source);
        return (mdPath, csvPath);
    }

    private static void WriteGate(MigrationConfig config, ReconcileReport report,
        string command, bool dryRun, SourceFingerprint source)
    {
        var payload = new
        {
            result = report.Passed ? "PASS" : "FAIL",
            command,
            dryRun,
            generatedAtUtc = DateTime.UtcNow.ToString("O", CultureInfo.InvariantCulture),
            sourcePath = source.Path,
            sourceSha256 = source.Sha256,
            sourceTables = source.TableCount,
            tolerance = config.Tolerance,
            checks = report.Rows.Count,
            failing = report.FailCount,
            failures = report.Rows.Where(row => row.Status == "FAIL")
                .Select(row => new { row.Check, row.Scope, row.Expected, row.Actual, row.Detail }),
        };
        var path = Path.Combine(config.ReportsDirectory, "reconciliation-gate.json");
        File.WriteAllText(path, System.Text.Json.JsonSerializer.Serialize(payload,
            new System.Text.Json.JsonSerializerOptions { WriteIndented = true }));
    }

    private static void WriteExceptionWorkbook(MigrationConfig config, ReconcileReport report,
        SourceFingerprint source)
    {
        var path = Path.Combine(config.ReportsDirectory, "exception-workbook.csv");
        using var csv = new StreamWriter(path);
        csv.WriteLine("category,source_key,expected,actual,cause,disposition,owner,approval,evidence");
        foreach (var row in report.Rows.Where(row => row.Status is "FAIL" or "INFO"))
        {
            csv.WriteLine(string.Join(',', Csv(row.Check), Csv(row.Scope), Csv(row.Expected),
                Csv(row.Actual), Csv(row.Detail), Csv(row.Status == "FAIL" ? "OPEN" : "INFORMATIONAL"),
                Csv(""), Csv(""), Csv($"sha256:{source.Sha256}")));
        }
    }

    private static string Esc(string? value) => (value ?? "").Replace("|", "\\|").Replace("\n", " ");

    private static string Csv(string? value)
    {
        value ??= "";
        return value.Contains(',') || value.Contains('"')
            ? "\"" + value.Replace("\"", "\"\"") + "\""
            : value;
    }
}
