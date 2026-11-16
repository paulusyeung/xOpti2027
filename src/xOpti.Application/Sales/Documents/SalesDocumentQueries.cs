using System.Text.Json.Serialization;
using xOpti.Application.Authorization;
using xOpti.Application.Common;
using xOpti.Application.Pipeline;

namespace xOpti.Application.Sales.Documents;

public sealed record SalesDocumentLineDto(
    int RowNo, string Sku, int Qty, decimal UnitAmount, decimal DiscountAmount,
    [property: JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)] decimal? UnitCost,
    decimal Amount, string? TaxCode);

public sealed record SalesDocumentPaymentDto(
    double PaymentLineNo, string Type, decimal AmountTender, decimal AppliedAmount, string? Reference);

public sealed record SalesDocumentDto(
    string TxNumber, string TxType, string Kind, string ControlNumber, DateTimeOffset DateOfEntry,
    int CustomerId, string? CustomerName, string? Status, string StatusLabel, string? RefNumber,
    decimal TotalSale, decimal TaxA, decimal TaxB, decimal GrossSale, decimal Change, decimal TotalAmount,
    int TotalQty, decimal Paid, decimal Balance,
    IReadOnlyList<SalesDocumentLineDto> Lines,
    IReadOnlyList<SalesDocumentPaymentDto> Payments);

public interface ISalesDocumentStore
{
    Task<SalesDocumentDto?> GetAsync(string txNumber, CancellationToken ct);
    Task<IReadOnlyList<SalesDocumentDto>> PageAsync(
        int? customerId, string? status, string? afterTxNumber, int limit, CancellationToken ct);
}

public sealed record GetSalesDocumentQuery(string TxNumber)
    : IQuery<SalesDocumentDto>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.SalesOrderCreate };
}

public sealed class GetSalesDocumentHandler(ISalesDocumentStore store)
    : IRequestHandler<GetSalesDocumentQuery, SalesDocumentDto>
{
    public async Task<SalesDocumentDto> Handle(GetSalesDocumentQuery request, CancellationToken ct) =>
        await store.GetAsync(request.TxNumber, ct)
        ?? throw new ValidationFailedException(new[]
        {
            new ValidationFieldError("TxNumber", "not-found", "Sales document was not found."),
        });
}

public sealed record ListSalesDocumentsQuery(
    int? CustomerId, string? Status, string? Cursor, int PageSize)
    : IQuery<PagedResult<SalesDocumentDto>>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.SalesOrderCreate };

    public string? AfterTxNumber => Cursor is null ? null : KeysetCursor.Decode(Cursor);
}

public sealed class ListSalesDocumentsHandler(ISalesDocumentStore store)
    : IRequestHandler<ListSalesDocumentsQuery, PagedResult<SalesDocumentDto>>
{
    public async Task<PagedResult<SalesDocumentDto>> Handle(ListSalesDocumentsQuery request, CancellationToken ct)
    {
        var rows = await store.PageAsync(request.CustomerId, request.Status, request.AfterTxNumber,
            request.PageSize + 1, ct);
        var hasMore = rows.Count > request.PageSize;
        var page = hasMore ? rows.Take(request.PageSize).ToList() : rows.ToList();
        return new PagedResult<SalesDocumentDto>(page,
            hasMore ? KeysetCursor.Encode(page[^1].TxNumber) : null);
    }
}
