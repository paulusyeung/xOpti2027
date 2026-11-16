using System.Text.Json;
using FluentValidation;
using xOpti.Application.Authorization;
using xOpti.Application.Common;
using xOpti.Application.Pipeline;
using xOpti.Application.Ports;
using xOpti.Application.Sales.Documents;
using xOpti.Domain.Values;

namespace xOpti.Application.Sales.Retail;

public sealed record RetailLineInput(
    string Sku, int Quantity, decimal UnitAmount, decimal DiscountAmount, string TaxCode);

public sealed record RetailTenderInput(string Method, decimal Amount, string? Reference);

public sealed record RefundLineInput(int OriginalRowNo, int Quantity, bool Restock);

public sealed record RefundableLineDto(
    int RowNo, string Sku, int OriginalQuantity, int RefundedQuantity, int RefundableQuantity,
    decimal UnitAmount, decimal DiscountAmount, decimal Amount, decimal TaxA, decimal TaxB,
    string? TaxCode);

public sealed record RefundableInvoiceDto(
    string TxNumber, int CustomerId, string? CustomerName, DateTimeOffset DateOfEntry,
    decimal TotalSale, decimal TaxA, decimal TaxB, decimal TotalAmount,
    decimal RefundedTaxA, decimal RefundedTaxB, IReadOnlyList<RefundableLineDto> Lines);

public sealed record RetailInvoicePosting(
    string TxNumber, string ControlNumber, int CustomerId, string StaffCode,
    IReadOnlyList<PricedLine> Lines, decimal TotalSale, decimal TaxA, decimal TaxB,
    decimal GrossSale, IReadOnlyList<RetailTenderInput> Tenders, DateTimeOffset DateOfEntry);

public sealed record RefundPostingLine(
    int OriginalRowNo, string Sku, int Quantity, bool Restock,
    decimal UnitAmount, decimal DiscountAmount, decimal Amount, decimal TaxA, decimal TaxB,
    string? TaxCode);

public sealed record RefundPosting(
    string TxNumber, string ControlNumber, string OriginalTxNumber, int CustomerId,
    string StaffCode, IReadOnlyList<RefundPostingLine> RefundLines,
    IReadOnlyList<PricedLine> ReplacementLines, decimal TotalSale, decimal TaxA, decimal TaxB,
    decimal GrossSale, int TotalQty, bool FullyRefunded, DateTimeOffset DateOfEntry);

public interface IRetailSaleStore
{
    Task<bool> CustomerExistsAsync(int customerId, CancellationToken ct);
    Task<IReadOnlyList<string>> MissingSkusAsync(IEnumerable<string> skus, CancellationToken ct);
    Task<IReadOnlyDictionary<string, decimal?>> RetailPricesAsync(
        IEnumerable<string> skus, CancellationToken ct);
    Task<(double GstRate, double PstRate)> TaxRatesAsync(CancellationToken ct);
    Task<string> NextControlNumberAsync(CancellationToken ct);
    Task PostInvoiceAsync(RetailInvoicePosting posting, CancellationToken ct);
    Task<SalesDocumentDto?> GetDocumentAsync(string txNumber, CancellationToken ct);
    Task<RefundableInvoiceDto?> GetRefundableAsync(string invoiceNumber, CancellationToken ct);
    Task PostRefundAsync(RefundPosting posting, CancellationToken ct);
}

public sealed record PostRetailInvoiceCommand(
    int CustomerId, string StaffCode, IReadOnlyList<RetailLineInput> Lines,
    IReadOnlyList<RetailTenderInput> Tenders, string Reason, string? IdempotencyKey)
    : ICommand<SalesDocumentDto>, IRequiresIdempotencyKey, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.SalesInvoicePost };
}

public sealed record PostRetailRefundCommand(
    string OriginalTxNumber, string StaffCode, IReadOnlyList<RefundLineInput> Lines,
    IReadOnlyList<RetailLineInput> Replacements, string Reason, string? IdempotencyKey)
    : ICommand<SalesDocumentDto>, IRequiresIdempotencyKey, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.SalesInvoicePost };
}

