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

    /// <summary>
    /// Manual discount percentage allowed without the price-override
    /// permission. Zero until the signed discount policy is supplied.
    /// </summary>
    public decimal PosDiscountThresholdPercent { get; init; }

    /// <summary>Blind cash-count policy; false until the signed policy is supplied.</summary>
    public bool BlindCashCount { get; init; }

    /// <summary>
    /// Payment terminal mode: "manual" requires an operator-entered opaque
    /// reference; "simulated" is a disposable test harness.
    /// </summary>
    public string PaymentTerminalMode { get; init; } = "manual";

    /// <summary>Require a verified current prescription before optical conversion.</summary>
    public bool RequirePrescriptionVerification { get; init; }

    /// <summary>Maximum patient attachment size; 10 MiB until the signed policy lands.</summary>
    public long PrescriptionAttachmentMaxBytes { get; init; } = 10 * 1024 * 1024;

    /// <summary>Enable line-level wholesale backorders; the signed baseline decides.</summary>
    public bool WholesaleBackordersEnabled { get; init; }

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
        services.AddScoped<xOpti.Application.Identity.ILegacyStaffAuthenticator,
            Identity.LegacyStaffAuthenticator>();
        services.AddScoped<xOpti.Application.Identity.Staff.ILegacyStaffDirectory,
            Identity.EfLegacyStaffDirectory>();
        services.AddScoped<xOpti.Application.Reporting.IBarCodeTagStore,
            Repositories.EfBarCodeTagStore>();
        services.AddScoped<xOpti.Application.Inventory.GetInventorySummary.IInventorySummaryRepository,
            Repositories.EfInventorySummaryRepository>();
        services.AddScoped<xOpti.Application.Reference.IReferenceDirectory, Repositories.EfReferenceDirectory>();
        services.AddScoped<xOpti.Application.Reference.IReferenceWriter, Repositories.EfReferenceWriter>();
        services.AddScoped<xOpti.Application.Reference.IPartyDirectory, Repositories.EfPartyDirectory>();
        services.AddScoped<xOpti.Application.Inventory.Catalogue.ICatalogueStore,
            Repositories.EfCatalogueStore>();
        services.AddScoped<xOpti.Application.Inventory.Availability.IAvailabilityStore,
            Repositories.EfAvailabilityStore>();
        services.AddScoped<xOpti.Application.Inventory.Valuation.IValuationStore,
            Repositories.EfValuationStore>();
        services.AddScoped<xOpti.Application.Purchasing.ReceiveStock.IReceiptStore,
            Repositories.EfReceiptStore>();
        services.AddScoped<xOpti.Application.Purchasing.RejectStock.IRejectStockStore,
            Repositories.EfRejectStockStore>();
        services.AddScoped<xOpti.Application.Inventory.AdjustStock.IAdjustmentStore,
            Repositories.EfAdjustmentStore>();
        services.AddScoped<xOpti.Application.Inventory.TransferStock.ITransferStore,
            Repositories.EfTransferStore>();
        services.AddScoped<xOpti.Application.Inventory.Documents.IStockDocumentStore,
            Repositories.EfStockDocumentStore>();
        services.AddScoped<xOpti.Application.Inventory.StockTake.IStockTakeStore,
            Repositories.EfStockTakeStore>();
        services.AddScoped<xOpti.Application.Inventory.StockTake.IStockTakeCountStore,
            Repositories.EfStockTakeStore>();
        services.AddScoped<xOpti.Application.Inventory.StockTake.IStockTakeVarianceStore,
            Repositories.EfStockTakeStore>();
        services.AddScoped<xOpti.Application.Inventory.StockTake.IStockTakePostingStore,
            Repositories.EfStockTakeStore>();
        services.AddScoped<xOpti.Application.Inventory.IssueStock.IIssueStockStore,
            Repositories.EfIssueStockStore>();
        services.AddScoped<xOpti.Application.Inventory.Reconciliation.IInventoryReconciliationStore,
            Repositories.EfInventoryReconciliationStore>();
        services.AddScoped<xOpti.Application.Inventory.Summaries.ISummaryStore,
            Repositories.EfSummaryStore>();
        services.AddScoped<xOpti.Application.Purchasing.SupplierDocuments.ISupplierDocumentStore,
            Repositories.EfSupplierDocumentStore>();
        services.AddScoped<xOpti.Application.Sales.Documents.ISalesDocumentStore,
            Repositories.EfSalesDocumentStore>();
        services.AddScoped<xOpti.Application.Sales.OrderEntry.IOrderStore, Repositories.EfOrderStore>();
        services.AddScoped<xOpti.Application.Sales.Retail.IRetailSaleStore,
            Repositories.EfRetailSaleStore>();
        services.AddScoped<xOpti.Application.Cash.ICashStore, Repositories.EfCashStore>();
        services.AddScoped<xOpti.Application.Customers.ICustomerStore, Repositories.EfCustomerStore>();
        services.AddScoped<xOpti.Application.Prescriptions.IPrescriptionStore,
            Repositories.EfPrescriptionStore>();
        services.AddScoped<xOpti.Application.Optical.IOpticalOrderStore,
            Repositories.EfOpticalOrderStore>();
        services.AddScoped<xOpti.Application.Claims.IClaimStore, Repositories.EfClaimStore>();
        services.AddSingleton<xOpti.Application.Reporting.IReportCatalogue,
            xOpti.Application.Reporting.ReportCatalogue>();
        services.AddScoped<xOpti.Application.Reporting.IReportDataStore,
            Repositories.EfReportDataStore>();
        services.AddScoped<xOpti.Application.Reporting.IReportRunStore,
            Repositories.EfReportRunStore>();
        services.AddScoped<xOpti.Application.Analytics.IAnalyticsStore,
            Repositories.EfAnalyticsStore>();
        services.AddScoped<xOpti.Infrastructure.Jobs.ReportReadModelRefresher>();
        services.AddScoped<xOpti.Application.Reporting.IReportReadModelRefresher>(sp =>
            sp.GetRequiredService<xOpti.Infrastructure.Jobs.ReportReadModelRefresher>());
        services.AddScoped<xOpti.Application.Wholesale.IWholesaleAccountStore,
            Repositories.EfWholesaleAccountStore>();
        services.AddScoped<xOpti.Application.Wholesale.IWholesalePricingStore,
            Repositories.EfWholesalePricingStore>();
        services.AddScoped<xOpti.Application.Wholesale.IWholesaleInvoiceStore,
            Repositories.EfWholesaleInvoiceStore>();
        services.AddScoped<xOpti.Application.Wholesale.IWholesaleReturnStore,
            Repositories.EfWholesaleReturnStore>();
        services.AddScoped<xOpti.Application.Wholesale.IWholesaleStatementStore,
            Repositories.EfWholesaleStatementStore>();
        services.AddScoped<xOpti.Application.Settings.IPreferencesStore, Repositories.EfPreferencesStore>();
        services.AddScoped<xOpti.Application.Settings.IImportStore, Repositories.EfImportStore>();
        services.AddSingleton<xOpti.Application.Identity.Staff.IRoleCatalogue, Identity.RoleCatalogue>();
        services.AddSingleton<IClock, SystemClock>();
        services.AddSingleton<IPosPolicy, PosPolicy>();
        services.AddSingleton<IPrescriptionPolicy, PrescriptionPolicy>();
        services.AddSingleton<IWholesalePolicy, WholesalePolicy>();
        services.AddSingleton<xOpti.Application.Payments.IPaymentTerminal>(sp =>
            string.Equals(options.PaymentTerminalMode, "simulated", StringComparison.OrdinalIgnoreCase)
                ? new SimulatedPaymentTerminal()
                : new ManualPaymentTerminal());
        services.AddScoped<xOpti.Application.Identity.ListBranches.IBranchRepository, Repositories.EfBranchRepository>();

        services.AddScoped<Platform.IdempotencyStoreOptions>(_ =>
            new Platform.IdempotencyStoreOptions(options.IdempotencyRetention));

        services.AddSingleton<Documents.IDocumentRenderer, Documents.QuestPdfDocumentRenderer>();
        services.AddSingleton<xOpti.Application.Sales.Documents.IPosDocumentRenderer,
            Documents.QuestPdfPosDocumentRenderer>();
        services.AddSingleton<xOpti.Application.Claims.IClaimDocumentRenderer,
            Documents.ClaimDocumentRenderer>();
        services.AddSingleton<xOpti.Application.Wholesale.IWholesaleInvoiceDocumentRenderer,
            Documents.WholesaleInvoiceDocumentRenderer>();
        services.AddSingleton<xOpti.Application.Wholesale.IWholesaleReturnDocumentRenderer,
            Documents.WholesaleReturnDocumentRenderer>();
        services.AddSingleton<xOpti.Application.Reporting.IReportRenderer,
            Documents.QuestPdfReportRenderer>();
        services.AddSingleton<Documents.IFileStorage>(sp =>
            new Documents.LocalFileStorage(options.FileStorageRoot));

        return services;
    }
}
