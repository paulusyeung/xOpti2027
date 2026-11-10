using xOpti.Domain.Values;

namespace xOpti.Infrastructure.Persistence.Entities;

/// <summary>Mirror of the legacy tx_header table; tx_number stays the key.</summary>
public class TxHeader
{
    public string TxNumber { get; set; } = string.Empty;

    public string ControlNumber { get; set; } = string.Empty;

    public TransactionType TxType { get; set; }

    public DateTimeOffset DateOfEntry { get; set; }

    public DateTimeOffset? DateOfCreation { get; set; }

    public string? RefNumber { get; set; }

    public int CustomerId { get; set; }

    public string? SupplierCode { get; set; }

    public string? Particulars { get; set; }

    public Money TotalCost { get; set; }

    public Money TotalSale { get; set; }

    public Money TaxA { get; set; }

    public Money TaxB { get; set; }

    public Money TaxC { get; set; }

    public Money GrossSale { get; set; }

    public Money SalesDiscount { get; set; }

    public Money TotalAmount { get; set; }

    public int TotalQty { get; set; }

    public Money ThisPaid { get; set; }

    public string? Status { get; set; }

    public List<TxDetail> Details { get; set; } = new();
}

public class TxDetail
{
    public TransactionType TxType { get; set; }

    public string TxNumber { get; set; } = string.Empty;

    public DateTimeOffset DateOfEntry { get; set; }

    public double RowNo { get; set; }

    public string Sku { get; set; } = string.Empty;

    public string? Remarks { get; set; }

    public int Qty { get; set; }

    public Money UnitAmount { get; set; }

    public Money UnitCost { get; set; }

    public Money Amount { get; set; }

    public string? TaxCode { get; set; }
}

public class TxPayment
{
    public string TxNumber { get; set; } = string.Empty;

    public double PaymentLineNo { get; set; }

    public string Type { get; set; } = string.Empty;

    public string? CardNumber { get; set; }

    public Money AmountTender { get; set; }

    public Money EqAmount { get; set; }

    public Money TotalThisPay { get; set; }
}
