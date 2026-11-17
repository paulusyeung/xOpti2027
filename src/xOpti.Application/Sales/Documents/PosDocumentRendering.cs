using System.Text.Json.Serialization;
using FluentValidation;
using xOpti.Application.Authorization;
using xOpti.Application.Common;
using xOpti.Application.Pipeline;
using xOpti.Application.Ports;

namespace xOpti.Application.Sales.Documents;

public sealed record PosRenderLine(
    int RowNo, string Sku, string? Name, int Qty, decimal UnitAmount, decimal DiscountAmount,
    decimal Amount, string? TaxCode);

public sealed record PosRenderTender(
    double PaymentLineNo, string Type, decimal AmountTender, decimal AppliedAmount,
    string? Reference);

public sealed record PosDocumentRenderDto(
    string TxNumber, string DocumentType, string Title, bool Duplicate,
    DateTimeOffset DateOfEntry, int CustomerId, string? CustomerName, string? StaffCode,
    string? OriginalTxNumber, string? Status,
    decimal Subtotal, decimal TaxA, decimal TaxB, decimal Total, decimal Change, decimal Paid,
    IReadOnlyList<PosRenderLine> Lines, IReadOnlyList<PosRenderTender> Tenders,
    IReadOnlyList<string> Barcodes, IReadOnlyList<string>? OpticalLines = null);

public sealed record RenderedDocument(byte[] Content, string ContentType, string FileName);

/// <summary>
/// Application boundary for printing posted POS documents. Layouts are
/// deterministic for a given document so golden tests can pin them.
/// </summary>
public interface IPosDocumentRenderer
{
    RenderedDocument Render(PosDocumentRenderDto document, string format);
}

public sealed record GetPosDocumentRenderQuery(string TxNumber, bool Duplicate)
    : IQuery<PosDocumentRenderDto>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.SalesInvoicePost };
}

public sealed class GetPosDocumentRenderHandler(ISalesDocumentStore store)
    : IRequestHandler<GetPosDocumentRenderQuery, PosDocumentRenderDto>
{
    public async Task<PosDocumentRenderDto> Handle(
        GetPosDocumentRenderQuery request, CancellationToken ct)
    {
        var document = await store.GetRenderAsync(request.TxNumber, ct)
            ?? throw new ValidationFailedException(new[]
            {
                new ValidationFieldError("TxNumber", "not-found", "Sales document was not found."),
            });
        return document with { Duplicate = request.Duplicate };
    }
}

public sealed record PrintPosDocumentCommand(
    string TxNumber, bool Reprint, string Format, string? TerminalCode, string Reason)
    : ICommand<PosDocumentPrintResult>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.SalesInvoicePost };
}

public sealed record PosDocumentPrintResult(
    string TxNumber, bool Duplicate, string FileName, string ContentType,
    [property: JsonIgnore] byte[] Content);

public sealed class PrintPosDocumentCommandValidator : AbstractValidator<PrintPosDocumentCommand>
{
    public PrintPosDocumentCommandValidator()
    {
        RuleFor(x => x.TxNumber).NotEmpty().MaximumLength(10);
        RuleFor(x => x.Format).Must(format =>
                format is "receipt" or "invoice" or "order")
            .WithMessage("Approved format must be receipt, invoice, or order; claim layouts are not approved yet.");
        RuleFor(x => x.TerminalCode).MaximumLength(20);
        RuleFor(x => x.Reason).NotEmpty().MinimumLength(3).MaximumLength(500);
    }
}

public sealed class PrintPosDocumentHandler(
    IUnitOfWork unitOfWork, ISalesDocumentStore store, IPosDocumentRenderer renderer,
    IAuditRecorder audit)
    : IRequestHandler<PrintPosDocumentCommand, PosDocumentPrintResult>
{
    public Task<PosDocumentPrintResult> Handle(
        PrintPosDocumentCommand request, CancellationToken ct) =>
        unitOfWork.ExecuteInTransactionAsync(async token =>
        {
            var document = await store.GetRenderAsync(request.TxNumber, token)
                ?? throw new ValidationFailedException(new[]
                {
                    new ValidationFieldError("TxNumber", "not-found", "Sales document was not found."),
                });
            var rendered = renderer.Render(document with { Duplicate = request.Reprint }, request.Format);
            var fileName = $"{document.TxNumber}{(request.Reprint ? "-duplicate" : string.Empty)}.pdf";
            await audit.RecordAsync(new AuditRecord(
                request.Reprint ? "document.reprint" : "document.print",
                "TxHeader", document.TxNumber,
                System.Text.Json.JsonSerializer.Serialize(new
                {
                    format = request.Format,
                    terminal = request.TerminalCode,
                    duplicate = request.Reprint,
                    reason = request.Reason,
                })), token);
            return new PosDocumentPrintResult(document.TxNumber, request.Reprint,
                fileName, rendered.ContentType, rendered.Content);
        }, ct);
}
