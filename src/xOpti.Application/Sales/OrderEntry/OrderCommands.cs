using System.Text.Json;
using FluentValidation;
using xOpti.Application.Authorization;
using xOpti.Application.Common;
using xOpti.Application.Pipeline;
using xOpti.Application.Optical;
using xOpti.Application.Payments;
using xOpti.Application.Ports;
using xOpti.Application.Sales.Documents;
using xOpti.Domain.Rules;
using xOpti.Domain.Values;

namespace xOpti.Application.Sales.OrderEntry;

public sealed record OrderLineInput(
    string Sku, int Quantity, decimal? UnitAmount, string TaxCode, decimal DiscountAmount = 0m);

public sealed record OrderPosting(
    string TxNumber, string ControlNumber, int CustomerId, string StaffCode,
    IReadOnlyList<OrderComputedLine> Lines, decimal TotalSale, decimal TaxA, decimal TaxB,
    decimal GrossSale, decimal Paid, int TotalQty, DateTimeOffset DateOfEntry);

public sealed record OrderComputedLine(
    string Sku, int Quantity, decimal UnitAmount, decimal DiscountAmount,
    decimal Amount, string TaxCode, decimal TaxA, decimal TaxB);

public sealed record CustomerLookupDto(int Id, string? FullName, string? VipCode);

public sealed record SalesItemLookupDto(
    string Sku, string? Name, decimal? RetailPrice, string? TaxCode, int QtyOnHand);

public sealed record PosContextDto(double TaxARate, double TaxBRate);

public interface IOrderStore
{
    Task<bool> CustomerExistsAsync(int customerId, CancellationToken ct);
    Task<IReadOnlyList<CustomerLookupDto>> SearchCustomersAsync(
        string? search, int limit, CancellationToken ct);
    Task<IReadOnlyList<SalesItemLookupDto>> SearchItemsAsync(
        string? search, int limit, CancellationToken ct);
    Task<IReadOnlyList<string>> MissingSkusAsync(IEnumerable<string> skus, CancellationToken ct);
    Task<IReadOnlyDictionary<string, decimal?>> RetailPricesAsync(
        IEnumerable<string> skus, CancellationToken ct);
    Task<(double GstRate, double PstRate)> TaxRatesAsync(CancellationToken ct);
    Task<IReadOnlyList<PaymentMethodDto>> PaymentMethodsAsync(CancellationToken ct);
    Task AddDepositAsync(string txNumber, decimal amount, string method, string? reference,
        CancellationToken ct);
    Task<string> NextControlNumberAsync(CancellationToken ct);
    Task CreateAsync(OrderPosting posting, CancellationToken ct);
    Task UpdateAsync(OrderPosting posting, CancellationToken ct);
    Task CancelAsync(string txNumber, string reason, string? actor, CancellationToken ct);
    Task<SalesDocumentDto?> GetOrderAsync(string txNumber, CancellationToken ct);
    Task<IReadOnlyList<SalesDocumentDto>> PageOrdersAsync(
        int? customerId, string? status, string? afterTxNumber, int limit, CancellationToken ct);
    Task<ConversionOutcome?> ConvertAsync(
        string txNumber, IReadOnlyList<TenderInput> tenders, long? sessionId, string? actor,
        CancellationToken ct);
    Task<SalesDocumentDto?> GetInvoiceAsync(string invoiceNumber, CancellationToken ct);
}

public sealed record TenderInput(string Method, decimal Amount, string? Reference);

public sealed record ConversionOutcome(string InvoiceNumber, int IssuedQuantity, decimal TotalCost);

public sealed record CreateOrderCommand(
    int CustomerId, string StaffCode, IReadOnlyList<OrderLineInput> Lines,
    decimal DepositAmount, string Reason, string? IdempotencyKey)
    : ICommand<SalesDocumentDto>, IRequiresIdempotencyKey, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.SalesOrderCreate };
}

