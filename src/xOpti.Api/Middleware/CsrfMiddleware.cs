using Microsoft.AspNetCore.Antiforgery;
using Microsoft.AspNetCore.Mvc;

namespace xOpti.Api.Middleware;

/// <summary>
/// Same-origin CSRF defense for state-changing API requests: unsafe methods
/// must present the antiforgery request token (header) alongside the
/// antiforgery cookie. Applied after authentication, before authorization.
/// </summary>
public sealed class CsrfMiddleware(RequestDelegate next, IAntiforgery antiforgery)
{
    public const string HeaderName = "X-CSRF-TOKEN";

    private static readonly HashSet<string> SafeMethods =
        new(StringComparer.OrdinalIgnoreCase) { "GET", "HEAD", "OPTIONS" };

    public async Task InvokeAsync(HttpContext context)
    {
        if (!SafeMethods.Contains(context.Request.Method)
            && context.Request.Path.StartsWithSegments("/api")
            && !context.Request.Path.StartsWithSegments("/api/v1/auth/csrf-token"))
        {
            try
            {
                await antiforgery.ValidateRequestAsync(context);
            }
            catch (AntiforgeryValidationException)
            {
                var problem = new ProblemDetails
                {
                    Type = Problems.Authorization,
                    Title = "Forbidden",
                    Status = StatusCodes.Status403Forbidden,
                    Detail = "Missing or invalid CSRF token. Fetch /api/v1/auth/csrf-token and send the token in the X-CSRF-TOKEN header.",
                };

                await ProblemResponses.WriteAsync(context.Response, problem);
                return;
            }
        }

        await next(context);
    }
}
