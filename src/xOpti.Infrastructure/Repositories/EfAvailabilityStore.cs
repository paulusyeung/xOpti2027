using System.Globalization;
using Microsoft.EntityFrameworkCore;
using xOpti.Application.Inventory.Availability;
using xOpti.Domain.Values;
using xOpti.Infrastructure.Persistence;

namespace xOpti.Infrastructure.Repositories;

public sealed class EfAvailabilityStore(XOptiDbContext context) : IAvailabilityStore
{
    public async Task<SkuAvailabilityDto?> GetAvailabilityAsync(string sku, CancellationToken ct)
    {
        var inventory = await context.InventoryItems.AsNoTracking()
            .SingleOrDefaultAsync(row => row.Sku == sku, ct);
        if (inventory is null) return null;

        var branches = await context.BranchInventory.AsNoTracking()
            .Where(row => row.Sku == sku)
            .OrderBy(row => row.BranchCode)
            .Select(row => new BranchAvailabilityDto(row.BranchCode, row.QtyOnHand))
            .ToListAsync(ct);

        var lots = await context.LotRecords.AsNoTracking()
            .Where(row => row.Sku == sku)
            .OrderBy(row => row.DateReceived).ThenBy(row => row.LotNo)
            .Select(row => new LotAvailabilityDto(row.LotNo, row.SupplierCode, row.DateReceived,
                row.QtyPurchased, row.QtyUsed, row.QtyOnHand))
            .ToListAsync(ct);

        return new SkuAvailabilityDto(sku, inventory.QtyTotalOnHand, 0, 0, branches, lots);
    }

    public async Task<IReadOnlyList<MovementDto>> PageMovementsAsync(
        string sku, string? beforeCursor, int limit, CancellationToken ct)
    {
        var query = context.TxDetails.AsNoTracking().Where(row => row.Sku == sku);

        if (!string.IsNullOrEmpty(beforeCursor))
        {
            var parts = beforeCursor.Split('|');
            if (parts.Length == 3
                && DateTimeOffset.TryParse(parts[0], CultureInfo.InvariantCulture,
                    DateTimeStyles.RoundtripKind, out var date)
                && double.TryParse(parts[2], CultureInfo.InvariantCulture, out var rowNo))
            {
                var txNumber = parts[1];
                query = query.Where(row =>
                    row.DateOfEntry < date
                    || (row.DateOfEntry == date && row.TxNumber.CompareTo(txNumber) < 0)
                    || (row.DateOfEntry == date && row.TxNumber == txNumber && row.RowNo < rowNo));
            }
        }

        var rows = await query
            .OrderByDescending(row => row.DateOfEntry)
            .ThenByDescending(row => row.TxNumber)
            .ThenByDescending(row => row.RowNo)
            .Take(limit)
            .ToListAsync(ct);

        return rows.Select(row => new MovementDto(row.DateOfEntry, row.TxType.ToLegacyCode(),
            row.TxNumber, (int)row.RowNo, row.Qty, row.UnitAmount, row.Amount, row.TaxCode)).ToList();
    }
}
