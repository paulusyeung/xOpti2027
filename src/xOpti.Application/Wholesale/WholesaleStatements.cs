using System.Text.Json;
using FluentValidation;
using xOpti.Application.Authorization;
using xOpti.Application.Common;
using xOpti.Application.Pipeline;
using xOpti.Application.Ports;
using xOpti.Application.Reporting;

namespace xOpti.Application.Wholesale;

public sealed record WholesaleBalanceDto(
    int CustomerId, string? CustomerName, decimal Invoiced, decimal Returned,
    decimal Payments, decimal Balance, decimal CreditLimit, bool OverCreditLimit);

public sealed record WholesaleStatementItemDto(
    string DocumentType, string TxNumber, DateOnly Date, decimal Amount, string? Description);

public sealed record WholesaleStatementDto(
    int CustomerId, string? CustomerName, DateOnly From, DateOnly To,
    decimal OpeningBalance, decimal Invoiced, decimal Returned, decimal Payments,
    decimal ClosingBalance, decimal CreditLimit, bool OverCreditLimit,
    IReadOnlyList<WholesaleStatementItemDto> Items);

public sealed record WholesaleStatementRenderDto(WholesaleStatementDto Statement, bool Duplicate);

public sealed record WholesaleStatementPrintResult(
    string FileName, string ContentType, byte[] Content);

public interface IWholesaleStatementStore
{
    Task<WholesaleBalanceDto?> GetBalanceAsync(int customerId, CancellationToken ct);

    Task<WholesaleStatementDto?> GetStatementAsync(
        int customerId, DateOnly from, DateOnly to, CancellationToken ct);
}

public sealed record GetWholesaleBalanceQuery(int CustomerId)
    : IQuery<WholesaleBalanceDto>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions =>
        new[] { PermissionNames.WholesaleInvoicePost };
}

public sealed record GetWholesaleStatementQuery(int CustomerId, DateOnly From, DateOnly To)
    : IQuery<WholesaleStatementDto>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions =>
        new[] { PermissionNames.ReportFinancial };
}

public sealed record GetWholesaleStatementRenderQuery(int CustomerId, DateOnly From, DateOnly To)
    : IQuery<WholesaleStatementRenderDto>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions =>
        new[] { PermissionNames.ReportFinancial };
}

public sealed record PrintWholesaleStatementCommand(
    int CustomerId, DateOnly From, DateOnly To, bool Reprint, string? TerminalCode, string Reason)
    : ICommand<WholesaleStatementPrintResult>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions =>
        new[] { PermissionNames.ReportFinancial };
}

public sealed class PrintWholesaleStatementCommandValidator
    : AbstractValidator<PrintWholesaleStatementCommand>
{
    public PrintWholesaleStatementCommandValidator()
    {
        RuleFor(x => x.CustomerId).GreaterThan(0);
        RuleFor(x => x.Reason).NotEmpty().MinimumLength(3).MaximumLength(500);
    }
}

public sealed class GetWholesaleBalanceHandler(IWholesaleStatementStore store)
    : IRequestHandler<GetWholesaleBalanceQuery, WholesaleBalanceDto>
{
    public async Task<WholesaleBalanceDto> Handle(
        GetWholesaleBalanceQuery request, CancellationToken ct) =>
        await store.GetBalanceAsync(request.CustomerId, ct)
        ?? throw new ValidationFailedException(new[]
        {
            new ValidationFieldError("CustomerId", "not-found",
                "The customer does not have a wholesale account."),
        });
}

public sealed class GetWholesaleStatementHandler(IWholesaleStatementStore store)
    : IRequestHandler<GetWholesaleStatementQuery, WholesaleStatementDto>
{
    public async Task<WholesaleStatementDto> Handle(
        GetWholesaleStatementQuery request, CancellationToken ct)
    {
        if (request.From > request.To)
            throw new ValidationFailedException(new[]
            {
                new ValidationFieldError("From", "range", "From must not be after To."),
            });
        return await store.GetStatementAsync(request.CustomerId, request.From, request.To, ct)
            ?? throw new ValidationFailedException(new[]
            {
                new ValidationFieldError("CustomerId", "not-found",
                    "The customer does not have a wholesale account."),
            });
    }
}

public sealed class GetWholesaleStatementRenderHandler(IWholesaleStatementStore store)
    : IRequestHandler<GetWholesaleStatementRenderQuery, WholesaleStatementRenderDto>
{
    public async Task<WholesaleStatementRenderDto> Handle(
        GetWholesaleStatementRenderQuery request, CancellationToken ct)
    {
        if (request.From > request.To)
            throw new ValidationFailedException(new[]
            {
                new ValidationFieldError("From", "range", "From must not be after To."),
            });
        var statement = await store.GetStatementAsync(request.CustomerId, request.From,
            request.To, ct)
            ?? throw new ValidationFailedException(new[]
            {
                new ValidationFieldError("CustomerId", "not-found",
                    "The customer does not have a wholesale account."),
            });
        return new WholesaleStatementRenderDto(statement, false);
    }
}

public sealed class PrintWholesaleStatementHandler(
    IUnitOfWork unitOfWork, IWholesaleStatementStore store, IReportRenderer renderer,
    IAuditRecorder audit)
    : IRequestHandler<PrintWholesaleStatementCommand, WholesaleStatementPrintResult>
{
    public Task<WholesaleStatementPrintResult> Handle(
        PrintWholesaleStatementCommand request, CancellationToken ct) =>
        unitOfWork.ExecuteInTransactionAsync(async token =>
        {
            if (request.From > request.To)
                throw new ValidationFailedException(new[]
                {
                    new ValidationFieldError("From", "range", "From must not be after To."),
                });
            var statement = await store.GetStatementAsync(request.CustomerId, request.From,
                request.To, token)
                ?? throw new ValidationFailedException(new[]
                {
                    new ValidationFieldError("CustomerId", "not-found",
                        "The customer does not have a wholesale account."),
                });
            var rendered = renderer.RenderWholesaleStatement(statement, request.Reprint);
            var fileName = $"wholesale-statement-{request.CustomerId}-"
                + $"{request.From:yyyyMMdd}-{request.To:yyyyMMdd}"
                + $"{(request.Reprint ? "-duplicate" : string.Empty)}.pdf";
            await audit.RecordAsync(new AuditRecord(
                request.Reprint ? "wholesale.statement.reprint" : "wholesale.statement.print",
                "Customer", request.CustomerId.ToString(), JsonSerializer.Serialize(new
                {
                    request.From,
                    request.To,
                    request.TerminalCode,
                    request.Reason,
                    duplicate = request.Reprint,
                    closing = statement.ClosingBalance,
                })), token);
            return new WholesaleStatementPrintResult(fileName, rendered.ContentType,
                rendered.Content);
        }, ct);
}
