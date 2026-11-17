namespace xOpti.Infrastructure.Persistence.Entities;

public class InsurancePlan
{
    public long Id { get; set; }
    public string PlanCode { get; set; } = string.Empty;
    public int Version { get; set; }
    public string Name { get; set; } = string.Empty;
    public string PayerName { get; set; } = string.Empty;
    public bool IsCurrent { get; set; }
    public bool IsActive { get; set; } = true;
    public DateTimeOffset CreatedAt { get; set; }
    public string? CreatedBy { get; set; }
}

public class CoverageRule
{
    public long Id { get; set; }
    public long PlanId { get; set; }
    public string? CategoryCode { get; set; }
    public string? Sku { get; set; }
    public decimal CoveragePercent { get; set; }
    public decimal AnnualMaximum { get; set; }
    public bool RequiresPreauthorization { get; set; }
}

public class InsuranceMember
{
    public long Id { get; set; }
    public int CustomerId { get; set; }
    public long PlanId { get; set; }
    public string MemberNumber { get; set; } = string.Empty;
    public string? GroupNumber { get; set; }
    public DateOnly EffectiveFrom { get; set; }
    public DateOnly? EffectiveTo { get; set; }
    public string? EligibilityNote { get; set; }
    public bool IsActive { get; set; } = true;
    public DateTimeOffset CreatedAt { get; set; }
    public string? CreatedBy { get; set; }
}

public class InsuranceClaim
{
    public long Id { get; set; }
    public string ClaimNumber { get; set; } = string.Empty;
    public string InvoiceTxNumber { get; set; } = string.Empty;
    public int CustomerId { get; set; }
    public long PlanId { get; set; }
    public int PlanVersion { get; set; }
    public long MemberId { get; set; }
    public string Status { get; set; } = "draft";
    public DateTimeOffset CreatedAt { get; set; }
    public string? CreatedBy { get; set; }
    public decimal TotalBilled { get; set; }
    public decimal CoveredAmount { get; set; }
    public decimal PatientAmount { get; set; }
    public decimal ApprovedAmount { get; set; }
    public decimal AdjustmentAmount { get; set; }
    public decimal PaidAmount { get; set; }
    public string? RejectionReason { get; set; }
    public long? ResubmissionOf { get; set; }
}

public class ClaimLine
{
    public long Id { get; set; }
    public long ClaimId { get; set; }
    public int LineNumber { get; set; }
    public int InvoiceRowNo { get; set; }
    public string Sku { get; set; } = string.Empty;
    public decimal BilledAmount { get; set; }
    public bool Eligible { get; set; }
    public decimal CoveragePercent { get; set; }
    public decimal CoveredAmount { get; set; }
    public decimal PatientAmount { get; set; }
    public string? IneligibleReason { get; set; }
}

public class ClaimEvent
{
    public long Id { get; set; }
    public long ClaimId { get; set; }
    public string EventType { get; set; } = string.Empty;
    public string? Status { get; set; }
    public decimal? Amount { get; set; }
    public string? Reason { get; set; }
    public string? Reference { get; set; }
    public DateTimeOffset OccurredAt { get; set; }
    public string? Actor { get; set; }
}

public class ClaimPayment
{
    public long Id { get; set; }
    public long ClaimId { get; set; }
    public decimal Amount { get; set; }
    public string Method { get; set; } = string.Empty;
    public string? Reference { get; set; }
    public DateTimeOffset ReceivedAt { get; set; }
    public string? Actor { get; set; }
}
