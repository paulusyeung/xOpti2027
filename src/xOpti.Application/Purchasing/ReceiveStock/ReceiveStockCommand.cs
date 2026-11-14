using System.Text.Json;
using FluentValidation;
using xOpti.Application.Authorization;
using xOpti.Application.Common;
using xOpti.Application.Ports;
using xOpti.Domain.Values;

namespace xOpti.Application.Purchasing.ReceiveStock;

public sealed record ReceiveStockLine(
    string Sku,
    string LotNo,
    int Quantity,
    decimal UnitCost,
    decimal GstAmount,
    decimal PstAmount,
    string TaxCode);

public sealed record ReceiveStockCommand(
    string SupplierCode,
    string BranchCode,
    IReadOnlyList<ReceiveStockLine> Lines,
    string? IdempotencyKey,
    string Reason)
    : ICommand<ReceiveStockResult>,
      IRequiresIdempotencyKey,
      IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.InventoryReceive };
}

public sealed record ReceiveStockResult(
    string TxNumber,
    string ControlNumber,
    int TotalQuantity,
    decimal TotalCost,
    decimal TotalTax);

public sealed record ReceiptPosting(
    string TxNumber,
    string ControlNumber,
    string SupplierCode,
    string BranchCode,
    IReadOnlyList<ReceiveStockLine> Lines,
    decimal TotalCost,
    decimal TotalTax,
    int TotalQuantity);

public interface IReceiptStore
{
    Task<bool> SupplierExistsAsync(string supplierCode, CancellationToken ct);
    Task<bool> BranchExistsAsync(string branchCode, CancellationToken ct);
    Task<IReadOnlyList<string>> MissingSkusAsync(IEnumerable<string> skus, CancellationToken ct);
    Task<string> NextInventoryControlNumberAsync(CancellationToken ct);
    Task PostAsync(ReceiptPosting posting, CancellationToken ct);
}

public sealed class ReceiveStockCommandValidator : AbstractValidator<ReceiveStockCommand>
{
    public ReceiveStockCommandValidator()
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
            line.RuleFor(item => item.UnitCost).GreaterThanOrEqualTo(0)
                .Must(value => decimal.Round(value, 4) == value).WithMessage("Unit cost allows at most four decimals.");
            line.RuleFor(item => item.GstAmount).GreaterThanOrEqualTo(0)
                .Must(value => decimal.Round(value, 4) == value);
            line.RuleFor(item => item.PstAmount).GreaterThanOrEqualTo(0)
                .Must(value => decimal.Round(value, 4) == value);
            line.RuleFor(item => item.TaxCode).MaximumLength(1);
        });
    }
}

public sealed class ReceiveStockHandler(
    IUnitOfWork unitOfWork,
    IReceiptStore store,
    IControlNumberAllocator allocator,
    IAuditRecorder audit)
    : IRequestHandler<ReceiveStockCommand, ReceiveStockResult>
{
    public Task<ReceiveStockResult> Handle(ReceiveStockCommand request, CancellationToken cancellationToken) =>
        unitOfWork.ExecuteInTransactionAsync(async ct =>
        {
            if (!await store.SupplierExistsAsync(request.SupplierCode, ct))
            {
                throw Field("SupplierCode", "not-found", "Supplier was not found.");
            }

            if (!await store.BranchExistsAsync(request.BranchCode, ct))
            {
                throw Field("BranchCode", "not-found", "Branch was not found.");
            }

            var missing = await store.MissingSkusAsync(request.Lines.Select(line => line.Sku), ct);
            if (missing.Count > 0)
            {
                throw Field("Sku", "not-found", $"Unknown SKU(s): {string.Join(", ", missing)}.");
            }

            var totalCost = request.Lines.Sum(line =>
                decimal.Round(line.UnitCost * line.Quantity, 4));
            var totalTax = request.Lines.Sum(line => line.GstAmount + line.PstAmount);
            var totalQuantity = request.Lines.Sum(line => line.Quantity);

            var txNumber = await allocator.AllocateAsync(TransactionType.StockReceived, ct);
            var controlNumber = await store.NextInventoryControlNumberAsync(ct);

            await store.PostAsync(new ReceiptPosting(
                txNumber.Value, controlNumber, request.SupplierCode, request.BranchCode,
                request.Lines, totalCost, totalTax, totalQuantity), ct);

            await audit.RecordAsync(new AuditRecord(
                "stock.receive",
                "TxHeader",
                txNumber.Value,
                JsonSerializer.Serialize(new
                {
                    reason = request.Reason,
                    supplier = request.SupplierCode,
                    branch = request.BranchCode,
                    controlNumber,
                    totalQuantity,
                    totalCost,
                    totalTax,
                })), ct);

            return new ReceiveStockResult(txNumber.Value, controlNumber, totalQuantity, totalCost, totalTax);
        }, cancellationToken);

    private static Pipeline.ValidationFailedException Field(string field, string code, string message) =>
        new(new[] { new Pipeline.ValidationFieldError(field, code, message) });
}
