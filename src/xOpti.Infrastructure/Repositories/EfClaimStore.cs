using Microsoft.EntityFrameworkCore;
using xOpti.Application.Claims;
using xOpti.Application.Pipeline;
using xOpti.Domain.Values;
using xOpti.Infrastructure.Persistence;
using xOpti.Infrastructure.Persistence.Entities;

namespace xOpti.Infrastructure.Repositories;

public sealed class EfClaimStore(XOptiDbContext context) : IClaimStore
{
    public async Task<PlanDto> CreatePlanVersionAsync(
        CreatePlanInput input, string? actor, CancellationToken ct)
    {
        if (input.Rules.Count == 0)
            throw Validation("Rules", "required", "At least one coverage rule is required.");
        if (input.Rules.Any(rule => rule.CoveragePercent is < 0 or > 100))
            throw Validation("CoveragePercent", "range", "Coverage percent must be between 0 and 100.");
        await context.InsurancePlans
            .Where(row => row.PlanCode == input.PlanCode && row.IsCurrent)
            .ExecuteUpdateAsync(setter => setter.SetProperty(row => row.IsCurrent, false), ct);
        var version = (await context.InsurancePlans
            .Where(row => row.PlanCode == input.PlanCode)
            .MaxAsync(row => (int?)row.Version, ct) ?? 0) + 1;
        var plan = new InsurancePlan
        {
            PlanCode = input.PlanCode, Version = version, Name = input.Name,
            PayerName = input.PayerName, IsCurrent = true, IsActive = true,
            CreatedAt = DateTimeOffset.UtcNow, CreatedBy = actor,
        };
        context.InsurancePlans.Add(plan);
        await context.SaveChangesAsync(ct);
        foreach (var rule in input.Rules)
        {
            context.CoverageRules.Add(new CoverageRule
            {
                PlanId = plan.Id, CategoryCode = rule.CategoryCode, Sku = rule.Sku,
                CoveragePercent = rule.CoveragePercent, AnnualMaximum = rule.AnnualMaximum,
                RequiresPreauthorization = rule.RequiresPreauthorization,
            });
        }
        await context.SaveChangesAsync(ct);
        return (await GetPlanAsync(plan.Id, ct))!;
    }

    public async Task<IReadOnlyList<PlanDto>> ListPlansAsync(bool currentOnly, CancellationToken ct)
    {
        var plans = await context.InsurancePlans.AsNoTracking()
            .Where(row => !currentOnly || row.IsCurrent)
            .OrderBy(row => row.PlanCode).ThenByDescending(row => row.Version)
            .ToListAsync(ct);
        var result = new List<PlanDto>(plans.Count);
        foreach (var plan in plans) result.Add(await MapPlanAsync(plan, ct));
        return result;
    }

    public async Task<PlanDto?> GetPlanAsync(long planId, CancellationToken ct)
    {
        var plan = await context.InsurancePlans.AsNoTracking()
            .SingleOrDefaultAsync(row => row.Id == planId, ct);
        return plan is null ? null : await MapPlanAsync(plan, ct);
    }

    public async Task<MemberDto> AssignMemberAsync(int customerId, long planId,
        string memberNumber, string? groupNumber, DateOnly effectiveFrom,
        DateOnly? effectiveTo, string? eligibilityNote, string? actor, CancellationToken ct)
    {
        if (!await context.Customers.AnyAsync(row => row.Id == customerId, ct))
            throw Validation("CustomerId", "not-found", "Customer was not found.");
        var plan = await context.InsurancePlans.SingleOrDefaultAsync(row => row.Id == planId, ct)
            ?? throw Validation("PlanId", "not-found", "Insurance plan was not found.");
        var member = new InsuranceMember
        {
            CustomerId = customerId, PlanId = planId, MemberNumber = memberNumber,
            GroupNumber = groupNumber, EffectiveFrom = effectiveFrom, EffectiveTo = effectiveTo,
            EligibilityNote = eligibilityNote, IsActive = true,
            CreatedAt = DateTimeOffset.UtcNow, CreatedBy = actor,
        };
        context.InsuranceMembers.Add(member);
        await context.SaveChangesAsync(ct);
        return new MemberDto(member.Id, customerId, plan.Id, plan.PlanCode, plan.Version,
            member.MemberNumber, member.GroupNumber, member.EffectiveFrom, member.EffectiveTo,
            member.EligibilityNote, member.IsActive);
    }

