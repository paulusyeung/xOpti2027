using System.Net;
using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using xOpti.Api.IntegrationTests.Support;
using xOpti.Infrastructure.Persistence.Entities;

namespace xOpti.Api.IntegrationTests;

[Collection("api")]
public sealed class PiiAccessTests(ApiPostgresFixture fixture)
{
    [Fact]
    public async Task ProtectedCustomerPrescriptionAndClaimData_AreNotLeakedWithoutPermission()
    {
        const int customerId = 939991;
        const string phone = "6045559399";
        const string email = "pii-sentinel@example.test";
        await using (var seed = fixture.NewContext())
        {
            seed.Customers.Add(new Customer
            {
                Id = customerId, FullName = "PII Sentinel", FirstName = "PII",
                LastName = "Sentinel", HomePhone = phone, Email = email,
                HomeAddress = "99 Secret Street", Remarks = "private",
            });
            await seed.SaveChangesAsync();
        }

        var factory = new XOptiApiFactory(fixture);
        using var manager = new TestClient(factory);
        await manager.FetchCsrfTokenAsync();
        await manager.SignInAsync("manager", SeedData.Password);

        var detail = await manager.GetAsync($"/api/v1/customers/{customerId}");
        Assert.Equal(HttpStatusCode.OK, detail.StatusCode);
        var detailText = await detail.Content.ReadAsStringAsync();
        Assert.Contains("***", detailText);
        Assert.DoesNotContain(phone, detailText);
        Assert.DoesNotContain(email, detailText);
        Assert.DoesNotContain("99 Secret Street", detailText);

        var search = await manager.GetAsync("/api/v1/customers?search=PII%20Sentinel");
        var searchText = await search.Content.ReadAsStringAsync();
        Assert.Contains("***", searchText);
        Assert.DoesNotContain(phone, searchText);

        using var clerk = new TestClient(factory);
        await clerk.FetchCsrfTokenAsync();
        await clerk.SignInAsync("clerk", SeedData.Password);
        foreach (var path in new[]
                 {
                     $"/api/v1/customers/{customerId}/prescriptions",
                     "/api/v1/claims",
                     "/api/v1/claims/reconciliation",
                 })
        {
            var response = await clerk.GetAsync(path);
            Assert.True(response.StatusCode is HttpStatusCode.Forbidden
                or HttpStatusCode.Unauthorized, $"{path}: {response.StatusCode}");
            var text = await response.Content.ReadAsStringAsync();
            Assert.DoesNotContain(phone, text);
            Assert.DoesNotContain(email, text);
        }

        var clerkDetail = await clerk.GetAsync($"/api/v1/customers/{customerId}");
        Assert.Equal(HttpStatusCode.OK, clerkDetail.StatusCode);
        var clerkText = await clerkDetail.Content.ReadAsStringAsync();
        Assert.DoesNotContain(phone, clerkText);
        Assert.DoesNotContain(email, clerkText);

        await using var verify = fixture.NewContext();
        Assert.True(await verify.AuditLogs.AnyAsync(row =>
            row.Action == "customer.pii.denied" && row.EntityId == customerId.ToString()));
    }
}
