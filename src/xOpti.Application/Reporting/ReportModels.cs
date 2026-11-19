using System.Globalization;
using xOpti.Application.Pipeline;

namespace xOpti.Application.Reporting;

public sealed record ReportField(
    string Key, string Label, string Type, bool Sensitive = false);

public sealed record ReportReadModelDefinition(
    string Key,
    string View,
    IReadOnlyList<ReportField> Fields,
    string? DateColumn = null,
    string? BranchColumn = null,
    string? CustomerColumn = null,
    string? SkuColumn = null,
    string? DepartmentColumn = null,
    string? ClassColumn = null,
    string? CategoryColumn = null,
    string? StaffColumn = null,
    string? TxNumberColumn = null,
    string? DefaultSort = null);

public sealed record ReportColumn(string Key, string Label, string Type);

public sealed record ReportDataPage(
    IReadOnlyList<ReportColumn> Columns,
    IReadOnlyList<IReadOnlyList<object?>> Rows,
    bool Truncated,
    int AppliedCap,
    DateTimeOffset AsOf,
    bool Stale);

public sealed record ReportDocument(
    ReportCatalogueEntry Entry,
    IReadOnlyList<ReportColumn> Columns,
    IReadOnlyList<IReadOnlyList<object?>> Rows,
    IReadOnlyDictionary<string, string?> Parameters,
    bool Truncated,
    int AppliedCap,
    DateTimeOffset AsOf,
    bool Stale,
    bool Duplicate);

public static class ReportReadModels
{
    private static ReportField F(string key, string label, string type, bool sensitive = false) =>
        new(key, label, type, sensitive);

