using QuestPDF.Fluent;
using QuestPDF.Helpers;
using QuestPDF.Infrastructure;
using xOpti.Application.Reporting;

namespace xOpti.Infrastructure.Documents;

/// <summary>Shared deterministic QuestPDF components used by report layouts.</summary>
public static class QuestPdfReportComponents
{
    public static void Header(ColumnDescriptor column, string title, string subtitle,
        DateTimeOffset asOf, bool duplicate)
    {
        column.Item().Text("xOpti").FontSize(10).FontColor(Colors.Grey.Darken2);
        column.Item().Text(title).Bold().FontSize(18);
        column.Item().Text(subtitle).FontSize(10);
        column.Item().Text($"As of {asOf.UtcDateTime:yyyy-MM-dd HH:mm:ss} UTC").FontSize(9);
        if (duplicate)
            column.Item().Background(Colors.Red.Lighten3).Padding(3)
                .Text("DUPLICATE REPORT").Bold();
    }

    public static void AddressBlock(ColumnDescriptor column, string? name, string? line1,
        string? line2)
    {
        if (string.IsNullOrWhiteSpace(name) && string.IsNullOrWhiteSpace(line1)
            && string.IsNullOrWhiteSpace(line2)) return;
        column.Item().PaddingTop(6).Column(address =>
        {
            if (!string.IsNullOrWhiteSpace(name)) address.Item().Text(name).Bold();
            if (!string.IsNullOrWhiteSpace(line1)) address.Item().Text(line1);
            if (!string.IsNullOrWhiteSpace(line2)) address.Item().Text(line2);
        });
    }

    public static void DataTable(ColumnDescriptor column, IReadOnlyList<ReportColumn> columns,
        IReadOnlyList<IReadOnlyList<object?>> rows)
    {
        column.Item().PaddingTop(8).Table(table =>
        {
            table.ColumnsDefinition(definition =>
            {
                foreach (var _ in columns) definition.RelativeColumn();
            });
            table.Header(header =>
            {
                foreach (var label in columns.Select(item => item.Label))
                    header.Cell().Background(Colors.Grey.Lighten4).Padding(2).Text(label).Bold();
            });
            foreach (var row in rows)
            {
                for (var index = 0; index < columns.Count; index++)
                {
                    var text = ReportLayout.Format(row[index], columns[index].Type);
                    table.Cell().Padding(2).Text(text);
                }
            }
        });
    }

    public static void Totals(ColumnDescriptor column,
        IReadOnlyList<(string Label, decimal Value)> totals)
    {
        column.Item().PaddingTop(8).AlignRight().Column(lines =>
        {
            foreach (var (label, value) in totals)
                lines.Item().Text($"{label} {value:0.0000}");
        });
    }

    public static void TaxSummary(ColumnDescriptor column, decimal gst, decimal pst)
    {
        column.Item().PaddingTop(4).Text($"GST {gst:0.0000} · PST {pst:0.0000}").FontSize(9);
    }

    public static void SignatureBlock(ColumnDescriptor column, params string[] labels)
    {
        column.Item().PaddingTop(24).Row(row =>
        {
            foreach (var label in labels)
            {
                row.RelativeItem().Column(signature =>
                {
                    signature.Item().PaddingTop(20).LineHorizontal(1);
                    signature.Item().Text(label).FontSize(8);
                });
            }
        });
    }

    public static void Barcode(ColumnDescriptor column, string value)
    {
        var family = QuestPdfDocumentRenderer.TryBarcodeFamily;
        var text = column.Item().Text($"*{value}*").FontSize(20);
        if (family is not null) text.FontFamily(family);
    }

    public static void PageNumbers(PageDescriptor page)
    {
        page.Footer().AlignCenter().Text(text =>
        {
            text.CurrentPageNumber();
            text.Span(" / ");
            text.TotalPages();
        });
    }
}
