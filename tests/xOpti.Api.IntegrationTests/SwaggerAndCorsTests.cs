using System.Net;
using xOpti.Api.IntegrationTests.Support;

namespace xOpti.Api.IntegrationTests;

[Collection("api")]
public class SwaggerAndCorsTests(ApiPostgresFixture fixture)
{
    [Fact]
    public async Task SwaggerUi_IsServedAnonymously()
    {
        var client = new TestClient(new XOptiApiFactory(fixture));

        var redirect = await client.GetAsync("/swagger");
        redirect.EnsureSuccessStatusCode(); // 301 -> follows to the UI

        var index = await client.GetAsync("/swagger/index.html");
        Assert.Equal(HttpStatusCode.OK, index.StatusCode);
        Assert.Contains("swagger-ui", await index.Content.ReadAsStringAsync());
    }

    [Fact]
    public async Task Cors_IsClosedByDefault()
    {
        var client = new TestClient(new XOptiApiFactory(fixture));
        var request = new HttpRequestMessage(HttpMethod.Options, "/api/v1/branches");
        request.Headers.TryAddWithoutValidation("Origin", "http://localhost:5173");
        request.Headers.TryAddWithoutValidation("Access-Control-Request-Method", "GET");

        var response = await client.Http.SendAsync(request);

        Assert.False(response.Headers.Contains("Access-Control-Allow-Origin"));
    }

    [Fact]
    public async Task Cors_AllowsConfiguredOrigins_WithCredentialsAndProtocolHeaders()
    {
        var factory = new XOptiApiFactory(fixture, new Dictionary<string, string?>
        {
            ["XOptiApi:CorsAllowedOrigins:0"] = "http://localhost:5173",
        });
        var client = new TestClient(factory);

        var request = new HttpRequestMessage(HttpMethod.Options, "/api/v1/sales/holds");
        request.Headers.TryAddWithoutValidation("Origin", "http://localhost:5173");
        request.Headers.TryAddWithoutValidation("Access-Control-Request-Method", "POST");
        request.Headers.TryAddWithoutValidation("Access-Control-Request-Headers", "content-type,x-csrf-token,idempotency-key");

        var response = await client.Http.SendAsync(request);

        Assert.Equal(HttpStatusCode.NoContent, response.StatusCode);
        Assert.Equal("http://localhost:5173", response.Headers.GetValues("Access-Control-Allow-Origin").Single());
        Assert.Equal("true", response.Headers.GetValues("Access-Control-Allow-Credentials").Single());
        Assert.Contains("Idempotency-Key", response.Headers.GetValues("Access-Control-Allow-Headers").Single());
    }
}
