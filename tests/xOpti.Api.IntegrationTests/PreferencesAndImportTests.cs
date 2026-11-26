using System.Net;
using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using xOpti.Api.IntegrationTests.Support;

namespace xOpti.Api.IntegrationTests;

[Collection("api")]
public sealed class PreferencesAndImportTests(ApiPostgresFixture fixture)
{
    private async Task<TestClient> ManagerAsync()
    {
        var client = new TestClient(new XOptiApiFactory(fixture));
        await client.FetchCsrfTokenAsync();
        Assert.Equal(HttpStatusCode.OK, (await client.SignInAsync("manager", SeedData.Password)).Status);
        return client;
    }

    private static async Task<JsonElement> BodyAsync(HttpResponseMessage response)
    {
        using var document = JsonDocument.Parse(await response.Content.ReadAsStringAsync());
        return document.RootElement.Clone();
    }

    private async Task SeedAsync()
    {
        await using var context = fixture.NewContext();
        await context.Database.ExecuteSqlRawAsync("""
            INSERT INTO public.pref_tx_number (tx_prefix, tx_next_number, description, value) VALUES
                ('RC', 1, 'Retail Invoice', '+ve'), ('RS', 1, 'Refund', '-ve'),
                ('SR', 1, 'Received', '+ve'), ('RJ', 1, 'Rejected', '-ve'),
                ('SJ', 1, 'Adjustment', '+/-'), ('WC', 1, 'Wholesale', '+ve'),
                ('WR', 1, 'Wholesale return', '-ve'), ('SA', 1, 'Sales order', '+ve'),
                ('LA', 1, 'Layaway', '+ve'), ('PR', 1, 'Purchase order', '+ve'),
                ('QT', 1, 'Quotation', '+ve'), ('TN', 1, 'Transfer in', '+ve'),
                ('TU', 1, 'Transfer out', '-ve')
            ON CONFLICT (tx_prefix) DO NOTHING;
            INSERT INTO public.city (code, city_name, province_code, country_code)
            VALUES (999, 'TESTVILLE', 'BC', 'CA') ON CONFLICT (code) DO NOTHING;
            INSERT INTO public.country (country_code, country_name)
            VALUES ('CA', 'CANADA') ON CONFLICT DO NOTHING;
            """);
    }

    [Fact]
    public async Task Preferences_ShowAllFamilies_AndUpdatesAreAuditedWithoutTouchingCounters()
    {
        await SeedAsync();
        using var manager = await ManagerAsync();

        var response = await manager.GetAsync("/api/v1/admin/preferences");
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        var data = await BodyAsync(response);
        Assert.Equal(13, data.GetProperty("counters").GetArrayLength());
        Assert.Empty(data.GetProperty("missingFamilies").EnumerateArray());
        Assert.Contains(
            data.GetProperty("requiredFamilies").EnumerateArray().Select(f => f.GetString()),
            family => family == "RC");

        long transactionsBefore;
        await using (var context = fixture.NewContext())
        {
            transactionsBefore = await context.TxHeaders.LongCountAsync();
        }

        var update = await manager.PutAsync("/api/v1/admin/preferences", new
        {
            productName = "Synergy",
            userName = "Operator",
            userAddress = "1 Main St",
            ownerName = "Owner",
            ownerAddress = "2 Main St",
            gstNumber = "123456789",
            pstNumber = "987654321",
            userPhone = "(604) 111-2222",
            userFax = "(604) 333-4444",
            ownerPhone = "(604) 555-6666",
            ownerFax = "(604) 777-8888",
            userCityCode = 999,
            userProvince = "BC",
            userPostalCode = "V6E 1B2",
            userCountryCode = "CA",
            taxARate = 6.0,
            taxBRate = 8.0,
            reason = "rate change",
        });
        Assert.Equal(HttpStatusCode.OK, update.StatusCode);
        var updated = await BodyAsync(update);
        Assert.Equal(6.0, updated.GetProperty("taxARate").GetDouble());
        Assert.Equal("(604) 111-2222", updated.GetProperty("userPhone").GetString());
        Assert.Equal("(604) 333-4444", updated.GetProperty("userFax").GetString());
        Assert.Equal(999, updated.GetProperty("userCityCode").GetInt32());

        var reread = (await BodyAsync(await manager.GetAsync("/api/v1/admin/preferences")))
            .GetProperty("preferences");
        Assert.Equal("TESTVILLE", reread.GetProperty("userCityName").GetString());
        Assert.Equal("CANADA", reread.GetProperty("userCountryName").GetString());

        await using (var context = fixture.NewContext())
        {
            Assert.Equal(transactionsBefore, await context.TxHeaders.LongCountAsync());
            Assert.True(await context.AuditLogs.AnyAsync(row =>
                row.Action == "preference.update" && row.Details!.Contains("rate change")));
            Assert.Equal(13, await context.PrefTxNumbers.CountAsync());
        }
    }

    [Fact]
    public async Task Import_DryRunWritesNothing_AndConfirmationReportsCounts()
    {
        using var manager = await ManagerAsync();
        var code = Guid.NewGuid().ToString("N")[..4].ToUpperInvariant();

        int before;
        await using (var context = fixture.NewContext())
        {
            before = await context.Suppliers.CountAsync();
        }

        var invalid = await manager.PostAsync("/api/v1/admin/import", new
        {
            kind = "Supplier",
            csv = $"supplierCode,name\n{code},",
            dryRun = true,
            reason = "invalid import",
        });
        Assert.Equal(HttpStatusCode.OK, invalid.StatusCode);
        var invalidBody = await BodyAsync(invalid);
        Assert.NotEmpty(invalidBody.GetProperty("errors").EnumerateArray());
        Assert.Equal(2, invalidBody.GetProperty("resumeFrom").GetInt32());

        await using (var context = fixture.NewContext())
        {
            Assert.Equal(before, await context.Suppliers.CountAsync());
        }

        var dryRun = await manager.PostAsync("/api/v1/admin/import", new
        {
            kind = "Supplier",
            csv = $"supplierCode,name\n{code},Imported Supplier",
            dryRun = true,
            reason = "dry run",
        });
        Assert.Equal(1, (await BodyAsync(dryRun)).GetProperty("created").GetInt32());
        await using (var context = fixture.NewContext())
        {
            Assert.Equal(before, await context.Suppliers.CountAsync());
        }

        var confirm = await manager.PostAsync("/api/v1/admin/import", new
        {
            kind = "Supplier",
            csv = $"supplierCode,name\n{code},Imported Supplier",
            dryRun = false,
            reason = "confirmed import",
        });
        Assert.Equal(1, (await BodyAsync(confirm)).GetProperty("created").GetInt32());

        await using (var context = fixture.NewContext())
        {
            Assert.True(await context.Suppliers.AnyAsync(row => row.SupplierCode == code));
            Assert.True(await context.AuditLogs.AnyAsync(row =>
                row.Action == "master-data.import" && row.Details!.Contains("confirmed import")));
        }
    }
}
