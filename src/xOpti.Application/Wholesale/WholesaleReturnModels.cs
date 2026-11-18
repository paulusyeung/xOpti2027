using xOpti.Application.Payments;

namespace xOpti.Application.Wholesale;

public sealed record WholesaleReturnLineInput(
    int OriginalRowNo, int Quantity, bool Restock, string? DispositionReason = null);

public sealed record WholesaleReturnableLineDto(
    int RowNo, string Sku, int OriginalQuantity, int ReturnedQuantity, int AvailableQuantity,
    decimal UnitAmount, decimal UnitCost, decimal DiscountAmount, decimal Amount,
    decimal TaxA, decimal TaxB, decimal AvailableAmount, string? TaxCode);

public sealed record WholesaleReturnableInvoiceDto(
    string TxNumber, int CustomerId, string? CustomerName, DateTimeOffset DateOfEntry,
    decimal TotalSale, decimal TaxA, decimal TaxB, decimal TotalAmount,
    string? TermsCode, int TermsDays,
    IReadOnlyList<WholesaleReturnableLineDto> Lines);

public sealed record WholesaleReturnLineDto(
    int RowNo, int OriginalRowNo, string Sku, int Quantity, decimal UnitAmount,
    decimal UnitCost, decimal DiscountAmount, decimal Amount, decimal TaxA, decimal TaxB,
    string? TaxCode, bool Restock, string? DispositionReason);

public sealed record WholesaleReturnDto(
    string TxNumber, string OriginalInvoiceNumber, int CustomerId, string? CustomerName,
    string? StaffCode, string Status, DateTimeOffset DateOfEntry, string? TermsCode,
    int TermsDays, decimal TotalSale, decimal TaxA, decimal TaxB, decimal TotalAmount,
    decimal Refunded, DateTimeOffset? PostedAt, string? PostedBy,
    IReadOnlyList<WholesaleReturnLineDto> Lines,
    IReadOnlyList<WholesaleTenderInput> Tenders);

public sealed record WholesaleReturnPosting(
    string TxNumber, string OriginalInvoiceNumber, int CustomerId, string StaffCode,
    DateTimeOffset DateOfEntry, string? TermsCode, int TermsDays,
    IReadOnlyList<WholesaleReturnLineDto> Lines, IReadOnlyList<WholesaleTenderInput> Tenders,
    decimal TotalSale, decimal TaxA, decimal TaxB, decimal TotalAmount, int TotalQty,
    string? Actor);

public interface IWholesaleReturnStore
{
    Task<WholesaleReturnableInvoiceDto?> GetReturnableAsync(
        string invoiceNumber, string? excludeReturnTxNumber, CancellationToken ct);

    Task<IReadOnlyList<PaymentMethodDto>> PaymentMethodsAsync(CancellationToken ct);

    Task LockOriginalInvoiceAsync(string invoiceNumber, CancellationToken ct);

    Task<string> NextControlNumberAsync(CancellationToken ct);

    Task CreateAsync(WholesaleReturnPosting posting, CancellationToken ct);

    Task UpdateAsync(WholesaleReturnPosting posting, CancellationToken ct);

    Task PostAsync(string txNumber, IReadOnlyList<WholesaleTenderInput> tenders,
        string controlNumber, DateTimeOffset now, string branchCode, string? actor,
        CancellationToken ct);

    Task<WholesaleReturnDto?> GetAsync(string txNumber, CancellationToken ct);

    Task<IReadOnlyList<WholesaleReturnDto>> ListAsync(
        int? customerId, string? status, string? afterTxNumber, int limit, CancellationToken ct);
}
