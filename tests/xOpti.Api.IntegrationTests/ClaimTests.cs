using System.Net;
using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using xOpti.Api.IntegrationTests.Support;
using xOpti.Domain.Values;
using xOpti.Infrastructure.Persistence.Entities;

namespace xOpti.Api.IntegrationTests;

[Collection("api")]
public sealed class ClaimTests(ApiPostgresFixture fixture)
{
    private static async Task<JsonElement> BodyAsync(HttpResponseMessage response,
        XOptiApiFactory factory, params HttpStatusCode[] expected)
    {
        if (!expected.Contains(response.StatusCode))
        {
            var exceptions = string.Join("\n", factory.Logs.Snapshot()
                .Where(entry => entry.Exception is not null)
                .Select(entry => entry.Exception!.ToString()));
            Assert.Fail($"{response.StatusCode}: {await response.Content.ReadAsStringAsync()}\n{exceptions}");
        }
        using var document = JsonDocument.Parse(await response.Content.ReadAsStringAsync());
        return document.RootElement.Clone();
    }

    private async Task<(int CustomerId, string InvoiceNumber, string Sku)> SeedAsync()
    {
        var customerId = Random.Shared.Next(930000, 939999);
        var sku = "CL" + Random.Shared.Next(10000000, 99999999);
        var invoice = "RC" + Random.Shared.Next(10000000, 99999999);
        await using var seed = fixture.NewContext();
        seed.Customers.Add(new Customer { Id = customerId, FullName = "Claim Customer" });
        seed.InventoryItems.Add(new Inventory
        {
            Sku = sku, DepartmentCode = "09", ClassCode = "09", CategoryCode = "09",
            SupplierCode = "0001", BrandCode = "0001", Name = "Claim Frame",
            QtyTotalOnHand = 10, AverageCost = Money.From(20m),
            InventoryLotFlag = true, RetailPriceFlag = true,
        });
        seed.TxHeaders.Add(new TxHeader
        {
            TxNumber = invoice, ControlNumber = "93000001",
            TxType = xOpti.Domain.Values.TransactionType.RetailInvoice,
            DateOfEntry = DateTimeOffset.UtcNow, CustomerId = customerId,
            TotalSale = Money.From(100m), GrossSale = Money.From(100m),
            TotalAmount = Money.From(100m), TotalQty = 1, Status = "0",
        });
        seed.TxDetails.Add(new TxDetail
        {
            ControlNumber = "93000001", TxType = xOpti.Domain.Values.TransactionType.RetailInvoice,
            TxNumber = invoice, DateOfEntry = DateTimeOffset.UtcNow, RowNo = 1, Sku = sku,
            Qty = 1, UnitAmount = Money.From(100m), Amount = Money.From(100m), TaxCode = "N",
        });
        await seed.SaveChangesAsync();
        return (customerId, invoice, sku);
    }

