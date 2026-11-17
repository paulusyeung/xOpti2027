using System.IO;

namespace xOpti.Infrastructure.Tests;

public class ClaimMigrationTests
{
    [Fact]
    public void ClaimMigration_CreatesOnlyPlatformTables()
    {
        var root = new DirectoryInfo(AppContext.BaseDirectory);
        while (root is not null && !File.Exists(Path.Combine(root.FullName, "xOpti.sln"))) root = root.Parent;
        var file = Directory.GetFiles(Path.Combine(root!.FullName,
            "src", "xOpti.Infrastructure", "Persistence", "Migrations"),
            "*_AddInsurancePlansAndClaims.cs").Single();
        var text = File.ReadAllText(file);

        foreach (var table in new[] { "insurance_plan", "coverage_rule", "insurance_member",
                     "claim", "claim_line", "claim_event", "claim_payment" })
        {
            Assert.Contains($"name: \"{table}\"", text);
        }
        Assert.Contains("schema: \"platform\"", text);
        foreach (var legacy in new[] { "tx_header", "tx_details", "tx_payment", "inventory", "customer_accounts" })
        {
            Assert.DoesNotContain(legacy, text, StringComparison.OrdinalIgnoreCase);
        }
        Assert.DoesNotContain("AlterColumn", text, StringComparison.Ordinal);
    }
}
