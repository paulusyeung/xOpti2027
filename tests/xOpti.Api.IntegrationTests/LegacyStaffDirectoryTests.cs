using System.Net;
using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using xOpti.Api.IntegrationTests.Support;

namespace xOpti.Api.IntegrationTests;

[Collection("api")]
public sealed class LegacyStaffDirectoryTests(ApiPostgresFixture fixture)
{
    private async Task<TestClient> SignInAsync(string user)
    {
        var client = new TestClient(new XOptiApiFactory(fixture));
        await client.FetchCsrfTokenAsync();
        var outcome = await client.SignInAsync(user, SeedData.Password);
        Assert.Equal(HttpStatusCode.OK, outcome.Status);
        return client;
    }

    private async Task SeedAsync()
    {
        await using var context = fixture.NewContext();
        await context.Database.ExecuteSqlRawAsync("""
            INSERT INTO public.job_title (job_title_code, job_title)
            VALUES ('T99', 'Test Role')
            ON CONFLICT (job_title_code) DO NOTHING;

            INSERT INTO public.staff
                (staff_code, staff_first_name, staff_last_name, job_title,
                 security_level, password, date_hired, sin)
            VALUES
                ('T99', 'Directory', 'Probe', 'T99', 5, 'PROBE', now(), '999999999')
            ON CONFLICT (staff_code) DO UPDATE
            SET staff_first_name = excluded.staff_first_name,
                staff_last_name = excluded.staff_last_name,
                job_title = excluded.job_title;
            """);
    }

    [Fact]
    public async Task Directory_ExposesLegacyStaffColumns()
    {
        await SeedAsync();
        using var manager = await SignInAsync("manager");

        var response = await manager.GetAsync("/api/v1/admin/staff/directory?pageSize=50");
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);

        using var document = JsonDocument.Parse(await response.Content.ReadAsStringAsync());
        var item = document.RootElement.GetProperty("items").EnumerateArray()
            .Single(row => row.GetProperty("code").GetString() == "T99");

        Assert.Equal("Directory", item.GetProperty("firstName").GetString());
        Assert.Equal("Probe", item.GetProperty("lastName").GetString());
        Assert.Equal("T99", item.GetProperty("jobTitle").GetString());
        Assert.Equal("Test Role", item.GetProperty("jobTitleName").GetString());
    }
}
