namespace xOpti.Infrastructure.Persistence.Entities;

public class CashSession
{
    public long Id { get; set; }
    public string BranchCode { get; set; } = string.Empty;
    public string TerminalCode { get; set; } = string.Empty;
    public DateOnly BusinessDate { get; set; }
    public string Status { get; set; } = "open";
    public DateTimeOffset OpenedAt { get; set; }
    public string? OpenedBy { get; set; }
    public decimal OpeningFloat { get; set; }
    public DateTimeOffset? SuspendedAt { get; set; }
    public DateTimeOffset? ClosedAt { get; set; }
    public string? ClosedBy { get; set; }
    public decimal? ExpectedCash { get; set; }
    public decimal? CountedCash { get; set; }
    public decimal? Variance { get; set; }
    public string? VarianceReason { get; set; }
}

public class CashCount
{
    public long Id { get; set; }
    public long SessionId { get; set; }
    public string Kind { get; set; } = "interim";
    public decimal Amount { get; set; }
    public DateTimeOffset CountedAt { get; set; }
    public string? CountedBy { get; set; }
    public decimal? Variance { get; set; }
    public string? Reason { get; set; }
}

public class CashMovement
{
    public long Id { get; set; }
    public long SessionId { get; set; }
    public string Kind { get; set; } = string.Empty;
    public decimal Amount { get; set; }
    public string Reason { get; set; } = string.Empty;
    public DateTimeOffset OccurredAt { get; set; }
    public string? Actor { get; set; }
    public string? DestinationReference { get; set; }
}

/// <summary>Links a posted invoice or refund to the drawer session that took it.</summary>
public class CashSessionTransaction
{
    public long Id { get; set; }
    public long SessionId { get; set; }
    public string TxNumber { get; set; } = string.Empty;
    public string TxType { get; set; } = string.Empty;
    public DateTimeOffset OccurredAt { get; set; }
}

/// <summary>Immutable finalized business-day close; corrections create a new audited row.</summary>
public class CashDailyClose
{
    public long Id { get; set; }
    public string BranchCode { get; set; } = string.Empty;
    public DateOnly BusinessDate { get; set; }
    public string Status { get; set; } = "final";
    public DateTimeOffset FinalizedAt { get; set; }
    public string? FinalizedBy { get; set; }
    public string Reason { get; set; } = string.Empty;
    public decimal TotalSales { get; set; }
    public decimal TotalRefunds { get; set; }
    public decimal TaxA { get; set; }
    public decimal TaxB { get; set; }
    public decimal CashTenders { get; set; }
    public decimal CardTenders { get; set; }
    public decimal OtherTenders { get; set; }
    public decimal PaidIn { get; set; }
    public decimal PaidOut { get; set; }
    public decimal Pickups { get; set; }
    public decimal Deposits { get; set; }
    public decimal ExpectedCash { get; set; }
    public decimal CountedCash { get; set; }
    public decimal Variance { get; set; }
    public string SnapshotJson { get; set; } = string.Empty;
}
