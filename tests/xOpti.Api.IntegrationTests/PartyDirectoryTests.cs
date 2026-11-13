using System.Net;
using Microsoft.EntityFrameworkCore;
using System.Text.Json;
using xOpti.Api.IntegrationTests.Support;

namespace xOpti.Api.IntegrationTests;

[Collection("api")]
public sealed class PartyDirectoryTests(ApiPostgresFixture fixture)
{
    private async Task<TestClient> ManagerAsync()
    {
        var client = new TestClient(new XOptiApiFactory(fixture));
        await client.FetchCsrfTokenAsync();
        Assert.Equal(HttpStatusCode.OK, (await client.SignInAsync("manager", SeedData.Password)).Status);
        return client;
    }

    private static async Task<JsonElement> BodyAsync(HttpResponseMessage response)
    {
        using var document = JsonDocument.Parse(await response.Content.ReadAsStringAsync());
        return document.RootElement.Clone();
    }

    [Fact]
    public async Task SupplierDirectory_RejectsDuplicates_AndSearchesCaseInsensitively()
    {
        using var manager = await ManagerAsync();
        var code = Guid.NewGuid().ToString("N")[..4].ToUpperInvariant();
        var name = $"Supplier {code}";

        var create = await manager.PostAsync("/api/v1/admin/suppliers", new
        {
            supplierCode = code,
            name,
            province = "BC",
            country = "CA",
            paymentTerms = "NET30",
            reason = "integration supplier",
        });
        Assert.Equal(HttpStatusCode.Created, create.StatusCode);

        var duplicate = await manager.PostAsync("/api/v1/admin/suppliers", new
        {
            supplierCode = code,
            name = "Duplicate",
            reason = "duplicate probe",
        });
        Assert.Equal(HttpStatusCode.BadRequest, duplicate.StatusCode);
        var duplicateBody = await BodyAsync(duplicate);
        Assert.Contains(
            duplicateBody.GetProperty("errors").EnumerateArray().Select(error => error.GetProperty("field").GetString()),
            field => field == "SupplierCode");

        var list = await manager.GetAsync($"/api/v1/admin/suppliers?search=SUPPLIER%20{code}");
        Assert.Equal(HttpStatusCode.OK, list.StatusCode);
        using var listBody = JsonDocument.Parse(await list.Content.ReadAsStringAsync());
        Assert.Equal(code, Assert.Single(listBody.RootElement.GetProperty("items").EnumerateArray())
            .GetProperty("supplierCode").GetString());
    }

    [Fact]
    public async Task DoctorAndContactDirectories_ValidateRequiredFieldsAndUniqueness()
    {
        using var manager = await ManagerAsync();
        var code = Guid.NewGuid().ToString("N")[..4].ToUpperInvariant();

        await manager.PostAsync("/api/v1/admin/suppliers", new
        {
            supplierCode = code,
            name = $"Contact Supplier {code}",
            reason = "for contacts",
        });

        var doctor = await manager.PostAsync("/api/v1/admin/doctors", new
        {
            name = "Dr Integration",
            province = "BC",
            country = "CA",
            reason = "integration doctor",
        });
        Assert.Equal(HttpStatusCode.Created, doctor.StatusCode);
        Assert.True((await BodyAsync(doctor)).GetProperty("id").GetInt32() > 0);

        var missingName = await manager.PostAsync("/api/v1/admin/doctors", new
        {
            name = "",
            reason = "invalid doctor",
        });
        Assert.Equal(HttpStatusCode.BadRequest, missingName.StatusCode);

        var contact = await manager.PostAsync($"/api/v1/admin/suppliers/{code}/contacts", new
        {
            firstName = "Alex",
            initial = "B",
            lastName = "Chen",
            jobTitle = "Buyer",
            reason = "integration contact",
        });
        Assert.Equal(HttpStatusCode.Created, contact.StatusCode);

        var duplicate = await manager.PostAsync($"/api/v1/admin/suppliers/{code}/contacts", new
        {
            firstName = "Alex",
            initial = "B",
            lastName = "Chen",
            reason = "duplicate contact",
        });
        Assert.Equal(HttpStatusCode.BadRequest, duplicate.StatusCode);
        Assert.Contains(
            (await BodyAsync(duplicate)).GetProperty("errors").EnumerateArray()
                .Select(error => error.GetProperty("field").GetString()),
            field => field == "LastName");

        var contacts = await manager.GetAsync($"/api/v1/admin/suppliers/{code}/contacts");
        using var contactsBody = JsonDocument.Parse(await contacts.Content.ReadAsStringAsync());
        Assert.Contains(
            contactsBody.RootElement.EnumerateArray().Select(row => row.GetProperty("lastName").GetString()),
            lastName => lastName == "Chen");
    }

    [Fact]
    public async Task BranchDeactivation_BlocksReferences_AndAcceptsAClosureDecision()
    {
        using var manager = await ManagerAsync();

        var blocked = await manager.PostAsync("/api/v1/admin/branches/01/deactivate", new
        {
            reason = "closure probe",
        });
        Assert.Equal(HttpStatusCode.BadRequest, blocked.StatusCode);
        Assert.Contains(
            (await BodyAsync(blocked)).GetProperty("errors").EnumerateArray()
                .Select(error => error.GetProperty("field").GetString()),
            field => field == "TargetBranchCode");

        var invalidTarget = await manager.PostAsync("/api/v1/admin/branches/01/deactivate", new
        {
            reason = "closure probe",
            targetBranchCode = "01",
        });
        Assert.Equal(HttpStatusCode.BadRequest, invalidTarget.StatusCode);

        var closed = await manager.PostAsync("/api/v1/admin/branches/07/deactivate", new
        {
            reason = "branch consolidated",
        });
        Assert.Equal(HttpStatusCode.OK, closed.StatusCode);

        await using var context = fixture.NewContext();
        Assert.True(await context.EntityRetirements.AnyAsync(row =>
            row.EntityType == "Branch" && row.EntityKey == "07"));
        Assert.True(await context.AuditLogs.AnyAsync(row =>
            row.EntityId == "07" && row.Action == "branch.deactivate"));
    }
}
