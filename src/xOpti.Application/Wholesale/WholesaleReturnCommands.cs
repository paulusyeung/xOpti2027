using System.Text.Json;
using FluentValidation;
using xOpti.Application.Authorization;
using xOpti.Application.Common;
using xOpti.Application.Pipeline;
using xOpti.Application.Ports;
using xOpti.Application.Sales;
using xOpti.Domain.Values;

namespace xOpti.Application.Wholesale;

public sealed record CreateWholesaleReturnCommand(
    string OriginalInvoiceNumber, string StaffCode, IReadOnlyList<WholesaleReturnLineInput> Lines,
    IReadOnlyList<WholesaleTenderInput> Tenders, string Reason, string? IdempotencyKey)
    : ICommand<WholesaleReturnDto>, IRequiresIdempotencyKey, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions =>
        new[] { PermissionNames.WholesaleInvoicePost };
}

public sealed record UpdateWholesaleReturnCommand(
    string TxNumber, string OriginalInvoiceNumber, string StaffCode,
    IReadOnlyList<WholesaleReturnLineInput> Lines, IReadOnlyList<WholesaleTenderInput> Tenders,
    string Reason)
    : ICommand<WholesaleReturnDto>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions =>
        new[] { PermissionNames.WholesaleInvoicePost };
}

public sealed record PostWholesaleReturnCommand(
    string TxNumber, IReadOnlyList<WholesaleTenderInput>? Tenders, string Reason,
    string? IdempotencyKey)
    : ICommand<WholesaleReturnDto>, IRequiresIdempotencyKey, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions =>
        new[] { PermissionNames.WholesaleInvoicePost };
}

public sealed record GetWholesaleReturnableQuery(string InvoiceNumber)
    : IQuery<WholesaleReturnableInvoiceDto>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions =>
        new[] { PermissionNames.WholesaleInvoicePost };
}

public sealed record GetWholesaleReturnQuery(string TxNumber)
    : IQuery<WholesaleReturnDto>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions =>
        new[] { PermissionNames.WholesaleInvoicePost };
}

public sealed record ListWholesaleReturnsQuery(
    int? CustomerId, string? Status, string? Cursor, int PageSize)
    : IQuery<PagedResult<WholesaleReturnDto>>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions =>
        new[] { PermissionNames.WholesaleInvoicePost };

    public string? AfterTxNumber => Cursor is null ? null : KeysetCursor.Decode(Cursor);
}

public sealed class WholesaleReturnLineInputValidator
    : AbstractValidator<WholesaleReturnLineInput>
{
    public WholesaleReturnLineInputValidator()
    {
        RuleFor(x => x.OriginalRowNo).GreaterThan(0);
        RuleFor(x => x.Quantity).GreaterThan(0);
        RuleFor(x => x.DispositionReason).MaximumLength(500);
    }
}

public sealed class CreateWholesaleReturnCommandValidator
    : AbstractValidator<CreateWholesaleReturnCommand>
{
    public CreateWholesaleReturnCommandValidator()
    {
        RuleFor(x => x.OriginalInvoiceNumber).NotEmpty().MaximumLength(10);
        RuleFor(x => x.StaffCode).NotEmpty().MaximumLength(4);
        RuleFor(x => x.Lines).NotEmpty();
        RuleForEach(x => x.Lines).SetValidator(new WholesaleReturnLineInputValidator());
        RuleForEach(x => x.Tenders).SetValidator(new WholesaleTenderInputValidator());
        RuleFor(x => x.Reason).NotEmpty().MinimumLength(3).MaximumLength(500);
    }
}

public sealed class UpdateWholesaleReturnCommandValidator
    : AbstractValidator<UpdateWholesaleReturnCommand>
{
    public UpdateWholesaleReturnCommandValidator()
    {
        RuleFor(x => x.TxNumber).NotEmpty().MaximumLength(10);
        RuleFor(x => x.OriginalInvoiceNumber).NotEmpty().MaximumLength(10);
        RuleFor(x => x.StaffCode).NotEmpty().MaximumLength(4);
        RuleFor(x => x.Lines).NotEmpty();
        RuleForEach(x => x.Lines).SetValidator(new WholesaleReturnLineInputValidator());
        RuleForEach(x => x.Tenders).SetValidator(new WholesaleTenderInputValidator());
        RuleFor(x => x.Reason).NotEmpty().MinimumLength(3).MaximumLength(500);
    }
}