public sealed record UpdateOrderCommand(
    string TxNumber, int CustomerId, string StaffCode, IReadOnlyList<OrderLineInput> Lines,
    decimal DepositAmount, string Reason)
    : ICommand<SalesDocumentDto>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.SalesOrderCreate };
}

public sealed record CancelOrderCommand(string TxNumber, string Reason)
    : ICommand<bool>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.SalesOrderCreate };
}

public sealed record ConvertOrderCommand(
    string TxNumber, IReadOnlyList<TenderInput> Tenders, long? SessionId, string Reason,
    string? IdempotencyKey)
    : ICommand<SalesDocumentDto>, IRequiresIdempotencyKey, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.SalesInvoicePost };
}

public sealed class OrderLineValidator : AbstractValidator<OrderLineInput>
{
    public OrderLineValidator()
    {
        RuleFor(x => x.Sku).NotEmpty().MaximumLength(13);
        RuleFor(x => x.Quantity).GreaterThan(0);
        RuleFor(x => x.UnitAmount).GreaterThanOrEqualTo(0).When(x => x.UnitAmount is not null);
        RuleFor(x => x.DiscountAmount).GreaterThanOrEqualTo(0);
        RuleFor(x => x.TaxCode).MaximumLength(1);
    }
}

public sealed class CreateOrderCommandValidator : AbstractValidator<CreateOrderCommand>
{
    public CreateOrderCommandValidator()
    {
        RuleFor(x => x.CustomerId).GreaterThan(0);
        RuleFor(x => x.StaffCode).NotEmpty().MaximumLength(4);
        RuleFor(x => x.Lines).NotEmpty();
        RuleForEach(x => x.Lines).SetValidator(new OrderLineValidator());
        RuleFor(x => x.DepositAmount).GreaterThanOrEqualTo(0);
        RuleFor(x => x.Reason).NotEmpty().MinimumLength(3).MaximumLength(500);
    }
}

public sealed class UpdateOrderCommandValidator : AbstractValidator<UpdateOrderCommand>
{
    public UpdateOrderCommandValidator()
    {
        RuleFor(x => x.TxNumber).NotEmpty();
        RuleFor(x => x.CustomerId).GreaterThan(0);
        RuleFor(x => x.StaffCode).NotEmpty().MaximumLength(4);
        RuleFor(x => x.Lines).NotEmpty();
        RuleForEach(x => x.Lines).SetValidator(new OrderLineValidator());
        RuleFor(x => x.Reason).NotEmpty().MinimumLength(3).MaximumLength(500);
    }
}

public sealed class CancelOrderCommandValidator : AbstractValidator<CancelOrderCommand>
{
    public CancelOrderCommandValidator()
    {
        RuleFor(x => x.TxNumber).NotEmpty();
        RuleFor(x => x.Reason).NotEmpty().MinimumLength(3).MaximumLength(500);
    }
}

public sealed class ConvertOrderCommandValidator : AbstractValidator<ConvertOrderCommand>
{
    public ConvertOrderCommandValidator()
    {
        RuleFor(x => x.TxNumber).NotEmpty();
        RuleFor(x => x.Reason).NotEmpty().MinimumLength(3).MaximumLength(500);
        RuleForEach(x => x.Tenders).ChildRules(tender =>
        {
            tender.RuleFor(x => x.Method).NotEmpty().MaximumLength(2);
            tender.RuleFor(x => x.Amount).GreaterThan(0);
            tender.RuleFor(x => x.Reference).MaximumLength(10);
        });
    }
}

