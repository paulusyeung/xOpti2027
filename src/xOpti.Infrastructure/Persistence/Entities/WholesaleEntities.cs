using xOpti.Domain.Values;

namespace xOpti.Infrastructure.Persistence.Entities;

/// <summary>
/// App-owned wholesale account configuration. Customer identity, credit limit
/// history, and representatives stay on the migrated customer/staff rows; this
/// table records the wholesale-only terms and price-list assignment.
/// </summary>
public class WholesaleAccount
{
    public int CustomerId { get; set; }

    public bool IsWholesale { get; set; }

    /// <summary>Legacy wholesale price grade: A, B, or C.</summary>
    public string? PriceGrade { get; set; }

    public string? TermsCode { get; set; }

    public int TermsDays { get; set; }

    public Money CreditLimit { get; set; }

    /// <summary>Tax treatment code applied to wholesale documents.</summary>
    public string? TaxTreatment { get; set; }

    /// <summary>Migrated staff_code of the assigned sales representative.</summary>
    public string? RepresentativeStaffCode { get; set; }

    public bool CreditHold { get; set; }

    public string? Notes { get; set; }

    public DateTimeOffset CreatedAt { get; set; }

    public string? CreatedBy { get; set; }

    public DateTimeOffset? UpdatedAt { get; set; }

    public string? UpdatedBy { get; set; }
}
