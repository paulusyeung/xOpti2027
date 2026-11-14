using System.Net;
using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using xOpti.Api.IntegrationTests.Support;

namespace xOpti.Api.IntegrationTests;

[Collection("api")]
public sealed class ReconciliationAndPermissionTests(ApiPostgresFixture fixture)
{
    private async Task<TestClient> SignInAsync(string user)
    {
        var client = new TestClient(new XOptiApiFactory(fixture));
        await client.FetchCsrfTokenAsync();
        Assert.Equal(HttpStatusCode.OK, (await client.SignInAsync(user, SeedData.Password)).Status);
        return client;
    }

    private static async Task<List<string>> ApiKeys(TestClient client, string path, string property)
    {
        var response = await client.GetAsync(path);
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        using var body = JsonDocument.Parse(await response.Content.ReadAsStringAsync());
        return body.RootElement.GetProperty("items").EnumerateArray()
            .Select(item => item.GetProperty(property).GetString()!)
            .ToList();
    }

    [Fact]
    public async Task DirectoryFirstPages_MatchTheMigratedTables()
    {
        await using (var seed = fixture.NewContext())
        {
            await seed.Database.ExecuteSqlRawAsync("""
                INSERT INTO public.category (department_code, class_code, category_code, category_name,
                    costing_method, inventory_method, tax_method)
                VALUES ('01','01','01','Default','1','1','1')
                ON CONFLICT (department_code, class_code, category_code) DO NOTHING;
                INSERT INTO public.supplier (supplier_code, supplier_name)
                VALUES ('0001','Seed Supplier') ON CONFLICT (supplier_code) DO NOTHING;
                INSERT INTO public.brand (brand_code, brand_description)
                VALUES ('0001','Seed Brand') ON CONFLICT (brand_code) DO NOTHING;
                """);
        }

        using var manager = await SignInAsync("manager");

        var skuKeys = await ApiKeys(manager, "/api/v1/admin/skus?pageSize=5", "sku");
        List<string> sqlSkus;
        await using (var context = fixture.NewContext())
        {
            var retired = context.EntityRetirements.Where(r => r.EntityType == "Inventory").Select(r => r.EntityKey);
            sqlSkus = await context.InventoryItems.AsNoTracking()
                .Where(i => !retired.Contains(i.Sku)).OrderBy(i => i.Sku).Take(5)
                .Select(i => i.Sku).ToListAsync();
        }
        Assert.Equal(sqlSkus, skuKeys);

        var supplierKeys = await ApiKeys(manager, "/api/v1/admin/suppliers?pageSize=5", "supplierCode");
        List<string> sqlSuppliers;
        await using (var context = fixture.NewContext())
        {
            sqlSuppliers = await context.Suppliers.AsNoTracking().OrderBy(s => s.SupplierCode).Take(5)
                .Select(s => s.SupplierCode).ToListAsync();
        }
        Assert.Equal(sqlSuppliers, supplierKeys);

        var staffKeys = await ApiKeys(manager, "/api/v1/admin/staff?pageSize=5", "userName");
        List<string> sqlStaff;
        await using (var context = fixture.NewContext())
        {
            sqlStaff = await context.Users.AsNoTracking().OrderBy(u => u.UserName).Take(5)
                .Select(u => u.UserName!).ToListAsync();
        }
        Assert.Equal(sqlStaff, staffKeys);

        var branchKeys = await ApiKeys(manager, "/api/v1/branches?pageSize=5", "branchCode");
        List<string> sqlBranches;
        await using (var context = fixture.NewContext())
        {
            var retired = context.EntityRetirements.Where(r => r.EntityType == "Branch").Select(r => r.EntityKey);
            sqlBranches = await context.Branches.AsNoTracking()
                .Where(b => !retired.Contains(b.BranchCode)).OrderBy(b => b.BranchCode).Take(5)
                .Select(b => b.BranchCode).ToListAsync();
        }
        Assert.Equal(sqlBranches, branchKeys);
    }

    [Theory]
    [InlineData("/api/v1/admin/staff")]
    [InlineData("/api/v1/admin/roles")]
    [InlineData("/api/v1/admin/permissions")]
    [InlineData("/api/v1/admin/reference/Brand")]
    [InlineData("/api/v1/admin/suppliers")]
    [InlineData("/api/v1/admin/doctors")]
    [InlineData("/api/v1/admin/skus")]
    [InlineData("/api/v1/admin/preferences")]
    [InlineData("/api/v1/admin/skus/30110359/prices")]
    [InlineData("/api/v1/inventory/30110359")]
    public async Task AdministrativeEndpoints_RequireTheirNamedPermission(string path)
    {
        using var clerk = await SignInAsync("clerk");
        Assert.Equal(HttpStatusCode.Forbidden, (await clerk.GetAsync(path)).StatusCode);

        using var manager = await SignInAsync("manager");
        Assert.NotEqual(HttpStatusCode.Forbidden, (await manager.GetAsync(path)).StatusCode);
    }
}
