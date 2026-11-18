using xOpti.Domain.Values;

namespace xOpti.Infrastructure.Persistence.Entities;

/// <summary>Shipping, terms snapshot, and lifecycle metadata for WC/WR documents.</summary>
public class WholesaleDocument
{
    public string TxNumber { get; set; } = string.Empty;

    public string Kind { get; set; } = string.Empty;

    public string Status { get; set; } = "draft";

    public string? TermsCode { get; set; }

    public int TermsDays { get; set; }

    public DateOnly? DueDate { get; set; }

    public string? ShippingMethod { get; set; }

    public string? ShipToName { get; set; }

    public string? ShipToAddress { get; set; }

    public string? ShippingInstructions { get; set; }

    public string? PurchaseOrderNumber { get; set; }

    public string? OriginalInvoiceNumber { get; set; }

    public DateTimeOffset CreatedAt { get; set; }

    public string? CreatedBy { get; set; }

    public DateTimeOffset? UpdatedAt { get; set; }

    public string? UpdatedBy { get; set; }

    public DateTimeOffset? PostedAt { get; set; }

    public string? PostedBy { get; set; }

    public DateTimeOffset? VoidedAt { get; set; }

    public string? VoidedBy { get; set; }

    public string? VoidReason { get; set; }
}

/// <summary>Draft payment intent; promoted to tx_payment when the document posts.</summary>
public class WholesaleTender
{
    public string TxNumber { get; set; } = string.Empty;

    public int LineNo { get; set; }

    public string Method { get; set; } = string.Empty;

    public Money Amount { get; set; }

    public string? Reference { get; set; }
}

/// <summary>Unshipped remainder linked to a posted wholesale invoice line.</summary>
public class WholesaleBackorder
{
    public long Id { get; set; }

    public string OriginalTxNumber { get; set; } = string.Empty;

    public int OriginalRowNo { get; set; }

    public int CustomerId { get; set; }

    public string Sku { get; set; } = string.Empty;

    public int OrderedQuantity { get; set; }

    public int ShippedQuantity { get; set; }

    public int RemainingQuantity { get; set; }

    public string Status { get; set; } = "draft";

    public DateTimeOffset CreatedAt { get; set; }

    public string? FulfilledByTxNumber { get; set; }

    public DateTimeOffset? FulfilledAt { get; set; }
}

/// <summary>Links a WR line to the original WC invoice line and records disposition.</summary>
public class WholesaleReturnLine
{
    public long Id { get; set; }

    public string ReturnTxNumber { get; set; } = string.Empty;

    public int ReturnRowNo { get; set; }

    public string OriginalInvoiceNumber { get; set; } = string.Empty;

    public int OriginalRowNo { get; set; }

    public string Sku { get; set; } = string.Empty;

    public int Quantity { get; set; }

    public Money UnitAmount { get; set; }

    public Money UnitCost { get; set; }

    public Money DiscountAmount { get; set; }

    public Money Amount { get; set; }

    public Money TaxA { get; set; }

    public Money TaxB { get; set; }

    public string? TaxCode { get; set; }

    public bool Restock { get; set; }

    public string? DispositionReason { get; set; }

    public DateTimeOffset CreatedAt { get; set; }
}