    public async Task<IReadOnlyList<MemberDto>> GetMembersAsync(
        int customerId, CancellationToken ct)
    {
        var rows = await (from member in context.InsuranceMembers.AsNoTracking()
                          join plan in context.InsurancePlans.AsNoTracking()
                              on member.PlanId equals plan.Id
                          where member.CustomerId == customerId
                          orderby member.CreatedAt descending
                          select new MemberDto(member.Id, member.CustomerId, plan.Id,
                              plan.PlanCode, plan.Version, member.MemberNumber,
                              member.GroupNumber, member.EffectiveFrom, member.EffectiveTo,
                              member.EligibilityNote, member.IsActive)).ToListAsync(ct);
        return rows;
    }

    public async Task<ClaimDto> CreateClaimAsync(
        CreateClaimInput input, string? actor, CancellationToken ct)
    {
        var header = await context.TxHeaders.AsNoTracking().SingleOrDefaultAsync(row =>
            row.TxNumber == input.InvoiceTxNumber
            && row.TxType == xOpti.Domain.Values.TransactionType.RetailInvoice, ct)
            ?? throw Validation("InvoiceTxNumber", "not-found", "Invoice was not found.");
        var member = await context.InsuranceMembers.AsNoTracking()
            .SingleOrDefaultAsync(row => row.Id == input.MemberId, ct)
            ?? throw Validation("MemberId", "not-found", "Insurance member was not found.");
        if (!member.IsActive || member.CustomerId != header.CustomerId)
            throw Validation("MemberId", "ineligible", "Member is inactive or belongs to another customer.");
        var plan = await context.InsurancePlans.AsNoTracking()
            .SingleOrDefaultAsync(row => row.Id == member.PlanId, ct)
            ?? throw Validation("PlanId", "not-found", "Insurance plan was not found.");

        var duplicate = await context.Claims.AnyAsync(row =>
            row.InvoiceTxNumber == input.InvoiceTxNumber
            && row.Status != "rejected" && row.Status != "cancelled", ct);
        if (duplicate)
            throw Validation("InvoiceTxNumber", "duplicate",
                "An active claim already exists for this invoice; use resubmission.");

        var rows = await context.TxDetails.AsNoTracking()
            .Where(row => row.TxNumber == input.InvoiceTxNumber
                && input.InvoiceRowNumbers.Contains((int)row.RowNo))
            .OrderBy(row => row.RowNo).ToListAsync(ct);
        if (rows.Count == 0)
            throw Validation("InvoiceRowNumbers", "required", "Select at least one invoice line.");
        if (rows.Count != input.InvoiceRowNumbers.Distinct().Count())
            throw Validation("InvoiceRowNumbers", "invalid", "One or more invoice lines were not found.");

        var rules = await context.CoverageRules.AsNoTracking()
            .Where(row => row.PlanId == plan.Id).ToListAsync(ct);
        var claim = new InsuranceClaim
        {
            ClaimNumber = "PENDING", InvoiceTxNumber = input.InvoiceTxNumber,
            CustomerId = header.CustomerId, PlanId = plan.Id, PlanVersion = plan.Version,
            MemberId = member.Id, Status = "submitted", CreatedAt = DateTimeOffset.UtcNow,
            CreatedBy = actor,
        };
        context.Claims.Add(claim);
        await context.SaveChangesAsync(ct);
        claim.ClaimNumber = $"CL{claim.Id:D8}";
        var lineNumber = 1;
        foreach (var row in rows)
        {
            var category = await context.InventoryItems.AsNoTracking()
                .Where(item => item.Sku == row.Sku)
                .Select(item => item.CategoryCode).SingleOrDefaultAsync(ct);
            var rule = rules.FirstOrDefault(item => item.Sku == row.Sku)
                ?? rules.FirstOrDefault(item => item.CategoryCode == category)
                ?? rules.FirstOrDefault(item => item.Sku == null && item.CategoryCode == null);
            var eligible = rule is not null;
            var percent = rule?.CoveragePercent ?? 0m;
            var billed = row.Amount.Amount;
            var covered = eligible ? decimal.Round(billed * percent / 100m, 4) : 0m;
            context.ClaimLines.Add(new ClaimLine
            {
                ClaimId = claim.Id, LineNumber = lineNumber++, InvoiceRowNo = (int)row.RowNo,
                Sku = row.Sku, BilledAmount = billed, Eligible = eligible,
                CoveragePercent = percent, CoveredAmount = covered,
                PatientAmount = decimal.Round(billed - covered, 4),
                IneligibleReason = eligible ? null : "No coverage rule matched this line.",
            });
            claim.TotalBilled += billed;
            claim.CoveredAmount += covered;
            claim.PatientAmount += decimal.Round(billed - covered, 4);
        }
        context.ClaimEvents.Add(new ClaimEvent
        {
            ClaimId = claim.Id, EventType = "submitted", Status = "submitted",
            OccurredAt = DateTimeOffset.UtcNow, Actor = actor, Reason = "claim created",
        });
        await context.SaveChangesAsync(ct);
        return (await GetClaimAsync(claim.Id, ct))!;
    }

