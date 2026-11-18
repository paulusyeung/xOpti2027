using xOpti.Application.Payments;

namespace xOpti.Application.Wholesale;

public sealed record WholesaleLineInput(
    string Sku, int Quantity, decimal? UnitAmount, decimal DiscountAmount, string TaxCode,
    string? OverrideReason = null, string? Description = null, int BackorderQuantity = 0);

public sealed record WholesaleTenderInput(string Method, decimal Amount, string? Reference);

public sealed record WholesaleShippingInput(
    string? ShippingMethod, string? ShipToName, string? ShipToAddress,
    string? ShippingInstructions, string? PurchaseOrderNumber, DateOnly? DueDate);

public sealed record WholesaleInvoiceLineDto(
    int RowNo, string Sku, string? Description, int Quantity, decimal UnitAmount,
    decimal DiscountAmount, decimal Amount, decimal TaxA, decimal TaxB, string? TaxCode,
    string? PriceListCode, int? PriceListVersion, decimal ListUnitPrice,
    bool IsOverride, string? OverrideReason, int BackorderQuantity);

public sealed record WholesaleInvoiceDto(
    string TxNumber, int CustomerId, string? CustomerName, string? StaffCode,
    string Status, DateTimeOffset DateOfEntry, string? TermsCode, int TermsDays,
    DateOnly? DueDate, string? ShippingMethod, string? ShipToName, string? ShipToAddress,
    string? ShippingInstructions, string? PurchaseOrderNumber,
    decimal TotalSale, decimal TaxA, decimal TaxB, decimal TotalAmount, decimal Paid,
    int TotalQty, DateTimeOffset? PostedAt, string? PostedBy,
    IReadOnlyList<WholesaleInvoiceLineDto> Lines,
    IReadOnlyList<WholesaleTenderInput> Tenders);

public sealed record WholesaleComputedLine(
    string Sku, string? Description, int Quantity, decimal UnitAmount, decimal DiscountAmount,
    decimal Amount, string TaxCode, decimal TaxA, decimal TaxB, string PriceListCode,
    int PriceListVersion, decimal ListUnitPrice, bool IsOverride, string? OverrideReason,
    int BackorderQuantity);

public sealed record WholesaleInvoicePosting(
    string TxNumber, int CustomerId, string StaffCode, DateTimeOffset DateOfEntry,
    string Status, string? TermsCode, int TermsDays, WholesaleShippingInput Shipping,
    IReadOnlyList<WholesaleComputedLine> Lines, IReadOnlyList<WholesaleTenderInput> Tenders,
    decimal TotalSale, decimal TaxA, decimal TaxB, decimal TotalAmount, int TotalQty,
    string? Actor);

public sealed record WholesaleBackorderDto(
    long Id, string OriginalTxNumber, int OriginalRowNo, int CustomerId, string Sku,
    int OrderedQuantity, int ShippedQuantity, int RemainingQuantity, string Status,
    DateTimeOffset CreatedAt, string? FulfilledByTxNumber, DateTimeOffset? FulfilledAt);

public interface IWholesaleInvoiceStore
{
    Task<bool> CustomerExistsAsync(int customerId, CancellationToken ct);

    Task<IReadOnlyList<string>> MissingSkusAsync(IEnumerable<string> skus, CancellationToken ct);

    Task<(double GstRate, double PstRate)> TaxRatesAsync(CancellationToken ct);

    Task<IReadOnlyList<PaymentMethodDto>> PaymentMethodsAsync(CancellationToken ct);

    Task<(string? TermsCode, int TermsDays)> AccountTermsAsync(
        int customerId, CancellationToken ct);

    Task<string> NextControlNumberAsync(CancellationToken ct);

    Task CreateAsync(WholesaleInvoicePosting posting, CancellationToken ct);

    Task UpdateAsync(WholesaleInvoicePosting posting, CancellationToken ct);

    Task PostAsync(string txNumber, IReadOnlyList<WholesaleTenderInput> tenders,
        string controlNumber, DateTimeOffset now, string branchCode, string? actor,
        CancellationToken ct);

    Task<WholesaleInvoiceDto?> GetAsync(string txNumber, CancellationToken ct);

    Task<IReadOnlyList<WholesaleInvoiceDto>> ListAsync(
        int? customerId, string? status, string? afterTxNumber, int limit, CancellationToken ct);

    Task<IReadOnlyList<WholesaleBackorderDto>> GetBackordersAsync(
        string txNumber, CancellationToken ct);
}
