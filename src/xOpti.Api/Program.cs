using System.Globalization;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.HttpOverrides;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.DependencyInjection;
using xOpti.Api;
using Asp.Versioning;
using xOpti.Api.Endpoints;
using xOpti.Api.Health;
using xOpti.Api.Middleware;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Diagnostics.HealthChecks;
using xOpti.Application;
using xOpti.Infrastructure;
using xOpti.Infrastructure.Identity;
using xOpti.Infrastructure.Jobs;

var builder = WebApplication.CreateBuilder(args);

// ---------------------------------------------------------------- options
var apiOptions = builder.Configuration.GetSection("XOptiApi").Get<ApiOptions>() ?? new ApiOptions();
var connectionString = builder.Configuration.GetConnectionString("XOptiDatabase") ?? apiOptions.ConnectionString;

// ---------------------------------------------------------------- services
builder.Services.AddXOptiInfrastructure(new InfrastructureOptions
{
    ConnectionString = connectionString,
    FileStorageRoot = apiOptions.FileStorageRoot,
    IdempotencyRetention = apiOptions.IdempotencyRetention,
    FontDirectories = apiOptions.FontDirectories,
    MaterializedViewRefreshStatements = apiOptions.MaterializedViewRefreshStatements,
});

// EF schema deployment runs ONLY as this one-shot job (docker compose run --rm api --migrate),
// never at API startup.
if (args.Contains("--migrate"))
{
    var runner = builder.Build();
    await SchemaMigrationJob.MigrateAsync(runner.Services);
    return 0;
}

builder.Services.AddXOptiApplication();
builder.Services.AddXOptiIdentity(
    lockoutMaxFailedAccessAttempts: 5,
    lockoutWindow: apiOptions.LockoutWindow,
    sessionIdleTimeout: apiOptions.SessionIdle);

builder.Services.AddHttpContextAccessor();
builder.Services.AddProblemDetails();

// Session-scoped authorization principal from the cookie identity.
builder.Services.AddScoped<xOpti.Application.Ports.ICurrentPrincipal>(sp =>
    new xOpti.Infrastructure.ClaimsCurrentPrincipal(
        sp.GetRequiredService<IHttpContextAccessor>().HttpContext?.User
        ?? new System.Security.Claims.ClaimsPrincipal()));

builder.Services
    .AddAuthentication(IdentityConstants.ApplicationScheme)
    .AddCookie(IdentityConstants.ApplicationScheme, options =>
    {
        options.SlidingExpiration = true;
        options.ExpireTimeSpan = apiOptions.SessionIdle;
        options.Cookie.Name = apiOptions.SessionCookieName;
        options.Cookie.HttpOnly = true;
        // SameAsRequest: Secure over TLS (Caddy/nginx) on the LAN deployment,
        // and usable over plain HTTP in TestServer integration tests.
        options.Cookie.SecurePolicy = CookieSecurePolicy.SameAsRequest;
        options.Cookie.SameSite = SameSiteMode.Strict;

        // API clients must never receive 302 HTML redirects from the
        // authentication handlers; return problem documents instead.
        options.Events = new CookieAuthenticationEvents
        {
            OnRedirectToLogin = context =>
            {
                var hasSessionCookie = context.Request.Cookies.ContainsKey(options.Cookie.Name!);

                var problem = new ProblemDetails
                {
                    Type = hasSessionCookie ? Problems.SessionExpired : Problems.Unauthenticated,
                    Title = hasSessionCookie ? "Session expired" : "Unauthorized",
                    Status = StatusCodes.Status401Unauthorized,
                    Detail = hasSessionCookie
                        ? "The session is no longer valid; sign in again."
                        : "Authentication is required for this endpoint.",
                };

                return ProblemResponses.WriteAsync(context.Response, problem);
            },
            OnRedirectToAccessDenied = context =>
            {
                var problem = new ProblemDetails
                {
                    Type = Problems.Authorization,
                    Title = "Forbidden",
                    Status = StatusCodes.Status403Forbidden,
                    Detail = "The session lacks the permissions required by this endpoint.",
                };

                return ProblemResponses.WriteAsync(context.Response, problem);
            },
            OnRedirectToLogout = context =>
            {
                context.Response.StatusCode = StatusCodes.Status200OK;
                return Task.CompletedTask;
            },
            OnRedirectToReturnUrl = context =>
            {
                context.Response.StatusCode = StatusCodes.Status200OK;
                return Task.CompletedTask;
            },
        };
    });

builder.Services.AddAuthorizationBuilder()
    .SetDefaultPolicy(new AuthorizationPolicyBuilder().RequireAuthenticatedUser().Build())
    .SetFallbackPolicy(new AuthorizationPolicyBuilder().RequireAuthenticatedUser().Build());

