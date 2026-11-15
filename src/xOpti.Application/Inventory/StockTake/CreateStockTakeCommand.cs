using System.Text.Json;
using FluentValidation;
using xOpti.Application.Authorization;
using xOpti.Application.Common;
using xOpti.Application.Ports;

namespace xOpti.Application.Inventory.StockTake;

public sealed record StockTakeSnapshotRow(
    string Sku, double ComputerQty, decimal? AverageCost);

public sealed record CreateStockTakeCommand(string Name, string? BranchCode, string Reason)
    : ICommand<StockTakeDto>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.InventoryAdjust };
}

public sealed record StockTakeDto(
    int Id, string Name, string? BranchCode, short Status, int RowCount, DateTimeOffset FrozenAt);

public sealed record StockTakeSnapshot(
    int HeaderId, string Name, IReadOnlyList<StockTakeSnapshotRow> Rows);

public interface IStockTakeStore
{
    Task<int> NextHeaderIdAsync(CancellationToken ct);
    Task<IReadOnlyList<StockTakeSnapshotRow>> SnapshotAsync(string? branchCode, CancellationToken ct);
    Task CreateAsync(StockTakeSnapshot snapshot, DateTimeOffset frozenAt, CancellationToken ct);
}

public sealed class CreateStockTakeCommandValidator : AbstractValidator<CreateStockTakeCommand>
{
    public CreateStockTakeCommandValidator()
    {
        RuleFor(x => x.Name).NotEmpty().MaximumLength(30);
        RuleFor(x => x.BranchCode).MaximumLength(3);
        RuleFor(x => x.Reason).NotEmpty().MinimumLength(3).MaximumLength(500);
    }
}

public sealed class CreateStockTakeHandler(
    IUnitOfWork unitOfWork, IStockTakeStore store, IAuditRecorder audit, IClock clock)
    : IRequestHandler<CreateStockTakeCommand, StockTakeDto>
{
    public Task<StockTakeDto> Handle(CreateStockTakeCommand request, CancellationToken ct) =>
        unitOfWork.ExecuteInTransactionAsync(async token =>
        {
            var id = await store.NextHeaderIdAsync(token);
            var rows = await store.SnapshotAsync(request.BranchCode, token);
            var frozenAt = clock.UtcNow;
            await store.CreateAsync(new StockTakeSnapshot(id, request.Name, rows), frozenAt, token);

            await audit.RecordAsync(new AuditRecord("stocktake.freeze", "InvtSTHeader", id.ToString(),
                JsonSerializer.Serialize(new
                {
                    reason = request.Reason, branch = request.BranchCode, rows = rows.Count, frozenAt,
                })), token);

            return new StockTakeDto(id, request.Name, request.BranchCode, 1, rows.Count, frozenAt);
        }, ct);
}
