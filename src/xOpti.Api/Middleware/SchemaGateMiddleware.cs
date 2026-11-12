using Microsoft.AspNetCore.Mvc;
using xOpti.Api.Health;

namespace xOpti.Api.Middleware;

/// <summary>
/// Rejects business requests with a 503 problem document when the database is
/// not bootstrapped or its schema baseline no longer matches the deployed
/// script. Health, OpenAPI, and static routes stay reachable so operators can
/// diagnose the instance.
/// </summary>
public sealed class SchemaGateMiddleware(RequestDelegate next, SchemaReadinessProbe probe)
{
    public async Task InvokeAsync(HttpContext context)
    {
        if (!IsBusinessRequest(context.Request.Path))
        {
            await next(context);
            return;
        }

        var status = await probe.CheckAsync(context.RequestAborted);
        if (status.Ready)
        {
            await next(context);
            return;
        }

        var problem = new ProblemDetails
        {
            Type = Problems.ServiceUnavailable,
            Title = "Service unavailable",
            Status = StatusCodes.Status503ServiceUnavailable,
            Detail = status.Detail,
        };

        await ProblemResponses.WriteAsync(
            context.Response,
            problem,
            new Dictionary<string, string> { ["Retry-After"] = "30" });
    }

    /// <summary>
    /// Business endpoints are everything under <c>/api</c> except the health
    /// endpoints; the SPA shell and OpenAPI document are not gated.
    /// </summary>
    public static bool IsBusinessRequest(PathString path) =>
        path.StartsWithSegments("/api", StringComparison.OrdinalIgnoreCase)
        && !path.StartsWithSegments("/api/health", StringComparison.OrdinalIgnoreCase);
}
