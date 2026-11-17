using System.Globalization;
using System.Text;
using QuestPDF.Fluent;
using QuestPDF.Helpers;
using QuestPDF.Infrastructure;
using xOpti.Application.Claims;
using xOpti.Application.Sales.Documents;

namespace xOpti.Infrastructure.Documents;

public sealed class ClaimDocumentRenderer(InfrastructureOptions options) : IClaimDocumentRenderer
{
    public RenderedDocument RenderReceipt(ClaimReceiptDto receipt, bool duplicate)
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
                    column.Item().Text("xOpti claim receipt").Bold().FontSize(18);
                    if (duplicate)
                        column.Item().Background(Colors.Red.Lighten3).Padding(3)
                            .Text("DUPLICATE CLAIM RECEIPT").Bold();
                    column.Item().PaddingTop(8).Text($"Claim {receipt.ClaimNumber}");
                    column.Item().Text($"Invoice {receipt.InvoiceTxNumber}");
                    column.Item().Text($"Customer {receipt.CustomerName} (#{receipt.CustomerId})");
                    column.Item().Text($"Plan {receipt.PlanName} · {receipt.PayerName} v{receipt.PlanVersion}");
                    column.Item().Text($"Status {receipt.Status}");
                    column.Item().PaddingTop(8).Table(table =>
                    {
                        table.ColumnsDefinition(columns =>
                        {
                            columns.RelativeColumn(3);
                            columns.ConstantColumn(80);
                            columns.ConstantColumn(80);
                            columns.ConstantColumn(80);
                        });
                        table.Header(header =>
                        {
                            header.Cell().Text("SKU").Bold();
                            header.Cell().AlignRight().Text("Billed").Bold();
                            header.Cell().AlignRight().Text("Covered").Bold();
                            header.Cell().AlignRight().Text("Patient").Bold();
                        });
                        foreach (var line in receipt.Lines)
                        {
                            table.Cell().Text(line.Sku);
                            table.Cell().AlignRight().Text(line.BilledAmount.ToString("0.0000"));
                            table.Cell().AlignRight().Text(line.CoveredAmount.ToString("0.0000"));
                            table.Cell().AlignRight().Text(line.PatientAmount.ToString("0.0000"));
                        }
                    });
                    column.Item().PaddingTop(8).AlignRight().Column(totals =>
                    {
                        totals.Item().Text($"Billed {receipt.TotalBilled:0.0000}");
                        totals.Item().Text($"Covered {receipt.CoveredAmount:0.0000}");
                        totals.Item().Text($"Patient {receipt.PatientAmount:0.0000}");
                        totals.Item().Text($"Approved {receipt.ApprovedAmount:0.0000}");
                        totals.Item().Text($"Paid {receipt.PaidAmount:0.0000}");
                    });
                    column.Item().PaddingTop(16).Text(duplicate ? "DUPLICATE" : "CUSTOMER COPY")
                        .FontSize(8);
                });
            });
        })
        .WithMetadata(new DocumentMetadata
        {
            Title = $"Claim {receipt.ClaimNumber}", Author = "xOpti",
            Subject = duplicate ? "Duplicate claim receipt" : "Claim receipt",
            Creator = "xOpti Claims", Producer = "QuestPDF",
            CreationDate = receipt.CreatedAt.UtcDateTime,
        })
        .GeneratePdf();
        return new RenderedDocument(pdf, "application/pdf",
            $"{receipt.ClaimNumber}{(duplicate ? "-duplicate" : string.Empty)}.pdf");
    }

    public byte[] RenderRbic(IReadOnlyList<RbicRowDto> rows, DateOnly from, DateOnly to)
    {
        var builder = new StringBuilder();
        builder.AppendLine("claim_number,invoice,customer_id,customer,plan_code,payer,plan_version,claim_date,billed,covered,patient,approved,paid");
        foreach (var row in rows)
        {
            builder.AppendLine(string.Join(',',
                Csv(row.ClaimNumber), Csv(row.InvoiceTxNumber), row.CustomerId.ToString(),
                Csv(row.CustomerName ?? string.Empty), Csv(row.PlanCode), Csv(row.PayerName),
                row.PlanVersion.ToString(), row.ClaimDate.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture),
                row.BilledAmount.ToString("0.0000", CultureInfo.InvariantCulture),
                row.CoveredAmount.ToString("0.0000", CultureInfo.InvariantCulture),
                row.PatientAmount.ToString("0.0000", CultureInfo.InvariantCulture),
                row.ApprovedAmount.ToString("0.0000", CultureInfo.InvariantCulture),
                row.PaidAmount.ToString("0.0000", CultureInfo.InvariantCulture)));
        }
        return Encoding.UTF8.GetBytes(builder.ToString());
    }

    private static string Csv(string value) =>
        value.Contains(',') || value.Contains('"')
            ? $"\"{value.Replace("\"", "\"\"")}\""
            : value;
}
