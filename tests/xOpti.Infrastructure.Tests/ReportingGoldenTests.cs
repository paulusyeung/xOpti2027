using System.IO;
using System.Text;
using System.Text.RegularExpressions;
using Microsoft.Extensions.Logging.Abstractions;
using xOpti.Application.Reporting;
using xOpti.Infrastructure.Documents;

namespace xOpti.Infrastructure.Tests;

public class ReportingGoldenTests
{
    private static string Root()
    {
        var dir = new DirectoryInfo(AppContext.BaseDirectory);
        while (dir is not null && !File.Exists(Path.Combine(dir.FullName, "xOpti.sln")))
            dir = dir.Parent;
        return dir!.FullName;
    }

    private static ReportDocument DocumentFor(ReportCatalogueEntry entry)
    {
        var definition = ReportReadModels.Get(entry.ReadModel);
        var columns = definition.Fields
            .Select(field => new ReportColumn(field.Key, field.Label, field.Type)).ToList();
        var row = definition.Fields.Select(field => field.Type switch
        {
            "money" => (object?)10.0000m,
            "number" => 1,
            "date" => new DateTime(2026, 1, 2, 0, 0, 0, DateTimeKind.Utc),
            _ => "value",
        }).ToList();
        return new ReportDocument(entry, columns, new[] { (IReadOnlyList<object?>)row },
            new Dictionary<string, string?> { ["AskDateFrom"] = "2026-01-01" },
            false, entry.RowCap, new DateTimeOffset(2026, 1, 2, 0, 0, 0, TimeSpan.Zero),
            false, false);
    }

    private static string CatalogueGolden()
    {
        var builder = new StringBuilder();
        foreach (var entry in ReportCatalogueData.All.OrderBy(entry => entry.Id))
        {
            builder.AppendLine($"=== {entry.Id} {entry.LogicalName} ===");
            foreach (var line in ReportLayout.Build(DocumentFor(entry)))
                builder.AppendLine(line);
            builder.AppendLine();
        }
        return builder.ToString();
    }

    [Fact]
    public void EveryEffectiveReportFile_IsClassifiedInTheCatalogue()
    {
        var csv = Path.Combine(Root(), "docs", "parity", "reports.csv");
        var ids = File.ReadLines(csv).Skip(1)
            .Select(line => line.Split(',')[0].Trim())
            .Where(id => id.StartsWith("RPT-"))
            .ToHashSet(StringComparer.Ordinal);
        var catalogue = ReportCatalogueData.All
            .Where(entry => entry.Id.StartsWith("RPT-"))
            .ToDictionary(entry => entry.Id, StringComparer.Ordinal);
        Assert.Equal(98, ids.Count);
        Assert.Equal(ids.OrderBy(id => id), catalogue.Keys.OrderBy(id => id));
        Assert.All(catalogue.Values, entry =>
        {
            Assert.False(string.IsNullOrWhiteSpace(entry.LayoutKey));
            Assert.False(string.IsNullOrWhiteSpace(entry.ReadModel));
            Assert.False(string.IsNullOrWhiteSpace(entry.Permission));
            Assert.Equal("provisional", entry.InScope);
            Assert.Equal("pending", entry.SignoffStatus);
        });
    }

    [Fact]
    public void CatalogueLayouts_AreDeterministicAndGolden()
    {
        var path = Path.Combine(Root(), "docs", "reports", "golden-catalogue.txt");
        var actual = CatalogueGolden();
        Assert.Equal(actual, CatalogueGolden());
        if (Environment.GetEnvironmentVariable("XOPTI_UPDATE_GOLDEN") == "1")
            File.WriteAllText(path, actual);
        Assert.True(File.Exists(path), "Golden catalogue file is missing.");
        Assert.Equal(File.ReadAllText(path), actual);
    }

    [Fact]
    public void GenericReportPdf_IsByteStableAfterMetadataNormalization()
    {
        var entry = ReportCatalogueData.All.Single(item => item.Id == "RPT-014");
        var document = DocumentFor(entry);
        var renderer = new QuestPdfReportRenderer(new InfrastructureOptions());
        var first = renderer.RenderReport(document);
        var second = renderer.RenderReport(document);
        Assert.Equal("%PDF", Encoding.ASCII.GetString(first.Content[..4]));
        Assert.Equal(Normalize(first.Content), Normalize(second.Content));
        Assert.True(first.Content.Length > 1000);
    }

