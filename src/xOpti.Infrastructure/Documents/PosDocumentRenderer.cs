using QuestPDF.Fluent;
using QuestPDF.Helpers;
using QuestPDF.Infrastructure;
using xOpti.Application.Sales.Documents;

namespace xOpti.Infrastructure.Documents;

/// <summary>
/// Deterministic POS document layouts through the render port. Receipts use
/// 80 mm stock; invoices and orders use A4. Approved customer-specific layouts
/// are still pending sign-off.
/// </summary>
public sealed class QuestPdfPosDocumentRenderer : IPosDocumentRenderer
{
    public QuestPdfPosDocumentRenderer(InfrastructureOptions options)
    {
        // Reuse the shared font registration (bundled 3of9) from the stub renderer.
        _ = new QuestPdfDocumentRenderer(options);
    }

    public RenderedDocument Render(PosDocumentRenderDto document, string format)
    {
        var receipt = format == "receipt";
        var pageSize = receipt
            ? new PageSize(80, 297, Unit.Millimetre)
            : PageSizes.A4;
        var barcodeFamily = QuestPdfDocumentRenderer.TryBarcodeFamily;

        var pdf = Document.Create(container =>
        {
            container.Page(page =>
            {
                page.Size(pageSize);
                page.Margin(receipt ? 4 : 18, Unit.Millimetre);
                page.DefaultTextStyle(style => style.FontSize(receipt ? 8 : 11));
                page.Header().Column(header =>
                {
                    header.Item().Text("xOpti").Bold().FontSize(receipt ? 12 : 18);
                    header.Item().Text(document.Title).Bold();
                    if (document.Duplicate)
                    {
                        header.Item().Background(Colors.Red.Lighten3).Padding(2)
                            .Text("DUPLICATE COPY — REPRINT").Bold();
                    }
                });
                page.Content().PaddingVertical(receipt ? 4 : 10).Column(column =>
                {
                    column.Item().Text($"Document {document.TxNumber}").Bold();
                    if (!string.IsNullOrWhiteSpace(document.OriginalTxNumber))
                        column.Item().Text($"Original {document.OriginalTxNumber}");
                    column.Item().Text($"Date {document.DateOfEntry:yyyy-MM-dd HH:mm}");
                    if (!string.IsNullOrWhiteSpace(document.CustomerName))
                        column.Item().Text($"Customer {document.CustomerName} (#{document.CustomerId})");
                    if (!string.IsNullOrWhiteSpace(document.StaffCode))
                        column.Item().Text($"Staff {document.StaffCode}");

                    column.Item().PaddingTop(6).Table(table =>
                    {
                        table.ColumnsDefinition(columns =>
                        {
                            columns.RelativeColumn(4);
                            columns.ConstantColumn(receipt ? 22 : 40);
                            columns.ConstantColumn(receipt ? 42 : 70);
                        });
                        table.Header(header =>
                        {
                            header.Cell().Text("Item").Bold();
                            header.Cell().AlignRight().Text("Qty").Bold();
                            header.Cell().AlignRight().Text("Amount").Bold();
                        });
                        foreach (var line in document.Lines)
                        {
                            table.Cell().Text($"{line.Sku} {line.Name}".Trim());
                            table.Cell().AlignRight().Text(line.Qty.ToString());
                            table.Cell().AlignRight().Text(line.Amount.ToString("0.00"));
                        }
                    });

                    column.Item().PaddingTop(6).AlignRight().Column(totals =>
                    {
                        totals.Item().Text($"Subtotal {document.Subtotal:0.00}");
                        totals.Item().Text($"GST {document.TaxA:0.00}");
                        totals.Item().Text($"PST {document.TaxB:0.00}");
                        totals.Item().Text($"Total {document.Total:0.00}").Bold();
                        totals.Item().Text($"Paid {document.Paid:0.00}");
                        if (document.Change != 0) totals.Item().Text($"Change {document.Change:0.00}");
                    });

                    if (document.Tenders.Count > 0)
                    {
                        column.Item().PaddingTop(6).Text("Tenders").Bold();
                        foreach (var tender in document.Tenders)
                        {
                            column.Item().Text(
                                $"{tender.Type} {tender.AppliedAmount:0.00}"
                                + (string.IsNullOrWhiteSpace(tender.Reference)
                                    ? string.Empty
                                    : $" ref {tender.Reference}"));
                        }
                    }

                    foreach (var barcode in document.Barcodes)
                    {
                        var text = column.Item().PaddingTop(8).Text($"*{barcode}*").FontSize(receipt ? 18 : 24);
                        if (barcodeFamily is not null) text.FontFamily(barcodeFamily);
                    }
                });
                page.Footer().AlignCenter().Text(text =>
                {
                    text.Span(document.Duplicate ? "DUPLICATE" : "CUSTOMER COPY").FontSize(7);
                    text.Span(" · xOpti POS").FontSize(7);
                });
            });
        })
        .WithMetadata(new DocumentMetadata
        {
            Title = $"{document.Title} {document.TxNumber}",
            Author = "xOpti",
            Subject = document.Duplicate ? "Duplicate reprint" : "POS document",
            Creator = "xOpti POS",
            Producer = "QuestPDF",
            CreationDate = document.DateOfEntry.UtcDateTime,
        })
        .GeneratePdf();

        return new RenderedDocument(pdf, "application/pdf",
            $"{document.TxNumber}{(document.Duplicate ? "-duplicate" : string.Empty)}.pdf");
    }
}
