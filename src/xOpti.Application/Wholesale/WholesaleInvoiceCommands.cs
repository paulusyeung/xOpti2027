using System.Text.Json;
using FluentValidation;
using xOpti.Application.Authorization;
using xOpti.Application.Common;
using xOpti.Application.Pipeline;
using xOpti.Application.Payments;
using xOpti.Application.Ports;
using xOpti.Application.Sales;
using xOpti.Domain.Values;

namespace xOpti.Application.Wholesale;

public sealed record CreateWholesaleInvoiceCommand(
    int CustomerId, string StaffCode, IReadOnlyList<WholesaleLineInput> Lines,
    IReadOnlyList<WholesaleTenderInput> Tenders, WholesaleShippingInput Shipping,
    string Reason, string? IdempotencyKey)
    : ICommand<WholesaleInvoiceDto>, IRequiresIdempotencyKey, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions =>
        new[] { PermissionNames.WholesaleInvoicePost };
}

public sealed record UpdateWholesaleInvoiceCommand(
    string TxNumber, int CustomerId, string StaffCode, IReadOnlyList<WholesaleLineInput> Lines,
    IReadOnlyList<WholesaleTenderInput> Tenders, WholesaleShippingInput Shipping, string Reason)
    : ICommand<WholesaleInvoiceDto>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions =>
        new[] { PermissionNames.WholesaleInvoicePost };
}

public sealed record PostWholesaleInvoiceCommand(
    string TxNumber, IReadOnlyList<WholesaleTenderInput>? Tenders, string Reason,
    string? IdempotencyKey)
    : ICommand<WholesaleInvoiceDto>, IRequiresIdempotencyKey, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions =>
        new[] { PermissionNames.WholesaleInvoicePost };
}

public sealed record GetWholesaleInvoiceQuery(string TxNumber)
    : IQuery<WholesaleInvoiceDto>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions =>
        new[] { PermissionNames.WholesaleInvoicePost };
}

public sealed record ListWholesaleInvoicesQuery(
    int? CustomerId, string? Status, string? Cursor, int PageSize)
    : IQuery<PagedResult<WholesaleInvoiceDto>>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions =>
        new[] { PermissionNames.WholesaleInvoicePost };

    public string? AfterTxNumber => Cursor is null ? null : KeysetCursor.Decode(Cursor);
}

public sealed class WholesaleLineInputValidator : AbstractValidator<WholesaleLineInput>
{
    public WholesaleLineInputValidator()
    {
        RuleFor(x => x.Sku).NotEmpty().MaximumLength(13);
        RuleFor(x => x.Quantity).GreaterThan(0);
        RuleFor(x => x.BackorderQuantity).GreaterThanOrEqualTo(0);
        RuleFor(x => x.UnitAmount).GreaterThanOrEqualTo(0).When(x => x.UnitAmount is not null);
        RuleFor(x => x.DiscountAmount).GreaterThanOrEqualTo(0);
        RuleFor(x => x.TaxCode).MaximumLength(1);
        RuleFor(x => x.OverrideReason).MaximumLength(500);
        RuleFor(x => x.Description).MaximumLength(200);
    }
}

public sealed class WholesaleTenderInputValidator : AbstractValidator<WholesaleTenderInput>
{
    public WholesaleTenderInputValidator()
    {
        RuleFor(x => x.Method).NotEmpty().MaximumLength(2);
        RuleFor(x => x.Amount).GreaterThan(0);
        RuleFor(x => x.Reference).MaximumLength(10)
            .Must(reference => reference is null
                || !System.Text.RegularExpressions.Regex.IsMatch(reference, "\\d{12,}"))
            .WithMessage("The reference must be an opaque terminal reference, not card data.");
    }
}

public sealed class WholesaleShippingInputValidator : AbstractValidator<WholesaleShippingInput>
{
    public WholesaleShippingInputValidator()
    {
        RuleFor(x => x.ShippingMethod).MaximumLength(60);
        RuleFor(x => x.ShipToName).MaximumLength(120);
        RuleFor(x => x.ShipToAddress).MaximumLength(500);
        RuleFor(x => x.ShippingInstructions).MaximumLength(1000);
        RuleFor(x => x.PurchaseOrderNumber).MaximumLength(40);
    }
}

