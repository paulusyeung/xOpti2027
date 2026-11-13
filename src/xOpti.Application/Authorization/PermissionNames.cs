namespace xOpti.Application.Authorization;

/// <summary>
/// Closed set of permission claims replacing the legacy integer SecurityLevel.
/// Claim names are kebab-case `<resource>:<action>`. Mapped entries are derived
/// from the legacy security gates: the Security table's Cost flag (IsCostOK /
/// pyUserHasCostLevel), and the module-level gates enforced via
/// GetUserSecurity thresholds in the legacy UI (sales override, stock
/// adjustment, receiving, customer PII, financial reporting).
/// </summary>
public static class PermissionNames
{
    /// <summary>View supplier cost and margin data (legacy Security.Cost via IsCostOK/pyUserHasCostLevel).</summary>
    public const string CostView = "cost:view";

    /// <summary>Perform stock adjustments (legacy SJ flow).</summary>
    public const string InventoryAdjust = "inventory:adjust";

    /// <summary>Read financial reports and balances.</summary>
    public const string ReportFinancial = "report:financial";

    /// <summary>Read customer PII/contact details.</summary>
    public const string CustomerPii = "customer:pii";

    /// <summary>Receive stock from suppliers (legacy SR flow).</summary>
    public const string InventoryReceive = "inventory:receive";

    /// <summary>Override line pricing at the POS (legacy price wizard gate).</summary>
    public const string SalesPriceOverride = "sales:price-override";

    /// <summary>Enter and post sale orders (legacy SA flow).</summary>
    public const string SalesOrderCreate = "sales:order-create";

    /// <summary>Post retail invoices and refunds (legacy RC/RS flow).</summary>
    public const string SalesInvoicePost = "sales:invoice-post";

    /// <summary>Post wholesale invoices and returns (legacy WC/WR flow).</summary>
    public const string WholesaleInvoicePost = "wholesale:invoice-post";

    /// <summary>Enter prescriptions (legacy customer_pres_* write path).</summary>
    public const string PrescriptionEnter = "prescription:enter";

    /// <summary>View prescription clinical detail.</summary>
    public const string PrescriptionView = "prescription:view";

    /// <summary>Maintain master data (customers, suppliers, staff, items).</summary>
    public const string MasterDataMaintain = "master-data:maintain";

    /// <summary>View staff contact and payroll PII (provisional addition pending matrix sign-off).</summary>
    public const string StaffPii = "staff:pii";

    public static readonly IReadOnlyList<string> All = new[]
    {
        CostView, InventoryAdjust, ReportFinancial, CustomerPii, InventoryReceive,
        SalesPriceOverride, SalesOrderCreate, SalesInvoicePost, WholesaleInvoicePost,
        PrescriptionEnter, PrescriptionView, MasterDataMaintain, StaffPii,
    };
}
