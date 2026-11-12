using System.Net;
using xOpti.Api.IntegrationTests.Support;
using xOpti.Api.Logging;

namespace xOpti.Api.IntegrationTests;

[Collection("api")]
public sealed class LoggingAndRedactionTests(ApiPostgresFixture fixture)
{
    [Fact]
    public void PiiRedaction_MasksEmailSinPhoneAndCardNumbers()
    {
        var redacted = PiiRedaction.Redact(
            "card 4111 1111 1111 1111, sin 123-456-789, mail jane@example.com, phone 604-555-1212");

        Assert.DoesNotContain("4111", redacted);
        Assert.DoesNotContain("123-456-789", redacted);
        Assert.DoesNotContain("jane@example.com", redacted);
        Assert.DoesNotContain("604-555-1212", redacted);
        Assert.Contains(PiiRedaction.Mask, redacted);
    }

    [Fact]
    public async Task FailedSignIn_AndFailedPayment_AreCorrelatedAndRedacted()
    {
        await using var factory = new XOptiApiFactory(fixture);
        using var client = new TestClient(factory);
        await client.FetchCsrfTokenAsync();

        const string wrongPassword = "WrongPassword!1";
        var signIn = await client.PostAsync(
            "/api/v1/auth/sign-in", new { username = "manager", password = wrongPassword });
        Assert.Equal(HttpStatusCode.Unauthorized, signIn.StatusCode);

        var signInCorrelation = CorrelationOf(signIn);
        var signInLog = factory.Logs.Snapshot().FirstOrDefault(entry =>
            entry.CorrelationId == signInCorrelation && entry.Message.Contains("/api/v1/auth/sign-in"));
        Assert.NotNull(signInLog);
        Assert.Contains("401", signInLog!.Message);

        // A financial endpoint without its idempotency key fails without a body.
        var signedIn = await client.SignInAsync("manager", SeedData.Password);
        Assert.Equal(HttpStatusCode.OK, signedIn.Status);

        var payment = await client.PostAsync("/api/v1/sales/holds");
        Assert.Equal(HttpStatusCode.BadRequest, payment.StatusCode);

        var paymentCorrelation = CorrelationOf(payment);
        var paymentLog = factory.Logs.Snapshot().FirstOrDefault(entry =>
            entry.CorrelationId == paymentCorrelation && entry.Message.Contains("/api/v1/sales/holds"));
        Assert.NotNull(paymentLog);
        Assert.Contains("400", paymentLog!.Message);

        var messages = string.Join("\n", factory.Logs.Snapshot().Select(entry => entry.Message));
        Assert.DoesNotContain(wrongPassword, messages);
        Assert.DoesNotContain(SeedData.Password, messages);
        Assert.DoesNotContain("4111 1111 1111 1111", messages);
        Assert.DoesNotContain("123-456-789", messages);
    }

    private static string CorrelationOf(HttpResponseMessage response) =>
        response.Headers.TryGetValues("x-correlation-id", out var values)
            ? values.Single()
            : throw new Xunit.Sdk.XunitException("response has no x-correlation-id header");
}