    public async Task<ClaimDto?> GetClaimAsync(long claimId, CancellationToken ct)
    {
        var claim = await context.Claims.AsNoTracking()
            .SingleOrDefaultAsync(row => row.Id == claimId, ct);
        if (claim is null) return null;
        var lines = await context.ClaimLines.AsNoTracking()
            .Where(row => row.ClaimId == claimId).OrderBy(row => row.LineNumber)
            .Select(row => new ClaimLineDto(row.LineNumber, row.InvoiceRowNo, row.Sku,
                row.BilledAmount, row.Eligible, row.CoveragePercent, row.CoveredAmount,
                row.PatientAmount, row.IneligibleReason)).ToListAsync(ct);
        var events = await context.ClaimEvents.AsNoTracking()
            .Where(row => row.ClaimId == claimId).OrderBy(row => row.OccurredAt)
            .Select(row => new ClaimEventDto(row.Id, row.EventType, row.Status, row.Amount,
                row.Reason, row.Reference, row.OccurredAt, row.Actor)).ToListAsync(ct);
        var payments = await context.ClaimPayments.AsNoTracking()
            .Where(row => row.ClaimId == claimId).OrderBy(row => row.ReceivedAt)
            .Select(row => new ClaimPaymentDto(row.Id, row.Amount, row.Method, row.Reference,
                row.ReceivedAt, row.Actor)).ToListAsync(ct);
        return MapClaim(claim, lines, events, payments);
    }

    public async Task<IReadOnlyList<ClaimDto>> ListClaimsAsync(
        string? invoiceTxNumber, CancellationToken ct)
    {
        var query = context.Claims.AsNoTracking();
        if (!string.IsNullOrWhiteSpace(invoiceTxNumber))
            query = query.Where(row => row.InvoiceTxNumber == invoiceTxNumber);
        var claims = await query.OrderByDescending(row => row.CreatedAt).Take(100).ToListAsync(ct);
        var result = new List<ClaimDto>(claims.Count);
        foreach (var claim in claims) result.Add((await GetClaimAsync(claim.Id, ct))!);
        return result;
    }

    public async Task<ClaimDto> AdjudicateAsync(long claimId, decimal approvedAmount,
        string reason, string? reference, string? actor, CancellationToken ct)
    {
        var claim = await context.Claims.SingleOrDefaultAsync(row => row.Id == claimId, ct)
            ?? throw Validation("ClaimId", "not-found", "Claim was not found.");
        if (claim.Status is "paid" or "rejected" or "cancelled")
            throw Validation("Status", "not-adjudicable", "Claim cannot be adjudicated in its current status.");
        if (approvedAmount < 0 || approvedAmount > claim.CoveredAmount)
            throw Validation("ApprovedAmount", "range",
                $"Approved amount must be between 0 and the covered amount {claim.CoveredAmount:0.0000}.");
        var adjustment = decimal.Round(claim.CoveredAmount - approvedAmount, 4);
        claim.ApprovedAmount = approvedAmount;
        claim.AdjustmentAmount = adjustment;
        claim.PatientAmount = decimal.Round(claim.PatientAmount + adjustment, 4);
        claim.Status = adjustment == 0 ? "approved" : "partially-approved";
        context.ClaimEvents.Add(new ClaimEvent
        {
            ClaimId = claim.Id, EventType = "adjudicated", Status = claim.Status,
            Amount = approvedAmount, Reason = reason, Reference = reference,
            OccurredAt = DateTimeOffset.UtcNow, Actor = actor,
        });
        await context.SaveChangesAsync(ct);
        return (await GetClaimAsync(claim.Id, ct))!;
    }

