using System.Text.Json;
using FluentValidation;
using xOpti.Application.Authorization;
using xOpti.Application.Common;
using xOpti.Application.Pipeline;
using xOpti.Application.Ports;
using xOpti.Domain.Values;

namespace xOpti.Application.Inventory.AdjustStock;

public static class AdjustmentReasonCodes
{
    public static readonly IReadOnlyList<string> All = new[]
    {
        "COUNT", "DAMAGE", "FOUND", "CORRECTION", "THEFT", "EXPIRY",
    };
}

public sealed record AdjustStockCommand(
    string Sku,
    string BranchCode,
    int QuantityDelta,
    string ReasonCode,
    string Reason,
    bool AllowNegative,
    string? IdempotencyKey)
    : ICommand<AdjustStockResult>, IRequiresIdempotencyKey, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.InventoryAdjust };
}

public sealed record AdjustStockResult(
    string TxNumber, string ControlNumber, int QuantityDelta, int NewOnHand);

public sealed record AdjustmentPosting(
    string TxNumber, string ControlNumber, string Sku, string BranchCode,
    int QuantityDelta, string ReasonCode, string Reason);

public interface IAdjustmentStore
{
    Task<int> OnHandAsync(string sku, string branchCode, CancellationToken ct);
    Task<string> NextInventoryControlNumberAsync(CancellationToken ct);
    Task PostAsync(AdjustmentPosting posting, CancellationToken ct);
}

public sealed class AdjustStockCommandValidator : AbstractValidator<AdjustStockCommand>
{
    public AdjustStockCommandValidator()
    {
        RuleFor(x => x.Sku).NotEmpty().MaximumLength(13);
        RuleFor(x => x.BranchCode).NotEmpty().MaximumLength(3);
        RuleFor(x => x.QuantityDelta).NotEqual(0);
        RuleFor(x => x.ReasonCode).NotEmpty().Must(AdjustmentReasonCodes.All.Contains)
            .WithMessage("Reason code is not approved.");
        RuleFor(x => x.Reason).NotEmpty().MinimumLength(3).MaximumLength(500);
    }
}

public sealed class AdjustStockHandler(
    IUnitOfWork unitOfWork, IAdjustmentStore store,
    IControlNumberAllocator allocator, IAuditRecorder audit)
    : IRequestHandler<AdjustStockCommand, AdjustStockResult>
{
    public Task<AdjustStockResult> Handle(AdjustStockCommand request, CancellationToken ct) =>
        unitOfWork.ExecuteInTransactionAsync(async token =>
        {
            var onHand = await store.OnHandAsync(request.Sku, request.BranchCode, token);
            var newOnHand = onHand + request.QuantityDelta;
            if (newOnHand < 0 && !request.AllowNegative)
            {
                throw new ValidationFailedException(new[]
                {
                    new ValidationFieldError("QuantityDelta", "below-zero",
                        $"Adjustment would leave {newOnHand}; shortfall is {-newOnHand}. Confirm the deficit explicitly."),
                });
            }

            var txNumber = await allocator.AllocateAsync(TransactionType.StockAdjustment, token);
            var controlNumber = await store.NextInventoryControlNumberAsync(token);
            await store.PostAsync(new AdjustmentPosting(txNumber.Value, controlNumber,
                request.Sku, request.BranchCode, request.QuantityDelta,
                request.ReasonCode, request.Reason), token);

            await audit.RecordAsync(new AuditRecord("stock.adjust", "TxHeader", txNumber.Value,
                JsonSerializer.Serialize(new
                {
                    reason = request.Reason, request.ReasonCode, request.Sku, request.BranchCode,
                    before = onHand, delta = request.QuantityDelta, after = newOnHand,
                })), token);

            return new AdjustStockResult(txNumber.Value, controlNumber, request.QuantityDelta, newOnHand);
        }, ct);
}
