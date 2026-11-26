using FluentValidation;
using xOpti.Application.Authorization;
using xOpti.Application.Common;
using xOpti.Application.Pipeline;
using xOpti.Application.Sales.Documents;
using xOpti.Application.Settings;

namespace xOpti.Application.Reporting;

/// <summary>One label from the legacy Bar Code Tag report.</summary>
public sealed record BarCodeTagLabel(
    string Sku,
    string? Brand,
    string? Color,
    string? Size,
    decimal? RetailPrice,
    string? Model,
    string? ClassName);

public sealed record BarCodeTagDocument(
    string FromTxNumber,
    string ToTxNumber,
    IReadOnlyList<BarCodeTagLabel> Labels,
    bool Duplicate);

/// <summary>
/// Reads the bar-code pool populated when stock is received. Each pool row is
/// one physical label, matching the legacy Crystal report's Details section.
/// </summary>
public interface IBarCodeTagStore
{
    Task<IReadOnlyList<BarCodeTagLabel>> GetLabelsAsync(
        string fromTxNumber,
        string toTxNumber,
        CancellationToken cancellationToken);
}

public sealed record PrintBarCodeTagsCommand(string FromNumber, string ToNumber, bool Duplicate, string Reason)
    : ICommand<RenderedDocument>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.ReportFinancial };
}

public sealed class PrintBarCodeTagsCommandValidator : AbstractValidator<PrintBarCodeTagsCommand>
{
    public PrintBarCodeTagsCommandValidator()
    {
        RuleFor(x => x.FromNumber).NotEmpty().MaximumLength(8);
        RuleFor(x => x.ToNumber).NotEmpty().MaximumLength(8);
        RuleFor(x => x.Reason).NotEmpty().MinimumLength(3).MaximumLength(500);
    }
}

public sealed class PrintBarCodeTagsHandler(
    IBarCodeTagStore store,
    IReportRenderer renderer,
    IPreferencesStore preferences)
    : IRequestHandler<PrintBarCodeTagsCommand, RenderedDocument>
{
    public async Task<RenderedDocument> Handle(
        PrintBarCodeTagsCommand request,
        CancellationToken cancellationToken)
    {
        if (!int.TryParse(request.FromNumber, out var fromValue) || fromValue < 1 || fromValue > 99999999)
        {
            throw new ValidationFailedException(new[]
            {
                new ValidationFieldError("FromNumber", "range", "From must be a number between 1 and 99999999."),
            });
        }
        if (!int.TryParse(request.ToNumber, out var toValue) || toValue < 1 || toValue > 99999999)
        {
            throw new ValidationFailedException(new[]
            {
                new ValidationFieldError("ToNumber", "range", "To must be a number between 1 and 99999999."),
            });
        }
        if (fromValue > toValue)
        {
            (fromValue, toValue) = (toValue, fromValue);
        }

        var fromTxNumber = $"SR{fromValue:D8}";
        var toTxNumber = $"SR{toValue:D8}";
        var labels = await store.GetLabelsAsync(fromTxNumber, toTxNumber, cancellationToken);
        if (labels.Count == 0)
        {
            throw new DomainRuleException(
                $"No bar-code labels found between '{fromTxNumber}' and '{toTxNumber}'.");
        }

        var letterhead = ReportLetterheadDto.From(await preferences.GetAsync(cancellationToken));
        return renderer.RenderBarCodeTags(
            new BarCodeTagDocument(fromTxNumber, toTxNumber, labels, request.Duplicate), letterhead);
    }
}
