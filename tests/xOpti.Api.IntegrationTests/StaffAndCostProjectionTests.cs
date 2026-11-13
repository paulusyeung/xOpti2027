using System.Net;
using System.Text.Json;
using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.DependencyInjection;
using xOpti.Api.IntegrationTests.Support;
using xOpti.Application.Identity.Staff;
using xOpti.Infrastructure;
using xOpti.Infrastructure.Identity;

namespace xOpti.Api.IntegrationTests;

[Collection("api")]
public sealed class StaffAndCostProjectionTests(ApiPostgresFixture fixture)
{
    private async Task<TestClient> SignInAsync(string user)
    {
        var client = new TestClient(new XOptiApiFactory(fixture));
        await client.FetchCsrfTokenAsync();
        var outcome = await client.SignInAsync(user, SeedData.Password);
        Assert.Equal(HttpStatusCode.OK, outcome.Status);
        return client;
    }

    [Fact]
    public async Task StaffDirectory_OmitsPii_WithoutStaffPii_AndIncludesItForAdmin()
    {
        using var manager = await SignInAsync("manager");
        var managerResponse = await manager.GetAsync("/api/v1/admin/staff?pageSize=50");
        Assert.Equal(HttpStatusCode.OK, managerResponse.StatusCode);

        using var managerBody = JsonDocument.Parse(await managerResponse.Content.ReadAsStringAsync());
        var managerRow = Find(managerBody.RootElement, "manager");
        Assert.False(managerRow.TryGetProperty("email", out _));
        Assert.False(managerRow.TryGetProperty("phoneNumber", out _));
        Assert.Equal("01", managerRow.GetProperty("branchCode").GetString());

        using var admin = await SignInAsync("admin");
        var adminResponse = await admin.GetAsync("/api/v1/admin/staff?pageSize=50");
        Assert.Equal(HttpStatusCode.OK, adminResponse.StatusCode);

        using var adminBody = JsonDocument.Parse(await adminResponse.Content.ReadAsStringAsync());
        var adminRow = Find(adminBody.RootElement, "manager");
        Assert.Equal("manager@example.test", adminRow.GetProperty("email").GetString());
        Assert.Equal("604-555-0100", adminRow.GetProperty("phoneNumber").GetString());
    }

    [Fact]
    public async Task StaffDirectory_RequiresMasterDataPermission()
    {
        using var clerk = await SignInAsync("clerk");

        var response = await clerk.GetAsync("/api/v1/admin/staff");

        Assert.Equal(HttpStatusCode.Forbidden, response.StatusCode);
    }

    [Fact]
    public async Task InventoryCost_IsOmittedWithoutCostView_AndPresentWithIt()
    {
        using var purchasing = await SignInAsync("purchasing");
        var hidden = await purchasing.GetAsync("/api/v1/inventory/30110359");
        Assert.Equal(HttpStatusCode.OK, hidden.StatusCode);

        using var hiddenBody = JsonDocument.Parse(await hidden.Content.ReadAsStringAsync());
        Assert.False(hiddenBody.RootElement.TryGetProperty("averageCost", out _));
        Assert.Equal("30110359", hiddenBody.RootElement.GetProperty("sku").GetString());

        using var manager = await SignInAsync("manager");
        var visible = await manager.GetAsync("/api/v1/inventory/30110359");
        Assert.Equal(HttpStatusCode.OK, visible.StatusCode);

        using var visibleBody = JsonDocument.Parse(await visible.Content.ReadAsStringAsync());
        Assert.True(visibleBody.RootElement.TryGetProperty("averageCost", out _));
    }

    [Fact]
    public async Task InventoryEndpoint_RequiresInventoryPermission()
    {
        using var clerk = await SignInAsync("clerk");

        var response = await clerk.GetAsync("/api/v1/inventory/30110359");

        Assert.Equal(HttpStatusCode.Forbidden, response.StatusCode);
    }

    [Fact]
    public async Task DisabledAccount_ExistingSession_IsRejectedOnTheNextRequest()
    {
        using var client = new TestClient(new XOptiApiFactory(fixture));
        await client.FetchCsrfTokenAsync();
        Assert.Equal(HttpStatusCode.OK, (await client.SignInAsync("clerk", SeedData.Password)).Status);

        var me = await client.GetAsync("/api/v1/auth/me");
        Assert.Equal(HttpStatusCode.OK, me.StatusCode);
        using var meBody = JsonDocument.Parse(await me.Content.ReadAsStringAsync());
        Assert.Equal("01", meBody.RootElement.GetProperty("branch").GetString());

        var services = new ServiceCollection();
        services.AddXOptiInfrastructure(new InfrastructureOptions { ConnectionString = fixture.ConnectionString });
        services.AddXOptiIdentity();
        await using var provider = services.BuildServiceProvider();
        using var scope = provider.CreateScope();
        var users = scope.ServiceProvider.GetRequiredService<UserManager<XoptiUser>>();
        var store = scope.ServiceProvider.GetRequiredService<IStaffAccountStore>();
        var user = await users.FindByNameAsync("clerk");
        Assert.NotNull(user);

        try
        {
            var account = await store.FindByIdAsync(user!.Id, CancellationToken.None);
            await store.SetDisabledAsync(account!, true, CancellationToken.None);

            var rejected = await client.GetAsync("/api/v1/auth/me");
            Assert.Equal(HttpStatusCode.Unauthorized, rejected.StatusCode);
        }
        finally
        {
            var current = await store.FindByIdAsync(user!.Id, CancellationToken.None);
            await store.SetDisabledAsync(current!, false, CancellationToken.None);
        }
    }

    private static JsonElement Find(JsonElement page, string userName)
    {
        foreach (var row in page.GetProperty("items").EnumerateArray())
        {
            if (row.GetProperty("userName").GetString() == userName)
            {
                return row;
            }
        }

        throw new Xunit.Sdk.XunitException($"staff row '{userName}' was not returned");
    }
}
