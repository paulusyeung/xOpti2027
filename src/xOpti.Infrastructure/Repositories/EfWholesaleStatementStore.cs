using Microsoft.EntityFrameworkCore;
using xOpti.Application.Wholesale;
using xOpti.Domain.Values;
using xOpti.Infrastructure.Persistence;

namespace xOpti.Infrastructure.Repositories;

public sealed class EfWholesaleStatementStore(XOptiDbContext context) : IWholesaleStatementStore
{
    public async Task<WholesaleBalanceDto?> GetBalanceAsync(int customerId, CancellationToken ct)
    {
        var statement = await BuildAsync(customerId,
            DateOnly.MinValue, DateOnly.MaxValue, ct);
        if (statement is null) return null;
        return new WholesaleBalanceDto(customerId, statement.CustomerName,
            statement.Invoiced, statement.Returned, statement.Payments,
            statement.ClosingBalance, statement.CreditLimit, statement.OverCreditLimit);
    }

    public async Task<WholesaleStatementDto?> GetStatementAsync(
        int customerId, DateOnly from, DateOnly to, CancellationToken ct) =>
        await BuildAsync(customerId, from, to, ct);

    private async Task<WholesaleStatementDto?> BuildAsync(int customerId, DateOnly from,
        DateOnly to, CancellationToken ct)
    {
        var account = await context.WholesaleAccounts.AsNoTracking()
            .SingleOrDefaultAsync(row => row.CustomerId == customerId, ct);
        if (account is null || !account.IsWholesale) return null;
        var customerName = await context.Customers.AsNoTracking()
            .Where(row => row.Id == customerId).Select(row => row.FullName)
            .SingleOrDefaultAsync(ct);

        var headers = await context.TxHeaders.AsNoTracking()
            .Where(row => row.CustomerId == customerId
                && (row.TxType == TransactionType.WholesaleInvoice
                    || row.TxType == TransactionType.WholesaleReturn)
                && !context.WholesaleDocuments.Any(document =>
                    document.TxNumber == row.TxNumber && document.Status != "posted"))
            .OrderBy(row => row.DateOfEntry).ThenBy(row => row.TxNumber)
            .ToListAsync(ct);
        var numbers = headers.Select(row => row.TxNumber).ToList();
        var paymentRows = await context.TxPayments.AsNoTracking()
            .Where(row => numbers.Contains(row.TxNumber) && row.Type != "D")
            .Select(row => new { row.TxNumber, row.TotalThisPay })
            .ToListAsync(ct);
        var payments = paymentRows
            .GroupBy(row => row.TxNumber)
            .ToDictionary(group => group.Key,
                group => group.Sum(row => row.TotalThisPay.Amount));

        var items = new List<WholesaleStatementItemDto>();
        foreach (var header in headers)
        {
            var date = DateOnly.FromDateTime(header.DateOfEntry.UtcDateTime);
            var isInvoice = header.TxType == TransactionType.WholesaleInvoice;
            items.Add(new WholesaleStatementItemDto(
                isInvoice ? "invoice" : "return", header.TxNumber, date,
                header.TotalAmount.Amount,
                isInvoice ? "Wholesale invoice" : "Wholesale return"));
            var paid = payments.GetValueOrDefault(header.TxNumber);
            if (paid != 0m)
            {
                items.Add(new WholesaleStatementItemDto("payment", header.TxNumber, date,
                    -paid, paid > 0 ? "Payment received" : "Refund issued"));
            }
        }

        var opening = decimal.Round(items.Where(row => row.Date < from)
            .Sum(row => row.Amount), 4);
        var period = items.Where(row => row.Date >= from && row.Date <= to).ToList();
        var invoiced = decimal.Round(period.Where(row => row.DocumentType == "invoice")
            .Sum(row => row.Amount), 4);
        var returned = decimal.Round(period.Where(row => row.DocumentType == "return")
            .Sum(row => row.Amount), 4);
        var periodPayments = -decimal.Round(period
            .Where(row => row.DocumentType == "payment").Sum(row => row.Amount), 4);
        var closing = decimal.Round(opening + period.Sum(row => row.Amount), 4);

        return new WholesaleStatementDto(customerId, customerName, from, to, opening,
            invoiced, returned, periodPayments, closing, account.CreditLimit.Amount,
            closing > account.CreditLimit.Amount, period);
    }
}
