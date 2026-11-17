using System.Net;
using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using xOpti.Api.IntegrationTests.Support;
using xOpti.Infrastructure.Persistence.Entities;

namespace xOpti.Api.IntegrationTests;

[Collection("api")]
public sealed class PrescriptionTests(ApiPostgresFixture fixture)
{
    private async Task<TestClient> SignedInAsync(string user = "manager")
    {
        var client = new TestClient(new XOptiApiFactory(fixture));
        await client.FetchCsrfTokenAsync();
        Assert.Equal(HttpStatusCode.OK, (await client.SignInAsync(user, SeedData.Password)).Status);
        return client;
    }

    private static object Eye(decimal sphere = 1.25m, decimal cylinder = -0.5m, int axis = 90) => new
    {
        sphere, cylinder, axis, add = 2m, prism = 1m, @base = 0m, pd = 32m,
    };

    private static object Spectacle(
        DateTimeOffset issued, string reason = "new prescription",
        decimal? rightSphere = 1.25m) => new
    {
        issuedOn = issued,
        prescriberId = 1,
        right = new
        {
            sphere = rightSphere, cylinder = -0.5m, axis = 90, add = 2m,
            prism = 1m, @base = 0m, pd = 32m,
        },
        left = Eye(-1.75m, -1.25m, 85),
        notes = "test prescription",
        reason,
    };

    private static object Contact(DateTimeOffset issued, decimal baseCurve = 8.6m) => new
    {
        issuedOn = issued, prescriberId = 1, brand = "Test Lens", baseCurve,
        diameter = 14.2m, rightPower = -2.5m, rightCylinder = -0.75m, rightAxis = 10,
        leftPower = -2.75m, leftCylinder = -0.5m, leftAxis = 170,
        replacementSchedule = "monthly", notes = "contact test",
        reason = "contact prescription",
    };

    private static async Task<int> CreateCustomerAsync(TestClient manager, string name)
    {
        var response = await manager.PostAsync("/api/v1/customers", new
        {
            input = new
            {
                fullName = name, firstName = name.Split(' ')[0], lastName = name.Split(' ')[^1],
                homePhone = "6045550100", email = $"{Guid.NewGuid():N}@example.test",
            },
            confirmDuplicate = true, reason = "rx test customer",
        });
        Assert.Equal(HttpStatusCode.Created, response.StatusCode);
        using var body = JsonDocument.Parse(await response.Content.ReadAsStringAsync());
        return body.RootElement.GetProperty("customer").GetProperty("id").GetInt32();
    }

    private static async Task<JsonElement> BodyAsync(HttpResponseMessage response,
        XOptiApiFactory factory, HttpStatusCode expected)
    {
        if (response.StatusCode != expected)
            Assert.Fail($"{response.StatusCode}: {await response.Content.ReadAsStringAsync()}");
        using var body = JsonDocument.Parse(await response.Content.ReadAsStringAsync());
        return body.RootElement.Clone();
    }

    [Fact]
    public async Task PrescriptionVersions_AreImmutable_AndLegacyRowsRemainReadable()
    {
        var factory = new XOptiApiFactory(fixture);
        using var manager = new TestClient(factory);
        await manager.FetchCsrfTokenAsync();
        await manager.SignInAsync("manager", SeedData.Password);
        var customerId = await CreateCustomerAsync(manager, "Rx Customer " + Guid.NewGuid().ToString("N")[..6]);

        await using (var seed = fixture.NewContext())
        {
            seed.CustomerPresLenses.Add(new CustomerPresLens
            {
                CustomerId = customerId, IssuedOn = DateTimeOffset.UtcNow,
                IssuedByDr = 1, RightSphere = 1.0, RightCylinder = -0.25, RightAxis = 80,
                LeftSphere = -1.0, LeftCylinder = -0.25, LeftAxis = 100,
            });
            await seed.SaveChangesAsync();
        }

        var legacy = await BodyAsync(await manager.GetAsync(
            $"/api/v1/customers/{customerId}/prescriptions"), factory, HttpStatusCode.OK);
        Assert.Contains(legacy.GetProperty("spectacle").EnumerateArray(),
            row => row.GetProperty("source").GetString() == "legacy");

        var first = await BodyAsync(await manager.PostAsync(
            $"/api/v1/customers/{customerId}/prescriptions/spectacle",
            Spectacle(DateTimeOffset.UtcNow.AddDays(-2))), factory, HttpStatusCode.OK);
        var firstVersion = first.GetProperty("spectacle").EnumerateArray()
            .Last(row => row.GetProperty("source").GetString() == "app");
        Assert.Equal(1, firstVersion.GetProperty("versionNumber").GetInt32());
        Assert.True(firstVersion.GetProperty("isCurrent").GetBoolean());

        var second = await BodyAsync(await manager.PostAsync(
            $"/api/v1/customers/{customerId}/prescriptions/spectacle",
            Spectacle(DateTimeOffset.UtcNow.AddDays(-1), "amended prescription", 2.0m)),
            factory, HttpStatusCode.OK);
        var appVersions = second.GetProperty("spectacle").EnumerateArray()
            .Where(row => row.GetProperty("source").GetString() == "app").ToList();
        Assert.Equal(2, appVersions.Count);
        Assert.Equal(1, appVersions[0].GetProperty("versionNumber").GetInt32());
        Assert.False(appVersions[0].GetProperty("isCurrent").GetBoolean());
        Assert.Equal(1.25m, appVersions[0].GetProperty("right").GetProperty("sphere").GetDecimal());
        Assert.Equal(2, appVersions[1].GetProperty("versionNumber").GetInt32());
        Assert.True(appVersions[1].GetProperty("isCurrent").GetBoolean());
        Assert.Equal(2.0m, appVersions[1].GetProperty("right").GetProperty("sphere").GetDecimal());

        var invalid = await manager.PostAsync(
            $"/api/v1/customers/{customerId}/prescriptions/spectacle",
            Spectacle(DateTimeOffset.UtcNow, rightSphere: null));
        Assert.Equal(HttpStatusCode.BadRequest, invalid.StatusCode);

        var invalidContact = await manager.PostAsync(
            $"/api/v1/customers/{customerId}/prescriptions/contact",
            Contact(DateTimeOffset.UtcNow, baseCurve: 20m));
        Assert.Equal(HttpStatusCode.BadRequest, invalidContact.StatusCode);
        var contact = await BodyAsync(await manager.PostAsync(
            $"/api/v1/customers/{customerId}/prescriptions/contact",
            Contact(DateTimeOffset.UtcNow)), factory, HttpStatusCode.OK);
        Assert.Single(contact.GetProperty("contact").EnumerateArray());
    }

