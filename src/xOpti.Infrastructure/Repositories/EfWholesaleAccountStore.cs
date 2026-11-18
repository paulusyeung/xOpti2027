using Microsoft.EntityFrameworkCore;
using xOpti.Application.Pipeline;
using xOpti.Application.Wholesale;
using xOpti.Domain.Values;
using xOpti.Infrastructure.Persistence;
using xOpti.Infrastructure.Persistence.Entities;

namespace xOpti.Infrastructure.Repositories;

public sealed class EfWholesaleAccountStore(XOptiDbContext context) : IWholesaleAccountStore
{
    public async Task<WholesaleAccountDto?> GetAsync(int customerId, CancellationToken ct)
    {
        var account = await context.WholesaleAccounts.AsNoTracking()
            .SingleOrDefaultAsync(row => row.CustomerId == customerId, ct);
        return account is null ? null : Map(account);
    }

    public async Task<WholesaleAccountDto> SaveAsync(int customerId, WholesaleAccountInput input,
        string? actor, CancellationToken ct)
    {
        if (!await context.Customers.AnyAsync(row => row.Id == customerId, ct))
            throw Validation("CustomerId", "not-found", "Customer was not found.");

        if (!string.IsNullOrWhiteSpace(input.RepresentativeStaffCode)
            && !await context.LegacyStaff.AnyAsync(row => row.StaffCode == input.RepresentativeStaffCode, ct))
            throw Validation("RepresentativeStaffCode", "not-found",
                "Sales representative was not found.");

        var now = DateTimeOffset.UtcNow;
        var account = await context.WholesaleAccounts
            .SingleOrDefaultAsync(row => row.CustomerId == customerId, ct);
        if (account is null)
        {
            account = new WholesaleAccount
            {
                CustomerId = customerId,
                CreatedAt = now,
                CreatedBy = actor,
            };
            context.WholesaleAccounts.Add(account);
        }

        account.IsWholesale = true;
        account.PriceGrade = input.PriceGrade?.Trim().ToUpperInvariant();
        account.TermsCode = input.TermsCode?.Trim();
        account.TermsDays = input.TermsDays;
        account.CreditLimit = Money.From(input.CreditLimit);
        account.TaxTreatment = input.TaxTreatment?.Trim().ToUpperInvariant();
        account.RepresentativeStaffCode = input.RepresentativeStaffCode?.Trim();
        account.CreditHold = input.CreditHold;
        account.Notes = input.Notes;
        account.UpdatedAt = now;
        account.UpdatedBy = actor;

        await context.SaveChangesAsync(ct);
        return Map(account);
    }

    private static WholesaleAccountDto Map(WholesaleAccount row) => new(
        row.CustomerId, row.IsWholesale, row.PriceGrade, row.TermsCode, row.TermsDays,
        row.CreditLimit.Amount, row.TaxTreatment, row.RepresentativeStaffCode,
        row.CreditHold, row.Notes, row.CreatedAt, row.CreatedBy, row.UpdatedAt,
        row.UpdatedBy);

    private static ValidationFailedException Validation(string field, string code, string message) =>
        new(new[] { new ValidationFieldError(field, code, message) });
}
