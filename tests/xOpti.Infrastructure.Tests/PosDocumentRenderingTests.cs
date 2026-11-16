using System.IO;
using System.Security.Cryptography;
using System.Text;
using System.Text.RegularExpressions;
using xOpti.Application.Sales.Documents;
using xOpti.Infrastructure;
using xOpti.Infrastructure.Documents;

namespace xOpti.Infrastructure.Tests;

public class PosDocumentRenderingTests
{
    private static QuestPdfPosDocumentRenderer Renderer()
    {
        var root = new DirectoryInfo(AppContext.BaseDirectory);
        while (root is not null && !File.Exists(Path.Combine(root.FullName, "xOpti.sln"))) root = root.Parent;
        var fontDir = Path.Combine(root!.FullName, "eOptical6DAO");
        return new QuestPdfPosDocumentRenderer(new InfrastructureOptions
        {
            ConnectionString = "unused", FontDirectories = new[] { fontDir },
        });
    }

    private static PosDocumentRenderDto Document(bool duplicate = false) => new(
        "RC00000001", "Invoice", "Retail invoice", duplicate,
        new DateTimeOffset(2026, 1, 2, 3, 4, 5, TimeSpan.Zero),
        1, "Test Customer", "0007", null, "0",
        100m, 5m, 7m, 112m, 0m, 112m,
        new[]
        {
            new PosRenderLine(1, "30110359", "Demo Frame", 2, 50m, 0m, 100m, "B"),
        },
        new[]
        {
            new PosRenderTender(1, "C", 120m, 112m, null),
        },
        new[] { "RC00000001" });

    [Fact]
    public void ReceiptLayout_PlanIsGolden_AndUses80mmStock()
    {
        var renderer = Renderer();
        var first = renderer.Render(Document(), "receipt");
        var second = renderer.Render(Document(), "receipt");

        Assert.Equal("%PDF", Encoding.ASCII.GetString(first.Content[..4]));
        Assert.Equal("%PDF", Encoding.ASCII.GetString(second.Content[..4]));
        var text = Encoding.ASCII.GetString(first.Content);
        Assert.Matches(new Regex("MediaBox \\[0 0 226\\.7"), text);

        var plan = string.Join("\n", PosDocumentLayout.Build(Document()));
        const string golden = """
            xOpti
            Retail invoice
            Document RC00000001
            Date 2026-01-02 03:04
            Customer Test Customer (#1)
            Staff 0007
            30110359 Demo Frame x2 @50.00 = 100.00
            Subtotal 100.00
            GST 5.00
            PST 7.00
            Total 112.00
            Paid 112.00
            Tender C 112.00
            *RC00000001*
            CUSTOMER COPY · xOpti POS
            """;
        Assert.Equal(golden.ReplaceLineEndings("\n"), plan);
    }

    [Fact]
    public void DuplicateReprint_IsMarkedAndDiffersFromTheOriginal()
    {
        var renderer = Renderer();
        var original = renderer.Render(Document(), "receipt");
        var duplicate = renderer.Render(Document(duplicate: true), "receipt");

        Assert.NotEqual(original.Content, duplicate.Content);
        Assert.EndsWith("-duplicate.pdf", duplicate.FileName);
        Assert.Contains("Duplicate reprint", Encoding.ASCII.GetString(duplicate.Content));
    }

    [Fact]
    public void InvoiceLayout_UsesA4()
    {
        var renderer = Renderer();
        var invoice = renderer.Render(Document(), "invoice");
        var text = Encoding.ASCII.GetString(invoice.Content);
        Assert.Matches(new Regex("MediaBox \\[0 0 595"), text);
    }
}