    public async Task<ClaimDto> RejectAsync(long claimId, string reason, string? actor,
        CancellationToken ct)
    {
        var claim = await context.Claims.SingleOrDefaultAsync(row => row.Id == claimId, ct)
            ?? throw Validation("ClaimId", "not-found", "Claim was not found.");
        claim.Status = "rejected";
        claim.RejectionReason = reason;
        claim.ApprovedAmount = 0m;
        claim.AdjustmentAmount = claim.CoveredAmount;
        claim.PatientAmount = decimal.Round(claim.TotalBilled, 4);
        context.ClaimEvents.Add(new ClaimEvent
        {
            ClaimId = claim.Id, EventType = "rejected", Status = "rejected", Reason = reason,
            OccurredAt = DateTimeOffset.UtcNow, Actor = actor,
        });
        await context.SaveChangesAsync(ct);
        return (await GetClaimAsync(claim.Id, ct))!;
    }

    public async Task<ClaimDto> ResubmitAsync(long claimId, string reason,
        string? reference, string? actor, CancellationToken ct)
    {
        var claim = await context.Claims.SingleOrDefaultAsync(row => row.Id == claimId, ct)
            ?? throw Validation("ClaimId", "not-found", "Claim was not found.");
        if (claim.Status != "rejected")
            throw Validation("Status", "not-rejected", "Only a rejected claim can be resubmitted.");
        claim.Status = "submitted";
        claim.RejectionReason = null;
        claim.ApprovedAmount = 0m;
        claim.AdjustmentAmount = 0m;
        claim.PatientAmount = claim.CoveredAmount;
        context.ClaimEvents.Add(new ClaimEvent
        {
            ClaimId = claim.Id, EventType = "resubmitted", Status = "submitted",
            Reason = reason, Reference = reference, OccurredAt = DateTimeOffset.UtcNow,
            Actor = actor,
        });
        await context.SaveChangesAsync(ct);
        return (await GetClaimAsync(claim.Id, ct))!;
    }

    public async Task<ClaimDto> AddPaymentAsync(long claimId, decimal amount, string method,
        string? reference, string? actor, CancellationToken ct)
    {
        var claim = await context.Claims.SingleOrDefaultAsync(row => row.Id == claimId, ct)
            ?? throw Validation("ClaimId", "not-found", "Claim was not found.");
        if (amount <= 0) throw Validation("Amount", "range", "Payment amount must be positive.");
        var remaining = decimal.Round(claim.ApprovedAmount - claim.PaidAmount, 4);
        if (amount > remaining)
            throw Validation("Amount", "over-payment",
                $"Payment exceeds the remaining approved balance {remaining:0.0000}.");
        context.ClaimPayments.Add(new ClaimPayment
        {
            ClaimId = claim.Id, Amount = amount, Method = method, Reference = reference,
            ReceivedAt = DateTimeOffset.UtcNow, Actor = actor,
        });
        claim.PaidAmount = decimal.Round(claim.PaidAmount + amount, 4);
        if (claim.PaidAmount >= claim.ApprovedAmount) claim.Status = "paid";
        context.ClaimEvents.Add(new ClaimEvent
        {
            ClaimId = claim.Id, EventType = "payment", Status = claim.Status, Amount = amount,
            Reason = "insurer payment", Reference = reference,
            OccurredAt = DateTimeOffset.UtcNow, Actor = actor,
        });
        await context.SaveChangesAsync(ct);
        return (await GetClaimAsync(claim.Id, ct))!;
    }

    public async Task<IReadOnlyList<ClaimReconciliationDto>> ReconcileAsync(CancellationToken ct)
    {
        var claims = await context.Claims.AsNoTracking().OrderBy(row => row.Id).ToListAsync(ct);
        var totals = await context.TxHeaders.AsNoTracking()
            .Where(row => claims.Select(claim => claim.InvoiceTxNumber).Contains(row.TxNumber))
            .Select(row => new { row.TxNumber, Total = row.TotalAmount.Amount }).ToListAsync(ct);
        return claims.Select(claim => new ClaimReconciliationDto(
            claim.Id, claim.ClaimNumber, claim.InvoiceTxNumber, claim.CustomerId,
            decimal.Round(totals.FirstOrDefault(row => row.TxNumber == claim.InvoiceTxNumber)?.Total ?? 0, 4),
            claim.CoveredAmount, claim.ApprovedAmount, claim.PaidAmount,
            decimal.Round(claim.ApprovedAmount - claim.PaidAmount, 4))).ToList();
    }

