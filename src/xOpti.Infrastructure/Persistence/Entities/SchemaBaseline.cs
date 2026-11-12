namespace xOpti.Infrastructure.Persistence.Entities;

/// <summary>
/// One row recording which schema rebuild script produced this database and
/// whether it is still the approved baseline (platform.schema_baseline).
/// </summary>
public class SchemaBaseline
{
    /// <summary>Always 1: the table holds exactly one baseline row.</summary>
    public int Id { get; set; }

    /// <summary>Human-readable baseline label; bump when the script is regenerated.</summary>
    public string Version { get; set; } = string.Empty;

    /// <summary>SHA-256 of the executable <c>xopti-schema.sql</c>.</summary>
    public string Checksum { get; set; } = string.Empty;

    public DateTimeOffset AppliedAt { get; set; }

    /// <summary>Tool that applied the baseline (bootstrap command or manual run).</summary>
    public string AppliedBy { get; set; } = "xOpti bootstrap";
}
