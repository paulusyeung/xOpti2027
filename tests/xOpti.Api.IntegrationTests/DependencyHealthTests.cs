using System.Net;
using xOpti.Api.IntegrationTests.Support;

namespace xOpti.Api.IntegrationTests;

[Collection("api")]
public sealed class DependencyHealthTests(ApiPostgresFixture fixture)
{
    [Fact]
    public async Task UnreachableDatabase_MarksReadinessUnhealthy_ButLivenessHealthy()
    {
        await using var factory = new XOptiApiFactory(fixture, new Dictionary<string, string?>
        {
            // Nothing listens on port 1; the probe fails fast instead of hanging.
            ["ConnectionStrings:XOptiDatabase"] = "Host=127.0.0.1;Port=1;Database=xopti;Username=postgres;Password=x;Timeout=2",
        });
        using var client = factory.CreateClient();

        var live = await client.GetAsync("/api/health/live");
        Assert.Equal(HttpStatusCode.OK, live.StatusCode);

        var ready = await client.GetAsync("/api/health/ready");
        Assert.Equal(HttpStatusCode.ServiceUnavailable, ready.StatusCode);
        Assert.Contains("Unhealthy", await ready.Content.ReadAsStringAsync(), StringComparison.Ordinal);
    }

    [Fact]
    public async Task UnwritableFileVolume_MarksReadinessUnhealthy_ButLivenessHealthy()
    {
        // Use a regular file as the storage root: Directory.CreateDirectory fails.
        var blocker = Path.Combine(Path.GetTempPath(), "xopti-not-a-directory-" + Guid.NewGuid().ToString("N")[..8]);
        await File.WriteAllTextAsync(blocker, "probe");
        try
        {
            await using var factory = new XOptiApiFactory(fixture, new Dictionary<string, string?>
            {
                ["XOptiApi:FileStorageRoot"] = Path.Combine(blocker, "files"),
            });
            using var client = factory.CreateClient();

            var live = await client.GetAsync("/api/health/live");
            Assert.Equal(HttpStatusCode.OK, live.StatusCode);

            var ready = await client.GetAsync("/api/health/ready");
            Assert.Equal(HttpStatusCode.ServiceUnavailable, ready.StatusCode);
            Assert.Equal("Unhealthy", await ready.Content.ReadAsStringAsync());
        }
        finally
        {
            File.Delete(blocker);
        }
    }
}
