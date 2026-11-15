using System.Net;
using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using xOpti.Api.IntegrationTests.Support;

namespace xOpti.Api.IntegrationTests;

[Collection("api")]
public sealed class InventorySummaryTests(ApiPostgresFixture fixture)
{
    private async Task<TestClient> ManagerAsync()
    {
        var client = new TestClient(new XOptiApiFactory(fixture));
        await client.FetchCsrfTokenAsync();
        Assert.Equal(HttpStatusCode.OK, (await client.SignInAsync("manager", SeedData.Password)).Status);
        return client;
    }

    [Fact]
    public async Task SummaryReadModels_MatchPostedLines()
    {
        var tx = "SR" + Guid.NewGuid().ToString("N")[..8];
        await using (var seed = fixture.NewContext())
        {
            await seed.Database.ExecuteSqlInterpolatedAsync($"""
                INSERT INTO public.tx_header (control_number, tx_type, tx_number, date_of_entry)
                VALUES ('00000077', 'SR', {tx}, '2026-11-10');
                INSERT INTO public.tx_details (control_number, tx_type, tx_number, date_of_entry,
                    row_no, sku, qty, unit_amount, unit_cost, amount, tax_code)
                VALUES ('00000077', 'SR', {tx}, '2026-11-10', 1, '30110359', 5, 4.3650, 4.3650, 21.8250, 'N');
                """);
        }

        using var manager = await ManagerAsync();
        var response = await manager.GetAsync("/api/v1/inventory/summaries?from=2026-11-01&to=2026-11-30");
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        using var body = JsonDocument.Parse(await response.Content.ReadAsStringAsync());
        var groups = body.RootElement.GetProperty("groups").EnumerateArray().ToList();

        var inventoryRow = groups.Single(group => group.GetProperty("level").GetString() == "Inventory")
            .GetProperty("rows").EnumerateArray()
            .Single(row => row.GetProperty("key").GetString() == "30110359");
        Assert.Equal(5, inventoryRow.GetProperty("quantity").GetInt32());
        Assert.Equal(21.825m, inventoryRow.GetProperty("amount").GetDecimal());

        var departmentRow = groups.Single(group => group.GetProperty("level").GetString() == "Department")
            .GetProperty("rows").EnumerateArray()
            .Single(row => row.GetProperty("key").GetString() == "01");
        Assert.True(departmentRow.GetProperty("quantity").GetInt32() >= 5);
        Assert.True(departmentRow.GetProperty("amount").GetDecimal() >= 21.825m);
    }
}