internal static class OrderPricing
{
    public static (OrderPosting Posting, List<OrderComputedLine> Lines) Compute(
        string txNumber, string controlNumber, int customerId, string staffCode,
        IReadOnlyList<OrderLineInput> lines, decimal deposit,
        (double GstRate, double PstRate) rates, DateTimeOffset now)
    {
        var priced = SalesPricing.Price(
            lines.Select(line => new PricingLineInput(line.Sku, line.Quantity,
                line.UnitAmount ?? 0m, line.DiscountAmount, line.TaxCode)).ToList(),
            rates);
        var computed = priced.Lines
            .Select(line => new OrderComputedLine(line.Sku, line.Quantity, line.UnitAmount,
                line.DiscountAmount, line.Amount, line.TaxCode, line.TaxA, line.TaxB))
            .ToList();

        if (deposit > priced.GrossSale)
            throw new ValidationFailedException(new[]
            {
                new ValidationFieldError("DepositAmount", "over-total",
                    "The deposit cannot exceed the order total."),
            });
        var posting = new OrderPosting(txNumber, controlNumber, customerId, staffCode, computed,
            priced.TotalSale, priced.TaxA, priced.TaxB, priced.GrossSale, deposit,
            priced.TotalQty, now);
        return (posting, computed);
    }
}

public sealed class CreateOrderHandler(
    IUnitOfWork unitOfWork, IOrderStore store, IControlNumberAllocator allocator,
    IAuditRecorder audit, IClock clock, ICurrentPrincipal principal, IPosPolicy policy)
    : IRequestHandler<CreateOrderCommand, SalesDocumentDto>
{
    public Task<SalesDocumentDto> Handle(CreateOrderCommand request, CancellationToken ct) =>
        unitOfWork.ExecuteInTransactionAsync(async token =>
        {
            var (lines, overrides) = await ValidateAndResolveAsync(
                store, request.CustomerId, request.Lines, principal, policy, token);
            var txNumber = await allocator.AllocateAsync(TransactionType.SalesOrder, token);
            var control = await store.NextControlNumberAsync(token);
            var (posting, _) = OrderPricing.Compute(txNumber.Value, control, request.CustomerId,
                request.StaffCode, lines, request.DepositAmount,
                await store.TaxRatesAsync(token), clock.UtcNow);
            await store.CreateAsync(posting, token);
            await audit.RecordAsync(new AuditRecord("order.create", "TxHeader", txNumber.Value,
                JsonSerializer.Serialize(new { reason = request.Reason, total = posting.GrossSale })), token);
            await PriceOverrideRules.RecordAuditAsync(audit, txNumber.Value, overrides, request.Reason, token);
            return await store.GetOrderAsync(txNumber.Value, token) ?? throw new InvalidOperationException();
        }, ct);

    internal static async Task<(List<OrderLineInput> Lines, IReadOnlyList<PriceOverrideNote> Overrides)>
        ValidateAndResolveAsync(
            IOrderStore store, int customerId, IReadOnlyList<OrderLineInput> lines,
            ICurrentPrincipal principal, IPosPolicy policy, CancellationToken ct)
    {
        if (!await store.CustomerExistsAsync(customerId, ct))
            throw new ValidationFailedException(new[]
            {
                new ValidationFieldError("CustomerId", "not-found", "Customer was not found."),
            });
        var missing = await store.MissingSkusAsync(lines.Select(line => line.Sku), ct);
        if (missing.Count > 0)
            throw new ValidationFailedException(new[]
            {
                new ValidationFieldError("Sku", "not-found", $"Unknown SKU(s): {string.Join(", ", missing)}."),
            });

        var retailPrices = await store.RetailPricesAsync(lines.Select(line => line.Sku), ct);
        var resolved = lines.Select(line => line with
        {
            UnitAmount = line.UnitAmount ?? retailPrices.GetValueOrDefault(line.Sku) ?? 0m,
        }).ToList();
        var overrides = PriceOverrideRules.Validate(
            resolved.Select(line => new PricingLineInput(line.Sku, line.Quantity,
                line.UnitAmount ?? 0m, line.DiscountAmount, line.TaxCode)).ToList(),
            retailPrices, PriceOverrideRules.CanOverride(principal), policy.DiscountThresholdPercent);
        return (resolved, overrides);
    }

}