    public static readonly IReadOnlyDictionary<string, ReportReadModelDefinition> All =
        new Dictionary<string, ReportReadModelDefinition>(StringComparer.OrdinalIgnoreCase)
        {
            ["customer"] = new("customer", "reporting.v_customer",
                new[]
                {
                    F("customer_id", "Customer", "number"),
                    F("full_name", "Name", "text"),
                    F("vip_code", "VIP", "text"),
                    F("home_phone", "Phone", "text"),
                    F("email", "Email", "text"),
                    F("home_city", "City", "number"),
                    F("home_province", "Province", "text"),
                    F("credit_limit", "Credit limit", "money", true),
                    F("ttl_purchased", "Total purchased", "money", true),
                    F("last_purchase_date", "Last purchase", "date"),
                },
                CustomerColumn: "customer_id"),
            ["inventory"] = new("inventory", "reporting.v_inventory",
                new[]
                {
                    F("sku", "SKU", "text"),
                    F("name", "Name", "text"),
                    F("department_code", "Dept", "text"),
                    F("class_code", "Class", "text"),
                    F("category_code", "Category", "text"),
                    F("supplier_code", "Supplier", "text"),
                    F("brand_code", "Brand", "text"),
                    F("qty_total_on_hand", "On hand", "number"),
                    F("average_cost", "Average cost", "money", true),
                    F("retail_price", "Retail", "money"),
                    F("wholesale_a", "Wholesale A", "money"),
                    F("wholesale_b", "Wholesale B", "money"),
                    F("wholesale_c", "Wholesale C", "money"),
                },
                SkuColumn: "sku", DepartmentColumn: "department_code",
                ClassColumn: "class_code", CategoryColumn: "category_code",
                DefaultSort: "sku"),
            ["purchasing"] = new("purchasing", "reporting.v_purchasing",
                new[]
                {
                    F("tx_number", "Document", "text"),
                    F("date_of_entry", "Date", "date"),
                    F("tx_type", "Type", "text"),
                    F("supplier_code", "Supplier", "text"),
                    F("supplier_name", "Supplier name", "text"),
                    F("sku", "SKU", "text"),
                    F("qty", "Qty", "number"),
                    F("unit_cost", "Unit cost", "money", true),
                    F("amount", "Amount", "money", true),
                    F("total_amount", "Document total", "money", true),
                },
                DateColumn: "date_of_entry", SkuColumn: "sku",
                TxNumberColumn: "tx_number", DefaultSort: "date_of_entry desc,tx_number"),
            ["sales"] = new("sales", "reporting.v_sales",
                new[]
                {
                    F("tx_number", "Document", "text"),
                    F("date_of_entry", "Date", "date"),
                    F("tx_type", "Type", "text"),
                    F("customer_id", "Customer", "number"),
                    F("customer_name", "Customer name", "text"),
                    F("staff_code", "Staff", "text"),
                    F("row_no", "Line", "number"),
                    F("sku", "SKU", "text"),
                    F("qty", "Qty", "number"),
                    F("unit_amount", "Unit price", "money"),
                    F("amount", "Amount", "money"),
                    F("tax_code", "Tax", "text"),
                    F("unit_cost", "Unit cost", "money", true),
                    F("margin", "Margin", "money", true),
                },
                DateColumn: "date_of_entry", CustomerColumn: "customer_id",
                SkuColumn: "sku", StaffColumn: "staff_code",
                TxNumberColumn: "tx_number", DefaultSort: "date_of_entry,tx_number,row_no"),
            ["cost"] = new("cost", "reporting.v_cost",
                new[]
                {
                    F("tx_number", "Document", "text"),
                    F("date_of_entry", "Date", "date"),
                    F("customer_id", "Customer", "number"),
                    F("customer_name", "Customer name", "text"),
                    F("staff_code", "Staff", "text"),
                    F("sku", "SKU", "text"),
                    F("qty", "Qty", "number"),
                    F("sales", "Sales", "money"),
                    F("cost", "Cost", "money", true),
                    F("margin", "Margin", "money", true),
                    F("margin_percent", "Margin %", "number", true),
                },
                DateColumn: "date_of_entry", CustomerColumn: "customer_id",
                SkuColumn: "sku", StaffColumn: "staff_code",
                TxNumberColumn: "tx_number", DefaultSort: "date_of_entry,tx_number"),
            ["orders"] = new("orders", "reporting.v_orders",
                new[]
                {
                    F("tx_number", "Order", "text"),
                    F("date_of_entry", "Date", "date"),
                    F("customer_id", "Customer", "number"),
                    F("customer_name", "Customer name", "text"),
                    F("status", "Status", "text"),
                    F("total_amount", "Total", "money"),
                    F("this_paid", "Paid", "money"),
                    F("balance", "Balance", "money"),
                    F("age_days", "Age (days)", "number"),
                    F("ref_number", "Invoice", "text"),
                },
                DateColumn: "date_of_entry", CustomerColumn: "customer_id",
                TxNumberColumn: "tx_number", DefaultSort: "date_of_entry,tx_number"),
            ["wholesale"] = new("wholesale", "reporting.v_wholesale",
                new[]
                {
                    F("tx_number", "Document", "text"),
                    F("date_of_entry", "Date", "date"),
                    F("tx_type", "Type", "text"),
                    F("customer_id", "Customer", "number"),
                    F("customer_name", "Customer name", "text"),
                    F("status", "Status", "text"),
                    F("row_no", "Line", "number"),
                    F("sku", "SKU", "text"),
                    F("qty", "Qty", "number"),
                    F("unit_amount", "Unit price", "money"),
                    F("amount", "Amount", "money"),
                    F("total_amount", "Document total", "money"),
                    F("this_paid", "Paid", "money"),
                    F("balance", "Balance", "money"),
                },
                DateColumn: "date_of_entry", CustomerColumn: "customer_id",
                SkuColumn: "sku", TxNumberColumn: "tx_number",
                DefaultSort: "date_of_entry,tx_number,row_no"),
            ["prescriptions"] = new("prescriptions", "reporting.v_prescriptions",
                new[]
                {
                    F("customer_id", "Customer", "number"),
                    F("customer_name", "Customer name", "text"),
                    F("type", "Type", "text"),
                    F("version_number", "Version", "number"),
                    F("issued_on", "Issued", "date"),
                    F("prescriber", "Prescriber", "number"),
                    F("right_sphere", "R sphere", "number"),
                    F("right_cylinder", "R cylinder", "number"),
                    F("right_axis", "R axis", "number"),
                    F("left_sphere", "L sphere", "number"),
                    F("left_cylinder", "L cylinder", "number"),
                    F("left_axis", "L axis", "number"),
                    F("verified_at", "Verified", "date"),
                },
                DateColumn: "issued_on", CustomerColumn: "customer_id",
                DefaultSort: "issued_on desc,customer_id"),
            ["claims"] = new("claims", "reporting.v_claims",
                new[]
                {
                    F("claim_number", "Claim", "text"),
                    F("invoice_tx_number", "Invoice", "text"),
                    F("customer_id", "Customer", "number"),
                    F("customer_name", "Customer name", "text"),
                    F("plan_code", "Plan", "text"),
                    F("payer_name", "Payer", "text"),
                    F("status", "Status", "text"),
                    F("created_at", "Created", "date"),
                    F("total_billed", "Billed", "money"),
                    F("covered_amount", "Covered", "money"),
                    F("approved_amount", "Approved", "money"),
                    F("paid_amount", "Paid", "money"),
                },
                DateColumn: "created_at", CustomerColumn: "customer_id",
                TxNumberColumn: "invoice_tx_number", DefaultSort: "created_at,claim_number"),
            ["cash"] = new("cash", "reporting.v_cash",
                new[]
                {
                    F("business_date", "Business date", "date"),
                    F("branch_code", "Branch", "text"),
                    F("terminal_code", "Terminal", "text"),
                    F("status", "Status", "text"),
                    F("opening_float", "Opening float", "money"),
                    F("expected_cash", "Expected cash", "money"),
                    F("counted_cash", "Counted cash", "money"),
                    F("variance", "Variance", "money"),
                    F("closed_at", "Closed", "date"),
                },
                DateColumn: "business_date", BranchColumn: "branch_code",
                DefaultSort: "business_date,branch_code,terminal_code"),
            ["tax"] = new("tax", "reporting.v_tax",
                new[]
                {
                    F("tx_number", "Document", "text"),
                    F("date_of_entry", "Date", "date"),
                    F("tx_type", "Type", "text"),
                    F("customer_id", "Customer", "number"),
                    F("net_sales", "Net sales", "money"),
                    F("tax_a", "GST", "money"),
                    F("tax_b", "PST", "money"),
                    F("total_amount", "Total", "money"),
                },
                DateColumn: "date_of_entry", CustomerColumn: "customer_id",
                TxNumberColumn: "tx_number", DefaultSort: "date_of_entry,tx_number"),
            ["catalogue"] = new("catalogue", "reporting.v_catalogue",
                new[]
                {
                    F("kind", "Kind", "text"),
                    F("code", "Code", "text"),
                    F("name", "Name", "text"),
                    F("extra", "Detail", "text"),
                },
                DefaultSort: "kind,code"),
        };

