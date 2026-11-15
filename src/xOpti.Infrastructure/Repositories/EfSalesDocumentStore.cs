using Microsoft.EntityFrameworkCore;
using xOpti.Application.Sales.Documents;
using xOpti.Domain.Values;
using xOpti.Infrastructure.Persistence;

namespace xOpti.Infrastructure.Repositories;

public sealed class EfSalesDocumentStore(XOptiDbContext context) : ISalesDocumentStore
{
    public async Task<SalesDocumentDto?> GetAsync(string txNumber, CancellationToken ct)
    {
        var header = await context.TxHeaders.AsNoTracking()
            .SingleOrDefaultAsync(row => row.TxNumber == txNumber, ct);
        return header is null ? null : await MapAsync(header, ct);
    }

    public async Task<IReadOnlyList<SalesDocumentDto>> PageAsync(
        int? customerId, string? status, string? afterTxNumber, int limit, CancellationToken ct)
    {
        var query = context.TxHeaders.AsNoTracking().Where(row =>
            row.TxType == TransactionType.SalesOrder
            || row.TxType == TransactionType.RetailInvoice
            || row.TxType == TransactionType.RetailRefund);
        if (customerId is not null) query = query.Where(row => row.CustomerId == customerId);
        if (!string.IsNullOrWhiteSpace(status)) query = query.Where(row => row.Status == status.Trim());
        if (!string.IsNullOrEmpty(afterTxNumber))
            query = query.Where(row => row.TxNumber.CompareTo(afterTxNumber) > 0);

        var headers = await query.OrderBy(row => row.TxNumber).Take(limit).ToListAsync(ct);
        var results = new List<SalesDocumentDto>(headers.Count);
        foreach (var header in headers) results.Add(await MapAsync(header, ct));
        return results;
    }

    private async Task<SalesDocumentDto> MapAsync(Persistence.Entities.TxHeader header, CancellationToken ct)
    {
        var customerName = await context.Customers.AsNoTracking()
            .Where(row => row.Id == header.CustomerId).Select(row => row.FullName)
            .SingleOrDefaultAsync(ct);
        var lines = await context.TxDetails.AsNoTracking()
            .Where(row => row.TxNumber == header.TxNumber)
            .OrderBy(row => row.RowNo)
            .Select(row => new SalesDocumentLineDto((int)row.RowNo, row.Sku, row.Qty,
                row.UnitAmount.Amount, row.MarkDownAmount.Amount, row.UnitCost.Amount,
                row.Amount.Amount, row.TaxCode))
            .ToListAsync(ct);
        var payments = await context.TxPayments.AsNoTracking()
            .Where(row => row.TxNumber == header.TxNumber)
            .OrderBy(row => row.PaymentLineNo)
            .Select(row => new SalesDocumentPaymentDto(row.PaymentLineNo, row.Type,
                row.AmountTender.Amount, row.TotalThisPay.Amount,
                row.AuthorizationCode ?? (row.CardNumber == null ? null : "CARD-REF")))
            .ToListAsync(ct);

        var paid = payments.Sum(row => row.AmountTender);
        return new SalesDocumentDto(header.TxNumber, header.TxType.ToLegacyCode(), Kind(header.TxType),
            header.ControlNumber, header.DateOfEntry, header.CustomerId, customerName,
            header.Status, StatusLabel(header.Status), header.RefNumber,
            header.TotalSale.Amount, header.TaxA.Amount, header.TaxB.Amount,
            header.GrossSale.Amount, header.TotalAmount.Amount, header.TotalQty, paid,
            decimal.Round(header.TotalAmount.Amount - paid, 2), lines, payments);
    }

    private static string Kind(TransactionType type) => type switch
    {
        TransactionType.SalesOrder => "Order",
        TransactionType.RetailInvoice => "Invoice",
        TransactionType.RetailRefund => "Refund",
        _ => "Other",
    };

    private static string StatusLabel(string? status) => status?.Trim() switch
    {
        "0" => "Open",
        "1" => "Refunded",
        "2" => "Voided",
        "3" => "Completed",
        _ => status ?? "Unknown",
    };
}
