namespace xOpti.Application.Analytics;

public sealed record AnalyticsField(string Key, string Label, string Type, bool Sensitive = false);

public sealed record AnalyticsViewDefinition(
    string Key, string Name, string ReadModel, IReadOnlyList<AnalyticsField> Fields);

public static class AnalyticsViews
{
    private static AnalyticsField F(string key, string label, string type, bool sensitive = false) =>
        new(key, label, type, sensitive);

    public static readonly IReadOnlyList<AnalyticsViewDefinition> All = new[]
    {
        new AnalyticsViewDefinition("sales_by_cost", "Sales by Cost",
            "reporting.mv_olap_sales_by_cost", new[]
            {
                F("period", "Period", "text"),
                F("branch", "Branch", "text"),
                F("department_code", "Department", "text"),
                F("class_code", "Class", "text"),
                F("category_code", "Category", "text"),
                F("sku", "SKU", "text"),
                F("qty", "Qty", "number"),
                F("sales", "Sales", "money"),
                F("cost", "Cost", "money", true),
                F("margin", "Margin", "money", true),
            }),
        new AnalyticsViewDefinition("sales_by_lsp", "Sales by LSP",
            "reporting.mv_olap_sales_by_lsp", new[]
            {
                F("period", "Period", "text"),
                F("branch", "Branch", "text"),
                F("staff_code", "Staff", "text"),
                F("qty", "Qty", "number"),
                F("sales", "Sales", "money"),
                F("cost", "Cost", "money", true),
                F("margin", "Margin", "money", true),
            }),
        new AnalyticsViewDefinition("orders_in_progress", "Orders in Progress",
            "reporting.mv_olap_orders_in_progress", new[]
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
            }),
        new AnalyticsViewDefinition("category_summary", "Category Summary",
            "reporting.mv_olap_category_summary", new[]
            {
                F("department_code", "Department", "text"),
                F("class_code", "Class", "text"),
                F("category_code", "Category", "text"),
                F("qty", "Qty", "number"),
                F("sales", "Sales", "money"),
                F("cost", "Cost", "money", true),
                F("margin", "Margin", "money", true),
            }),
    };

    public static AnalyticsViewDefinition Get(string key) =>
        All.FirstOrDefault(view => view.Key.Equals(key, StringComparison.OrdinalIgnoreCase))
        ?? throw new InvalidOperationException($"Unknown analytics view '{key}'.");
}

public sealed record AnalyticsFeedDto(
    string ViewKey, string Name, IReadOnlyList<AnalyticsField> Fields,
    IReadOnlyList<IReadOnlyList<object?>> Data, DateTimeOffset AsOf, bool Stale,
    bool Truncated, int RowCap);

public sealed record AnalyticsViewDto(
    long Id, string ViewKey, string Name, bool IsShared, string OwnerUserId,
    string ConfigJson, DateTimeOffset CreatedAt, DateTimeOffset UpdatedAt,
    bool CanEdit);

public interface IAnalyticsStore
{
    Task<AnalyticsFeedDto> GetFeedAsync(string viewKey, string? from, string? to,
        string? branch, string? staff, string? department, string? classCode,
        string? category, bool includeSensitive, int rowCap, CancellationToken ct);

    Task<IReadOnlyList<AnalyticsViewDto>> ListSavedAsync(string ownerUserId,
        CancellationToken ct);

    Task<AnalyticsViewDto> SaveAsync(string viewKey, string name, bool isShared,
        string configJson, string ownerUserId, CancellationToken ct);

    Task<AnalyticsViewDto?> GetSavedAsync(long id, string userId, CancellationToken ct);

    Task DeleteSavedAsync(long id, string userId, CancellationToken ct);
}
