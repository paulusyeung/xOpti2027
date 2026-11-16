using xOpti.Application.Ports;

namespace xOpti.Infrastructure;

/// <summary>Configuration-backed POS policy; defaults to the strictest threshold.</summary>
public sealed class PosPolicy(InfrastructureOptions options) : IPosPolicy
{
    public decimal DiscountThresholdPercent => options.PosDiscountThresholdPercent;

    public bool BlindCashCount => options.BlindCashCount;
}