    [Fact]
    public async Task ClaimLifecycle_CoverageAdjudicationRejectionResubmissionAndPayments()
    {
        var (customerId, invoice, _) = await SeedAsync();
        var factory = new XOptiApiFactory(fixture);
        using var manager = new TestClient(factory);
        await manager.FetchCsrfTokenAsync();
        await manager.SignInAsync("manager", SeedData.Password);
        var today = DateOnly.FromDateTime(DateTime.UtcNow);

        var plan = await BodyAsync(await manager.PostAsync("/api/v1/claims/plans", new
        {
            planCode = "PLAN" + customerId, name = "Test Plan", payerName = "Test Payer",
            rules = new[] { new { categoryCode = "09", sku = (string?)null,
                coveragePercent = 80m, annualMaximum = 10000m, requiresPreauthorization = false } },
            reason = "test plan",
        }), factory, HttpStatusCode.OK);
        var planId = plan.GetProperty("id").GetInt64();
        Assert.Equal(1, plan.GetProperty("version").GetInt32());

        var member = await BodyAsync(await manager.PostAsync("/api/v1/claims/members", new
        {
            customerId, planId, memberNumber = "MEM-1", groupNumber = "GRP-1",
            effectiveFrom = today, effectiveTo = (string?)null,
            eligibilityNote = "eligible", reason = "assign member",
        }), factory, HttpStatusCode.OK);
        var memberId = member.GetProperty("id").GetInt64();

        var claim = await BodyAsync(await manager.PostAsync("/api/v1/claims", new
        {
            invoiceTxNumber = invoice, memberId, invoiceRowNumbers = new[] { 1 },
            reason = "create claim",
        }), factory, HttpStatusCode.Created);
        var claimId = claim.GetProperty("id").GetInt64();
        Assert.Equal(80m, claim.GetProperty("coveredAmount").GetDecimal());
        Assert.Equal(20m, claim.GetProperty("patientAmount").GetDecimal());
        Assert.Equal(1, claim.GetProperty("planVersion").GetInt32());

        var duplicate = await manager.PostAsync("/api/v1/claims", new
        {
            invoiceTxNumber = invoice, memberId, invoiceRowNumbers = new[] { 1 },
            reason = "duplicate claim",
        });
        Assert.Equal(HttpStatusCode.BadRequest, duplicate.StatusCode);

        var partial = await BodyAsync(await manager.PostAsync(
            $"/api/v1/claims/{claimId}/adjudicate", new
            {
                approvedAmount = 60m, reason = "partial approval", reference = "AUTH-1",
                note = "plan limit",
            }), factory, HttpStatusCode.OK);
        Assert.Equal("partially-approved", partial.GetProperty("status").GetString());
        Assert.Equal(60m, partial.GetProperty("approvedAmount").GetDecimal());
        Assert.Equal(20m, partial.GetProperty("adjustmentAmount").GetDecimal());
        Assert.Equal(40m, partial.GetProperty("patientAmount").GetDecimal());

        var rejected = await BodyAsync(await manager.PostAsync(
            $"/api/v1/claims/{claimId}/reject", new { reason = "missing documentation" }),
            factory, HttpStatusCode.OK);
        Assert.Equal("rejected", rejected.GetProperty("status").GetString());

        var resubmitted = await BodyAsync(await manager.PostAsync(
            $"/api/v1/claims/{claimId}/resubmit", new
            {
                reason = "documents supplied", reference = "RESUB-1",
            }), factory, HttpStatusCode.OK);
        Assert.Equal("submitted", resubmitted.GetProperty("status").GetString());

        var approved = await BodyAsync(await manager.PostAsync(
            $"/api/v1/claims/{claimId}/adjudicate", new
            {
                approvedAmount = 80m, reason = "full approval", reference = "AUTH-2",
                note = (string?)null,
            }), factory, HttpStatusCode.OK);
        Assert.Equal("approved", approved.GetProperty("status").GetString());

        var overPayment = await manager.PostAsync($"/api/v1/claims/{claimId}/payments", new
        {
            amount = 100m, method = "EFT", reference = "PAY-1", reason = "insurer payment",
        });
        Assert.Equal(HttpStatusCode.BadRequest, overPayment.StatusCode);

        var paid = await BodyAsync(await manager.PostAsync(
            $"/api/v1/claims/{claimId}/payments", new
            {
                amount = 50m, method = "EFT", reference = "PAY-1", reason = "insurer payment",
            }), factory, HttpStatusCode.OK);
        Assert.Equal(50m, paid.GetProperty("paidAmount").GetDecimal());
        Assert.Equal("approved", paid.GetProperty("status").GetString());

        var final = await BodyAsync(await manager.PostAsync(
            $"/api/v1/claims/{claimId}/payments", new
            {
                amount = 30m, method = "EFT", reference = "PAY-2", reason = "insurer payment",
            }), factory, HttpStatusCode.OK);
        Assert.Equal(80m, final.GetProperty("paidAmount").GetDecimal());
        Assert.Equal("paid", final.GetProperty("status").GetString());

        var reconciliation = await BodyAsync(
            await manager.GetAsync("/api/v1/claims/reconciliation"),
            factory, HttpStatusCode.OK);
        var row = reconciliation.EnumerateArray().Single(item =>
            item.GetProperty("claimId").GetInt64() == claimId);
        Assert.Equal(100m, row.GetProperty("invoiceTotal").GetDecimal());
        Assert.Equal(80m, row.GetProperty("approvedAmount").GetDecimal());
        Assert.Equal(80m, row.GetProperty("paidAmount").GetDecimal());
        Assert.Equal(0m, row.GetProperty("difference").GetDecimal());

        var audits = new[] { "claim.plan.create", "claim.member.assign", "claim.create",
            "claim.adjudicate", "claim.reject", "claim.resubmit", "claim.payment" };
        await using var verify = fixture.NewContext();
        foreach (var action in audits)
            Assert.True(await verify.AuditLogs.AnyAsync(log => log.Action == action), action);
    }

