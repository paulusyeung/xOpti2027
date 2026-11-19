using System.Net;
using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using xOpti.Api.IntegrationTests.Support;
using xOpti.Domain.Values;
using xOpti.Infrastructure.Persistence.Entities;

namespace xOpti.Api.IntegrationTests;

[Collection("api")]
public sealed class ReportingTests(ApiPostgresFixture fixture)
{
    private static async Task<JsonElement> BodyAsync(HttpResponseMessage response,
        XOptiApiFactory factory, HttpStatusCode expected)
    {
        if (response.StatusCode != expected)
        {
            var exceptions = string.Join("\n", factory.Logs.Snapshot()
                .Where(entry => entry.Exception is not null)
                .Select(entry => entry.Exception!.ToString()));
            Assert.Fail($"{response.StatusCode}: {await response.Content.ReadAsStringAsync()}\n{exceptions}");
        }
        using var document = JsonDocument.Parse(await response.Content.ReadAsStringAsync());
        return document.RootElement.Clone();
    }

    private async Task<(int CustomerId, string Sku, string Invoice)> SeedAsync()
    {
        var customerId = Random.Shared.Next(995000, 995999);
        var sku = "RP" + Random.Shared.Next(10000000, 99999999);
        var invoice = "RC" + Random.Shared.Next(10000000, 99999999);
        var now = DateTimeOffset.UtcNow;
        await using var seed = fixture.NewContext();
        seed.Customers.Add(new Customer
        {
            Id = customerId, FullName = "Reporting Customer " + customerId,
            HomePhone = "6045550101", Email = "report@example.test",
        });
        seed.InventoryItems.Add(new Inventory
        {
            Sku = sku, DepartmentCode = "09", ClassCode = "09", CategoryCode = "09",
            SupplierCode = "0001", BrandCode = "0001", Name = "Report item",
            QtyTotalOnHand = 10, AverageCost = Money.From(5m),
            InventoryLotFlag = true, RetailPriceFlag = true,
        });
        seed.TxHeaders.Add(new TxHeader
        {
            TxNumber = invoice, ControlNumber = Random.Shared.Next(10000000, 99999999).ToString(),
            TxType = TransactionType.RetailInvoice, DateOfEntry = now, DateOfCreation = now,
            CustomerId = customerId, TotalSale = Money.From(20m), TaxA = Money.From(1m),
            TaxB = Money.From(1.4m), GrossSale = Money.From(22.4m),
            TotalAmount = Money.From(22.4m), TotalQty = 1, Status = "0",
        });
        seed.TxDetails.Add(new TxDetail
        {
            ControlNumber = "00000001", TxType = TransactionType.RetailInvoice,
            TxNumber = invoice, DateOfEntry = now, RowNo = 1, Sku = sku, Qty = 1,
            UnitAmount = Money.From(20m), UnitCost = Money.From(5m), UnitLsp = Money.From(4m),
            Amount = Money.From(20m), TaxCode = "B",
        });
        await seed.SaveChangesAsync();
        return (customerId, sku, invoice);
    }

    private static async Task<TestClient> ManagerAsync(XOptiApiFactory factory)
    {
        var client = new TestClient(factory);
        await client.FetchCsrfTokenAsync();
        Assert.Equal(HttpStatusCode.OK, (await client.SignInAsync("manager", SeedData.Password)).Status);
        return client;
    }

