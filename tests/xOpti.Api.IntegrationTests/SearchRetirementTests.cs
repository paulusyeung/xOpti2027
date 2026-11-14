using System.Net;
using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using xOpti.Api.IntegrationTests.Support;
using xOpti.Application.Inventory.Catalogue;
using xOpti.Infrastructure;

namespace xOpti.Api.IntegrationTests;

[Collection("api")]
public sealed class SearchRetirementTests(ApiPostgresFixture fixture)
{
    private async Task<TestClient> ManagerAsync()
    {
        var client = new TestClient(new XOptiApiFactory(fixture));
        await client.FetchCsrfTokenAsync();
        Assert.Equal(HttpStatusCode.OK, (await client.SignInAsync("manager", SeedData.Password)).Status);
        return client;
    }

    [Fact]
    public async Task SearchIndexes_Exist_AndAreUsedForTrigramSearches()
    {
        await using var context = fixture.NewContext();
        await context.Database.OpenConnectionAsync();
        foreach (var index in new[]
                 {
                     "ix_inventory_name_trgm", "ix_supplier_name_trgm", "ix_doctor_name_trgm",
                     "ix_staff_fullname_trgm", "ix_branch_name_trgm",
                 })
        {
            Assert.True(await context.Database
                .SqlQuery<int>($"SELECT count(*)::int AS \"Value\" FROM pg_indexes WHERE indexname = {index}")
                .SingleAsync() == 1, $"missing index {index}");
        }

        await context.Database.ExecuteSqlRawAsync("SET enable_seqscan = off");
        var plan = await context.Database
            .SqlQuery<string>($"EXPLAIN SELECT sku FROM public.inventory WHERE lower(name) LIKE '%frame%'")
            .ToListAsync();
        Assert.Contains(plan, line => line.Contains("ix_inventory_name_trgm", StringComparison.OrdinalIgnoreCase));
    }

    [Fact]
    public async Task CatalogueDeepPages_DoNotRepeatOrSkip()
    {
        var prefix = "8" + Guid.NewGuid().ToString("N")[..4];
        await using (var context = fixture.NewContext())
        {
            for (var i = 0; i < 12; i++)
            {
                var sku = $"{prefix}{i:D4}";
                await context.Database.ExecuteSqlInterpolatedAsync($"""
                    INSERT INTO public.inventory (sku, department_code, class_code, category_code,
                        supplier_code, brand_code, name, qty_total_on_hand,
                        inventory_lot_flag, retail_price_flag, whole_sale_price_flag)
                    VALUES ({sku}, '01', '01', '01', '0001', '0001', {prefix + " item"}, 0, false, false, false)
                    ON CONFLICT (sku) DO NOTHING
                    """);
            }
        }

        using var manager = await ManagerAsync();
        var seen = new List<string>();
        string? cursor = null;
        do
        {
            var suffix = cursor is null ? string.Empty : $"&cursor={cursor}";
            var response = await manager.GetAsync($"/api/v1/admin/skus?search={prefix}&pageSize=4{suffix}");
            Assert.Equal(HttpStatusCode.OK, response.StatusCode);
            using var body = JsonDocument.Parse(await response.Content.ReadAsStringAsync());
            seen.AddRange(body.RootElement.GetProperty("items").EnumerateArray()
                .Select(item => item.GetProperty("sku").GetString()!));
            cursor = body.RootElement.GetProperty("nextCursor").GetString();
        } while (cursor is not null);

        Assert.Equal(12, seen.Count);
        Assert.Equal(12, seen.Distinct().Count());
    }

    [Fact]
    public async Task MasterDataMutations_EmitOneAllowListedAuditWithoutContactPii()
    {
        using var manager = await ManagerAsync();
        var code = Guid.NewGuid().ToString("N")[..4].ToUpperInvariant();
        const string phone = "604-555-9999";

        var create = await manager.PostAsync("/api/v1/admin/suppliers", new
        {
            supplierCode = code,
            name = "Audit Supplier",
            phone,
            reason = "audit probe",
        });
        Assert.Equal(HttpStatusCode.Created, create.StatusCode);

        await using var context = fixture.NewContext();
        var entries = await context.AuditLogs.Where(row =>
            row.EntityType == "Supplier" && row.EntityId == code).ToListAsync();
        var entry = Assert.Single(entries);
        Assert.Equal("supplier.create", entry.Action);
        Assert.Contains("audit probe", entry.Details);
        Assert.DoesNotContain(phone, entry.Details);
        Assert.DoesNotContain("@", entry.Details);
    }

    [Fact]
    public async Task RetiredSku_LeavesSelectionButKeepsHistory()
    {
        var sku = "7" + Guid.NewGuid().ToString("N")[..8];
        await using (var context = fixture.NewContext())
        {
            await context.Database.ExecuteSqlInterpolatedAsync($"""
                INSERT INTO public.inventory (sku, department_code, class_code, category_code,
                    supplier_code, brand_code, name, qty_total_on_hand,
                    inventory_lot_flag, retail_price_flag, whole_sale_price_flag)
                VALUES ({sku}, '01', '01', '01', '0001', '0001', 'Retirement Probe', 0, false, false, false)
                """);
        }

        var services = new ServiceCollection();
        services.AddXOptiInfrastructure(new InfrastructureOptions { ConnectionString = fixture.ConnectionString });
        await using var provider = services.BuildServiceProvider();
        using var scope = provider.CreateScope();
        var store = scope.ServiceProvider.GetRequiredService<ICatalogueStore>();

        Assert.NotNull(await store.FindForSelectionAsync(sku, CancellationToken.None));
        await store.RetireAsync(sku, "obsolete", "test", CancellationToken.None);

        Assert.Null(await store.FindForSelectionAsync(sku, CancellationToken.None));
        Assert.NotNull(await store.FindAsync(sku, CancellationToken.None)); // history still resolves
    }
}