public sealed class UpdateOrderHandler(
    IUnitOfWork unitOfWork, IOrderStore store, IAuditRecorder audit,
    ICurrentPrincipal principal, IPosPolicy policy)
    : IRequestHandler<UpdateOrderCommand, SalesDocumentDto>
{
    public Task<SalesDocumentDto> Handle(UpdateOrderCommand request, CancellationToken ct) =>
        unitOfWork.ExecuteInTransactionAsync(async token =>
        {
            var existing = await store.GetOrderAsync(request.TxNumber, token);
            if (existing is null || existing.Kind != "Order")
                throw new ValidationFailedException(new[]
                {
                    new ValidationFieldError("TxNumber", "not-found", "Sale order was not found."),
                });
            if (existing.Status != "0")
                throw new ValidationFailedException(new[]
                {
                    new ValidationFieldError("TxNumber", "not-editable", "Only open orders can be updated."),
                });

            var (lines, overrides) = await CreateOrderHandler.ValidateAndResolveAsync(
                store, request.CustomerId, request.Lines, principal, policy, token);
            // Detail rows share the header's composite key, so an edit keeps the
            // original entry timestamp instead of restamping the lines.
            var (posting, _) = OrderPricing.Compute(existing.TxNumber, existing.ControlNumber,
                request.CustomerId, request.StaffCode, lines, request.DepositAmount,
                await store.TaxRatesAsync(token), existing.DateOfEntry);
            await store.UpdateAsync(posting, token);
            await audit.RecordAsync(new AuditRecord("order.update", "TxHeader", existing.TxNumber,
                JsonSerializer.Serialize(new { reason = request.Reason, total = posting.GrossSale })), token);
            await PriceOverrideRules.RecordAuditAsync(
                audit, existing.TxNumber, overrides, request.Reason, token);
            return await store.GetOrderAsync(existing.TxNumber, token) ?? existing;
        }, ct);
}

public sealed class CancelOrderHandler(
    IUnitOfWork unitOfWork, IOrderStore store, IAuditRecorder audit, ICurrentPrincipal principal)
    : IRequestHandler<CancelOrderCommand, bool>
{
    public Task<bool> Handle(CancelOrderCommand request, CancellationToken ct) =>
        unitOfWork.ExecuteInTransactionAsync(async token =>
        {
            var existing = await store.GetOrderAsync(request.TxNumber, token);
            if (existing is null || existing.Kind != "Order")
                throw new ValidationFailedException(new[]
                {
                    new ValidationFieldError("TxNumber", "not-found", "Sale order was not found."),
                });
            if (existing.Status != "0")
                throw new ValidationFailedException(new[]
                {
                    new ValidationFieldError("TxNumber", "not-cancellable", "Only open orders can be cancelled."),
                });

            await store.CancelAsync(existing.TxNumber, request.Reason, principal.UserId, token);
            await audit.RecordAsync(new AuditRecord("order.cancel", "TxHeader", existing.TxNumber,
                JsonSerializer.Serialize(new { reason = request.Reason })), token);
            return true;
        }, ct);
}

