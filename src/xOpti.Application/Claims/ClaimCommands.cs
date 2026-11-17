using System.Text.Json;
using FluentValidation;
using xOpti.Application.Authorization;
using xOpti.Application.Common;
using xOpti.Application.Pipeline;
using xOpti.Application.Ports;

namespace xOpti.Application.Claims;

public sealed record CreateInsurancePlanCommand(CreatePlanInput Input, string Reason)
    : ICommand<PlanDto>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.ReportFinancial };
}

public sealed record ListInsurancePlansQuery(bool CurrentOnly)
    : IQuery<IReadOnlyList<PlanDto>>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.ReportFinancial };
}

public sealed record AssignInsuranceMemberCommand(
    int CustomerId, long PlanId, string MemberNumber, string? GroupNumber,
    DateOnly EffectiveFrom, DateOnly? EffectiveTo, string? EligibilityNote, string Reason)
    : ICommand<MemberDto>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.ReportFinancial };
}

public sealed record GetInsuranceMembersQuery(int CustomerId)
    : IQuery<IReadOnlyList<MemberDto>>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.ReportFinancial };
}

public sealed record CreateClaimCommand(CreateClaimInput Input, string Reason)
    : ICommand<ClaimDto>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.ReportFinancial };
}

public sealed record GetClaimQuery(long ClaimId)
    : IQuery<ClaimDto>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.ReportFinancial };
}

public sealed record ListClaimsQuery(string? InvoiceTxNumber)
    : IQuery<IReadOnlyList<ClaimDto>>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.ReportFinancial };
}

public sealed record AdjudicateClaimCommand(
    long ClaimId, decimal ApprovedAmount, string Reason, string? Reference, string? Note)
    : ICommand<ClaimDto>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.ReportFinancial };
}

public sealed record RejectClaimCommand(long ClaimId, string Reason)
    : ICommand<ClaimDto>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.ReportFinancial };
}

public sealed record ResubmitClaimCommand(long ClaimId, string Reason, string? Reference)
    : ICommand<ClaimDto>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.ReportFinancial };
}

public sealed record AddClaimPaymentCommand(
    long ClaimId, decimal Amount, string Method, string? Reference, string Reason)
    : ICommand<ClaimDto>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.ReportFinancial };
}

public sealed record GetClaimReconciliationQuery
    : IQuery<IReadOnlyList<ClaimReconciliationDto>>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.ReportFinancial };
}

public sealed class CreateInsurancePlanCommandValidator : AbstractValidator<CreateInsurancePlanCommand>
{
    public CreateInsurancePlanCommandValidator()
    {
        RuleFor(x => x.Input.PlanCode).NotEmpty().MaximumLength(40);
        RuleFor(x => x.Input.Name).NotEmpty().MaximumLength(120);
        RuleFor(x => x.Input.PayerName).NotEmpty().MaximumLength(120);
        RuleFor(x => x.Input.Rules).NotEmpty();
        RuleForEach(x => x.Input.Rules).ChildRules(rule =>
        {
            rule.RuleFor(x => x.CoveragePercent).InclusiveBetween(0m, 100m);
            rule.RuleFor(x => x.AnnualMaximum).GreaterThanOrEqualTo(0m);
        });
        RuleFor(x => x.Reason).NotEmpty().MinimumLength(3).MaximumLength(500);
    }
}

public sealed class AssignInsuranceMemberCommandValidator
    : AbstractValidator<AssignInsuranceMemberCommand>
{
    public AssignInsuranceMemberCommandValidator()
    {
        RuleFor(x => x.CustomerId).GreaterThan(0);
        RuleFor(x => x.PlanId).GreaterThan(0);
        RuleFor(x => x.MemberNumber).NotEmpty().MaximumLength(60);
        RuleFor(x => x.EffectiveTo)
            .GreaterThanOrEqualTo(x => x.EffectiveFrom)
            .When(x => x.EffectiveTo is not null);
        RuleFor(x => x.Reason).NotEmpty().MinimumLength(3).MaximumLength(500);
    }
}

public sealed class CreateClaimCommandValidator : AbstractValidator<CreateClaimCommand>
{
    public CreateClaimCommandValidator()
    {
        RuleFor(x => x.Input.InvoiceTxNumber).NotEmpty().MaximumLength(10);
        RuleFor(x => x.Input.MemberId).GreaterThan(0);
        RuleFor(x => x.Input.InvoiceRowNumbers).NotEmpty();
        RuleFor(x => x.Reason).NotEmpty().MinimumLength(3).MaximumLength(500);
    }
}

