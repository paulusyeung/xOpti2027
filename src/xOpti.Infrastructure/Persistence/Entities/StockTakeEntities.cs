namespace xOpti.Infrastructure.Persistence.Entities;

public class InvtSTHeader
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public DateTime? DateOfCreation { get; set; }
    public DateTime? DateOfUpdate { get; set; }
    public DateTime? DateOfPurge { get; set; }
    public short? Status { get; set; }
}

public class InvtSTDetail
{
    public int HeaderId { get; set; }
    public string Sku { get; set; } = string.Empty;
    public double? ComputerQty { get; set; }
    public double? PhysicalQty { get; set; }
    public double? DiffQty { get; set; }
    public decimal? AverageCost { get; set; }
}

public class InvtSTImport
{
    public int HeaderId { get; set; }
    public string Sku { get; set; } = string.Empty;
    public int? Qty { get; set; }
    public int? Status { get; set; }
}

public class SupplierSummary
{
    public string SupplierCode { get; set; } = string.Empty;
    public int Year { get; set; }
    public int Month { get; set; }
    public DateTime FirstDateOfMonth { get; set; }
    public int? QtyPurchased { get; set; }
    public decimal? AmountPurchased { get; set; }
    public int? QtyRejected { get; set; }
    public decimal? AmountRejected { get; set; }
}