public sealed class CreateWholesaleInvoiceCommandValidator
    : AbstractValidator<CreateWholesaleInvoiceCommand>
{
    public CreateWholesaleInvoiceCommandValidator()
    {
        RuleFor(x => x.CustomerId).GreaterThan(0);
        RuleFor(x => x.StaffCode).NotEmpty().MaximumLength(4);
        RuleFor(x => x.Lines).NotEmpty();
        RuleForEach(x => x.Lines).SetValidator(new WholesaleLineInputValidator());
        RuleForEach(x => x.Tenders).SetValidator(new WholesaleTenderInputValidator());
        RuleFor(x => x.Shipping).SetValidator(new WholesaleShippingInputValidator());
        RuleFor(x => x.Reason).NotEmpty().MinimumLength(3).MaximumLength(500);
    }
}

public sealed class UpdateWholesaleInvoiceCommandValidator
    : AbstractValidator<UpdateWholesaleInvoiceCommand>
{
    public UpdateWholesaleInvoiceCommandValidator()
    {
        RuleFor(x => x.TxNumber).NotEmpty().MaximumLength(10);
        RuleFor(x => x.CustomerId).GreaterThan(0);
        RuleFor(x => x.StaffCode).NotEmpty().MaximumLength(4);
        RuleFor(x => x.Lines).NotEmpty();
        RuleForEach(x => x.Lines).SetValidator(new WholesaleLineInputValidator());
        RuleForEach(x => x.Tenders).SetValidator(new WholesaleTenderInputValidator());
        RuleFor(x => x.Shipping).SetValidator(new WholesaleShippingInputValidator());
        RuleFor(x => x.Reason).NotEmpty().MinimumLength(3).MaximumLength(500);
    }
}

internal static class WholesaleInvoicePreparation
{
    public static async Task<WholesaleInvoicePosting> PrepareAsync(
        string txNumber, int customerId, string staffCode, IReadOnlyList<WholesaleLineInput> lines,
        IReadOnlyList<WholesaleTenderInput> tenders, WholesaleShippingInput shipping,
        DateTimeOffset dateOfEntry, string? actor,
        IWholesaleInvoiceStore store, IWholesalePricingStore pricing,
        ICurrentPrincipal principal, IWholesalePolicy policy, CancellationToken ct)
    {
        if (!await store.CustomerExistsAsync(customerId, ct))
            throw Validation("CustomerId", "not-found", "Customer was not found.");
        var missing = await store.MissingSkusAsync(lines.Select(line => line.Sku), ct);
        if (missing.Count > 0)
            throw Validation("Sku", "not-found", $"Unknown SKU(s): {string.Join(", ", missing)}.");

        if (!policy.BackordersEnabled && lines.Any(line => line.BackorderQuantity > 0))
            throw Validation("Backorders", "disabled",
                "Backorders are disabled by the signed baseline; ship the full quantity.");

        var canOverride = principal.HasPermission(PermissionNames.SalesPriceOverride);
        var quotes = new List<WholesalePriceQuoteDto>(lines.Count);
        foreach (var line in lines)
        {
            quotes.Add(await pricing.QuoteAsync(customerId, line.Sku, line.UnitAmount,
                line.OverrideReason, canOverride, actor, ct));
        }

        var priced = SalesPricing.Price(lines.Select((line, index) =>
            new PricingLineInput(line.Sku, line.Quantity, quotes[index].AppliedUnitPrice,
                line.DiscountAmount, line.TaxCode)).ToList(),
            await store.TaxRatesAsync(ct));
        var computed = priced.Lines.Select((line, index) => new WholesaleComputedLine(
            line.Sku, lines[index].Description, line.Quantity, line.UnitAmount,
            line.DiscountAmount, line.Amount, line.TaxCode, line.TaxA, line.TaxB,
            quotes[index].PriceListCode, quotes[index].PriceListVersion,
            quotes[index].ListUnitPrice, quotes[index].IsOverride,
            quotes[index].OverrideReason, lines[index].BackorderQuantity)).ToList();

        var configured = (await store.PaymentMethodsAsync(ct))
            .Select(method => method.Code).ToHashSet(StringComparer.OrdinalIgnoreCase);
        foreach (var tender in tenders)
        {
            if (!configured.Contains(tender.Method))
                throw Validation("Tenders", "unknown-method",
                    $"Payment method '{tender.Method}' is not configured.");
        }
        var tenderTotal = decimal.Round(tenders.Sum(row => row.Amount), 4);
        if (tenderTotal > priced.GrossSale)
            throw Validation("Tenders", "over-total",
                $"Tenders {tenderTotal:0.0000} exceed the invoice total {priced.GrossSale:0.0000}.");

        var terms = await store.AccountTermsAsync(customerId, ct);
        var dueDate = shipping.DueDate
            ?? (terms.TermsDays > 0
                ? DateOnly.FromDateTime(dateOfEntry.UtcDateTime).AddDays(terms.TermsDays)
                : null);
        return new WholesaleInvoicePosting(txNumber, customerId, staffCode, dateOfEntry,
            "draft", terms.TermsCode, terms.TermsDays, shipping with { DueDate = dueDate },
            computed, tenders, priced.TotalSale, priced.TaxA, priced.TaxB, priced.GrossSale,
            priced.TotalQty, actor);
    }