    [Fact]
    public async Task VerificationMedicalNotesAndAttachments_AreAuditedAndPermissioned()
    {
        var factory = new XOptiApiFactory(fixture);
        using var manager = new TestClient(factory);
        await manager.FetchCsrfTokenAsync();
        await manager.SignInAsync("manager", SeedData.Password);
        var customerId = await CreateCustomerAsync(manager, "Rx Attach " + Guid.NewGuid().ToString("N")[..6]);

        var saved = await BodyAsync(await manager.PostAsync(
            $"/api/v1/customers/{customerId}/prescriptions/spectacle",
            Spectacle(DateTimeOffset.UtcNow)), factory, HttpStatusCode.OK);
        var versionId = saved.GetProperty("spectacle").EnumerateArray()
            .Single(row => row.GetProperty("source").GetString() == "app")
            .GetProperty("id").GetInt64();

        var verified = await BodyAsync(await manager.PostAsync(
            $"/api/v1/customers/{customerId}/prescriptions/verify", new
            {
                type = "spectacle", versionId, note = "checked", reason = "verified sale",
            }), factory, HttpStatusCode.OK);
        Assert.NotNull(verified.GetProperty("spectacle").EnumerateArray()
            .Single(row => row.GetProperty("id").GetInt64() == versionId)
            .GetProperty("verifiedAt").GetString());

        await BodyAsync(await manager.PostAsync($"/api/v1/customers/{customerId}/medical-notes", new
        {
            note = "allergy: none", reason = "medical history",
        }), factory, HttpStatusCode.OK);

        using var multipart = new MultipartFormDataContent();
        var bytes = Encoding.UTF8.GetBytes("%PDF-1.4 test");
        var file = new ByteArrayContent(bytes);
        file.Headers.ContentType = new MediaTypeHeaderValue("application/pdf");
        multipart.Add(file, "file", "scan.pdf");
        multipart.Add(new StringContent("prescription"), "kind");
        multipart.Add(new StringContent("spectacle"), "prescriptionType");
        multipart.Add(new StringContent(versionId.ToString()), "versionId");
        multipart.Add(new StringContent("attachment"), "reason");
        var uploaded = await BodyAsync(await manager.PostMultipartAsync(
            $"/api/v1/customers/{customerId}/attachments", multipart),
            factory, HttpStatusCode.OK);
        var attachmentId = uploaded.GetProperty("attachments").EnumerateArray()
            .Single().GetProperty("id").GetInt64();

        using var bad = new MultipartFormDataContent();
        var text = new ByteArrayContent(Encoding.UTF8.GetBytes("not allowed"));
        text.Headers.ContentType = new MediaTypeHeaderValue("text/plain");
        bad.Add(text, "file", "scan.txt");
        bad.Add(new StringContent("prescription"), "kind");
        bad.Add(new StringContent("unsupported"), "reason");
        var rejected = await manager.PostMultipartAsync(
            $"/api/v1/customers/{customerId}/attachments", bad);
        Assert.Equal(HttpStatusCode.BadRequest, rejected.StatusCode);

        var download = await manager.GetAsync($"/api/v1/customers/attachments/{attachmentId}");
        Assert.Equal(HttpStatusCode.OK, download.StatusCode);
        Assert.Equal("application/pdf", download.Content.Headers.ContentType?.MediaType);
        Assert.Equal(bytes, await download.Content.ReadAsByteArrayAsync());

        using var clerk = new TestClient(factory);
        await clerk.FetchCsrfTokenAsync();
        await clerk.SignInAsync("clerk", SeedData.Password);
        Assert.Equal(HttpStatusCode.Forbidden,
            (await clerk.GetAsync($"/api/v1/customers/{customerId}/prescriptions")).StatusCode);
        Assert.Equal(HttpStatusCode.Forbidden,
            (await clerk.GetAsync($"/api/v1/customers/attachments/{attachmentId}")).StatusCode);

        await using var verify = fixture.NewContext();
        Assert.True(await verify.AuditLogs.AnyAsync(row =>
            row.Action == "prescription.verify" && row.EntityId == customerId.ToString()));
        Assert.True(await verify.AuditLogs.AnyAsync(row =>
            row.Action == "prescription.attachment.upload" && row.EntityId == customerId.ToString()));
        Assert.True(await verify.AuditLogs.AnyAsync(row =>
            row.Action == "prescription.attachment.access" && row.EntityId == customerId.ToString()));
    }
}
