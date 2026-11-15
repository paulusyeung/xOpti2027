using System.Text.Json;
using FluentValidation;
using xOpti.Application.Authorization;
using xOpti.Application.Common;
using xOpti.Application.Pipeline;
using xOpti.Application.Ports;
using xOpti.Domain.Rules;
using xOpti.Domain.Values;

namespace xOpti.Application.Inventory.IssueStock;

public sealed record IssueConsumptionDto(string LotNo, int Quantity, decimal UnitCost, decimal Cost);

public sealed record IssueStockCommand(
    string Sku, string BranchCode, int Quantity, string Reason, string? IdempotencyKey)
    : ICommand<IssueStockResult>, IRequiresIdempotencyKey, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.InventoryAdjust };
}

public sealed record IssueStockResult(
    string TxNumber, string Method, decimal TotalCost, int DeficitQuantity,
    string? DeficitLotNo, IReadOnlyList<IssueConsumptionDto> Consumptions);

public interface IIssueStockStore
{
    Task<string?> CostingCodeAsync(string sku, CancellationToken ct);
    Task<IReadOnlyList<CostLayer>> LayersAsync(string sku, CancellationToken ct);
    Task<Money> FallbackCostAsync(string sku, CancellationToken ct);
    Task<string> NextControlNumberAsync(CancellationToken ct);
    Task PostAsync(string txNumber, string controlNumber, string sku, string branchCode,
        int quantity, IReadOnlyList<LayerConsumption> consumptions, int deficitQuantity,
        string? deficitLotNo, string method, string reason, CancellationToken ct);
}

public sealed class IssueStockCommandValidator : AbstractValidator<IssueStockCommand>
{
    public IssueStockCommandValidator()
    {
        RuleFor(x => x.Sku).NotEmpty().MaximumLength(13);
        RuleFor(x => x.BranchCode).NotEmpty().MaximumLength(3);
        RuleFor(x => x.Quantity).GreaterThan(0);
        RuleFor(x => x.Reason).NotEmpty().MinimumLength(3).MaximumLength(500);
    }
}

public sealed class IssueStockHandler(
    IUnitOfWork unitOfWork, IIssueStockStore store,
    IControlNumberAllocator allocator, IAuditRecorder audit)
    : IRequestHandler<IssueStockCommand, IssueStockResult>
{
    public Task<IssueStockResult> Handle(IssueStockCommand request, CancellationToken ct) =>
        unitOfWork.ExecuteInTransactionAsync(async token =>
        {
            var code = await store.CostingCodeAsync(request.Sku, token);
            if (code is null)
            {
                throw new ValidationFailedException(new[]
                {
                    new ValidationFieldError("Sku", "missing-cost-method",
                        $"SKU '{request.Sku}' has no category costing method."),
                });
            }

            var method = code.Trim() switch
            {
                "1" => CategoryCostingMethod.Fifo,
                "2" => CategoryCostingMethod.Lifo,
                "3" => CategoryCostingMethod.Average,
                _ => throw new ValidationFailedException(new[]
                {
                    new ValidationFieldError("Sku", "unsupported-cost-method",
                        $"Category costing method '{code}' is not supported."),
                }),
            };

            var layers = await store.LayersAsync(request.Sku, token);
            var fallback = await store.FallbackCostAsync(request.Sku, token);
            var txNumber = await allocator.AllocateAsync(TransactionType.StockAdjustment, token);
            var result = CostingPolicy.Issue(layers, txNumber.Value, Quantity.From(request.Quantity),
                method, fallback);
            if (!result.IsSuccess)
            {
                throw new ValidationFailedException(new[]
                {
                    new ValidationFieldError("Quantity", "costing", result.Error),
                });
            }

            var control = await store.NextControlNumberAsync(token);
            var deficitQty = (int)result.Value.DeficitQuantity.Value;
            var deficitLot = deficitQty > 0 ? "DEF" + txNumber.Value[^7..] : null;

            await store.PostAsync(txNumber.Value, control, request.Sku, request.BranchCode,
                request.Quantity, result.Value.Consumptions, deficitQty, deficitLot,
                method.ToString(), request.Reason, token);

            await audit.RecordAsync(new AuditRecord("stock.issue", "TxHeader", txNumber.Value,
                JsonSerializer.Serialize(new
                {
                    reason = request.Reason, request.Sku, request.BranchCode, request.Quantity,
                    method = method.ToString(), totalCost = result.Value.TotalCost.Amount,
                    deficitQty, deficitLot,
                })), token);

            return new IssueStockResult(txNumber.Value, method.ToString(),
                result.Value.TotalCost.Amount, deficitQty, deficitLot,
                result.Value.Consumptions.Select(row => new IssueConsumptionDto(
                    row.SourceDocument, (int)row.Quantity.Value, row.UnitCost.Amount, row.Cost.Amount)).ToList());
        }, ct);
}
