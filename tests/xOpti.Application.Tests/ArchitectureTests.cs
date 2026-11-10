using System.Reflection;

namespace xOpti.Application.Tests;

public static class RepoPaths
{
    public static string RepositoryRoot { get; } = FindRoot();

    private static string FindRoot()
    {
        var dir = new DirectoryInfo(AppContext.BaseDirectory);
        while (dir is not null && !File.Exists(Path.Combine(dir.FullName, "xOpti.sln")))
        {
            dir = dir.Parent;
        }

        return dir?.FullName ?? throw new DirectoryNotFoundException("xOpti.sln not found above the test output directory.");
    }
}

public class ArchitectureTests
{
    private static readonly string[] Modules =
    {
        "Sales", "Inventory", "Purchasing", "Customers",
        "Prescriptions", "Wholesale", "Reporting", "Identity",
    };

    private static readonly string[] TechnicalFolders = { "Common", "Pipeline", "Ports", "Authorization" };

    private static readonly Assembly ApplicationAssembly = typeof(Common.IRequest<int>).Assembly;

    [Theory]
    [InlineData("Sales")]
    [InlineData("Inventory")]
    [InlineData("Purchasing")]
    [InlineData("Customers")]
    [InlineData("Prescriptions")]
    [InlineData("Wholesale")]
    [InlineData("Reporting")]
    [InlineData("Identity")]
    public void ModuleFolderExists(string module)
    {
        var path = Path.Combine(RepoPaths.RepositoryRoot, "src", "xOpti.Application", module);
        Assert.True(Directory.Exists(path), $"Missing module folder: {path}");
    }

    [Fact]
    public void EveryApplicationTypeNamespaceFitsConvention()
    {
        var allowed = Modules.Concat(TechnicalFolders).ToHashSet();

        var violations = ApplicationAssembly.GetTypes()
            .Where(t => t.Namespace is not null)
            .Select(t => t.Namespace!.Split('.'))
            .Where(segments => segments.Length < 2
                || segments[0] != "xOpti"
                || segments[1] != "Application"
                || (segments.Length > 2 && !allowed.Contains(segments[2])))
            .Select(segments => string.Join('.', segments))
            .Distinct()
            .ToList();

        Assert.True(violations.Count == 0, "Offending namespaces: " + string.Join(", ", violations));
    }

    [Fact]
    public void UseCaseFilesDeclareModuleNamespaces()
    {
        foreach (var module in Modules)
        {
            var dir = Path.Combine(RepoPaths.RepositoryRoot, "src", "xOpti.Application", module);
            foreach (var file in Directory.GetFiles(dir, "*.cs", SearchOption.AllDirectories))
            {
                var content = File.ReadAllText(file);
                Assert.Contains($"namespace xOpti.Application.{module}", content, StringComparison.Ordinal);
            }
        }
    }

    [Fact]
    public void ApplicationDoesNotReferencePersistenceOrHostingPackages()
    {
        var referenced = ApplicationAssembly.GetReferencedAssemblies()
            .Select(a => a.Name ?? string.Empty)
            .Where(n => n.Contains("EntityFrameworkCore", StringComparison.OrdinalIgnoreCase)
                     || n.Contains("Npgsql", StringComparison.OrdinalIgnoreCase)
                     || n.StartsWith("Microsoft.AspNetCore", StringComparison.OrdinalIgnoreCase)
                     || n.Contains("QuestPDF", StringComparison.OrdinalIgnoreCase))
            .ToList();

        Assert.Empty(referenced);
    }
}
