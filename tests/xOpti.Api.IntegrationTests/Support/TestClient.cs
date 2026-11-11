using System.Text;
using Microsoft.AspNetCore.Mvc.Testing;
using System.Text.Json;

namespace xOpti.Api.IntegrationTests.Support;

/// <summary>
/// Thin HTTP helper for the cookie + CSRF flow: keeps session and antiforgery
/// cookies by hand so SameSite/HttpOnly attributes are observable.
/// </summary>
public sealed class TestClient : IDisposable
{
    public HttpClient Http { get; }

    private readonly Dictionary<string, string> _cookies = new(StringComparer.Ordinal);

    public string? CsrfToken { get; private set; }

    public TestClient(WebApplicationFactory<Program> factory)
    {
        Http = factory.CreateClient();
    }

    /// <summary>Attach X-Forwarded-Proto: https so the Secure cookie policy engages.</summary>
    public bool ForwardedHttps { get; set; }

    public bool HasSession => _cookies.ContainsKey("xopti.session");

    public async Task FetchCsrfTokenAsync()
    {
        var response = await Http.GetAsync("/api/v1/auth/csrf-token");
        response.EnsureSuccessStatusCode();
        StoreCookies(response);

        using var body = JsonDocument.Parse(await response.Content.ReadAsStringAsync());
        CsrfToken = body.RootElement.GetProperty("token").GetString();
    }

    public async Task<SignInOutcome> SignInAsync(string username, string password, bool withCsrf = true)
    {
        var request = new HttpRequestMessage(HttpMethod.Post, "/api/v1/auth/sign-in")
        {
            Content = new StringContent(
                JsonSerializer.Serialize(new { username, password }),
                Encoding.UTF8,
                "application/json"),
        };

        if (withCsrf && CsrfToken is not null)
        {
            request.Headers.Add("X-CSRF-TOKEN", CsrfToken);
        }

        ApplyCookies(request);
        var response = await Http.SendAsync(request);
        StoreCookies(response);

        var bodyText = await response.Content.ReadAsStringAsync();

        // Session cookie string captured from Set-Cookie before stripping it.
        string? rawSessionCookie = null;
        if (response.Headers.TryGetValues("Set-Cookie", out var setCookies))
        {
            rawSessionCookie = setCookies.FirstOrDefault(c => c.StartsWith("xopti.session=", StringComparison.Ordinal));
        }

        // ASP.NET rotates the antiforgery cookie when the identity changes;
        // a well-behaved SPA refetches its token after signing in.
        if (response.IsSuccessStatusCode)
        {
            await FetchCsrfTokenAsync();
        }

        return new SignInOutcome(response.StatusCode, bodyText, rawSessionCookie);
    }

    public async Task<HttpResponseMessage> GetAsync(string path)
    {
        var request = new HttpRequestMessage(HttpMethod.Get, path);
        ApplyCookies(request);
        return await Http.SendAsync(request);
    }

    public async Task<HttpResponseMessage> PostAsync(string path, object? body = null, string? idempotencyKey = null, string? csrf = null)
    {
        var request = new HttpRequestMessage(HttpMethod.Post, path);
        if (body is not null)
        {
            request.Content = new StringContent(JsonSerializer.Serialize(body), Encoding.UTF8, "application/json");
        }

        if (idempotencyKey is not null)
        {
            request.Headers.Add("Idempotency-Key", idempotencyKey);
        }

        var token = csrf ?? CsrfToken;
        if (token is not null)
        {
            request.Headers.Add("X-CSRF-TOKEN", token);
        }

        ApplyCookies(request);
        var response = await Http.SendAsync(request);
        StoreCookies(response);
        return response;
    }

    public async Task<HttpResponseMessage> PatchAsync(string path, object body)
    {
        var request = new HttpRequestMessage(HttpMethod.Patch, path)
        {
            Content = new StringContent(JsonSerializer.Serialize(body), Encoding.UTF8, "application/json"),
        };

        if (CsrfToken is not null)
        {
            request.Headers.Add("X-CSRF-TOKEN", CsrfToken);
        }

        ApplyCookies(request);
        var response = await Http.SendAsync(request);
        StoreCookies(response);
        return response;
    }

    public void ApplyCookies(HttpRequestMessage request)
    {
        if (ForwardedHttps)
        {
            request.Headers.TryAddWithoutValidation("X-Forwarded-Proto", "https");
        }

        if (_cookies.Count > 0)
        {
            request.Headers.TryAddWithoutValidation("Cookie", string.Join("; ", _cookies.Select(c => $"{c.Key}={c.Value}")));
        }
    }

    private void StoreCookies(HttpResponseMessage response)
    {
        if (!response.Headers.TryGetValues("Set-Cookie", out var setCookies))
        {
            return;
        }

        foreach (var cookie in setCookies)
        {
            var pair = cookie.Split(';')[0];
            var eq = pair.IndexOf('=');
            if (eq > 0)
            {
                _cookies[pair[..eq].Trim()] = pair[(eq + 1)..].Trim();
            }
        }
    }

    public void Dispose() => Http.Dispose();
}

public sealed record SignInOutcome(System.Net.HttpStatusCode Status, string Body, string? RawSessionCookie);