public sealed class PostWholesaleReturnCommandValidator
    : AbstractValidator<PostWholesaleReturnCommand>
{
    public PostWholesaleReturnCommandValidator()
    {
        RuleFor(x => x.TxNumber).NotEmpty().MaximumLength(10);
        RuleForEach(x => x.Tenders).SetValidator(new WholesaleTenderInputValidator());
        RuleFor(x => x.Reason).NotEmpty().MinimumLength(3).MaximumLength(500);
    }
}

internal static class WholesaleReturnPreparation
{
    public static async Task<WholesaleReturnPosting> PrepareAsync(
        string txNumber, string originalInvoiceNumber, string staffCode,
        IReadOnlyList<WholesaleReturnLineInput> lines, IReadOnlyList<WholesaleTenderInput> tenders,
        DateTimeOffset dateOfEntry, string? actor, IWholesaleReturnStore store,
        CancellationToken ct)
    {
        await store.LockOriginalInvoiceAsync(originalInvoiceNumber, ct);
        var returnable = await store.GetReturnableAsync(originalInvoiceNumber, txNumber, ct)
            ?? throw Validation("OriginalInvoiceNumber", "not-returnable",
                "The original wholesale invoice was not found or is not posted.");

        var duplicates = lines.GroupBy(line => line.OriginalRowNo)
            .Where(group => group.Count() > 1).Select(group => group.Key).ToList();
        if (duplicates.Count > 0)
            throw Validation("OriginalRowNo", "duplicate",
                $"Original line(s) appear more than once: {string.Join(", ", duplicates)}.");

        var computed = new List<WholesaleReturnLineDto>(lines.Count);
        var rowNo = 1;
        foreach (var input in lines)
        {
            var original = returnable.Lines.SingleOrDefault(line =>
                line.RowNo == input.OriginalRowNo)
                ?? throw Validation("OriginalRowNo", "not-found",
                    $"Original invoice line {input.OriginalRowNo} was not found.");
            if (input.Quantity > original.AvailableQuantity)
                throw Validation("Quantity", "over-return",
                    $"Line {input.OriginalRowNo} has only {original.AvailableQuantity} "
                    + $"returnable unit(s); {input.Quantity} requested.");
            if (!input.Restock && string.IsNullOrWhiteSpace(input.DispositionReason))
                throw Validation("DispositionReason", "required",
                    "A reason is required when a returned line is written off.");
            if (original.OriginalQuantity <= 0)
                throw Validation("OriginalRowNo", "invalid-quantity",
                    $"Original invoice line {input.OriginalRowNo} has no returnable quantity.");

            var ratio = (decimal)input.Quantity / original.OriginalQuantity;
            var discount = decimal.Round(original.DiscountAmount * ratio, 4);
            var amount = -decimal.Round(original.Amount * ratio, 4);
            var taxA = -decimal.Round(original.TaxA * ratio, 4);
            var taxB = -decimal.Round(original.TaxB * ratio, 4);
            var credit = decimal.Round(Math.Abs(amount) + Math.Abs(taxA) + Math.Abs(taxB), 4);
            if (credit > original.AvailableAmount + 0.0001m)
                throw Validation("Quantity", "over-amount",
                    $"Line {input.OriginalRowNo} has only {original.AvailableAmount:0.0000} "
                    + $"returnable credit; {credit:0.0000} requested.");

            computed.Add(new WholesaleReturnLineDto(rowNo++, input.OriginalRowNo,
                original.Sku, input.Quantity, original.UnitAmount, original.UnitCost,
                discount, amount, taxA, taxB, original.TaxCode, input.Restock,
                input.DispositionReason));
        }

        var totalSale = decimal.Round(computed.Sum(line => line.Amount), 4);
        var totalTaxA = decimal.Round(computed.Sum(line => line.TaxA), 4);
        var totalTaxB = decimal.Round(computed.Sum(line => line.TaxB), 4);
        var total = decimal.Round(totalSale + totalTaxA + totalTaxB, 4);
        var creditTotal = Math.Abs(total);

        var configured = (await store.PaymentMethodsAsync(ct))
            .Select(method => method.Code).ToHashSet(StringComparer.OrdinalIgnoreCase);
        foreach (var tender in tenders)
        {
            if (!configured.Contains(tender.Method))
                throw Validation("Tenders", "unknown-method",
                    $"Payment method '{tender.Method}' is not configured.");
        }
        var refunded = decimal.Round(tenders.Sum(row => row.Amount), 4);
        if (refunded > creditTotal)
            throw Validation("Tenders", "over-credit",
                $"Refund tenders {refunded:0.0000} exceed the return credit {creditTotal:0.0000}.");

        return new WholesaleReturnPosting(txNumber, originalInvoiceNumber,
            returnable.CustomerId, staffCode, dateOfEntry, returnable.TermsCode,
            returnable.TermsDays, computed, tenders, totalSale, totalTaxA, totalTaxB, total,
            -computed.Sum(line => line.Quantity), actor);
    }