    public async Task<ClaimReceiptDto?> GetReceiptAsync(long claimId, CancellationToken ct)
    {
        var claim = await context.Claims.AsNoTracking()
            .SingleOrDefaultAsync(row => row.Id == claimId, ct);
        if (claim is null) return null;
        var customer = await context.Customers.AsNoTracking()
            .Where(row => row.Id == claim.CustomerId).Select(row => row.FullName)
            .SingleOrDefaultAsync(ct);
        var plan = await context.InsurancePlans.AsNoTracking()
            .SingleOrDefaultAsync(row => row.Id == claim.PlanId, ct);
        var lines = await context.ClaimLines.AsNoTracking()
            .Where(row => row.ClaimId == claimId).OrderBy(row => row.LineNumber)
            .Select(row => new ClaimReceiptLineDto(row.LineNumber, row.Sku, row.BilledAmount,
                row.CoveredAmount, row.PatientAmount, row.Eligible, row.IneligibleReason))
            .ToListAsync(ct);
        return new ClaimReceiptDto(claim.Id, claim.ClaimNumber, claim.InvoiceTxNumber,
            claim.CustomerId, customer, plan?.Name ?? "Unknown plan",
            plan?.PayerName ?? "Unknown payer", claim.PlanVersion, claim.CreatedAt,
            claim.Status, claim.TotalBilled, claim.CoveredAmount, claim.PatientAmount,
            claim.ApprovedAmount, claim.AdjustmentAmount, claim.PaidAmount, lines);
    }

    public async Task<IReadOnlyList<RbicRowDto>> GetRbicAsync(
        DateOnly from, DateOnly to, CancellationToken ct)
    {
        var start = new DateTimeOffset(from.ToDateTime(TimeOnly.MinValue), TimeSpan.Zero);
        var end = new DateTimeOffset(to.AddDays(1).ToDateTime(TimeOnly.MinValue), TimeSpan.Zero);
        var rows = await (from claim in context.Claims.AsNoTracking()
                          join plan in context.InsurancePlans.AsNoTracking()
                              on claim.PlanId equals plan.Id
                          join customer in context.Customers.AsNoTracking()
                              on claim.CustomerId equals customer.Id into customers
                          from customer in customers.DefaultIfEmpty()
                          where claim.CreatedAt >= start && claim.CreatedAt < end
                          orderby claim.ClaimNumber
                          select new RbicRowDto(claim.ClaimNumber, claim.InvoiceTxNumber,
                              claim.CustomerId, customer == null ? null : customer.FullName,
                              plan.PlanCode, plan.PayerName, claim.PlanVersion,
                              claim.CreatedAt, claim.TotalBilled, claim.CoveredAmount,
                              claim.PatientAmount, claim.ApprovedAmount, claim.PaidAmount))
            .ToListAsync(ct);
        return rows;
    }

    private async Task<PlanDto> MapPlanAsync(InsurancePlan plan, CancellationToken ct)
    {
        var rules = await context.CoverageRules.AsNoTracking()
            .Where(row => row.PlanId == plan.Id).OrderBy(row => row.Id)
            .Select(row => new CoverageRuleDto(row.Id, row.CategoryCode, row.Sku,
                row.CoveragePercent, row.AnnualMaximum, row.RequiresPreauthorization))
            .ToListAsync(ct);
        return new PlanDto(plan.Id, plan.PlanCode, plan.Version, plan.Name, plan.PayerName,
            plan.IsCurrent, plan.IsActive, rules);
    }

    private static ClaimDto MapClaim(InsuranceClaim claim, IReadOnlyList<ClaimLineDto> lines,
        IReadOnlyList<ClaimEventDto> events, IReadOnlyList<ClaimPaymentDto> payments) =>
        new(claim.Id, claim.ClaimNumber, claim.InvoiceTxNumber, claim.CustomerId, claim.PlanId,
            claim.PlanVersion, claim.MemberId, claim.Status, claim.CreatedAt,
            claim.TotalBilled, claim.CoveredAmount, claim.PatientAmount, claim.ApprovedAmount,
            claim.AdjustmentAmount, claim.PaidAmount, claim.RejectionReason,
            claim.ResubmissionOf, lines, events, payments);

    private static ValidationFailedException Validation(string field, string code, string message) =>
        new(new[] { new ValidationFieldError(field, code, message) });
}
