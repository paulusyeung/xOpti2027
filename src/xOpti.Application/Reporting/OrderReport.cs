using FluentValidation;
using xOpti.Application.Authorization;
using xOpti.Application.Common;
using xOpti.Application.Pipeline;
using xOpti.Application.Sales.Documents;
using xOpti.Application.Settings;

namespace xOpti.Application.Reporting;

/// <summary>
/// Shared BC tax-period rule for the Crystal sales documents. HST applied
/// between 2010-07-01 and 2015-03-31; GST and PST apply either side.
/// </summary>
public static class SalesTaxPeriods
{
    private static readonly DateTime HstStart = new(2010, 7, 1);

    private static readonly DateTime HstEnd = new(2015, 4, 1);

    public static bool UsesHst(DateTimeOffset date)
    {
        var value = date.UtcDateTime;
        return value >= HstStart && value < HstEnd;
    }
}

/// <summary>Legacy Crystal Sale Order projection, keyed by an SA order number.</summary>
public sealed record OrderReport(
    string TxNumber,
    DateTimeOffset DateOfEntry,
    DateTimeOffset? RequiredDate,
    string? RefNumber,
    string CustomerName,
    string? CustomerCity,
    string? CustomerPhone,
    string? VipCode,
    string? SalesPerson,
    IReadOnlyList<InvoiceReportLine> Lines,
    IReadOnlyList<InvoiceReportPayment> Payments,
    decimal NetSales,
    decimal TaxA,
    decimal TaxB,
    decimal GrossSales,
    decimal Deposit,
    decimal Balance)
{
    public bool UsesHst => SalesTaxPeriods.UsesHst(DateOfEntry);

    public string TaxALabel => UsesHst ? "H.S.T.:" : "G.S.T.:";

    public string TaxBLabel => UsesHst ? string.Empty : "P.S.T.:";

    public decimal TaxAAmount => UsesHst ? TaxA + TaxB : TaxA;

    public decimal TaxBAmount => UsesHst ? 0m : TaxB;
}

public interface IOrderReportStore
{
    Task<OrderReport?> GetAsync(string txNumber, CancellationToken cancellationToken);
}

public sealed record PrintOrderReportCommand(string OrderNumber, string Reason)
    : ICommand<RenderedDocument>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.ReportFinancial };

    /// <summary>Legacy InputBox handling simply prefixes "SA".</summary>
    public static string Normalize(string value) =>
        value.Trim().StartsWith("SA", StringComparison.OrdinalIgnoreCase)
            ? value.Trim().ToUpperInvariant()
            : "SA" + value.Trim().ToUpperInvariant();
}

public sealed class PrintOrderReportCommandValidator : AbstractValidator<PrintOrderReportCommand>
{
    public PrintOrderReportCommandValidator()
    {
        RuleFor(x => x.OrderNumber).NotEmpty().MaximumLength(20);
        RuleFor(x => x.Reason).NotEmpty().MinimumLength(3).MaximumLength(500);
    }
}

public sealed class PrintOrderReportHandler(
    IOrderReportStore store,
    IReportRenderer renderer,
    IPreferencesStore preferences)
    : IRequestHandler<PrintOrderReportCommand, RenderedDocument>
{
    public async Task<RenderedDocument> Handle(
        PrintOrderReportCommand request, CancellationToken cancellationToken)
    {
        var txNumber = PrintOrderReportCommand.Normalize(request.OrderNumber);
        var report = await store.GetAsync(txNumber, cancellationToken);
        if (report is null)
        {
            throw new DomainRuleException($"No order found for '{txNumber}'.");
        }

        var letterhead = ReportLetterheadDto.From(await preferences.GetAsync(cancellationToken));
        return renderer.RenderOrderReport(report, letterhead);
    }
}