public sealed record GetRefundableInvoiceQuery(string TxNumber)
    : IQuery<RefundableInvoiceDto>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.SalesInvoicePost };
}

public sealed class RetailLineValidator : AbstractValidator<RetailLineInput>
{
    public RetailLineValidator()
    {
        RuleFor(x => x.Sku).NotEmpty().MaximumLength(13);
        RuleFor(x => x.Quantity).GreaterThan(0);
        RuleFor(x => x.UnitAmount).GreaterThanOrEqualTo(0);
        RuleFor(x => x.DiscountAmount).GreaterThanOrEqualTo(0);
        RuleFor(x => x.TaxCode).MaximumLength(1);
    }
}

public sealed class RetailTenderValidator : AbstractValidator<RetailTenderInput>
{
    public RetailTenderValidator()
    {
        RuleFor(x => x.Method).NotEmpty().MaximumLength(2);
        RuleFor(x => x.Amount).GreaterThan(0);
        RuleFor(x => x.Reference).MaximumLength(30);
    }
}

public sealed class PostRetailInvoiceCommandValidator : AbstractValidator<PostRetailInvoiceCommand>
{
    public PostRetailInvoiceCommandValidator()
    {
        RuleFor(x => x.CustomerId).GreaterThan(0);
        RuleFor(x => x.StaffCode).NotEmpty().MaximumLength(4);
        RuleFor(x => x.Lines).NotEmpty();
        RuleForEach(x => x.Lines).SetValidator(new RetailLineValidator());
        RuleFor(x => x.Tenders).NotEmpty();
        RuleForEach(x => x.Tenders).SetValidator(new RetailTenderValidator());
        RuleFor(x => x.Reason).NotEmpty().MinimumLength(3).MaximumLength(500);
    }
}

public sealed class PostRetailRefundCommandValidator : AbstractValidator<PostRetailRefundCommand>
{
    public PostRetailRefundCommandValidator()
    {
        RuleFor(x => x.OriginalTxNumber).NotEmpty();
        RuleFor(x => x.StaffCode).NotEmpty().MaximumLength(4);
        RuleFor(x => x.Lines).NotEmpty();
        RuleForEach(x => x.Lines).ChildRules(line =>
        {
            line.RuleFor(x => x.OriginalRowNo).GreaterThan(0);
            line.RuleFor(x => x.Quantity).GreaterThan(0);
        });
        RuleFor(x => x.Lines)
            .Must(lines => lines.Select(line => line.OriginalRowNo).Distinct().Count() == lines.Count)
            .WithMessage("Each original line may appear only once.");
        RuleForEach(x => x.Replacements).SetValidator(new RetailLineValidator());
        RuleFor(x => x.Reason).NotEmpty().MinimumLength(3).MaximumLength(500);
    }
}

