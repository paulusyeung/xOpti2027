using System.Text.Json;
using System.Text.Json.Serialization;
using xOpti.Application.Authorization;

namespace xOpti.Infrastructure.Identity;

/// <summary>
/// Versioned role/permission matrix loaded from <c>permissions.v1.json</c>.
///
/// The file is the runtime source of truth for authorization. While the parity
/// matrix is unsigned it carries <c>signed: false</c> and records the parity
/// gaps; unmapped legacy levels receive no role. Loading fails fast when the
/// file references a permission outside <see cref="PermissionNames.All"/> or a
/// role that is not defined, so the vocabulary cannot drift silently.
/// </summary>
public sealed class PermissionMatrix
{
    public const string FileName = "permissions.v1.json";

    private readonly Dictionary<string, IReadOnlyList<string>> _roles;

    private PermissionMatrix(
        string version,
        bool signed,
        string? signedBy,
        string? approvedOn,
        PermissionMatrixBaseline baseline,
        IReadOnlyList<string?> parityGaps,
        IReadOnlyList<UnassignedPermission> unassignedPermissions,
        IReadOnlyList<LevelRule> levelRules,
        Dictionary<string, IReadOnlyList<string>> roles)
    {
        Version = version;
        Signed = signed;
        SignedBy = signedBy;
        ApprovedOn = approvedOn;
        Baseline = baseline;
        ParityGaps = parityGaps;
        UnassignedPermissions = unassignedPermissions;
        LevelRules = levelRules;
        _roles = roles;
    }

    public string Version { get; }

    /// <summary>False until the customer signs the parity matrix (task 3.2).</summary>
    public bool Signed { get; }

    public string? SignedBy { get; }

    public string? ApprovedOn { get; }

    public PermissionMatrixBaseline Baseline { get; }

    public IReadOnlyList<string?> ParityGaps { get; }

    /// <summary>Permissions deliberately granted to no role, with the parity reason.</summary>
    public IReadOnlyList<UnassignedPermission> UnassignedPermissions { get; }

    public IReadOnlyList<LevelRule> LevelRules { get; }

    public IReadOnlyList<string> KnownRoles => _roles.Keys.ToList();

    public IReadOnlyList<string> PermissionsForRole(string role) =>
        _roles.TryGetValue(role, out var permissions) ? permissions : Array.Empty<string>();

    public IReadOnlyList<string> PermissionsFor(IEnumerable<string> roles)
    {
        var set = new HashSet<string>(StringComparer.Ordinal);
        foreach (var role in roles)
        {
            foreach (var permission in PermissionsForRole(role))
            {
                set.Add(permission);
            }
        }

        return set.ToList();
    }

    /// <summary>
    /// Maps a legacy level to a role, or null when no rule matches. A null
    /// result means default-deny: the account gets no business claims.
    /// </summary>
    public string? RoleForLevel(int level)
    {
        foreach (var rule in LevelRules)
        {
            if (level >= rule.MinLevel)
            {
                return rule.Role;
            }
        }

        return null;
    }

    public bool IsKnownRole(string role) => _roles.ContainsKey(role);

    /// <summary>Loads and validates a matrix file.</summary>
    public static PermissionMatrix Load(string path)
    {
        if (!File.Exists(path))
        {
            throw new FileNotFoundException($"Permission matrix file not found: {path}", path);
        }

        var document = JsonSerializer.Deserialize<PermissionMatrixDocument>(
            File.ReadAllText(path),
            new JsonSerializerOptions { PropertyNameCaseInsensitive = true })
            ?? throw new InvalidOperationException($"Permission matrix file is empty: {path}");

        return Create(document, path);
    }

    /// <summary>
    /// Loads the deployed matrix, allowing an explicit path override and falling
    /// back to the repository source when running from a test/design-time output.
    /// </summary>
    public static PermissionMatrix LoadDefault(string? configuredPath = null)
    {
        if (!string.IsNullOrWhiteSpace(configuredPath))
        {
            return Load(configuredPath);
        }

        var candidate = Path.Combine(AppContext.BaseDirectory, "Identity", FileName);
        if (File.Exists(candidate))
        {
            return Load(candidate);
        }

        var directory = new DirectoryInfo(AppContext.BaseDirectory);
        while (directory is not null)
        {
            candidate = Path.Combine(directory.FullName, "src", "xOpti.Infrastructure", "Identity", FileName);
            if (File.Exists(candidate))
            {
                return Load(candidate);
            }

            directory = directory.Parent;
        }

        throw new FileNotFoundException(
            $"Could not locate {FileName}. Deploy it beside the application or set XOptiPermissions:File.");
    }