    [Fact]
    public void SharedComponents_RenderHeaderTableTotalsBarcodeAndPageNumbers()
    {
        var entry = ReportCatalogueData.All.Single(item => item.Id == "RPT-014");
        var document = DocumentFor(entry);
        var plan = string.Join("\n", ReportLayout.Build(document));
        Assert.Contains("xOpti report", plan);
        Assert.Contains("RPT-014", plan);
        Assert.Contains("Customer | Name", plan);
        Assert.Contains("Customer", plan);
        Assert.Contains("As of 2026-01-02 00:00:00 UTC", plan);
    }

    private static string Normalize(byte[] pdf)
    {
        var text = Encoding.Latin1.GetString(pdf);
        text = Regex.Replace(text, @"/CreationDate\s*\([^)]*\)", "/CreationDate (D:20000101000000Z)");
        text = Regex.Replace(text, @"/ModDate\s*\([^)]*\)", "/ModDate (D:20000101000000Z)");
        text = Regex.Replace(text, @"/ID\s*\[[^\]]*\]", "/ID [<00><00>]");
        return text;
    }
}

public class ReportingSecurityTests
{
    private sealed class Principal(params string[] permissions)
        : xOpti.Application.Ports.ICurrentPrincipal
    {
        public string? UserId => "test";
        public string? BranchCode => "01";
        public bool HasPermission(string permission) => permissions.Contains(permission);
    }

    [Fact]
    public void CostAndMarginFields_AreMaskedWithoutCostPermission()
    {
        var columns = new[]
        {
            new ReportColumn("sku", "SKU", "text"),
            new ReportColumn("cost", "Cost", "money"),
            new ReportColumn("margin", "Margin", "money"),
        };
        var fields = new[]
        {
            new ReportField("sku", "SKU", "text"),
            new ReportField("cost", "Cost", "money", true),
            new ReportField("margin", "Margin", "money", true),
        };
        var rows = new[] { (IReadOnlyList<object?>)new object?[] { "ABC", 10m, 2m } };

        var masked = ReportDataMasking.Mask(columns, rows, fields, new Principal());
        Assert.Equal(new object?[] { "ABC", null, null }, masked.Rows.Single());

        var visible = ReportDataMasking.Mask(columns, rows, fields,
            new Principal(xOpti.Application.Authorization.PermissionNames.CostView));
        Assert.Equal(new object?[] { "ABC", 10m, 2m }, visible.Rows.Single());
    }

    [Fact]
    public void RequiredAndTypedParameters_ReturnFieldLevelErrors()
    {
        var entry = ReportCatalogueData.All.Single(item => item.Id == "RPT-071");
        Assert.Throws<xOpti.Application.Pipeline.ValidationFailedException>(() =>
            ReportParameterValues.Bind(entry, new Dictionary<string, string?>()));
        Assert.Throws<xOpti.Application.Pipeline.ValidationFailedException>(() =>
            ReportParameterValues.Bind(entry, new Dictionary<string, string?>
            {
                ["AskDateFrom"] = "not-a-date", ["AskDateTo"] = "2026-01-01",
            }));
        Assert.Throws<xOpti.Application.Pipeline.ValidationFailedException>(() =>
            ReportParameterValues.Bind(entry, new Dictionary<string, string?>
            {
                ["AskDateFrom"] = "2026-02-01", ["AskDateTo"] = "2026-01-01",
            }));
        var valid = ReportParameterValues.Bind(entry, new Dictionary<string, string?>
        {
            ["AskDateFrom"] = "2026-01-01", ["AskDateTo"] = "2026-01-31",
        });
        Assert.Equal("2026-01-01", valid.Get("AskDateFrom"));
    }

    [Fact]
    public void AnalyticsDefinitions_MarkCostAndMarginAsSensitive()
    {
        foreach (var view in xOpti.Application.Analytics.AnalyticsViews.All
                     .Where(view => view.Key != "orders_in_progress"))
        {
            Assert.Contains(view.Fields, field => field.Sensitive);
        }
    }
}
