using System.IO;

namespace xOpti.Infrastructure.Tests;

public class WholesaleRunbookTests
{
    [Fact]
    public void WholesaleRunbookCoversTheAutomatedOperatorFlows()
    {
        var root = new DirectoryInfo(AppContext.BaseDirectory);
        while (root is not null && !File.Exists(Path.Combine(root.FullName, "xOpti.sln")))
            root = root.Parent;
        var path = Path.Combine(root!.FullName, "docs", "operations", "wholesale.md");
        Assert.True(File.Exists(path));
        var text = File.ReadAllText(path);

        foreach (var heading in new[]
                 {
                     "Account and terms", "Price lists and overrides",
                     "Wholesale invoice (WC)", "Backorders and partial fulfilment",
                     "Wholesale return (WR)", "Packing lists and price visibility",
                     "Balances and statements", "Concurrency and numbering",
                     "Migrated-data reconciliation",
                 })
        {
            Assert.Contains(heading, text);
        }

        foreach (var testClass in new[]
                 {
                     "WholesaleAccountTests", "WholesalePricingTests",
                     "WholesalePricingApiTests", "WholesaleInvoiceTests",
                     "WholesalePostingTests", "WholesaleReturnTests",
                     "WholesaleReportingTests", "WholesaleConcurrencyTests",
                 })
        {
            Assert.Contains($"{testClass}.", text);
            Assert.True(Directory.GetFiles(Path.Combine(root.FullName, "tests"),
                $"{testClass}.cs", SearchOption.AllDirectories).Length == 1,
                $"Runbook cites missing test class {testClass}.");
        }

        Assert.Contains("XOptiApi:WholesaleBackordersEnabled", text);
        Assert.Contains("report:financial", text);
        Assert.Contains("sales:price-override", text);
        Assert.True(File.Exists(Path.Combine(root.FullName, "scripts",
            "wholesale-reconciliation.py")));
        Assert.Contains("WholesalePage.test.ts", text);
        Assert.Contains("WholesaleInvoicePage.test.ts", text);
    }
}