    public static ValidationFailedException Validation(string field, string code,
        string message) => new(new[] { new ValidationFieldError(field, code, message) });
}

public sealed class CreateWholesaleInvoiceHandler(
    IUnitOfWork unitOfWork, IWholesaleInvoiceStore store, IWholesalePricingStore pricing,
    IControlNumberAllocator allocator, IClock clock, IAuditRecorder audit,
    ICurrentPrincipal principal, IWholesalePolicy policy)
    : IRequestHandler<CreateWholesaleInvoiceCommand, WholesaleInvoiceDto>
{
    public Task<WholesaleInvoiceDto> Handle(
        CreateWholesaleInvoiceCommand request, CancellationToken ct) =>
        unitOfWork.ExecuteInTransactionAsync(async token =>
        {
            var txNumber = await allocator.AllocateAsync(TransactionType.WholesaleInvoice, token);
            var posting = await WholesaleInvoicePreparation.PrepareAsync(txNumber.Value,
                request.CustomerId, request.StaffCode, request.Lines, request.Tenders,
                request.Shipping, clock.UtcNow, principal.UserId, store, pricing, principal,
                policy, token);
            await store.CreateAsync(posting, token);
            await audit.RecordAsync(new AuditRecord("wholesale.invoice.create", "TxHeader",
                txNumber.Value, JsonSerializer.Serialize(new
                {
                    request.CustomerId,
                    total = posting.TotalAmount,
                    request.Reason,
                    tenders = posting.Tenders.Select(row => new { row.Method, row.Amount }),
                })), token);
            await RecordOverridesAsync(audit, posting, request.Reason, token);
            return await store.GetAsync(txNumber.Value, token)
                ?? throw new InvalidOperationException("Wholesale invoice was not found after creation.");
        }, ct);

    internal static async Task RecordOverridesAsync(IAuditRecorder audit,
        WholesaleInvoicePosting posting, string reason, CancellationToken ct)
    {
        foreach (var line in posting.Lines.Where(line => line.IsOverride))
        {
            await audit.RecordAsync(new AuditRecord("wholesale.price.override", "TxHeader",
                posting.TxNumber, JsonSerializer.Serialize(new
                {
                    line.Sku,
                    line.PriceListCode,
                    line.PriceListVersion,
                    line.ListUnitPrice,
                    line.UnitAmount,
                    line.OverrideReason,
                    reason,
                })), ct);
        }
    }
}

public sealed class UpdateWholesaleInvoiceHandler(
    IUnitOfWork unitOfWork, IWholesaleInvoiceStore store, IWholesalePricingStore pricing,
    IAuditRecorder audit, ICurrentPrincipal principal, IWholesalePolicy policy)
    : IRequestHandler<UpdateWholesaleInvoiceCommand, WholesaleInvoiceDto>
{
    public Task<WholesaleInvoiceDto> Handle(
        UpdateWholesaleInvoiceCommand request, CancellationToken ct) =>
        unitOfWork.ExecuteInTransactionAsync(async token =>
        {
            var existing = await store.GetAsync(request.TxNumber, token);
            if (existing is null)
                throw WholesaleInvoicePreparation.Validation(
                    "TxNumber", "not-found", "Wholesale invoice was not found.");
            if (existing.Status != "draft")
                throw WholesaleInvoicePreparation.Validation(
                    "TxNumber", "not-editable", "Only draft wholesale invoices can be updated.");

            var posting = await WholesaleInvoicePreparation.PrepareAsync(existing.TxNumber,
                request.CustomerId, request.StaffCode, request.Lines, request.Tenders,
                request.Shipping, existing.DateOfEntry, principal.UserId, store, pricing,
                principal, policy, token);
            await store.UpdateAsync(posting, token);
            await audit.RecordAsync(new AuditRecord("wholesale.invoice.update", "TxHeader",
                existing.TxNumber, JsonSerializer.Serialize(new
                {
                    request.CustomerId,
                    total = posting.TotalAmount,
                    request.Reason,
                })), token);
            await CreateWholesaleInvoiceHandler.RecordOverridesAsync(
                audit, posting, request.Reason, token);
            return await store.GetAsync(existing.TxNumber, token) ?? existing;
        }, ct);
}

