using System.Text.Json;
using FluentValidation;
using xOpti.Application.Authorization;
using xOpti.Application.Common;
using xOpti.Application.Pipeline;
using xOpti.Application.Ports;
using xOpti.Domain.Values;

namespace xOpti.Application.Purchasing.RejectStock;

public sealed record RejectStockLine(
    string Sku, string LotNo, int Quantity, decimal UnitCost,
    decimal GstAmount, decimal PstAmount, string TaxCode);

public sealed record RejectStockCommand(
    string SupplierCode,
    string BranchCode,
    string? OriginalTxNumber,
    IReadOnlyList<RejectStockLine> Lines,
    string? IdempotencyKey,
    string Reason)
    : ICommand<RejectStockResult>, IRequiresIdempotencyKey, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.InventoryReceive };
}

public sealed record RejectStockResult(
    string TxNumber, string ControlNumber, string? OriginalTxNumber,
    int TotalQuantity, decimal TotalCost, decimal TotalTax);

public sealed record RejectPosting(
    string TxNumber, string ControlNumber, string SupplierCode, string BranchCode,
    string? OriginalTxNumber, IReadOnlyList<RejectStockLine> Lines,
    decimal TotalCost, decimal TotalTax, int TotalQuantity);

public interface IRejectStockStore
{
    Task<int> AvailableQuantityAsync(string sku, string lotNo, CancellationToken ct);
    Task<string> NextInventoryControlNumberAsync(CancellationToken ct);
    Task PostAsync(RejectPosting posting, CancellationToken ct);
}

public sealed class RejectStockCommandValidator : AbstractValidator<RejectStockCommand>
{
    public RejectStockCommandValidator()
    {
        RuleFor(x => x.SupplierCode).NotEmpty().MaximumLength(4);
        RuleFor(x => x.BranchCode).NotEmpty().MaximumLength(3);
        RuleFor(x => x.Reason).NotEmpty().MinimumLength(3).MaximumLength(500);
        RuleFor(x => x.Lines).NotEmpty();
        RuleForEach(x => x.Lines).ChildRules(line =>
        {
            line.RuleFor(item => item.Sku).NotEmpty().MaximumLength(13);
            line.RuleFor(item => item.LotNo).NotEmpty().MaximumLength(10);
            line.RuleFor(item => item.Quantity).GreaterThan(0);
            line.RuleFor(item => item.UnitCost).GreaterThanOrEqualTo(0);
            line.RuleFor(item => item.GstAmount).GreaterThanOrEqualTo(0);
            line.RuleFor(item => item.PstAmount).GreaterThanOrEqualTo(0);
        });
    }
}

public sealed class RejectStockHandler(
    IUnitOfWork unitOfWork, IRejectStockStore store,
    IControlNumberAllocator allocator, IAuditRecorder audit)
    : IRequestHandler<RejectStockCommand, RejectStockResult>
{
    public Task<RejectStockResult> Handle(RejectStockCommand request, CancellationToken ct) =>
        unitOfWork.ExecuteInTransactionAsync(async token =>
        {
            foreach (var line in request.Lines)
            {
                var available = await store.AvailableQuantityAsync(line.Sku, line.LotNo, token);
                if (line.Quantity > available)
                {
                    throw new ValidationFailedException(new[]
                    {
                        new ValidationFieldError("Quantity", "insufficient",
                            $"Only {available} unit(s) available for SKU '{line.Sku}' in lot '{line.LotNo}'."),
                    });
                }
            }

            var totalCost = request.Lines.Sum(line => decimal.Round(line.UnitCost * line.Quantity, 4));
            var totalTax = request.Lines.Sum(line => line.GstAmount + line.PstAmount);
            var totalQuantity = request.Lines.Sum(line => line.Quantity);

            var txNumber = await allocator.AllocateAsync(TransactionType.StockRejected, token);
            var controlNumber = await store.NextInventoryControlNumberAsync(token);

            await store.PostAsync(new RejectPosting(
                txNumber.Value, controlNumber, request.SupplierCode, request.BranchCode,
                request.OriginalTxNumber, request.Lines, totalCost, totalTax, totalQuantity), token);

            await audit.RecordAsync(new AuditRecord("stock.reject", "TxHeader", txNumber.Value,
                JsonSerializer.Serialize(new
                {
                    reason = request.Reason, request.SupplierCode, request.BranchCode,
                    original = request.OriginalTxNumber, totalQuantity, totalCost, totalTax,
                })), token);

            return new RejectStockResult(txNumber.Value, controlNumber, request.OriginalTxNumber,
                totalQuantity, totalCost, totalTax);
        }, ct);
}