    public static ValidationFailedException Validation(string field, string code,
        string message) => new(new[] { new ValidationFieldError(field, code, message) });
}

public sealed class CreateWholesaleReturnHandler(
    IUnitOfWork unitOfWork, IWholesaleReturnStore store, IControlNumberAllocator allocator,
    IClock clock, IAuditRecorder audit, ICurrentPrincipal principal)
    : IRequestHandler<CreateWholesaleReturnCommand, WholesaleReturnDto>
{
    public Task<WholesaleReturnDto> Handle(
        CreateWholesaleReturnCommand request, CancellationToken ct) =>
        unitOfWork.ExecuteInTransactionAsync(async token =>
        {
            var prepared = await WholesaleReturnPreparation.PrepareAsync(string.Empty,
                request.OriginalInvoiceNumber, request.StaffCode, request.Lines, request.Tenders,
                clock.UtcNow, principal.UserId, store, token);
            var txNumber = await allocator.AllocateAsync(TransactionType.WholesaleReturn, token);
            var posting = prepared with { TxNumber = txNumber.Value };
            await store.CreateAsync(posting, token);
            await audit.RecordAsync(new AuditRecord("wholesale.return.create", "TxHeader",
                txNumber.Value, JsonSerializer.Serialize(new
                {
                    request.OriginalInvoiceNumber,
                    credit = posting.TotalAmount,
                    request.Reason,
                    dispositions = posting.Lines.Select(line => new
                    {
                        line.Sku, line.Quantity, line.Restock, line.DispositionReason,
                    }),
                })), token);
            return await store.GetAsync(txNumber.Value, token)
                ?? throw new InvalidOperationException("Wholesale return was not found after creation.");
        }, ct);
}

public sealed class UpdateWholesaleReturnHandler(
    IUnitOfWork unitOfWork, IWholesaleReturnStore store, IAuditRecorder audit,
    ICurrentPrincipal principal)
    : IRequestHandler<UpdateWholesaleReturnCommand, WholesaleReturnDto>
{
    public Task<WholesaleReturnDto> Handle(
        UpdateWholesaleReturnCommand request, CancellationToken ct) =>
        unitOfWork.ExecuteInTransactionAsync(async token =>
        {
            var existing = await store.GetAsync(request.TxNumber, token)
                ?? throw WholesaleReturnPreparation.Validation(
                    "TxNumber", "not-found", "Wholesale return was not found.");
            if (existing.Status != "draft")
                throw WholesaleReturnPreparation.Validation(
                    "TxNumber", "not-editable", "Only draft wholesale returns can be updated.");
            if (existing.OriginalInvoiceNumber != request.OriginalInvoiceNumber)
                throw WholesaleReturnPreparation.Validation("OriginalInvoiceNumber", "mismatch",
                    "The original invoice cannot change on an existing return.");

            var posting = await WholesaleReturnPreparation.PrepareAsync(existing.TxNumber,
                existing.OriginalInvoiceNumber, request.StaffCode, request.Lines, request.Tenders,
                existing.DateOfEntry, principal.UserId, store, token);
            await store.UpdateAsync(posting, token);
            await audit.RecordAsync(new AuditRecord("wholesale.return.update", "TxHeader",
                existing.TxNumber, JsonSerializer.Serialize(new
                {
                    existing.OriginalInvoiceNumber,
                    credit = posting.TotalAmount,
                    request.Reason,
                })), token);
            return await store.GetAsync(existing.TxNumber, token) ?? existing;
        }, ct);
}

