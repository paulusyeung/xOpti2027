using System.Net;
using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using xOpti.Api.IntegrationTests.Support;
using xOpti.Infrastructure.Persistence.Entities;

namespace xOpti.Api.IntegrationTests;

[Collection("api")]
public sealed class WholesaleAccountTests(ApiPostgresFixture fixture)
{
    private static async Task<JsonElement> BodyAsync(HttpResponseMessage response,
        XOptiApiFactory factory, HttpStatusCode expected)
    {
        if (response.StatusCode != expected)
        {
            var exceptions = string.Join("\n", factory.Logs.Snapshot()
                .Where(entry => entry.Exception is not null)
                .Select(entry => entry.Exception!.ToString()));
            Assert.Fail($"{response.StatusCode}: {await response.Content.ReadAsStringAsync()}\n{exceptions}");
        }
        using var document = JsonDocument.Parse(await response.Content.ReadAsStringAsync());
        return document.RootElement.Clone();
    }

    private static object Input(
        string grade = "B", string terms = "NET30", int days = 30,
        decimal credit = 25000.1234m, string tax = "EXEMPT", string? rep = "0042") => new
    {
        priceGrade = grade, termsCode = terms, termsDays = days, creditLimit = credit,
        taxTreatment = tax, representativeStaffCode = rep, creditHold = false,
        notes = "wholesale terms",
    };

    private async Task<int> SeedCustomerAsync(string staffCode = "0042")
    {
        var customerId = Random.Shared.Next(940000, 949999);
        await using var seed = fixture.NewContext();
        seed.Customers.Add(new Customer
        {
            Id = customerId, FullName = "Wholesale Account Customer",
            PaymentTerms = "NET30",
        });
        await seed.Database.ExecuteSqlInterpolatedAsync($"""
            INSERT INTO public.staff (staff_code, staff_full_name, security_level, date_hired, sin)
            VALUES ({staffCode}, 'Wholesale Representative', 1, now(), '000000000')
            ON CONFLICT (staff_code) DO NOTHING;
            """);
        await seed.SaveChangesAsync();
        return customerId;
    }

    [Fact]
    public async Task SaveWholesaleAccount_RecordsTermsAndAudit_AndValidates()
    {
        var customerId = await SeedCustomerAsync();
        var factory = new XOptiApiFactory(fixture);
        using var manager = new TestClient(factory);
        await manager.FetchCsrfTokenAsync();
        await manager.SignInAsync("manager", SeedData.Password);

        var saved = await BodyAsync(await manager.PutAsync(
            $"/api/v1/wholesale/accounts/{customerId}",
            new { input = Input(), reason = "approve wholesale terms" }),
            factory, HttpStatusCode.OK);
        Assert.True(saved.GetProperty("isWholesale").GetBoolean());
        Assert.Equal("B", saved.GetProperty("priceGrade").GetString());
        Assert.Equal("NET30", saved.GetProperty("termsCode").GetString());
        Assert.Equal(30, saved.GetProperty("termsDays").GetInt32());
        Assert.Equal(25000.1234m, saved.GetProperty("creditLimit").GetDecimal());
        Assert.Equal("EXEMPT", saved.GetProperty("taxTreatment").GetString());
        Assert.Equal("0042", saved.GetProperty("representativeStaffCode").GetString());

        var loaded = await BodyAsync(await manager.GetAsync(
            $"/api/v1/wholesale/accounts/{customerId}"), factory, HttpStatusCode.OK);
        Assert.Equal(25000.1234m, loaded.GetProperty("creditLimit").GetDecimal());

        var badGrade = await manager.PutAsync($"/api/v1/wholesale/accounts/{customerId}",
            new { input = Input(grade: "Z"), reason = "bad grade" });
        Assert.Equal(HttpStatusCode.BadRequest, badGrade.StatusCode);
        Assert.Contains("A, B, or C", await badGrade.Content.ReadAsStringAsync());

        var badTerms = await manager.PutAsync($"/api/v1/wholesale/accounts/{customerId}",
            new { input = Input(days: 999), reason = "bad terms" });
        Assert.Equal(HttpStatusCode.BadRequest, badTerms.StatusCode);

        var badRep = await manager.PutAsync($"/api/v1/wholesale/accounts/{customerId}",
            new { input = Input(rep: "9999"), reason = "missing rep" });
        Assert.Equal(HttpStatusCode.BadRequest, badRep.StatusCode);
        Assert.Contains("representative", await badRep.Content.ReadAsStringAsync(),
            StringComparison.OrdinalIgnoreCase);

        var missing = await manager.PutAsync("/api/v1/wholesale/accounts/999999",
            new { input = Input(), reason = "missing customer" });
        Assert.Equal(HttpStatusCode.BadRequest, missing.StatusCode);

        await using var verify = fixture.NewContext();
        Assert.True(await verify.WholesaleAccounts.AnyAsync(row =>
            row.CustomerId == customerId && row.PriceGrade == "B"));
        Assert.True(await verify.AuditLogs.AnyAsync(row =>
            row.Action == "wholesale.account.save"
            && row.EntityId == customerId.ToString()));

        using var clerk = new TestClient(factory);
        await clerk.FetchCsrfTokenAsync();
        await clerk.SignInAsync("clerk", SeedData.Password);
        Assert.Equal(HttpStatusCode.Forbidden,
            (await clerk.GetAsync($"/api/v1/wholesale/accounts/{customerId}")).StatusCode);
        Assert.Equal(HttpStatusCode.Forbidden,
            (await clerk.PutAsync($"/api/v1/wholesale/accounts/{customerId}",
                new { input = Input(), reason = "clerk cannot configure" })).StatusCode);
    }

    [Fact]
    public async Task MissingWholesaleAccount_ReturnsClearConfigurationError()
    {
        var customerId = await SeedCustomerAsync("0043");
        var factory = new XOptiApiFactory(fixture);
        using var manager = new TestClient(factory);
        await manager.FetchCsrfTokenAsync();
        await manager.SignInAsync("manager", SeedData.Password);

        var response = await manager.GetAsync($"/api/v1/wholesale/accounts/{customerId}");
        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
        Assert.Contains("wholesale account", await response.Content.ReadAsStringAsync(),
            StringComparison.OrdinalIgnoreCase);
    }
}
