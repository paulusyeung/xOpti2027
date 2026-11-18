using System.Text.Json;
using FluentValidation;
using xOpti.Application.Authorization;
using xOpti.Application.Common;
using xOpti.Application.Pipeline;
using xOpti.Application.Ports;
using xOpti.Application.Sales.Documents;

namespace xOpti.Application.Wholesale;

public sealed record WholesaleInvoiceRenderDto(
    WholesaleInvoiceDto Invoice, bool Duplicate);

public sealed record WholesaleInvoicePrintResult(
    string TxNumber, bool Duplicate, string FileName, string ContentType, byte[] Content);

public interface IWholesaleInvoiceDocumentRenderer
{
    RenderedDocument Render(WholesaleInvoiceDto invoice, bool duplicate);
}

public static class WholesaleInvoiceDocumentLayout
{
    public static IReadOnlyList<string> Build(WholesaleInvoiceDto invoice, bool duplicate = false)
    {
        var lines = new List<string>
        {
            "xOpti wholesale invoice",
            duplicate ? "DUPLICATE WHOLESALE INVOICE" : "CUSTOMER COPY",
            $"Invoice {invoice.TxNumber}",
            $"Date {invoice.DateOfEntry:yyyy-MM-dd}",
            $"Status {invoice.Status}",
            $"Customer {invoice.CustomerName} (#{invoice.CustomerId})",
            $"Terms {invoice.TermsCode ?? "-"} · due {invoice.DueDate?.ToString("yyyy-MM-dd") ?? "-"}",
            $"PO {invoice.PurchaseOrderNumber ?? "-"}",
            $"Ship to {invoice.ShipToName ?? "-"} · {invoice.ShippingMethod ?? "-"}",
            $"Address {invoice.ShipToAddress ?? "-"}",
            $"Instructions {invoice.ShippingInstructions ?? "-"}",
        };
        foreach (var line in invoice.Lines)
        {
            lines.Add($"{line.Sku} qty {line.Quantity} @ {line.UnitAmount:0.0000}"
                + $" discount {line.DiscountAmount:0.0000} amount {line.Amount:0.0000}"
                + $" tax {line.TaxCode ?? "-"}");
        }
        lines.Add($"Subtotal {invoice.TotalSale:0.0000}");
        lines.Add($"Tax A {invoice.TaxA:0.0000}");
        lines.Add($"Tax B {invoice.TaxB:0.0000}");
        lines.Add($"Total {invoice.TotalAmount:0.0000}");
        lines.Add($"Paid {invoice.Paid:0.0000}");
        lines.Add($"Balance {(invoice.TotalAmount - invoice.Paid):0.0000}");
        foreach (var tender in invoice.Tenders)
            lines.Add($"Tender {tender.Method} {tender.Amount:0.0000}");
        return lines;
    }
}

public sealed record GetWholesaleInvoiceRenderQuery(string TxNumber)
    : IQuery<WholesaleInvoiceRenderDto>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions =>
        new[] { PermissionNames.WholesaleInvoicePost };
}

public sealed record GetWholesaleBackordersQuery(string TxNumber)
    : IQuery<IReadOnlyList<WholesaleBackorderDto>>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions =>
        new[] { PermissionNames.WholesaleInvoicePost };
}

public sealed class GetWholesaleBackordersHandler(IWholesaleInvoiceStore store)
    : IRequestHandler<GetWholesaleBackordersQuery, IReadOnlyList<WholesaleBackorderDto>>
{
    public Task<IReadOnlyList<WholesaleBackorderDto>> Handle(
        GetWholesaleBackordersQuery request, CancellationToken ct) =>
        store.GetBackordersAsync(request.TxNumber, ct);
}

public sealed record PrintWholesaleInvoiceCommand(
    string TxNumber, bool Reprint, string? TerminalCode, string Reason)
    : ICommand<WholesaleInvoicePrintResult>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions =>
        new[] { PermissionNames.WholesaleInvoicePost };
}

public sealed class PrintWholesaleInvoiceCommandValidator
    : AbstractValidator<PrintWholesaleInvoiceCommand>
{
    public PrintWholesaleInvoiceCommandValidator()
    {
        RuleFor(x => x.TxNumber).NotEmpty().MaximumLength(10);
        RuleFor(x => x.TerminalCode).MaximumLength(20);
        RuleFor(x => x.Reason).NotEmpty().MinimumLength(3).MaximumLength(500);
    }
}

public sealed class GetWholesaleInvoiceRenderHandler(IWholesaleInvoiceStore store)
    : IRequestHandler<GetWholesaleInvoiceRenderQuery, WholesaleInvoiceRenderDto>
{
    public async Task<WholesaleInvoiceRenderDto> Handle(
        GetWholesaleInvoiceRenderQuery request, CancellationToken ct) =>
        new(await store.GetAsync(request.TxNumber, ct)
            ?? throw WholesaleInvoicePreparation.Validation(
                "TxNumber", "not-found", "Wholesale invoice was not found."),
            false);
}

public sealed class PrintWholesaleInvoiceHandler(
    IUnitOfWork unitOfWork, IWholesaleInvoiceStore store,
    IWholesaleInvoiceDocumentRenderer renderer, IAuditRecorder audit)
    : IRequestHandler<PrintWholesaleInvoiceCommand, WholesaleInvoicePrintResult>
{
    public Task<WholesaleInvoicePrintResult> Handle(
        PrintWholesaleInvoiceCommand request, CancellationToken ct) =>
        unitOfWork.ExecuteInTransactionAsync(async token =>
        {
            var invoice = await store.GetAsync(request.TxNumber, token)
                ?? throw WholesaleInvoicePreparation.Validation(
                    "TxNumber", "not-found", "Wholesale invoice was not found.");
            if (invoice.Status != "posted")
                throw WholesaleInvoicePreparation.Validation(
                    "TxNumber", "not-posted", "Only posted wholesale invoices can be printed.");

            var rendered = renderer.Render(invoice, request.Reprint);
            var fileName = $"{invoice.TxNumber}{(request.Reprint ? "-duplicate" : string.Empty)}.pdf";
            await audit.RecordAsync(new AuditRecord(
                request.Reprint ? "wholesale.invoice.reprint" : "wholesale.invoice.print",
                "TxHeader", invoice.TxNumber, JsonSerializer.Serialize(new
                {
                    request.TerminalCode,
                    request.Reason,
                    duplicate = request.Reprint,
                    total = invoice.TotalAmount,
                })), token);
            return new WholesaleInvoicePrintResult(invoice.TxNumber, request.Reprint,
                fileName, rendered.ContentType, rendered.Content);
        }, ct);
}
