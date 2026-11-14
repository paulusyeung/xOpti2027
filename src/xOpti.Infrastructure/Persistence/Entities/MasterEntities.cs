using xOpti.Domain.Values;

namespace xOpti.Infrastructure.Persistence.Entities;

public class Inventory
{
    public string Sku { get; set; } = string.Empty;

    public string DepartmentCode { get; set; } = string.Empty;

    public string ClassCode { get; set; } = string.Empty;

    public string CategoryCode { get; set; } = string.Empty;

    public string SupplierCode { get; set; } = string.Empty;

    public string BrandCode { get; set; } = string.Empty;

    public string? MaterialCode { get; set; }

    public string? Name { get; set; }

    public Money AverageCost { get; set; }

    public int QtyTotalOnHand { get; set; }

    public DateTimeOffset? DateLastIssued { get; set; }

    public bool RetailPriceFlag { get; set; }

    public bool WholesalePriceFlag { get; set; }

    public bool InventoryLotFlag { get; set; }
}

public class InvtLotRecord
{
    public string Sku { get; set; } = string.Empty;

    public string LotNo { get; set; } = string.Empty;

    public DateTimeOffset DateReceived { get; set; }

    public string SupplierCode { get; set; } = string.Empty;

    public int QtyPurchased { get; set; }

    public int QtyUsed { get; set; }

    public int QtyOnHand { get; set; }

    public Money UnitAmountPurchased { get; set; }

    public Money TotalAmountPurchased { get; set; }
}

public class Branch
{
    public string BranchCode { get; set; } = string.Empty;

    public string BranchName { get; set; } = string.Empty;

    public string? City { get; set; }

    public string? Phone { get; set; }
}

public class Customer
{
    public int Id { get; set; }

    public string? VipCode { get; set; }

    public string? FullName { get; set; }

    public string? Email { get; set; }

    public string? HomePhone { get; set; }

    public Money CreditLimit { get; set; }
}

public class Preference
{
    public string SerialNumber { get; set; } = string.Empty;

    public string Platform { get; set; } = string.Empty;

    public string ProductName { get; set; } = string.Empty;

    public string UserName { get; set; } = string.Empty;

    public string OwnerName { get; set; } = string.Empty;

    public double TaxARate { get; set; }

    public double TaxBRate { get; set; }

    public int NextInvoiceNumber { get; set; }
}

public class PrefTxNumber
{
    public string TxPrefix { get; set; } = string.Empty;

    public int TxNextNumber { get; set; }

    public string Description { get; set; } = string.Empty;

    public string? Value { get; set; }
}