public sealed class ConvertOrderHandler(
    IUnitOfWork unitOfWork, IOrderStore store, IAuditRecorder audit,
    IOpticalOrderStore opticalStore, IPrescriptionPolicy prescriptionPolicy)
    : IRequestHandler<ConvertOrderCommand, SalesDocumentDto>
{
    public Task<SalesDocumentDto> Handle(ConvertOrderCommand request, CancellationToken ct) =>
        unitOfWork.ExecuteInTransactionAsync(async token =>
        {
            var order = await store.GetOrderAsync(request.TxNumber, token);
            if (order is null || order.Kind != "Order")
                throw new ValidationFailedException(new[]
                {
                    new ValidationFieldError("TxNumber", "not-found", "Sale order was not found."),
                });

            if (order.Status == "3" && !string.IsNullOrWhiteSpace(order.RefNumber))
            {
                return await store.GetInvoiceAsync(order.RefNumber, token)
                    ?? throw new InvalidOperationException("Converted invoice was not found.");
            }

            if (order.Status != "0")
                throw new ValidationFailedException(new[]
                {
                    new ValidationFieldError("TxNumber", "not-convertible", "Only open orders can be invoiced."),
                });

            var opticalIssues = await opticalStore.ConversionIssuesAsync(
                request.TxNumber, prescriptionPolicy.RequireVerificationBeforeOrder, token);
            if (opticalIssues.Count > 0)
                throw new ValidationFailedException(new[]
                {
                    new ValidationFieldError("Optical", "not-ready",
                        string.Join(" ", opticalIssues)),
                });

            // Only the outstanding balance is tendered; the deposit is already on
            // the order and is applied once during conversion.
            var tenderTotal = decimal.Round(request.Tenders.Sum(row => row.Amount), 4);
            if (tenderTotal != decimal.Round(order.Balance, 4))
                throw new ValidationFailedException(new[]
                {
                    new ValidationFieldError("Tenders", "balance-mismatch",
                        $"Tenders must equal the outstanding balance {order.Balance:0.00}."),
                });

            var outcome = await store.ConvertAsync(
                request.TxNumber, request.Tenders, request.SessionId, null, token)
                ?? throw new ValidationFailedException(new[]
                {
                    new ValidationFieldError("TxNumber", "conversion-failed", "Order could not be converted."),
                });

            await audit.RecordAsync(new AuditRecord("order.convert", "TxHeader", outcome.InvoiceNumber,
                JsonSerializer.Serialize(new
                {
                    reason = request.Reason, order = request.TxNumber,
                    issued = outcome.IssuedQuantity, cost = outcome.TotalCost,
                })), token);

            return await store.GetInvoiceAsync(outcome.InvoiceNumber, token)
                ?? throw new InvalidOperationException("Invoice was not found after conversion.");
        }, ct);
}

public sealed record ListOrdersQuery(int? CustomerId, string? Status, string? Cursor, int PageSize)
    : IQuery<PagedResult<SalesDocumentDto>>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.SalesOrderCreate };

    public string? AfterTxNumber => Cursor is null ? null : KeysetCursor.Decode(Cursor);
}

public sealed class ListOrdersHandler(IOrderStore store)
    : IRequestHandler<ListOrdersQuery, PagedResult<SalesDocumentDto>>
{
    public async Task<PagedResult<SalesDocumentDto>> Handle(ListOrdersQuery request, CancellationToken ct)
    {
        var rows = await store.PageOrdersAsync(request.CustomerId, request.Status,
            request.AfterTxNumber, request.PageSize + 1, ct);
        var hasMore = rows.Count > request.PageSize;
        var page = hasMore ? rows.Take(request.PageSize).ToList() : rows.ToList();
        return new PagedResult<SalesDocumentDto>(page,
            hasMore ? KeysetCursor.Encode(page[^1].TxNumber) : null);
    }
}

public sealed record SearchPosCustomersQuery(string? Search, int Limit)
    : IQuery<IReadOnlyList<CustomerLookupDto>>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.SalesOrderCreate };
}

public sealed class SearchPosCustomersHandler(IOrderStore store)
    : IRequestHandler<SearchPosCustomersQuery, IReadOnlyList<CustomerLookupDto>>
{
    public Task<IReadOnlyList<CustomerLookupDto>> Handle(
        SearchPosCustomersQuery request, CancellationToken ct) =>
        store.SearchCustomersAsync(request.Search, Math.Clamp(request.Limit, 1, 50), ct);
}

public sealed record SearchPosItemsQuery(string? Search, int Limit)
    : IQuery<IReadOnlyList<SalesItemLookupDto>>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.SalesOrderCreate };
}

