using System.Net;
using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using xOpti.Api.IntegrationTests.Support;
using xOpti.Domain.Values;
using xOpti.Infrastructure.Persistence.Entities;

namespace xOpti.Api.IntegrationTests;

[Collection("api")]
public sealed class CustomerTests(ApiPostgresFixture fixture)
{
    private async Task<TestClient> ManagerAsync()
    {
        var client = new TestClient(new XOptiApiFactory(fixture));
        await client.FetchCsrfTokenAsync();
        Assert.Equal(HttpStatusCode.OK, (await client.SignInAsync("manager", SeedData.Password)).Status);
        return client;
    }

    private static object Input(string fullName, string? phone = null, string? email = null,
        decimal creditLimit = 0m) => new
    {
        vipCode = (string?)null, salutation = "Ms", firstName = fullName.Split(' ')[0],
        initial = (string?)null, lastName = fullName.Split(' ')[^1], fullName,
        birthday = (string?)null, homeAddress = "1 Main St", homeCity = 1,
        homeProvince = "BC", homePostalCode = "V6B1A1", homeCountry = "CA",
        homePhone = phone, homeFax = (string?)null, cellular = phone, email,
        bizCompanyName = (string?)null, bizJobTitle = (string?)null, bizAddress = (string?)null,
        bizCity = 0, bizProvince = (string?)null, bizPostalCode = (string?)null,
        bizCountry = (string?)null, bizPhone = (string?)null, bizFax = (string?)null,
        creditLimit, paymentTerms = "30", vipMarkDownPct = 0, summaryFlag = (bool?)null,
        accountingFlag = (bool?)null, remarks = "private note",
    };

    private static object Write(string fullName, string? phone = null, string? email = null,
        bool confirm = false, decimal creditLimit = 0m) => new
    {
        input = Input(fullName, phone, email, creditLimit),
        confirmDuplicate = confirm,
        reason = "customer test",
    };

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

    [Fact]
    public async Task CustomerCreateSearchViewPiiAndDuplicateWarning()
    {
        var token = Guid.NewGuid().ToString("N")[..6];
        var name = "Ada Lens " + token;
        var phone = "604" + Random.Shared.Next(1000000, 9999999);
        var email = $"ada{token}@example.test";
        var factory = new XOptiApiFactory(fixture);
        using var manager = new TestClient(factory);
        await manager.FetchCsrfTokenAsync();
        await manager.SignInAsync("manager", SeedData.Password);

        var created = await BodyAsync(await manager.PostAsync("/api/v1/customers",
            Write(name, phone, email, creditLimit: 100m)),
            factory, HttpStatusCode.Created);
        var id = created.GetProperty("customer").GetProperty("id").GetInt32();
        Assert.True(id > 0);
        Assert.Equal("***", created.GetProperty("customer").GetProperty("fullName").GetString());
        Assert.Equal(JsonValueKind.Null,
            created.GetProperty("customer").GetProperty("homePhone").ValueKind);

        var duplicate = await manager.PostAsync("/api/v1/customers", Write(name, phone, email));
        Assert.Equal(HttpStatusCode.BadRequest, duplicate.StatusCode);
        Assert.Contains("duplicate-candidate", await duplicate.Content.ReadAsStringAsync());
        var confirmed = await BodyAsync(await manager.PostAsync("/api/v1/customers",
            Write(name, phone, email, confirm: true)), factory, HttpStatusCode.Created);
        var secondId = confirmed.GetProperty("customer").GetProperty("id").GetInt32();
        Assert.NotEqual(id, secondId);

        var pageOne = await BodyAsync(await manager.GetAsync(
            $"/api/v1/customers?search={Uri.EscapeDataString(name)}&pageSize=1"),
            factory, HttpStatusCode.OK);
        var firstPageId = Assert.Single(pageOne.GetProperty("items").EnumerateArray())
            .GetProperty("id").GetInt32();
        var cursor = pageOne.GetProperty("nextCursor").GetString();
        Assert.NotNull(cursor);
        var pageTwo = await BodyAsync(await manager.GetAsync(
            $"/api/v1/customers?search={Uri.EscapeDataString(name)}&pageSize=1&cursor={Uri.EscapeDataString(cursor)}"),
            factory, HttpStatusCode.OK);
        var secondPageId = Assert.Single(pageTwo.GetProperty("items").EnumerateArray())
            .GetProperty("id").GetInt32();
        Assert.NotEqual(firstPageId, secondPageId);

        var search = await BodyAsync(await manager.GetAsync($"/api/v1/customers?search={phone}"),
            factory, HttpStatusCode.OK);
        var hit = search.GetProperty("items").EnumerateArray()
            .Single(row => row.GetProperty("id").GetInt32() == id);
        Assert.Equal("***", hit.GetProperty("displayName").GetString());
        Assert.Equal(JsonValueKind.Null, hit.GetProperty("homePhone").ValueKind);

        var view = await BodyAsync(await manager.GetAsync($"/api/v1/customers/{id}"),
            factory, HttpStatusCode.OK);
        Assert.Equal("***", view.GetProperty("customer").GetProperty("fullName").GetString());
        Assert.Equal(100m, view.GetProperty("customer").GetProperty("creditLimit").GetDecimal());

        await using var verify = fixture.NewContext();
        Assert.True(await verify.AuditLogs.AnyAsync(row =>
            row.Action == "customer.pii.denied" && row.EntityId == id.ToString()));
        Assert.True(await verify.AuditLogs.AnyAsync(row =>
            row.Action == "customer.create" && row.EntityId == id.ToString()));
    }

