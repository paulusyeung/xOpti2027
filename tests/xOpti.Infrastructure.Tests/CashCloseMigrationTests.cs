using System.IO;

namespace xOpti.Infrastructure.Tests;

public class CashCloseMigrationTests
{
    [Fact]
    public void CashCloseMigration_TouchesOnlyPlatformCashObjects()
    {
        var root = new DirectoryInfo(AppContext.BaseDirectory);
        while (root is not null && !File.Exists(Path.Combine(root.FullName, "xOpti.sln"))) root = root.Parent;
        var file = Directory.GetFiles(Path.Combine(root!.FullName,
            "src", "xOpti.Infrastructure", "Persistence", "Migrations"),
            "*_AddCashCloseAndSessionLinks.cs").Single();
        var text = File.ReadAllText(file);

        Assert.Contains("name: \"cash_daily_close\"", text);
        Assert.Contains("name: \"cash_session_tx\"", text);
        Assert.Contains("name: \"business_date\"", text);
        Assert.Contains("schema: \"platform\"", text);
        foreach (var legacy in new[] { "tx_header", "tx_details", "tx_payment", "inventory", "customer" })
        {
            Assert.DoesNotContain(legacy, text, StringComparison.OrdinalIgnoreCase);
        }
        Assert.DoesNotContain("AlterColumn", text, StringComparison.Ordinal);
    }
}
