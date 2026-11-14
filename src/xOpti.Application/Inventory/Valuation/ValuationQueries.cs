using System.Text.Json.Serialization;
using FluentValidation;
using xOpti.Application.Authorization;
using xOpti.Application.Common;
using xOpti.Application.Ports;
using xOpti.Domain.Values;

namespace xOpti.Application.Inventory.Valuation;

public sealed record LotValuationDto(
    string LotNo,
    int QtyOnHand,
    [property: JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)] Money? UnitCost,
    [property: JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)] Money? ExtendedCost);

public sealed record InventoryValuationDto(
    string Sku,
    int QtyOnHand,
    IReadOnlyList<LotValuationDto> Lots,
    [property: JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)] Money? AverageCost,
    [property: JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)] Money? ExtendedCost)
    : ICanMaskCosts<InventoryValuationDto>
{
    public InventoryValuationDto WithoutCosts() => this with
    {
        AverageCost = null,
        ExtendedCost = null,
        Lots = Lots.Select(lot => lot with { UnitCost = null, ExtendedCost = null }).ToList(),
    };
}

public interface IValuationStore
{
    Task<InventoryValuationDto?> GetAsync(string sku, CancellationToken ct);
}

public sealed record GetInventoryValuationQuery(string Sku)
    : IQuery<InventoryValuationDto>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.InventoryAdjust };
}

public sealed class GetInventoryValuationQueryValidator : AbstractValidator<GetInventoryValuationQuery>
{
    public GetInventoryValuationQueryValidator() => RuleFor(x => x.Sku).NotEmpty();
}

public sealed class GetInventoryValuationHandler(
    IValuationStore store,
    ICurrentPrincipal principal)
    : IRequestHandler<GetInventoryValuationQuery, InventoryValuationDto>
{
    public async Task<InventoryValuationDto> Handle(
        GetInventoryValuationQuery request,
        CancellationToken ct)
    {
        var valuation = await store.GetAsync(request.Sku, ct)
            ?? throw new xOpti.Application.Pipeline.ValidationFailedException(new[]
            {
                new xOpti.Application.Pipeline.ValidationFieldError(
                    "Sku", "not-found", $"SKU '{request.Sku}' was not found."),
            });

        // Cost visibility is a projection decision, never a client concern.
        return valuation.MaskCost(principal);
    }
}
