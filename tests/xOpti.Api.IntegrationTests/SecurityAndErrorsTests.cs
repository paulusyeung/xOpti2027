using System.Net;
using System.Text.Json;
using xOpti.Api.IntegrationTests.Support;
using Microsoft.Extensions.DependencyInjection;
using xOpti.Infrastructure;
using xOpti.Infrastructure.Persistence;
using xOpti.Infrastructure.Persistence.Entities;

namespace xOpti.Api.IntegrationTests;

[Collection("api")]
public class SecurityAndErrorsTests(ApiPostgresFixture fixture)
{
    private XOptiApiFactory Factory => new(fixture);

    private async Task<TestClient> SignedInAsync(string user = "manager")
    {
        var client = new TestClient(Factory);
        await client.FetchCsrfTokenAsync();
        Assert.Equal(HttpStatusCode.OK, (await client.SignInAsync(user, "Test#Passw0rd1!")).Status);
        return client;
    }

    // ---- task 2.2: CSRF ----

    [Fact]
    public async Task UnsafeRequest_WithoutCsrfToken_IsRejected()
    {
        var client = new TestClient(Factory);
        await client.FetchCsrfTokenAsync();

        var response = await client.PostAsync("/api/v1/auth/sign-in",
            new { username = "manager", password = "Test#Passw0rd1!" }, csrf: string.Empty);

        Assert.Equal(HttpStatusCode.Forbidden, response.StatusCode);
        Assert.Equal("application/problem+json", response.Content.Headers.ContentType?.MediaType);
        Assert.False(client.HasSession);
    }

    [Fact]
    public async Task UnsafeRequest_WithCsrfToken_Succeeds()
    {
        var client = await SignedInAsync();
        Assert.True(client.HasSession);
    }

    [Fact]
    public async Task Authenticated_UnsafeRequest_NoCsrfHeader_IsRejected_AfterSession()
    {
        var client = await SignedInAsync();

        var response = await client.PostAsync("/api/v1/auth/sign-out", body: null, csrf: string.Empty);
        Assert.Equal(HttpStatusCode.Forbidden, response.StatusCode);
    }

    // ---- task 2.4: permission policies ----

    [Fact]
    public async Task ClerkSession_SalesHoldIsDenied_AndConsumesNoControlNumber()
    {
        var before = fixture.PrefCounter("RC");
        var client = await SignedInAsync("clerk");

        var response = await client.PostAsync("/api/v1/sales/holds", body: null, idempotencyKey: "denied-1");

        Assert.Equal(HttpStatusCode.Forbidden, response.StatusCode);
        using var doc = JsonDocument.Parse(await response.Content.ReadAsStringAsync());
        Assert.Equal("https://errors.xopti/authorization", doc.RootElement.GetProperty("type").GetString());
        Assert.Equal(before, fixture.PrefCounter("RC"));
    }

    [Fact]
    public async Task Unauthenticated_SalesHoldIsDenied()
    {
        var client = new TestClient(Factory);
        await client.FetchCsrfTokenAsync();

        // CSRF present, session absent -> cookie challenge -> 401 problem.
        var response = await client.PostAsync("/api/v1/sales/holds", body: null, idempotencyKey: "anon-1");

        Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
        using var doc = JsonDocument.Parse(await response.Content.ReadAsStringAsync());
        Assert.Equal("https://errors.xopti/unauthenticated", doc.RootElement.GetProperty("type").GetString());
    }

    // ---- task 3.1: error contract shapes ----

    [Fact]
    public async Task ValidationFailure_HasFieldErrors()
    {
        var client = await SignedInAsync("clerk");

        var response = await client.GetAsync("/api/v1/branches?pageSize=0");

        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
        var body = await response.Content.ReadAsStringAsync();
        using var doc = JsonDocument.Parse(body);
        Assert.Equal("https://errors.xopti/validation", doc.RootElement.GetProperty("type").GetString());
        var errors = doc.RootElement.GetProperty("errors");
        Assert.Equal("PageSize", errors[0].GetProperty("field").GetString());
    }

    [Fact]
    public async Task ConcurrencyConflict_Returns409Problem()
    {
        var client = await SignedInAsync("manager");

        var first = await client.PatchAsync("/api/v1/branches/03",
            new { name = "Renamed Once", expectedCurrentName = "Branch 3" });
        Assert.Equal(HttpStatusCode.OK, first.StatusCode);

        // Second patch still asserting the ORIGINAL name: lost update.
        var second = await client.PatchAsync("/api/v1/branches/03",
            new { name = "Renamed Twice", expectedCurrentName = "Branch 3" });

        Assert.Equal(HttpStatusCode.Conflict, second.StatusCode);
        using var doc = JsonDocument.Parse(await second.Content.ReadAsStringAsync());
        Assert.Equal("https://errors.xopti/concurrency-conflict", doc.RootElement.GetProperty("type").GetString());
    }

