using System.Net;
using System.Text.Json;
using xOpti.Api.IntegrationTests.Support;

namespace xOpti.Api.IntegrationTests;

[Collection("api")]
public sealed class AdminStaffApiTests(ApiPostgresFixture fixture)
{
    private static string UniqueUser(string prefix) =>
        $"{prefix}.{Guid.NewGuid().ToString("N")[..8]}";

    private async Task<TestClient> SignInAsync(string user)
    {
        var client = new TestClient(new XOptiApiFactory(fixture));
        await client.FetchCsrfTokenAsync();
        var outcome = await client.SignInAsync(user, SeedData.Password);
        Assert.Equal(HttpStatusCode.OK, outcome.Status);
        return client;
    }

    private static async Task<JsonElement> BodyAsync(HttpResponseMessage response)
    {
        using var document = JsonDocument.Parse(await response.Content.ReadAsStringAsync());
        return document.RootElement.Clone();
    }

    [Fact]
    public async Task AdminEndpoints_RequireMasterDataPermission()
    {
        using var anonymous = new TestClient(new XOptiApiFactory(fixture));
        Assert.Equal(HttpStatusCode.Unauthorized, (await anonymous.GetAsync("/api/v1/admin/staff")).StatusCode);

        using var clerk = await SignInAsync("clerk");
        Assert.Equal(HttpStatusCode.Forbidden, (await clerk.GetAsync("/api/v1/admin/staff")).StatusCode);
        Assert.Equal(HttpStatusCode.Forbidden, (await clerk.GetAsync("/api/v1/admin/roles")).StatusCode);
        Assert.Equal(HttpStatusCode.Forbidden, (await clerk.GetAsync("/api/v1/admin/permissions")).StatusCode);

        var create = await clerk.PostAsync("/api/v1/admin/staff", new
        {
            userName = UniqueUser("denied"),
            role = "clerk",
            reason = "should be denied",
        });
        Assert.Equal(HttpStatusCode.Forbidden, create.StatusCode);
    }

    [Fact]
    public async Task RoleAndPermissionCatalogues_ExposeTheVersionedMatrix()
    {
        using var manager = await SignInAsync("manager");

        var rolesResponse = await manager.GetAsync("/api/v1/admin/roles");
        Assert.Equal(HttpStatusCode.OK, rolesResponse.StatusCode);
        var roles = await BodyAsync(rolesResponse);
        Assert.False(roles.GetProperty("signed").GetBoolean());
        Assert.NotEmpty(roles.GetProperty("parityGaps").EnumerateArray());
        var managerGrants = roles.GetProperty("roles").EnumerateArray()
            .Single(role => role.GetProperty("role").GetString() == "manager");
        Assert.Contains(
            managerGrants.GetProperty("permissions").EnumerateArray().Select(p => p.GetString()),
            permission => permission == "master-data:maintain");
        var adminGrants = roles.GetProperty("roles").EnumerateArray()
            .Single(role => role.GetProperty("role").GetString() == "admin");
        Assert.Contains(
            adminGrants.GetProperty("permissions").EnumerateArray().Select(p => p.GetString()),
            permission => permission == "staff:pii");

        var permissionsResponse = await manager.GetAsync("/api/v1/admin/permissions");
        Assert.Equal(HttpStatusCode.OK, permissionsResponse.StatusCode);
        var permissions = await BodyAsync(permissionsResponse);
        Assert.Contains(
            permissions.GetProperty("unassignedPermissions").EnumerateArray().Select(p => p.GetString()),
            permission => permission == "customer:pii");
    }

