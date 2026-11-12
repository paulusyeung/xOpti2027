using System.Security.Cryptography;
using System.Text;

namespace xOpti.Infrastructure.Bootstrap;

/// <summary>
/// Loads the canonical <c>xopti-schema.sql</c> rebuild script.
///
/// The file is a <c>pg_dump</c> snapshot, so it is not idempotent and contains
/// psql meta-commands (<c>\restrict</c>/<c>\unrestrict</c>) that Npgsql cannot
/// execute. Those lines are stripped and line endings normalized before the
/// script is sent and before the checksum is computed, so the checksum is stable
/// across checkouts on Windows and Linux.
/// </summary>
public static class SchemaScript
{
    public const string RelativePath = "tools/legacy-migration/schema/xopti-schema.sql";

    /// <summary>
    /// Label recorded with the checksum. Bump it whenever xopti-schema.sql is
    /// regenerated; the checksum remains the authoritative identity.
    /// </summary>
    public const string BaselineVersion = "2026.11.10";

    /// <summary>Reads the executable form of the script.</summary>
    public static string ReadExecutable(string path)
    {
        var lines = File.ReadLines(path)
            .Where(line => !line.TrimStart().StartsWith('\\'))
            .Select(line => line.TrimEnd('\r'));
        return string.Join('\n', lines);
    }

    /// <summary>SHA-256 of the executable script, lowercase hex.</summary>
    public static string ComputeChecksum(string path)
    {
        var bytes = Encoding.UTF8.GetBytes(ReadExecutable(path));
        return Convert.ToHexString(SHA256.HashData(bytes)).ToLowerInvariant();
    }

    /// <summary>
    /// Resolves the schema file from configuration, the content root, or the
    /// repository root (tests and <c>dotnet run</c>). Returns null when absent.
    /// </summary>
    public static string? ResolvePath(string? configured, string contentRoot)
    {
        if (!string.IsNullOrWhiteSpace(configured))
        {
            return File.Exists(configured) ? Path.GetFullPath(configured) : null;
        }

        foreach (var start in new[] { contentRoot, AppContext.BaseDirectory })
        {
            var directory = new DirectoryInfo(start);
            while (directory is not null)
            {
                var candidate = Path.Combine(directory.FullName, RelativePath);
                if (File.Exists(candidate))
                {
                    return candidate;
                }

                directory = directory.Parent;
            }
        }

        return null;
    }
}
