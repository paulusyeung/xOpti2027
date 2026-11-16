namespace xOpti.Application.Ports;

/// <summary>
/// Operator policy for POS pricing. The discount threshold is a configurable
/// percentage of the line value; until the signed policy is supplied the
/// default is zero, so every manual discount requires the override permission.
/// </summary>
public interface IPosPolicy
{
    decimal DiscountThresholdPercent { get; }

    /// <summary>Hide expected cash until a blind count is submitted.</summary>
    bool BlindCashCount { get; }
}