public sealed class AdjudicateClaimCommandValidator : AbstractValidator<AdjudicateClaimCommand>
{
    public AdjudicateClaimCommandValidator()
    {
        RuleFor(x => x.ClaimId).GreaterThan(0);
        RuleFor(x => x.ApprovedAmount).GreaterThanOrEqualTo(0);
        RuleFor(x => x.Reason).NotEmpty().MinimumLength(3).MaximumLength(500);
    }
}

public sealed class AddClaimPaymentCommandValidator : AbstractValidator<AddClaimPaymentCommand>
{
    public AddClaimPaymentCommandValidator()
    {
        RuleFor(x => x.ClaimId).GreaterThan(0);
        RuleFor(x => x.Amount).GreaterThan(0);
        RuleFor(x => x.Method).NotEmpty().MaximumLength(20);
        RuleFor(x => x.Reason).NotEmpty().MinimumLength(3).MaximumLength(500);
    }
}

public sealed class CreateInsurancePlanHandler(
    IUnitOfWork unitOfWork, IClaimStore store, IAuditRecorder audit, ICurrentPrincipal principal)
    : IRequestHandler<CreateInsurancePlanCommand, PlanDto>
{
    public Task<PlanDto> Handle(CreateInsurancePlanCommand request, CancellationToken ct) =>
        unitOfWork.ExecuteInTransactionAsync(async token =>
        {
            var plan = await store.CreatePlanVersionAsync(request.Input, principal.UserId, token);
            await audit.RecordAsync(new AuditRecord("claim.plan.create", "InsurancePlan",
                plan.Id.ToString(), JsonSerializer.Serialize(new
                {
                    plan.PlanCode, plan.Version, rules = plan.Rules.Count, request.Reason,
                })), token);
            return plan;
        }, ct);
}

public sealed class ListInsurancePlansHandler(IClaimStore store)
    : IRequestHandler<ListInsurancePlansQuery, IReadOnlyList<PlanDto>>
{
    public Task<IReadOnlyList<PlanDto>> Handle(
        ListInsurancePlansQuery request, CancellationToken ct) =>
        store.ListPlansAsync(request.CurrentOnly, ct);
}

public sealed class AssignInsuranceMemberHandler(
    IUnitOfWork unitOfWork, IClaimStore store, IAuditRecorder audit, ICurrentPrincipal principal)
    : IRequestHandler<AssignInsuranceMemberCommand, MemberDto>
{
    public Task<MemberDto> Handle(AssignInsuranceMemberCommand request, CancellationToken ct) =>
        unitOfWork.ExecuteInTransactionAsync(async token =>
        {
            var member = await store.AssignMemberAsync(request.CustomerId, request.PlanId,
                request.MemberNumber, request.GroupNumber, request.EffectiveFrom,
                request.EffectiveTo, request.EligibilityNote, principal.UserId, token);
            await audit.RecordAsync(new AuditRecord("claim.member.assign", "InsuranceMember",
                member.Id.ToString(), JsonSerializer.Serialize(new
                {
                    request.CustomerId, request.PlanId, request.MemberNumber,
                    request.Reason,
                })), token);
            return member;
        }, ct);
}

public sealed class GetInsuranceMembersHandler(IClaimStore store)
    : IRequestHandler<GetInsuranceMembersQuery, IReadOnlyList<MemberDto>>
{
    public Task<IReadOnlyList<MemberDto>> Handle(
        GetInsuranceMembersQuery request, CancellationToken ct) =>
        store.GetMembersAsync(request.CustomerId, ct);
}

public sealed class CreateClaimHandler(
    IUnitOfWork unitOfWork, IClaimStore store, IAuditRecorder audit, ICurrentPrincipal principal)
    : IRequestHandler<CreateClaimCommand, ClaimDto>
{
    public Task<ClaimDto> Handle(CreateClaimCommand request, CancellationToken ct) =>
        unitOfWork.ExecuteInTransactionAsync(async token =>
        {
            var claim = await store.CreateClaimAsync(request.Input, principal.UserId, token);
            await audit.RecordAsync(new AuditRecord("claim.create", "Claim",
                claim.Id.ToString(), JsonSerializer.Serialize(new
                {
                    claim.ClaimNumber, claim.InvoiceTxNumber, claim.CoveredAmount,
                    claim.PatientAmount, request.Reason,
                })), token);
            return claim;
        }, ct);
}

