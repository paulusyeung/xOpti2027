using System.Text.Json;
using FluentValidation;
using xOpti.Application.Authorization;
using xOpti.Application.Common;
using xOpti.Application.Pipeline;
using xOpti.Application.Ports;

namespace xOpti.Application.Cash;

public sealed record CashSessionDto(
    long Id, string BranchCode, string TerminalCode, DateOnly BusinessDate, string Status,
    DateTimeOffset OpenedAt, string? OpenedBy, decimal OpeningFloat, decimal ExpectedCash,
    DateTimeOffset? SuspendedAt, DateTimeOffset? ClosedAt, string? ClosedBy,
    decimal? CountedCash, decimal? Variance, string? VarianceReason);

public sealed record CashMovementDto(
    long Id, string Kind, decimal Amount, string Reason, DateTimeOffset OccurredAt,
    string? Actor, string? DestinationReference);

public sealed record CashCountDto(
    long Id, string Kind, decimal Amount, DateTimeOffset CountedAt, string? CountedBy,
    decimal? Variance, string? Reason);

public sealed record CashSessionDetailDto(
    CashSessionDto Session, IReadOnlyList<CashCountDto> Counts,
    IReadOnlyList<CashMovementDto> Movements);

public sealed record CashCountContextDto(
    long SessionId, decimal OpeningFloat, decimal? ExpectedCash, bool Blind,
    IReadOnlyList<CashCountDto> Counts, IReadOnlyList<CashMovementDto> Movements);

public sealed record CashJournalTenderDto(string Method, decimal Applied);

public sealed record CashJournalDocumentDto(
    string TxNumber, string TxType, decimal TotalSale, decimal TaxA, decimal TaxB,
    decimal TotalAmount, IReadOnlyList<CashJournalTenderDto> Tenders);

public sealed record CashJournalDto(
    string BranchCode, DateOnly BusinessDate, string Status, DateTimeOffset? FinalizedAt,
    string? FinalizedBy, string? Reason,
    decimal TotalSales, decimal TotalRefunds, decimal TaxA, decimal TaxB,
    decimal CashTenders, decimal CardTenders, decimal OtherTenders,
    decimal PaidIn, decimal PaidOut, decimal Pickups, decimal Deposits,
    decimal ExpectedCash, decimal CountedCash, decimal Variance,
    IReadOnlyList<CashSessionDto> Sessions,
    IReadOnlyList<CashJournalDocumentDto> Documents,
    IReadOnlyList<CashMovementDto> Movements);

public interface ICashStore
{
    Task<bool> BranchExistsAsync(string branchCode, CancellationToken ct);
    Task<CashSessionDto?> SessionAsync(long id, CancellationToken ct);
    Task<CashSessionDetailDto?> SessionDetailAsync(long id, CancellationToken ct);
    Task<IReadOnlyList<CashSessionDto>> SessionsAsync(
        string branchCode, DateOnly businessDate, CancellationToken ct);
    Task<IReadOnlyList<CashSessionDto>> OpenSessionsAsync(string branchCode, CancellationToken ct);
    Task<decimal> ExpectedCashAsync(long sessionId, CancellationToken ct);
    Task<long> OpenSessionAsync(string branchCode, string terminalCode, DateOnly businessDate,
        decimal openingFloat, string? actor, CancellationToken ct);
    Task SuspendAsync(long sessionId, string? actor, CancellationToken ct);
    Task ResumeAsync(long sessionId, string? actor, CancellationToken ct);
    Task CloseAsync(long sessionId, decimal countedCash, decimal expectedCash, decimal variance,
        string? varianceReason, string? actor, CancellationToken ct);
    Task RecordCountAsync(long sessionId, string kind, decimal amount, decimal variance,
        string? reason, string? actor, CancellationToken ct);
    Task RecordMovementAsync(long sessionId, string kind, decimal amount, string reason,
        string? destinationReference, string? actor, CancellationToken ct);
    Task<CashJournalDto> JournalAsync(string branchCode, DateOnly businessDate, CancellationToken ct);
    Task<CashJournalDto> FinalizeDailyCloseAsync(
        string branchCode, DateOnly businessDate, string reason, string? actor, CancellationToken ct);
}

