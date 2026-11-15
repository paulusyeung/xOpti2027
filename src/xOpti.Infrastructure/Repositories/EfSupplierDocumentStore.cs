using Microsoft.EntityFrameworkCore;
using xOpti.Application.Purchasing.SupplierDocuments;
using xOpti.Infrastructure.Persistence;
using xOpti.Domain.Values;

namespace xOpti.Infrastructure.Repositories;

public sealed class EfSupplierDocumentStore(XOptiDbContext context) : ISupplierDocumentStore
{
    public async Task<SupplierDocumentDto?> GetDocumentAsync(string txNumber, CancellationToken ct)
    {
        var header = await context.TxHeaders.AsNoTracking()
            .SingleOrDefaultAsync(row => row.TxNumber == txNumber, ct);
        if (header is null) return null;

        var lines = await context.TxDetails.AsNoTracking()
            .Where(row => row.TxNumber == txNumber)
            .OrderBy(row => row.RowNo)
            .Select(row => new SupplierDocumentLineDto(
                (int)row.RowNo, row.Sku, row.Qty, row.UnitCost.Amount, row.Amount.Amount, row.TaxCode))
            .ToListAsync(ct);

        return new SupplierDocumentDto(header.TxNumber, header.TxType.ToLegacyCode(),
            header.ControlNumber, header.DateOfEntry, header.SupplierCode, header.RefNumber,
            header.TotalCost.Amount, header.TaxA.Amount, header.TaxB.Amount,
            header.TotalAmount.Amount, true, lines);
    }

    public async Task<SupplierActivityDto> ActivityAsync(
        string supplierCode, DateOnly from, DateOnly to, CancellationToken ct)
    {
        var start = new DateTimeOffset(from.ToDateTime(TimeOnly.MinValue), TimeSpan.Zero);
        var end = new DateTimeOffset(to.ToDateTime(TimeOnly.MaxValue), TimeSpan.Zero);

        var documents = await context.TxHeaders.AsNoTracking()
            .Where(row => row.SupplierCode == supplierCode
                && row.DateOfEntry >= start && row.DateOfEntry <= end
                && (row.TxType == TransactionType.StockReceived || row.TxType == TransactionType.StockRejected))
            .OrderBy(row => row.DateOfEntry).ThenBy(row => row.TxNumber)
            .ToListAsync(ct);

        var receipts = documents.Where(row => row.TxType == TransactionType.StockReceived).ToList();
        var returns = documents.Where(row => row.TxType == TransactionType.StockRejected).ToList();
        var receiptCost = receipts.Sum(row => row.TotalCost.Amount);
        var returnCost = returns.Sum(row => Math.Abs(row.TotalCost.Amount));
        var tax = documents.Sum(row => row.TaxA.Amount + row.TaxB.Amount);

        var startLocal = DateTime.SpecifyKind(start.UtcDateTime, DateTimeKind.Unspecified);
        var endLocal = DateTime.SpecifyKind(end.UtcDateTime, DateTimeKind.Unspecified);
        var summaries = await context.SupplierSummaries.AsNoTracking()
            .Where(row => row.SupplierCode == supplierCode
                && row.FirstDateOfMonth >= startLocal && row.FirstDateOfMonth <= endLocal)
            .ToListAsync(ct);
        var summaryPurchased = summaries.Sum(row => row.AmountPurchased ?? 0);
        var summaryRejected = summaries.Sum(row => Math.Abs(row.AmountRejected ?? 0));

        var mismatches = new List<string>();
        if (summaries.Count > 0 && Math.Abs(summaryPurchased - receiptCost) > 0.005m)
        {
            mismatches.Add($"purchased {summaryPurchased:0.0000} vs posted {receiptCost:0.0000} "
                + $"({string.Join(", ", receipts.Select(row => row.TxNumber))})");
        }

        if (summaries.Count > 0 && Math.Abs(summaryRejected - returnCost) > 0.005m)
        {
            mismatches.Add($"rejected {summaryRejected:0.0000} vs posted {returnCost:0.0000} "
                + $"({string.Join(", ", returns.Select(row => row.TxNumber))})");
        }

        return new SupplierActivityDto(supplierCode, from, to, receipts.Count, returns.Count,
            receiptCost, returnCost, receiptCost - returnCost, tax,
            documents.Select(row => row.TxNumber).ToList(), mismatches);
    }
}
