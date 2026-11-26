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
        if (row is null)
        {
            return new PreferencesDto("0000000000", string.Empty, string.Empty, string.Empty, null,
                string.Empty, null, null, null, 0, 0, 0, 0);
        }

        // City and country are stored as legacy codes; resolve their display
        // names so reports can print a complete letterhead address.
        var city = row.UserCityCode is { } code
            ? await context.Cities.AsNoTracking()
                .Where(entry => entry.Code == code)
                .Select(entry => new { entry.CityName, entry.CountryCode })
                .FirstOrDefaultAsync(ct)
            : null;
        var countryCode = string.IsNullOrWhiteSpace(row.UserCountryCode)
            ? city?.CountryCode
            : row.UserCountryCode;
        var countryName = string.IsNullOrWhiteSpace(countryCode)
            ? null
            : await context.Countries.AsNoTracking()
                .Where(entry => entry.CountryCode == countryCode)
                .Select(entry => (string?)entry.CountryName)
                .FirstOrDefaultAsync(ct);

        return Map(row, city?.CityName, countryCode, countryName);
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
        row.UserCityCode = preferences.UserCityCode;
        row.UserProvince = preferences.UserProvince;
        row.UserPostalCode = preferences.UserPostalCode;
        row.UserCountryCode = preferences.UserCountryCode;
        row.UserPhone = preferences.UserPhone;
        row.UserFax = preferences.UserFax;
        row.OwnerName = preferences.OwnerName;
        row.OwnerAddress = preferences.OwnerAddress;
        row.OwnerPhone = preferences.OwnerPhone;
        row.OwnerFax = preferences.OwnerFax;
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

    private static PreferencesDto Map(
        Preference row, string? cityName, string? countryCode, string? countryName) => new(
        row.SerialNumber, row.Platform, row.ProductName, row.UserName, row.UserAddress,
        row.OwnerName, row.OwnerAddress, row.GstNumber, row.PstNumber,
        row.TaxARate, row.TaxBRate, row.NextInvoiceNumber, row.NextInvtControlNumber,
        row.UserPhone, row.UserFax, row.OwnerPhone, row.OwnerFax,
        row.UserCityCode, cityName, row.UserProvince, row.UserPostalCode,
        countryCode, countryName);
}