public static class CashKinds
{
    public static readonly IReadOnlyList<string> MovementKinds =
        new[] { "paid-in", "paid-out", "pickup", "deposit" };
    public static readonly IReadOnlyList<string> CountKinds =
        new[] { "opening", "interim", "closing" };
}

public sealed record OpenCashSessionCommand(
    string BranchCode, string TerminalCode, decimal OpeningFloat, string Reason)
    : ICommand<CashSessionDto>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.SalesInvoicePost };
}

public sealed record SuspendCashSessionCommand(long SessionId, string Reason)
    : ICommand<CashSessionDto>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.SalesInvoicePost };
}

public sealed record ResumeCashSessionCommand(long SessionId, string Reason)
    : ICommand<CashSessionDto>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.SalesInvoicePost };
}

public sealed record CloseCashSessionCommand(
    long SessionId, decimal CountedCash, string? VarianceReason, string Reason)
    : ICommand<CashSessionDto>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.SalesInvoicePost };
}

public sealed record RecordCashCountCommand(
    long SessionId, string Kind, decimal Amount, string? Reason)
    : ICommand<CashSessionDetailDto>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.SalesInvoicePost };
}

public sealed record RecordCashMovementCommand(
    long SessionId, string Kind, decimal Amount, string Reason, string? DestinationReference)
    : ICommand<CashSessionDetailDto>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.SalesInvoicePost };
}

public sealed record GetCashCountContextQuery(long SessionId)
    : IQuery<CashCountContextDto>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.SalesInvoicePost };
}

public sealed record ListOpenCashSessionsQuery(string BranchCode)
    : IQuery<IReadOnlyList<CashSessionDto>>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.SalesInvoicePost };
}

public sealed record ListCashSessionsQuery(string BranchCode, DateOnly BusinessDate)
    : IQuery<IReadOnlyList<CashSessionDto>>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.SalesInvoicePost };
}

public sealed record GetCashSessionQuery(long SessionId)
    : IQuery<CashSessionDetailDto>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.SalesInvoicePost };
}

public sealed record GetCashJournalQuery(string BranchCode, DateOnly BusinessDate)
    : IQuery<CashJournalDto>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.ReportFinancial };
}

public sealed record FinalizeDailyCloseCommand(
    string BranchCode, DateOnly BusinessDate, string Reason)
    : ICommand<CashJournalDto>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.ReportFinancial };
}

public sealed class OpenCashSessionCommandValidator : AbstractValidator<OpenCashSessionCommand>
{
    public OpenCashSessionCommandValidator()
    {
        RuleFor(x => x.BranchCode).NotEmpty().MaximumLength(3);
        RuleFor(x => x.TerminalCode).NotEmpty().MaximumLength(20);
        RuleFor(x => x.OpeningFloat).GreaterThanOrEqualTo(0);
        RuleFor(x => x.Reason).NotEmpty().MinimumLength(3).MaximumLength(500);
    }
}

public sealed class CloseCashSessionCommandValidator : AbstractValidator<CloseCashSessionCommand>
{
    public CloseCashSessionCommandValidator()
    {
        RuleFor(x => x.SessionId).GreaterThan(0);
        RuleFor(x => x.CountedCash).GreaterThanOrEqualTo(0);
        RuleFor(x => x.Reason).NotEmpty().MinimumLength(3).MaximumLength(500);
    }
}