    [Fact]
    public async Task UnknownRoute_Returns404Problem()
    {
        var client = await SignedInAsync("clerk");

        var response = await client.GetAsync("/api/v1/nothing-here");

        Assert.Equal(HttpStatusCode.NotFound, response.StatusCode);
        Assert.Equal("application/problem+json", response.Content.Headers.ContentType?.MediaType);
        using var doc = JsonDocument.Parse(await response.Content.ReadAsStringAsync());
        Assert.Equal("https://errors.xopti/not-found", doc.RootElement.GetProperty("type").GetString());
    }

    // ---- task 3.2: unhandled fault + correlation id ----

    [Fact]
    public async Task InjectedFault_Returns500_WithCorrelationIdOnly()
    {
        var factory = new XOptiApiFactory(fixture, new Dictionary<string, string?>
        {
            ["XOptiApi:FaultInjectionEnabled"] = "true",
        });
        var client = new TestClient(factory);

        var response = await client.GetAsync("/api/v1/_internal/fault");

        Assert.Equal(HttpStatusCode.InternalServerError, response.StatusCode);
        var body = await response.Content.ReadAsStringAsync();
        using var doc = JsonDocument.Parse(body);
        Assert.Equal("https://errors.xopti/unhandled", doc.RootElement.GetProperty("type").GetString());
        Assert.NotEqual(string.Empty, doc.RootElement.GetProperty("correlationId").GetString());

        // Nothing internal is leaked.
        Assert.DoesNotContain("injected fault", body);
        Assert.DoesNotContain("InvalidOperationException", body);
        Assert.DoesNotContain("stack", body, StringComparison.OrdinalIgnoreCase);
    }

    // ---- task 3.3: idempotency on financial endpoints ----

    [Fact]
    public async Task MissingIdempotencyKey_IsRejected_BeforePosting()
    {
        var client = await SignedInAsync("manager");
        var before = fixture.PrefCounter("RC");

        var response = await client.PostAsync("/api/v1/sales/holds", body: null);

        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
        using var doc = JsonDocument.Parse(await response.Content.ReadAsStringAsync());
        Assert.Equal("https://errors.xopti/idempotency-key-required", doc.RootElement.GetProperty("type").GetString());
        Assert.Equal(before, fixture.PrefCounter("RC"));
    }

    [Fact]
    public async Task ReplayOfSameKey_ReturnsFirstResult_PostingOnce()
    {
        var client = await SignedInAsync("manager");
        var before = fixture.PrefCounter("RC");
        var key = Guid.NewGuid().ToString("N");

        var first = await client.PostAsync("/api/v1/sales/holds", body: null, idempotencyKey: key);
        var replay = await client.PostAsync("/api/v1/sales/holds", body: null, idempotencyKey: key);

        Assert.Equal(HttpStatusCode.OK, first.StatusCode);
        Assert.Equal(HttpStatusCode.OK, replay.StatusCode);
        Assert.Equal(await first.Content.ReadAsStringAsync(), await replay.Content.ReadAsStringAsync());

        Assert.Equal(before + 1, fixture.PrefCounter("RC"));

        using var doc = JsonDocument.Parse(await replay.Content.ReadAsStringAsync());
        Assert.StartsWith("RC", doc.RootElement.GetProperty("controlNumber").GetString());
    }

    [Fact]
    public async Task ConcurrentSameKey_NeverDoublePosts()
    {
        var client = await SignedInAsync("manager");
        var before = fixture.PrefCounter("RC");
        var key = Guid.NewGuid().ToString("N");

        var responses = await Task.WhenAll(Enumerable.Range(0, 20).Select(async _ =>
            await client.PostAsync("/api/v1/sales/holds", body: null, idempotencyKey: key)));

        foreach (var r in responses)
        {
            Assert.True(r.StatusCode is HttpStatusCode.OK or HttpStatusCode.Conflict,
                $"unexpected status {r.StatusCode}");
        }

        Assert.Equal(before + 1, fixture.PrefCounter("RC"));

        var conflicts = responses.Where(r => r.StatusCode == HttpStatusCode.Conflict).ToList();
        if (conflicts.Count > 0)
        {
            using var doc = JsonDocument.Parse(await conflicts[0].Content.ReadAsStringAsync());
            Assert.Equal("https://errors.xopti/idempotency-conflict", doc.RootElement.GetProperty("type").GetString());
        }
    }

