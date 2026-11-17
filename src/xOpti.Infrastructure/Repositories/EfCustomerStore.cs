using Microsoft.EntityFrameworkCore;
using xOpti.Application.Customers;
using xOpti.Application.Pipeline;
using xOpti.Domain.Values;
using xOpti.Infrastructure.Persistence;
using xOpti.Infrastructure.Persistence.Entities;

namespace xOpti.Infrastructure.Repositories;

public sealed class EfCustomerStore(XOptiDbContext context) : ICustomerStore
{
    public async Task<CustomerDetailDto?> GetAsync(int customerId, CancellationToken ct)
    {
        var canonicalId = await ResolveCanonicalIdAsync(customerId, ct);
        if (canonicalId is null) return null;
        var customer = await context.Customers.AsNoTracking()
            .SingleOrDefaultAsync(row => row.Id == canonicalId, ct);
        return customer is null ? null : Map(customer);
    }

    public async Task<int?> ResolveCanonicalIdAsync(int customerId, CancellationToken ct)
    {
        var alias = await context.CustomerAliases.AsNoTracking()
            .SingleOrDefaultAsync(row => row.AliasId == customerId, ct);
        var resolved = alias?.CanonicalId ?? customerId;
        if (alias is not null)
        {
            var next = await context.CustomerAliases.AsNoTracking()
                .SingleOrDefaultAsync(row => row.AliasId == resolved, ct);
            if (next is not null) return await ResolveCanonicalIdAsync(next.CanonicalId, ct);
        }
        return await context.Customers.AnyAsync(row => row.Id == resolved, ct) ? resolved : null;
    }

    public async Task<IReadOnlyList<int>> ResolveGroupIdsAsync(int canonicalId, CancellationToken ct)
    {
        var ids = new List<int> { canonicalId };
        var frontier = new List<int> { canonicalId };
        while (frontier.Count > 0)
        {
            var current = frontier.ToList();
            var aliases = await context.CustomerAliases.AsNoTracking()
                .Where(row => current.Contains(row.CanonicalId))
                .Select(row => row.AliasId).ToListAsync(ct);
            var newIds = aliases.Where(id => !ids.Contains(id)).ToList();
            ids.AddRange(newIds);
            frontier = newIds;
        }
        return ids;
    }

    public async Task<CustomerBalanceDto?> GetBalanceAsync(int canonicalId, CancellationToken ct)
    {
        var customer = await context.Customers.AsNoTracking()
            .SingleOrDefaultAsync(row => row.Id == canonicalId, ct);
        if (customer is null) return null;
        var ids = await ResolveGroupIdsAsync(canonicalId, ct);
        var headers = await context.TxHeaders.AsNoTracking()
            .Where(row => ids.Contains(row.CustomerId)).ToListAsync(ct);
        var numbers = headers.Select(row => row.TxNumber).ToList();
        var payments = await context.TxPayments.AsNoTracking()
            .Where(row => numbers.Contains(row.TxNumber) && row.Type != "D")
            .Select(row => row.TotalThisPay.Amount).ToListAsync(ct);
        var charges = headers.Where(row => row.TxType == TransactionType.RetailInvoice)
            .Sum(row => row.TotalAmount.Amount);
        var refunds = headers.Where(row => row.TxType == TransactionType.RetailRefund)
            .Sum(row => row.TotalAmount.Amount);
        var paid = payments.Sum();
        var balance = decimal.Round(charges + refunds - paid, 4);
        return new CustomerBalanceDto(canonicalId, decimal.Round(charges, 4),
            decimal.Round(paid, 4), decimal.Round(refunds, 4), balance,
            customer.CreditLimit.Amount, balance > customer.CreditLimit.Amount);
    }

    public async Task<IReadOnlyList<CustomerPurchaseDto>> GetHistoryAsync(
        IReadOnlyList<int> customerIds, DateOnly? from, DateOnly? to, CancellationToken ct)
    {
        var query = context.TxHeaders.AsNoTracking()
            .Where(row => customerIds.Contains(row.CustomerId)
                && (row.TxType == TransactionType.RetailInvoice
                    || row.TxType == TransactionType.RetailRefund
                    || row.TxType == TransactionType.SalesOrder));
        if (from is not null)
        {
            var start = new DateTimeOffset(from.Value.ToDateTime(TimeOnly.MinValue), TimeSpan.Zero);
            query = query.Where(row => row.DateOfEntry >= start);
        }
        if (to is not null)
        {
            var end = new DateTimeOffset(to.Value.AddDays(1).ToDateTime(TimeOnly.MinValue), TimeSpan.Zero);
            query = query.Where(row => row.DateOfEntry < end);
        }

        var headers = await query.OrderBy(row => row.DateOfEntry).ThenBy(row => row.TxNumber).ToListAsync(ct);
        var numbers = headers.Select(row => row.TxNumber).ToList();
        var payments = await context.TxPayments.AsNoTracking()
            .Where(row => numbers.Contains(row.TxNumber) && row.Type != "D")
            .Select(row => new { row.TxNumber, row.TotalThisPay.Amount }).ToListAsync(ct);
        return headers.Select(header => new CustomerPurchaseDto(
            header.TxNumber, header.TxType.ToLegacyCode(), header.DateOfEntry,
            header.TotalSale.Amount, header.TaxA.Amount, header.TaxB.Amount,
            header.TotalAmount.Amount,
            decimal.Round(payments.Where(row => row.TxNumber == header.TxNumber).Sum(row => row.Amount), 4),
            header.Status, header.RefNumber)).ToList();
    }