public sealed class CashCountCommandValidator : AbstractValidator<RecordCashCountCommand>
{
    public CashCountCommandValidator()
    {
        RuleFor(x => x.SessionId).GreaterThan(0);
        RuleFor(x => x.Amount).GreaterThanOrEqualTo(0);
        RuleFor(x => x.Kind).Must(CashKinds.CountKinds.Contains)
            .WithMessage("Count kind must be opening, interim, or closing.");
        RuleFor(x => x.Reason).MaximumLength(500);
    }
}

public sealed class CashMovementCommandValidator : AbstractValidator<RecordCashMovementCommand>
{
    public CashMovementCommandValidator()
    {
        RuleFor(x => x.SessionId).GreaterThan(0);
        RuleFor(x => x.Amount).GreaterThan(0);
        RuleFor(x => x.Kind).Must(CashKinds.MovementKinds.Contains)
            .WithMessage("Movement kind must be paid-in, paid-out, pickup, or deposit.");
        RuleFor(x => x.Reason).NotEmpty().MinimumLength(3).MaximumLength(500);
        RuleFor(x => x.DestinationReference).MaximumLength(128);
    }
}

public sealed class OpenCashSessionHandler(
    IUnitOfWork unitOfWork, ICashStore store, IAuditRecorder audit, IClock clock,
    ICurrentPrincipal principal)
    : IRequestHandler<OpenCashSessionCommand, CashSessionDto>
{
    public Task<CashSessionDto> Handle(OpenCashSessionCommand request, CancellationToken ct) =>
        unitOfWork.ExecuteInTransactionAsync(async token =>
        {
            if (!await store.BranchExistsAsync(request.BranchCode, token))
                throw Validation("BranchCode", "not-found", "Branch was not found.");
            var id = await store.OpenSessionAsync(request.BranchCode, request.TerminalCode,
                DateOnly.FromDateTime(clock.UtcNow.UtcDateTime), request.OpeningFloat,
                principal.UserId, token);
            await audit.RecordAsync(new AuditRecord("cash.session.open", "CashSession",
                id.ToString(), JsonSerializer.Serialize(new
                {
                    request.BranchCode, request.TerminalCode, request.OpeningFloat, request.Reason,
                })), token);
            return await store.SessionAsync(id, token) ?? throw new InvalidOperationException();
        }, ct);

    internal static ValidationFailedException Validation(string field, string code, string message) =>
        new(new[] { new ValidationFieldError(field, code, message) });
}

public sealed class SuspendCashSessionHandler(
    IUnitOfWork unitOfWork, ICashStore store, IAuditRecorder audit, ICurrentPrincipal principal)
    : IRequestHandler<SuspendCashSessionCommand, CashSessionDto>
{
    public Task<CashSessionDto> Handle(SuspendCashSessionCommand request, CancellationToken ct) =>
        unitOfWork.ExecuteInTransactionAsync(async token =>
        {
            await store.SuspendAsync(request.SessionId, principal.UserId, token);
            await audit.RecordAsync(new AuditRecord("cash.session.suspend", "CashSession",
                request.SessionId.ToString(), JsonSerializer.Serialize(new { request.Reason })), token);
            return await store.SessionAsync(request.SessionId, token)
                ?? throw OpenCashSessionHandler.Validation("SessionId", "not-found", "Session was not found.");
        }, ct);
}

public sealed class ResumeCashSessionHandler(
    IUnitOfWork unitOfWork, ICashStore store, IAuditRecorder audit, ICurrentPrincipal principal)
    : IRequestHandler<ResumeCashSessionCommand, CashSessionDto>
{
    public Task<CashSessionDto> Handle(ResumeCashSessionCommand request, CancellationToken ct) =>
        unitOfWork.ExecuteInTransactionAsync(async token =>
        {
            await store.ResumeAsync(request.SessionId, principal.UserId, token);
            await audit.RecordAsync(new AuditRecord("cash.session.resume", "CashSession",
                request.SessionId.ToString(), JsonSerializer.Serialize(new { request.Reason })), token);
            return await store.SessionAsync(request.SessionId, token)
                ?? throw OpenCashSessionHandler.Validation("SessionId", "not-found", "Session was not found.");
        }, ct);
}