public sealed class PostRetailInvoiceHandler(
    IUnitOfWork unitOfWork, IRetailSaleStore store, IControlNumberAllocator allocator,
    IAuditRecorder audit, IClock clock, ICurrentPrincipal principal, IPosPolicy policy)
    : IRequestHandler<PostRetailInvoiceCommand, SalesDocumentDto>
{
    public Task<SalesDocumentDto> Handle(PostRetailInvoiceCommand request, CancellationToken ct) =>
        unitOfWork.ExecuteInTransactionAsync(async token =>
        {
            await ValidateAsync(store, request.CustomerId, request.Lines.Select(line => line.Sku).ToList(), token);
            var pricingLines = request.Lines.Select(line => new PricingLineInput(
                line.Sku, line.Quantity, line.UnitAmount, line.DiscountAmount, line.TaxCode)).ToList();
            var retailPrices = await store.RetailPricesAsync(request.Lines.Select(line => line.Sku), token);
            var overrides = PriceOverrideRules.Validate(pricingLines, retailPrices,
                PriceOverrideRules.CanOverride(principal), policy.DiscountThresholdPercent);

            var priced = SalesPricing.Price(pricingLines, await store.TaxRatesAsync(token));
            var txNumber = await allocator.AllocateAsync(TransactionType.RetailInvoice, token);
            var control = await store.NextControlNumberAsync(token);
            var posting = new RetailInvoicePosting(txNumber.Value, control, request.CustomerId,
                request.StaffCode, priced.Lines, priced.TotalSale, priced.TaxA, priced.TaxB,
                priced.GrossSale, request.Tenders, clock.UtcNow);
            await store.PostInvoiceAsync(posting, token);

            await audit.RecordAsync(new AuditRecord("retail.invoice", "TxHeader", txNumber.Value,
                JsonSerializer.Serialize(new
                {
                    reason = request.Reason, total = priced.GrossSale,
                    tenders = request.Tenders.Select(tender => new { tender.Method, tender.Amount }),
                })), token);
            await PriceOverrideRules.RecordAuditAsync(audit, txNumber.Value, overrides, request.Reason, token);

            return await store.GetDocumentAsync(txNumber.Value, token)
                ?? throw new InvalidOperationException("Invoice was not found after posting.");
        }, ct);

    internal static async Task ValidateAsync(
        IRetailSaleStore store, int customerId, IReadOnlyList<string> skus, CancellationToken ct)
    {
        if (!await store.CustomerExistsAsync(customerId, ct))
            throw new ValidationFailedException(new[]
            {
                new ValidationFieldError("CustomerId", "not-found", "Customer was not found."),
            });
        var missing = await store.MissingSkusAsync(skus, ct);
        if (missing.Count > 0)
            throw new ValidationFailedException(new[]
            {
                new ValidationFieldError("Sku", "not-found", $"Unknown SKU(s): {string.Join(", ", missing)}."),
            });
    }
}

public sealed class GetRefundableInvoiceHandler(IRetailSaleStore store)
    : IRequestHandler<GetRefundableInvoiceQuery, RefundableInvoiceDto>
{
    public async Task<RefundableInvoiceDto> Handle(GetRefundableInvoiceQuery request, CancellationToken ct) =>
        await store.GetRefundableAsync(request.TxNumber, ct)
        ?? throw new ValidationFailedException(new[]
        {
            new ValidationFieldError("TxNumber", "not-found", "Retail invoice was not found."),
        });
}