public sealed class SearchPosItemsHandler(IOrderStore store)
    : IRequestHandler<SearchPosItemsQuery, IReadOnlyList<SalesItemLookupDto>>
{
    public Task<IReadOnlyList<SalesItemLookupDto>> Handle(
        SearchPosItemsQuery request, CancellationToken ct) =>
        store.SearchItemsAsync(request.Search, Math.Clamp(request.Limit, 1, 50), ct);
}

public sealed record GetPosContextQuery : IQuery<PosContextDto>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.SalesOrderCreate };
}

public sealed class GetPosContextHandler(IOrderStore store)
    : IRequestHandler<GetPosContextQuery, PosContextDto>
{
    public async Task<PosContextDto> Handle(GetPosContextQuery request, CancellationToken ct)
    {
        var rates = await store.TaxRatesAsync(ct);
        return new PosContextDto(rates.GstRate, rates.PstRate);
    }
}

public sealed record AddOrderDepositCommand(
    string TxNumber, decimal Amount, string Method, string? Reference, string Reason,
    string? IdempotencyKey)
    : ICommand<SalesDocumentDto>, IRequiresIdempotencyKey, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.SalesOrderCreate };
}

public sealed class AddOrderDepositCommandValidator : AbstractValidator<AddOrderDepositCommand>
{
    public AddOrderDepositCommandValidator()
    {
        RuleFor(x => x.TxNumber).NotEmpty();
        RuleFor(x => x.Amount).GreaterThan(0);
        RuleFor(x => x.Method).NotEmpty().MaximumLength(2);
        RuleFor(x => x.Reference).MaximumLength(10)
            .Must(reference => reference is null
                || !System.Text.RegularExpressions.Regex.IsMatch(reference, "\\d{12,}"))
            .WithMessage("The reference must be an opaque terminal reference, not card data.");
        RuleFor(x => x.Reason).NotEmpty().MinimumLength(3).MaximumLength(500);
    }
}

public sealed class AddOrderDepositHandler(
    IUnitOfWork unitOfWork, IOrderStore store, IAuditRecorder audit,
    IPaymentTerminal terminal)
    : IRequestHandler<AddOrderDepositCommand, SalesDocumentDto>
{
    public Task<SalesDocumentDto> Handle(AddOrderDepositCommand request, CancellationToken ct) =>
        unitOfWork.ExecuteInTransactionAsync(async token =>
        {
            var order = await store.GetOrderAsync(request.TxNumber, token);
            if (order is null || order.Kind != "Order")
                throw new ValidationFailedException(new[]
                {
                    new ValidationFieldError("TxNumber", "not-found", "Sale order was not found."),
                });
            if (order.Status != "0")
                throw new ValidationFailedException(new[]
                {
                    new ValidationFieldError("TxNumber", "not-open", "Only open orders can take a deposit."),
                });
            if (request.Amount > order.Balance)
                throw new ValidationFailedException(new[]
                {
                    new ValidationFieldError("Amount", "over-balance",
                        $"The deposit cannot exceed the balance {order.Balance:0.00}."),
                });

            var methods = await store.PaymentMethodsAsync(token);
            await TenderAuthorization.AuthorizeAsync(
                methods.Select(method => method.Code).ToHashSet(StringComparer.OrdinalIgnoreCase),
                new[] { (request.Method, request.Amount, request.Reference) },
                terminal, request.IdempotencyKey, token);

            await store.AddDepositAsync(order.TxNumber, request.Amount, request.Method,
                request.Reference, token);
            await audit.RecordAsync(new AuditRecord("order.deposit", "TxHeader", order.TxNumber,
                JsonSerializer.Serialize(new
                {
                    reason = request.Reason, amount = request.Amount,
                    method = request.Method, reference = request.Reference,
                })), token);
            return await store.GetOrderAsync(order.TxNumber, token)
                ?? throw new InvalidOperationException("Order was not found after the deposit.");
        }, ct);
}
