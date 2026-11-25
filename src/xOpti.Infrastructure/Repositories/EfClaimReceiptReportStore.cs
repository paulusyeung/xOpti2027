using Microsoft.EntityFrameworkCore;
using xOpti.Application.Reporting;
using xOpti.Infrastructure.Persistence;

namespace xOpti.Infrastructure.Repositories;

/// <summary>
/// Reads the legacy RptClaimReceipt view. One row is one item line; the report
/// groups those lines by class and computes the Crystal formula totals.
/// </summary>
public sealed class EfClaimReceiptReportStore(XOptiDbContext context) : IClaimReceiptReportStore
{
    public async Task<ClaimReceiptReport?> GetAsync(
        string txNumber, CancellationToken cancellationToken)
    {
        var rows = await context.ClaimReceiptReportRows.AsNoTracking()
            .Where(row => row.TxNumber == txNumber)
            .OrderBy(row => row.ClassName).ThenBy(row => row.RowNo)
            .ToListAsync(cancellationToken);

        if (rows.Count == 0) return null;

        var first = rows[0];
        var classes = rows
            .GroupBy(row => row.ClassName)
            .Select(group => new ClaimReceiptReportClass(group.Key, group.Sum(row => row.Price)))
            .ToList();

        var paymentLines = rows
            .Where(row => row.PaymentLineNo.HasValue)
            .Select(row => row.PaymentLineNo!.Value)
            .Distinct()
            .Count();
        var averagePayment = rows
            .Where(row => row.TotalThisPay.HasValue)
            .Select(row => row.TotalThisPay!.Value)
            .DefaultIfEmpty(0m)
            .Average();

        return new ClaimReceiptReport(
            txNumber,
            first.DateOfEntry,
            first.LastName ?? string.Empty,
            first.FirstName ?? string.Empty,
            first.StaffCode,
            classes,
            rows.Sum(row => row.Discount),
            rows.Sum(row => row.NetPaid),
            paymentLines * averagePayment);
    }
}
