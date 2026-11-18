using System.Text.Json;
using FluentValidation;
using xOpti.Application.Authorization;
using xOpti.Application.Common;
using xOpti.Application.Pipeline;
using xOpti.Application.Ports;
using xOpti.Application.Reporting;
using xOpti.Application.Sales.Documents;

namespace xOpti.Application.Wholesale;

public sealed record PackingListLineDto(
    int RowNo, string Sku, string? Description, int Quantity, int BackorderQuantity,
    decimal? UnitAmount, decimal? Amount);

public sealed record WholesalePackingListDto(
    string TxNumber, string Status, DateTimeOffset DateOfEntry, int CustomerId,
    string? CustomerName, string? PurchaseOrderNumber, string? ShippingMethod,
    string? ShipToName, string? ShipToAddress, string? ShippingInstructions,
    bool IncludesPrices, IReadOnlyList<PackingListLineDto> Lines);

public sealed record WholesalePackingListPrintResult(
    string TxNumber, bool Duplicate, string FileName, string ContentType, byte[] Content);

public static class WholesalePackingListLayout
{
    public static IReadOnlyList<string> Build(WholesalePackingListDto document,
        bool duplicate = false)
    {
        var lines = new List<string>
        {
            "xOpti packing list",
            duplicate ? "DUPLICATE PACKING LIST" : "CUSTOMER COPY",
            $"Invoice {document.TxNumber}",
            $"Date {document.DateOfEntry:yyyy-MM-dd}",
            $"Customer {document.CustomerName} (#{document.CustomerId})",
            $"PO {document.PurchaseOrderNumber ?? "-"}",
            $"Ship to {document.ShipToName ?? "-"} · {document.ShippingMethod ?? "-"}",
            $"Address {document.ShipToAddress ?? "-"}",
            $"Instructions {document.ShippingInstructions ?? "-"}",
        };
        foreach (var line in document.Lines)
        {
            var row = $"{line.Sku} qty {line.Quantity}";
            if (line.BackorderQuantity > 0)
                row += $" backordered {line.BackorderQuantity}";
            if (document.IncludesPrices)
                row += $" unit {line.UnitAmount ?? 0m:0.0000} amount {line.Amount ?? 0m:0.0000}";
            lines.Add(row);
        }
        lines.Add(document.IncludesPrices ? "Prices included by approval" : "No prices on packing list");
        return lines;
    }
}

public sealed record GetWholesalePackingListQuery(string TxNumber, bool IncludePrices)
    : IQuery<WholesalePackingListDto>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions =>
        new[] { PermissionNames.WholesaleInvoicePost };
}

public sealed record PrintWholesalePackingListCommand(
    string TxNumber, bool IncludePrices, bool Reprint, string? TerminalCode, string Reason)
    : ICommand<WholesalePackingListPrintResult>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions =>
        new[] { PermissionNames.WholesaleInvoicePost };
}

public sealed class PrintWholesalePackingListCommandValidator
    : AbstractValidator<PrintWholesalePackingListCommand>
{
    public PrintWholesalePackingListCommandValidator()
    {
        RuleFor(x => x.TxNumber).NotEmpty().MaximumLength(10);
        RuleFor(x => x.TerminalCode).MaximumLength(20);
        RuleFor(x => x.Reason).NotEmpty().MinimumLength(3).MaximumLength(500);
    }
}

internal static class WholesalePackingListProjection
{
    public static async Task<WholesalePackingListDto> BuildAsync(
        string txNumber, bool includePrices, IWholesaleInvoiceStore store,
        ICurrentPrincipal principal, CancellationToken ct)
    {
        var invoice = await store.GetAsync(txNumber, ct)
            ?? throw new ValidationFailedException(new[]
            {
                new ValidationFieldError("TxNumber", "not-found",
                    "Wholesale invoice was not found."),
            });
        if (invoice.Status != "posted")
            throw new ValidationFailedException(new[]
            {
                new ValidationFieldError("TxNumber", "not-approved",
                    "A packing list requires a posted wholesale invoice."),
            });
        if (includePrices && !principal.HasPermission(PermissionNames.ReportFinancial))
            throw new ValidationFailedException(new[]
            {
                new ValidationFieldError("IncludePrices", "price-visibility",
                    "Including prices on a packing list requires financial reporting permission."),
            });

        return new WholesalePackingListDto(invoice.TxNumber, invoice.Status,
            invoice.DateOfEntry, invoice.CustomerId, invoice.CustomerName,
            invoice.PurchaseOrderNumber, invoice.ShippingMethod, invoice.ShipToName,
            invoice.ShipToAddress, invoice.ShippingInstructions, includePrices,
            invoice.Lines.Select(line => new PackingListLineDto(line.RowNo, line.Sku,
                line.Description, line.Quantity, line.BackorderQuantity,
                includePrices ? line.UnitAmount : null,
                includePrices ? line.Amount : null)).ToList());
    }
}

public sealed class GetWholesalePackingListHandler(
    IWholesaleInvoiceStore store, ICurrentPrincipal principal)
    : IRequestHandler<GetWholesalePackingListQuery, WholesalePackingListDto>
{
    public Task<WholesalePackingListDto> Handle(
        GetWholesalePackingListQuery request, CancellationToken ct) =>
        WholesalePackingListProjection.BuildAsync(request.TxNumber, request.IncludePrices,
            store, principal, ct);
}

public sealed class PrintWholesalePackingListHandler(
    IUnitOfWork unitOfWork, IWholesaleInvoiceStore store, IReportRenderer renderer,
    IAuditRecorder audit, ICurrentPrincipal principal)
    : IRequestHandler<PrintWholesalePackingListCommand, WholesalePackingListPrintResult>
{
    public Task<WholesalePackingListPrintResult> Handle(
        PrintWholesalePackingListCommand request, CancellationToken ct) =>
        unitOfWork.ExecuteInTransactionAsync(async token =>
        {
            var document = await WholesalePackingListProjection.BuildAsync(
                request.TxNumber, request.IncludePrices, store, principal, token);
            var rendered = renderer.RenderPackingList(document, request.Reprint);
            var fileName = $"{document.TxNumber}-packing"
                + $"{(request.Reprint ? "-duplicate" : string.Empty)}.pdf";
            await audit.RecordAsync(new AuditRecord(
                request.Reprint ? "wholesale.packing-list.reprint" : "wholesale.packing-list.print",
                "TxHeader", document.TxNumber, JsonSerializer.Serialize(new
                {
                    request.TerminalCode,
                    request.Reason,
                    request.IncludePrices,
                    duplicate = request.Reprint,
                    document.Lines.Count,
                })), token);
            return new WholesalePackingListPrintResult(document.TxNumber, request.Reprint,
                fileName, rendered.ContentType, rendered.Content);
        }, ct);
}