if (apiOptions.JobsEnabled)
{
    builder.Services.AddXOptiJobs(enabled: true);
}

builder.Services.Configure<Microsoft.AspNetCore.Authorization.AuthorizationOptions>(options =>
{
    foreach (var permission in xOpti.Application.Authorization.PermissionNames.All)
    {
        options.AddPolicy(
            $"perm:{permission}",
            policy => policy.RequireAuthenticatedUser()
                .RequireClaim(xOpti.Infrastructure.ClaimsCurrentPrincipal.PermissionClaimType, permission));
    }
});

builder.Services.AddCors(options =>
{
    if (apiOptions.CorsAllowedOrigins.Count > 0)
    {
        options.AddPolicy("spa", policy => policy
            .WithOrigins(apiOptions.CorsAllowedOrigins.ToArray())
            .AllowCredentials()
            .WithMethods("GET", "POST", "PATCH", "PUT", "DELETE", "OPTIONS")
            .WithHeaders("Content-Type", "X-CSRF-TOKEN", "Idempotency-Key", "x-correlation-id")
            .WithExposedHeaders("x-correlation-id"));
    }
});

builder.Services.AddAntiforgery(options =>
{
    options.HeaderName = CsrfMiddleware.HeaderName;
    options.Cookie.Name = "xopti.csrf";
    options.Cookie.HttpOnly = true;
    options.Cookie.SameSite = SameSiteMode.Strict;
    options.Cookie.SecurePolicy = CookieSecurePolicy.SameAsRequest;
});

builder.Services.AddApiVersioning(options =>
{
    options.DefaultApiVersion = new ApiVersion(1, 0);
    options.AssumeDefaultVersionWhenUnspecified = true;
    options.ApiVersionReader = new UrlSegmentApiVersionReader();
});

builder.Services.AddOpenApi();

builder.Services.AddHealthChecks()
    .AddCheck<XOptiDbHealthCheck>("database", tags: new[] { "ready" })
    .AddCheck<FileVolumeHealthCheck>("file-volume", tags: new[] { "ready" })
    .AddCheck("self", () => Microsoft.Extensions.Diagnostics.HealthChecks.HealthCheckResult.Healthy(), tags: new[] { "live" });

builder.Services.AddRequestLocalization(options =>
{
    var enCa = new CultureInfo("en-CA");
    options.DefaultRequestCulture = new Microsoft.AspNetCore.Localization.RequestCulture(enCa);
    options.SupportedCultures = new[] { enCa };
    options.SupportedUICultures = new[] { enCa };
});

builder.Services.Configure<ForwardedHeadersOptions>(options =>
{
    options.ForwardedHeaders = ForwardedHeaders.XForwardedFor | ForwardedHeaders.XForwardedProto;
    options.KnownNetworks.Clear();
    options.KnownProxies.Clear();
});

var app = builder.Build();

// ---------------------------------------------------------------- pipeline
app.UseForwardedHeaders();
app.UseRequestLocalization();
if (apiOptions.CorsAllowedOrigins.Count > 0)
{
    app.UseCors("spa");
}

// Interactive API browser (anonymous); reads the built-in OpenAPI document.
app.UseSwaggerUI(options =>
{
    options.DocumentTitle = "xOpti API";
    options.SwaggerEndpoint("/openapi/v1.json", "xOpti v1");
    options.RoutePrefix = "swagger";
});
app.UseMiddleware<CorrelationIdMiddleware>();
app.UseMiddleware<XOptiExceptionMapper>();
app.UseAuthentication();
app.UseMiddleware<CsrfMiddleware>();
app.UseAuthorization();

// ---------------------------------------------------------------- endpoints
app.MapAuthEndpoints();
app.MapXOptiApiVersioned();
app.MapXOptiHealth();
app.MapOpenApi().AllowAnonymous();

// Unknown routes get a 404 problem document, never a fallback page.
app.MapFallback(async httpContext =>
{
    var problem = new ProblemDetails
    {
        Type = Problems.NotFound,
        Title = "Not found",
        Status = StatusCodes.Status404NotFound,
        Detail = $"No route matches {httpContext.Request.Method} {httpContext.Request.Path}.",
    };

    await ProblemResponses.WriteAsync(httpContext.Response, problem);
}).AllowAnonymous();

if (apiOptions.FaultInjectionEnabled)
{
    // Test-only fault injection gate (disabled by default in every environment).
    app.Map("/api/v1/_internal/fault", (HttpContext http) =>
    {
        throw new InvalidOperationException("injected fault (test only)");
    }).AllowAnonymous();
}

app.Run();

return 0;

public partial class Program
{
}