public sealed class PostRetailRefundHandler(
    IUnitOfWork unitOfWork, IRetailSaleStore store, IControlNumberAllocator allocator,
    IAuditRecorder audit, IClock clock)
    : IRequestHandler<PostRetailRefundCommand, SalesDocumentDto>
{
    public Task<SalesDocumentDto> Handle(PostRetailRefundCommand request, CancellationToken ct) =>
        unitOfWork.ExecuteInTransactionAsync(async token =>
        {
            var invoice = await store.GetRefundableAsync(request.OriginalTxNumber, token)
                ?? throw new ValidationFailedException(new[]
                {
                    new ValidationFieldError("OriginalTxNumber", "not-found",
                        "Retail invoice was not found."),
                });

            var requested = new Dictionary<int, int>();
            var refundLines = new List<RefundPostingLine>();
            var totalRefundNet = 0m;
            var totalRefundQty = 0;
            foreach (var line in request.Lines)
            {
                var original = invoice.Lines.SingleOrDefault(row => row.RowNo == line.OriginalRowNo)
                    ?? throw new ValidationFailedException(new[]
                    {
                        new ValidationFieldError("OriginalRowNo", "not-found",
                            $"Original line {line.OriginalRowNo} was not found."),
                    });
                if (line.Quantity > original.RefundableQuantity)
                    throw new ValidationFailedException(new[]
                    {
                        new ValidationFieldError("Quantity", "over-refund",
                            $"Line {original.RowNo} ({original.Sku}) has {original.RefundableQuantity} "
                            + "refundable unit(s)."),
                    });

                requested[original.RowNo] = line.Quantity;
                var amount = decimal.Round(
                    original.Amount * line.Quantity / original.OriginalQuantity, 4);
                var discount = decimal.Round(
                    original.DiscountAmount * line.Quantity / original.OriginalQuantity, 4);
                refundLines.Add(new RefundPostingLine(original.RowNo, original.Sku, line.Quantity,
                    line.Restock, original.UnitAmount, discount, amount, 0m, 0m, original.TaxCode));
                totalRefundNet += amount;
                totalRefundQty += line.Quantity;
            }

            var fullyRefunded = invoice.Lines.All(line =>
                requested.GetValueOrDefault(line.RowNo) == line.RefundableQuantity);
            var refundTaxA = RefundTax(invoice.TaxA, invoice.RefundedTaxA,
                totalRefundNet, invoice.TotalSale, fullyRefunded);
            var refundTaxB = RefundTax(invoice.TaxB, invoice.RefundedTaxB,
                totalRefundNet, invoice.TotalSale, fullyRefunded);

            AllocateTax(refundLines, totalRefundNet, refundTaxA, refundTaxB);
            var replacements = SalesPricing.Price(
                request.Replacements.Select(line => new PricingLineInput(
                    line.Sku, line.Quantity, line.UnitAmount, line.DiscountAmount, line.TaxCode)).ToList(),
                await store.TaxRatesAsync(token));

            var totalSale = decimal.Round(replacements.TotalSale - totalRefundNet, 4);
            var taxA = decimal.Round(replacements.TaxA - refundTaxA, 4);
            var taxB = decimal.Round(replacements.TaxB - refundTaxB, 4);
            var gross = decimal.Round(totalSale + taxA + taxB, 4);
            var rsNumber = await allocator.AllocateAsync(TransactionType.RetailRefund, token);
            var control = await store.NextControlNumberAsync(token);
            var posting = new RefundPosting(rsNumber.Value, control, invoice.TxNumber,
                invoice.CustomerId, request.StaffCode, refundLines, replacements.Lines, totalSale, taxA, taxB,
                gross, replacements.TotalQty - totalRefundQty, fullyRefunded, clock.UtcNow);
            await store.PostRefundAsync(posting, token);

            await audit.RecordAsync(new AuditRecord("retail.refund", "TxHeader", rsNumber.Value,
                JsonSerializer.Serialize(new
                {
                    reason = request.Reason, invoice = invoice.TxNumber,
                    refund = totalRefundNet, replacement = replacements.TotalSale,
                    restocked = request.Lines.Where(line => line.Restock)
                        .Select(line => line.OriginalRowNo),
                    fullyRefunded,
                })), token);

            return await store.GetDocumentAsync(rsNumber.Value, token)
                ?? throw new InvalidOperationException("Refund was not found after posting.");
        }, ct);

    private static decimal RefundTax(
        decimal originalTax, decimal alreadyRefunded, decimal refundNet,
        decimal originalNet, bool fullyRefunded)
    {
        var remaining = decimal.Round(originalTax - alreadyRefunded, 4);
        if (remaining <= 0) return 0m;
        if (fullyRefunded) return remaining;
        var share = originalNet == 0
            ? 0m
            : decimal.Round(originalTax * refundNet / originalNet, 2);
        return Math.Min(remaining, Math.Max(0m, share));
    }

    private static void AllocateTax(
        List<RefundPostingLine> lines, decimal totalNet, decimal taxA, decimal taxB)
    {
        if (lines.Count == 0) return;
        var remainingA = taxA;
        var remainingB = taxB;
        for (var index = 0; index < lines.Count; index++)
        {
            var line = lines[index];
            var last = index == lines.Count - 1;
            var share = totalNet == 0 ? 0m : line.Amount / totalNet;
            var lineTaxA = last ? remainingA : decimal.Round(taxA * share, 2);
            var lineTaxB = last ? remainingB : decimal.Round(taxB * share, 2);
            lines[index] = line with { TaxA = lineTaxA, TaxB = lineTaxB };
            remainingA = decimal.Round(remainingA - lineTaxA, 4);
            remainingB = decimal.Round(remainingB - lineTaxB, 4);
        }
    }
}
