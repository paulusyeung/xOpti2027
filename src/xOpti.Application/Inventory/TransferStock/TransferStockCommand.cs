using System.Text.Json;
using FluentValidation;
using xOpti.Application.Authorization;
using xOpti.Application.Common;
using xOpti.Application.Pipeline;
using xOpti.Application.Ports;
using xOpti.Domain.Values;

namespace xOpti.Application.Inventory.TransferStock;

public sealed record TransferStockCommand(
    string Sku, string FromBranch, string ToBranch, int Quantity,
    string Reason, string? IdempotencyKey)
    : ICommand<TransferStockResult>, IRequiresIdempotencyKey, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.InventoryAdjust };
}

public sealed record TransferStockResult(
    string TransferId, string SourceTxNumber, string DestinationTxNumber,
    string Sku, int Quantity);

public sealed record TransferPosting(
    string TransferId, string SourceTxNumber, string DestinationTxNumber,
    string ControlNumber, string Sku, string FromBranch, string ToBranch,
    int Quantity, string Reason);

public interface ITransferStore
{
    Task<bool> BranchExistsAsync(string branchCode, CancellationToken ct);
    Task<int> OnHandAsync(string sku, string branchCode, CancellationToken ct);
    Task<string> NextInventoryControlNumberAsync(CancellationToken ct);
    Task PostAsync(TransferPosting posting, CancellationToken ct);
}

public sealed class TransferStockCommandValidator : AbstractValidator<TransferStockCommand>
{
    public TransferStockCommandValidator()
    {
        RuleFor(x => x.Sku).NotEmpty().MaximumLength(13);
        RuleFor(x => x.FromBranch).NotEmpty().MaximumLength(3);
        RuleFor(x => x.ToBranch).NotEmpty().MaximumLength(3).NotEqual(x => x.FromBranch);
        RuleFor(x => x.Quantity).GreaterThan(0);
        RuleFor(x => x.Reason).NotEmpty().MinimumLength(3).MaximumLength(500);
    }
}

public sealed class TransferStockHandler(
    IUnitOfWork unitOfWork, ITransferStore store,
    IControlNumberAllocator allocator, IAuditRecorder audit)
    : IRequestHandler<TransferStockCommand, TransferStockResult>
{
    public Task<TransferStockResult> Handle(TransferStockCommand request, CancellationToken ct) =>
        unitOfWork.ExecuteInTransactionAsync(async token =>
        {
            if (!await store.BranchExistsAsync(request.FromBranch, token)
                || !await store.BranchExistsAsync(request.ToBranch, token))
            {
                throw new ValidationFailedException(new[]
                {
                    new ValidationFieldError("ToBranch", "not-found", "Both branches must exist."),
                });
            }

            var available = await store.OnHandAsync(request.Sku, request.FromBranch, token);
            if (request.Quantity > available)
            {
                throw new ValidationFailedException(new[]
                {
                    new ValidationFieldError("Quantity", "insufficient",
                        $"Only {available} unit(s) available at branch '{request.FromBranch}'."),
                });
            }

            var source = await allocator.AllocateAsync(TransactionType.StockAdjustment, token);
            var destination = await allocator.AllocateAsync(TransactionType.StockAdjustment, token);
            var control = await store.NextInventoryControlNumberAsync(token);
            var transferId = "TR" + Guid.NewGuid().ToString("N")[..8].ToUpperInvariant();

            await store.PostAsync(new TransferPosting(transferId, source.Value, destination.Value,
                control, request.Sku, request.FromBranch, request.ToBranch,
                request.Quantity, request.Reason), token);

            await audit.RecordAsync(new AuditRecord("stock.transfer", "Transfer", transferId,
                JsonSerializer.Serialize(new
                {
                    reason = request.Reason, request.Sku, request.FromBranch, request.ToBranch,
                    request.Quantity, source = source.Value, destination = destination.Value,
                })), token);

            return new TransferStockResult(transferId, source.Value, destination.Value,
                request.Sku, request.Quantity);
        }, ct);
}
