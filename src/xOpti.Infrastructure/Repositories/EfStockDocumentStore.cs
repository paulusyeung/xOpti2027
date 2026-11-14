using Microsoft.EntityFrameworkCore;
using xOpti.Application.Inventory.Documents;
using xOpti.Domain.Values;
using xOpti.Infrastructure.Persistence;

namespace xOpti.Infrastructure.Repositories;

public sealed class EfStockDocumentStore(XOptiDbContext context) : IStockDocumentStore
{
    public async Task<StockDocumentDto?> GetAsync(string txNumber, CancellationToken ct)
    {
        var header = await context.TxHeaders.AsNoTracking()
            .SingleOrDefaultAsync(row => row.TxNumber == txNumber, ct);
        if (header is null) return null;

        var lines = await context.TxDetails.AsNoTracking()
            .Where(row => row.TxNumber == txNumber)
            .OrderBy(row => row.RowNo)
            .Select(row => new StockDocumentLineDto(
                (int)row.RowNo, row.Sku, row.Qty, row.UnitAmount, row.Amount, row.Remarks, row.TaxCode))
            .ToListAsync(ct);

        return new StockDocumentDto(header.TxNumber, header.TxType.ToLegacyCode(),
            header.ControlNumber, header.DateOfEntry, header.TrackingNumber, header.Particulars,
            header.TotalQty, Reprint: true, lines);
    }
}
