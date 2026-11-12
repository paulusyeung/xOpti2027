using System.Diagnostics;
using xOpti.Api.Logging;

namespace xOpti.Api.Middleware;

/// <summary>
/// Assigns a correlation id (reusing an inbound x-correlation-id header when
/// present), exposes it on the response, adds it to the log scope so
/// Seq/Loki consumers can group by it, and records one completion entry per
/// request. Request bodies, query strings, credentials, and PHI are never logged.
/// </summary>
public sealed class CorrelationIdMiddleware(RequestDelegate next, ILogger<CorrelationIdMiddleware> logger)
{
    public const string HeaderName = "x-correlation-id";
    public const string ItemKey = "xopti:correlation-id";

    public async Task InvokeAsync(HttpContext context)
    {
        var correlationId = context.Request.Headers[HeaderName].FirstOrDefault();
        if (string.IsNullOrWhiteSpace(correlationId))
        {
            correlationId = Guid.NewGuid().ToString("N");
        }

        context.Items[ItemKey] = correlationId;
        context.Response.Headers[HeaderName] = correlationId;

        var stopwatch = Stopwatch.StartNew();
        using (logger.BeginScope(new Dictionary<string, object> { ["CorrelationId"] = correlationId }))
        {
            try
            {
                await next(context);
            }
            finally
            {
                stopwatch.Stop();
                var status = context.Response.StatusCode;
                var level = status >= 500 ? LogLevel.Error : status >= 400 ? LogLevel.Warning : LogLevel.Information;
                // Path only: query strings can carry identifiers or search terms.
                logger.Log(
                    level,
                    "HTTP {Method} {Path} responded {StatusCode} in {ElapsedMs} ms",
                    context.Request.Method,
                    PiiRedaction.Redact(context.Request.Path.Value),
                    status,
                    stopwatch.ElapsedMilliseconds);
            }
        }
    }

    public static string? ForRequest(HttpContext context) =>
        context.Items.TryGetValue(ItemKey, out var value) ? value as string : null;
}
