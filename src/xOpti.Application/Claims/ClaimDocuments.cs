using FluentValidation;
using xOpti.Application.Authorization;
using xOpti.Application.Common;
using xOpti.Application.Pipeline;
using xOpti.Application.Ports;
using xOpti.Application.Sales.Documents;

namespace xOpti.Application.Claims;

public sealed record ClaimReceiptLineDto(
    int LineNumber, string Sku, decimal BilledAmount, decimal CoveredAmount,
    decimal PatientAmount, bool Eligible, string? IneligibleReason);

public sealed record ClaimReceiptDto(
    long ClaimId, string ClaimNumber, string InvoiceTxNumber, int CustomerId,
    string? CustomerName, string PlanName, string PayerName, int PlanVersion,
    DateTimeOffset CreatedAt, string Status,
    decimal TotalBilled, decimal CoveredAmount, decimal PatientAmount,
    decimal ApprovedAmount, decimal AdjustmentAmount, decimal PaidAmount,
    IReadOnlyList<ClaimReceiptLineDto> Lines);

public sealed record RbicRowDto(
    string ClaimNumber, string InvoiceTxNumber, int CustomerId, string? CustomerName,
    string PlanCode, string PayerName, int PlanVersion, DateTimeOffset ClaimDate,
    decimal BilledAmount, decimal CoveredAmount, decimal PatientAmount,
    decimal ApprovedAmount, decimal PaidAmount);

public sealed record ClaimReceiptPrintResult(
    string ClaimNumber, bool Duplicate, string FileName, string ContentType, byte[] Content);

public interface IClaimDocumentRenderer
{
    RenderedDocument RenderReceipt(ClaimReceiptDto receipt, bool duplicate);
    byte[] RenderRbic(IReadOnlyList<RbicRowDto> rows, DateOnly from, DateOnly to);
}

public static class ClaimDocumentLayout
{
    public static IReadOnlyList<string> BuildReceipt(ClaimReceiptDto receipt, bool duplicate = false)
    {
        var lines = new List<string>
        {
            "xOpti claim receipt",
            duplicate ? "DUPLICATE CLAIM RECEIPT" : "CUSTOMER COPY",
            $"Claim {receipt.ClaimNumber}",
            $"Invoice {receipt.InvoiceTxNumber}",
            $"Customer {receipt.CustomerName} (#{receipt.CustomerId})",
            $"Plan {receipt.PlanName} · {receipt.PayerName} v{receipt.PlanVersion}",
            $"Status {receipt.Status}",
        };
        foreach (var line in receipt.Lines)
        {
            lines.Add($"{line.Sku} billed {line.BilledAmount:0.0000} covered {line.CoveredAmount:0.0000} patient {line.PatientAmount:0.0000}");
        }
        lines.Add($"Total billed {receipt.TotalBilled:0.0000}");
        lines.Add($"Covered {receipt.CoveredAmount:0.0000}");
        lines.Add($"Patient {receipt.PatientAmount:0.0000}");
        lines.Add($"Approved {receipt.ApprovedAmount:0.0000}");
        lines.Add($"Paid {receipt.PaidAmount:0.0000}");
        return lines;
    }
}

public sealed record GetClaimReceiptQuery(long ClaimId)
    : IQuery<ClaimReceiptDto>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.ReportFinancial };
}

public sealed record GetRbicExportQuery(DateOnly From, DateOnly To)
    : IQuery<IReadOnlyList<RbicRowDto>>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.ReportFinancial };
}

public sealed record PrintClaimReceiptCommand(
    long ClaimId, bool Reprint, string? TerminalCode, string Reason)
    : ICommand<ClaimReceiptPrintResult>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.ReportFinancial };
}

public sealed record RbicExportResult(string FileName, string ContentType, byte[] Content);

public sealed record ExportRbicCommand(DateOnly From, DateOnly To, string Reason)
    : ICommand<RbicExportResult>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.ReportFinancial };
}

