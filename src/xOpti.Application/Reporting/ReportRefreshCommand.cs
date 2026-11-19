using System.Text.Json;
using FluentValidation;
using xOpti.Application.Authorization;
using xOpti.Application.Common;
using xOpti.Application.Pipeline;
using xOpti.Application.Ports;

namespace xOpti.Application.Reporting;

public interface IReportReadModelRefresher
{
    Task RefreshAsync(CancellationToken ct);
}

public sealed record RefreshReportingReadModelsCommand(string Reason)
    : ICommand<bool>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.ReportFinancial };
}

public sealed class RefreshReportingReadModelsCommandValidator
    : AbstractValidator<RefreshReportingReadModelsCommand>
{
    public RefreshReportingReadModelsCommandValidator()
    {
        RuleFor(x => x.Reason).NotEmpty().MinimumLength(3).MaximumLength(500);
    }
}

public sealed class RefreshReportingReadModelsHandler(
    IUnitOfWork unitOfWork, IReportReadModelRefresher refresher, IAuditRecorder audit)
    : IRequestHandler<RefreshReportingReadModelsCommand, bool>
{
    public Task<bool> Handle(RefreshReportingReadModelsCommand request, CancellationToken ct) =>
        unitOfWork.ExecuteInTransactionAsync(async token =>
        {
            await refresher.RefreshAsync(token);
            await audit.RecordAsync(new AuditRecord("reporting.refresh", "ReadModel",
                "reporting", JsonSerializer.Serialize(new { request.Reason })), token);
            return true;
        }, ct);
}
