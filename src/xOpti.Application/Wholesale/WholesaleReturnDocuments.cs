using System.Text.Json;
using FluentValidation;
using xOpti.Application.Authorization;
using xOpti.Application.Common;
using xOpti.Application.Pipeline;
using xOpti.Application.Ports;
using xOpti.Application.Sales.Documents;

namespace xOpti.Application.Wholesale;

public sealed record WholesaleReturnRenderDto(WholesaleReturnDto Return, bool Duplicate);

public sealed record WholesaleReturnPrintResult(
    string TxNumber, bool Duplicate, string FileName, string ContentType, byte[] Content);

public interface IWholesaleReturnDocumentRenderer
{
    RenderedDocument Render(WholesaleReturnDto document, bool duplicate);
}

public static class WholesaleReturnDocumentLayout
{
    public static IReadOnlyList<string> Build(WholesaleReturnDto document, bool duplicate = false)
    {
        var lines = new List<string>
        {
            "xOpti wholesale return",
            duplicate ? "DUPLICATE WHOLESALE RETURN" : "CUSTOMER COPY",
            $"Return {document.TxNumber}",
            $"Original invoice {document.OriginalInvoiceNumber}",
            $"Date {document.DateOfEntry:yyyy-MM-dd}",
            $"Status {document.Status}",
            $"Customer {document.CustomerName} (#{document.CustomerId})",
        };
        foreach (var line in document.Lines)
        {
            lines.Add($"{line.Sku} line {line.OriginalRowNo} qty {line.Quantity}"
                + $" amount {line.Amount:0.0000} tax {line.TaxA:0.0000}/{line.TaxB:0.0000}"
                + $" disposition {(line.Restock ? "restock" : "write-off")}"
                + (line.DispositionReason is null ? string.Empty : $" ({line.DispositionReason})"));
        }
        lines.Add($"Credit {document.TotalAmount:0.0000}");
        lines.Add($"Refunded {document.Refunded:0.0000}");
        return lines;
    }
}

public sealed record GetWholesaleReturnRenderQuery(string TxNumber)
    : IQuery<WholesaleReturnRenderDto>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions =>
        new[] { PermissionNames.WholesaleInvoicePost };
}

public sealed record PrintWholesaleReturnCommand(
    string TxNumber, bool Reprint, string? TerminalCode, string Reason)
    : ICommand<WholesaleReturnPrintResult>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions =>
        new[] { PermissionNames.WholesaleInvoicePost };
}

public sealed class PrintWholesaleReturnCommandValidator
    : AbstractValidator<PrintWholesaleReturnCommand>
{
    public PrintWholesaleReturnCommandValidator()
    {
        RuleFor(x => x.TxNumber).NotEmpty().MaximumLength(10);
        RuleFor(x => x.TerminalCode).MaximumLength(20);
        RuleFor(x => x.Reason).NotEmpty().MinimumLength(3).MaximumLength(500);
    }
}

public sealed class GetWholesaleReturnRenderHandler(IWholesaleReturnStore store)
    : IRequestHandler<GetWholesaleReturnRenderQuery, WholesaleReturnRenderDto>
{
    public async Task<WholesaleReturnRenderDto> Handle(
        GetWholesaleReturnRenderQuery request, CancellationToken ct) =>
        new(await store.GetAsync(request.TxNumber, ct)
            ?? throw WholesaleReturnPreparation.Validation(
                "TxNumber", "not-found", "Wholesale return was not found."),
            false);
}

public sealed class PrintWholesaleReturnHandler(
    IUnitOfWork unitOfWork, IWholesaleReturnStore store,
    IWholesaleReturnDocumentRenderer renderer, IAuditRecorder audit)
    : IRequestHandler<PrintWholesaleReturnCommand, WholesaleReturnPrintResult>
{
    public Task<WholesaleReturnPrintResult> Handle(
        PrintWholesaleReturnCommand request, CancellationToken ct) =>
        unitOfWork.ExecuteInTransactionAsync(async token =>
        {
            var document = await store.GetAsync(request.TxNumber, token)
                ?? throw WholesaleReturnPreparation.Validation(
                    "TxNumber", "not-found", "Wholesale return was not found.");
            if (document.Status != "posted")
                throw WholesaleReturnPreparation.Validation(
                    "TxNumber", "not-posted", "Only posted wholesale returns can be printed.");

            var rendered = renderer.Render(document, request.Reprint);
            var fileName = $"{document.TxNumber}{(request.Reprint ? "-duplicate" : string.Empty)}.pdf";
            await audit.RecordAsync(new AuditRecord(
                request.Reprint ? "wholesale.return.reprint" : "wholesale.return.print",
                "TxHeader", document.TxNumber, JsonSerializer.Serialize(new
                {
                    request.TerminalCode,
                    request.Reason,
                    duplicate = request.Reprint,
                    credit = document.TotalAmount,
                })), token);
            return new WholesaleReturnPrintResult(document.TxNumber, request.Reprint,
                fileName, rendered.ContentType, rendered.Content);
        }, ct);
}
