using xOpti.Application.Authorization;
using xOpti.Application.Common;
using xOpti.Application.Ports;

namespace xOpti.Application.Sales.HoldSale;

/// <summary>
/// Reference idempotent financial write. Allocates the RC control number and
/// records the audit entry inside one transaction; the idempotency key is
/// required and replay-safe via the pipeline behaviors.
/// </summary>
public sealed record HoldSaleCommand(string? IdempotencyKey)
    : ICommand<HoldSaleResult>,
      IRequiresIdempotencyKey,
      IHasPermissions
{
    string? IRequiresIdempotencyKey.IdempotencyKey => IdempotencyKey;

    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.SalesInvoicePost };
}

public sealed record HoldSaleResult(string ControlNumber, DateTimeOffset HeldAt);

public sealed class HoldSaleHandler(
    IUnitOfWork unitOfWork,
    IControlNumberAllocator allocator,
    IAuditRecorder audit,
    IClock clock) : IRequestHandler<HoldSaleCommand, HoldSaleResult>
{
    public async Task<HoldSaleResult> Handle(HoldSaleCommand request, CancellationToken cancellationToken)
    {
        return await unitOfWork.ExecuteInTransactionAsync(async ct =>
        {
            var controlNumber = await allocator.AllocateAsync(
                Domain.Values.TransactionType.RetailInvoice, ct);

            await audit.RecordAsync(
                new AuditRecord("sale-hold", "TxHeader", controlNumber.Value, null), ct);

            return new HoldSaleResult(controlNumber.Value, clock.UtcNow);
        }, cancellationToken);
    }
}
