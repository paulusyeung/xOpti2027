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
    private const string ReportFontFamily = "Liberation Sans";

    private static readonly byte[] OpticalCentreLogo = LoadOpticalCentreLogo();

    static QuestPdfReportRenderer()
    {
        RegisterReportFont("xOpti.Infrastructure.Documents.Assets.LiberationSans-Regular.ttf");
        RegisterReportFont("xOpti.Infrastructure.Documents.Assets.LiberationSans-Bold.ttf");
    }

    private static void RegisterReportFont(string resourceName)
    {
        using var stream = typeof(QuestPdfReportRenderer).Assembly.GetManifestResourceStream(resourceName)
            ?? throw new InvalidOperationException($"Embedded font is missing: {resourceName}");
        QuestPDF.Drawing.FontManager.RegisterFontFromStream(stream);
    }

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
                    page.DefaultTextStyle(style => style.FontFamily(ReportFontFamily).FontSize(7));

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

    public RenderedDocument RenderInvoiceReport(InvoiceReport report, ReportLetterheadDto letterhead)
    {
        _ = new QuestPdfDocumentRenderer(options);

        var pdf = Document.Create(container =>
        {
            container.Page(page =>
            {
                page.Size(PageSizes.Letter);
                page.MarginLeft(54f);
                page.MarginRight(32f);
                page.MarginTop(59f);
                page.MarginBottom(42f);
                page.DefaultTextStyle(style => style.FontFamily(ReportFontFamily).FontSize(8.5f));

                page.Content().Column(column =>
                {
                    // Title block and the legacy Chinese shop logo.
                    column.Item().Row(row =>
                    {
                        row.RelativeItem().Column(title =>
                        {
                            title.Item().Text("Invoice").Bold().FontSize(28);
                            title.Item().PaddingTop(1).Width(168).BorderBottom(1)
                                .Height(1);
                            title.Item().PaddingTop(4).Row(meta =>
                            {
                                meta.ConstantItem(70).Text("Date:").Bold().FontSize(9.5f);
                                meta.RelativeItem().Text(report.DateOfEntry.ToString("MMMM dd, yyyy"))
                                    .FontSize(9.5f);
                            });
                            title.Item().PaddingTop(2).Row(meta =>
                            {
                                meta.ConstantItem(70).Text("Invoice No.:").Bold().FontSize(9.5f);
                                meta.RelativeItem().Text(report.TxNumber).FontSize(9.5f);
                            });
                        });
                        row.ConstantItem(160).Column(logo =>
                        {
                            logo.Item().AlignRight().Width(60).Height(60).Image(OpticalCentreLogo);
                            logo.Item().AlignRight().PaddingRight(2).Text("TM").FontSize(6);
                        });
                    });

                    // Sold To / Ship To.
                    column.Item().PaddingTop(44).Row(row =>
                    {
                        row.RelativeItem().Column(party =>
                        {
                            party.Item().Row(label =>
                            {
                                label.ConstantItem(55).Text("Sold To:").Bold().FontSize(9.5f);
                                label.RelativeItem().AlignMiddle().LineHorizontal(1);
                            });
                            party.Item().PaddingTop(4).PaddingLeft(18)
                                .Text(report.CustomerName).Bold().FontSize(9.5f);
                            party.Item().PaddingTop(42).PaddingLeft(18)
                                .Text(report.CustomerPhone ?? string.Empty).Bold().FontSize(9.5f);
                        });
                        row.ConstantItem(10);
                        row.RelativeItem().Column(party =>
                        {
                            party.Item().Row(label =>
                            {
                                label.ConstantItem(55).Text("Ship To:").Bold().FontSize(9.5f);
                                label.RelativeItem().AlignMiddle().LineHorizontal(1);
                            });
                            party.Item().PaddingTop(4).PaddingLeft(18)
                                .Text(report.CustomerName).Bold().FontSize(9.5f);
                            party.Item().PaddingTop(42).PaddingLeft(18)
                                .Text(report.CustomerPhone ?? string.Empty).Bold().FontSize(9.5f);
                        });
                    });

                    // Order information grid.
                    column.Item()
                    .PaddingTop(20)
                    .BorderTop(0.75f)
                    .BorderLeft(0.75f)
                    .BorderColor(Colors.Black)
                    .Table(table =>
                    {
                        InvoiceColumns(table, 72, 95, 117, 113, 90, 39);

                        InvoiceGridRow(table, new[]
                        {
                            "VIP No.", "Order No.", "Sales Person", "Order Date", "Shipped Date", "Terms",
                        }, bold: true, fontSize: 8.5f, centered: true);

                        InvoiceGridRow(table, new[]
                        {
                            report.VipCode ?? string.Empty,
                            report.OrderNumber ?? string.Empty,
                            report.SalesPerson ?? string.Empty,
                            report.OrderDate is { } ordered ? FormatDate(ordered) : string.Empty,
                            FormatDate(report.DateOfEntry),
                            "C.O.D.",
                        }, centered: true);
                    });

                    // Line items.
                    column.Item()
                    .PaddingTop(20)
                    .BorderTop(0.75f)
                    .BorderColor(Colors.Black)
                    .Table(table =>
                    {
                        InvoiceColumns(table, 61, 29, 79, 35, 192, 33, 55, 42);
                        InvoiceGridRow(table, new[]
                        {
                            "Line No.", "Qty", "SKU Code", "Type", "Description",
                            "Tax", "Unit Price", "Amount",
                        }, bold: true, fontSize: 8.5f, leftBorder: true);
                        foreach (var line in report.Lines)
                        {
                            InvoiceGridRow(table, new[]
                            {
                                line.RowNo.ToString("0.0"),
                                line.Qty.ToString(),
                                line.Sku,
                                string.Empty,
                                line.Description ?? string.Empty,
                                line.TaxCode ?? string.Empty,
                                line.UnitPrice.ToString("0.00"),
                                line.Amount.ToString("0.00"),
                            }, boxed: false, rightAlignLastTwo: true);
                        }
                    });

                    // Payment details and totals.
                    column.Item().PaddingTop(22).Row(row =>
                    {
                        row.RelativeItem().PaddingLeft(4).Border(1).BorderColor(Colors.Black)
                            .Padding(6).Column(payment =>
                            {
                                payment.Item().AlignCenter().Text("THIS PAYMENT DETAILS")
                                    .Bold().FontSize(12);
                                payment.Item().PaddingTop(5).Row(head =>
                                {
                                    head.RelativeItem();
                                    head.ConstantItem(50).AlignRight().Text("Exchange").Bold().FontSize(8);
                                    head.ConstantItem(72).AlignRight().Text("Canadian").Bold().FontSize(8);
                                });
                                payment.Item().Row(head =>
                                {
                                    head.ConstantItem(70).Text("Type").Bold().FontSize(8);
                                    head.ConstantItem(110).Text("CardNumber/Authorization")
                                        .Bold().FontSize(8);
                                    head.RelativeItem().AlignRight().Text("Tender").Bold().FontSize(8);
                                    head.ConstantItem(35).AlignRight().Text("Rate").Bold().FontSize(8);
                                    head.ConstantItem(70).AlignRight().Text("Amounts").Bold().FontSize(8);
                                });
                                payment.Item().BorderBottom(1).BorderColor(Colors.Black).Height(1);
                                foreach (var tender in report.Payments)
                                {
                                    payment.Item().PaddingTop(3).Row(line =>
                                    {
                                        line.ConstantItem(70).Text(tender.Type).FontSize(9.5f);
                                        line.ConstantItem(100)
                                            .Text(tender.CardAuthorization ?? string.Empty).FontSize(9.5f);
                                        line.RelativeItem().AlignRight()
                                            .Text(tender.AmountTender.ToString("0.00")).FontSize(9.5f);
                                        line.ConstantItem(35).AlignRight()
                                            .Text(tender.ExchangeRate.ToString("0.00")).FontSize(9.5f);
                                        line.ConstantItem(70).AlignRight()
                                            .Text(tender.EqAmount.ToString("0.00")).FontSize(9.5f);
                                    });
                                }
                                payment.Item().PaddingTop(4).AlignRight().Width(70)
                                    .BorderBottom(1).BorderColor(Colors.Black);
                                payment.Item().PaddingTop(2).AlignRight().Width(70)
                                    .BorderBottom(1).BorderColor(Colors.Black);
                            });

                        row.ConstantItem(118).Table(table =>
                        {
                            InvoiceColumns(table, 68, 52);
                            InvoiceTotalRow(table, "Net Sales:", InvoiceMoney(report.NetSales),
                                topBorder: true);
                            InvoiceTotalRow(table, report.TaxALabel, InvoiceMoney(report.TaxAAmount));
                            if (report.TaxBLabel.Length > 0)
                                InvoiceTotalRow(table, report.TaxBLabel, InvoiceMoney(report.TaxBAmount));
                            InvoiceTotalRow(table, "Gross Sales:", InvoiceMoney(report.GrossSales));
                            InvoiceTotalRow(table, "Deposit:", InvoiceMoney(report.Deposit));
                            InvoiceTotalRow(table, "Balance:", InvoiceMoney(report.Balance));
                        });
                    });

                });

                // Anchored to the page bottom so its position never depends on
                // how many line items or payments the content area contains.
                page.Footer().Column(footer =>
                {
                    footer.Item().Text(
                        "30 DAYS WARRANTY ON CONTACT LENSES.  90 DAYS WARRANTY ON ALL OTHER "
                        + "PRESCRIPTION ITEMS.").FontSize(9.5f);
                    footer.Item().Text("NO CASH REFUNDS, EXCHANGES WITH RECEIPT ONLY.").FontSize(9.5f);
                    footer.Item().Row(notice =>
                    {
                        notice.RelativeItem().Text($"G.S.T. NO. {letterhead.GstNumber}").FontSize(9.5f);
                        notice.ConstantItem(130).AlignRight().Text(
                            $"{DateTime.Now:MMM dd, yyyy}  {DateTime.Now:hh:mm:ss}AM").FontSize(8);
                    });
                    footer.Item().LineHorizontal(1);
                    footer.Item().Column(identity =>
                    {
                        identity.Item().Text($"{letterhead.ShopName.ToUpperInvariant()}    "
                            + letterhead.LegalName.ToUpperInvariant()).Bold().FontSize(9.5f);
                        identity.Item().PaddingTop(2).Text(letterhead.Address).FontSize(9.5f);
                        identity.Item().Text($"Phone: {letterhead.Phone}       Fax: {letterhead.Fax}")
                            .FontSize(9.5f);
                    });
                });
            });
        })
        .WithMetadata(new DocumentMetadata
        {
            Title = $"Invoice {report.TxNumber}",
            Author = "xOpti",
            Subject = "Invoice",
            Creator = "xOpti Reporting",
            Producer = "QuestPDF",
            CreationDate = DateTime.UtcNow,
        })
        .GeneratePdf();

        return new RenderedDocument(pdf, "application/pdf", $"{report.TxNumber}-invoice.pdf");
    }

    private static void InvoiceGridRow(TableDescriptor table, string[] cells,
        bool bold = false, float fontSize = 8.5f, bool centered = false, bool leftBorder = false)
    {
        foreach (var text in cells)
        {
            var container = table.Cell()
                .BorderBottom(0.75f)          // Bottom line of each cell
                .BorderRight(0.75f)           // Right line of each cell
                .BorderColor(Colors.Black);
            if (leftBorder) container = container.BorderLeft(0.75f).BorderColor(Colors.Black);
            container = container
                .PaddingVertical(3)           // Inner spacing (MUST be after Border)
                .PaddingHorizontal(4)
                .AlignMiddle();
            if (centered) container = container.AlignCenter();
            container.Text(t =>
            {
                var span = t.Span(text).FontSize(fontSize);
                if (bold)
                    span.Bold();
            });
        }
    }

    private static string FormatDate(DateTimeOffset value) => value.ToString("MMMM dd, yyyy");

    private static string InvoiceMoney(decimal value) =>
        value.ToString("#,##0.00", System.Globalization.CultureInfo.InvariantCulture);

    private static void InvoiceColumns(TableDescriptor table, params float[] widths)
    {
        table.ColumnsDefinition(columns =>
        {
            foreach (var width in widths) columns.ConstantColumn(width);
        });
    }

    private static void InvoiceGridRow(TableDescriptor table, IReadOnlyList<string> cells,
        bool bold = false, bool boxed = true, float fontSize = 9.5f,
        bool rightAlignLastTwo = false)
    {
        for (var index = 0; index < cells.Count; index++)
        {
            var container = table.Cell().PaddingHorizontal(4).PaddingVertical(3);
            if (boxed) container = container.Border(0.6f).BorderColor(Colors.Black);
            if (rightAlignLastTwo && index >= cells.Count - 2) container = container.AlignRight();
            var text = container.Text(cells[index]).FontSize(fontSize);
            if (bold) text.Bold();
        }
    }

    private static void InvoiceGridSeparator(TableDescriptor table, int cellCount)
    {
        for (var i = 0; i < cellCount; i++)
            table.Cell().BorderBottom(0.6f).BorderColor(Colors.Black).Height(1);
    }

    private static void InvoiceTotalRow(TableDescriptor table, string label, string amount,
        bool topBorder = false)
    {
        var labelCell = table.Cell().BorderBottom(1).BorderColor(Colors.Black);
        if (topBorder) labelCell = labelCell.BorderTop(1).BorderColor(Colors.Black);
        labelCell.PaddingHorizontal(4).PaddingVertical(3).Text(label).Bold().FontSize(9.5f);

        var valueCell = table.Cell().BorderBottom(1).BorderRight(1).BorderColor(Colors.Black);
        if (topBorder) valueCell = valueCell.BorderTop(1).BorderColor(Colors.Black);
        valueCell.PaddingHorizontal(4).PaddingVertical(3).AlignRight().Text(amount).FontSize(9.5f);
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
                page.DefaultTextStyle(style => style.FontFamily(ReportFontFamily).FontSize(10f));

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
                    .Text(letterhead.ShopName.ToUpperInvariant()).Bold().FontSize(8.5f).LetterSpacing(0.09f);
            });

            column.Item().PaddingTop(11.8f).Row(row =>
            {
                row.ConstantItem(7.5f);
                row.ConstantItem(108.6f).AlignCenter()
                    .Text(label.Sku).Bold().FontSize(9.7f).LetterSpacing(0.37f);
            });

            column.Item().PaddingTop(23f)
                .Element(cell => QuestPdfReportComponents.Barcode(cell, label.Sku));

            column.Item().Row(row =>
            {
                row.ConstantItem(64).Column(left =>
                {
                    left.Item().Text(label.Sku).FontSize(6.1f).LineHeight(0.85f);
                    left.Item().Text(label.ClassName ?? string.Empty).FontSize(6.1f).LineHeight(0.85f);
                    left.Item().Text(label.Model ?? string.Empty).FontSize(6.1f).LineHeight(0.85f);
                    left.Item().Text($"${label.RetailPrice ?? 0m:0.00}").FontSize(6.1f).LineHeight(0.85f);
                });
                row.ConstantItem(63).Column(right =>
                {
                    right.Item().AlignRight().Text(label.Brand ?? string.Empty).FontSize(6.1f).LineHeight(0.85f);
                    right.Item().AlignRight().Text(label.Color ?? string.Empty).FontSize(6.1f).LineHeight(0.85f);
                    right.Item().AlignRight().Text(label.Size ?? string.Empty).FontSize(6.1f).LineHeight(0.85f);
                });
            });
        });
    }
}