    [Fact]
    public async Task Catalogue_ListsEveryEffectiveReport_RejectsUnknownAndUnauthorized()
    {
        var factory = new XOptiApiFactory(fixture);
        using var manager = await ManagerAsync(factory);
        var catalogue = await BodyAsync(await manager.GetAsync("/api/v1/reports"),
            factory, HttpStatusCode.OK);
        var items = catalogue.EnumerateArray().ToList();
        Assert.True(items.Count >= 98);
        for (var index = 1; index <= 98; index++)
        {
            var id = $"RPT-{index:000}";
            var entry = items.Single(row => row.GetProperty("id").GetString() == id);
            Assert.Equal("provisional", entry.GetProperty("inScope").GetString());
            Assert.Equal("pending", entry.GetProperty("signoffStatus").GetString());
            Assert.False(string.IsNullOrWhiteSpace(entry.GetProperty("layoutKey").GetString()));
            Assert.False(string.IsNullOrWhiteSpace(entry.GetProperty("readModel").GetString()));
        }
        Assert.Contains(items, row => row.GetProperty("layoutKey").GetString() == "invoice");
        Assert.Contains(items, row => row.GetProperty("layoutKey").GetString() == "claim-receipt");
        Assert.Contains(items, row => row.GetProperty("layoutKey").GetString() == "rbic");
        Assert.Contains(items, row => row.GetProperty("layoutKey").GetString() == "statement");

        var unknown = await manager.PostAsync("/api/v1/reports/RPT-999/preview", new
        {
            parameters = new Dictionary<string, string?>(),
        });
        Assert.Equal(HttpStatusCode.BadRequest, unknown.StatusCode);
        Assert.Contains("not in the approved", await unknown.Content.ReadAsStringAsync());

        using var clerk = new TestClient(factory);
        await clerk.FetchCsrfTokenAsync();
        await clerk.SignInAsync("clerk", SeedData.Password);
        Assert.Equal(HttpStatusCode.Forbidden,
            (await clerk.GetAsync("/api/v1/reports")).StatusCode);
    }

    [Fact]
    public async Task PreviewPrintExport_UseReadModelsParametersAndAudit()
    {
        var (customerId, _, _) = await SeedAsync();
        var factory = new XOptiApiFactory(fixture);
        using var manager = await ManagerAsync(factory);

        var preview = await BodyAsync(await manager.PostAsync(
            "/api/v1/reports/RPT-014/preview", new
            {
                parameters = new Dictionary<string, string?>
                {
                    ["AskDays"] = "0", ["AskZeroPurchase"] = "true",
                },
            }), factory, HttpStatusCode.OK);
        Assert.Equal("RPT-014", preview.GetProperty("reportId").GetString());
        Assert.Contains(preview.GetProperty("rows").EnumerateArray(), row =>
            row.EnumerateArray().Any(value => value.ValueKind == JsonValueKind.Number
                && value.TryGetInt32(out var id) && id == customerId));

        var invalid = await manager.PostAsync("/api/v1/reports/RPT-071/preview", new
        {
            parameters = new Dictionary<string, string?>
            {
                ["AskDateFrom"] = "not-a-date", ["AskDateTo"] = "2026-01-01",
            },
        });
        Assert.Equal(HttpStatusCode.BadRequest, invalid.StatusCode);
        Assert.Contains("AskDateFrom", await invalid.Content.ReadAsStringAsync());

        var print = await manager.PostAsync("/api/v1/reports/RPT-014/print", new
        {
            parameters = new Dictionary<string, string?>
            {
                ["AskDays"] = "0", ["AskZeroPurchase"] = "true",
            },
            duplicate = true,
            terminalCode = "01",
            reason = "management report",
        });
        Assert.Equal(HttpStatusCode.OK, print.StatusCode);
        Assert.Equal("application/pdf", print.Content.Headers.ContentType?.MediaType);
        Assert.Contains("RPT-014-duplicate.pdf",
            print.Content.Headers.ContentDisposition?.FileName ?? string.Empty);

        var export = await manager.PostAsync("/api/v1/reports/RPT-014/export", new
        {
            parameters = new Dictionary<string, string?>
            {
                ["AskDays"] = "0", ["AskZeroPurchase"] = "true",
            },
            reason = "management export",
        });
        Assert.Equal(HttpStatusCode.OK, export.StatusCode);
        Assert.Contains("Customer", await export.Content.ReadAsStringAsync());

        await using var verify = fixture.NewContext();
        Assert.True(await verify.ReportRuns.AnyAsync(row =>
            row.CatalogueId == "RPT-014" && row.Duplicate));
        Assert.True(await verify.AuditLogs.AnyAsync(row =>
            row.Action == "report.reprint" && row.EntityId == "RPT-014"));
        Assert.True(await verify.AuditLogs.AnyAsync(row =>
            row.Action == "report.export" && row.EntityId == "RPT-014"));
    }

