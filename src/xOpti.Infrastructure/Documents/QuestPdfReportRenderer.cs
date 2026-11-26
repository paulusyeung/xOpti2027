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
    private static readonly byte[] OpticalCentreLogo = LoadOpticalCentreLogo();

    private static byte[] LoadOpticalCentreLogo()
    {
        using var stream = typeof(QuestPdfReportRenderer).Assembly.GetManifestResourceStream(
            "xOpti.Infrastructure.Documents.Assets.optical-centre-logo.png")
            ?? throw new InvalidOperationException("Embedded optical centre logo is missing.");
        using var memory = new MemoryStream();
        stream.CopyTo(memory);
        return memory.ToArray();
    }

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

    public RenderedDocument RenderBarCodeTags(
        BarCodeTagDocument document, ReportLetterheadDto letterhead)
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
                                .Element(cell => ComposeBarCodeLabel(cell, label, letterhead));
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

    public RenderedDocument RenderClaimReceiptReport(
        ClaimReceiptReport report, ReportLetterheadDto letterhead)
    {
        _ = new QuestPdfDocumentRenderer(options);

        var pdf = Document.Create(container =>
        {
            container.Page(page =>
            {
                page.Size(PageSizes.Letter);
                page.MarginLeft(54.8f);
                page.MarginRight(39.6f);
                page.MarginTop(57f);
                page.MarginBottom(45f);
                page.DefaultTextStyle(style => style.FontSize(10f));

                page.Content().Column(column =>
                {
                    // Legacy reserves the left margin for the Chinese shop logo.
                    column.Item().Row(row =>
                    {
                        row.ConstantItem(75f).PaddingLeft(6f).PaddingTop(4f).Column(logo =>
                        {
                            logo.Item().Width(60f).Height(56f).Image(OpticalCentreLogo);
                            logo.Item().PaddingLeft(55f).Text("™").FontSize(8f);
                        });
                        row.RelativeItem().Column(header =>
                        {
                            header.Item().AlignCenter()
                                .Text(letterhead.ShopName.ToUpperInvariant()).Bold().FontSize(13f);
                            header.Item().PaddingTop(2).AlignCenter()
                                .Text(letterhead.LegalName.ToUpperInvariant()).FontSize(10f);
                            header.Item().PaddingTop(6).AlignCenter()
                                .Text(letterhead.Address).FontSize(10f);
                            header.Item().PaddingTop(2).Row(line =>
                            {
                                line.RelativeItem().AlignRight()
                                    .Text($"Phone: {letterhead.Phone}").FontSize(10f);
                                line.ConstantItem(40f);
                                line.RelativeItem().AlignLeft()
                                    .Text($"Fax: {letterhead.Fax}").FontSize(10f);
                            });
                            header.Item().PaddingTop(5).AlignCenter()
                                .Text($"G.S.T. No. {letterhead.GstNumber}").FontSize(10f);
                        });
                    });

                    column.Item().PaddingTop(11).AlignCenter()
                        .Text($"{letterhead.TitleName} - Optical Claims Receipt")
                        .Bold().FontSize(13f);

                    column.Item().PaddingTop(17).Text(
                        "This is to certify that our company has supplied the following "
                        + "optical products or services to:");

                    // The Crystal rule runs between the name and its LAST/FIRST
                    // caption, across the full width of the body.
                    column.Item().PaddingTop(31).Column(names =>
                    {
                        names.Item().Table(table =>
                        {
                            table.ColumnsDefinition(columns =>
                            {
                                columns.ConstantColumn(74f);
                                columns.ConstantColumn(80f);
                                columns.ConstantColumn(133.4f);
                                columns.ConstantColumn(60f);
                                columns.RelativeColumn();
                            });
                            table.Cell();
                            table.Cell().Text(report.LastName).FontSize(10f);
                            table.Cell();
                            table.Cell().Text(report.FirstName).FontSize(10f);
                            table.Cell();
                        });
                        names.Item().LineHorizontal(0.7f);
                        names.Item().PaddingTop(1).Table(table =>
                        {
                            table.ColumnsDefinition(columns =>
                            {
                                columns.ConstantColumn(74f);
                                columns.ConstantColumn(80f);
                                columns.ConstantColumn(133.4f);
                                columns.ConstantColumn(60f);
                                columns.RelativeColumn();
                            });
                            table.Cell();
                            table.Cell().Text("LAST").Bold().FontSize(10f);
                            table.Cell();
                            table.Cell().Text("FIRST").Bold().FontSize(10f);
                            table.Cell();
                        });
                    });

                    column.Item().PaddingTop(15).Text(
                        "who should be reimbursed to the extent of the coverage "
                        + "under their group health plan:");

                    column.Item().PaddingTop(14).AlignCenter()
                        .Text("DESCRIPTION OF MATERIAL AND/OR SERVICES SUPPLIED").FontSize(10f);

                    column.Item().PaddingTop(35).Row(row =>
                    {
                        row.RelativeItem().Text("ITEMS").Bold();
                        row.ConstantItem(100f).AlignRight().Text("PRICE").Bold();
                    });

                    foreach (var group in report.Classes)
                        ClaimReceiptItemRow(column, 14, group.Name, $"${group.Amount:0.00}");

                    ClaimReceiptItemRow(column, 13, "Other", string.Empty);

                    ClaimReceiptTotalRow(column, 40, "DISCOUNT", $"${report.Discount:0.00}");
                    ClaimReceiptTotalRow(column, 15, "TOTAL", $"${report.Total:0.00}");
                    ClaimReceiptTotalRow(column, 14, "DEPOSIT", $"{report.Deposit:0.00}");
                    ClaimReceiptTotalRow(column, 14, "BALANCE", $"${report.Total - report.Deposit:0.00}");

                    column.Item().PaddingTop(60).Text(
                        "INSURANCE COMPANY PLEASE NOTE: If we can be of any further "
                        + "assistance in supplying information required to process any "
                        + "claim, please call the above number.");

                    column.Item().PaddingTop(64).Column(footer =>
                    {
                        footer.Item().Row(row =>
                        {
                            row.ConstantItem(120f).Text("Date items supplied:");
                            row.ConstantItem(106f).Text(report.DateOfEntry.ToString("MMM dd, yyyy"));
                            // row.ConstantItem(12f);
                            row.ConstantItem(100f).Text(
                                string.IsNullOrWhiteSpace(report.StaffCode)
                                    ? $"({report.TxNumber})"
                                    : $"({report.TxNumber}/{report.StaffCode})");
                            row.RelativeItem();
                        });
                        // Single continuous rule that runs to the right edge.
                        footer.Item().PaddingTop(1).PaddingLeft(113).PaddingRight(2.4f)
                            .LineHorizontal(0.8f);
                        footer.Item().PaddingTop(4).PaddingRight(55).AlignRight()
                            .Text("Signature of dispensing optician");
                    });
                });
            });
        })
        .WithMetadata(new DocumentMetadata
        {
            Title = $"Claims receipt {report.TxNumber}",
            Author = "xOpti",
            Subject = "Optical Claims Receipt",
            Creator = "xOpti Reporting",
            Producer = "QuestPDF",
            CreationDate = DateTime.UtcNow,
        })
        .GeneratePdf();

        return new RenderedDocument(pdf, "application/pdf", $"{report.TxNumber}-claims-receipt.pdf");
    }

    private static void ClaimReceiptItemRow(
        ColumnDescriptor column, float topPadding, string label, string amount)
    {
        column.Item().PaddingTop(topPadding).Row(row =>
        {
            row.RelativeItem().Text(label);
            row.ConstantItem(100f).Column(value =>
            {
                value.Item().AlignRight().Text(amount);
                value.Item().LineHorizontal(0.7f);
            });
        });
    }

    private static void ClaimReceiptTotalRow(
        ColumnDescriptor column, float topPadding, string label, string amount)
    {
        column.Item().PaddingTop(topPadding).Row(row =>
        {
            row.RelativeItem();
            row.ConstantItem(55f).AlignRight().Text(label).Bold();
            row.ConstantItem(100f).Column(value =>
            {
                value.Item().AlignRight().Text(amount).Bold();
                value.Item().LineHorizontal(0.7f);
            });
        });
    }

    private static void ComposeBarCodeLabel(
        IContainer container, BarCodeTagLabel label, ReportLetterheadDto letterhead)
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
                    .Text(letterhead.ShopName.ToUpperInvariant()).Bold().FontSize(10.5f);
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
