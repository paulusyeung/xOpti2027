using System.Text.RegularExpressions;

namespace xOpti.Api.Logging;

/// <summary>
/// Masks patient/payment identifiers before they can reach a log sink. Call this
/// on any free-form text that may contain user input; the API does not log
/// request bodies, but support bundles and exception messages can carry values.
/// </summary>
public static partial class PiiRedaction
{
    public const string Mask = "[redacted]";

    public static string Redact(string? value)
    {
        if (string.IsNullOrEmpty(value))
        {
            return string.Empty;
        }

        var redacted = Email().Replace(value, Mask);
        redacted = Sin().Replace(redacted, Mask);
        redacted = Phone().Replace(redacted, Mask);
        redacted = Card().Replace(redacted, Mask);
        return redacted;
    }

    [GeneratedRegex(@"[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}")]
    private static partial Regex Email();

    [GeneratedRegex(@"\b\d{3}-\d{3}-\d{3}\b")]
    private static partial Regex Sin();

    [GeneratedRegex(@"\b(?:\+?1[-.\s]?)?\(?\d{3}\)?[-.\s]\d{3}[-.\s]\d{4}\b")]
    private static partial Regex Phone();

    [GeneratedRegex(@"\b(?:\d[ -]?){13,19}\b")]
    private static partial Regex Card();
}
