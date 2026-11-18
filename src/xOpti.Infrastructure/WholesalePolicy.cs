using xOpti.Application.Ports;

namespace xOpti.Infrastructure;

public sealed class WholesalePolicy(InfrastructureOptions options) : IWholesalePolicy
{
    public bool BackordersEnabled => options.WholesaleBackordersEnabled;
}
