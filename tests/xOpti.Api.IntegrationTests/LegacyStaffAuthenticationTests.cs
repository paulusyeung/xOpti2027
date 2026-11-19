using System.Net;
using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using xOpti.Api.IntegrationTests.Support;

namespace xOpti.Api.IntegrationTests;

[Collection("api")]
public sealed class LegacyStaffAuthenticationTests(ApiPostgresFixture fixture)
{
    private async Task SeedStaffAsync()
    {
        await using var seed = fixture.NewContext();
        await seed.Database.ExecuteSqlRawAsync("""
            INSERT INTO public.staff
                (staff_code, staff_full_name, job_title, security_level, password, date_hired, sin)
            VALUES
                ('T201', 'Legacy Optician', '202', 4, 'OPT1', now(), '000000201'),
                ('T202', 'Legacy Owner', '101', 1, 'OWN1', now(), '000000202'),
                ('T203', 'Legacy Clerk', '102', 3, 'CLK1', now(), '000000203')
            ON CONFLICT (staff_code) DO UPDATE
            SET job_title = excluded.job_title,
                security_level = excluded.security_level,
                password = excluded.password,
                staff_full_name = excluded.staff_full_name;
            """);
    }

    private static async Task<JsonElement> JsonAsync(HttpResponseMessage response)
    {
        using var document = JsonDocument.Parse(await response.Content.ReadAsStringAsync());
        return document.RootElement.Clone();
    }

    [Theory]
    [InlineData("T201", "OPT1", "prescription:view", true)]
    [InlineData("T201", "OPT1", "report:financial", false)]
    [InlineData("T202", "OWN1", "staff:pii", true)]
    [InlineData("T203", "CLK1", "sales:order-create", true)]
    [InlineData("T203", "CLK1", "report:financial", false)]
    public async Task LegacyStaffSignIn_MapsJobTitleToApprovedRole(
        string code, string password, string permission, bool expected)
    {
        await SeedStaffAsync();
        var factory = new XOptiApiFactory(fixture);
        using var client = new TestClient(factory);
        await client.FetchCsrfTokenAsync();

        var signIn = await client.SignInAsync(code, password);
        Assert.Equal(HttpStatusCode.OK, signIn.Status);

        var me = await client.GetAsync("/api/v1/auth/me");
        Assert.Equal(HttpStatusCode.OK, me.StatusCode);
        var body = await JsonAsync(me);
        var permissions = body.GetProperty("permissions").EnumerateArray()
            .Select(item => item.GetString()).ToList();
        Assert.Equal(expected, permissions.Contains(permission));

        await using var verify = fixture.NewContext();
        var user = await verify.Users.SingleAsync(row => row.UserName == code);
        Assert.True(string.IsNullOrEmpty(user.PasswordHash),
            "Legacy plaintext passwords must not be copied into the Identity password hash.");
    }

    [Fact]
    public async Task LegacyStaffSignIn_RejectsWrongPassword()
    {
        await SeedStaffAsync();
        var factory = new XOptiApiFactory(fixture);
        using var client = new TestClient(factory);
        await client.FetchCsrfTokenAsync();

        var signIn = await client.SignInAsync("T201", "WRONG");
        Assert.Equal(HttpStatusCode.Unauthorized, signIn.Status);
    }
}