public sealed class PostWholesaleReturnHandler(
    IUnitOfWork unitOfWork, IWholesaleReturnStore store, IAuditRecorder audit,
    IClock clock, ICurrentPrincipal principal)
    : IRequestHandler<PostWholesaleReturnCommand, WholesaleReturnDto>
{
    public Task<WholesaleReturnDto> Handle(
        PostWholesaleReturnCommand request, CancellationToken ct) =>
        unitOfWork.ExecuteInTransactionAsync(async token =>
        {
            var existing = await store.GetAsync(request.TxNumber, token)
                ?? throw WholesaleReturnPreparation.Validation(
                    "TxNumber", "not-found", "Wholesale return was not found.");
            if (existing.Status != "draft")
                throw WholesaleReturnPreparation.Validation(
                    "TxNumber", "not-draft", "Only draft wholesale returns can be posted.");

            var tenders = request.Tenders ?? existing.Tenders;
            var refunded = decimal.Round(tenders.Sum(row => row.Amount), 4);
            var credit = Math.Abs(existing.TotalAmount);
            if (refunded > credit)
                throw WholesaleReturnPreparation.Validation("Tenders", "over-credit",
                    $"Refund tenders {refunded:0.0000} exceed the return credit {credit:0.0000}.");

            if (request.Tenders is not null)
            {
                var configured = (await store.PaymentMethodsAsync(token))
                    .Select(method => method.Code).ToHashSet(StringComparer.OrdinalIgnoreCase);
                foreach (var tender in tenders)
                {
                    if (!configured.Contains(tender.Method))
                        throw WholesaleReturnPreparation.Validation("Tenders", "unknown-method",
                            $"Payment method '{tender.Method}' is not configured.");
                }
            }

            var control = await store.NextControlNumberAsync(token);
            var now = clock.UtcNow;
            await store.PostAsync(existing.TxNumber, tenders, control, now,
                principal.BranchCode ?? "01", principal.UserId, token);
            await audit.RecordAsync(new AuditRecord("wholesale.return.post", "TxHeader",
                existing.TxNumber, JsonSerializer.Serialize(new
                {
                    control,
                    existing.OriginalInvoiceNumber,
                    credit,
                    refunded,
                    request.Reason,
                    dispositions = existing.Lines.Select(line => new
                    {
                        line.Sku, line.Quantity, line.Restock, line.DispositionReason,
                    }),
                })), token);
            return await store.GetAsync(existing.TxNumber, token)
                ?? throw new InvalidOperationException("Wholesale return was not found after posting.");
        }, ct);
}

public sealed class GetWholesaleReturnableHandler(IWholesaleReturnStore store)
    : IRequestHandler<GetWholesaleReturnableQuery, WholesaleReturnableInvoiceDto>
{
    public async Task<WholesaleReturnableInvoiceDto> Handle(
        GetWholesaleReturnableQuery request, CancellationToken ct) =>
        await store.GetReturnableAsync(request.InvoiceNumber, null, ct)
        ?? throw WholesaleReturnPreparation.Validation("InvoiceNumber", "not-returnable",
            "The original wholesale invoice was not found or is not posted.");
}

public sealed class GetWholesaleReturnHandler(IWholesaleReturnStore store)
    : IRequestHandler<GetWholesaleReturnQuery, WholesaleReturnDto>
{
    public async Task<WholesaleReturnDto> Handle(
        GetWholesaleReturnQuery request, CancellationToken ct) =>
        await store.GetAsync(request.TxNumber, ct)
        ?? throw WholesaleReturnPreparation.Validation(
            "TxNumber", "not-found", "Wholesale return was not found.");
}

public sealed class ListWholesaleReturnsHandler(IWholesaleReturnStore store)
    : IRequestHandler<ListWholesaleReturnsQuery, PagedResult<WholesaleReturnDto>>
{
    public async Task<PagedResult<WholesaleReturnDto>> Handle(
        ListWholesaleReturnsQuery request, CancellationToken ct)
    {
        var size = Math.Clamp(request.PageSize, 1, 100);
        var rows = await store.ListAsync(request.CustomerId, request.Status,
            request.AfterTxNumber, size + 1, ct);
        var hasMore = rows.Count > size;
        var page = hasMore ? rows.Take(size).ToList() : rows.ToList();
        return new PagedResult<WholesaleReturnDto>(page,
            hasMore ? KeysetCursor.Encode(page[^1].TxNumber) : null);
    }
}