    [Fact]
    public async Task InFlightLease_ConcurrentRequestGets409()
    {
        var key = "inflight-" + Guid.NewGuid().ToString("N");
        await using (var ctx = fixture.NewContext())
        {
            ctx.IdempotencyRecords.Add(new IdempotencyRecord
            {
                Key = key,
                Status = "in-progress",
                CreatedAt = DateTimeOffset.UtcNow,
                ExpiresAt = DateTimeOffset.UtcNow.AddMinutes(5),
            });
            await ctx.SaveChangesAsync();
        }

        var client = await SignedInAsync("manager");
        var response = await client.PostAsync("/api/v1/sales/holds", body: null, idempotencyKey: key);

        Assert.Equal(HttpStatusCode.Conflict, response.StatusCode);
        using var doc = JsonDocument.Parse(await response.Content.ReadAsStringAsync());
        Assert.Equal("https://errors.xopti/idempotency-conflict", doc.RootElement.GetProperty("type").GetString());
    }

    // ---- task 3.4: keyset pagination ----

    [Fact]
    public async Task BranchPages_TraverseEveryRowExactlyOnce()
    {
        var client = await SignedInAsync("clerk");
        var seen = new List<string>();
        string? cursor = null;
        var terminated = false;

        for (var pages = 0; pages < 12 && !terminated; pages++)
        {
            var url = cursor is null ? "/api/v1/branches?pageSize=3" : $"/api/v1/branches?pageSize=3&cursor={Uri.EscapeDataString(cursor)}";
            var response = await client.GetAsync(url);
            response.EnsureSuccessStatusCode();

            using var doc = JsonDocument.Parse(await response.Content.ReadAsStringAsync());
            foreach (var item in doc.RootElement.GetProperty("items").EnumerateArray())
            {
                seen.Add(item.GetProperty("branchCode").GetString()!);
            }

            var next = doc.RootElement.GetProperty("nextCursor");
            if (next.ValueKind == JsonValueKind.Null)
            {
                terminated = true;
            }
            else
            {
                cursor = next.GetString();
            }
        }

        Assert.True(terminated, "pagination did not terminate");
        Assert.Equal(7, seen.Count);
        Assert.Equal(seen.Count, seen.Distinct().Count());
        Assert.Equal(new[] { "01", "02", "03", "04", "05", "06", "07" }, seen);
    }

    // ---- task 4.1: versioning ----

    [Fact]
    public async Task V1MountsThroughDispatcher_And_OtherVersionsNotFound()
    {
        var client = await SignedInAsync("clerk");

        var v1 = await client.GetAsync("/api/v1/branches");
        Assert.Equal(HttpStatusCode.OK, v1.StatusCode);

        var v2 = await client.GetAsync("/api/v2/branches");
        Assert.Equal(HttpStatusCode.NotFound, v2.StatusCode);
        Assert.Equal("application/problem+json", v2.Content.Headers.ContentType?.MediaType);

        var unversioned = await client.GetAsync("/api/branches");
        Assert.Equal(HttpStatusCode.NotFound, unversioned.StatusCode);
    }

    // ---- task 4.2: OpenAPI document ----

    [Fact]
    public async Task OpenApiDocument_IsPublishedAndAdvertisesEndpoints()
    {
        var client = new TestClient(Factory);
        var response = await client.GetAsync("/openapi/v1.json");
        response.EnsureSuccessStatusCode();

        using var doc = JsonDocument.Parse(await response.Content.ReadAsStringAsync());
        var paths = doc.RootElement.GetProperty("paths").EnumerateObject().Select(p => p.Name).ToList();

        Assert.Contains("/api/v1/branches", paths);
        Assert.Contains("/api/v1/auth/sign-in", paths);
        Assert.Contains("/api/v1/sales/holds", paths);
        Assert.Contains("/api/v1/branches/{branchCode}", paths);
    }

    [Fact]
    public async Task OpenApiDocument_MatchesCommittedContract()
    {
        var client = new TestClient(Factory);
        var liveResponse = await client.GetAsync("/openapi/v1.json");
        var liveJson = await liveResponse.Content.ReadAsStringAsync();
        liveResponse.EnsureSuccessStatusCode();

        var committed = File.ReadAllText(CommittedContractPath());

        Assert.Equal(Canonicalize(committed), Canonicalize(liveJson));
    }

    internal static string Canonicalize(string json)
    {
        using var doc = JsonDocument.Parse(json);
        var mutable = JsonSerializer.Deserialize<Dictionary<string, JsonElement>>(json)!;
        // The servers block reflects the host binding, not the contract.
        mutable.Remove("servers");
        var sb = new System.Text.StringBuilder();
        WriteSorted(JsonSerializer.SerializeToElement(mutable), sb);
        return sb.ToString();
    }