    private static PermissionMatrix Create(PermissionMatrixDocument document, string path)
    {
        if (string.IsNullOrWhiteSpace(document.Version))
        {
            throw new InvalidOperationException($"Permission matrix {path} has no version.");
        }

        if (document.Roles is null || document.Roles.Count == 0)
        {
            throw new InvalidOperationException($"Permission matrix {path} defines no roles.");
        }

        var roles = new Dictionary<string, IReadOnlyList<string>>(StringComparer.Ordinal);
        foreach (var (role, permissions) in document.Roles)
        {
            if (string.IsNullOrWhiteSpace(role))
            {
                throw new InvalidOperationException($"Permission matrix {path} contains an empty role name.");
            }

            var unknown = permissions.Where(permission => !PermissionNames.All.Contains(permission)).ToArray();
            if (unknown.Length > 0)
            {
                throw new InvalidOperationException(
                    $"Permission matrix {path} role '{role}' references unknown permissions: {string.Join(", ", unknown)}");
            }

            roles[role] = permissions.Distinct(StringComparer.Ordinal).ToArray();
        }

        // Every permission in the closed vocabulary must be either granted to a
        // role or explicitly recorded as unassigned. A missing entry means a new
        // constant silently became dead authority.
        var assigned = roles.Values.SelectMany(permissions => permissions).ToHashSet(StringComparer.Ordinal);
        var unassignedPermissions = document.UnassignedPermissions ?? [];
        foreach (var entry in unassignedPermissions)
        {
            if (!PermissionNames.All.Contains(entry.Permission))
            {
                throw new InvalidOperationException(
                    $"Permission matrix {path} marks unknown permission '{entry.Permission}' as unassigned.");
            }

            if (assigned.Contains(entry.Permission))
            {
                throw new InvalidOperationException(
                    $"Permission matrix {path} both assigns and unassigns '{entry.Permission}'.");
            }

            if (string.IsNullOrWhiteSpace(entry.Reason))
            {
                throw new InvalidOperationException(
                    $"Permission matrix {path} unassigns '{entry.Permission}' without a reason.");
            }
        }

        var covered = assigned
            .Concat(unassignedPermissions.Select(entry => entry.Permission))
            .ToHashSet(StringComparer.Ordinal);
        var missing = PermissionNames.All.Where(permission => !covered.Contains(permission)).ToArray();
        if (missing.Length > 0)
        {
            throw new InvalidOperationException(
                $"Permission matrix {path} neither assigns nor explicitly unassigns: {string.Join(", ", missing)}");
        }

        var levelRules = document.LevelRules ?? [];
        if (levelRules.Count == 0)
        {
            throw new InvalidOperationException($"Permission matrix {path} defines no level rules.");
        }

        foreach (var rule in levelRules)
        {
            if (!roles.ContainsKey(rule.Role))
            {
                throw new InvalidOperationException(
                    $"Permission matrix {path} maps level >= {rule.MinLevel} to unknown role '{rule.Role}'.");
            }
        }

        if (document.Baseline is null || string.IsNullOrWhiteSpace(document.Baseline.Source))
        {
            throw new InvalidOperationException($"Permission matrix {path} has no baseline reference.");
        }

        return new PermissionMatrix(
            document.Version,
            document.Signed,
            document.SignedBy,
            document.ApprovedOn,
            document.Baseline,
            document.ParityGaps ?? [],
            unassignedPermissions,
            levelRules,
            roles);
    }

    public sealed record LevelRule(int MinLevel, string Role);

    public sealed record UnassignedPermission(string Permission, string Reason);

    public sealed record PermissionMatrixBaseline(
        string Change,
        string Source,
        string ChecksumSha256,
        string SignOffTask);

    private sealed class PermissionMatrixDocument
    {
        public string Version { get; init; } = string.Empty;

        public bool Signed { get; init; }

        public string? SignedBy { get; init; }

        public string? ApprovedOn { get; init; }

        public PermissionMatrixBaseline? Baseline { get; init; }

        [JsonPropertyName("parityGaps")]
        public IReadOnlyList<string?>? ParityGaps { get; init; }

        public IReadOnlyList<UnassignedPermission>? UnassignedPermissions { get; init; }

        public IReadOnlyList<LevelRule>? LevelRules { get; init; }

        public Dictionary<string, List<string>>? Roles { get; init; }
    }
}
