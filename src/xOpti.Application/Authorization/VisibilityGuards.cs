using xOpti.Application.Ports;

namespace xOpti.Application.Authorization;

/// <summary>A read DTO whose cost/margin members can be withheld.</summary>
public interface ICanMaskCosts<TSelf>
{
    TSelf WithoutCosts();
}

/// <summary>A read DTO whose customer contact/PII members can be withheld.</summary>
public interface ICanMaskPii<TSelf>
{
    TSelf WithoutPii();
}

/// <summary>
/// Handler-side enforcement of the legacy pyUserHasCostLevel replacement:
/// clears cost/margin DTO members unless the principal holds <c>cost:view</c>.
/// </summary>
public static class CostGuard
{
    public static IReadOnlyList<T> MaskCosts<T>(this IReadOnlyList<T> items, ICurrentPrincipal principal)
        where T : ICanMaskCosts<T> =>
        principal.HasPermission(PermissionNames.CostView)
            ? items
            : items.Select(i => i.WithoutCosts()).ToList();

    public static T MaskCost<T>(this T item, ICurrentPrincipal principal)
        where T : ICanMaskCosts<T> =>
        principal.HasPermission(PermissionNames.CostView) ? item : item.WithoutCosts();
}

/// <summary>
/// Clears identifying contact members unless the principal holds
/// <c>customer:pii</c>.
/// </summary>
public static class PiiGuard
{
    public static IReadOnlyList<T> MaskPii<T>(this IReadOnlyList<T> items, ICurrentPrincipal principal)
        where T : ICanMaskPii<T> =>
        principal.HasPermission(PermissionNames.CustomerPii)
            ? items
            : items.Select(i => i.WithoutPii()).ToList();

    public static T MaskPii<T>(this T item, ICurrentPrincipal principal)
        where T : ICanMaskPii<T> =>
        principal.HasPermission(PermissionNames.CustomerPii) ? item : item.WithoutPii();
}
