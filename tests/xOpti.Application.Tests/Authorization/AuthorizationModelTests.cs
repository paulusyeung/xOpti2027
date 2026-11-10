using System.Text.RegularExpressions;
using FluentValidation;
using Microsoft.Extensions.DependencyInjection;
using xOpti.Application.Authorization;
using xOpti.Application.Common;
using xOpti.Application.Pipeline;
using xOpti.Application.Ports;
using xOpti.Domain.Values;
using xOpti.Application.Tests.Support;

namespace xOpti.Application.Tests.Authorization;

public class PermissionNamesTests
{
    [Fact]
    public void Claims_AreKebabCaseResourceAction()
    {
        var pattern = new Regex("^[a-z][a-z0-9-]*:[a-z][a-z0-9-]*$");
        foreach (var claim in PermissionNames.All)
        {
            Assert.Matches(pattern, claim);
        }
    }

    [Fact]
    public void CoreVocabulary_IsPresent()
    {
        Assert.Contains("cost:view", PermissionNames.All);
        Assert.Contains("inventory:adjust", PermissionNames.All);
        Assert.Contains("report:financial", PermissionNames.All);
        Assert.Contains("customer:pii", PermissionNames.All);
    }

    [Fact]
    public void Vocabulary_IsClosedAndDistinct()
    {
        Assert.Equal(PermissionNames.All.Count, PermissionNames.All.Distinct().Count());
    }

    [Fact]
    public void Constants_MatchClaimStrings()
    {
        Assert.Equal("cost:view", PermissionNames.CostView);
        Assert.Equal("inventory:adjust", PermissionNames.InventoryAdjust);
        Assert.Equal("report:financial", PermissionNames.ReportFinancial);
        Assert.Equal("customer:pii", PermissionNames.CustomerPii);
    }
}

public class PermissionBehaviorDenialTests
{
    [Fact]
    public async Task DeniedDispatch_ProducesAuthorizationError_AndNoSideEffects()
    {
        var principal = new FakePrincipal(); // no permissions
        var uow = new FakeUnitOfWork();
        var store = new FakeIdempotencyStore();
        var log = new FakeExecutionLog();

        var services = new ServiceCollection();
        services.AddXOptiApplication();
        services.AddScoped<ICurrentPrincipal>(_ => principal);
        services.AddSingleton<IUnitOfWork>(uow);
        services.AddSingleton<IIdempotencyStore>(store);
        services.AddSingleton(log);
        services.AddTransient<IRequestHandler<GuardedCommand, string>, GuardedCommandHandler>();
        var provider = services.BuildServiceProvider();
        var dispatcher = provider.GetRequiredService<IRequestDispatcher>();

        var error = await Assert.ThrowsAsync<AuthorizationFailedException>(() =>
            dispatcher.DispatchAsync(new GuardedCommand(PermissionNames.InventoryAdjust)));

        Assert.Equal("inventory:adjust", error.Permission);
        Assert.Equal(0, log.GuardedExecuted);
        Assert.Equal(0, uow.Started);
    }

    [Fact]
    public async Task GrantedDispatch_ProceedsToExecution()
    {
        var principal = new FakePrincipal(PermissionNames.InventoryAdjust);
        var log = new FakeExecutionLog();

        var services = new ServiceCollection();
        services.AddXOptiApplication();
        services.AddScoped<ICurrentPrincipal>(_ => principal);
        services.AddSingleton<IUnitOfWork>(new FakeUnitOfWork());
        services.AddSingleton<IIdempotencyStore>(new FakeIdempotencyStore());
        services.AddSingleton(log);
        services.AddTransient<IRequestHandler<GuardedCommand, string>, GuardedCommandHandler>();
        var provider = services.BuildServiceProvider();
        var dispatcher = provider.GetRequiredService<IRequestDispatcher>();

        var result = await dispatcher.DispatchAsync(new GuardedCommand(PermissionNames.InventoryAdjust));

        Assert.Equal("guarded", result);
        Assert.Equal(1, log.GuardedExecuted);
    }
}

// ---- inventory-shaped fixture DTOs for cost visibility ----

public sealed record InventoryListingDto(string Sku, decimal QtyOnHand, Money? Cost, Money? Margin)
    : ICanMaskCosts<InventoryListingDto>
{
    public InventoryListingDto WithoutCosts() => this with { Cost = null, Margin = null };
}

public sealed record PrescriptionLookupDto(string PatientName, string? Phone, string RxSummary)
    : ICanMaskPii<PrescriptionLookupDto>
{
    public PrescriptionLookupDto WithoutPii() => this with { PatientName = "***", Phone = null };
}

public class CostMaskingTests
{
    private static readonly InventoryListingDto[] Fixture =
    {
        new("30110359", 4m, Money.From(115.57m), Money.From(222.43m)),
        new("20007096", 10m, Money.From(7.7142m), Money.From(30.2858m)),
    };

    [Fact]
    public void WithoutCostView_CostsAreOmitted()
    {
        var masked = Fixture.MaskCosts(new FakePrincipal("sales:invoice-post"));

        Assert.All(masked, item =>
        {
            Assert.Null(item.Cost);
            Assert.Null(item.Margin);
        });
        Assert.Equal("30110359", masked[0].Sku);
    }

    [Fact]
    public void WithCostView_CostsArePresent()
    {
        var visible = Fixture.MaskCosts(new FakePrincipal(PermissionNames.CostView));

        Assert.Equal(Money.From(115.57m), visible[0].Cost);
        Assert.Equal(Money.From(30.2858m), visible[1].Margin);
    }

    [Fact]
    public void SingleItem_MasksPerPermission()
    {
        Assert.Null(Fixture[0].MaskCost(new FakePrincipal()).Cost);
        Assert.NotNull(Fixture[0].MaskCost(new FakePrincipal(PermissionNames.CostView)).Cost);
    }
}

public class PiiGatingTests
{
    [Fact]
    public void WithoutPiiPermission_ContactFieldsAreMasked()
    {
        var dto = new PrescriptionLookupDto("Jane Doe", "604-555-0100", "+2.00 -1.25 x 90");

        var masked = dto.MaskPii(new FakePrincipal(PermissionNames.PrescriptionView));

        Assert.Equal("***", masked.PatientName);
        Assert.Null(masked.Phone);
        Assert.Equal("+2.00 -1.25 x 90", masked.RxSummary);
    }

    [Fact]
    public void WithPiiPermission_FullOutput()
    {
        var dto = new PrescriptionLookupDto("Jane Doe", "604-555-0100", "+2.00 -1.25 x 90");

        var full = dto.MaskPii(new FakePrincipal(PermissionNames.CustomerPii));

        Assert.Equal("Jane Doe", full.PatientName);
        Assert.Equal("604-555-0100", full.Phone);
    }

    [Fact]
    public void ListGating_MasksAllItems()
    {
        var items = new[]
        {
            new PrescriptionLookupDto("A", "1", "r1"),
            new PrescriptionLookupDto("B", "2", "r2"),
        }.ToList().MaskPii(new FakePrincipal());

        Assert.All(items, i => Assert.Equal("***", i.PatientName));
    }
}