    [Fact]
    public async Task ClaimReceiptAndRbicExport_AreAuditedAndPermissioned()
    {
        var (customerId, invoice, _) = await SeedAsync();
        var factory = new XOptiApiFactory(fixture);
        using var manager = new TestClient(factory);
        await manager.FetchCsrfTokenAsync();
        await manager.SignInAsync("manager", SeedData.Password);
        var today = DateOnly.FromDateTime(DateTime.UtcNow);
        var plan = await BodyAsync(await manager.PostAsync("/api/v1/claims/plans", new
        {
            planCode = "DOC" + customerId, name = "Document Plan", payerName = "Payer",
            rules = new[] { new { categoryCode = "09", sku = (string?)null,
                coveragePercent = 100m, annualMaximum = 0m, requiresPreauthorization = false } },
            reason = "document plan",
        }), factory, HttpStatusCode.OK);
        var planId = plan.GetProperty("id").GetInt64();
        var member = await BodyAsync(await manager.PostAsync("/api/v1/claims/members", new
        {
            customerId, planId, memberNumber = "DOC-1", groupNumber = (string?)null,
            effectiveFrom = today, effectiveTo = (string?)null,
            eligibilityNote = (string?)null, reason = "document member",
        }), factory, HttpStatusCode.OK);
        var memberId = member.GetProperty("id").GetInt64();
        var claim = await BodyAsync(await manager.PostAsync("/api/v1/claims", new
        {
            invoiceTxNumber = invoice, memberId, invoiceRowNumbers = new[] { 1 },
            reason = "document claim",
        }), factory, HttpStatusCode.Created);
        var claimId = claim.GetProperty("id").GetInt64();
        await BodyAsync(await manager.PostAsync($"/api/v1/claims/{claimId}/adjudicate", new
        {
            approvedAmount = 100m, reason = "full", reference = "AUTH-DOC", note = (string?)null,
        }), factory, HttpStatusCode.OK);
        await BodyAsync(await manager.PostAsync($"/api/v1/claims/{claimId}/payments", new
        {
            amount = 100m, method = "EFT", reference = "PAY-DOC", reason = "paid",
        }), factory, HttpStatusCode.OK);

        var receipt = await BodyAsync(await manager.GetAsync(
            $"/api/v1/claims/{claimId}/receipt"), factory, HttpStatusCode.OK);
        Assert.Equal("Document Plan", receipt.GetProperty("planName").GetString());
        Assert.Equal(100m, receipt.GetProperty("coveredAmount").GetDecimal());

        var print = await manager.PostAsync($"/api/v1/claims/{claimId}/receipt/prints", new
        {
            reprint = true, terminalCode = "01", reason = "duplicate claim receipt",
        });
        Assert.Equal(HttpStatusCode.OK, print.StatusCode);
        Assert.Contains("-duplicate.pdf",
            print.Content.Headers.ContentDisposition?.FileName ?? string.Empty);
        Assert.Equal("%PDF", System.Text.Encoding.ASCII.GetString(
            (await print.Content.ReadAsByteArrayAsync())[..4]));

        var rbic = await manager.GetAsync(
            $"/api/v1/claims/rbic?from={today:yyyy-MM-dd}&to={today:yyyy-MM-dd}&reason=reconcile");
        Assert.Equal(HttpStatusCode.OK, rbic.StatusCode);
        Assert.Equal("text/csv", rbic.Content.Headers.ContentType?.MediaType);
        Assert.Contains(claim.GetProperty("claimNumber").GetString(),
            await rbic.Content.ReadAsStringAsync());

        using var clerk = new TestClient(factory);
        await clerk.FetchCsrfTokenAsync();
        await clerk.SignInAsync("clerk", SeedData.Password);
        Assert.Equal(HttpStatusCode.Forbidden,
            (await clerk.GetAsync($"/api/v1/claims/{claimId}/receipt")).StatusCode);
        Assert.Equal(HttpStatusCode.Forbidden,
            (await clerk.GetAsync(
                $"/api/v1/claims/rbic?from={today:yyyy-MM-dd}&to={today:yyyy-MM-dd}")).StatusCode);

        await using var verify = fixture.NewContext();
        Assert.True(await verify.AuditLogs.AnyAsync(row =>
            row.Action == "claim.receipt.reprint" && row.EntityId == claimId.ToString()));
        Assert.True(await verify.AuditLogs.AnyAsync(row =>
            row.Action == "claim.rbic.export"));
    }

