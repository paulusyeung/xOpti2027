using System.IO;

namespace xOpti.Infrastructure.Tests;

public class CashMigrationTests
{
    [Fact]
    public void CashMigration_CreatesOnlyPlatformTables()
    {
        var root = new DirectoryInfo(AppContext.BaseDirectory);
        while (root is not null && !File.Exists(Path.Combine(root.FullName, "xOpti.sln"))) root = root.Parent;
        var file = Directory.GetFiles(Path.Combine(root!.FullName,
            "src", "xOpti.Infrastructure", "Persistence", "Migrations"), "*_AddCashManagement.cs").Single();
        var text = File.ReadAllText(file);

        Assert.Contains("name: \"cash_session\"", text);
        Assert.Contains("name: \"cash_count\"", text);
        Assert.Contains("name: \"cash_movement\"", text);
        Assert.Contains("schema: \"platform\"", text);
        foreach (var legacy in new[] { "tx_header", "tx_details", "tx_payment", "inventory", "customer", "staff" })
        {
            Assert.DoesNotContain(legacy, text, StringComparison.OrdinalIgnoreCase);
        }
        // Down() only removes the app-owned cash tables.
        Assert.DoesNotContain("DropColumn", text, StringComparison.Ordinal);
    }
}
