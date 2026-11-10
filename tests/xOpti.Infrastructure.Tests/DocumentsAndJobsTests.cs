using System.Runtime.InteropServices;
using Microsoft.Extensions.DependencyInjection;
using xOpti.Application;
using xOpti.Infrastructure.Jobs;
using Microsoft.Extensions.Hosting;
using xOpti.Application.Ports;
using xOpti.Infrastructure;
using xOpti.Infrastructure.Documents;
using xOpti.Infrastructure.Persistence;
using xOpti.Infrastructure.Tests.Support;

namespace xOpti.Infrastructure.Tests;

public class FileStorageTests : IDisposable
{
    private readonly string _root = Path.Combine(Path.GetTempPath(), "xopti-files-" + Guid.NewGuid().ToString("N")[..8]);

    public void Dispose()
    {
        if (Directory.Exists(_root))
        {
            Directory.Delete(_root, true);
        }
    }

    [Fact]
    public void Save_LandsUnderConfiguredRoot_WithNamespacedKey()
    {
        var storage = new LocalFileStorage(_root);

        var relative = storage.Save("sales/invoices/2026-01-15/RC00000123.pdf", new byte[] { 1, 2, 3 }, "application/pdf");

        Assert.StartsWith("sales", relative.Replace('\\', '/'));
        var fullPath = Path.Combine(_root, relative);
        Assert.True(File.Exists(fullPath));
        Assert.Equal(3, new FileInfo(fullPath).Length);
    }

    [Fact]
    public void TraversalKeys_AreRejected()
    {
        var storage = new LocalFileStorage(_root);

        Assert.Throws<UnauthorizedAccessException>(() => storage.Save("../../etc/passwd", Array.Empty<byte>(), "text/plain"));
        Assert.Throws<UnauthorizedAccessException>(() => storage.Save("sales/../../../etc/shadow", Array.Empty<byte>(), "text/plain"));
        Assert.Throws<ArgumentException>(() => storage.Save("   ", Array.Empty<byte>(), "text/plain"));
    }

    [Fact]
    public void TryRead_RoundTrips()
    {
        var storage = new LocalFileStorage(_root);
        storage.Save("reporting/test.bin", new byte[] { 9, 8, 7 }, "application/octet-stream");

        Assert.True(storage.TryRead("reporting/test.bin", out var content));
        Assert.Equal(new byte[] { 9, 8, 7 }, content);
        Assert.False(storage.TryRead("reporting/missing.bin", out _));
    }
}

[Collection("linux")]
public class DocumentRenderingTests
{
    [Fact]
    public void RendersPdf_WithBundledBarcodeFont_OnLinuxRuntime()
    {
        Assert.True(RuntimeInformation.IsOSPlatform(OSPlatform.Linux));

        // Locate the repo to use the same bundled font shipped to the container.
        var dir = new DirectoryInfo(AppContext.BaseDirectory);
        while (dir is not null && !File.Exists(Path.Combine(dir.FullName, "xOpti.sln")))
        {
            dir = dir.Parent;
        }

        var fontDir = Path.Combine(dir!.FullName, "eOptical6DAO");
        Assert.True(File.Exists(Path.Combine(fontDir, "3of9.TTF")), "bundled barcode font missing");

        var renderer = new QuestPdfDocumentRenderer(new InfrastructureOptions
        {
            ConnectionString = "unused",
            FontDirectories = new[] { fontDir },
        });

        var file = renderer.RenderInvoiceStub(new DocumentRequest(
            BarcodeValues: new[] { "30110359" },
            Lines: new[] { "Retail Invoice RC000123", "Total: $113.00" }));

        Assert.NotNull(QuestPdfDocumentRenderer.BarcodeFamily);
        Assert.NotEmpty(file.Content);
        Assert.Equal("%PDF", System.Text.Encoding.ASCII.GetString(file.Content[..4]));
    }
}

[CollectionDefinition("linux")]
public class LinuxCollection : ICollectionFixture<object>
{
}

