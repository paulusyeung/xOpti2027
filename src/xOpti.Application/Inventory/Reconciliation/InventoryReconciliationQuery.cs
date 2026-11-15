using xOpti.Application.Authorization;
using xOpti.Application.Common;

namespace xOpti.Application.Inventory.Reconciliation;

public sealed record ReconciliationRowDto(
    string Sku, int InventoryQuantity, int LotQuantity, int Difference,
    IReadOnlyList<string> AffectedLots);

public sealed record InventoryReconciliationDto(
    int CheckedSkus, IReadOnlyList<ReconciliationRowDto> Drifts);

public interface IInventoryReconciliationStore
{
    Task<InventoryReconciliationDto> CheckAsync(CancellationToken ct);
}

public sealed record GetInventoryReconciliationQuery
    : IQuery<InventoryReconciliationDto>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.InventoryAdjust };
}

public sealed class GetInventoryReconciliationHandler(IInventoryReconciliationStore store)
    : IRequestHandler<GetInventoryReconciliationQuery, InventoryReconciliationDto>
{
    public Task<InventoryReconciliationDto> Handle(GetInventoryReconciliationQuery request, CancellationToken ct) =>
        store.CheckAsync(ct);
}
