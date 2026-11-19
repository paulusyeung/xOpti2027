using System.Text;
using FluentValidation;
using xOpti.Application.Authorization;
using xOpti.Application.Common;
using xOpti.Application.Pipeline;
using xOpti.Application.Ports;

namespace xOpti.Application.Analytics;

public sealed record ListAnalyticsViewsQuery
    : IQuery<IReadOnlyList<AnalyticsViewDefinition>>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.ReportFinancial };
}

public sealed record GetAnalyticsFeedQuery(
    string ViewKey, string? From, string? To, string? Branch, string? Staff,
    string? Department, string? ClassCode, string? Category)
    : IQuery<AnalyticsFeedDto>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.ReportFinancial };
}

public sealed record ExportAnalyticsFeedQuery(
    string ViewKey, string? From, string? To, string? Branch, string? Staff,
    string? Department, string? ClassCode, string? Category, string Reason)
    : IQuery<AnalyticsExportResult>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.ReportFinancial };
}

public sealed record AnalyticsExportResult(string FileName, string ContentType, byte[] Content);

public sealed record ListSavedAnalyticsViewsQuery
    : IQuery<IReadOnlyList<AnalyticsViewDto>>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.ReportFinancial };
}

public sealed record GetSavedAnalyticsViewQuery(long Id)
    : IQuery<AnalyticsViewDto>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.ReportFinancial };
}

public sealed record SaveAnalyticsViewCommand(
    string ViewKey, string Name, bool IsShared, string ConfigJson, string Reason)
    : ICommand<AnalyticsViewDto>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.ReportFinancial };
}

public sealed record DeleteAnalyticsViewCommand(long Id, string Reason)
    : ICommand<bool>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.ReportFinancial };
}

public sealed class SaveAnalyticsViewCommandValidator
    : AbstractValidator<SaveAnalyticsViewCommand>
{
    public SaveAnalyticsViewCommandValidator()
    {
        RuleFor(x => x.ViewKey).NotEmpty().MaximumLength(40);
        RuleFor(x => x.Name).NotEmpty().MaximumLength(120);
        RuleFor(x => x.ConfigJson).NotEmpty().MaximumLength(20000)
            .Must(json => IsJson(json)).WithMessage("The view configuration must be valid JSON.");
        RuleFor(x => x.Reason).NotEmpty().MinimumLength(3).MaximumLength(500);
    }

    private static bool IsJson(string value)
    {
        try { using var _ = System.Text.Json.JsonDocument.Parse(value); return true; }
        catch { return false; }
    }
}

public sealed class ExportAnalyticsFeedQueryValidator
    : AbstractValidator<ExportAnalyticsFeedQuery>
{
    public ExportAnalyticsFeedQueryValidator()
    {
        RuleFor(x => x.ViewKey).NotEmpty().MaximumLength(40);
        RuleFor(x => x.Reason).NotEmpty().MinimumLength(3).MaximumLength(500);
    }
}

public sealed class ListAnalyticsViewsHandler
    : IRequestHandler<ListAnalyticsViewsQuery, IReadOnlyList<AnalyticsViewDefinition>>
{
    public Task<IReadOnlyList<AnalyticsViewDefinition>> Handle(
        ListAnalyticsViewsQuery request, CancellationToken ct) =>
        Task.FromResult(AnalyticsViews.All);
}

public sealed class GetAnalyticsFeedHandler(
    IAnalyticsStore store, IAuditRecorder audit, ICurrentPrincipal principal)
    : IRequestHandler<GetAnalyticsFeedQuery, AnalyticsFeedDto>
{
    public async Task<AnalyticsFeedDto> Handle(
        GetAnalyticsFeedQuery request, CancellationToken ct)
    {
        var feed = await store.GetFeedAsync(request.ViewKey, request.From, request.To,
            request.Branch, request.Staff, request.Department, request.ClassCode,
            request.Category, principal.HasPermission(PermissionNames.CostView), 5000, ct);
        await audit.RecordAsync(new AuditRecord("analytics.feed", "AnalyticsView",
            request.ViewKey, System.Text.Json.JsonSerializer.Serialize(new
            {
                request.From, request.To, request.Branch, request.Staff, request.Department,
                request.ClassCode, request.Category, rows = feed.Data.Count,
                costFields = principal.HasPermission(PermissionNames.CostView),
            })), ct);
        return feed;
    }
}

