using xOpti.Application.Payments;

namespace xOpti.Infrastructure;

/// <summary>
/// Manual fallback: the operator captures the terminal's opaque approval
/// reference. No card data is accepted, persisted, or logged.
/// </summary>
public sealed class ManualPaymentTerminal : IPaymentTerminal
{
    public Task<TerminalPaymentResult> AuthorizeAsync(
        TerminalPaymentRequest request, CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(request.Reference))
        {
            return Task.FromResult(new TerminalPaymentResult(
                TerminalPaymentStatus.ManualReferenceRequired, null,
                $"Capture the terminal approval reference for the {request.Method} payment."));
        }

        return Task.FromResult(new TerminalPaymentResult(
            TerminalPaymentStatus.Approved, request.Reference, null));
    }
}

/// <summary>Disposable test harness; selected only by explicit configuration.</summary>
public sealed class SimulatedPaymentTerminal : IPaymentTerminal
{
    public Task<TerminalPaymentResult> AuthorizeAsync(
        TerminalPaymentRequest request, CancellationToken cancellationToken)
    {
        var reference = request.Reference?.Trim();
        if (string.Equals(reference, "SIM-DECL", StringComparison.OrdinalIgnoreCase))
        {
            return Task.FromResult(new TerminalPaymentResult(
                TerminalPaymentStatus.Declined, null, "The simulated terminal declined the payment."));
        }

        if (string.Equals(reference, "SIM-TIME", StringComparison.OrdinalIgnoreCase))
        {
            return Task.FromResult(new TerminalPaymentResult(
                TerminalPaymentStatus.Timeout, null, "The simulated terminal timed out."));
        }

        return Task.FromResult(new TerminalPaymentResult(
            TerminalPaymentStatus.Approved,
            string.IsNullOrWhiteSpace(reference) ? "SIM-" + Guid.NewGuid().ToString("N")[..8] : reference,
            null));
    }
}
