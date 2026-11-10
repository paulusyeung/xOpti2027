using System.Text;

namespace xOpti.Migrations;

public sealed class MigrationConfig
{
    public required string SynergyMdbPath { get; init; }
    public required string TargetConnectionString { get; init; }
    public string? ReferenceConnectionString { get; init; }
    public string LegacySchema { get; init; } = "legacy";
    public string MigrationSchema { get; init; } = "migration";
    public decimal Tolerance { get; init; } = 0.005m;
    public required string ReportsDirectory { get; init; }
    public required string RepositoryRoot { get; init; }

    public static MigrationConfig Load(string? envFile, decimal? toleranceOverride = null)
    {
        var root = FindRepositoryRoot();
        var path = envFile is not null
            ? Path.GetFullPath(envFile)
            : Path.Combine(root, "eOptical6DAO", ".env");

        var values = new Dictionary<string, string?>(StringComparer.OrdinalIgnoreCase);
        if (File.Exists(path))
        {
            foreach (var raw in File.ReadLines(path))
            {
                var line = raw.Trim();
                if (line.Length == 0 || line.StartsWith('#') || !line.Contains('='))
                    continue;
                var idx = line.IndexOf('=');
                var key = line[..idx].Trim();
                var value = line[(idx + 1)..].Trim().Trim('\'', '"');
                values[key] = value;
            }
        }

        string? Get(string key) =>
            Environment.GetEnvironmentVariable(key) is { Length: > 0 } env ? env : values.GetValueOrDefault(key);

        var missing = new List<string>();
        var mdb = Get("SYNERGY_MDB");
        var target = Get("XOPTI_DATABASE_URL");
        if (string.IsNullOrWhiteSpace(mdb)) missing.Add("SYNERGY_MDB");
        if (string.IsNullOrWhiteSpace(target)) missing.Add("XOPTI_DATABASE_URL");
        if (missing.Count > 0)
            throw new MigrationException(
                $"Missing required configuration: {string.Join(", ", missing)}. " +
                $"Set the environment variables or provide {path} (see tools/legacy-migration/README.md).");

        var tolerance = toleranceOverride
            ?? (decimal.TryParse(Get("MIGRATION_TOLERANCE"), out var t) ? t : 0.005m);

        return new MigrationConfig
        {
            SynergyMdbPath = Environment.ExpandEnvironmentVariables(mdb!).Replace("~/", Environment.GetFolderPath(Environment.SpecialFolder.UserProfile) + "/"),
            TargetConnectionString = target!,
            ReferenceConnectionString = Get("DATABASE_URL"),
            Tolerance = tolerance,
            ReportsDirectory = Path.Combine(root, "tools", "legacy-migration", "reports"),
            RepositoryRoot = root,
        };
    }

    private static string FindRepositoryRoot()
    {
        var dir = new DirectoryInfo(AppContext.BaseDirectory);
        while (dir is not null &&
               !File.Exists(Path.Combine(dir.FullName, "xOpti.sln")) &&
               !File.Exists(Path.Combine(dir.FullName, "xOpti.slnx")))
            dir = dir.Parent;
        if (dir is null)
            throw new MigrationException("Could not locate repository root (xOpti.sln). Run the tool from within the repository.");
        return dir.FullName;
    }
}

public sealed class MigrationException : Exception
{
    public MigrationException(string message) : base(message) { }
}

public static class CommandLine
{
    public sealed record Options(
        string Command,
        bool DryRun,
        string? EnvFile,
        decimal? Tolerance,
        HashSet<string>? OnlyTables,
        bool ShowHelp);

    public const string Help = """
        xOpti.Migrations - legacy SynergyV.mdb -> PostgreSQL xOpti migration runner

        Usage: xOpti.Migrations <command> [options]

        Commands:
          extract     Stream every MDB table into the PostgreSQL legacy staging schema
          stage       Validate the staged snapshot (counts vs. reference mirror)
          transform   Set-based idempotent upserts from legacy into the target schema
          reconcile   Row-count, aggregate, sequence, and anomaly checks; writes reports
          sync        extract + transform (freeze-window refresh, captures in-place edits)
          cutover     sync + reconcile; fails unless every reconciliation check passes

        Options:
          --dry-run           Execute staging, transforms, and checks, then roll back
          --env-file <path>   .env file (default: eOptical6DAO/.env)
          --tolerance <n>     Absolute money tolerance for reconciliation (default 0.005)
          --only <a,b,c>      Restrict extract/transform to the named source tables
          -h, --help          Show this help

        Required configuration (environment or .env):
          SYNERGY_MDB          Path to the legacy Access database
          XOPTI_DATABASE_URL   Target PostgreSQL connection string
          DATABASE_URL         Optional read-only reference (Synergy5 mirror) for stage validation
        """;

    public static Options Parse(string[] args)
    {
        if (args.Length == 0 || args[0] is "-h" or "--help" or "help")
            return new Options("", true, null, null, null, ShowHelp: true);

        var known = new[] { "extract", "stage", "transform", "reconcile", "sync", "cutover" };
        var command = args[0].ToLowerInvariant();
        if (!known.Contains(command))
            throw new MigrationException($"Unknown command '{args[0]}'. Try --help.");

        bool dryRun = false;
        string? envFile = null;
        decimal? tolerance = null;
        HashSet<string>? only = null;

        for (var i = 1; i < args.Length; i++)
        {
            switch (args[i])
            {
                case "--dry-run":
                    dryRun = true;
                    break;
                case "--env-file":
                    envFile = Require(args, ref i, "--env-file");
                    break;
                case "--tolerance":
                    var raw = Require(args, ref i, "--tolerance");
                    if (!decimal.TryParse(raw, out var parsed) || parsed < 0)
                        throw new MigrationException($"--tolerance expects a non-negative number, got '{raw}'.");
                    tolerance = parsed;
                    break;
                case "--only":
                    var list = Require(args, ref i, "--only");
                    only = new HashSet<string>(
                        list.Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries),
                        StringComparer.OrdinalIgnoreCase);
                    break;
                case "-h" or "--help":
                    return new Options(command, dryRun, envFile, tolerance, only, ShowHelp: true);
                default:
                    throw new MigrationException($"Unknown option '{args[i]}'. Try --help.");
            }
        }

        return new Options(command, dryRun, envFile, tolerance, only, ShowHelp: false);
    }

    private static string Require(string[] args, ref int i, string name)
    {
        if (i + 1 >= args.Length)
            throw new MigrationException($"{name} requires a value.");
        return args[++i];
    }
}
