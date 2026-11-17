using System.IO;

namespace xOpti.Infrastructure.Tests;

public class PosRunbookTests
{
    [Fact]
    public void RunbookCoversTheAutomatedOperatorFlows()
    {
        var root = new DirectoryInfo(AppContext.BaseDirectory);
        while (root is not null && !File.Exists(Path.Combine(root.FullName, "xOpti.sln"))) root = root.Parent;
        var path = Path.Combine(root!.FullName, "docs", "operations", "pos.md");
        Assert.True(File.Exists(path));
        var text = File.ReadAllText(path);

        foreach (var heading in new[]
                 {
                     "Sale order (SA)", "Convert an order to an invoice (RC)",
                     "Counter sale and tenders", "Price overrides and discounts",
                     "Refund and exchange (RS)", "Cash drawer", "Daily close and journal",
                     "Reprints and printing", "Branch and company scope",
                 })
        {
            Assert.Contains(heading, text);
        }

        foreach (var testClass in new[]
                 {
                     "OrderEntryTests", "RetailSaleTests", "CashManagementTests",
                     "PosConcurrencyTests", "PosFullDayRehearsalTests", "PosTenantBranchTests",
                     "PosDocumentRenderingTests",
                 })
        {
            Assert.Contains($"{testClass}.", text);
            Assert.True(Directory.GetFiles(Path.Combine(root.FullName, "tests"),
                $"{testClass}.cs", SearchOption.AllDirectories).Length == 1,
                $"Runbook cites missing test class {testClass}.");
        }

        Assert.Contains("Expected cash = opening float", text);
        Assert.Contains("Migrated-data rehearsal", text);
        Assert.True(File.Exists(Path.Combine(root.FullName, "scripts", "pos-rehearsal.py")));
        var optical = Path.Combine(root.FullName, "docs", "operations", "optical-claims.md");
        Assert.True(File.Exists(optical));
        var opticalText = File.ReadAllText(optical);
        foreach (var heading in new[]
                 {
                     "Customer records and duplicates", "PII and PHI access", "Prescriptions",
                     "Optical orders", "Insurance plans, members, and claims",
                     "Claim receipt and RBIC", "Migrated-data rehearsal",
                 })
        {
            Assert.Contains(heading, opticalText);
        }
        Assert.True(File.Exists(Path.Combine(root.FullName, "scripts", "optical-claim-rehearsal.py")));
        Assert.Contains("totals are immutable", text);
        Assert.Contains("DUPLICATE COPY", text);
    }
}