    [Fact]
    public async Task StaffLifecycle_EndToEnd_IncludingForcedReset()
    {
        using var manager = await SignInAsync("manager");
        var userName = UniqueUser("lifecycle");

        var create = await manager.PostAsync("/api/v1/admin/staff", new
        {
            userName,
            displayName = "Lifecycle Test",
            role = "clerk",
            branchCode = "01",
            reason = "integration lifecycle",
        });
        Assert.Equal(HttpStatusCode.Created, create.StatusCode);
        var created = await BodyAsync(create);
        var id = created.GetProperty("account").GetProperty("id").GetString()!;
        var resetToken = created.GetProperty("resetToken").GetString()!;
        Assert.False(string.IsNullOrWhiteSpace(resetToken));
        Assert.True(created.GetProperty("account").GetProperty("resetRequired").GetBoolean());
        Assert.False(created.GetProperty("account").TryGetProperty("email", out _));

        // Duplicate create is a domain rejection.
        var duplicate = await manager.PostAsync("/api/v1/admin/staff", new
        {
            userName,
            role = "clerk",
            reason = "duplicate",
        });
        Assert.Equal(HttpStatusCode.UnprocessableEntity, duplicate.StatusCode);

        // Unknown role is a field validation error.
        var badRole = await manager.PostAsync("/api/v1/admin/staff", new
        {
            userName = UniqueUser("badrole"),
            role = "superuser",
            reason = "bad role",
        });
        Assert.Equal(HttpStatusCode.BadRequest, badRole.StatusCode);
        var problem = await BodyAsync(badRole);
        Assert.Contains(
            problem.GetProperty("errors").EnumerateArray().Select(error => error.GetProperty("message").GetString()),
            message => message!.Contains("approved permission matrix"));

        // Role change and branch scope are visible on the next read.
        var role = await manager.PutAsync($"/api/v1/admin/staff/{id}/role", new { role = "optician", reason = "promotion" });
        Assert.Equal(HttpStatusCode.OK, role.StatusCode);
        var branch = await manager.PutAsync($"/api/v1/admin/staff/{id}/branch", new { branchCode = "02", reason = "transfer" });
        Assert.Equal(HttpStatusCode.OK, branch.StatusCode);

        var read = await BodyAsync(await manager.GetAsync($"/api/v1/admin/staff/{id}"));
        Assert.Equal("02", read.GetProperty("branchCode").GetString());
        Assert.Contains(read.GetProperty("roles").EnumerateArray().Select(r => r.GetString()), r => r == "optician");

        // Forced reset invalidates the account until the token is used.
        var force = await manager.PostAsync($"/api/v1/admin/staff/{id}/force-reset", new { reason = "lost password" });
        Assert.Equal(HttpStatusCode.OK, force.StatusCode);
        var forceBody = await BodyAsync(force);
        var newToken = forceBody.GetProperty("resetToken").GetString()!;
        Assert.True(forceBody.GetProperty("account").GetProperty("resetRequired").GetBoolean());

        // The reset endpoint is anonymous but CSRF-protected.
        using var anonymous = new TestClient(new XOptiApiFactory(fixture));
        var noCsrf = await anonymous.Http.PostAsync(
            "/api/v1/auth/reset-password",
            new StringContent(JsonSerializer.Serialize(new
            {
                username = userName,
                token = newToken,
                newPassword = "New#Strong1Pass",
            }), System.Text.Encoding.UTF8, "application/json"));
        Assert.Equal(HttpStatusCode.Forbidden, noCsrf.StatusCode);

        await anonymous.FetchCsrfTokenAsync();
        var reset = await anonymous.PostAsync("/api/v1/auth/reset-password", new
        {
            username = userName,
            token = newToken,
            newPassword = "New#Strong1Pass",
        });
        Assert.Equal(HttpStatusCode.OK, reset.StatusCode);

        // Token reuse fails, and the new password signs in.
        var reuse = await anonymous.PostAsync("/api/v1/auth/reset-password", new
        {
            username = userName,
            token = newToken,
            newPassword = "Another#Pass1",
        });
        Assert.Equal(HttpStatusCode.UnprocessableEntity, reuse.StatusCode);

        using var signedIn = new TestClient(new XOptiApiFactory(fixture));
        await signedIn.FetchCsrfTokenAsync();
        Assert.Equal(HttpStatusCode.OK, (await signedIn.SignInAsync(userName, "New#Strong1Pass")).Status);

        // Disable and re-enable.
        Assert.Equal(HttpStatusCode.OK,
            (await manager.PostAsync($"/api/v1/admin/staff/{id}/disable", new { reason = "left company" })).StatusCode);
        var disabled = await BodyAsync(await manager.GetAsync($"/api/v1/admin/staff/{id}"));
        Assert.True(disabled.GetProperty("disabled").GetBoolean());
        Assert.Equal(HttpStatusCode.OK,
            (await manager.PostAsync($"/api/v1/admin/staff/{id}/enable", new { reason = "returned" })).StatusCode);
    }

    [Fact]
    public async Task ResetWithUnknownAccount_IsIndistinguishableFromABadToken()
    {
        using var client = new TestClient(new XOptiApiFactory(fixture));
        await client.FetchCsrfTokenAsync();

        var unknown = await client.PostAsync("/api/v1/auth/reset-password", new
        {
            username = "does-not-exist." + Guid.NewGuid().ToString("N")[..6],
            token = "bogus",
            newPassword = "New#Strong1Pass",
        });
        var seeded = await client.PostAsync("/api/v1/auth/reset-password", new
        {
            username = "manager",
            token = "bogus",
            newPassword = "New#Strong1Pass",
        });

        Assert.Equal(HttpStatusCode.UnprocessableEntity, unknown.StatusCode);
        Assert.Equal(HttpStatusCode.UnprocessableEntity, seeded.StatusCode);
        Assert.Equal(
            (await BodyAsync(unknown)).GetProperty("detail").GetString(),
            (await BodyAsync(seeded)).GetProperty("detail").GetString());
    }
}
