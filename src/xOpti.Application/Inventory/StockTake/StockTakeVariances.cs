using System.Text.Json;
using FluentValidation;
using xOpti.Application.Authorization;
using xOpti.Application.Common;
using xOpti.Application.Pipeline;
using xOpti.Application.Ports;

namespace xOpti.Application.Inventory.StockTake;

public sealed record VarianceRowDto(
    string Sku, decimal? ComputerQty, int? CountedQty, decimal? Difference, decimal? AverageCost);

public sealed record StockTakeVarianceDto(
    int HeaderId, string Name, short Status, IReadOnlyList<VarianceRowDto> Rows);

public sealed record ApproveStockTakeCommand(int HeaderId, string Reason)
    : ICommand<StockTakeVarianceDto>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.InventoryAdjust };
}

public interface IStockTakeVarianceStore
{
    Task<StockTakeVarianceDto?> GetAsync(int headerId, CancellationToken ct);
    Task ApproveAsync(int headerId, CancellationToken ct);
}

public sealed class ApproveStockTakeCommandValidator :
    FluentValidation.AbstractValidator<ApproveStockTakeCommand>
{
    public ApproveStockTakeCommandValidator()
    {
        RuleFor(x => x.HeaderId).GreaterThan(0);
        RuleFor(x => x.Reason).NotEmpty().MinimumLength(3).MaximumLength(500);
    }
}

public sealed record GetStockTakeVariancesQuery(int HeaderId)
    : IQuery<StockTakeVarianceDto>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.InventoryAdjust };
}

public sealed class GetStockTakeVariancesHandler(IStockTakeVarianceStore store)
    : IRequestHandler<GetStockTakeVariancesQuery, StockTakeVarianceDto>
{
    public async Task<StockTakeVarianceDto> Handle(GetStockTakeVariancesQuery request, CancellationToken ct) =>
        await store.GetAsync(request.HeaderId, ct)
        ?? throw new ValidationFailedException(new[]
        {
            new ValidationFieldError("HeaderId", "not-found", "Stock take was not found."),
        });
}

public sealed class ApproveStockTakeHandler(
    IUnitOfWork unitOfWork, IStockTakeVarianceStore store, IAuditRecorder audit)
    : IRequestHandler<ApproveStockTakeCommand, StockTakeVarianceDto>
{
    public Task<StockTakeVarianceDto> Handle(ApproveStockTakeCommand request, CancellationToken ct) =>
        unitOfWork.ExecuteInTransactionAsync(async token =>
        {
            var current = await store.GetAsync(request.HeaderId, token)
                ?? throw new ValidationFailedException(new[]
                {
                    new ValidationFieldError("HeaderId", "not-found", "Stock take was not found."),
                });

            var uncounted = current.Rows.Count(row => row.CountedQty is null);
            if (uncounted > 0)
            {
                throw new ValidationFailedException(new[]
                {
                    new ValidationFieldError("CountedQty", "incomplete",
                        $"{uncounted} snapshot row(s) have no counted quantity."),
                });
            }

            await store.ApproveAsync(request.HeaderId, token);
            await audit.RecordAsync(new AuditRecord("stocktake.approve", "InvtSTHeader",
                request.HeaderId.ToString(),
                JsonSerializer.Serialize(new { reason = request.Reason })), token);

            return await store.GetAsync(request.HeaderId, token) ?? current;
        }, ct);
}
