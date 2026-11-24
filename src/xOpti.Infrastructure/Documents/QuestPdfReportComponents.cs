using QuestPDF.Fluent;
using QuestPDF.Helpers;
using QuestPDF.Infrastructure;
using xOpti.Application.Reporting;
using ZXing;
using ZXing.Common;
using ZXing.OneD;

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

    public static void Barcode(IContainer container, string value)
    {
        // Legacy Crystal renders "*SKU*" in 3of9.TTF: 115pt wide, 15pt tall,
        // starting 6.7pt inside the label. ZXing adds the Code39 start/stop
        // guards itself, so the raw SKU is encoded.
        container.PaddingLeft(6.7f).PaddingBottom(5f)
            .AlignLeft().Width(115).Height(15).Svg(_ =>
        {
            var hints = new Dictionary<EncodeHintType, object>
            {
                [EncodeHintType.MARGIN] = 0,
            };
            var matrix = new Code39Writer().encode(value, BarcodeFormat.CODE_39, 348, 66, hints);

            // ZXing centres the pattern inside the requested matrix even with a
            // zero margin. Crop to the ink box so the bars fill the viewBox.
            var first = matrix.Width;
            var last = -1;
            for (var x = 0; x < matrix.Width; x++)
            {
                if (!matrix[x, 0]) continue;
                first = Math.Min(first, x);
                last = x;
            }

            var width = last - first + 1;
            var svg = new System.Text.StringBuilder();
            svg.Append("<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 ")
                .Append(width).Append(' ').Append(matrix.Height)
                .Append("' preserveAspectRatio='none'>");

            // 1D barcodes repeat one pattern on every row, so one full-height
            // rectangle per contiguous bar keeps the PDF small and sharp.
            var x0 = first;
            while (x0 <= last)
            {
                if (!matrix[x0, 0]) { x0++; continue; }
                var x1 = x0;
                while (x1 <= last && matrix[x1, 0]) x1++;
                svg.Append("<rect x='").Append(x0 - first).Append("' y='0' width='")
                    .Append(x1 - x0).Append("' height='").Append(matrix.Height).Append("'/>");
                x0 = x1;
            }
            svg.Append("</svg>");
            return svg.ToString();
        });
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
