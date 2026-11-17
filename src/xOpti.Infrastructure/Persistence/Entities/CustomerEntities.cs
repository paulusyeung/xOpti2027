using xOpti.Domain.Values;

namespace xOpti.Infrastructure.Persistence.Entities;

public class CustomerAccount
{
    public int CustomerId { get; set; }
    public DateTimeOffset? JointDate { get; set; }
    public Money TtlAmtPurchased { get; set; }
    public Money TtlAmtRefund { get; set; }
    public Money TtlAmtMrkdwnApplied { get; set; }
    public Money TtlAmtCpnUsed { get; set; }
    public Money YtdAmtPurchased { get; set; }
    public Money YtdAmtRefund { get; set; }
    public Money YtdAmtMrkdwnApplied { get; set; }
    public Money YtdAmtCpnUsed { get; set; }
    public DateTimeOffset? LastPurchaseDate { get; set; }
}

public class CustomerMedical
{
    public int CustomerId { get; set; }
    public DateTimeOffset? InsMaturityDate { get; set; }
    public string? CareCardNo { get; set; }
    public string? CareCardValidPeriod { get; set; }
    public string? CareCardType { get; set; }
    public bool? PrescriptionLensFlag { get; set; }
    public bool? PrescriptionContactFlag { get; set; }
}

public class CustomerPresLens
{
    public int CustomerId { get; set; }
    public DateTimeOffset? IssuedOn { get; set; }
    public int IssuedByDr { get; set; }
    public double RightSphere { get; set; }
    public double RightCylinder { get; set; }
    public int RightAxis { get; set; }
    public double RightPdDist { get; set; }
    public double RightPdNear { get; set; }
    public double RightPrism { get; set; }
    public double RightAdd { get; set; }
    public double RightPupil { get; set; }
    public double LeftSphere { get; set; }
    public double LeftCylinder { get; set; }
    public int LeftAxis { get; set; }
    public double LeftPdDist { get; set; }
    public double LeftPdNear { get; set; }
    public double LeftPrism { get; set; }
    public double LeftAdd { get; set; }
    public double LeftPupil { get; set; }
}

public class CustomerPresContact
{
    public int CustomerId { get; set; }
    public DateTimeOffset? IssuedOn { get; set; }
    public int IssuedByDr { get; set; }
    public double RightSphere { get; set; }
    public double RightCylinder { get; set; }
    public int RightAxis { get; set; }
    public double RightKReadingV { get; set; }
    public double RightKReadingH { get; set; }
    public double RightPalp { get; set; }
    public double RightCorn { get; set; }
    public double RightPupil { get; set; }
    public double LeftSphere { get; set; }
    public double LeftCylinder { get; set; }
    public int LeftAxis { get; set; }
    public double LeftKReadingV { get; set; }
    public double LeftKReadingH { get; set; }
    public double LeftPalp { get; set; }
    public double LeftCorn { get; set; }
    public double LeftPupil { get; set; }
    public string? History { get; set; }
    public string? Medical { get; set; }
    public string? Allergy { get; set; }
    public string? Reason { get; set; }
    public string? Evaluation { get; set; }
    public string? Test { get; set; }
}

/// <summary>Maps a merged-away customer id to the canonical customer.</summary>
public class CustomerAlias
{
    public int AliasId { get; set; }
    public int CanonicalId { get; set; }
    public DateTimeOffset MergedAt { get; set; }
    public string? MergedBy { get; set; }
    public string Reason { get; set; } = string.Empty;
}
