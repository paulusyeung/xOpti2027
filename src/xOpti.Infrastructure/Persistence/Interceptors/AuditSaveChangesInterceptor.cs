using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Diagnostics;
using xOpti.Application.Ports;
using xOpti.Infrastructure.Persistence;
using xOpti.Infrastructure.Persistence.Entities;

namespace xOpti.Infrastructure.Persistence.Interceptors;

/// <summary>
/// SaveChanges interceptor that appends audit rows for committed changes on
/// financial/inventory entities. Payloads are allow-listed per entity type, so
/// PII columns (customer contact data, staff passwords) are never captured.
/// </summary>
public sealed class AuditSaveChangesInterceptor : SaveChangesInterceptor
{
    /// <summary>Allowed properties per audited entity; anything else is excluded.</summary>
    public static readonly IReadOnlyDictionary<Type, string[]> AllowList = new Dictionary<Type, string[]>
    {
        [typeof(TxHeader)] = new[]
        {
            "TxNumber", "ControlNumber", "TxType", "DateOfEntry", "CustomerId", "SupplierCode",
            "TotalCost", "TotalSale", "TaxA", "TaxB", "TaxC", "GrossSale", "SalesDiscount",
            "TotalAmount", "TotalQty", "ThisPaid", "Status",
        },
        [typeof(TxDetail)] = new[]
        {
            "TxNumber", "TxType", "DateOfEntry", "RowNo", "Sku", "Qty",
            "UnitAmount", "UnitCost", "Amount", "TaxCode",
        },
        [typeof(TxPayment)] = new[]
        {
            "TxNumber", "PaymentLineNo", "Type", "AmountTender", "EqAmount", "TotalThisPay",
        },
        [typeof(Inventory)] = new[]
        {
            "Sku", "AverageCost", "QtyTotalOnHand", "Name", "CategoryCode", "SupplierCode",
        },
        [typeof(InvtLotRecord)] = new[]
        {
            "Sku", "LotNo", "DateReceived", "SupplierCode", "QtyPurchased", "QtyUsed",
            "QtyOnHand", "UnitAmountPurchased", "TotalAmountPurchased",
        },
        // Financial field only: email/phone/name are PII and deliberately excluded.
        [typeof(Customer)] = new[] { "Id", "CreditLimit", "VipCode" },
    };

    private readonly IServiceProvider _services;

    public AuditSaveChangesInterceptor(IServiceProvider services)
    {
        _services = services;
    }

    public override InterceptionResult<int> SavingChanges(
        DbContextEventData eventData,
        InterceptionResult<int> result)
    {
        AppendAuditEntries(eventData.Context);
        return base.SavingChanges(eventData, result);
    }

    public override ValueTask<InterceptionResult<int>> SavingChangesAsync(
        DbContextEventData eventData,
        InterceptionResult<int> result,
        CancellationToken cancellationToken = default)
    {
        AppendAuditEntries(eventData.Context);
        return base.SavingChangesAsync(eventData, result, cancellationToken);
    }

    private void AppendAuditEntries(DbContext? context)
    {
        if (context is null)
        {
            return;
        }

        var principal = _services.GetService(typeof(ICurrentPrincipal)) as ICurrentPrincipal;
        var clock = _services.GetService(typeof(IClock)) as IClock;

        // Materialize before appending audit rows: modifying the change
        // tracker during enumeration would invalidate it.
        var candidates = context.ChangeTracker.Entries()
            .Where(e => e.State != EntityState.Unchanged && e.State != EntityState.Detached)
            .Where(e => AllowList.ContainsKey(e.Entity.GetType()))
            .ToList();

        foreach (var entry in candidates)
        {
            var allowed = AllowList[entry.Entity.GetType()];

            var changes = new Dictionary<string, object?>();
            foreach (var name in allowed)
            {
                var property = entry.Properties.FirstOrDefault(p => p.Metadata.Name == name);
                if (property is null)
                {
                    continue;
                }

                if (entry.State == EntityState.Modified && !property.IsModified)
                {
                    continue;
                }

                changes[name] = entry.State == EntityState.Deleted
                    ? property.CurrentValue
                    : property.OriginalValue?.ToString() is { } original
                        ? new { before = original, after = property.CurrentValue?.ToString() }
                        : property.CurrentValue?.ToString();
            }

            if (entry.State == EntityState.Modified && changes.Count == 0)
            {
                continue;
            }

            var action = entry.State switch
            {
                EntityState.Added => "insert",
                EntityState.Deleted => "delete",
                _ => "update",
            };

            var audit = new AuditLog
            {
                OccurredAt = clock?.UtcNow ?? DateTimeOffset.UtcNow,
                ActorUserId = principal?.UserId,
                ActorBranch = principal?.BranchCode,
                Action = action,
                EntityType = entry.Entity.GetType().Name,
                EntityId = EntityId(entry),
                Details = changes.Count > 0 ? JsonSerializer.Serialize(changes) : null,
            };

            context.Set<AuditLog>().Add(audit);
        }
    }

    private static string EntityId( Microsoft.EntityFrameworkCore.ChangeTracking.EntityEntry entry) =>
        string.Join('|', entry.Properties
            .Where(p => p.Metadata.IsKey())
            .Select(p => p.CurrentValue?.ToString() ?? string.Empty));
}
