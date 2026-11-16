namespace xOpti.Infrastructure.Persistence.Entities;

public class TxSalePerson
{
    public string TxNumber { get; set; } = string.Empty;
    public double SalesRowNo { get; set; }
    public string StaffCode { get; set; } = string.Empty;
}

public class TxSOrderAdd
{
    public string TxNumber { get; set; } = string.Empty;
    public double LineNumber { get; set; }
    public string? Supplier { get; set; }
    public string? Brand { get; set; }
    public string? Model { get; set; }
}

public class TxSOrderExtra
{
    public string TxNumber { get; set; } = string.Empty;
    public bool? Redo { get; set; }
    public bool? Warranty { get; set; }
    public bool? Mail { get; set; }
    public bool? Msd { get; set; }
    public int? Remarks { get; set; }
}

/// <summary>App-owned link from a refund line to the original invoice line.</summary>
public class SalesRefundLine
{
    public string RefundTxNumber { get; set; } = string.Empty;

    public double RefundRowNo { get; set; }

    public string OriginalTxNumber { get; set; } = string.Empty;

    public double OriginalRowNo { get; set; }

    public int Quantity { get; set; }

    public bool Restocked { get; set; }

    public decimal TaxA { get; set; }

    public decimal TaxB { get; set; }
}

/// <summary>App-owned link from a refund tender to the original payment line.</summary>
public class SalesRefundTender
{
    public string RefundTxNumber { get; set; } = string.Empty;

    public double PaymentLineNo { get; set; }

    public string OriginalTxNumber { get; set; } = string.Empty;

    public double OriginalPaymentLineNo { get; set; }

    public decimal Amount { get; set; }

    public string Method { get; set; } = string.Empty;
}
