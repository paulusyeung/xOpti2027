using FluentValidation;
using xOpti.Application.Authorization;
using xOpti.Application.Common;
using xOpti.Application.Pipeline;
using xOpti.Application.Ports;
using xOpti.Domain.Values;

namespace xOpti.Application.Inventory.Documents;

public sealed record StockDocumentLineDto(
    int RowNo, string Sku, int Qty, Money UnitAmount, Money Amount, string? Remarks, string? TaxCode);

public sealed record StockDocumentDto(
    string TxNumber, string TxType, string ControlNumber, DateTimeOffset DateOfEntry,
    string? TrackingNumber, string? Particulars, int TotalQty, bool Reprint,
    IReadOnlyList<StockDocumentLineDto> Lines);

public interface IStockDocumentStore
{
    Task<StockDocumentDto?> GetAsync(string txNumber, CancellationToken ct);
}

public sealed record GetStockDocumentQuery(string TxNumber)
    : IQuery<StockDocumentDto>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.InventoryAdjust };
}

public sealed class GetStockDocumentQueryValidator : AbstractValidator<GetStockDocumentQuery>
{
    public GetStockDocumentQueryValidator() => RuleFor(x => x.TxNumber).NotEmpty().MaximumLength(10);
}

public sealed class GetStockDocumentHandler(IStockDocumentStore store, IAuditRecorder audit)
    : IRequestHandler<GetStockDocumentQuery, StockDocumentDto>
{
    public async Task<StockDocumentDto> Handle(GetStockDocumentQuery request, CancellationToken ct)
    {
        var document = await store.GetAsync(request.TxNumber, ct)
            ?? throw new ValidationFailedException(new[]
            {
                new ValidationFieldError("TxNumber", "not-found",
                    $"Stock document '{request.TxNumber}' was not found."),
            });

        await audit.RecordAsync(new AuditRecord(
            "document.reprint", "TxHeader", document.TxNumber, null), ct);

        return document;
    }
}
