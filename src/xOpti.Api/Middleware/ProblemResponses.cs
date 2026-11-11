using System.Text.Json;
using Microsoft.AspNetCore.Mvc;

namespace xOpti.Api.Middleware;

/// <summary>
/// Writes problem documents with the `application/problem+json` media type
/// (JsonTextWriter would otherwise reset it to application/json).
/// </summary>
public static class ProblemResponses
{
    public static async Task WriteAsync(HttpResponse response, ProblemDetails problem)
    {
        if (response.HttpContext.Items.TryGetValue(CorrelationIdMiddleware.ItemKey, out var value)
            && value is string correlationId)
        {
            problem.Extensions["correlationId"] = correlationId;
        }

        response.Clear();
        response.StatusCode = problem.Status ?? StatusCodes.Status500InternalServerError;
        response.ContentType = "application/problem+json";
        await response.WriteAsync(
            JsonSerializer.Serialize(problem, new JsonSerializerOptions(JsonSerializerDefaults.Web)));
    }

    public static Task WriteAsync(
        HttpResponse response,
        int status,
        string type,
        string title,
        string detail) =>
        WriteAsync(response, new ProblemDetails
        {
            Type = type,
            Title = title,
            Status = status,
            Detail = detail,
        });
}