    [Fact]
    public async Task ReportFamilies_HaveCatalogueEntriesAndReadModelColumns()
    {
        await SeedAsync();
        var factory = new XOptiApiFactory(fixture);
        using var manager = await ManagerAsync(factory);
        foreach (var report in new[]
                 {
                     "RPT-014", "RPT-026", "RPT-029", "RPT-036",
                     "RPT-060", "RPT-096",
                 })
        {
            var preview = await BodyAsync(await manager.PostAsync(
                $"/api/v1/reports/{report}/preview", new
                {
                    parameters = new Dictionary<string, string?>
                    {
                        ["AskDateFrom"] = "2000-01-01",
                        ["AskDateTo"] = "2099-12-31",
                    },
                }), factory, HttpStatusCode.OK);
            Assert.Equal(report, preview.GetProperty("reportId").GetString());
            Assert.True(preview.GetProperty("columns").GetArrayLength() > 0,
                $"{report} has no read-model columns.");
        }
    }

    [Fact]
    public async Task CriticalOrderClaimsStatementsCashAndTaxReports_Render()
    {
        var (customerId, sku, invoice) = await SeedAsync();
        var order = "SA" + Random.Shared.Next(10000000, 99999999);
        var claimNumber = "CL" + Random.Shared.Next(10000000, 99999999);
        var today = DateOnly.FromDateTime(DateTime.UtcNow);
        await using (var seed = fixture.NewContext())
        {
            seed.TxHeaders.Add(new TxHeader
            {
                TxNumber = order, ControlNumber = "00000002",
                TxType = TransactionType.SalesOrder, DateOfEntry = DateTimeOffset.UtcNow,
                DateOfCreation = DateTimeOffset.UtcNow, CustomerId = customerId,
                TotalSale = Money.From(20m), TaxA = Money.From(1m), TaxB = Money.From(1.4m),
                GrossSale = Money.From(22.4m), TotalAmount = Money.From(22.4m),
                TotalQty = 1, Status = "0",
            });
            seed.TxDetails.Add(new TxDetail
            {
                ControlNumber = "00000002", TxType = TransactionType.SalesOrder,
                TxNumber = order, DateOfEntry = DateTimeOffset.UtcNow, RowNo = 1, Sku = sku,
                Qty = 1, UnitAmount = Money.From(20m), Amount = Money.From(20m), TaxCode = "B",
            });
            seed.CashSessions.Add(new CashSession
            {
                BranchCode = "01", TerminalCode = "91", BusinessDate = today,
                Status = "closed", OpenedAt = DateTimeOffset.UtcNow,
                OpeningFloat = 100m, ExpectedCash = 150m, CountedCash = 145m,
                Variance = -5m, ClosedAt = DateTimeOffset.UtcNow,
            });
            await seed.SaveChangesAsync();
        }

        var plan = new InsurancePlan
        {
            PlanCode = "RPT" + customerId, Version = 1, Name = "Report Plan",
            PayerName = "Report Payer", IsCurrent = true, IsActive = true,
            CreatedAt = DateTimeOffset.UtcNow,
        };
        var member = new InsuranceMember
        {
            CustomerId = customerId, PlanId = 0, MemberNumber = "RPT-1",
            EffectiveFrom = today, IsActive = true, CreatedAt = DateTimeOffset.UtcNow,
        };
        await using (var seed = fixture.NewContext())
        {
            seed.InsurancePlans.Add(plan);
            await seed.SaveChangesAsync();
            member.PlanId = plan.Id;
            seed.InsuranceMembers.Add(member);
            await seed.SaveChangesAsync();
            seed.Claims.Add(new InsuranceClaim
            {
                ClaimNumber = claimNumber, InvoiceTxNumber = invoice, CustomerId = customerId,
                PlanId = plan.Id, PlanVersion = 1, MemberId = member.Id, Status = "approved",
                CreatedAt = DateTimeOffset.UtcNow, TotalBilled = 22.4m,
                CoveredAmount = 20m, PatientAmount = 2.4m, ApprovedAmount = 20m,
            });
            await seed.SaveChangesAsync();
        }

        var factory = new XOptiApiFactory(fixture);
        using var manager = await ManagerAsync(factory);

        foreach (var report in new[] { "RPT-046", "SYS-ORDER", "SYS-RECEIPT" })
        {
            var response = await manager.PostAsync($"/api/v1/reports/{report}/print", new
            {
                parameters = new Dictionary<string, string?> { ["DocumentNumber"] = order },
                duplicate = false, terminalCode = "01", reason = "critical order",
            });
            Assert.Equal(HttpStatusCode.OK, response.StatusCode);
            Assert.Equal("application/pdf", response.Content.Headers.ContentType?.MediaType);
        }

        var claim = await manager.PostAsync("/api/v1/reports/RPT-010/print", new
        {
            parameters = new Dictionary<string, string?>
            {
                ["ClaimId"] = member.Id.ToString(),
            },
            duplicate = false, terminalCode = "01", reason = "claim receipt",
        });
        Assert.Equal(HttpStatusCode.OK, claim.StatusCode);

        var rbic = await manager.PostAsync("/api/v1/reports/RPT-062/print", new
        {
            parameters = new Dictionary<string, string?>
            {
                ["AskDateFrom"] = today.AddDays(-1).ToString("yyyy-MM-dd"),
                ["AskDateTo"] = today.AddDays(1).ToString("yyyy-MM-dd"),
            },
            duplicate = false, terminalCode = "01", reason = "rbic",
        });
        Assert.Equal(HttpStatusCode.OK, rbic.StatusCode);
        Assert.Contains(claimNumber, await rbic.Content.ReadAsStringAsync());

        var statement = await manager.PostAsync("/api/v1/reports/SYS-CUST-STATEMENT/print", new
        {
            parameters = new Dictionary<string, string?>
            {
                ["CustomerId"] = customerId.ToString(),
                ["AskDateFrom"] = today.AddDays(-1).ToString("yyyy-MM-dd"),
                ["AskDateTo"] = today.AddDays(1).ToString("yyyy-MM-dd"),
            },
            duplicate = true, terminalCode = "01", reason = "statement",
        });
        if (statement.StatusCode != HttpStatusCode.OK)
            Assert.Fail($"{statement.StatusCode}: {await statement.Content.ReadAsStringAsync()}");
        Assert.Contains("-duplicate.pdf",
            statement.Content.Headers.ContentDisposition?.FileName ?? string.Empty);

        foreach (var report in new[] { "SYS-DAILY-CASH", "SYS-SALES-REPORT", "SYS-TAX-HST" })
        {
            var preview = await BodyAsync(await manager.PostAsync(
                $"/api/v1/reports/{report}/preview", new
                {
                    parameters = new Dictionary<string, string?>
                    {
                        ["AskDateFrom"] = today.AddDays(-1).ToString("yyyy-MM-dd"),
                        ["AskDateTo"] = today.AddDays(1).ToString("yyyy-MM-dd"),
                    },
                }), factory, HttpStatusCode.OK);
            Assert.True(preview.GetProperty("rows").GetArrayLength() >= 1);
        }
    }

