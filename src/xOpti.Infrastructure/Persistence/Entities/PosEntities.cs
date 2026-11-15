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
