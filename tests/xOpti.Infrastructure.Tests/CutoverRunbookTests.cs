using System.IO;

namespace xOpti.Infrastructure.Tests;

public class CutoverRunbookTests
{
    [Fact]
    public void RunbookCoversTheCutoverGate()
    {
        var root = new DirectoryInfo(AppContext.BaseDirectory);
        while (root is not null && !File.Exists(Path.Combine(root.FullName, "xOpti.sln")))
            root = root.Parent;
        var path = Path.Combine(root!.FullName, "docs", "operations", "cutover.md");
        Assert.True(File.Exists(path));
        var text = File.ReadAllText(path);
        foreach (var heading in new[]
                 {
                     "Source baseline", "Counter contract", "Reconciliation gate and exceptions",
                     "Command sequence", "Rehearsals", "Rollback",
                     "Post-cutover validation", "Retention and destruction", "Evidence and PII",
                 })
        {
            Assert.Contains(heading, text);
        }
        Assert.Contains("MIGRATION_EXPECTED_SHA256", text);
        Assert.Contains("tx_next_number` stores **the next number to allocate**", text);
        Assert.Contains("RC`, `RS`, `SR`, `RJ`, `SJ`, `WC`, `WR`, and `SA", text);
        Assert.Contains("reconciliation-gate.json", text);
        Assert.Contains("CutoverGateTests.", text);
        Assert.Contains("ControlNumberContractTests.", text);
        Assert.Contains("ReconciliationFixtureTests.", text);
    }
}
