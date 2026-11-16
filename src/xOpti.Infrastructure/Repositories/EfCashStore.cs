using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using xOpti.Application.Cash;
using xOpti.Application.Pipeline;
using xOpti.Application.Ports;
using xOpti.Domain.Values;
using xOpti.Infrastructure.Persistence;
using xOpti.Infrastructure.Persistence.Entities;

namespace xOpti.Infrastructure.Repositories;

public sealed class EfCashStore(XOptiDbContext context, IClock clock) : ICashStore
{
    public Task<bool> BranchExistsAsync(string branchCode, CancellationToken ct) =>
        context.Branches.AnyAsync(row => row.BranchCode == branchCode, ct);

    public async Task<CashSessionDto?> SessionAsync(long id, CancellationToken ct)
    {
        var session = await context.CashSessions.AsNoTracking()
            .SingleOrDefaultAsync(row => row.Id == id, ct);
        return session is null ? null : await MapAsync(session, ct);
    }

    public async Task<CashSessionDetailDto?> SessionDetailAsync(long id, CancellationToken ct)
    {
        var session = await SessionAsync(id, ct);
        if (session is null) return null;
        var counts = await context.CashCounts.AsNoTracking()
            .Where(row => row.SessionId == id).OrderBy(row => row.CountedAt)
            .Select(row => new CashCountDto(row.Id, row.Kind, row.Amount, row.CountedAt,
                row.CountedBy, row.Variance, row.Reason)).ToListAsync(ct);
        var movements = await context.CashMovements.AsNoTracking()
            .Where(row => row.SessionId == id).OrderBy(row => row.OccurredAt)
            .Select(row => new CashMovementDto(row.Id, row.Kind, row.Amount, row.Reason,
                row.OccurredAt, row.Actor, row.DestinationReference)).ToListAsync(ct);
        return new CashSessionDetailDto(session, counts, movements);
    }

    public async Task<IReadOnlyList<CashSessionDto>> SessionsAsync(
        string branchCode, DateOnly businessDate, CancellationToken ct)
    {
        var sessions = await context.CashSessions.AsNoTracking()
            .Where(row => row.BranchCode == branchCode && row.BusinessDate == businessDate)
            .OrderBy(row => row.TerminalCode).ThenBy(row => row.OpenedAt).ToListAsync(ct);
        var results = new List<CashSessionDto>(sessions.Count);
        foreach (var session in sessions) results.Add(await MapAsync(session, ct));
        return results;
    }

    public async Task<IReadOnlyList<CashSessionDto>> OpenSessionsAsync(
        string branchCode, CancellationToken ct)
    {
        var sessions = await context.CashSessions.AsNoTracking()
            .Where(row => row.BranchCode == branchCode
                && (row.Status == "open" || row.Status == "suspended"))
            .OrderBy(row => row.TerminalCode).ToListAsync(ct);
        var results = new List<CashSessionDto>(sessions.Count);
        foreach (var session in sessions) results.Add(await MapAsync(session, ct));
        return results;
    }

    public async Task<decimal> ExpectedCashAsync(long sessionId, CancellationToken ct)
    {
        var session = await context.CashSessions.AsNoTracking()
            .SingleOrDefaultAsync(row => row.Id == sessionId, ct);
        if (session is null) return 0m;

        var txNumbers = await context.CashSessionTransactions.AsNoTracking()
            .Where(row => row.SessionId == sessionId).Select(row => row.TxNumber).ToListAsync(ct);
        var cashAmounts = await context.TxPayments.AsNoTracking()
            .Where(row => txNumbers.Contains(row.TxNumber) && row.Type == "C")
            .Select(row => row.TotalThisPay.Amount).ToListAsync(ct);
        var movements = await context.CashMovements.AsNoTracking()
            .Where(row => row.SessionId == sessionId)
            .Select(row => new { row.Kind, row.Amount }).ToListAsync(ct);

        var expected = session.OpeningFloat + cashAmounts.Sum();
        foreach (var movement in movements)
        {
            expected += movement.Kind switch
            {
                "paid-in" => movement.Amount,
                "paid-out" or "pickup" or "deposit" => -movement.Amount,
                _ => 0m,
            };
        }
        return decimal.Round(expected, 4);
    }

    public async Task<long> OpenSessionAsync(string branchCode, string terminalCode,
        DateOnly businessDate, decimal openingFloat, string? actor, CancellationToken ct)
    {
        if (await context.CashSessions.AnyAsync(row => row.BranchCode == branchCode
                && row.TerminalCode == terminalCode
                && (row.Status == "open" || row.Status == "suspended"), ct))
        {
            throw Validation("TerminalCode", "duplicate-session",
                $"Terminal {terminalCode} already has an open drawer session; close it first.");
        }

        var session = new CashSession
        {
            BranchCode = branchCode, TerminalCode = terminalCode, BusinessDate = businessDate,
            Status = "open", OpenedAt = clock.UtcNow, OpenedBy = actor, OpeningFloat = openingFloat,
        };
        context.CashSessions.Add(session);
        await context.SaveChangesAsync(ct);
        context.CashCounts.Add(new CashCount
        {
            SessionId = session.Id, Kind = "opening", Amount = openingFloat,
            CountedAt = session.OpenedAt, CountedBy = actor, Variance = 0m,
            Reason = "Opening float",
        });
        await context.SaveChangesAsync(ct);
        return session.Id;
    }