public sealed class CloseCashSessionHandler(
    IUnitOfWork unitOfWork, ICashStore store, IAuditRecorder audit, ICurrentPrincipal principal)
    : IRequestHandler<CloseCashSessionCommand, CashSessionDto>
{
    public Task<CashSessionDto> Handle(CloseCashSessionCommand request, CancellationToken ct) =>
        unitOfWork.ExecuteInTransactionAsync(async token =>
        {
            var session = await store.SessionAsync(request.SessionId, token)
                ?? throw OpenCashSessionHandler.Validation("SessionId", "not-found", "Session was not found.");
            if (session.Status == "closed")
                throw OpenCashSessionHandler.Validation("SessionId", "already-closed",
                    "The drawer session is already closed.");
            var expected = await store.ExpectedCashAsync(request.SessionId, token);
            var variance = decimal.Round(request.CountedCash - expected, 4);
            if (variance != 0 && string.IsNullOrWhiteSpace(request.VarianceReason))
                throw OpenCashSessionHandler.Validation("VarianceReason", "required",
                    $"The closing count differs from expected cash by {variance:0.00}; a reason is required.");

            await store.CloseAsync(request.SessionId, request.CountedCash, expected, variance,
                request.VarianceReason, principal.UserId, token);
            await audit.RecordAsync(new AuditRecord("cash.session.close", "CashSession",
                request.SessionId.ToString(), JsonSerializer.Serialize(new
                {
                    request.Reason, expected, counted = request.CountedCash, variance,
                    request.VarianceReason,
                })), token);
            return await store.SessionAsync(request.SessionId, token)
                ?? throw new InvalidOperationException();
        }, ct);
}

public sealed class RecordCashCountHandler(
    IUnitOfWork unitOfWork, ICashStore store, IAuditRecorder audit, ICurrentPrincipal principal)
    : IRequestHandler<RecordCashCountCommand, CashSessionDetailDto>
{
    public Task<CashSessionDetailDto> Handle(RecordCashCountCommand request, CancellationToken ct) =>
        unitOfWork.ExecuteInTransactionAsync(async token =>
        {
            var session = await store.SessionAsync(request.SessionId, token)
                ?? throw OpenCashSessionHandler.Validation("SessionId", "not-found", "Session was not found.");
            if (session.Status == "closed")
                throw OpenCashSessionHandler.Validation("SessionId", "closed",
                    "The drawer session is closed.");
            var expected = await store.ExpectedCashAsync(request.SessionId, token);
            var variance = decimal.Round(request.Amount - expected, 4);
            await store.RecordCountAsync(request.SessionId, request.Kind, request.Amount, variance,
                request.Reason, principal.UserId, token);
            await audit.RecordAsync(new AuditRecord("cash.count", "CashSession",
                request.SessionId.ToString(), JsonSerializer.Serialize(new
                {
                    request.Kind, request.Amount, expected, variance, request.Reason,
                })), token);
            return await store.SessionDetailAsync(request.SessionId, token)
                ?? throw new InvalidOperationException();
        }, ct);
}

public sealed class RecordCashMovementHandler(
    IUnitOfWork unitOfWork, ICashStore store, IAuditRecorder audit, ICurrentPrincipal principal)
    : IRequestHandler<RecordCashMovementCommand, CashSessionDetailDto>
{
    public Task<CashSessionDetailDto> Handle(RecordCashMovementCommand request, CancellationToken ct) =>
        unitOfWork.ExecuteInTransactionAsync(async token =>
        {
            var session = await store.SessionAsync(request.SessionId, token)
                ?? throw OpenCashSessionHandler.Validation("SessionId", "not-found", "Session was not found.");
            if (session.Status != "open")
                throw OpenCashSessionHandler.Validation("SessionId", "not-open",
                    "Cash movements require an open session.");
            await store.RecordMovementAsync(request.SessionId, request.Kind, request.Amount,
                request.Reason, request.DestinationReference, principal.UserId, token);
            await audit.RecordAsync(new AuditRecord("cash.movement", "CashSession",
                request.SessionId.ToString(), JsonSerializer.Serialize(new
                {
                    request.Kind, request.Amount, request.Reason, request.DestinationReference,
                })), token);
            return await store.SessionDetailAsync(request.SessionId, token)
                ?? throw new InvalidOperationException();
        }, ct);
}

