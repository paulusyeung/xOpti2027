using System.Diagnostics;
using Microsoft.EntityFrameworkCore;
using xOpti.Application.Reporting;
using xOpti.Infrastructure.Repositories;
using xOpti.Infrastructure.Tests.Support;

namespace xOpti.Infrastructure.Tests;

[Collection("postgres")]
public class ReportPerformanceTests(PostgresFixture fixture)
{
    [Fact]
    public async Task ProductionSizedListing_IsCappedWithinInteractionBudget()
    {
        await using (var seed = fixture.NewContext())
        {
            await seed.Database.ExecuteSqlRawAsync("""
                INSERT INTO public.inventory
                    (sku, department_code, class_code, category_code, supplier_code, brand_code,
                     name, qty_total_on_hand, average_cost, inventory_lot_flag,
                     retail_price_flag, whole_sale_price_flag)
                SELECT 'PF' || lpad(value::text, 11, '0'), '09', '09', '09', '0001', '0001',
                       'Performance item', 1, 1.0000, true, true, false
                FROM generate_series(1, 25000) AS value
                ON CONFLICT (sku) DO NOTHING;
                """);
        }

        var entry = ReportCatalogueData.All.Single(item => item.Id == "RPT-026");
        var definition = ReportReadModels.Get(entry.ReadModel);
        var parameters = ReportParameterValues.Bind(entry,
            new Dictionary<string, string?>());
        await using var context = fixture.NewContext();
        var store = new EfReportDataStore(context);

        var stopwatch = Stopwatch.StartNew();
        var page = await store.QueryAsync(definition, entry.RowCap, parameters, default);
        stopwatch.Stop();

        Assert.True(page.Truncated);
        Assert.Equal(entry.RowCap, page.Rows.Count);
        Assert.True(stopwatch.Elapsed < TimeSpan.FromSeconds(10),
            $"Report listing took {stopwatch.Elapsed}.");
    }
}
