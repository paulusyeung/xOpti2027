using Microsoft.EntityFrameworkCore;
using xOpti.Application.Reporting;
using xOpti.Infrastructure.Identity;
using xOpti.Infrastructure.Persistence;

namespace xOpti.Infrastructure.Repositories;

/// <summary>
/// Reads the tables behind the legacy Crystal Invoice (TxHeader, TxDetails,
/// Customer, staff, payments and product descriptions).
/// </summary>
public sealed class EfInvoiceReportStore(XOptiDbContext context) : IInvoiceReportStore
{
    public async Task<InvoiceReport?> GetAsync(string txNumber, CancellationToken cancellationToken)
    {
        var header = await context.TxHeaders.AsNoTracking()
            .SingleOrDefaultAsync(row => row.TxNumber == txNumber, cancellationToken);
        if (header is null) return null;

        var customer = await context.Customers.AsNoTracking()
            .Where(row => row.Id == header.CustomerId)
            .Select(row => new
            {
                row.FullName, row.HomeAddress, row.HomeCity, row.HomeProvince,
                row.HomeCountry, row.HomePostalCode, row.HomePhone, row.VipCode,
            })
            .SingleOrDefaultAsync(cancellationToken);

        var cityName = customer is { HomeCity: > 0 }
            ? await context.Cities.AsNoTracking()
                .Where(row => row.Code == customer.HomeCity)
                .Select(row => (string?)row.CityName)
                .FirstOrDefaultAsync(cancellationToken)
            : null;
        var provinceName = string.IsNullOrWhiteSpace(customer?.HomeProvince)
            ? null
            : await context.Provinces.AsNoTracking()
                .Where(row => row.ProvinceCode == customer!.HomeProvince)
                .Select(row => (string?)row.ProvinceName)
                .FirstOrDefaultAsync(cancellationToken);
        var countryName = string.IsNullOrWhiteSpace(customer?.HomeCountry)
            ? null
            : await context.Countries.AsNoTracking()
                .Where(row => row.CountryCode == customer!.HomeCountry)
                .Select(row => (string?)row.CountryName)
                .FirstOrDefaultAsync(cancellationToken);

        var salesPerson = await
            (from link in context.TxSalePersons.AsNoTracking()
             join staff in context.LegacyStaff.AsNoTracking()
                 on link.StaffCode equals staff.StaffCode into matches
             from staff in matches.DefaultIfEmpty()
             where link.TxNumber == txNumber
             select staff.StaffFullName)
            .FirstOrDefaultAsync(cancellationToken);

        var details = await context.TxDetails.AsNoTracking()
            .Where(row => row.TxNumber == txNumber)
            .OrderBy(row => row.RowNo)
            .ToListAsync(cancellationToken);
        var skus = details.Select(row => row.Sku).Distinct().ToList();
        var descriptions = await
            (from inventory in context.InventoryItems.AsNoTracking()
             join brand in context.Brands.AsNoTracking()
                 on inventory.BrandCode equals brand.BrandCode into brands
             from brand in brands.DefaultIfEmpty()
             where skus.Contains(inventory.Sku)
             select new
             {
                 inventory.Sku,
                 Description = brand == null
                     ? inventory.Model
                     : brand.BrandDescription + " - " + inventory.Model,
             })
            .ToDictionaryAsync(row => row.Sku, row => row.Description, cancellationToken);
        var lines = details.Select(row => new InvoiceReportLine(
            row.RowNo,
            row.Sku,
            descriptions.GetValueOrDefault(row.Sku),
            row.TaxCode,
            row.Qty,
            row.UnitAmount.Amount - row.MarkDownAmount.Amount,
            row.Amount.Amount)).ToList();

        var paymentRows = await context.TxPayments.AsNoTracking()
            .Where(row => row.TxNumber == txNumber)
            .OrderBy(row => row.PaymentLineNo)
            .ToListAsync(cancellationToken);
        var methods = await context.PaymentMethods.AsNoTracking()
            .ToDictionaryAsync(row => row.PaymentCode, row => row.PaymentNameLong, cancellationToken);
        var payments = paymentRows.Select(row =>
        {
            var card = string.IsNullOrWhiteSpace(row.CardNumber)
                ? null
                : row.CardNumber + " / " + (row.AuthorizationCode ?? string.Empty);
            return new InvoiceReportPayment(
                methods.GetValueOrDefault(row.Type) ?? row.Type,
                card,
                row.AmountTender.Amount,
                row.ExchangeRate,
                row.EqAmount.Amount);
        }).ToList();

        return new InvoiceReport(
            header.TxNumber,
            header.DateOfEntry,
            header.SecondDate, // legacy "Order Date"; ship date is DateOfEntry
            header.TrackingNumber ?? header.RefNumber,
            customer?.FullName ?? string.Empty,
            customer?.HomeAddress,
            cityName,
            provinceName,
            countryName,
            customer?.HomePostalCode,
            customer?.HomePhone,
            customer?.VipCode,
            salesPerson,
            lines,
            payments,
            header.TotalSale.Amount,
            header.TaxA.Amount,
            header.TaxB.Amount,
            header.GrossSale.Amount,
            header.PreviousPaid.Amount,
            header.Change.Amount);
    }
}
