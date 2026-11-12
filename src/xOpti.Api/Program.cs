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
using xOpti.Infrastructure.Bootstrap;
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

builder.Services.AddSingleton<SchemaReadinessProbe>();

builder.Services.AddHealthChecks()
    .AddCheck<XOptiDbHealthCheck>("database", tags: new[] { "ready" })
    .AddCheck<SchemaBaselineHealthCheck>("schema-baseline", tags: new[] { "ready" })
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

// Fresh-database bootstrap: script + app-owned migrations + reference seed,
// recorded in platform.schema_baseline. Runs as a one-shot deployment command.
if (args.Contains("--bootstrap"))
{
    var schemaFile = SchemaScript.ResolvePath(
        builder.Configuration["XOptiApi:SchemaFile"], builder.Environment.ContentRootPath);
    if (schemaFile is null)
    {
        Console.Error.WriteLine(
            "xopti-schema.sql was not found. Set XOptiApi:SchemaFile to the deployed schema file.");
        return 1;
    }

    var runner = builder.Build();
    try
    {
        var result = await SchemaBootstrap.RunAsync(runner.Services, new SchemaBootstrapOptions
        {
            ConnectionString = connectionString,
            SchemaFilePath = schemaFile,
            Version = SchemaScript.BaselineVersion,
            ExpectedChecksum = SchemaScript.ComputeChecksum(schemaFile),
            AppliedBy = "xopti-api --bootstrap",
        });

        Console.WriteLine(
            result.Outcome == SchemaBootstrapOutcome.Bootstrapped
                ? $"Bootstrapped schema baseline {result.Version} ({result.Checksum[..12]})."
                : $"Schema baseline {result.Version} already current ({result.Checksum[..12]}); nothing to do.");
        return 0;
    }
    catch (Exception exception) when (exception is SchemaBaselineMismatchException or SchemaBootstrapException)
    {
        Console.Error.WriteLine(exception.Message);
        return 1;
    }
}

// Smoke/E2E seed: demo branches and accounts. Refuses unless explicitly allowed.
if (args.Contains("--seed-smoke"))
{
    if (Environment.GetEnvironmentVariable("XOPTI_ALLOW_SMOKE_SEED") != "1")
    {
        Console.Error.WriteLine(
            "Refusing to seed smoke accounts. Set XOPTI_ALLOW_SMOKE_SEED=1 for a disposable smoke database.");
        return 1;
    }

    var runner = builder.Build();
    var smokePassword = Environment.GetEnvironmentVariable("XOPTI_SMOKE_PASSWORD") ?? SmokeSeed.DefaultPassword;
    await SmokeSeed.ApplyAsync(runner.Services, smokePassword);
    Console.WriteLine("Seeded smoke branches and accounts.");
    return 0;
}

// CI schema-drift gate: compare a bootstrapped database with the canonical script.
if (args.Contains("--schema-drift"))
{
    var schemaFile = SchemaScript.ResolvePath(
        builder.Configuration["XOptiApi:SchemaFile"], builder.Environment.ContentRootPath);
    if (schemaFile is null)
    {
        Console.Error.WriteLine(
            "xopti-schema.sql was not found. Set XOptiApi:SchemaFile to the deployed schema file.");
        return 1;
    }

    var differences = await SchemaDrift.CompareAsync(connectionString, schemaFile);
    if (differences.Count == 0)
    {
        Console.WriteLine("No schema drift: the database matches xopti-schema.sql.");
        return 0;
    }

    foreach (var difference in differences)
    {
        Console.Error.WriteLine("  " + difference);
    }

    Console.Error.WriteLine($"{differences.Count} schema difference(s) between the database and xopti-schema.sql.");
    return 1;
}

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
app.UseMiddleware<SchemaGateMiddleware>();
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
