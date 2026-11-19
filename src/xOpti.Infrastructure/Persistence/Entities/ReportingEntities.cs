namespace xOpti.Infrastructure.Persistence.Entities;

public class ReadModelState
{
    public string ModelKey { get; set; } = string.Empty;
    public DateTimeOffset? AsOf { get; set; }
    public DateTimeOffset? RefreshStartedAt { get; set; }
    public DateTimeOffset? RefreshCompletedAt { get; set; }
    public long? RowCount { get; set; }
    public string? LastError { get; set; }
}

public class ReportRun
{
    public long Id { get; set; }
    public string CatalogueId { get; set; } = string.Empty;
    public string? Actor { get; set; }
    public string? Branch { get; set; }
    public string ParametersJson { get; set; } = "{}";
    public DateTimeOffset GeneratedAt { get; set; }
    public bool Duplicate { get; set; }
    public int RowCount { get; set; }
    public bool Truncated { get; set; }
}

public class AnalyticsSavedView
{
    public long Id { get; set; }
    public string ViewKey { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public string OwnerUserId { get; set; } = string.Empty;
    public bool IsShared { get; set; }
    public string ConfigJson { get; set; } = "{}";
    public DateTimeOffset CreatedAt { get; set; }
    public DateTimeOffset UpdatedAt { get; set; }
}
