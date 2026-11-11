using Microsoft.AspNetCore.Mvc;
using xOpti.Application.Pipeline;

namespace xOpti.Api.Middleware;

/// <summary>
/// Maps application/pipeline exceptions to uniform problem documents and
/// converts unexpected faults into 500s carrying only the correlation id.
/// </summary>
public sealed class XOptiExceptionMapper(RequestDelegate next, ILogger<XOptiExceptionMapper> logger)
{
    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await next(context);
        }
        catch (Exception exception)
        {
            await WriteAsync(context, exception);
        }
    }

    private async Task WriteAsync(HttpContext context, Exception exception)
    {
        var (status, type, title, detail, extensions) = Map(exception);

        if (status >= 500)
        {
            logger.LogError(exception, "Unhandled fault while handling {Method} {Path}", context.Request.Method, context.Request.Path);
        }

        var problem = new ProblemDetails
        {
            Type = type,
            Title = title,
            Status = status,
            Detail = detail,
        };

        foreach (var (key, value) in extensions)
        {
            problem.Extensions[key] = value;
        }

        await ProblemResponses.WriteAsync(context.Response, problem);
    }

    private static (int, string, string, string, Dictionary<string, object?>) Map(Exception exception) => exception switch
    {
        ValidationFailedException validation => (
            StatusCodes.Status400BadRequest,
            Problems.Validation,
            "Validation failed",
            "One or more request fields are invalid.",
            new Dictionary<string, object?>
            {
                ["errors"] = validation.Errors
                    .Select(e => new { field = e.Field, code = e.Code, message = e.Message })
                    .ToList(),
            }),

        AuthorizationFailedException authorization => (
            StatusCodes.Status403Forbidden,
            Problems.Authorization,
            "Forbidden",
            $"Missing permission '{authorization.Permission}'.",
            new Dictionary<string, object?>()),

        Microsoft.EntityFrameworkCore.DbUpdateConcurrencyException => (
            StatusCodes.Status409Conflict,
            Problems.ConcurrencyConflict,
            "Concurrency conflict",
            "The record changed since it was loaded. Reload and retry.",
            new Dictionary<string, object?>()),

        IdempotencyConflictException conflict => (
            StatusCodes.Status409Conflict,
            Problems.IdempotencyConflict,
            "Idempotency conflict",
            "A request with this idempotency key is already in progress.",
            new Dictionary<string, object?>
            {
                ["idempotencyKey"] = conflict.Key,
            }),

        UnsupportedRequestException => (
            StatusCodes.Status400BadRequest,
            Problems.UnsupportedRequest,
            "Unsupported request",
            "No handler is registered for this request.",
            new Dictionary<string, object?>()),

        xOpti.Application.Common.DomainRuleException rule => (
            StatusCodes.Status422UnprocessableEntity,
            Problems.DomainRule,
            "Domain rule rejected",
            rule.Message,
            new Dictionary<string, object?>()),

        _ => (
            StatusCodes.Status500InternalServerError,
            Problems.Unhandled,
            "Internal server error",
            "An unexpected error occurred. Use the correlation id to locate the server log entry.",
            new Dictionary<string, object?>()),
    };
}
