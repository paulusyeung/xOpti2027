using FluentValidation;
using xOpti.Application.Authorization;
using xOpti.Application.Common;
using xOpti.Application.Pipeline;
using xOpti.Application.Sales.Documents;
using xOpti.Application.Settings;

namespace xOpti.Application.Reporting;

public sealed record InvoiceReportLine(
    double RowNo, string Sku, string? Description, string? TaxCode,
    int Qty, decimal UnitPrice, decimal Amount);

public sealed record InvoiceReportPayment(
    string Type, string? CardAuthorization, decimal AmountTender,
    double ExchangeRate, decimal EqAmount);

/// <summary>Legacy Crystal Invoice projection, keyed by an RC invoice number.</summary>
public sealed record InvoiceReport(
    string TxNumber,
    DateTimeOffset DateOfEntry,
    DateTimeOffset? OrderDate,
    string? OrderNumber,
    string CustomerName,
    string? CustomerAddressLine,
    string? CustomerCity,
    string? CustomerProvince,
    string? CustomerCountry,
    string? CustomerPostalCode,
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
    decimal Change)
{
    // BC HST applied from 2010-07-01 until 2015-03-31. The legacy Crystal
    // report only encoded the start date; end it here so post-2015 invoices
    // print GST and PST again.
    private static readonly DateTime HstStart = new(2010, 7, 1);

    private static readonly DateTime HstEnd = new(2015, 4, 1);

    public bool UsesHst
    {
        get
        {
            var date = DateOfEntry.UtcDateTime;
            return date >= HstStart && date < HstEnd;
        }
    }

    public string TaxALabel => UsesHst ? "H.S.T.:" : "G.S.T.:";

    public string TaxBLabel => UsesHst ? string.Empty : "P.S.T.:";

    public decimal TaxAAmount => UsesHst ? TaxA + TaxB : TaxA;

    public decimal TaxBAmount => UsesHst ? 0m : TaxB;

    public decimal Balance => GrossSales - Deposit;
}

public interface IInvoiceReportStore
{
    Task<InvoiceReport?> GetAsync(string txNumber, CancellationToken cancellationToken);
}

public sealed record PrintInvoiceReportCommand(string InvoiceNumber, string Reason)
    : ICommand<RenderedDocument>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.ReportFinancial };

    public static string Normalize(string value)
    {
        var trimmed = value.Trim();
        var digits = trimmed.StartsWith("RC", StringComparison.OrdinalIgnoreCase)
            ? trimmed[2..]
            : trimmed;
        return int.TryParse(digits, out var number) && number > 0
            ? $"RC{number:D8}"
            : trimmed.ToUpperInvariant();
    }
}

public sealed class PrintInvoiceReportCommandValidator : AbstractValidator<PrintInvoiceReportCommand>
{
    public PrintInvoiceReportCommandValidator()
    {
        RuleFor(x => x.InvoiceNumber).NotEmpty().MaximumLength(20);
        RuleFor(x => x.Reason).NotEmpty().MinimumLength(3).MaximumLength(500);
    }
}

public sealed class PrintInvoiceReportHandler(
    IInvoiceReportStore store,
    IReportRenderer renderer,
    IPreferencesStore preferences)
    : IRequestHandler<PrintInvoiceReportCommand, RenderedDocument>
{
    public async Task<RenderedDocument> Handle(
        PrintInvoiceReportCommand request, CancellationToken cancellationToken)
    {
        var txNumber = PrintInvoiceReportCommand.Normalize(request.InvoiceNumber);
        var report = await store.GetAsync(txNumber, cancellationToken);
        if (report is null)
        {
            throw new DomainRuleException($"No invoice found for '{txNumber}'.");
        }

        var letterhead = ReportLetterheadDto.From(await preferences.GetAsync(cancellationToken));
        return renderer.RenderInvoiceReport(report, letterhead);
    }
}
