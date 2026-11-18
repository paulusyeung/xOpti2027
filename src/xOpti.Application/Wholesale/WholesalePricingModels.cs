namespace xOpti.Application.Wholesale;

public sealed record WholesalePriceItemInput(string Sku, decimal Price);

public sealed record WholesalePriceItemDto(string Sku, decimal Price);

public sealed record WholesalePriceListDto(
    long Id, string Code, string Name, int Version, bool IsCurrent,
    DateTimeOffset CreatedAt, IReadOnlyList<WholesalePriceItemDto> Items);

public sealed record PublishWholesalePriceListInput(
    string Code, string Name, IReadOnlyList<WholesalePriceItemInput> Items);

/// <summary>
/// Resolved line price with the exact list/version that produced it. Persisting
/// this snapshot on a document line keeps historical prices stable.
/// </summary>
public sealed record WholesalePriceQuoteDto(
    int CustomerId, string Sku, string PriceListCode, int PriceListVersion,
    decimal ListUnitPrice, decimal AppliedUnitPrice, bool IsOverride,
    string? OverrideReason, string? OverrideBy);

public sealed record WholesaleDocumentLineDto(
    string TxNumber, double RowNo, string PriceListCode, int PriceListVersion,
    decimal ListUnitPrice, decimal AppliedUnitPrice, bool IsOverride,
    string? OverrideReason, string? OverrideBy, DateTimeOffset CreatedAt);

public interface IWholesalePricingStore
{
    Task<WholesalePriceListDto> PublishAsync(PublishWholesalePriceListInput input,
        string? actor, CancellationToken ct);

    Task<WholesalePriceListDto?> GetCurrentAsync(string code, CancellationToken ct);

    Task<IReadOnlyList<WholesalePriceListDto>> ListCurrentAsync(CancellationToken ct);

    Task<int> ImportLegacyGradesAsync(string? actor, CancellationToken ct);

    Task<WholesalePriceQuoteDto> QuoteAsync(int customerId, string sku,
        decimal? requestedUnitPrice, string? overrideReason, bool canOverride,
        string? actor, CancellationToken ct);

    Task RecordDocumentLineAsync(string txNumber, double rowNo,
        WholesalePriceQuoteDto quote, CancellationToken ct);

    Task<IReadOnlyList<WholesaleDocumentLineDto>> GetDocumentLinesAsync(
        string txNumber, CancellationToken ct);
}
