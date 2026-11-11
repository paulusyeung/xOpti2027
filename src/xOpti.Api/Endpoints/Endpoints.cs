using Microsoft.AspNetCore.Antiforgery;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Diagnostics.HealthChecks;
using Microsoft.AspNetCore.Diagnostics.HealthChecks;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using xOpti.Application.Authorization;
using xOpti.Application.Common;
using xOpti.Application.Identity.ListBranches;
using xOpti.Application.Identity.UpdateBranchName;
using xOpti.Application.Sales.HoldSale;
using xOpti.Api.Middleware;

namespace xOpti.Api.Endpoints;

public static class Endpoints
{
    public static void MapAuthEndpoints(this WebApplication app)
    {
        var auth = app.MapGroup("/api/v1/auth");

        auth.MapGet("/csrf-token", (IAntiforgery antiforgery, HttpContext http) =>
        {
            var tokens = antiforgery.GetAndStoreTokens(http);
            return Results.Ok(new { token = tokens.RequestToken });
        }).AllowAnonymous().ExcludeFromDescription();

        auth.MapPost("/sign-in", async (
            SignInRequest request,
            SignInManager<xOpti.Infrastructure.Identity.XoptiUser> signInManager,
            UserManager<xOpti.Infrastructure.Identity.XoptiUser> users) =>
        {
            var user = string.IsNullOrWhiteSpace(request.Username)
                ? null
                : await users.FindByNameAsync(request.Username!);

            // Uniform failure shape whether the user is missing, locked out,
            // or the password is wrong: never reveal account existence.
            if (user is null)
            {
                return InvalidCredentials();
            }

            if (user.ResetRequired)
            {
                return Results.Problem(new ProblemDetails
                {
                    Type = Problems.ResetRequired,
                    Title = "Password reset required",
                    Status = StatusCodes.Status403Forbidden,
                    Detail = "This account is not activated; complete the administrator-issued password reset first.",
                });
            }

            var result = await signInManager.PasswordSignInAsync(
                user, request.Password ?? string.Empty, isPersistent: false, lockoutOnFailure: true);

            if (result.Succeeded)
            {
                return Results.Ok(new { username = user.UserName, displayName = user.DisplayName });
            }

            return InvalidCredentials();
        }).AllowAnonymous();

        auth.MapPost("/sign-out", async (
            SignInManager<xOpti.Infrastructure.Identity.XoptiUser> signInManager) =>
        {
            await signInManager.SignOutAsync();
            return Results.NoContent();
        });

        static IResult InvalidCredentials() => Results.Problem(new ProblemDetails
        {
            Type = Problems.Unauthenticated,
            Title = "Invalid credentials",
            Status = StatusCodes.Status401Unauthorized,
            Detail = "The username or password is incorrect.",
        });
    }

    public static void MapXOptiApiVersioned(this WebApplication app)
    {
        var versionSet = app.NewApiVersionSet()
            .HasApiVersion(new Asp.Versioning.ApiVersion(1, 0))
            .ReportApiVersions()
            .Build();

        // Literal /api/v1 prefix so the OpenAPI contract carries stable paths;
        // the version set reports v1. New versions mount /api/v2 alongside.
        var v1 = app.MapGroup("/api/v1")
            .WithApiVersionSet(versionSet);

        v1.MapGet("/branches", async (
            string? cursor,
            int? pageSize,
            IRequestDispatcher dispatcher,
            CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(new ListBranchesQuery(cursor, pageSize ?? 20), cancellationToken);
            return Results.Json(result);
        });

        v1.MapPatch("/branches/{branchCode}", async (
            string branchCode,
            RenameBranchRequest request,
            IRequestDispatcher dispatcher,
            CancellationToken cancellationToken) =>
        {
            var result = await dispatcher.DispatchAsync(
                new UpdateBranchNameCommand(branchCode, request.Name, request.ExpectedCurrentName), cancellationToken);
            return Results.Json(result);
        });

        // Financial reference endpoint: idempotency key enforced by filter,
        // forwarded to the command; replay/conflict semantics live in the
        // Application pipeline.
        v1.MapPost("/sales/holds", async (
            HttpContext http,
            IRequestDispatcher dispatcher,
            CancellationToken cancellationToken) =>
        {
            var key = http.Request.Headers["Idempotency-Key"].FirstOrDefault();
            var result = await dispatcher.DispatchAsync(new HoldSaleCommand(key), cancellationToken);
            return Results.Json(result);
        })
        .RequireAuthorization($"perm:{PermissionNames.SalesInvoicePost}")
        .AddEndpointFilter<IdempotencyKeyFilter>();
    }

    public static void MapXOptiHealth(this WebApplication app)
    {
        app.MapHealthChecks("/api/health/live", new HealthCheckOptions
        {
            Predicate = registration => registration.Tags.Contains("live"),
            ResponseWriter = (http, report) => http.Response.WriteAsync(report.Status.ToString()),
        }).AllowAnonymous();

        app.MapHealthChecks("/api/health/ready", new HealthCheckOptions
        {
            Predicate = registration => registration.Tags.Contains("ready"),
            ResponseWriter = (http, report) => http.Response.WriteAsync(report.Status.ToString()),
        }).AllowAnonymous();
    }
}

public sealed record SignInRequest(string? Username, string? Password);

public sealed record RenameBranchRequest(string Name, string? ExpectedCurrentName = null);

/// <summary>Requires the Idempotency-Key header on financial endpoints.</summary>
public sealed class IdempotencyKeyFilter : IEndpointFilter
{
    public async ValueTask<object?> InvokeAsync(
        EndpointFilterInvocationContext context,
        EndpointFilterDelegate next)
    {
        var http = context.HttpContext;
        var key = http.Request.Headers["Idempotency-Key"].FirstOrDefault();

        if (string.IsNullOrWhiteSpace(key))
        {
            return Results.Problem(new ProblemDetails
            {
                Type = Problems.IdempotencyKeyRequired,
                Title = "Idempotency key required",
                Status = StatusCodes.Status400BadRequest,
                Detail = "This endpoint requires an Idempotency-Key header.",
            });
        }

        return await next(context);
    }
}
