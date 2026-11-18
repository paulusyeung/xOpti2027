using QuestPDF.Fluent;
using QuestPDF.Helpers;
using QuestPDF.Infrastructure;
using xOpti.Application.Sales.Documents;
using xOpti.Application.Wholesale;

namespace xOpti.Infrastructure.Documents;

public sealed class WholesaleReturnDocumentRenderer(InfrastructureOptions options)
    : IWholesaleReturnDocumentRenderer
{
    public RenderedDocument Render(WholesaleReturnDto document, bool duplicate)
    {
        _ = new QuestPdfDocumentRenderer(options);
        var pdf = Document.Create(container =>
        {
            container.Page(page =>
            {
                page.Size(PageSizes.A4);
                page.Margin(18, Unit.Millimetre);
                page.DefaultTextStyle(style => style.FontSize(10));
                page.Content().Column(column =>
                {
                    column.Item().Text("xOpti wholesale return").Bold().FontSize(18);
                    if (duplicate)
                        column.Item().Background(Colors.Red.Lighten3).Padding(3)
                            .Text("DUPLICATE WHOLESALE RETURN").Bold();
                    column.Item().PaddingTop(8).Text($"Return {document.TxNumber}");
                    column.Item().Text($"Original invoice {document.OriginalInvoiceNumber}");
                    column.Item().Text($"Date {document.DateOfEntry:yyyy-MM-dd} · {document.Status}");
                    column.Item().Text($"Customer {document.CustomerName} (#{document.CustomerId})");
                    column.Item().PaddingTop(8).Table(table =>
                    {
                        table.ColumnsDefinition(columns =>
                        {
                            columns.RelativeColumn(3);
                            columns.ConstantColumn(40);
                            columns.ConstantColumn(70);
                            columns.ConstantColumn(90);
                        });
                        table.Header(header =>
                        {
                            header.Cell().Text("SKU").Bold();
                            header.Cell().AlignRight().Text("Qty").Bold();
                            header.Cell().AlignRight().Text("Amount").Bold();
                            header.Cell().AlignRight().Text("Disposition").Bold();
                        });
                        foreach (var line in document.Lines)
                        {
                            table.Cell().Text(line.Sku);
                            table.Cell().AlignRight().Text(line.Quantity.ToString());
                            table.Cell().AlignRight().Text(line.Amount.ToString("0.0000"));
                            table.Cell().AlignRight().Text(line.Restock ? "restock" : "write-off");
                        }
                    });
                    column.Item().PaddingTop(8).AlignRight().Column(totals =>
                    {
                        totals.Item().Text($"Tax A {document.TaxA:0.0000}");
                        totals.Item().Text($"Tax B {document.TaxB:0.0000}");
                        totals.Item().Text($"Credit {document.TotalAmount:0.0000}").Bold();
                        totals.Item().Text($"Refunded {document.Refunded:0.0000}");
                    });
                    column.Item().PaddingTop(16).Text(duplicate ? "DUPLICATE" : "CUSTOMER COPY")
                        .FontSize(8);
                });
            });
        })
        .WithMetadata(new DocumentMetadata
        {
            Title = $"Wholesale return {document.TxNumber}",
            Author = "xOpti",
            Subject = duplicate ? "Duplicate wholesale return" : "Wholesale return",
            Creator = "xOpti Wholesale",
            Producer = "QuestPDF",
            CreationDate = document.DateOfEntry.UtcDateTime,
        })
        .GeneratePdf();
        return new RenderedDocument(pdf, "application/pdf",
            $"{document.TxNumber}{(duplicate ? "-duplicate" : string.Empty)}.pdf");
    }
}
