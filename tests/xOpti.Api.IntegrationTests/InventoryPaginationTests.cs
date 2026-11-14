using System.Net;
using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using xOpti.Api.IntegrationTests.Support;

namespace xOpti.Api.IntegrationTests;

[Collection("api")]
public sealed class InventoryPaginationTests(ApiPostgresFixture fixture)
{
    private async Task<TestClient> ManagerAsync()
    {
        var client = new TestClient(new XOptiApiFactory(fixture));
        await client.FetchCsrfTokenAsync();
        Assert.Equal(HttpStatusCode.OK, (await client.SignInAsync("manager", SeedData.Password)).Status);
        return client;
    }

    [Fact]
    public async Task ProductionSizedCatalogue_PagesDeeplyWithoutRepeatsAndUsesTheTrigramIndex()
    {
        var prefix = "P" + Guid.NewGuid().ToString("N")[..5].ToUpperInvariant();
        await using (var seed = fixture.NewContext())
        {
            await seed.Database.ExecuteSqlInterpolatedAsync($"""
                INSERT INTO public.inventory (sku, department_code, class_code, category_code,
                    supplier_code, brand_code, name, qty_total_on_hand,
                    inventory_lot_flag, retail_price_flag, whole_sale_price_flag)
                SELECT {prefix} || lpad(i::text, 7, '0'), '01', '01', '01', '0001', '0001',
                       {prefix + " probe item"}, 0, false, false, false
                FROM generate_series(1, 1000) AS i
                ON CONFLICT (sku) DO NOTHING
                """);

            await using var connection = new Npgsql.NpgsqlConnection(fixture.ConnectionString);
            await connection.OpenAsync();
            await using (var set = connection.CreateCommand())
            {
                set.CommandText = "SET enable_seqscan = off";
                await set.ExecuteNonQueryAsync();
            }

            await using var explain = connection.CreateCommand();
            explain.CommandText =
                "EXPLAIN SELECT count(*) FROM public.inventory WHERE name ILIKE '%probe item%'";
            var plan = new List<string>();
            await using var reader = await explain.ExecuteReaderAsync();
            while (await reader.ReadAsync()) plan.Add(reader.GetString(0));
            Assert.Contains(plan, line => line.Contains("ix_inventory_name_trgm_raw", StringComparison.OrdinalIgnoreCase));
        }

        using var manager = await ManagerAsync();
        var seen = new List<string>();
        string? cursor = null;
        do
        {
            var suffix = cursor is null ? string.Empty : $"&cursor={cursor}";
            var response = await manager.GetAsync(
                $"/api/v1/admin/skus?search={prefix.ToLowerInvariant()}&pageSize=25{suffix}");
            Assert.Equal(HttpStatusCode.OK, response.StatusCode);
            using var body = JsonDocument.Parse(await response.Content.ReadAsStringAsync());
            seen.AddRange(body.RootElement.GetProperty("items").EnumerateArray()
                .Select(item => item.GetProperty("sku").GetString()!));
            cursor = body.RootElement.GetProperty("nextCursor").GetString();
        } while (cursor is not null);

        Assert.Equal(1000, seen.Count);
        Assert.Equal(1000, seen.Distinct().Count());
        Assert.Equal(seen.OrderBy(s => s, StringComparer.Ordinal), seen); // stable keyset order
    }
}