[Collection("postgres")]
public class JobsTests(PostgresFixture fixture)
{
    private ServiceProvider Build(bool jobsEnabled)
    {
        var services = new ServiceCollection();
        services.AddLogging();
        services.AddXOptiInfrastructure(new InfrastructureOptions { ConnectionString = fixture.ConnectionString });
        services.AddXOptiJobs(jobsEnabled);
        services.AddScoped<ICurrentPrincipal>(_ => new ClaimsCurrentPrincipal(
            new System.Security.Claims.ClaimsPrincipal()));
        return services.BuildServiceProvider();
    }

    [Fact]
    public void FeatureFlag_EnableRegistersTheJob()
    {
        using var provider = Build(true);

        Assert.Contains(
            provider.GetServices<IHostedService>(),
            s => s is xOpti.Infrastructure.Jobs.MaterializedViewRefreshJob);
    }

    [Fact]
    public void FeatureFlag_DisableOmitsTheJob()
    {
        using var provider = Build(false);

        Assert.DoesNotContain(
            provider.GetServices<IHostedService>(),
            s => s is xOpti.Infrastructure.Jobs.MaterializedViewRefreshJob);
    }

    [Fact]
    public async Task RefreshOnce_ExecutesStatementsAgainstDatabase()
    {
        using var provider = Build(true);
        var job = provider.GetServices<IHostedService>()
            .OfType<xOpti.Infrastructure.Jobs.MaterializedViewRefreshJob>()
            .Single();

        await job.RefreshOnceAsync(CancellationToken.None);
    }

    [Fact]
    public void IntervalParsing_CronLite()
    {
        Assert.Equal(TimeSpan.FromMinutes(15),
            xOpti.Infrastructure.Jobs.MaterializedViewRefreshJob.IntervalFrom("interval:00:15:00"));
        Assert.Throws<FormatException>(
            () => xOpti.Infrastructure.Jobs.MaterializedViewRefreshJob.IntervalFrom("0 3 * * *"));
    }
}

[Collection("postgres")]
public class ReferenceSliceIntegrationTests(PostgresFixture fixture)
{
    [Fact]
    public async Task ListBranches_RealInfrastructure_MatchesFakeSemantics()
    {
        var services = new ServiceCollection();
        services.AddLogging();
        services.AddXOptiApplication();
        services.AddXOptiInfrastructure(new InfrastructureOptions { ConnectionString = fixture.ConnectionString });
        services.AddScoped<ICurrentPrincipal>(_ => new ClaimsCurrentPrincipal(
            new System.Security.Claims.ClaimsPrincipal()));
        var provider = services.BuildServiceProvider();

        using var scope = provider.CreateScope();
        var dispatcher = scope.ServiceProvider.GetRequiredService<xOpti.Application.Common.IRequestDispatcher>();

        // Full traversal over the 7 seeded branches with page size 3:
        // every row exactly once, ordinal order, same as the in-memory fake tests.
        var seen = new List<string>();
        string? cursor = null;
        var pages = 0;

        while (true)
        {
            var page = await dispatcher.DispatchAsync(
                new xOpti.Application.Identity.ListBranches.ListBranchesQuery(cursor, 3));
            seen.AddRange(page.Items.Select(i => i.BranchCode));
            cursor = page.NextCursor;
            pages++;
            Assert.True(pages < 10, "did not terminate");
            if (cursor is null)
            {
                break;
            }
        }

        Assert.Equal(7, seen.Count);
        Assert.Equal(seen.Count, seen.Distinct().Count());
        Assert.Equal(new[] { "01", "02", "03", "04", "05", "06", "07" }, seen);

        // Validator + permission behaviors also run on the real path.
        await Assert.ThrowsAsync<xOpti.Application.Pipeline.ValidationFailedException>(() =>
            dispatcher.DispatchAsync(new xOpti.Application.Identity.ListBranches.ListBranchesQuery(null, 0)));
    }
}