    public async Task<(IReadOnlyList<CustomerSummaryDto> Items, bool HasMore)> SearchAsync(
        string? search, int? afterId, int limit, CancellationToken ct)
    {
        var query = context.Customers.AsNoTracking()
            .Where(row => !context.CustomerAliases.Any(alias => alias.AliasId == row.Id));
        if (afterId is not null) query = query.Where(row => row.Id > afterId);
        var term = search?.Trim() ?? string.Empty;
        if (term.Length > 0)
        {
            var pattern = $"%{term}%";
            query = query.Where(row =>
                EF.Functions.ILike(row.FullName ?? string.Empty, pattern)
                || EF.Functions.ILike(row.HomePhone ?? string.Empty, pattern)
                || EF.Functions.ILike(row.Cellular ?? string.Empty, pattern)
                || EF.Functions.ILike(row.Email ?? string.Empty, pattern)
                || EF.Functions.ILike(row.VipCode ?? string.Empty, pattern)
                || row.Id.ToString() == term);
        }

        var rows = await query.OrderBy(row => row.Id).Take(limit + 1).ToListAsync(ct);
        var hasMore = rows.Count > limit;
        var page = hasMore ? rows.Take(limit).ToList() : rows;
        return (page.Select(row => new CustomerSummaryDto(row.Id, row.VipCode, row.FullName,
            row.HomePhone ?? row.Cellular, row.Email, row.HomeCity.ToString(), row.VipCode)).ToList(),
            hasMore);
    }

    public async Task<IReadOnlyList<CustomerDuplicateDto>> FindDuplicatesAsync(
        CustomerInput input, int? excludeCustomerId, CancellationToken ct)
    {
        var name = (input.FullName
            ?? string.Join(' ', new[] { input.FirstName, input.LastName }
                .Where(part => !string.IsNullOrWhiteSpace(part)))).Trim();
        var rows = await context.Customers.AsNoTracking()
            .Where(row => excludeCustomerId == null || row.Id != excludeCustomerId)
            .Where(row =>
                (name.Length > 0 && row.FullName != null
                    && row.FullName.ToLower() == name.ToLower())
                || (input.HomePhone != null && input.HomePhone.Length > 0
                    && (row.HomePhone == input.HomePhone || row.Cellular == input.HomePhone))
                || (input.Email != null && input.Email.Length > 0
                    && row.Email != null && row.Email.ToLower() == input.Email.ToLower()))
            .OrderBy(row => row.Id).Take(10).ToListAsync(ct);
        return rows.Select(row => new CustomerDuplicateDto(row.Id, row.FullName, row.HomePhone,
            row.Email,
            row.FullName?.ToLower() == name.ToLower() ? "name"
                : input.HomePhone?.Length > 0 ? "phone" : "email")).ToList();
    }

    public async Task<int> CreateAsync(CustomerInput input, CancellationToken ct)
    {
        var id = await context.Database
            .SqlQuery<int>($"SELECT nextval('public.customer_id_seq')::int AS \"Value\"")
            .SingleAsync(ct);
        var customer = new Customer { Id = id };
        Apply(customer, input);
        context.Customers.Add(customer);
        if (!await context.CustomerAccounts.AnyAsync(row => row.CustomerId == id, ct))
            context.CustomerAccounts.Add(new CustomerAccount { CustomerId = id });
        await context.SaveChangesAsync(ct);
        return id;
    }

    public async Task UpdateAsync(int customerId, CustomerInput input, CancellationToken ct)
    {
        var customer = await context.Customers.SingleOrDefaultAsync(row => row.Id == customerId, ct)
            ?? throw Validation("CustomerId", "not-found", "Customer was not found.");
        Apply(customer, input);
        await context.SaveChangesAsync(ct);
    }