public sealed class ExportAnalyticsFeedHandler(
    IAnalyticsStore store, IAuditRecorder audit, ICurrentPrincipal principal)
    : IRequestHandler<ExportAnalyticsFeedQuery, AnalyticsExportResult>
{
    public async Task<AnalyticsExportResult> Handle(
        ExportAnalyticsFeedQuery request, CancellationToken ct)
    {
        var feed = await store.GetFeedAsync(request.ViewKey, request.From, request.To,
            request.Branch, request.Staff, request.Department, request.ClassCode,
            request.Category, principal.HasPermission(PermissionNames.CostView), 5000, ct);
        var builder = new StringBuilder();
        builder.AppendLine(string.Join(',', feed.Fields.Select(field => Csv(field.Label))));
        foreach (var row in feed.Data)
            builder.AppendLine(string.Join(',', feed.Fields.Select((field, index) =>
                Csv(Format(row[index], field.Type)))));
        await audit.RecordAsync(new AuditRecord("analytics.export", "AnalyticsView",
            request.ViewKey, System.Text.Json.JsonSerializer.Serialize(new
            {
                request.Reason, rows = feed.Data.Count,
                costFields = principal.HasPermission(PermissionNames.CostView),
            })), ct);
        return new AnalyticsExportResult($"{request.ViewKey}.csv", "text/csv",
            Encoding.UTF8.GetBytes(builder.ToString()));
    }

    private static string Format(object? value, string type) => value switch
    {
        null => string.Empty,
        DateTime date => date.ToString("yyyy-MM-dd"),
        DateTimeOffset date => date.ToString("yyyy-MM-dd"),
        decimal number when type == "money" => number.ToString("0.0000"),
        decimal number => number.ToString("0.####"),
        double number => number.ToString("0.####"),
        _ => Convert.ToString(value) ?? string.Empty,
    };

    private static string Csv(string value) =>
        value.Contains(',') || value.Contains('"')
            ? $"\"{value.Replace("\"", "\"\"")}\""
            : value;
}

public sealed class ListSavedAnalyticsViewsHandler(
    IAnalyticsStore store, ICurrentPrincipal principal)
    : IRequestHandler<ListSavedAnalyticsViewsQuery, IReadOnlyList<AnalyticsViewDto>>
{
    public Task<IReadOnlyList<AnalyticsViewDto>> Handle(
        ListSavedAnalyticsViewsQuery request, CancellationToken ct) =>
        store.ListSavedAsync(principal.UserId ?? string.Empty, ct);
}

public sealed class GetSavedAnalyticsViewHandler(
    IAnalyticsStore store, ICurrentPrincipal principal)
    : IRequestHandler<GetSavedAnalyticsViewQuery, AnalyticsViewDto>
{
    public async Task<AnalyticsViewDto> Handle(
        GetSavedAnalyticsViewQuery request, CancellationToken ct) =>
        await store.GetSavedAsync(request.Id, principal.UserId ?? string.Empty, ct)
        ?? throw new ValidationFailedException(new[]
        {
            new ValidationFieldError("Id", "not-found",
                "The saved analytics view was not found or is not shared with you."),
        });
}

public sealed class SaveAnalyticsViewHandler(
    IUnitOfWork unitOfWork, IAnalyticsStore store, IAuditRecorder audit,
    ICurrentPrincipal principal)
    : IRequestHandler<SaveAnalyticsViewCommand, AnalyticsViewDto>
{
    public Task<AnalyticsViewDto> Handle(SaveAnalyticsViewCommand request, CancellationToken ct) =>
        unitOfWork.ExecuteInTransactionAsync(async token =>
        {
            var view = await store.SaveAsync(request.ViewKey, request.Name, request.IsShared,
                request.ConfigJson, principal.UserId ?? string.Empty, token);
            await audit.RecordAsync(new AuditRecord("analytics.view.save", "AnalyticsView",
                view.Id.ToString(), System.Text.Json.JsonSerializer.Serialize(new
                {
                    view.ViewKey, view.Name, view.IsShared, request.Reason,
                })), token);
            return view;
        }, ct);
}

public sealed class DeleteAnalyticsViewHandler(
    IUnitOfWork unitOfWork, IAnalyticsStore store, IAuditRecorder audit,
    ICurrentPrincipal principal)
    : IRequestHandler<DeleteAnalyticsViewCommand, bool>
{
    public Task<bool> Handle(DeleteAnalyticsViewCommand request, CancellationToken ct) =>
        unitOfWork.ExecuteInTransactionAsync(async token =>
        {
            await store.DeleteSavedAsync(request.Id, principal.UserId ?? string.Empty, token);
            await audit.RecordAsync(new AuditRecord("analytics.view.delete", "AnalyticsView",
                request.Id.ToString(), System.Text.Json.JsonSerializer.Serialize(new
                {
                    request.Reason,
                })), token);
            return true;
        }, ct);
}
