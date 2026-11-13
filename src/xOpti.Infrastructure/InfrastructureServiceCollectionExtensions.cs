using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using xOpti.Application.Ports;
using xOpti.Infrastructure.Persistence;
using xOpti.Infrastructure.Persistence.Interceptors;
using xOpti.Infrastructure.Platform;

namespace xOpti.Infrastructure;

/// <summary>Configuration for Infrastructure-provided services.</summary>
public sealed record InfrastructureOptions
{
    public string ConnectionString { get; init; } = string.Empty;

    /// <summary>Root directory for generated documents and attachments.</summary>
    public string FileStorageRoot { get; init; } = "/var/lib/xopti/files";

    /// <summary>Retention window for idempotency records.</summary>
    public TimeSpan IdempotencyRetention { get; init; } = TimeSpan.FromHours(24);

    /// <summary>Directories scanned for bundled fonts (e.g. 3of9.TTF).</summary>
    public IReadOnlyList<string> FontDirectories { get; init; } = Array.Empty<string>();

    /// <summary>Schedule/cron-lite expressions for enabled jobs.</summary>
    public IReadOnlyList<string> MaterializedViewRefreshStatements { get; init; } =
        new[] { "SELECT 1 /* example: replace with REFRESH MATERIALIZED VIEW analytics... */" };
}

public static class InfrastructureServiceCollectionExtensions
{
    public static IServiceCollection AddXOptiInfrastructure(
        this IServiceCollection services,
        InfrastructureOptions options)
    {
        services.AddSingleton(options);

        services.AddDbContext<XOptiDbContext>((sp, builder) =>
        {
            builder.UseNpgsql(Persistence.ConnectionStrings.ToNpgsql(options.ConnectionString))
                .UseSnakeCaseNamingConvention()
                .AddInterceptors(sp.GetRequiredService<AuditSaveChangesInterceptor>());
        });

        services.AddScoped<AuditSaveChangesInterceptor>();

        services.AddScoped<IUnitOfWork, EfUnitOfWork>();
        services.AddScoped<IControlNumberAllocator, PostgresControlNumberAllocator>();
        services.AddScoped<IIdempotencyStore, DbIdempotencyStore>();
        services.AddScoped<IAuditRecorder, DbAuditRecorder>();
        services.AddScoped<xOpti.Application.Identity.Staff.IStaffAccountStore, Identity.EfStaffAccountStore>();
        services.AddScoped<xOpti.Application.Inventory.GetInventorySummary.IInventorySummaryRepository,
            Repositories.EfInventorySummaryRepository>();
        services.AddScoped<xOpti.Application.Reference.IReferenceDirectory, Repositories.EfReferenceDirectory>();
        services.AddSingleton<xOpti.Application.Identity.Staff.IRoleCatalogue, Identity.RoleCatalogue>();
        services.AddSingleton<IClock, SystemClock>();
        services.AddScoped<xOpti.Application.Identity.ListBranches.IBranchRepository, Repositories.EfBranchRepository>();

        services.AddScoped<Platform.IdempotencyStoreOptions>(_ =>
            new Platform.IdempotencyStoreOptions(options.IdempotencyRetention));

        services.AddSingleton<Documents.IDocumentRenderer, Documents.QuestPdfDocumentRenderer>();
        services.AddSingleton<Documents.IFileStorage>(sp =>
            new Documents.LocalFileStorage(options.FileStorageRoot));

        return services;
    }
}
