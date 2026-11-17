using xOpti.Application.Authorization;

namespace xOpti.Application.Customers;

/// <summary>Search/list projection. Contact fields are masked without customer:pii.</summary>
public sealed record CustomerSummaryDto(
    int Id, string? VipCode, string? DisplayName, string? HomePhone, string? Email,
    string? HomeCity, string? AccountNumber)
    : ICanMaskPii<CustomerSummaryDto>
{
    public CustomerSummaryDto WithoutPii() => this with
    {
        DisplayName = DisplayName is null ? null : "***",
        HomePhone = null,
        Email = null,
        HomeCity = null,
        AccountNumber = null,
    };
}

/// <summary>Customer detail projection; protected fields are cleared without customer:pii.</summary>
public sealed record CustomerDetailDto(
    int Id, string? VipCode, string? Salutation, string? FirstName, string? Initial,
    string? LastName, string? FullName, DateTimeOffset? Birthday,
    string? HomeAddress, int HomeCity, string? HomeProvince, string? HomePostalCode,
    string? HomeCountry, string? HomePhone, string? HomeFax, string? Cellular, string? Email,
    string? BizCompanyName, string? BizJobTitle, string? BizAddress, int BizCity,
    string? BizProvince, string? BizPostalCode, string? BizCountry, string? BizPhone,
    string? BizFax, decimal CreditLimit, string? PaymentTerms, double VipMarkDownPct,
    bool? SummaryFlag, bool? AccountingFlag, string? Remarks)
    : ICanMaskPii<CustomerDetailDto>
{
    public CustomerDetailDto WithoutPii() => this with
    {
        Salutation = null,
        FirstName = FirstName is null ? null : "***",
        Initial = null,
        LastName = LastName is null ? null : "***",
        FullName = FullName is null ? null : "***",
        Birthday = null,
        HomeAddress = null,
        HomeCity = 0,
        HomeProvince = null,
        HomePostalCode = null,
        HomeCountry = null,
        HomePhone = null,
        HomeFax = null,
        Cellular = null,
        Email = null,
        BizCompanyName = null,
        BizJobTitle = null,
        BizAddress = null,
        BizCity = 0,
        BizProvince = null,
        BizPostalCode = null,
        BizCountry = null,
        BizPhone = null,
        BizFax = null,
        Remarks = null,
    };
}

public sealed record CustomerAccountDto(
    int CustomerId, DateTimeOffset? JointDate,
    decimal TtlAmtPurchased, decimal TtlAmtRefund, decimal TtlAmtMrkdwnApplied,
    decimal TtlAmtCpnUsed, decimal YtdAmtPurchased, decimal YtdAmtRefund,
    decimal YtdAmtMrkdwnApplied, decimal YtdAmtCpnUsed, DateTimeOffset? LastPurchaseDate);

public sealed record CustomerMedicalDto(
    int CustomerId, DateTimeOffset? InsMaturityDate, string? CareCardNo,
    string? CareCardValidPeriod, string? CareCardType, bool? PrescriptionLensFlag,
    bool? PrescriptionContactFlag);

public sealed record CustomerPrescriptionSummaryDto(
    int CustomerId, string Type, DateTimeOffset? IssuedOn, int IssuedBy,
    string Summary);

public sealed record CustomerPrescriptionDetailDto(
    int CustomerId, string Type, DateTimeOffset? IssuedOn, int IssuedBy,
    double RightSphere, double RightCylinder, int RightAxis,
    double LeftSphere, double LeftCylinder, int LeftAxis,
    double? RightAdd, double? LeftAdd, double? RightPdDist, double? LeftPdDist,
    double? RightPrism, double? LeftPrism, string? Notes);

public sealed record CustomerViewDto(CustomerDetailDto Customer, int? ResolvedFrom);

public sealed record CustomerDuplicateDto(
    int Id, string? FullName, string? HomePhone, string? Email, string Reason)
    : ICanMaskPii<CustomerDuplicateDto>
{
    public CustomerDuplicateDto WithoutPii() => this with
    {
        FullName = FullName is null ? null : "***",
        HomePhone = null,
        Email = null,
    };
}

public sealed record CustomerBalanceDto(
    int CustomerId, decimal Charges, decimal Payments, decimal Refunds, decimal Balance,
    decimal CreditLimit, bool OverCreditLimit);

public sealed record CustomerPurchaseDto(
    string TxNumber, string TxType, DateTimeOffset DateOfEntry, decimal TotalSale,
    decimal TaxA, decimal TaxB, decimal TotalAmount, decimal Paid, string? Status,
    string? RefNumber);

public sealed record CustomerHistoryDto(
    int CustomerId, IReadOnlyList<CustomerPurchaseDto> Items);

public sealed record CustomerStatementDto(
    int CustomerId, DateOnly From, DateOnly To, decimal OpeningBalance,
    decimal Charges, decimal Payments, decimal Refunds, decimal ClosingBalance,
    IReadOnlyList<CustomerPurchaseDto> Items);

public sealed record CustomerInput(
    string? VipCode, string? Salutation, string? FirstName, string? Initial,
    string? LastName, string? FullName, DateTimeOffset? Birthday,
    string? HomeAddress, int HomeCity, string? HomeProvince, string? HomePostalCode,
    string? HomeCountry, string? HomePhone, string? HomeFax, string? Cellular, string? Email,
    string? BizCompanyName, string? BizJobTitle, string? BizAddress, int BizCity,
    string? BizProvince, string? BizPostalCode, string? BizCountry, string? BizPhone,
    string? BizFax, decimal CreditLimit, string? PaymentTerms, double VipMarkDownPct,
    bool? SummaryFlag, bool? AccountingFlag, string? Remarks);

public interface ICustomerStore
{
    Task<CustomerDetailDto?> GetAsync(int customerId, CancellationToken ct);
    Task<int?> ResolveCanonicalIdAsync(int customerId, CancellationToken ct);
    Task<IReadOnlyList<int>> ResolveGroupIdsAsync(int canonicalId, CancellationToken ct);
    Task<CustomerBalanceDto?> GetBalanceAsync(int canonicalId, CancellationToken ct);
    Task<IReadOnlyList<CustomerPurchaseDto>> GetHistoryAsync(
        IReadOnlyList<int> customerIds, DateOnly? from, DateOnly? to, CancellationToken ct);
    Task<(IReadOnlyList<CustomerSummaryDto> Items, bool HasMore)> SearchAsync(
        string? search, int? afterId, int limit, CancellationToken ct);
    Task<IReadOnlyList<CustomerDuplicateDto>> FindDuplicatesAsync(
        CustomerInput input, int? excludeCustomerId, CancellationToken ct);
    Task<int> CreateAsync(CustomerInput input, CancellationToken ct);
    Task UpdateAsync(int customerId, CustomerInput input, CancellationToken ct);
    Task MergeAsync(int sourceId, int targetId, string? phone, string? email, string? fullName,
        string reason, string? actor, CancellationToken ct);
}
