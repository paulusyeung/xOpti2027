using xOpti.Application.Authorization;
using xOpti.Application.Pipeline;
using xOpti.Application.Ports;

namespace xOpti.Application.Reporting;

public sealed record ReportCatalogueEntry(
    string Id,
    string LogicalName,
    string Title,
    string Subject,
    string ParameterSpec,
    string ReadModel,
    string LayoutKey,
    string Permission,
    int RowCap,
    string Criticality,
    bool CriticalDocument,
    string InScope,
    string SignoffStatus,
    string SourceFile)
{
    public IReadOnlyList<ReportParameterDefinition> Parameters =>
        ReportParameterDefinition.ParseAll(ParameterSpec);

    public IReadOnlyList<string> RequiredPermissions =>
        Permission == PermissionNames.CostView
            ? new[] { PermissionNames.ReportFinancial, PermissionNames.CostView }
            : new[] { Permission };
}

public sealed record ReportParameterDefinition(
    string Name,
    string Type,
    bool Required)
{
    public static IReadOnlyList<ReportParameterDefinition> ParseAll(string spec)
    {
        if (string.IsNullOrWhiteSpace(spec)) return Array.Empty<ReportParameterDefinition>();
        return spec.Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries)
            .Select(part =>
            {
                var pieces = part.Split(':', 2);
                var name = pieces[0].Trim();
                var type = pieces.Length > 1 ? pieces[1].Trim().ToLowerInvariant() : "text";
                var required = type == "date" && name is "AskDateFrom" or "AskDateTo";
                return new ReportParameterDefinition(name, type, required);
            })
            .ToList();
    }
}

public interface IReportCatalogue
{
    IReadOnlyList<ReportCatalogueEntry> All { get; }

    ReportCatalogueEntry Get(string id);
}

public sealed class ReportCatalogue : IReportCatalogue
{
    private readonly Dictionary<string, ReportCatalogueEntry> byId;

    public ReportCatalogue()
    {
        All = ReportCatalogueData.All;
        byId = All.ToDictionary(entry => entry.Id, StringComparer.OrdinalIgnoreCase);
    }

    public IReadOnlyList<ReportCatalogueEntry> All { get; }

    public ReportCatalogueEntry Get(string id) =>
        byId.TryGetValue(id, out var entry)
            ? entry
            : throw new ValidationFailedException(new[]
            {
                new ValidationFieldError("ReportId", "not-catalogued",
                    $"Report '{id}' is not in the approved Richmond catalogue."),
            });
}

public static class ReportAuthorization
{
    public static void EnsureAllowed(ReportCatalogueEntry entry, ICurrentPrincipal principal)
    {
        foreach (var permission in entry.RequiredPermissions)
        {
            if (!principal.HasPermission(permission))
            {
                throw new AuthorizationFailedException(permission,
                    $"report:{entry.Id}");
            }
        }
    }
}
