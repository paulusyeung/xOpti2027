namespace xOpti.Infrastructure.Persistence.Entities;

// Read/write projections of the migrated reference tables (3.1/3.2). They keep
// the legacy natural keys; only the columns the administration slice needs are
// mapped. All are excluded from EF migrations.

public class City
{
    public int Code { get; set; }

    public string CityName { get; set; } = string.Empty;

    public string ProvinceCode { get; set; } = string.Empty;

    public string CountryCode { get; set; } = string.Empty;

    public string? CityPhoneCode { get; set; }
}

public class Province
{
    public string ProvinceCode { get; set; } = string.Empty;

    public string ProvinceName { get; set; } = string.Empty;
}

public class Country
{
    public string CountryCode { get; set; } = string.Empty;

    public string CountryName { get; set; } = string.Empty;

    public string? CountryPhoneCode { get; set; }
}

public class Department
{
    public string DepartmentCode { get; set; } = string.Empty;

    public string? DepartmentName { get; set; }

    public bool? SummaryFlag { get; set; }
}

public class Class
{
    public string Department { get; set; } = string.Empty;

    public string ClassCode { get; set; } = string.Empty;

    public string? ClassName { get; set; }

    public bool? SummaryFlag { get; set; }
}

public class Category
{
    public string DepartmentCode { get; set; } = string.Empty;

    public string ClassCode { get; set; } = string.Empty;

    public string CategoryCode { get; set; } = string.Empty;

    public string? CategoryName { get; set; }

    public string CostingMethod { get; set; } = string.Empty;

    public string InventoryMethod { get; set; } = string.Empty;

    public string TaxMethod { get; set; } = string.Empty;

    public bool? SummaryFlag { get; set; }
}

public class Brand
{
    public string BrandCode { get; set; } = string.Empty;

    public string? BrandDescription { get; set; }
}

public class Material
{
    public string MaterialCode { get; set; } = string.Empty;

    public string? MaterialDescription { get; set; }
}

public class TaxMethod
{
    public string TaxCode { get; set; } = string.Empty;

    public string TaxName { get; set; } = string.Empty;
}

public class PaymentMethod
{
    public string PaymentCode { get; set; } = string.Empty;

    public string PaymentNameShort { get; set; } = string.Empty;

    public string PaymentNameLong { get; set; } = string.Empty;

    public double ExchangeRate { get; set; }
}

public class Supplier
{
    public string SupplierCode { get; set; } = string.Empty;

    public string? SupplierName { get; set; }

    public int? CityCode { get; set; }

    public string? Province { get; set; }

    public string? Country { get; set; }

    public string? Phone { get; set; }

    public string? ContactPerson { get; set; }

    public decimal? CreditLimit { get; set; }

    public string? PaymentTerms { get; set; }
}

public class SupplierContact
{
    public string SupCode { get; set; } = string.Empty;

    public string FirstName { get; set; } = string.Empty;

    public string Initial { get; set; } = string.Empty;

    public string LastName { get; set; } = string.Empty;

    public string? FullName { get; set; }

    public string? JobTitle { get; set; }

    public string? PhoneGeneralVoice { get; set; }

    public string? PhoneMobile { get; set; }
}

public class Doctor
{
    public int Id { get; set; }

    public string? DoctorName { get; set; }

    public string? Address { get; set; }

    public int? CityCode { get; set; }

    public string? Province { get; set; }

    public string? Country { get; set; }

    public string? Phone { get; set; }

    public string? PostalCode { get; set; }
}


public class BranchInventory
{
    public string BranchCode { get; set; } = string.Empty;

    public string Sku { get; set; } = string.Empty;

    public int QtyOnHand { get; set; }
}

public class RetailPrice
{
    public string Sku { get; set; } = string.Empty;

    public decimal? LeastSellingPrice { get; set; }

    public decimal? RetailPriceValue { get; set; }

    public decimal? RetailMarkdownAmount { get; set; }

    public double? RetailMarkdownPercent { get; set; }
}

public class WholesalePrice
{
    public string Sku { get; set; } = string.Empty;

    public decimal? SuggestedRetailPrice { get; set; }

    public decimal? GradeA { get; set; }

    public decimal? GradeB { get; set; }

    public decimal? GradeC { get; set; }
}

public class BarCodePool
{
    public int Id { get; set; }

    public string TxNumber { get; set; } = string.Empty;

    public DateTime DateOfEntry { get; set; }

    public string Sku { get; set; } = string.Empty;

    public int Qty { get; set; }
}