public sealed class PrintClaimReceiptCommandValidator : AbstractValidator<PrintClaimReceiptCommand>
{
    public PrintClaimReceiptCommandValidator()
    {
        RuleFor(x => x.ClaimId).GreaterThan(0);
        RuleFor(x => x.TerminalCode).MaximumLength(20);
        RuleFor(x => x.Reason).NotEmpty().MinimumLength(3).MaximumLength(500);
    }
}

public sealed class GetClaimReceiptHandler(IClaimStore store)
    : IRequestHandler<GetClaimReceiptQuery, ClaimReceiptDto>
{
    public async Task<ClaimReceiptDto> Handle(GetClaimReceiptQuery request, CancellationToken ct) =>
        await store.GetReceiptAsync(request.ClaimId, ct)
        ?? throw new ValidationFailedException(new[]
        {
            new ValidationFieldError("ClaimId", "not-found", "Claim was not found."),
        });
}

public sealed class GetRbicExportHandler(IClaimStore store)
    : IRequestHandler<GetRbicExportQuery, IReadOnlyList<RbicRowDto>>
{
    public Task<IReadOnlyList<RbicRowDto>> Handle(
        GetRbicExportQuery request, CancellationToken ct)
    {
        if (request.From > request.To)
            throw new ValidationFailedException(new[]
            {
                new ValidationFieldError("From", "range", "From must not be after To."),
            });
        return store.GetRbicAsync(request.From, request.To, ct);
    }
}

public sealed class PrintClaimReceiptHandler(
    IUnitOfWork unitOfWork, IClaimStore store, IClaimDocumentRenderer renderer,
    IAuditRecorder audit)
    : IRequestHandler<PrintClaimReceiptCommand, ClaimReceiptPrintResult>
{
    public Task<ClaimReceiptPrintResult> Handle(
        PrintClaimReceiptCommand request, CancellationToken ct) =>
        unitOfWork.ExecuteInTransactionAsync(async token =>
        {
            var receipt = await store.GetReceiptAsync(request.ClaimId, token)
                ?? throw new ValidationFailedException(new[]
                {
                    new ValidationFieldError("ClaimId", "not-found", "Claim was not found."),
                });
            var rendered = renderer.RenderReceipt(receipt, request.Reprint);
            var fileName = $"{receipt.ClaimNumber}{(request.Reprint ? "-duplicate" : string.Empty)}.pdf";
            await audit.RecordAsync(new AuditRecord(
                request.Reprint ? "claim.receipt.reprint" : "claim.receipt.print",
                "Claim", receipt.ClaimId.ToString(),
                System.Text.Json.JsonSerializer.Serialize(new
                {
                    request.TerminalCode, request.Reason, duplicate = request.Reprint,
                })), token);
            return new ClaimReceiptPrintResult(receipt.ClaimNumber, request.Reprint,
                fileName, rendered.ContentType, rendered.Content);
        }, ct);
}

public sealed class ExportRbicHandler(
    IUnitOfWork unitOfWork, IClaimStore store, IClaimDocumentRenderer renderer,
    IAuditRecorder audit)
    : IRequestHandler<ExportRbicCommand, RbicExportResult>
{
    public Task<RbicExportResult> Handle(ExportRbicCommand request, CancellationToken ct) =>
        unitOfWork.ExecuteInTransactionAsync(async token =>
        {
            if (request.From > request.To)
                throw new ValidationFailedException(new[]
                {
                    new ValidationFieldError("From", "range", "From must not be after To."),
                });
            var rows = await store.GetRbicAsync(request.From, request.To, token);
            var content = renderer.RenderRbic(rows, request.From, request.To);
            var fileName = $"rbic-{request.From:yyyyMMdd}-{request.To:yyyyMMdd}.csv";
            await audit.RecordAsync(new AuditRecord("claim.rbic.export", "Claim",
                $"{request.From:yyyy-MM-dd}:{request.To:yyyy-MM-dd}",
                System.Text.Json.JsonSerializer.Serialize(new
                {
                    rows = rows.Count, request.Reason,
                })), token);
            return new RbicExportResult(fileName, "text/csv", content);
        }, ct);
}
