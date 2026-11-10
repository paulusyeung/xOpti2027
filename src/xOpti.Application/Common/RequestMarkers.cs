namespace xOpti.Application.Common;

/// <summary>Requests that need an idempotency key (sales, invoices, payments).</summary>
public interface IRequiresIdempotencyKey
{
    string? IdempotencyKey { get; }
}

/// <summary>Requests declaring the permission claims they require.</summary>
public interface IHasPermissions
{
    IReadOnlyList<string> RequiredPermissions { get; }
}