    [Fact]
    public async Task CriticalInvoiceAndAnalyticsFeedsSavedViewsAndExports_Work()
    {
        var (customerId, sku, invoice) = await SeedAsync();
        var factory = new XOptiApiFactory(fixture);
        using var manager = await ManagerAsync(factory);

        var printed = await manager.PostAsync("/api/v1/reports/SYS-INVOICE/print", new
        {
            parameters = new Dictionary<string, string?>
            {
                ["DocumentNumber"] = invoice,
            },
            duplicate = false,
            terminalCode = "01",
            reason = "invoice print",
        });
        Assert.Equal(HttpStatusCode.OK, printed.StatusCode);
        Assert.Equal("application/pdf", printed.Content.Headers.ContentType?.MediaType);

        await BodyAsync(await manager.PostAsync("/api/v1/reports/refresh", new
        {
            reason = "analytics test refresh",
        }), factory, HttpStatusCode.OK);

        var feed = await BodyAsync(await manager.GetAsync(
            "/api/v1/analytics/views/sales_by_cost?from=2000-01&to=2099-12"),
            factory, HttpStatusCode.OK);
        Assert.Equal("sales_by_cost", feed.GetProperty("viewKey").GetString());
        Assert.True(feed.GetProperty("fields").GetArrayLength() > 5);
        Assert.Contains(feed.GetProperty("data").EnumerateArray(), row =>
            row.EnumerateArray().Any(value => value.ValueKind == JsonValueKind.String
                && value.GetString() == sku));

        await using (var verify = fixture.NewContext())
        {
            static async Task<(decimal Sales, decimal Cost, decimal Margin)> Totals(
                Microsoft.EntityFrameworkCore.DbContext context, string sql,
                string parameterName, string parameterValue)
            {
                var connection = context.Database.GetDbConnection();
                if (connection.State != System.Data.ConnectionState.Open)
                    await connection.OpenAsync();
                await using var command = connection.CreateCommand();
                command.CommandText = sql;
                var parameter = command.CreateParameter();
                parameter.ParameterName = parameterName;
                parameter.Value = parameterValue;
                command.Parameters.Add(parameter);
                await using var reader = await command.ExecuteReaderAsync();
                await reader.ReadAsync();
                return (reader.GetDecimal(0), reader.GetDecimal(1), reader.GetDecimal(2));
            }

            var legacy = await Totals(verify, """
                SELECT COALESCE(SUM(sales),0), COALESCE(SUM(cost),0), COALESCE(SUM(margin),0)
                FROM public.olap_sales WHERE sku = @sku
                """, "sku", sku);
            var model = await Totals(verify, """
                SELECT COALESCE(SUM(sales),0), COALESCE(SUM(cost),0), COALESCE(SUM(margin),0)
                FROM reporting.mv_olap_sales_by_cost WHERE sku = @sku
                """, "sku", sku);
            Assert.Equal(legacy.Sales, model.Sales);
            Assert.Equal(legacy.Cost, model.Cost);
            Assert.Equal(legacy.Margin, model.Margin);

            var legacyLsp = await Totals(verify, """
                SELECT COALESCE(SUM(sales),0), COALESCE(SUM(cost),0), COALESCE(SUM(margin),0)
                FROM public.olap_sales_lsp
                WHERE date_of_entry >= date_trunc('month', now())
                """, "unused", "x");
            var modelLsp = await Totals(verify, """
                SELECT COALESCE(SUM(sales),0), COALESCE(SUM(cost),0), COALESCE(SUM(margin),0)
                FROM reporting.mv_olap_sales_by_lsp
                WHERE period = to_char(now(), 'YYYY-MM')
                """, "unused", "x");
            Assert.Equal(legacyLsp.Sales, modelLsp.Sales);
            Assert.Equal(legacyLsp.Cost, modelLsp.Cost);
            Assert.Equal(legacyLsp.Margin, modelLsp.Margin);
        }

        var saved = await BodyAsync(await manager.PostAsync("/api/v1/analytics/saved", new
        {
            viewKey = "sales_by_cost",
            name = "Cost review " + customerId,
            isShared = true,
            configJson = "{\"rows\":[\"category_code\"],\"values\":[\"sales\"]}",
            reason = "save view",
        }), factory, HttpStatusCode.OK);
        var savedId = saved.GetProperty("id").GetInt64();
        var list = await BodyAsync(await manager.GetAsync("/api/v1/analytics/saved"),
            factory, HttpStatusCode.OK);
        Assert.Contains(list.EnumerateArray(), row => row.GetProperty("id").GetInt64() == savedId);

        var exported = await manager.GetAsync(
            "/api/v1/analytics/views/sales_by_cost/export?from=2000-01&to=2099-12"
            + "&reason=analytics%20export");
        Assert.Equal(HttpStatusCode.OK, exported.StatusCode);
        Assert.Contains("Sales", await exported.Content.ReadAsStringAsync());

        using var clerk = new TestClient(factory);
        await clerk.FetchCsrfTokenAsync();
        await clerk.SignInAsync("clerk", SeedData.Password);
        Assert.Equal(HttpStatusCode.Forbidden,
            (await clerk.GetAsync("/api/v1/analytics/views/sales_by_cost")).StatusCode);
        Assert.Equal(HttpStatusCode.Forbidden,
            (await clerk.GetAsync($"/api/v1/analytics/saved/{savedId}")).StatusCode);
    }
}
