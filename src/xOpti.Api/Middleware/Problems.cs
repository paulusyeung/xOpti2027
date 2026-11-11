namespace xOpti.Api.Middleware;

/// <summary>Stable problem type URIs for the xOpti error contract.</summary>
public static class Problems
{
    public const string Validation = "https://errors.xopti/validation";
    public const string Authorization = "https://errors.xopti/authorization";
    public const string Unauthenticated = "https://errors.xopti/unauthenticated";
    public const string SessionExpired = "https://errors.xopti/session-expired";
    public const string ResetRequired = "https://errors.xopti/reset-required";
    public const string ConcurrencyConflict = "https://errors.xopti/concurrency-conflict";
    public const string IdempotencyConflict = "https://errors.xopti/idempotency-conflict";
    public const string IdempotencyKeyRequired = "https://errors.xopti/idempotency-key-required";
    public const string UnsupportedRequest = "https://errors.xopti/unsupported-request";
    public const string DomainRule = "https://errors.xopti/domain-rule";
    public const string NotFound = "https://errors.xopti/not-found";
    public const string Unhandled = "https://errors.xopti/unhandled";
}
