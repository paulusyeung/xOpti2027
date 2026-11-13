using System.Net;
using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using xOpti.Api.IntegrationTests.Support;

namespace xOpti.Api.IntegrationTests;

[Collection("api")]
public sealed class ReferenceMutationTests(ApiPostgresFixture fixture)
{
    private async Task<TestClient> SignInAsync(string user)
    {
        var client = new TestClient(new XOptiApiFactory(fixture));
        await client.FetchCsrfTokenAsync();
        var outcome = await client.SignInAsync(user, SeedData.Password);
        Assert.Equal(HttpStatusCode.OK, outcome.Status);
        return client;
    }

    private static async Task<JsonElement> BodyAsync(HttpResponseMessage response)
    {
        using var document = JsonDocument.Parse(await response.Content.ReadAsStringAsync());
        return document.RootElement.Clone();
    }

    private static string UniqueKey(string prefix) => prefix + Guid.NewGuid().ToString("N")[..3].ToUpperInvariant();

    [Fact]
    public async Task CreateUpdateRetire_IsAuditedAndRemovedFromLists()
    {
        using var manager = await SignInAsync("manager");
        var key = UniqueKey("W");

        var create = await manager.PostAsync("/api/v1/admin/reference/Brand", new
        {
            key,
            name = "Mutation Brand",
            reason = "seed a brand",
        });
        Assert.Equal(HttpStatusCode.Created, create.StatusCode);

        var duplicate = await manager.PostAsync("/api/v1/admin/reference/Brand", new
        {
            key,
            name = "Duplicate",
            reason = "duplicate probe",
        });
        Assert.Equal(HttpStatusCode.BadRequest, duplicate.StatusCode);
        var duplicateBody = await BodyAsync(duplicate);
        Assert.Contains(
            duplicateBody.GetProperty("errors").EnumerateArray().Select(error => error.GetProperty("field").GetString()),
            field => field == "Key");

        var update = await manager.PutAsync("/api/v1/admin/reference/Brand", new
        {
            key,
            name = "Renamed Brand",
            reason = "rename",
        });
        Assert.Equal(HttpStatusCode.OK, update.StatusCode);
        Assert.Equal("Renamed Brand", (await BodyAsync(update)).GetProperty("name").GetString());

        var retire = await manager.PostAsync("/api/v1/admin/reference/Brand/retire", new
        {
            key,
            reason = "obsolete brand",
            confirmReferenced = false,
        });
        Assert.Equal(HttpStatusCode.OK, retire.StatusCode);

        var list = await manager.GetAsync($"/api/v1/admin/reference/Brand?search=Renamed");
        using var listBody = JsonDocument.Parse(await list.Content.ReadAsStringAsync());
        Assert.Empty(listBody.RootElement.GetProperty("items").EnumerateArray());

        await using var context = fixture.NewContext();
        Assert.True(await context.AuditLogs.AnyAsync(row =>
            row.EntityId == key && row.Action == "reference.create" && row.Details!.Contains("seed a brand")));
        Assert.True(await context.AuditLogs.AnyAsync(row =>
            row.EntityId == key && row.Action == "reference.retire" && row.Details!.Contains("obsolete brand")));
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
    public async Task EveryReferenceKind_CreatesUpdatesAndRetires(string kind)
    {
        using var manager = await SignInAsync("manager");
        var suffix = Guid.NewGuid().ToString("N")[..6].ToUpperInvariant();
        var (key, parent) = kind switch
        {
            "City" => ((400000 + Random.Shared.Next(100000)).ToString(), (string?)"BC/CA"),
            "Province" => (suffix[..2], (string?)null),
            "Country" => (suffix[..3], (string?)null),
            "Department" => (suffix[..2], (string?)null),
            "Class" => ($"{suffix[..2]}/{suffix[2..4]}", (string?)null),
            "Category" => ($"{suffix[..2]}/{suffix[2..4]}/{suffix[4..6]}", (string?)null),
            "Brand" => (suffix[..4], (string?)null),
            "Material" => (suffix[..2], (string?)null),
            "TaxMethod" => (suffix[..1], (string?)null),
            _ => (suffix[..1], (string?)null),
        };

        var name = $"Z{suffix[..4]}";
        var create = await manager.PostAsync($"/api/v1/admin/reference/{kind}", new
        {
            key,
            name,
            parent,
            reason = "theory create",
            costingMethod = kind == "Category" ? "1" : null,
            inventoryMethod = kind == "Category" ? "1" : null,
            taxMethod = kind == "Category" ? "1" : null,
            paymentNameShort = kind == "PaymentMethod" ? "PAY" : null,
            exchangeRate = kind == "PaymentMethod" ? 1.0 : (double?)null,
        });
        Assert.True(create.IsSuccessStatusCode, $"{kind} create: {await create.Content.ReadAsStringAsync()}");

        var update = await manager.PutAsync($"/api/v1/admin/reference/{kind}", new
        {
            key,
            name = $"Y{suffix[..4]}",
            parent,
            reason = "theory update",
            costingMethod = kind == "Category" ? "1" : null,
            inventoryMethod = kind == "Category" ? "1" : null,
            taxMethod = kind == "Category" ? "1" : null,
            paymentNameShort = kind == "PaymentMethod" ? "PAY" : null,
            exchangeRate = kind == "PaymentMethod" ? 1.0 : (double?)null,
        });
        Assert.True(update.IsSuccessStatusCode, $"{kind} update: {await update.Content.ReadAsStringAsync()}");

        var retire = await manager.PostAsync($"/api/v1/admin/reference/{kind}/retire", new
        {
            key,
            reason = "theory retire",
            confirmReferenced = false,
        });
        Assert.True(retire.IsSuccessStatusCode, $"{kind} retire: {await retire.Content.ReadAsStringAsync()}");
    }

    [Fact]
    public async Task ReferencedBrand_RequiresExplicitConfirmation()
    {
        using var manager = await SignInAsync("manager");
        var key = UniqueKey("R");

        var create = await manager.PostAsync("/api/v1/admin/reference/Brand", new
        {
            key,
            name = "Referenced Brand",
            reason = "referenced probe",
        });
        Assert.Equal(HttpStatusCode.Created, create.StatusCode);

        await using (var context = fixture.NewContext())
        {
            await context.Database.ExecuteSqlInterpolatedAsync(
                $"UPDATE public.inventory SET brand_code = {key} WHERE sku = '30110359'");
        }

        var blocked = await manager.PostAsync("/api/v1/admin/reference/Brand/retire", new
        {
            key,
            reason = "try without confirm",
            confirmReferenced = false,
        });
        Assert.Equal(HttpStatusCode.BadRequest, blocked.StatusCode);
        var blockedBody = await BodyAsync(blocked);
        Assert.Contains(
            blockedBody.GetProperty("errors").EnumerateArray().Select(error => error.GetProperty("field").GetString()),
            field => field == "ConfirmReferenced");

        var confirmed = await manager.PostAsync("/api/v1/admin/reference/Brand/retire", new
        {
            key,
            reason = "approved retirement",
            confirmReferenced = true,
        });
        Assert.Equal(HttpStatusCode.OK, confirmed.StatusCode);

        await using (var context = fixture.NewContext())
        {
            Assert.True(await context.EntityRetirements.AnyAsync(row =>
                row.EntityType == "Brand" && row.EntityKey == key && row.Reason == "approved retirement"));
        }
    }
}