    public async Task SuspendAsync(long sessionId, string? actor, CancellationToken ct)
    {
        var session = await RequireAsync(sessionId, ct);
        if (session.Status != "open")
            throw Validation("SessionId", "not-open", "Only an open session can be suspended.");
        session.Status = "suspended";
        session.SuspendedAt = clock.UtcNow;
        await context.SaveChangesAsync(ct);
    }

    public async Task ResumeAsync(long sessionId, string? actor, CancellationToken ct)
    {
        var session = await RequireAsync(sessionId, ct);
        if (session.Status != "suspended")
            throw Validation("SessionId", "not-suspended", "Only a suspended session can be resumed.");
        session.Status = "open";
        session.SuspendedAt = null;
        await context.SaveChangesAsync(ct);
    }

    public async Task CloseAsync(long sessionId, decimal countedCash, decimal expectedCash,
        decimal variance, string? varianceReason, string? actor, CancellationToken ct)
    {
        var session = await RequireAsync(sessionId, ct);
        if (session.Status == "closed")
            throw Validation("SessionId", "already-closed", "The drawer session is already closed.");
        var now = clock.UtcNow;
        session.Status = "closed";
        session.ClosedAt = now;
        session.ClosedBy = actor;
        session.ExpectedCash = expectedCash;
        session.CountedCash = countedCash;
        session.Variance = variance;
        session.VarianceReason = varianceReason;
        context.CashCounts.Add(new CashCount
        {
            SessionId = sessionId, Kind = "closing", Amount = countedCash, CountedAt = now,
            CountedBy = actor, Variance = variance, Reason = varianceReason,
        });
        await context.SaveChangesAsync(ct);
    }

    public async Task RecordCountAsync(long sessionId, string kind, decimal amount,
        decimal variance, string? reason, string? actor, CancellationToken ct)
    {
        _ = await RequireAsync(sessionId, ct);
        context.CashCounts.Add(new CashCount
        {
            SessionId = sessionId, Kind = kind, Amount = amount, CountedAt = clock.UtcNow,
            CountedBy = actor, Variance = variance, Reason = reason,
        });
        await context.SaveChangesAsync(ct);
    }

    public async Task RecordMovementAsync(long sessionId, string kind, decimal amount,
        string reason, string? destinationReference, string? actor, CancellationToken ct)
    {
        _ = await RequireAsync(sessionId, ct);
        context.CashMovements.Add(new CashMovement
        {
            SessionId = sessionId, Kind = kind, Amount = amount, Reason = reason,
            OccurredAt = clock.UtcNow, Actor = actor, DestinationReference = destinationReference,
        });
        await context.SaveChangesAsync(ct);
    }

    public async Task<CashJournalDto> JournalAsync(
        string branchCode, DateOnly businessDate, CancellationToken ct)
    {
        var finalized = await context.CashDailyCloses.AsNoTracking().SingleOrDefaultAsync(
            row => row.BranchCode == branchCode && row.BusinessDate == businessDate, ct);
        if (finalized is not null)
            return JsonSerializer.Deserialize<CashJournalDto>(finalized.SnapshotJson)!;
        return await BuildJournalAsync(branchCode, businessDate, ct);
    }

    public async Task<CashJournalDto> FinalizeDailyCloseAsync(
        string branchCode, DateOnly businessDate, string reason, string? actor, CancellationToken ct)
    {
        if (await context.CashDailyCloses.AnyAsync(row =>
                row.BranchCode == branchCode && row.BusinessDate == businessDate, ct))
        {
            throw Validation("BusinessDate", "already-final",
                "The business day is already finalized; use the approved correction workflow.");
        }

        var journal = await BuildJournalAsync(branchCode, businessDate, ct);
        if (journal.Sessions.Count == 0)
            throw Validation("BusinessDate", "no-sessions",
                "No drawer sessions exist for this branch and business date.");
        var open = journal.Sessions.Where(row => row.Status != "closed").ToList();
        if (open.Count > 0)
            throw Validation("Sessions", "terminals-open",
                $"Close all terminals first: {string.Join(", ", open.Select(row => row.TerminalCode))}.");

        var finalizedAt = clock.UtcNow;
        var final = journal with
        {
            Status = "final", FinalizedAt = finalizedAt, FinalizedBy = actor, Reason = reason,
        };
        context.CashDailyCloses.Add(new CashDailyClose
        {
            BranchCode = branchCode, BusinessDate = businessDate, Status = "final",
            FinalizedAt = finalizedAt, FinalizedBy = actor, Reason = reason,
            TotalSales = final.TotalSales, TotalRefunds = final.TotalRefunds,
            TaxA = final.TaxA, TaxB = final.TaxB, CashTenders = final.CashTenders,
            CardTenders = final.CardTenders, OtherTenders = final.OtherTenders,
            PaidIn = final.PaidIn, PaidOut = final.PaidOut, Pickups = final.Pickups,
            Deposits = final.Deposits, ExpectedCash = final.ExpectedCash,
            CountedCash = final.CountedCash, Variance = final.Variance,
            SnapshotJson = JsonSerializer.Serialize(final),
        });
        await context.SaveChangesAsync(ct);
        return final;
    }

