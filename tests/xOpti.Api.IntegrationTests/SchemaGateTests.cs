using System.Net;
using System.Text.Json;
using xOpti.Api.IntegrationTests.Support;

namespace xOpti.Api.IntegrationTests;

[Collection("api")]
public sealed class SchemaGateTests(ApiPostgresFixture fixture)
{
    [Fact]
    public async Task EmptyDatabase_IsUnready_AndBusinessEndpointsReturnServiceUnavailable()
    {
        var connectionString = await fixture.CreateEmptyDatabaseAsync();
        await using var factory = new XOptiApiFactory(fixture, new Dictionary<string, string?>
        {
            ["ConnectionStrings:XOptiDatabase"] = connectionString,
        });
        using var client = factory.CreateClient();

        // Liveness stays up so orchestrators can distinguish a broken schema from
        // a dead process.
        var live = await client.GetAsync("/api/health/live");
        Assert.Equal(HttpStatusCode.OK, live.StatusCode);

        var ready = await client.GetAsync("/api/health/ready");
        Assert.Equal(HttpStatusCode.ServiceUnavailable, ready.StatusCode);
        Assert.Contains("Unhealthy", await ready.Content.ReadAsStringAsync(), StringComparison.Ordinal);

        var business = await client.GetAsync("/api/v1/branches");
        Assert.Equal(HttpStatusCode.ServiceUnavailable, business.StatusCode);
        Assert.NotNull(business.Headers.RetryAfter);

        using var problem = JsonDocument.Parse(await business.Content.ReadAsStringAsync());
        Assert.Equal("https://errors.xopti/service-unavailable", problem.RootElement.GetProperty("type").GetString());
        Assert.Equal("Service unavailable", problem.RootElement.GetProperty("title").GetString());
        Assert.Contains("bootstrap", problem.RootElement.GetProperty("detail").GetString(), StringComparison.OrdinalIgnoreCase);
    }

    [Fact]
    public async Task BootstrappedDatabase_PassesTheGate_AndHealthIsReady()
    {
        var connectionString = await fixture.CreateEmptyDatabaseAsync();
        await SchemaBootstrapTestHelper.BootstrapAsync(connectionString);

        await using var factory = new XOptiApiFactory(fixture, new Dictionary<string, string?>
        {
            ["ConnectionStrings:XOptiDatabase"] = connectionString,
        });
        using var client = factory.CreateClient();

        var ready = await client.GetAsync("/api/health/ready");
        Assert.Equal(HttpStatusCode.OK, ready.StatusCode);

        // Anonymous request reaches authentication (401) instead of the schema gate.
        var business = await client.GetAsync("/api/v1/branches");
        Assert.Equal(HttpStatusCode.Unauthorized, business.StatusCode);
    }
}
