using FluentValidation;
using System.Text.Json.Serialization;
using xOpti.Application.Authorization;
using xOpti.Application.Common;
using xOpti.Application.Ports;
using xOpti.Domain.Values;

namespace xOpti.Application.Inventory.GetInventorySummary;

/// <summary>
/// Read-only inventory summary used by administration and POS lookups. Cost is
/// projected per caller: it is omitted from the JSON (not nulled) unless the
/// principal holds <c>cost:view</c>.
/// </summary>
public sealed record GetInventorySummaryQuery(string Sku)
    : IQuery<InventorySummaryDto>,
      IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.InventoryAdjust };
}

public sealed record InventorySummaryDto(
    string Sku,
    string? Name,
    int QtyOnHand,
    bool LotTracked,
    [property: JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)] Money? AverageCost)
    : ICanMaskCosts<InventorySummaryDto>
{
    public InventorySummaryDto WithoutCosts() => this with { AverageCost = null };
}

public sealed class GetInventorySummaryQueryValidator : AbstractValidator<GetInventorySummaryQuery>
{
    public GetInventorySummaryQueryValidator()
    {
        RuleFor(x => x.Sku).NotEmpty().MaximumLength(20);
    }
}

public sealed class GetInventorySummaryHandler(
    IInventorySummaryRepository repository,
    ICurrentPrincipal principal)
    : IRequestHandler<GetInventorySummaryQuery, InventorySummaryDto>
{
    public async Task<InventorySummaryDto> Handle(
        GetInventorySummaryQuery request,
        CancellationToken cancellationToken)
    {
        var inventory = await repository.FindBySkuAsync(request.Sku, cancellationToken)
            ?? throw new DomainRuleException($"SKU '{request.Sku}' was not found.");

        var dto = new InventorySummaryDto(
            inventory.Sku,
            inventory.Name,
            inventory.QtyTotalOnHand,
            inventory.InventoryLotFlag,
            inventory.AverageCost);

        return dto.MaskCost(principal);
    }
}

public interface IInventorySummaryRepository
{
    Task<InventorySummary?> FindBySkuAsync(string sku, CancellationToken cancellationToken);
}

public sealed record InventorySummary(
    string Sku,
    string? Name,
    int QtyTotalOnHand,
    bool InventoryLotFlag,
    Money AverageCost);