    private static void WriteSorted(JsonElement element, System.Text.StringBuilder sb)
    {
        switch (element.ValueKind)
        {
            case JsonValueKind.Object:
                sb.Append('{');
                var props = element.EnumerateObject().OrderBy(p => p.Name, StringComparer.Ordinal).ToList();
                for (var i = 0; i < props.Count; i++)
                {
                    if (i > 0)
                    {
                        sb.Append(',');
                    }

                    sb.Append('"').Append(props[i].Name).Append("\":");
                    WriteSorted(props[i].Value, sb);
                }

                sb.Append('}');
                break;
            case JsonValueKind.Array:
                sb.Append('[');
                var items = element.EnumerateArray().ToList();
                for (var i = 0; i < items.Count; i++)
                {
                    if (i > 0)
                    {
                        sb.Append(',');
                    }

                    WriteSorted(items[i], sb);
                }

                sb.Append(']');
                break;
            default:
                sb.Append(element.GetRawText());
                break;
        }
    }

    internal static string CommittedContractPath()
    {
        var dir = new DirectoryInfo(AppContext.BaseDirectory);
        while (dir is not null && !File.Exists(Path.Combine(dir.FullName, "xOpti.sln")))
        {
            dir = dir.Parent;
        }

        return Path.Combine(dir!.FullName, "api-contract", "xopti.api.v1.json");
    }

    // ---- task 5.1: health ----

    [Fact]
    public async Task Health_WhenDatabaseDown_LiveStaysReadyFlips()
    {
        var broken = new XOptiApiFactory(fixture, new Dictionary<string, string?>
        {
            ["ConnectionStrings:XOptiDatabase"] = "Host=127.0.0.1;Port=1;Database=nope;Username=postgres;Password=postgres",
        });

        var live = await new TestClient(broken).GetAsync("/api/health/live");
        var ready = await new TestClient(broken).GetAsync("/api/health/ready");

        Assert.Equal(HttpStatusCode.OK, live.StatusCode);
        Assert.Equal("Healthy", await live.Content.ReadAsStringAsync());
        Assert.Equal(HttpStatusCode.ServiceUnavailable, ready.StatusCode);
        Assert.Equal("Unhealthy", await ready.Content.ReadAsStringAsync());
    }

    [Fact]
    public async Task Health_WithHealthyDatabase_ReportsReady()
    {
        var client = new TestClient(Factory);
        Assert.Equal("Healthy", await (await client.GetAsync("/api/health/ready")).Content.ReadAsStringAsync());
    }

    // ---- task 1.2: composition root resolves real ports ----

    [Fact]
    public void PortsAreResolvedByInfrastructureOrApplication()
    {
        using var factory = new XOptiApiFactory(fixture);
        using var scope = factory.Services.CreateScope();
        var sp = scope.ServiceProvider;

        Assert.IsType<xOpti.Application.Common.Dispatcher>(sp.GetRequiredService<xOpti.Application.Common.IRequestDispatcher>());
        Assert.IsType<EfUnitOfWork>(sp.GetRequiredService<xOpti.Application.Ports.IUnitOfWork>());
        Assert.IsType<PostgresControlNumberAllocator>(sp.GetRequiredService<xOpti.Application.Ports.IControlNumberAllocator>());
        Assert.IsType<xOpti.Infrastructure.Platform.DbIdempotencyStore>(sp.GetRequiredService<xOpti.Application.Ports.IIdempotencyStore>());
        Assert.IsType<xOpti.Infrastructure.Platform.DbAuditRecorder>(sp.GetRequiredService<xOpti.Application.Ports.IAuditRecorder>());
        Assert.IsType<SystemClock>(sp.GetRequiredService<xOpti.Application.Ports.IClock>());
        Assert.IsType<ClaimsCurrentPrincipal>(sp.GetRequiredService<xOpti.Application.Ports.ICurrentPrincipal>());
        Assert.IsType<xOpti.Infrastructure.Repositories.EfBranchRepository>(sp.GetRequiredService<xOpti.Application.Identity.ListBranches.IBranchRepository>());
        Assert.IsType<xOpti.Infrastructure.Documents.QuestPdfDocumentRenderer>(sp.GetRequiredService<xOpti.Infrastructure.Documents.IDocumentRenderer>());
        Assert.IsType<xOpti.Infrastructure.Documents.LocalFileStorage>(sp.GetRequiredService<xOpti.Infrastructure.Documents.IFileStorage>());
    }
}
