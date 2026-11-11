namespace xOpti.Api;

/// <summary>Bound from the "XOptiApi" configuration section.</summary>
public sealed class ApiOptions
{
    public string ConnectionString { get; set; } = string.Empty;

    public string FileStorageRoot { get; set; } = "/var/lib/xopti/files";

    public TimeSpan IdempotencyRetention { get; set; } = TimeSpan.FromHours(24);

    public TimeSpan SessionIdle { get; set; } = TimeSpan.FromMinutes(20);

    public TimeSpan LockoutWindow { get; set; } = TimeSpan.FromMinutes(15);

    public string SessionCookieName { get; set; } = "xopti.session";

    public IReadOnlyList<string> FontDirectories { get; set; } = Array.Empty<string>();

    /// <summary>
    /// Extra origins allowed CORS credentialed requests. Empty (default) keeps
    /// the same-origin posture: nothing cross-origin is ever issued cookies.
    /// </summary>
    public IReadOnlyList<string> CorsAllowedOrigins { get; set; } = Array.Empty<string>();

    /// <summary>Enables the /api/v1/_internal/fault endpoint for integration tests only.</summary>
    public bool FaultInjectionEnabled { get; set; }

    /// <summary>Single-instance scheduled jobs; disable when scaling out.</summary>
    public bool JobsEnabled { get; set; }

    public IReadOnlyList<string> MaterializedViewRefreshStatements { get; set; } =
        new[] { "SELECT 1 /* example: replace with REFRESH MATERIALIZED VIEW analytics... */" };
}
