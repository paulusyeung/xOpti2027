using System.Net;
using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using xOpti.Api.IntegrationTests.Support;

namespace xOpti.Api.IntegrationTests;

[Collection("api")]
public sealed class ReferenceDirectoryTests(ApiPostgresFixture fixture)
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
        var connection = context.Database.GetDbConnection();
        await connection.OpenAsync();
        await using var command = connection.CreateCommand();
        command.CommandText = """
            INSERT INTO public.brand (brand_code, brand_description) VALUES
                ('Z1', 'Zenith Frames'),
                ('Z2', 'zenith optics'),
                ('Z3', 'Other Brand')
            ON CONFLICT (brand_code) DO NOTHING;

            INSERT INTO public.material (material_code, material_description) VALUES
                ('Z1', 'Zyl'),
                ('Z2', 'Titanium')
            ON CONFLICT (material_code) DO NOTHING;

            INSERT INTO public.category (department_code, class_code, category_code,
                category_name, costing_method, inventory_method, tax_method)
            VALUES ('Z1', 'Z2', 'Z3', 'Zeta Category', '1', '1', '1')
            ON CONFLICT (department_code, class_code, category_code) DO NOTHING;
            """;
        await command.ExecuteNonQueryAsync();
    }

    [Fact]
    public async Task BrandDirectory_IsCaseInsensitive_AndKeysetPaged()
    {
        await SeedAsync();
        using var manager = await SignInAsync("manager");

        var first = await manager.GetAsync("/api/v1/admin/reference/Brand?search=ZENITH&pageSize=1");
        Assert.Equal(HttpStatusCode.OK, first.StatusCode);
        using var firstBody = JsonDocument.Parse(await first.Content.ReadAsStringAsync());
        var firstItem = Assert.Single(firstBody.RootElement.GetProperty("items").EnumerateArray());
        Assert.Equal("Z1", firstItem.GetProperty("key").GetString());
        var cursor = firstBody.RootElement.GetProperty("nextCursor").GetString();
        Assert.NotNull(cursor);

        var second = await manager.GetAsync($"/api/v1/admin/reference/Brand?search=ZENITH&pageSize=1&cursor={cursor}");
        using var secondBody = JsonDocument.Parse(await second.Content.ReadAsStringAsync());
        var secondItem = Assert.Single(secondBody.RootElement.GetProperty("items").EnumerateArray());
        Assert.Equal("Z2", secondItem.GetProperty("key").GetString());
        Assert.Equal(JsonValueKind.Null, secondBody.RootElement.GetProperty("nextCursor").ValueKind);
    }

    [Fact]
    public async Task CompositeCategoryKey_IsExposedWithItsParent()
    {
        await SeedAsync();
        using var manager = await SignInAsync("manager");

        var response = await manager.GetAsync("/api/v1/admin/reference/Category?search=zeta");
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);

        using var body = JsonDocument.Parse(await response.Content.ReadAsStringAsync());
        var item = Assert.Single(body.RootElement.GetProperty("items").EnumerateArray());
        Assert.Equal("Z1/Z2/Z3", item.GetProperty("key").GetString());
        Assert.Equal("Z1/Z2", item.GetProperty("parent").GetString());
        Assert.Contains("costing 1", item.GetProperty("detail").GetString());
    }

    [Theory]
    [InlineData("City")]
    [InlineData("Province")]
    [InlineData("Country")]
    [InlineData("Department")]
    [InlineData("Class")]
    [InlineData("Category")]
    [InlineData("Brand")]
    [InlineData("Material")]
    [InlineData("TaxMethod")]
    [InlineData("PaymentMethod")]
    public async Task EveryKind_IsQueryable(string kind)
    {
        using var manager = await SignInAsync("manager");

        var response = await manager.GetAsync($"/api/v1/admin/reference/{kind}?pageSize=5");

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        using var body = JsonDocument.Parse(await response.Content.ReadAsStringAsync());
        Assert.Equal(JsonValueKind.Array, body.RootElement.GetProperty("items").ValueKind);
    }

    [Fact]
    public async Task ReferenceDirectory_RequiresMasterDataPermission()
    {
        using var clerk = await SignInAsync("clerk");

        var response = await clerk.GetAsync("/api/v1/admin/reference/Brand");

        Assert.Equal(HttpStatusCode.Forbidden, response.StatusCode);
    }
}
