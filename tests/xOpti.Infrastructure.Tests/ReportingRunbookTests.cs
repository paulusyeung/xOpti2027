using System.IO;

namespace xOpti.Infrastructure.Tests;

public class ReportingRunbookTests
{
    [Fact]
    public void ReportingRunbookCoversAutomatedBehaviour()
    {
        var root = new DirectoryInfo(AppContext.BaseDirectory);
        while (root is not null && !File.Exists(Path.Combine(root.FullName, "xOpti.sln")))
            root = root.Parent;
        var path = Path.Combine(root!.FullName, "docs", "operations", "reporting.md");
        Assert.True(File.Exists(path));
        var text = File.ReadAllText(path);
        foreach (var heading in new[]
                 {
                     "Report catalogue", "Parameters, preview, print, export, and reprint",
                     "Read models, refresh, and freshness", "Critical documents",
                     "Deterministic output and golden files", "Analytics",
                     "Licensing and open items",
                 })
        {
            Assert.Contains(heading, text);
        }
        foreach (var testClass in new[]
                 {
                     "ReportingTests", "ReportingGoldenTests", "ReportingSecurityTests",
                     "ReportingRunbookTests", "ReportPerformanceTests",
                 })
        {
            Assert.Contains($"{testClass}.", text);
        }
        Assert.True(File.Exists(Path.Combine(root.FullName, "docs", "reports",
            "golden-catalogue.txt")));
        Assert.Contains("signoff_status = pending", text);
        Assert.Contains("SYS-INVOICE", text);
        Assert.Contains("cost:view", text);
    }
}
