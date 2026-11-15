using xOpti.Application.Authorization;
using xOpti.Application.Common;

namespace xOpti.Application.Inventory.Summaries;

public sealed record SummaryRowDto(string Key, int Quantity, decimal Amount, int Lines);
public sealed record SummaryGroupDto(string Level, IReadOnlyList<SummaryRowDto> Rows);
public sealed record InventorySummariesDto(
    DateOnly From, DateOnly To, IReadOnlyList<SummaryGroupDto> Groups);

public sealed record GetInventorySummariesQuery(DateOnly From, DateOnly To)
    : IQuery<InventorySummariesDto>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.InventoryAdjust };
}

public interface ISummaryStore
{
    Task<InventorySummariesDto> BuildAsync(DateOnly from, DateOnly to, CancellationToken ct);
}

public sealed class GetInventorySummariesHandler(ISummaryStore store)
    : IRequestHandler<GetInventorySummariesQuery, InventorySummariesDto>
{
    public Task<InventorySummariesDto> Handle(GetInventorySummariesQuery request, CancellationToken ct) =>
        store.BuildAsync(request.From, request.To, ct);
}
