using System.Net;
using System.Text.Json;
using Microsoft.AspNetCore.Mvc.Testing;
using xOpti.Api.IntegrationTests.Support;

namespace xOpti.Api.IntegrationTests;

[CollectionDefinition("api")]
public class ApiCollection : ICollectionFixture<ApiPostgresFixture>
{
}

[Collection("api")]
public sealed class AuthAndSessionTests(ApiPostgresFixture _fixture)
{

    private async Task<TestClient> SignInAsync(string user = "manager")
    {
        var factory = new XOptiApiFactory(_fixture);
        var client = new TestClient(factory);
        await client.FetchCsrfTokenAsync();
        var outcome = await client.SignInAsync(user, "Test#Passw0rd1!");
        Assert.Equal(HttpStatusCode.OK, outcome.Status);
        return client;
    }

    [Fact]
    public async Task SignIn_EstablishesHttpOnlyStrictCookie_And_AuthenticatedGetSucceeds()
    {
        var factory = new XOptiApiFactory(_fixture);
        var client = new TestClient(factory);
        await client.FetchCsrfTokenAsync();

        var outcome = await client.SignInAsync("manager", "Test#Passw0rd1!");

        Assert.Equal(HttpStatusCode.OK, outcome.Status);
        Assert.NotNull(outcome.RawSessionCookie);
        Assert.Contains("httponly", outcome.RawSessionCookie, StringComparison.OrdinalIgnoreCase);
        Assert.Contains("samesite=strict", outcome.RawSessionCookie, StringComparison.OrdinalIgnoreCase);

        // Subsequent authenticated call succeeds with the session cookie.
        var branches = await client.GetAsync("/api/v1/branches");
        Assert.Equal(HttpStatusCode.OK, branches.StatusCode);

        // No secret material in the sign-in body.
        Assert.DoesNotContain("xopti.session", outcome.Body);
        Assert.DoesNotContain("Test#Passw0rd1!", outcome.Body);
    }

    [Fact]
    public async Task SecureAttribute_IsSet_WhenRequestIsHttps()
    {
        var factory = new XOptiApiFactory(_fixture);
        var client = new TestClient(factory) { ForwardedHttps = true };
        await client.FetchCsrfTokenAsync();

        var outcome = await client.SignInAsync("manager", "Test#Passw0rd1!");

        Assert.NotNull(outcome.RawSessionCookie);
        Assert.Contains("secure", outcome.RawSessionCookie!, StringComparison.OrdinalIgnoreCase);
    }

    [Fact]
    public async Task Unauthenticated_ProtectedRoute_Returns401Problem_NotRedirect()
    {
        var factory = new XOptiApiFactory(_fixture);
        var client = new TestClient(factory);

        var response = await client.GetAsync("/api/v1/branches");

        Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
        Assert.Equal("application/problem+json", response.Content.Headers.ContentType?.MediaType);
        Assert.Null(response.Headers.Location);

        var body = await response.Content.ReadAsStringAsync();
        using var doc = JsonDocument.Parse(body);
        Assert.Equal("https://errors.xopti/unauthenticated", doc.RootElement.GetProperty("type").GetString());
    }

    [Fact]
    public async Task ExpiredSession_ReturnsSessionExpiredProblem()
    {
        var factory = new XOptiApiFactory(_fixture, new Dictionary<string, string?>
        {
            ["XOptiApi:SessionIdle"] = "00:00:02",
        });
        var client = new TestClient(factory);
        await client.FetchCsrfTokenAsync();
        Assert.Equal(HttpStatusCode.OK, (await client.SignInAsync("manager", "Test#Passw0rd1!")).Status);

        await Task.Delay(TimeSpan.FromSeconds(3));

        var response = await client.GetAsync("/api/v1/branches");

        Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
        using var doc = JsonDocument.Parse(await response.Content.ReadAsStringAsync());
        Assert.Equal("https://errors.xopti/session-expired", doc.RootElement.GetProperty("type").GetString());
    }

    [Fact]
    public async Task UnknownUser_And_WrongPassword_ProduceIdenticalFailureShapes()
    {
        var factory = new XOptiApiFactory(_fixture);
        var client = new TestClient(factory);
        await client.FetchCsrfTokenAsync();

        var unknown = await client.SignInAsync("no-such-user-xyz", "whatever123");
        var wrong = await client.SignInAsync("manager", "wrong-password-123");

        Assert.Equal(unknown.Status, wrong.Status);
        Assert.Equal(HttpStatusCode.Unauthorized, wrong.Status);

        // The failure payloads must be identical apart from the correlation id.
        static string Normalize(string body)
        {
            using var doc = JsonDocument.Parse(body);
            var clone = new Dictionary<string, object?>();
            foreach (var prop in doc.RootElement.EnumerateObject())
            {
                if (prop.Name is "correlationId" or "traceId")
                {
                    continue;
                }

                clone[prop.Name] = prop.Value.GetRawText();
            }

            return string.Join(',', clone.OrderBy(k => k.Key).Select(k => $"{k.Key}:{k.Value}"));
        }

        Assert.Equal(Normalize(unknown.Body), Normalize(wrong.Body));
    }

    [Fact]
    public async Task RepeatedFailures_LockAccount_WithoutDisclosingMore()
    {
        var factory = new XOptiApiFactory(_fixture);
        var client = new TestClient(factory);
        await client.FetchCsrfTokenAsync();

        HttpStatusCode last = default;
        for (var i = 0; i < 6; i++)
        {
            var attempt = await client.SignInAsync("locked-target", "wrong-password-123");
            last = attempt.Status;
            Assert.Equal(HttpStatusCode.Unauthorized, attempt.Status);
        }

        // Locked out: the correct password now gets the same failure shape.
        var afterLockout = await client.SignInAsync("locked-target", "Test#Passw0rd1!");
        Assert.Equal(last, afterLockout.Status);
        Assert.Equal(HttpStatusCode.Unauthorized, afterLockout.Status);
    }
}
