using xOpti.Application.Authorization;
using xOpti.Application.Common;
using xOpti.Application.Pipeline;
using xOpti.Application.Ports;

namespace xOpti.Application.Purchasing.SupplierDocuments;

public sealed record SupplierDocumentLineDto(
    int RowNo, string Sku, int Qty, decimal UnitCost, decimal Amount, string? TaxCode);

public sealed record SupplierDocumentDto(
    string TxNumber, string TxType, string ControlNumber, DateTimeOffset DateOfEntry,
    string? SupplierCode, string? RefNumber, decimal TotalCost, decimal TaxA, decimal TaxB,
    decimal TotalAmount, bool Reprint, IReadOnlyList<SupplierDocumentLineDto> Lines);

public sealed record SupplierActivityDto(
    string SupplierCode, DateOnly From, DateOnly To,
    int ReceiptCount, int ReturnCount, decimal ReceiptCost, decimal ReturnCost,
    decimal NetCost, decimal TaxTotal, IReadOnlyList<string> DocumentNumbers,
    IReadOnlyList<string> Mismatches);

public interface ISupplierDocumentStore
{
    Task<SupplierDocumentDto?> GetDocumentAsync(string txNumber, CancellationToken ct);
    Task<SupplierActivityDto> ActivityAsync(string supplierCode, DateOnly from, DateOnly to, CancellationToken ct);
}

public sealed record GetSupplierDocumentQuery(string TxNumber)
    : IQuery<SupplierDocumentDto>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.InventoryReceive };
}

public sealed class GetSupplierDocumentHandler(ISupplierDocumentStore store, IAuditRecorder audit)
    : IRequestHandler<GetSupplierDocumentQuery, SupplierDocumentDto>
{
    public async Task<SupplierDocumentDto> Handle(GetSupplierDocumentQuery request, CancellationToken ct)
    {
        var document = await store.GetDocumentAsync(request.TxNumber, ct)
            ?? throw new ValidationFailedException(new[]
            {
                new ValidationFieldError("TxNumber", "not-found", "Supplier document was not found."),
            });

        await audit.RecordAsync(new AuditRecord("supplier-document.reprint", "TxHeader",
            document.TxNumber, null), ct);
        return document;
    }
}

public sealed record GetSupplierActivityQuery(string SupplierCode, DateOnly From, DateOnly To)
    : IQuery<SupplierActivityDto>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.InventoryReceive };
}

public sealed class GetSupplierActivityHandler(ISupplierDocumentStore store)
    : IRequestHandler<GetSupplierActivityQuery, SupplierActivityDto>
{
    public Task<SupplierActivityDto> Handle(GetSupplierActivityQuery request, CancellationToken ct) =>
        store.ActivityAsync(request.SupplierCode, request.From, request.To, ct);
}
