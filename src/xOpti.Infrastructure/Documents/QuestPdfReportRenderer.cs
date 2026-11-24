using QuestPDF.Fluent;
using QuestPDF.Helpers;
using QuestPDF.Infrastructure;
using xOpti.Application.Customers;
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

    public RenderedDocument RenderReport(ReportDocument document)
    {
        _ = new QuestPdfDocumentRenderer(options);
        var pdf = Document.Create(container =>
        {
            container.Page(page =>
            {
                page.Size(PageSizes.A4);
                page.Margin(16, Unit.Millimetre);
                page.DefaultTextStyle(style => style.FontFamily("Lato").FontSize(9));
                QuestPdfReportComponents.PageNumbers(page);
                page.Content().Column(column =>
                {
                    QuestPdfReportComponents.Header(column, document.Entry.Title,
                        document.Entry.LogicalName, document.AsOf, document.Duplicate);
                    if (document.Parameters.Count > 0)
                    {
                        column.Item().PaddingTop(6).Text(string.Join(" · ",
                            document.Parameters.OrderBy(pair => pair.Key)
                                .Where(pair => pair.Value is not null)
                                .Select(pair => $"{pair.Key}={pair.Value}"))).FontSize(8);
                    }
                    QuestPdfReportComponents.DataTable(column, document.Columns, document.Rows);
                    if (document.Truncated)
                        column.Item().PaddingTop(8).Background(Colors.Orange.Lighten3)
                            .Padding(4).Text($"Truncated at {document.AppliedCap} rows; "
                                + "narrow the parameters or export the underlying data.")
                            .Bold();
                    if (document.Stale)
                        column.Item().PaddingTop(4).Text("Stale read model; refresh before relying on this output.")
                            .FontColor(Colors.Red.Darken2).Bold();
                });
            });
        })
        .WithMetadata(new DocumentMetadata
        {
            Title = $"{document.Entry.Id} {document.Entry.LogicalName}",
            Author = "xOpti",
            Subject = document.Entry.Title,
            Creator = "xOpti Reporting",
            Producer = "QuestPDF",
            CreationDate = document.AsOf.UtcDateTime,
        })
        .GeneratePdf();
        return new RenderedDocument(pdf, "application/pdf",
            $"{document.Entry.Id}{(document.Duplicate ? "-duplicate" : string.Empty)}.pdf");
    }


    public RenderedDocument RenderCustomerStatement(CustomerStatementDto statement, bool duplicate)
    {
        _ = new QuestPdfDocumentRenderer(options);
        var pdf = Document.Create(container =>
        {
            container.Page(page =>
            {
                page.Size(PageSizes.A4);
                page.Margin(16, Unit.Millimetre);
                page.DefaultTextStyle(style => style.FontFamily("Lato").FontSize(9));
                QuestPdfReportComponents.PageNumbers(page);
                page.Content().Column(column =>
                {
                    QuestPdfReportComponents.Header(column, "Customer statement",
                        $"Customer #{statement.CustomerId} {statement.CustomerName}", DateTimeOffset.UtcNow,
                        duplicate);
                    column.Item().PaddingTop(4).Text($"{statement.From:yyyy-MM-dd} to {statement.To:yyyy-MM-dd}");
                    column.Item().Text($"Opening {statement.OpeningBalance:0.0000}");
                    column.Item().Text($"Charges {statement.Charges:0.0000}");
                    column.Item().Text($"Payments {statement.Payments:0.0000}");
                    column.Item().Text($"Refunds {statement.Refunds:0.0000}");
                    column.Item().Text($"Closing {statement.ClosingBalance:0.0000}").Bold();
                    column.Item().PaddingTop(8).Table(table =>
                    {
                        table.ColumnsDefinition(columns =>
                        {
                            columns.ConstantColumn(60);
                            columns.RelativeColumn(2);
                            columns.ConstantColumn(50);
                            columns.ConstantColumn(70);
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
                            table.Cell().Text(item.DateOfEntry.UtcDateTime.ToString("yyyy-MM-dd"));
                            table.Cell().Text(item.TxNumber);
                            table.Cell().Text(item.TxType);
                            table.Cell().AlignRight().Text(item.TotalAmount.ToString("0.0000"));
                        }
                    });
                });
            });
        })
        .WithMetadata(new DocumentMetadata
        {
            Title = $"Customer statement {statement.CustomerId}",
            Author = "xOpti",
            Subject = duplicate ? "Duplicate customer statement" : "Customer statement",
            Creator = "xOpti Reporting",
            Producer = "QuestPDF",
            CreationDate = DateTime.UnixEpoch,
        })
        .GeneratePdf();
        return new RenderedDocument(pdf, "application/pdf",
            $"customer-statement-{statement.CustomerId}"
            + $"{(duplicate ? "-duplicate" : string.Empty)}.pdf");
    }

    public RenderedDocument RenderBarCodeTags(BarCodeTagDocument document)
    {
        _ = new QuestPdfDocumentRenderer(options);

        var pages = new List<List<BarCodeTagLabel>>();
        for (var offset = 0; offset < document.Labels.Count; offset += 20)
        {
            // Legacy Crystal fills all 4 x 5 cells left-to-right, top-to-bottom.
            pages.Add(document.Labels.Skip(offset).Take(20).ToList());
        }

        var pdf = Document.Create(container =>
        {
            foreach (var pageLabels in pages)
            {
                container.Page(page =>
                {
                    // Legacy Crystal output: US Letter, 4 x 5 labels, L-to-R rows.
                    page.Size(PageSizes.Letter);
                    page.MarginLeft(34.8f);
                    page.MarginRight(22.8f);
                    page.MarginTop(66f);
                    page.MarginBottom(38.5f);
                    page.DefaultTextStyle(style => style.FontSize(7));

                    page.Content().Table(table =>
                    {
                        table.ColumnsDefinition(columns =>
                        {
                            for (var i = 0; i < 4; i++)
                            {
                                columns.ConstantColumn(138.6f);
                            }
                        });

                        foreach (var label in pageLabels)
                        {
                            table.Cell().Height(137f)
                                .Element(cell => ComposeBarCodeLabel(cell, label));
                        }
                    });
                });
            }
        })
        .WithMetadata(new DocumentMetadata
        {
            Title = $"Bar code tags {document.FromTxNumber}-{document.ToTxNumber}",
            Author = "xOpti",
            Subject = "Bar Code Tag",
            Creator = "xOpti Reporting",
            Producer = "QuestPDF",
            CreationDate = DateTime.UtcNow,
        })
        .GeneratePdf();

        return new RenderedDocument(pdf, "application/pdf",
            $"{document.FromTxNumber}-{document.ToTxNumber}-barcode-tags"
            + $"{(document.Duplicate ? "-duplicate" : string.Empty)}.pdf");
    }

    private static void ComposeBarCodeLabel(IContainer container, BarCodeTagLabel label)
    {
        container.Column(column =>
        {
            column.Item().Row(row =>
            {
                row.ConstantItem(2.2f);
                row.ConstantItem(123f)
                    .Border(1).BorderColor(Colors.Black)
                    .Padding(2)
                    .Border(1).BorderColor(Colors.Black)
                    .Padding(2.5f)
                    .AlignCenter()
                    .Text("THE OPTICAL CENTRE").Bold().FontSize(10.5f);
            });

            column.Item().PaddingTop(6.2f).Row(row =>
            {
                row.ConstantItem(7.5f);
                row.ConstantItem(108.6f).AlignCenter()
                    .Text(label.Sku).Bold().FontSize(12.3f).LetterSpacing(0.11f);
            });

            column.Item().PaddingTop(20.9f)
                .Element(cell => QuestPdfReportComponents.Barcode(cell, label.Sku));

            column.Item().Row(row =>
            {
                row.ConstantItem(64).Column(left =>
                {
                    left.Item().Text(label.Sku).FontSize(7.3f).LineHeight(0.85f);
                    left.Item().Text(label.ClassName ?? string.Empty).FontSize(7.3f).LineHeight(0.85f);
                    left.Item().Text(label.Model ?? string.Empty).FontSize(7.3f).LineHeight(0.85f);
                    left.Item().Text($"${label.RetailPrice ?? 0m:0.00}").FontSize(7.3f).LineHeight(0.85f);
                });
                row.ConstantItem(63).Column(right =>
                {
                    right.Item().AlignRight().Text(label.Brand ?? string.Empty).FontSize(7.3f).LineHeight(0.85f);
                    right.Item().AlignRight().Text(label.Color ?? string.Empty).FontSize(7.3f).LineHeight(0.85f);
                    right.Item().AlignRight().Text(label.Size ?? string.Empty).FontSize(7.3f).LineHeight(0.85f);
                });
            });
        });
    }
}
