using System.IO;

namespace xOpti.Infrastructure.Tests;

public class RetailMigrationTests
{
    [Fact]
    public void RefundLinkMigration_CreatesOnlyThePlatformTable()
    {
        var root = new DirectoryInfo(AppContext.BaseDirectory);
        while (root is not null && !File.Exists(Path.Combine(root.FullName, "xOpti.sln"))) root = root.Parent;
        var file = Directory.GetFiles(Path.Combine(root!.FullName,
            "src", "xOpti.Infrastructure", "Persistence", "Migrations"), "*_AddSalesRefundLinks.cs").Single();
        var text = File.ReadAllText(file);

        Assert.Contains("name: \"sales_refund_line\"", text);
        Assert.Contains("schema: \"platform\"", text);
        Assert.Contains("tax_a", text);
        Assert.Contains("tax_b", text);
        foreach (var legacy in new[] { "tx_header", "tx_details", "tx_payment", "inventory", "customer" })
        {
            Assert.DoesNotContain(legacy, text, StringComparison.OrdinalIgnoreCase);
        }
        Assert.DoesNotContain("DropColumn", text, StringComparison.Ordinal);
        Assert.DoesNotContain("AlterColumn", text, StringComparison.Ordinal);
    }
}
