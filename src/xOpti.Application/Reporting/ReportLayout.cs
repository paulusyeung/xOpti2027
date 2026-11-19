using System.Globalization;

namespace xOpti.Application.Reporting;

/// <summary>
/// Deterministic text projection of a report used by golden tests. The PDF
/// renderer uses the same headings, ordering, and formatting.
/// </summary>
public static class ReportLayout
{
    public static IReadOnlyList<string> Build(ReportDocument document)
    {
        var lines = new List<string>
        {
            "xOpti report",
            document.Duplicate ? "DUPLICATE REPORT" : "CUSTOMER COPY",
            $"{document.Entry.Id} · {document.Entry.LogicalName}",
            $"Title {document.Entry.Title}",
            $"As of {document.AsOf.UtcDateTime:yyyy-MM-dd HH:mm:ss} UTC",
        };
        foreach (var parameter in document.Parameters.OrderBy(pair => pair.Key))
        {
            if (parameter.Value is not null)
                lines.Add($"Parameter {parameter.Key}={parameter.Value}");
        }
        lines.Add(string.Join(" | ", document.Columns.Select(column => column.Label)));
        foreach (var row in document.Rows)
        {
            lines.Add(string.Join(" | ", document.Columns.Select((column, index) =>
                Format(row[index], column.Type))));
        }
        if (document.Truncated)
            lines.Add($"TRUNCATED at {document.AppliedCap} rows");
        if (document.Stale)
            lines.Add("STALE READ MODEL");
        return lines;
    }

    public static string Format(object? value, string type) => value switch
    {
        null => string.Empty,
        DateTime date => date.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture),
        DateTimeOffset date => date.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture),
        DateOnly date => date.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture),
        decimal number when type == "money" => number.ToString("0.0000", CultureInfo.InvariantCulture),
        decimal number => number.ToString("0.####", CultureInfo.InvariantCulture),
        double number => number.ToString("0.####", CultureInfo.InvariantCulture),
        bool flag => flag ? "Yes" : "No",
        _ => Convert.ToString(value, CultureInfo.InvariantCulture) ?? string.Empty,
    };
}