    [Fact]
    public async Task CustomerPaginationAndMergeResolveAliasesWithoutDeletingRows()
    {
        var token = Guid.NewGuid().ToString("N")[..6];
        var factory = new XOptiApiFactory(fixture);
        using var manager = new TestClient(factory);
        await manager.FetchCsrfTokenAsync();
        await manager.SignInAsync("manager", SeedData.Password);

        var first = await BodyAsync(await manager.PostAsync("/api/v1/customers",
            Write("Merge One " + token, "6041110001", $"m1{token}@example.test")),
            factory, HttpStatusCode.Created);
        var second = await BodyAsync(await manager.PostAsync("/api/v1/customers",
            Write("Merge Two " + token, "6041110002", $"m2{token}@example.test")),
            factory, HttpStatusCode.Created);
        var sourceId = first.GetProperty("customer").GetProperty("id").GetInt32();
        var targetId = second.GetProperty("customer").GetProperty("id").GetInt32();

        var merge = await BodyAsync(await manager.PostAsync("/api/v1/customers/merge", new
        {
            sourceId, targetId, phone = "6041110002", email = $"m2{token}@example.test",
            fullName = "Merge Two " + token, reason = "same person",
        }), factory, HttpStatusCode.OK);
        Assert.Equal(targetId, merge.GetProperty("customer").GetProperty("id").GetInt32());
        Assert.Equal(sourceId, merge.GetProperty("resolvedFrom").GetInt32());

        var redirected = await BodyAsync(await manager.GetAsync($"/api/v1/customers/{sourceId}"),
            factory, HttpStatusCode.OK);
        Assert.Equal(targetId, redirected.GetProperty("customer").GetProperty("id").GetInt32());
        Assert.Equal(sourceId, redirected.GetProperty("resolvedFrom").GetInt32());

        var search = await BodyAsync(await manager.GetAsync(
            $"/api/v1/customers?search=Merge%20One%20{token}"), factory, HttpStatusCode.OK);
        Assert.DoesNotContain(search.GetProperty("items").EnumerateArray(),
            row => row.GetProperty("id").GetInt32() == sourceId);

        await using var verify = fixture.NewContext();
        Assert.True(await verify.Customers.AnyAsync(row => row.Id == sourceId));
        Assert.True(await verify.CustomerAliases.AnyAsync(row =>
            row.AliasId == sourceId && row.CanonicalId == targetId));
        Assert.True(await verify.AuditLogs.AnyAsync(row =>
            row.Action == "customer.merge" && row.EntityId == targetId.ToString()));
    }

