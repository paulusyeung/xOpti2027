namespace xOpti.Application.Wholesale;

/// <summary>Wholesale-only account configuration over the shared customer row.</summary>
public sealed record WholesaleAccountDto(
    int CustomerId, bool IsWholesale, string? PriceGrade, string? TermsCode,
    int TermsDays, decimal CreditLimit, string? TaxTreatment,
    string? RepresentativeStaffCode, bool CreditHold, string? Notes,
    DateTimeOffset CreatedAt, string? CreatedBy, DateTimeOffset? UpdatedAt,
    string? UpdatedBy);

public sealed record WholesaleAccountInput(
    string? PriceGrade, string? TermsCode, int TermsDays, decimal CreditLimit,
    string? TaxTreatment, string? RepresentativeStaffCode, bool CreditHold,
    string? Notes);

public interface IWholesaleAccountStore
{
    Task<WholesaleAccountDto?> GetAsync(int customerId, CancellationToken ct);

    Task<WholesaleAccountDto> SaveAsync(int customerId, WholesaleAccountInput input,
        string? actor, CancellationToken ct);
}
