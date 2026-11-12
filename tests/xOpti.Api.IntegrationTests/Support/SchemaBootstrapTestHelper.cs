using Microsoft.Extensions.DependencyInjection;
using xOpti.Infrastructure;
using xOpti.Infrastructure.Bootstrap;
using xOpti.Infrastructure.Identity;

namespace xOpti.Api.IntegrationTests.Support;

/// <summary>Runs the production bootstrap against an empty test database.</summary>
public static class SchemaBootstrapTestHelper
{
    public static async Task BootstrapAsync(string connectionString)
    {
        var schemaFile = SchemaFilePath();
        await using var services = new ServiceCollection()
            .AddXOptiInfrastructure(new InfrastructureOptions { ConnectionString = connectionString })
            .AddXOptiIdentity()
            .BuildServiceProvider();

        await SchemaBootstrap.RunAsync(services, new SchemaBootstrapOptions
        {
            ConnectionString = connectionString,
            SchemaFilePath = schemaFile,
            Version = SchemaScript.BaselineVersion,
            ExpectedChecksum = SchemaScript.ComputeChecksum(schemaFile),
            AppliedBy = "integration-test",
        });
    }

    private static string SchemaFilePath()
    {
        var dir = new DirectoryInfo(AppContext.BaseDirectory);
        while (dir is not null && !File.Exists(Path.Combine(dir.FullName, "xOpti.sln")))
        {
            dir = dir.Parent;
        }

        return Path.Combine(dir!.FullName, SchemaScript.RelativePath);
    }
}
