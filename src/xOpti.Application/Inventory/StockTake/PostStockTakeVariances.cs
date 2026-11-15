using System.Text.Json;
using FluentValidation;
using xOpti.Application.Authorization;
using xOpti.Application.Common;
using xOpti.Application.Pipeline;
using xOpti.Application.Ports;
using xOpti.Domain.Values;

namespace xOpti.Application.Inventory.StockTake;

public sealed record StockTakeAdjustmentRow(string Sku, int Difference, decimal? AverageCost);

public sealed record PostStockTakeVariancesCommand(int HeaderId, string Reason)
    : ICommand<PostStockTakeVariancesResult>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.InventoryAdjust };
}

public sealed record PostStockTakeVariancesResult(
    int HeaderId, string TxNumber, int AdjustedRows, int TotalDifference, decimal TotalValue);

public interface IStockTakePostingStore
{
    Task<bool> IsApprovedAsync(int headerId, CancellationToken ct);
    Task<string> NextInventoryControlNumberAsync(CancellationToken ct);
    Task PostAsync(int headerId, string txNumber, string controlNumber,
        IReadOnlyList<StockTakeAdjustmentRow> rows, CancellationToken ct);
}

public sealed class PostStockTakeVariancesCommandValidator : AbstractValidator<PostStockTakeVariancesCommand>
{
    public PostStockTakeVariancesCommandValidator()
    {
        RuleFor(x => x.HeaderId).GreaterThan(0);
        RuleFor(x => x.Reason).NotEmpty().MinimumLength(3).MaximumLength(500);
    }
}

public sealed class PostStockTakeVariancesHandler(
    IUnitOfWork unitOfWork, IStockTakeVarianceStore variances,
    IStockTakePostingStore store, IControlNumberAllocator allocator, IAuditRecorder audit)
    : IRequestHandler<PostStockTakeVariancesCommand, PostStockTakeVariancesResult>
{
    public Task<PostStockTakeVariancesResult> Handle(
        PostStockTakeVariancesCommand request, CancellationToken ct) =>
        unitOfWork.ExecuteInTransactionAsync(async token =>
        {
            if (!await store.IsApprovedAsync(request.HeaderId, token))
            {
                throw new ValidationFailedException(new[]
                {
                    new ValidationFieldError("HeaderId", "not-approved",
                        "Only approved stock takes can post variances."),
                });
            }

            var variance = await variances.GetAsync(request.HeaderId, token)
                ?? throw new ValidationFailedException(new[]
                {
                    new ValidationFieldError("HeaderId", "not-found", "Stock take was not found."),
                });

            var rows = variance.Rows
                .Where(row => row.Difference is not null && row.Difference != 0)
                .Select(row => new StockTakeAdjustmentRow(
                    row.Sku, (int)(row.Difference ?? 0), row.AverageCost))
                .ToList();

            if (rows.Count == 0)
            {
                throw new ValidationFailedException(new[]
                {
                    new ValidationFieldError("HeaderId", "no-variance", "There are no variances to post."),
                });
            }

            var txNumber = await allocator.AllocateAsync(TransactionType.StockAdjustment, token);
            var controlNumber = await store.NextInventoryControlNumberAsync(token);
            await store.PostAsync(request.HeaderId, txNumber.Value, controlNumber, rows, token);

            var totalDifference = rows.Sum(row => row.Difference);
            var totalValue = decimal.Round(rows.Sum(row =>
                (row.AverageCost ?? 0) * row.Difference), 4);

            await audit.RecordAsync(new AuditRecord("stocktake.post", "InvtSTHeader",
                request.HeaderId.ToString(),
                JsonSerializer.Serialize(new
                {
                    reason = request.Reason, txNumber = txNumber.Value, rows = rows.Count,
                    totalDifference, totalValue,
                })), token);

            return new PostStockTakeVariancesResult(request.HeaderId, txNumber.Value,
                rows.Count, totalDifference, totalValue);
        }, ct);
}