    public async Task MergeAsync(int sourceId, int targetId, string? phone, string? email,
        string? fullName, string reason, string? actor, CancellationToken ct)
    {
        if (sourceId == targetId)
            throw Validation("SourceId", "same-customer", "A customer cannot be merged into itself.");
        if (await context.CustomerAliases.AnyAsync(row => row.AliasId == sourceId, ct))
            throw Validation("SourceId", "already-merged", "The source customer is already merged.");
        var source = await context.Customers.SingleOrDefaultAsync(row => row.Id == sourceId, ct)
            ?? throw Validation("SourceId", "not-found", "Source customer was not found.");
        var target = await context.Customers.SingleOrDefaultAsync(row => row.Id == targetId, ct)
            ?? throw Validation("TargetId", "not-found", "Target customer was not found.");

        if (!string.IsNullOrWhiteSpace(source.HomePhone)
            && !string.IsNullOrWhiteSpace(target.HomePhone)
            && source.HomePhone != target.HomePhone && phone is null)
            throw Validation("HomePhone", "merge-choice-required",
                "Both customers have different phone numbers; choose the canonical value.");
        if (!string.IsNullOrWhiteSpace(source.Email) && !string.IsNullOrWhiteSpace(target.Email)
            && !string.Equals(source.Email, target.Email, StringComparison.OrdinalIgnoreCase)
            && email is null)
            throw Validation("Email", "merge-choice-required",
                "Both customers have different emails; choose the canonical value.");
        if (!string.IsNullOrWhiteSpace(source.FullName)
            && !string.IsNullOrWhiteSpace(target.FullName)
            && !string.Equals(source.FullName, target.FullName, StringComparison.OrdinalIgnoreCase)
            && fullName is null)
            throw Validation("FullName", "merge-choice-required",
                "Both customers have different names; choose the canonical value.");

        if (phone is not null) target.HomePhone = phone;
        if (email is not null) target.Email = email;
        if (fullName is not null) target.FullName = fullName;
        context.CustomerAliases.Add(new CustomerAlias
        {
            AliasId = sourceId, CanonicalId = targetId, MergedAt = DateTimeOffset.UtcNow,
            MergedBy = actor, Reason = reason,
        });
        await context.SaveChangesAsync(ct);
    }

    private static CustomerDetailDto Map(Customer row) => new(
        row.Id, row.VipCode, row.Salutation, row.FirstName, row.Initial, row.LastName,
        row.FullName, row.Birthday, row.HomeAddress, row.HomeCity, row.HomeProvince,
        row.HomePostalCode, row.HomeCountry, row.HomePhone, row.HomeFax, row.Cellular,
        row.Email, row.BizCompanyName, row.BizJobTitle, row.BizAddress, row.BizCity,
        row.BizProvince, row.BizPostalCode, row.BizCountry, row.BizPhone, row.BizFax,
        row.CreditLimit.Amount, row.PaymentTerms, row.VipMarkDownPct,
        row.SummaryFlag, row.AccountingFlag, row.Remarks);

    private static void Apply(Customer customer, CustomerInput input)
    {
        customer.VipCode = input.VipCode;
        customer.Salutation = input.Salutation;
        customer.FirstName = input.FirstName;
        customer.Initial = input.Initial;
        customer.LastName = input.LastName;
        customer.FullName = input.FullName;
        customer.Birthday = input.Birthday;
        customer.HomeAddress = input.HomeAddress;
        customer.HomeCity = input.HomeCity;
        customer.HomeProvince = input.HomeProvince;
        customer.HomePostalCode = input.HomePostalCode;
        customer.HomeCountry = input.HomeCountry;
        customer.HomePhone = input.HomePhone;
        customer.HomeFax = input.HomeFax;
        customer.Cellular = input.Cellular;
        customer.Email = input.Email;
        customer.BizCompanyName = input.BizCompanyName;
        customer.BizJobTitle = input.BizJobTitle;
        customer.BizAddress = input.BizAddress;
        customer.BizCity = input.BizCity;
        customer.BizProvince = input.BizProvince;
        customer.BizPostalCode = input.BizPostalCode;
        customer.BizCountry = input.BizCountry;
        customer.BizPhone = input.BizPhone;
        customer.BizFax = input.BizFax;
        customer.CreditLimit = Money.From(input.CreditLimit);
        customer.PaymentTerms = input.PaymentTerms;
        customer.VipMarkDownPct = input.VipMarkDownPct;
        customer.SummaryFlag = input.SummaryFlag;
        customer.AccountingFlag = input.AccountingFlag;
        customer.Remarks = input.Remarks;
    }

    private static ValidationFailedException Validation(string field, string code, string message) =>
        new(new[] { new ValidationFieldError(field, code, message) });
}