    private async Task<CashJournalDto> BuildJournalAsync(
        string branchCode, DateOnly businessDate, CancellationToken ct)
    {
        var sessions = await SessionsAsync(branchCode, businessDate, ct);
        var sessionIds = sessions.Select(row => row.Id).ToList();
        var txNumbers = await context.CashSessionTransactions.AsNoTracking()
            .Where(row => sessionIds.Contains(row.SessionId))
            .Select(row => row.TxNumber).ToListAsync(ct);
        var headers = await context.TxHeaders.AsNoTracking()
            .Where(row => txNumbers.Contains(row.TxNumber)).OrderBy(row => row.TxNumber)
            .ToListAsync(ct);
        var payments = await context.TxPayments.AsNoTracking()
            .Where(row => txNumbers.Contains(row.TxNumber)).ToListAsync(ct);
        var movements = await context.CashMovements.AsNoTracking()
            .Where(row => sessionIds.Contains(row.SessionId)).OrderBy(row => row.OccurredAt)
            .Select(row => new CashMovementDto(row.Id, row.Kind, row.Amount, row.Reason,
                row.OccurredAt, row.Actor, row.DestinationReference)).ToListAsync(ct);

        var sales = headers.Where(row => row.TxType == TransactionType.RetailInvoice).ToList();
        var refunds = headers.Where(row => row.TxType == TransactionType.RetailRefund).ToList();
        var cash = payments.Where(row => row.Type == "C").Sum(row => row.TotalThisPay.Amount);
        var card = payments.Where(row => row.Type == "K").Sum(row => row.TotalThisPay.Amount);
        var other = payments.Where(row => row.Type != "C" && row.Type != "K")
            .Sum(row => row.TotalThisPay.Amount);
        var paidIn = movements.Where(row => row.Kind == "paid-in").Sum(row => row.Amount);
        var paidOut = movements.Where(row => row.Kind == "paid-out").Sum(row => row.Amount);
        var pickups = movements.Where(row => row.Kind == "pickup").Sum(row => row.Amount);
        var deposits = movements.Where(row => row.Kind == "deposit").Sum(row => row.Amount);
        var openingFloat = sessions.Sum(row => row.OpeningFloat);
        var expected = openingFloat + cash + paidIn - paidOut - pickups - deposits;

        var documents = headers.Select(header => new CashJournalDocumentDto(
            header.TxNumber, header.TxType.ToLegacyCode(), header.TotalSale.Amount,
            header.TaxA.Amount, header.TaxB.Amount, header.TotalAmount.Amount,
            payments.Where(row => row.TxNumber == header.TxNumber)
                .Select(row => new CashJournalTenderDto(row.Type, row.TotalThisPay.Amount))
                .ToList())).ToList();

        return new CashJournalDto(branchCode, businessDate, "draft", null, null, null,
            sales.Sum(row => row.TotalSale.Amount), -refunds.Sum(row => row.TotalSale.Amount),
            headers.Sum(row => row.TaxA.Amount), headers.Sum(row => row.TaxB.Amount),
            decimal.Round(cash, 4), decimal.Round(card, 4), decimal.Round(other, 4),
            decimal.Round(paidIn, 4), decimal.Round(paidOut, 4), decimal.Round(pickups, 4),
            decimal.Round(deposits, 4), decimal.Round(expected, 4),
            decimal.Round(sessions.Sum(row => row.CountedCash ?? 0), 4),
            decimal.Round(sessions.Sum(row => row.Variance ?? 0), 4),
            sessions, documents, movements);
    }

    private async Task<CashSessionDto> MapAsync(CashSession session, CancellationToken ct) =>
        new(session.Id, session.BranchCode, session.TerminalCode, session.BusinessDate,
            session.Status, session.OpenedAt, session.OpenedBy, session.OpeningFloat,
            await ExpectedCashAsync(session.Id, ct), session.SuspendedAt, session.ClosedAt,
            session.ClosedBy, session.CountedCash, session.Variance, session.VarianceReason);

    private async Task<CashSession> RequireAsync(long id, CancellationToken ct) =>
        await context.CashSessions.SingleOrDefaultAsync(row => row.Id == id, ct)
        ?? throw Validation("SessionId", "not-found", "Cash session was not found.");

    private static ValidationFailedException Validation(string field, string code, string message) =>
        new(new[] { new ValidationFieldError(field, code, message) });
}
