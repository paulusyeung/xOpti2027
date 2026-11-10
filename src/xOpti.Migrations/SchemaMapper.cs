namespace xOpti.Migrations;

public sealed record ColumnMap(StagingColumn Source, TargetColumn Target, string SelectExpression);

public sealed class TableMap
{
    public required StagingTable Source { get; init; }
    public required TargetTable Target { get; init; }
    public required IReadOnlyList<ColumnMap> Columns { get; init; }
    public required IReadOnlyList<string> UnmatchedTargetColumns { get; init; }
    public required IReadOnlyList<string> UnmatchedSourceColumns { get; init; }
    public bool HasPrimaryKey => Target.PrimaryKey.Count > 0;
}

public static class SchemaMapper
{
    /// <summary>Target line-number columns that must be integer-rounded from drifting REAL sources.</summary>
    public static readonly HashSet<string> LineNumberColumns = new(StringComparer.Ordinal)
    {
        "row_no", "line_number", "payment_line_no", "sales_row_no",
    };

    public static TargetTable? FindTarget(StagingTable source, IReadOnlyDictionary<string, TargetTable> catalog)
    {
        foreach (var t in catalog.Values)
            if (t.CanonicalName == source.CanonicalName)
                return t;
        return null;
    }

    public static TableMap Build(StagingTable source, TargetTable target)
    {
        var targetByCanon = new Dictionary<string, TargetColumn>(StringComparer.Ordinal);
        var ambiguous = new HashSet<string>(StringComparer.Ordinal);
        foreach (var col in target.Columns)
        {
            var canon = NameNormalizer.Canonical(col.Name);
            if (!targetByCanon.TryAdd(canon, col))
                ambiguous.Add(canon);
        }

        var maps = new List<ColumnMap>();
        var matchedTargets = new HashSet<string>(StringComparer.Ordinal);
        var unmatchedSource = new List<string>();

        foreach (var col in source.Columns)
        {
            var sourceCanon = NameNormalizer.Canonical(col.Name);
            var corrected = NameNormalizer.KnownColumnRenames.GetValueOrDefault((source.CanonicalName, sourceCanon));
            var lookupCanon = corrected is not null ? NameNormalizer.Canonical(corrected) : sourceCanon;

            if (ambiguous.Contains(lookupCanon) || !targetByCanon.TryGetValue(lookupCanon, out var targetCol))
            {
                unmatchedSource.Add(col.Name);
                continue;
            }

            maps.Add(new ColumnMap(col, targetCol, BuildExpression(col, targetCol)));
            matchedTargets.Add(targetCol.Name);
        }

        var unmatchedTarget = target.Columns
            .Where(c => !matchedTargets.Contains(c.Name))
            .Select(c => c.Name)
            .ToList();

        return new TableMap
        {
            Source = source,
            Target = target,
            Columns = maps,
            UnmatchedTargetColumns = unmatchedTarget,
            UnmatchedSourceColumns = unmatchedSource,
        };
    }

    /// <summary>
    /// Pure normalization/cast expression for a staging (text) column mapped to a typed target column.
    /// </summary>
    public static string BuildExpression(StagingColumn source, TargetColumn target)
    {
        var raw = "e." + Quote(source.Name);
        var trimmedNull = "NULLIF(BTRIM(" + raw + "), '')";

        if (target.DataType == "boolean")
        {
            return "CASE WHEN " + raw + " IS NULL THEN NULL " +
                   "WHEN BTRIM(" + raw + ") IN ('-1', '1', 'True', 'true', 'TRUE', 'Yes', 'yes', 'Y', 'y', 't') THEN TRUE " +
                   "WHEN BTRIM(" + raw + ") IN ('0', 'False', 'false', 'FALSE', 'No', 'no', 'N', 'n', 'f') THEN FALSE " +
                   "ELSE NULL END";
        }

        switch (target.DataType)
        {
            case "smallint" or "integer" or "bigint":
                // The numeric hop absorbs REAL drift such as 1.00000004 before rounding to integer.
                return "(" + trimmedNull + "::numeric)";

            case "numeric":
                return trimmedNull + "::numeric";

            case "double precision" or "real":
                if (source.IsReal && LineNumberColumns.Contains(target.Name))
                    return "ROUND(" + trimmedNull + "::numeric)::integer::double precision";
                return trimmedNull + "::double precision";

            case "timestamp without time zone" or "timestamp with time zone" or "date":
                return trimmedNull + "::" + target.DataType;

            case "text":
                return "NULLIF(" + raw + ", '')";

            case "character varying":
                return target.MaxLength is int len
                    ? "NULLIF(" + raw + ", '')::varchar(" + len + ")"
                    : "NULLIF(" + raw + ", '')::text";

            default:
                return trimmedNull + "::" + target.DataType;
        }
    }

    public static string Quote(string identifier) => "\"" + identifier.Replace("\"", "\"\"") + "\"";
}