    [Fact]
    public async Task AccountHistoryAndStatementReconcilePostedDocuments()
    {
        var token = Guid.NewGuid().ToString("N")[..6];
        var customerId = Random.Shared.Next(910000, 919999);
        var invoice = "RC" + Random.Shared.Next(10000000, 99999999);
        var refund = "RS" + Random.Shared.Next(10000000, 99999999);
        var today = DateOnly.FromDateTime(DateTime.UtcNow);
        await using (var seed = fixture.NewContext())
        {
            seed.Customers.Add(new Customer { Id = customerId, FullName = "Statement " + token });
            seed.TxHeaders.Add(new TxHeader
            {
                TxNumber = invoice, ControlNumber = "90000001", TxType = xOpti.Domain.Values.TransactionType.RetailInvoice,
                DateOfEntry = DateTimeOffset.UtcNow, CustomerId = customerId,
                TotalSale = Money.From(100m), TaxA = Money.From(5m), TaxB = Money.From(7m),
                GrossSale = Money.From(112m), TotalAmount = Money.From(112m), TotalQty = 1, Status = "0",
            });
            seed.TxPayments.Add(new TxPayment
            {
                TxNumber = invoice, PaymentLineNo = 1, Type = "C",
                AmountTender = Money.From(112m), EqAmount = Money.From(112m), TotalThisPay = Money.From(112m),
            });
            seed.TxHeaders.Add(new TxHeader
            {
                TxNumber = refund, ControlNumber = "90000002", TxType = xOpti.Domain.Values.TransactionType.RetailRefund,
                DateOfEntry = DateTimeOffset.UtcNow, CustomerId = customerId,
                TotalSale = Money.From(-50m), TaxA = Money.From(-2.5m), TaxB = Money.From(-3.5m),
                GrossSale = Money.From(-56m), TotalAmount = Money.From(-56m), TotalQty = -1, Status = "0",
            });
            seed.TxPayments.Add(new TxPayment
            {
                TxNumber = refund, PaymentLineNo = 1, Type = "C",
                AmountTender = Money.From(-56m), EqAmount = Money.From(-56m), TotalThisPay = Money.From(-56m),
            });
            await seed.SaveChangesAsync();
        }

        var factory = new XOptiApiFactory(fixture);
        using var manager = new TestClient(factory);
        await manager.FetchCsrfTokenAsync();
        await manager.SignInAsync("manager", SeedData.Password);

        var account = await BodyAsync(await manager.GetAsync($"/api/v1/customers/{customerId}/account"),
            factory, HttpStatusCode.OK);
        Assert.Equal(112m, account.GetProperty("charges").GetDecimal());
        Assert.Equal(56m, account.GetProperty("payments").GetDecimal());
        Assert.Equal(-56m, account.GetProperty("refunds").GetDecimal());
        Assert.Equal(0m, account.GetProperty("balance").GetDecimal());

        var history = await BodyAsync(await manager.GetAsync($"/api/v1/customers/{customerId}/history"),
            factory, HttpStatusCode.OK);
        Assert.Equal(2, history.GetProperty("items").GetArrayLength());

        var statement = await BodyAsync(await manager.GetAsync(
            $"/api/v1/customers/{customerId}/statement?from={today:yyyy-MM-dd}&to={today:yyyy-MM-dd}"),
            factory, HttpStatusCode.OK);
        Assert.Equal(0m, statement.GetProperty("openingBalance").GetDecimal());
        Assert.Equal(112m, statement.GetProperty("charges").GetDecimal());
        Assert.Equal(56m, statement.GetProperty("payments").GetDecimal());
        Assert.Equal(-56m, statement.GetProperty("refunds").GetDecimal());
        Assert.Equal(0m, statement.GetProperty("closingBalance").GetDecimal());
    }
}