public sealed class PostWholesaleInvoiceCommandValidator
    : AbstractValidator<PostWholesaleInvoiceCommand>
{
    public PostWholesaleInvoiceCommandValidator()
    {
        RuleFor(x => x.TxNumber).NotEmpty().MaximumLength(10);
        RuleForEach(x => x.Tenders).SetValidator(new WholesaleTenderInputValidator());
        RuleFor(x => x.Reason).NotEmpty().MinimumLength(3).MaximumLength(500);
    }
}

public sealed class PostWholesaleInvoiceHandler(
    IUnitOfWork unitOfWork, IWholesaleInvoiceStore store, IAuditRecorder audit,
    IPaymentTerminal terminal, IClock clock, ICurrentPrincipal principal)
    : IRequestHandler<PostWholesaleInvoiceCommand, WholesaleInvoiceDto>
{
    public Task<WholesaleInvoiceDto> Handle(
        PostWholesaleInvoiceCommand request, CancellationToken ct) =>
        unitOfWork.ExecuteInTransactionAsync(async token =>
        {
            var existing = await store.GetAsync(request.TxNumber, token)
                ?? throw WholesaleInvoicePreparation.Validation(
                    "TxNumber", "not-found", "Wholesale invoice was not found.");
            if (existing.Status != "draft")
                throw WholesaleInvoicePreparation.Validation(
                    "TxNumber", "not-draft", "Only draft wholesale invoices can be posted.");

            var tenders = request.Tenders ?? existing.Tenders;
            var total = decimal.Round(tenders.Sum(row => row.Amount), 4);
            if (total > existing.TotalAmount)
                throw WholesaleInvoicePreparation.Validation("Tenders", "over-total",
                    $"Tenders {total:0.0000} exceed the invoice total {existing.TotalAmount:0.0000}.");

            var configured = (await store.PaymentMethodsAsync(token))
                .Select(method => method.Code).ToHashSet(StringComparer.OrdinalIgnoreCase);
            await TenderAuthorization.AuthorizeAsync(configured,
                tenders.Select(tender => (tender.Method, tender.Amount, tender.Reference)).ToList(),
                terminal, request.IdempotencyKey, token);

            var control = await store.NextControlNumberAsync(token);
            var now = clock.UtcNow;
            await store.PostAsync(existing.TxNumber, tenders, control, now,
                principal.BranchCode ?? "01", principal.UserId, token);
            await audit.RecordAsync(new AuditRecord("wholesale.invoice.post", "TxHeader",
                existing.TxNumber, JsonSerializer.Serialize(new
                {
                    control,
                    total = existing.TotalAmount,
                    paid = total,
                    balance = decimal.Round(existing.TotalAmount - total, 4),
                    request.Reason,
                    tenders = tenders.Select(row => new { row.Method, row.Amount }),
                })), token);
            return await store.GetAsync(existing.TxNumber, token)
                ?? throw new InvalidOperationException(
                    "Wholesale invoice was not found after posting.");
        }, ct);
}

public sealed class GetWholesaleInvoiceHandler(IWholesaleInvoiceStore store)
    : IRequestHandler<GetWholesaleInvoiceQuery, WholesaleInvoiceDto>
{
    public async Task<WholesaleInvoiceDto> Handle(
        GetWholesaleInvoiceQuery request, CancellationToken ct) =>
        await store.GetAsync(request.TxNumber, ct)
        ?? throw WholesaleInvoicePreparation.Validation(
            "TxNumber", "not-found", "Wholesale invoice was not found.");
}

public sealed class ListWholesaleInvoicesHandler(IWholesaleInvoiceStore store)
    : IRequestHandler<ListWholesaleInvoicesQuery, PagedResult<WholesaleInvoiceDto>>
{
    public async Task<PagedResult<WholesaleInvoiceDto>> Handle(
        ListWholesaleInvoicesQuery request, CancellationToken ct)
    {
        var size = Math.Clamp(request.PageSize, 1, 100);
        var rows = await store.ListAsync(request.CustomerId, request.Status,
            request.AfterTxNumber, size + 1, ct);
        var hasMore = rows.Count > size;
        var page = hasMore ? rows.Take(size).ToList() : rows.ToList();
        return new PagedResult<WholesaleInvoiceDto>(page,
            hasMore ? KeysetCursor.Encode(page[^1].TxNumber) : null);
    }
}
