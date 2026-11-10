using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;

namespace xOpti.Infrastructure.Persistence;

public class DesignTimeDbContextFactory : IDesignTimeDbContextFactory<XOptiDbContext>
{
    public XOptiDbContext CreateDbContext(string[] args)
    {
        var url = Environment.GetEnvironmentVariable("XOPTI_DATABASE_URL")
            ?? "Host=localhost;Port=5432;Database=xopti_infra_design;Username=postgres;Password=postgres";

        var options = new DbContextOptionsBuilder<XOptiDbContext>()
            .UseNpgsql(ConnectionStrings.ToNpgsql(url))
            .UseSnakeCaseNamingConvention()
            .Options;

        return new XOptiDbContext(options);
    }
}

internal static class ConnectionStrings
{
    /// <summary>
    /// Accepts postgresql:// URLs (as the migration runner and ops tooling use)
    /// or native Npgsql key/value strings.
    /// </summary>
    public static string ToNpgsql(string urlOrCs)
    {
        if (!urlOrCs.StartsWith("postgres://", StringComparison.OrdinalIgnoreCase)
            && !urlOrCs.StartsWith("postgresql://", StringComparison.OrdinalIgnoreCase))
        {
            return urlOrCs;
        }

        var uri = new Uri(urlOrCs.Replace("postgres://", "http://").Replace("postgresql://", "http://"));
        var userInfo = uri.UserInfo.Split(':', 2);
        var database = uri.AbsolutePath.Trim('/');
        return $"Host={uri.Host};Port={(uri.Port > 0 ? uri.Port : 5432)};"
             + $"Database={database};Username={userInfo[0]};"
             + $"Password={(userInfo.Length > 1 ? userInfo[1] : string.Empty)}";
    }
}
