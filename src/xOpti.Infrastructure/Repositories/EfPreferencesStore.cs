using Microsoft.EntityFrameworkCore;
using xOpti.Application.Settings;
using xOpti.Infrastructure.Persistence;
using xOpti.Infrastructure.Persistence.Entities;

namespace xOpti.Infrastructure.Repositories;

public sealed class EfPreferencesStore(XOptiDbContext context) : IPreferencesStore
{
    public async Task<PreferencesDto> GetAsync(CancellationToken ct)
    {
        var row = await context.Preferences.AsNoTracking().OrderBy(x => x.SerialNumber).FirstOrDefaultAsync(ct);
        return row is null
            ? new PreferencesDto("0000000000", string.Empty, string.Empty, string.Empty, null,
                string.Empty, null, null, null, 0, 0, 0, 0)
            : Map(row);
    }

    public async Task UpdateAsync(PreferencesDto preferences, CancellationToken ct)
    {
        var row = await context.Preferences.OrderBy(x => x.SerialNumber).FirstOrDefaultAsync(ct);
        if (row is null)
        {
            row = new Preference
            {
                SerialNumber = preferences.SerialNumber,
                Platform = preferences.Platform,
                UserName = preferences.UserName,
                OwnerName = preferences.OwnerName,
                ProductName = preferences.ProductName,
                BranchNumber = "0001",
                GstNumber = preferences.GstNumber ?? string.Empty,
                PstNumber = preferences.PstNumber ?? string.Empty,
            };
            context.Preferences.Add(row);
        }

        row.ProductName = preferences.ProductName;
        row.UserName = preferences.UserName;
        row.UserAddress = preferences.UserAddress;
        row.OwnerName = preferences.OwnerName;
        row.OwnerAddress = preferences.OwnerAddress;
        row.GstNumber = preferences.GstNumber ?? string.Empty;
        row.PstNumber = preferences.PstNumber ?? string.Empty;
        row.TaxARate = preferences.TaxARate;
        row.TaxBRate = preferences.TaxBRate;
        await context.SaveChangesAsync(ct);
    }

    public async Task<IReadOnlyList<CounterDto>> GetCountersAsync(CancellationToken ct) =>
        await context.PrefTxNumbers.AsNoTracking()
            .OrderBy(row => row.TxPrefix)
            .Select(row => new CounterDto(row.TxPrefix, row.TxNextNumber, row.Description, row.Value))
            .ToListAsync(ct);

    private static PreferencesDto Map(Preference row) => new(
        row.SerialNumber, row.Platform, row.ProductName, row.UserName, row.UserAddress,
        row.OwnerName, row.OwnerAddress, row.GstNumber, row.PstNumber,
        row.TaxARate, row.TaxBRate, row.NextInvoiceNumber, row.NextInvtControlNumber);
}