    public static ReportReadModelDefinition Get(string key) =>
        All.TryGetValue(key, out var definition)
            ? definition
            : throw new InvalidOperationException($"Unknown report read model '{key}'.");
}

public sealed class ReportParameterValues
{
    private readonly Dictionary<string, string?> values;

    private ReportParameterValues(Dictionary<string, string?> values) => this.values = values;

    public static ReportParameterValues Bind(
        ReportCatalogueEntry entry, IReadOnlyDictionary<string, string?>? supplied)
    {
        var values = new Dictionary<string, string?>(StringComparer.OrdinalIgnoreCase);
        var errors = new List<ValidationFieldError>();
        foreach (var definition in entry.Parameters)
        {
            var raw = supplied is not null
                && supplied.TryGetValue(definition.Name, out var candidate)
                ? candidate
                : null;
            if (string.IsNullOrWhiteSpace(raw))
            {
                if (definition.Required)
                    errors.Add(new ValidationFieldError(definition.Name, "required",
                        $"{definition.Name} is required."));
                values[definition.Name] = null;
                continue;
            }

            switch (definition.Type)
            {
                case "date":
                    if (!DateOnly.TryParseExact(raw, "yyyy-MM-dd",
                            CultureInfo.InvariantCulture, DateTimeStyles.None, out var date))
                        errors.Add(new ValidationFieldError(definition.Name, "date",
                            $"{definition.Name} must be a date (yyyy-MM-dd)."));
                    else values[definition.Name] = date.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture);
                    break;
                case "number":
                    if (!int.TryParse(raw, NumberStyles.Integer, CultureInfo.InvariantCulture, out _))
                        errors.Add(new ValidationFieldError(definition.Name, "number",
                            $"{definition.Name} must be a whole number."));
                    else values[definition.Name] = raw;
                    break;
                case "percent":
                case "decimal":
                    if (!decimal.TryParse(raw, NumberStyles.Number, CultureInfo.InvariantCulture, out _))
                        errors.Add(new ValidationFieldError(definition.Name, "decimal",
                            $"{definition.Name} must be a number."));
                    else values[definition.Name] = raw;
                    break;
                case "boolean":
                    if (!bool.TryParse(raw, out var parsed)
                        && raw is not ("0" or "1" or "yes" or "no"))
                        errors.Add(new ValidationFieldError(definition.Name, "boolean",
                            $"{definition.Name} must be true or false."));
                    else values[definition.Name] = raw;
                    break;
                default:
                    values[definition.Name] = raw.Trim();
                    break;
            }
        }

        foreach (var definition in entry.Parameters.Where(p => p.Type == "date"
                     && p.Name is "AskDateFrom" or "AskLedgerDateFrom"))
        {
            var to = values.GetValueOrDefault("AskDateTo");
            if (values.GetValueOrDefault(definition.Name) is { } fromValue
                && to is not null
                && DateOnly.Parse(fromValue, CultureInfo.InvariantCulture)
                > DateOnly.Parse(to, CultureInfo.InvariantCulture))
            {
                errors.Add(new ValidationFieldError(definition.Name, "range",
                    $"{definition.Name} must not be after AskDateTo."));
            }
        }

        if (errors.Count > 0) throw new Pipeline.ValidationFailedException(errors);
        return new ReportParameterValues(values);
    }

    public string? Get(string name) => values.GetValueOrDefault(name);

    public IReadOnlyDictionary<string, string?> AsReadOnly() => values;
}