    [Fact]
    public async Task IneligibleLineAndMissingMember_AreRejectedClearly()
    {
        var (customerId, invoice, _) = await SeedAsync();
        var factory = new XOptiApiFactory(fixture);
        using var manager = new TestClient(factory);
        await manager.FetchCsrfTokenAsync();
        await manager.SignInAsync("manager", SeedData.Password);

        var plan = await BodyAsync(await manager.PostAsync("/api/v1/claims/plans", new
        {
            planCode = "OTHER" + customerId, name = "Other Plan", payerName = "Payer",
            rules = new[] { new { categoryCode = "99", sku = (string?)null,
                coveragePercent = 50m, annualMaximum = 0m, requiresPreauthorization = false } },
            reason = "ineligible plan",
        }), factory, HttpStatusCode.OK);
        var planId = plan.GetProperty("id").GetInt64();
        var today = DateOnly.FromDateTime(DateTime.UtcNow);
        var member = await BodyAsync(await manager.PostAsync("/api/v1/claims/members", new
        {
            customerId, planId, memberNumber = "MEM-2", groupNumber = (string?)null,
            effectiveFrom = today, effectiveTo = (string?)null,
            eligibilityNote = (string?)null, reason = "member",
        }), factory, HttpStatusCode.OK);
        var memberId = member.GetProperty("id").GetInt64();

        var claim = await BodyAsync(await manager.PostAsync("/api/v1/claims", new
        {
            invoiceTxNumber = invoice, memberId, invoiceRowNumbers = new[] { 1 },
            reason = "ineligible line",
        }), factory, HttpStatusCode.Created);
        var line = claim.GetProperty("lines").EnumerateArray().Single();
        Assert.False(line.GetProperty("eligible").GetBoolean());
        Assert.Equal(0m, line.GetProperty("coveredAmount").GetDecimal());
        Assert.Contains("No coverage rule", line.GetProperty("ineligibleReason").GetString());

        var missing = await manager.PostAsync("/api/v1/claims", new
        {
            invoiceTxNumber = invoice, memberId = 99999999, invoiceRowNumbers = new[] { 1 },
            reason = "missing member",
        });
        Assert.Equal(HttpStatusCode.BadRequest, missing.StatusCode);
        Assert.Contains("member", await missing.Content.ReadAsStringAsync(),
            StringComparison.OrdinalIgnoreCase);
    }
}

public class ClaimDocumentTests
{
    [Fact]
    public void ClaimReceiptLayout_IsGoldenAndDuplicateMarked()
    {
        var receipt = new xOpti.Application.Claims.ClaimReceiptDto(
            1, "CL00000001", "RC00000001", 1, "Test Customer", "Plan", "Payer", 1,
            DateTimeOffset.Parse("2026-11-17T10:00:00Z"), "approved",
            100m, 80m, 20m, 80m, 0m, 80m,
            new[]
            {
                new xOpti.Application.Claims.ClaimReceiptLineDto(1, "30110359", 100m, 80m, 20m,
                    true, null),
            });
        var plan = string.Join("\n", xOpti.Application.Claims.ClaimDocumentLayout.BuildReceipt(receipt));
        Assert.Contains("xOpti claim receipt", plan);
        Assert.Contains("Claim CL00000001", plan);
        Assert.Contains("Covered 80.0000", plan);
        var duplicate = string.Join("\n",
            xOpti.Application.Claims.ClaimDocumentLayout.BuildReceipt(receipt, true));
        Assert.Contains("DUPLICATE CLAIM RECEIPT", duplicate);
    }
}

public class ClaimDocumentApiTests
{
    // covered by ClaimTests; this marker keeps the file's document scenarios grouped.
}