public sealed class GetClaimHandler(IClaimStore store)
    : IRequestHandler<GetClaimQuery, ClaimDto>
{
    public async Task<ClaimDto> Handle(GetClaimQuery request, CancellationToken ct) =>
        await store.GetClaimAsync(request.ClaimId, ct)
        ?? throw new ValidationFailedException(new[]
        {
            new ValidationFieldError("ClaimId", "not-found", "Claim was not found."),
        });
}

public sealed class ListClaimsHandler(IClaimStore store)
    : IRequestHandler<ListClaimsQuery, IReadOnlyList<ClaimDto>>
{
    public Task<IReadOnlyList<ClaimDto>> Handle(
        ListClaimsQuery request, CancellationToken ct) =>
        store.ListClaimsAsync(request.InvoiceTxNumber, ct);
}

public sealed class AdjudicateClaimHandler(
    IUnitOfWork unitOfWork, IClaimStore store, IAuditRecorder audit, ICurrentPrincipal principal)
    : IRequestHandler<AdjudicateClaimCommand, ClaimDto>
{
    public Task<ClaimDto> Handle(AdjudicateClaimCommand request, CancellationToken ct) =>
        unitOfWork.ExecuteInTransactionAsync(async token =>
        {
            var claim = await store.AdjudicateAsync(request.ClaimId, request.ApprovedAmount,
                request.Reason, request.Reference, principal.UserId, token);
            await audit.RecordAsync(new AuditRecord("claim.adjudicate", "Claim",
                claim.Id.ToString(), JsonSerializer.Serialize(new
                {
                    request.ApprovedAmount, claim.Status, request.Reason,
                    request.Reference, request.Note,
                })), token);
            return claim;
        }, ct);
}

public sealed class RejectClaimHandler(
    IUnitOfWork unitOfWork, IClaimStore store, IAuditRecorder audit, ICurrentPrincipal principal)
    : IRequestHandler<RejectClaimCommand, ClaimDto>
{
    public Task<ClaimDto> Handle(RejectClaimCommand request, CancellationToken ct) =>
        unitOfWork.ExecuteInTransactionAsync(async token =>
        {
            var claim = await store.RejectAsync(request.ClaimId, request.Reason,
                principal.UserId, token);
            await audit.RecordAsync(new AuditRecord("claim.reject", "Claim",
                claim.Id.ToString(), JsonSerializer.Serialize(new { request.Reason })), token);
            return claim;
        }, ct);
}

public sealed class ResubmitClaimHandler(
    IUnitOfWork unitOfWork, IClaimStore store, IAuditRecorder audit, ICurrentPrincipal principal)
    : IRequestHandler<ResubmitClaimCommand, ClaimDto>
{
    public Task<ClaimDto> Handle(ResubmitClaimCommand request, CancellationToken ct) =>
        unitOfWork.ExecuteInTransactionAsync(async token =>
        {
            var claim = await store.ResubmitAsync(request.ClaimId, request.Reason,
                request.Reference, principal.UserId, token);
            await audit.RecordAsync(new AuditRecord("claim.resubmit", "Claim",
                claim.Id.ToString(), JsonSerializer.Serialize(new
                {
                    request.Reason, request.Reference,
                })), token);
            return claim;
        }, ct);
}

public sealed class AddClaimPaymentHandler(
    IUnitOfWork unitOfWork, IClaimStore store, IAuditRecorder audit, ICurrentPrincipal principal)
    : IRequestHandler<AddClaimPaymentCommand, ClaimDto>
{
    public Task<ClaimDto> Handle(AddClaimPaymentCommand request, CancellationToken ct) =>
        unitOfWork.ExecuteInTransactionAsync(async token =>
        {
            var claim = await store.AddPaymentAsync(request.ClaimId, request.Amount,
                request.Method, request.Reference, principal.UserId, token);
            await audit.RecordAsync(new AuditRecord("claim.payment", "Claim",
                claim.Id.ToString(), JsonSerializer.Serialize(new
                {
                    request.Amount, request.Method, request.Reference, request.Reason,
                    claim.PaidAmount,
                })), token);
            return claim;
        }, ct);
}

public sealed class GetClaimReconciliationHandler(IClaimStore store)
    : IRequestHandler<GetClaimReconciliationQuery, IReadOnlyList<ClaimReconciliationDto>>
{
    public Task<IReadOnlyList<ClaimReconciliationDto>> Handle(
        GetClaimReconciliationQuery request, CancellationToken ct) =>
        store.ReconcileAsync(ct);
}
