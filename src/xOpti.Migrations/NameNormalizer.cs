using System.Text;

namespace xOpti.Migrations;

public static class NameNormalizer
{
    /// <summary>Lowercase and strip everything that is not a-z/0-9 (e.g. "tx_number" and "txnumber" both map to "txnumber").</summary>
    public static string Canonical(string value)
    {
        var sb = new StringBuilder(value.Length);
        foreach (var c in value)
        {
            if (char.IsAsciiLetterOrDigit(c))
                sb.Append(char.ToLowerInvariant(c));
        }
        return sb.ToString();
    }

    // Source-side typos corrected in the target schema (same map the comparison tool uses).
    public static readonly Dictionary<(string Table, string Column), string> KnownColumnRenames = new()
    {
        [("preference", "paltform")] = "platform",
        [("txsorderlens", "rigthbase")] = "right_base",
        [("txsorderlens", "rigthoc")] = "right_oc",
    };
}

public sealed record StagingColumn(string Name, string SqlType)
{
    public string CanonicalName => NameNormalizer.Canonical(Name);
    public bool IsReal => SqlType.Equals("REAL", StringComparison.OrdinalIgnoreCase)
                          || SqlType.StartsWith("REAL ", StringComparison.OrdinalIgnoreCase);
}

public sealed record StagingTable(string Name, IReadOnlyList<StagingColumn> Columns)
{
    public string CanonicalName => NameNormalizer.Canonical(Name);
}
