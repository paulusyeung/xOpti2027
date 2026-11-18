using QuestPDF.Fluent;
using QuestPDF.Helpers;
using QuestPDF.Infrastructure;
using xOpti.Application.Sales.Documents;
using xOpti.Application.Wholesale;

namespace xOpti.Infrastructure.Documents;

public sealed class WholesaleInvoiceDocumentRenderer(InfrastructureOptions options)
    : IWholesaleInvoiceDocumentRenderer
{
    public RenderedDocument Render(WholesaleInvoiceDto invoice, bool duplicate)
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
                    column.Item().Text("xOpti wholesale invoice").Bold().FontSize(18);
                    if (duplicate)
                        column.Item().Background(Colors.Red.Lighten3).Padding(3)
                            .Text("DUPLICATE WHOLESALE INVOICE").Bold();
                    column.Item().PaddingTop(8).Text($"Invoice {invoice.TxNumber}");
                    column.Item().Text($"Date {invoice.DateOfEntry:yyyy-MM-dd} · {invoice.Status}");
                    column.Item().Text($"Customer {invoice.CustomerName} (#{invoice.CustomerId})");
                    column.Item().Text($"Terms {invoice.TermsCode ?? "-"} · due "
                        + $"{invoice.DueDate?.ToString("yyyy-MM-dd") ?? "-"}");
                    column.Item().Text($"PO {invoice.PurchaseOrderNumber ?? "-"}");
                    column.Item().Text($"Ship to {invoice.ShipToName ?? "-"} · "
                        + $"{invoice.ShippingMethod ?? "-"}");
                    column.Item().Text(invoice.ShipToAddress ?? "-");
                    if (!string.IsNullOrWhiteSpace(invoice.ShippingInstructions))
                        column.Item().Text(invoice.ShippingInstructions);

                    column.Item().PaddingTop(8).Table(table =>
                    {
                        table.ColumnsDefinition(columns =>
                        {
                            columns.RelativeColumn(3);
                            columns.ConstantColumn(35);
                            columns.ConstantColumn(70);
                            columns.ConstantColumn(65);
                            columns.ConstantColumn(70);
                        });
                        table.Header(header =>
                        {
                            header.Cell().Text("SKU").Bold();
                            header.Cell().AlignRight().Text("Qty").Bold();
                            header.Cell().AlignRight().Text("Unit").Bold();
                            header.Cell().AlignRight().Text("Discount").Bold();
                            header.Cell().AlignRight().Text("Amount").Bold();
                        });
                        foreach (var line in invoice.Lines)
                        {
                            table.Cell().Text(line.Sku);
                            table.Cell().AlignRight().Text(line.Quantity.ToString());
                            table.Cell().AlignRight().Text(line.UnitAmount.ToString("0.0000"));
                            table.Cell().AlignRight().Text(line.DiscountAmount.ToString("0.0000"));
                            table.Cell().AlignRight().Text(line.Amount.ToString("0.0000"));
                        }
                    });

                    column.Item().PaddingTop(8).AlignRight().Column(totals =>
                    {
                        totals.Item().Text($"Subtotal {invoice.TotalSale:0.0000}");
                        totals.Item().Text($"Tax A {invoice.TaxA:0.0000}");
                        totals.Item().Text($"Tax B {invoice.TaxB:0.0000}");
                        totals.Item().Text($"Total {invoice.TotalAmount:0.0000}").Bold();
                        totals.Item().Text($"Paid {invoice.Paid:0.0000}");
                        totals.Item().Text($"Balance {invoice.TotalAmount - invoice.Paid:0.0000}");
                    });
                    column.Item().PaddingTop(16).Text(duplicate ? "DUPLICATE" : "CUSTOMER COPY")
                        .FontSize(8);
                });
            });
        })
        .WithMetadata(new DocumentMetadata
        {
            Title = $"Wholesale invoice {invoice.TxNumber}",
            Author = "xOpti",
            Subject = duplicate ? "Duplicate wholesale invoice" : "Wholesale invoice",
            Creator = "xOpti Wholesale",
            Producer = "QuestPDF",
            CreationDate = invoice.DateOfEntry.UtcDateTime,
        })
        .GeneratePdf();
        return new RenderedDocument(pdf, "application/pdf",
            $"{invoice.TxNumber}{(duplicate ? "-duplicate" : string.Empty)}.pdf");
    }
}
