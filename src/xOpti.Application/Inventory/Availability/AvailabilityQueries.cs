using FluentValidation;
using xOpti.Application.Authorization;
using xOpti.Application.Common;
using xOpti.Application.Pipeline;
using xOpti.Application.Ports;
using xOpti.Domain.Values;

namespace xOpti.Application.Inventory.Availability;

public sealed record LotAvailabilityDto(
    string LotNo, string SupplierCode, DateTimeOffset DateReceived,
    int QtyPurchased, int QtyUsed, int QtyOnHand);

public sealed record BranchAvailabilityDto(string BranchCode, int QtyOnHand);

public sealed record SkuAvailabilityDto(
    string Sku,
    int QtyTotalOnHand,
    int QtySaleOrder,
    int QtyPurchaseOrder,
    IReadOnlyList<BranchAvailabilityDto> Branches,
    IReadOnlyList<LotAvailabilityDto> Lots);

public sealed record MovementDto(
    DateTimeOffset DateOfEntry,
    string TxType,
    string TxNumber,
    int RowNo,
    int Qty,
    Money UnitAmount,
    Money Amount,
    string? TaxCode);

public interface IAvailabilityStore
{
    Task<SkuAvailabilityDto?> GetAvailabilityAsync(string sku, CancellationToken ct);

    Task<IReadOnlyList<MovementDto>> PageMovementsAsync(
        string sku, string? beforeCursor, int limit, CancellationToken ct);
}

public sealed record GetSkuAvailabilityQuery(string Sku)
    : IQuery<SkuAvailabilityDto>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.InventoryAdjust };
}

public sealed class GetSkuAvailabilityQueryValidator : AbstractValidator<GetSkuAvailabilityQuery>
{
    public GetSkuAvailabilityQueryValidator() => RuleFor(x => x.Sku).NotEmpty();
}

public sealed class GetSkuAvailabilityHandler(IAvailabilityStore store)
    : IRequestHandler<GetSkuAvailabilityQuery, SkuAvailabilityDto>
{
    public async Task<SkuAvailabilityDto> Handle(GetSkuAvailabilityQuery request, CancellationToken ct) =>
        await store.GetAvailabilityAsync(request.Sku, ct)
        ?? throw new ValidationFailedException(new[]
        {
            new ValidationFieldError("Sku", "not-found", $"SKU '{request.Sku}' was not found."),
        });
}

public sealed record ListSkuMovementsQuery(string Sku, string? Cursor, int PageSize)
    : IQuery<PagedResult<MovementDto>>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.InventoryAdjust };

    public string? BeforeCursor => Cursor is null ? null : KeysetCursor.Decode(Cursor);
}

public sealed class ListSkuMovementsQueryValidator : AbstractValidator<ListSkuMovementsQuery>
{
    public ListSkuMovementsQueryValidator()
    {
        RuleFor(x => x.Sku).NotEmpty();
        RuleFor(x => x.PageSize).InclusiveBetween(1, 200);
    }
}

public sealed class ListSkuMovementsHandler(IAvailabilityStore store)
    : IRequestHandler<ListSkuMovementsQuery, PagedResult<MovementDto>>
{
    public async Task<PagedResult<MovementDto>> Handle(ListSkuMovementsQuery request, CancellationToken ct)
    {
        var rows = await store.PageMovementsAsync(request.Sku, request.BeforeCursor, request.PageSize + 1, ct);
        var hasMore = rows.Count > request.PageSize;
        var page = hasMore ? rows.Take(request.PageSize).ToList() : rows.ToList();

        string? next = null;
        if (hasMore)
        {
            var last = page[^1];
            next = KeysetCursor.Encode(
                $"{last.DateOfEntry.UtcDateTime:O}|{last.TxNumber}|{last.RowNo}");
        }

        return new PagedResult<MovementDto>(page, next);
    }
}
