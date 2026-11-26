using FluentValidation;
using xOpti.Application.Authorization;
using xOpti.Application.Common;
using xOpti.Application.Pipeline;
using xOpti.Application.Sales.Documents;
using xOpti.Application.Settings;

namespace xOpti.Application.Reporting;

/// <summary>One class subtotal on the legacy optical claims receipt.</summary>
public sealed record ClaimReceiptReportClass(string Name, decimal Amount);

/// <summary>
/// Legacy RptClaimReceipt projection keyed by an RC order/invoice number.
/// Amounts are computed exactly as the Crystal formulas do.
/// </summary>
public sealed record ClaimReceiptReport(
    string TxNumber,
    DateTime DateOfEntry,
    string LastName,
    string FirstName,
    string? StaffCode,
    IReadOnlyList<ClaimReceiptReportClass> Classes,
    decimal Discount,
    decimal Total,
    decimal Deposit);

public interface IClaimReceiptReportStore
{
    Task<ClaimReceiptReport?> GetAsync(string txNumber, CancellationToken cancellationToken);
}

public sealed record PrintClaimReceiptReportCommand(string OrderInvoiceNumber, string Reason)
    : ICommand<RenderedDocument>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.ReportFinancial };

    /// <summary>
    /// Matches the legacy InputBox handling: an RC-prefixed value is zero-padded
    /// to eight digits. A bare number is accepted for convenience.
    /// </summary>
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

public sealed class PrintClaimReceiptReportCommandValidator
    : AbstractValidator<PrintClaimReceiptReportCommand>
{
    public PrintClaimReceiptReportCommandValidator()
    {
        RuleFor(x => x.OrderInvoiceNumber).NotEmpty().MaximumLength(20);
        RuleFor(x => x.Reason).NotEmpty().MinimumLength(3).MaximumLength(500);
    }
}

public sealed class PrintClaimReceiptReportHandler(
    IClaimReceiptReportStore store,
    IReportRenderer renderer,
    IPreferencesStore preferences)
    : IRequestHandler<PrintClaimReceiptReportCommand, RenderedDocument>
{
    public async Task<RenderedDocument> Handle(
        PrintClaimReceiptReportCommand request, CancellationToken cancellationToken)
    {
        var txNumber = PrintClaimReceiptReportCommand.Normalize(request.OrderInvoiceNumber);
        var report = await store.GetAsync(txNumber, cancellationToken);
        if (report is null)
        {
            throw new DomainRuleException(
                $"No claim receipt found for order/invoice '{txNumber}'.");
        }

        var letterhead = ReportLetterheadDto.From(await preferences.GetAsync(cancellationToken));
        return renderer.RenderClaimReceiptReport(report, letterhead);
    }
}
