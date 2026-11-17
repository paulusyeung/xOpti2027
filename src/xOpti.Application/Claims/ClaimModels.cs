namespace xOpti.Application.Claims;

public sealed record CoverageRuleInput(
    string? CategoryCode, string? Sku, decimal CoveragePercent,
    decimal AnnualMaximum, bool RequiresPreauthorization);

public sealed record CoverageRuleDto(
    long Id, string? CategoryCode, string? Sku, decimal CoveragePercent,
    decimal AnnualMaximum, bool RequiresPreauthorization);

public sealed record PlanDto(
    long Id, string PlanCode, int Version, string Name, string PayerName,
    bool IsCurrent, bool IsActive, IReadOnlyList<CoverageRuleDto> Rules);

public sealed record MemberDto(
    long Id, int CustomerId, long PlanId, string PlanCode, int PlanVersion,
    string MemberNumber, string? GroupNumber, DateOnly EffectiveFrom,
    DateOnly? EffectiveTo, string? EligibilityNote, bool IsActive);

public sealed record ClaimLineDto(
    int LineNumber, int InvoiceRowNo, string Sku, decimal BilledAmount, bool Eligible,
    decimal CoveragePercent, decimal CoveredAmount, decimal PatientAmount,
    string? IneligibleReason);

public sealed record ClaimEventDto(
    long Id, string EventType, string? Status, decimal? Amount, string? Reason,
    string? Reference, DateTimeOffset OccurredAt, string? Actor);

public sealed record ClaimPaymentDto(
    long Id, decimal Amount, string Method, string? Reference,
    DateTimeOffset ReceivedAt, string? Actor);

public sealed record ClaimDto(
    long Id, string ClaimNumber, string InvoiceTxNumber, int CustomerId,
    long PlanId, int PlanVersion, long MemberId, string Status, DateTimeOffset CreatedAt,
    decimal TotalBilled, decimal CoveredAmount, decimal PatientAmount,
    decimal ApprovedAmount, decimal AdjustmentAmount, decimal PaidAmount,
    string? RejectionReason, long? ResubmissionOf,
    IReadOnlyList<ClaimLineDto> Lines, IReadOnlyList<ClaimEventDto> Events,
    IReadOnlyList<ClaimPaymentDto> Payments);

public sealed record ClaimReconciliationDto(
    long ClaimId, string ClaimNumber, string InvoiceTxNumber, int CustomerId,
    decimal InvoiceTotal, decimal CoveredAmount, decimal ApprovedAmount,
    decimal PaidAmount, decimal Difference);

public sealed record CreatePlanInput(
    string PlanCode, string Name, string PayerName, IReadOnlyList<CoverageRuleInput> Rules);

public sealed record CreateClaimInput(
    string InvoiceTxNumber, long MemberId, IReadOnlyList<int> InvoiceRowNumbers);

public interface IClaimStore
{
    Task<PlanDto> CreatePlanVersionAsync(CreatePlanInput input, string? actor, CancellationToken ct);
    Task<IReadOnlyList<PlanDto>> ListPlansAsync(bool currentOnly, CancellationToken ct);
    Task<PlanDto?> GetPlanAsync(long planId, CancellationToken ct);
    Task<MemberDto> AssignMemberAsync(int customerId, long planId, string memberNumber,
        string? groupNumber, DateOnly effectiveFrom, DateOnly? effectiveTo,
        string? eligibilityNote, string? actor, CancellationToken ct);
    Task<IReadOnlyList<MemberDto>> GetMembersAsync(int customerId, CancellationToken ct);
    Task<ClaimDto> CreateClaimAsync(CreateClaimInput input, string? actor, CancellationToken ct);
    Task<ClaimDto?> GetClaimAsync(long claimId, CancellationToken ct);
    Task<IReadOnlyList<ClaimDto>> ListClaimsAsync(string? invoiceTxNumber, CancellationToken ct);
    Task<ClaimDto> AdjudicateAsync(long claimId, decimal approvedAmount, string reason,
        string? reference, string? actor, CancellationToken ct);
    Task<ClaimDto> RejectAsync(long claimId, string reason, string? actor, CancellationToken ct);
    Task<ClaimDto> ResubmitAsync(long claimId, string reason, string? reference,
        string? actor, CancellationToken ct);
    Task<ClaimDto> AddPaymentAsync(long claimId, decimal amount, string method,
        string? reference, string? actor, CancellationToken ct);
    Task<IReadOnlyList<ClaimReconciliationDto>> ReconcileAsync(CancellationToken ct);
    Task<ClaimReceiptDto?> GetReceiptAsync(long claimId, CancellationToken ct);
    Task<IReadOnlyList<RbicRowDto>> GetRbicAsync(
        DateOnly from, DateOnly to, CancellationToken ct);
}
