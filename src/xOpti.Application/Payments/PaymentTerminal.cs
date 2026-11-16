namespace xOpti.Application.Payments;

public sealed record PaymentMethodDto(string Code, string NameShort, string NameLong);

public enum TerminalPaymentStatus
{
    Approved,
    Declined,
    Timeout,
    ManualReferenceRequired,
}

public sealed record TerminalPaymentRequest(
    string Method, decimal Amount, string? Reference, string? IdempotencyKey);

public sealed record TerminalPaymentResult(
    TerminalPaymentStatus Status, string? Reference, string? Message);

/// <summary>
/// Server-side card/manual terminal boundary. Implementations never receive or
/// return card numbers, security codes, or track data: only an opaque approval
/// reference crosses the port.
/// </summary>
public interface IPaymentTerminal
{
    Task<TerminalPaymentResult> AuthorizeAsync(
        TerminalPaymentRequest request, CancellationToken cancellationToken);
}

public static class TenderAuthorization
{
    /// <summary>
    /// Validates configured methods and asks the terminal adapter to approve
    /// every non-cash tender. Cash is never sent to the terminal.
    /// </summary>
    public static async Task AuthorizeAsync(
        IReadOnlyCollection<string> configuredMethods,
        IReadOnlyList<(string Method, decimal Amount, string? Reference)> tenders,
        IPaymentTerminal terminal, string? idempotencyKey, CancellationToken ct)
    {
        for (var index = 0; index < tenders.Count; index++)
        {
            var tender = tenders[index];
            if (!configuredMethods.Contains(tender.Method, StringComparer.OrdinalIgnoreCase))
                throw new xOpti.Application.Pipeline.ValidationFailedException(new[]
                {
                    new xOpti.Application.Pipeline.ValidationFieldError("Tenders", "unknown-method",
                        $"Payment method '{tender.Method}' is not configured."),
                });
            if (string.Equals(tender.Method, "C", StringComparison.OrdinalIgnoreCase))
                continue;

            var result = await terminal.AuthorizeAsync(new TerminalPaymentRequest(
                tender.Method, tender.Amount, tender.Reference,
                idempotencyKey is null ? null : $"{idempotencyKey}:{index}"), ct);
            if (result.Status == TerminalPaymentStatus.Approved) continue;
            throw new xOpti.Application.Pipeline.ValidationFailedException(new[]
            {
                new xOpti.Application.Pipeline.ValidationFieldError("Tenders",
                    result.Status switch
                    {
                        TerminalPaymentStatus.Declined => "terminal-declined",
                        TerminalPaymentStatus.Timeout => "terminal-timeout",
                        _ => "terminal-reference",
                    },
                    result.Message ?? "The payment terminal did not approve the tender."),
            });
        }
    }
}
