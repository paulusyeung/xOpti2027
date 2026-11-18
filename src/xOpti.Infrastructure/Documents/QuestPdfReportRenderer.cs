using QuestPDF.Fluent;
using QuestPDF.Helpers;
using QuestPDF.Infrastructure;
using xOpti.Application.Reporting;
using xOpti.Application.Sales.Documents;
using xOpti.Application.Wholesale;

namespace xOpti.Infrastructure.Documents;

public sealed class QuestPdfReportRenderer(InfrastructureOptions options) : IReportRenderer
{
    public RenderedDocument RenderPackingList(WholesalePackingListDto document, bool duplicate)
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
                    column.Item().Text("xOpti packing list").Bold().FontSize(18);
                    if (duplicate)
                        column.Item().Background(Colors.Red.Lighten3).Padding(3)
                            .Text("DUPLICATE PACKING LIST").Bold();
                    column.Item().PaddingTop(8).Text($"Invoice {document.TxNumber}");
                    column.Item().Text($"Date {document.DateOfEntry:yyyy-MM-dd}");
                    column.Item().Text($"Customer {document.CustomerName} (#{document.CustomerId})");
                    column.Item().Text($"PO {document.PurchaseOrderNumber ?? "-"}");
                    column.Item().Text($"Ship to {document.ShipToName ?? "-"} · "
                        + $"{document.ShippingMethod ?? "-"}");
                    column.Item().Text(document.ShipToAddress ?? "-");
                    if (!string.IsNullOrWhiteSpace(document.ShippingInstructions))
                        column.Item().Text(document.ShippingInstructions);

                    column.Item().PaddingTop(8).Table(table =>
                    {
                        table.ColumnsDefinition(columns =>
                        {
                            columns.RelativeColumn(3);
                            columns.ConstantColumn(45);
                            columns.ConstantColumn(80);
                            if (document.IncludesPrices)
                            {
                                columns.ConstantColumn(70);
                                columns.ConstantColumn(80);
                            }
                        });
                        table.Header(header =>
                        {
                            header.Cell().Text("SKU").Bold();
                            header.Cell().AlignRight().Text("Qty").Bold();
                            header.Cell().AlignRight().Text("Backordered").Bold();
                            if (document.IncludesPrices)
                            {
                                header.Cell().AlignRight().Text("Unit").Bold();
                                header.Cell().AlignRight().Text("Amount").Bold();
                            }
                        });
                        foreach (var line in document.Lines)
                        {
                            table.Cell().Text(line.Sku);
                            table.Cell().AlignRight().Text(line.Quantity.ToString());
                            table.Cell().AlignRight().Text(line.BackorderQuantity.ToString());
                            if (document.IncludesPrices)
                            {
                                table.Cell().AlignRight().Text((line.UnitAmount ?? 0m).ToString("0.0000"));
                                table.Cell().AlignRight().Text((line.Amount ?? 0m).ToString("0.0000"));
                            }
                        }
                    });
                    column.Item().PaddingTop(16).Text(
                        document.IncludesPrices ? "Prices included by approval" : "No prices")
                        .FontSize(8);
                });
            });
        })
        .WithMetadata(new DocumentMetadata
        {
            Title = $"Packing list {document.TxNumber}",
            Author = "xOpti",
            Subject = duplicate ? "Duplicate packing list" : "Packing list",
            Creator = "xOpti Reporting",
            Producer = "QuestPDF",
            CreationDate = document.DateOfEntry.UtcDateTime,
        })
        .GeneratePdf();
        return new RenderedDocument(pdf, "application/pdf",
            $"{document.TxNumber}-packing{(duplicate ? "-duplicate" : string.Empty)}.pdf");
    }

    public RenderedDocument RenderWholesaleStatement(WholesaleStatementDto statement,
        bool duplicate)
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
                    column.Item().Text("xOpti wholesale statement").Bold().FontSize(18);
                    if (duplicate)
                        column.Item().Background(Colors.Red.Lighten3).Padding(3)
                            .Text("DUPLICATE WHOLESALE STATEMENT").Bold();
                    column.Item().PaddingTop(8).Text(
                        $"Customer {statement.CustomerName} (#{statement.CustomerId})");
                    column.Item().Text($"{statement.From:yyyy-MM-dd} to {statement.To:yyyy-MM-dd}");
                    column.Item().Text($"Opening {statement.OpeningBalance:0.0000}");
                    column.Item().Text($"Invoiced {statement.Invoiced:0.0000}");
                    column.Item().Text($"Returned {statement.Returned:0.0000}");
                    column.Item().Text($"Payments {statement.Payments:0.0000}");
                    column.Item().Text($"Closing {statement.ClosingBalance:0.0000}").Bold();
                    column.Item().Text($"Credit limit {statement.CreditLimit:0.0000}"
                        + (statement.OverCreditLimit ? " · over limit" : string.Empty));

                    column.Item().PaddingTop(8).Table(table =>
                    {
                        table.ColumnsDefinition(columns =>
                        {
                            columns.ConstantColumn(80);
                            columns.RelativeColumn(3);
                            columns.ConstantColumn(80);
                            columns.ConstantColumn(90);
                        });
                        table.Header(header =>
                        {
                            header.Cell().Text("Date").Bold();
                            header.Cell().Text("Document").Bold();
                            header.Cell().Text("Type").Bold();
                            header.Cell().AlignRight().Text("Amount").Bold();
                        });
                        foreach (var item in statement.Items)
                        {
                            table.Cell().Text(item.Date.ToString("yyyy-MM-dd"));
                            table.Cell().Text(item.TxNumber);
                            table.Cell().Text(item.DocumentType);
                            table.Cell().AlignRight().Text(item.Amount.ToString("0.0000"));
                        }
                    });
                    column.Item().PaddingTop(16).Text(duplicate ? "DUPLICATE" : "CUSTOMER COPY")
                        .FontSize(8);
                });
            });
        })
        .WithMetadata(new DocumentMetadata
        {
            Title = $"Wholesale statement {statement.CustomerId}",
            Author = "xOpti",
            Subject = duplicate ? "Duplicate wholesale statement" : "Wholesale statement",
            Creator = "xOpti Reporting",
            Producer = "QuestPDF",
            CreationDate = DateTime.UtcNow,
        })
        .GeneratePdf();
        return new RenderedDocument(pdf, "application/pdf",
            $"wholesale-statement-{statement.CustomerId}"
            + $"{(duplicate ? "-duplicate" : string.Empty)}.pdf");
    }
}