public sealed class GetCashCountContextHandler(ICashStore store, IPosPolicy policy)
    : IRequestHandler<GetCashCountContextQuery, CashCountContextDto>
{
    public async Task<CashCountContextDto> Handle(
        GetCashCountContextQuery request, CancellationToken ct)
    {
        var detail = await store.SessionDetailAsync(request.SessionId, ct)
            ?? throw OpenCashSessionHandler.Validation("SessionId", "not-found", "Session was not found.");
        var expected = await store.ExpectedCashAsync(request.SessionId, ct);
        // Blind policy hides expected cash only until the operator submits a count.
        var blind = policy.BlindCashCount
            && detail.Counts.All(count => count.Kind == "opening");
        return new CashCountContextDto(request.SessionId, detail.Session.OpeningFloat,
            blind ? null : expected, blind, detail.Counts, detail.Movements);
    }
}

public sealed class ListOpenCashSessionsHandler(ICashStore store)
    : IRequestHandler<ListOpenCashSessionsQuery, IReadOnlyList<CashSessionDto>>
{
    public Task<IReadOnlyList<CashSessionDto>> Handle(
        ListOpenCashSessionsQuery request, CancellationToken ct) =>
        store.OpenSessionsAsync(request.BranchCode, ct);
}

public sealed class ListCashSessionsHandler(ICashStore store)
    : IRequestHandler<ListCashSessionsQuery, IReadOnlyList<CashSessionDto>>
{
    public Task<IReadOnlyList<CashSessionDto>> Handle(
        ListCashSessionsQuery request, CancellationToken ct) =>
        store.SessionsAsync(request.BranchCode, request.BusinessDate, ct);
}

public sealed class GetCashSessionHandler(ICashStore store)
    : IRequestHandler<GetCashSessionQuery, CashSessionDetailDto>
{
    public async Task<CashSessionDetailDto> Handle(GetCashSessionQuery request, CancellationToken ct) =>
        await store.SessionDetailAsync(request.SessionId, ct)
        ?? throw OpenCashSessionHandler.Validation("SessionId", "not-found", "Session was not found.");
}

public sealed class GetCashJournalHandler(ICashStore store)
    : IRequestHandler<GetCashJournalQuery, CashJournalDto>
{
    public Task<CashJournalDto> Handle(GetCashJournalQuery request, CancellationToken ct) =>
        store.JournalAsync(request.BranchCode, request.BusinessDate, ct);
}

public sealed class FinalizeDailyCloseHandler(
    IUnitOfWork unitOfWork, ICashStore store, IAuditRecorder audit, ICurrentPrincipal principal)
    : IRequestHandler<FinalizeDailyCloseCommand, CashJournalDto>
{
    public Task<CashJournalDto> Handle(FinalizeDailyCloseCommand request, CancellationToken ct) =>
        unitOfWork.ExecuteInTransactionAsync(async token =>
        {
            var journal = await store.FinalizeDailyCloseAsync(request.BranchCode,
                request.BusinessDate, request.Reason, principal.UserId, token);
            await audit.RecordAsync(new AuditRecord("cash.daily-close.finalize", "CashDailyClose",
                $"{request.BranchCode}:{request.BusinessDate:yyyy-MM-dd}",
                JsonSerializer.Serialize(new { request.Reason, journal.TotalSales, journal.TotalRefunds })), token);
            return journal;
        }, ct);
}