public class CustomerPiiAuditTests
{
    private sealed class PiiPrincipal : xOpti.Application.Ports.ICurrentPrincipal
    {
        public string? UserId => "auditor";
        public string? BranchCode => "01";
        public bool HasPermission(string permission) => permission == "customer:pii";
    }

    private sealed class AuditRecorder : xOpti.Application.Ports.IAuditRecorder
    {
        public List<xOpti.Application.Ports.AuditRecord> Records { get; } = new();
        public Task RecordAsync(xOpti.Application.Ports.AuditRecord record, CancellationToken ct)
        {
            Records.Add(record);
            return Task.CompletedTask;
        }
    }

    private sealed class Store : xOpti.Application.Customers.ICustomerStore
    {
        public Task<int?> ResolveCanonicalIdAsync(int customerId, CancellationToken ct) =>
            Task.FromResult<int?>(customerId);
        public Task<xOpti.Application.Customers.CustomerDetailDto?> GetAsync(
            int customerId, CancellationToken ct) =>
            Task.FromResult<xOpti.Application.Customers.CustomerDetailDto?>(new(
                customerId, "V1", "Ms", "Ada", null, "Lens", "Ada Lens", null,
                "1 Main", 1, "BC", "V6B", "CA", "6045550100", null, "6045550199",
                "ada@example.test", null, null, null, 0, null, null, null, null, null,
                100m, "30", 0, null, null, "note"));
        public Task<xOpti.Application.Customers.CustomerBalanceDto?> GetBalanceAsync(
            int customerId, CancellationToken ct) => throw new NotSupportedException();
        public Task<IReadOnlyList<int>> ResolveGroupIdsAsync(int customerId, CancellationToken ct) =>
            Task.FromResult<IReadOnlyList<int>>(new[] { customerId });
        public Task<IReadOnlyList<xOpti.Application.Customers.CustomerPurchaseDto>> GetHistoryAsync(
            IReadOnlyList<int> ids, DateOnly? from, DateOnly? to, CancellationToken ct) =>
            throw new NotSupportedException();
        public Task<(IReadOnlyList<xOpti.Application.Customers.CustomerSummaryDto> Items, bool HasMore)>
            SearchAsync(string? search, int? afterId, int limit, CancellationToken ct) =>
            throw new NotSupportedException();
        public Task<IReadOnlyList<xOpti.Application.Customers.CustomerDuplicateDto>> FindDuplicatesAsync(
            xOpti.Application.Customers.CustomerInput input, int? excludeCustomerId, CancellationToken ct) =>
            throw new NotSupportedException();
        public Task<int> CreateAsync(xOpti.Application.Customers.CustomerInput input, CancellationToken ct) =>
            throw new NotSupportedException();
        public Task UpdateAsync(int customerId, xOpti.Application.Customers.CustomerInput input,
            CancellationToken ct) => throw new NotSupportedException();
        public Task MergeAsync(int sourceId, int targetId, string? phone, string? email,
            string? fullName, string reason, string? actor, CancellationToken ct) =>
            throw new NotSupportedException();
    }

    [Fact]
    public async Task PermittedPiiView_RecordsAccessAuditAndReturnsProtectedFields()
    {
        var audit = new AuditRecorder();
        var handler = new xOpti.Application.Customers.GetCustomerHandler(
            new Store(), audit, new PiiPrincipal());

        var view = await handler.Handle(new xOpti.Application.Customers.GetCustomerQuery(1), default);

        Assert.Equal("Ada Lens", view.Customer.FullName);
        Assert.Equal("6045550100", view.Customer.HomePhone);
        var record = Assert.Single(audit.Records);
        Assert.Equal("customer.pii.access", record.Action);
        Assert.Equal("Customer", record.EntityType);
        Assert.Contains("email", record.Details);
    }
}
