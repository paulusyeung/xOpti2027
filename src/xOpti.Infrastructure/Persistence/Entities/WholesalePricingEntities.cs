using xOpti.Domain.Values;

namespace xOpti.Infrastructure.Persistence.Entities;

/// <summary>Immutable published wholesale price list version.</summary>
public class WholesalePriceList
{
    public long Id { get; set; }

    public string Code { get; set; } = string.Empty;

    public string Name { get; set; } = string.Empty;

    public int Version { get; set; }

    public bool IsCurrent { get; set; }

    public DateTimeOffset CreatedAt { get; set; }

    public string? CreatedBy { get; set; }
}

public class WholesalePriceListItem
{
    public long Id { get; set; }

    public long PriceListId { get; set; }

    public string Sku { get; set; } = string.Empty;

    public Money Price { get; set; }
}

/// <summary>
/// Snapshot of the price-list version and applied price for a wholesale
/// document line. Later list changes never reprice the stored line.
/// </summary>
public class WholesaleDocumentLine
{
    public string TxNumber { get; set; } = string.Empty;

    public double RowNo { get; set; }

    public string PriceListCode { get; set; } = string.Empty;

    public int PriceListVersion { get; set; }

    public Money ListUnitPrice { get; set; }

    public Money AppliedUnitPrice { get; set; }

    public Money TaxA { get; set; }

    public Money TaxB { get; set; }

    public bool IsOverride { get; set; }

    public string? OverrideReason { get; set; }

    public string? OverrideBy { get; set; }

    public DateTimeOffset CreatedAt { get; set; }
}
