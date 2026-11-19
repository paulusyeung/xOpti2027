using System.Globalization;
using System.Text;
using FluentValidation;
using xOpti.Application.Authorization;
using xOpti.Application.Claims;
using xOpti.Application.Common;
using xOpti.Application.Customers;
using xOpti.Application.Pipeline;
using xOpti.Application.Ports;
using xOpti.Application.Sales.Documents;
using xOpti.Application.Wholesale;

namespace xOpti.Application.Reporting;

public sealed record ReportCatalogueDto(
    string Id, string LogicalName, string Title, string Subject,
    IReadOnlyList<ReportParameterDefinition> Parameters, string ReadModel, string LayoutKey,
    IReadOnlyList<string> RequiredPermissions, int RowCap, string Criticality,
    bool CriticalDocument, string InScope, string SignoffStatus);

public sealed record ReportPreviewDto(
    string ReportId, string Title, IReadOnlyList<ReportColumn> Columns,
    IReadOnlyList<IReadOnlyList<object?>> Rows, bool Truncated, int AppliedCap,
    DateTimeOffset AsOf, bool Stale, IReadOnlyDictionary<string, string?> Parameters);

public sealed record ReportPrintResult(
    string ReportId, bool Duplicate, string FileName, string ContentType, byte[] Content);

public sealed record ReportExportResult(
    string ReportId, string FileName, string ContentType, byte[] Content);

public sealed record ListReportsQuery : IQuery<IReadOnlyList<ReportCatalogueDto>>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => Array.Empty<string>();
}

public sealed record GetReportMetadataQuery(string ReportId)
    : IQuery<ReportCatalogueDto>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => Array.Empty<string>();
}

public sealed record PreviewReportQuery(
    string ReportId, IReadOnlyDictionary<string, string?> Parameters)
    : IQuery<ReportPreviewDto>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.ReportFinancial };
}

public sealed record GenerateReportCommand(
    string ReportId, IReadOnlyDictionary<string, string?> Parameters, bool Duplicate,
    string? TerminalCode, string Reason)
    : ICommand<ReportPrintResult>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.ReportFinancial };
}

public sealed record ExportReportCommand(
    string ReportId, IReadOnlyDictionary<string, string?> Parameters, string Reason)
    : ICommand<ReportExportResult>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.ReportFinancial };
}

public sealed class GenerateReportCommandValidator : AbstractValidator<GenerateReportCommand>
{
    public GenerateReportCommandValidator()
    {
        RuleFor(x => x.ReportId).NotEmpty().MaximumLength(20);
        RuleFor(x => x.TerminalCode).MaximumLength(20);
        RuleFor(x => x.Reason).NotEmpty().MinimumLength(3).MaximumLength(500);
    }
}

public sealed class ExportReportCommandValidator : AbstractValidator<ExportReportCommand>
{
    public ExportReportCommandValidator()
    {
        RuleFor(x => x.ReportId).NotEmpty().MaximumLength(20);
        RuleFor(x => x.Reason).NotEmpty().MinimumLength(3).MaximumLength(500);
    }
}

public interface IReportRunStore
{
    Task RecordAsync(string catalogueId, string? actor, string? branch,
        IReadOnlyDictionary<string, string?> parameters, bool duplicate, int rowCount,
        bool truncated, CancellationToken ct);
}

internal static class ReportCatalogueMapping
{
    public static ReportCatalogueDto Map(ReportCatalogueEntry entry) => new(
        entry.Id, entry.LogicalName, entry.Title, entry.Subject, entry.Parameters,
        entry.ReadModel, entry.LayoutKey, entry.RequiredPermissions, entry.RowCap, entry.Criticality,
        entry.CriticalDocument, entry.InScope, entry.SignoffStatus);
}

public static class ReportDataMasking
{
    public static (IReadOnlyList<ReportColumn> Columns,
        IReadOnlyList<IReadOnlyList<object?>> Rows) Mask(
        IReadOnlyList<ReportColumn> columns,
        IReadOnlyList<IReadOnlyList<object?>> rows,
        IReadOnlyList<ReportField> fields,
        ICurrentPrincipal principal)
    {
        if (principal.HasPermission(PermissionNames.CostView))
            return (columns, rows);
        var sensitive = fields.Where(field => field.Sensitive)
            .Select(field => field.Key).ToHashSet(StringComparer.OrdinalIgnoreCase);
        if (sensitive.Count == 0) return (columns, rows);
        var maskedRows = rows.Select(row => (IReadOnlyList<object?>)row.Select((value, index) =>
            sensitive.Contains(columns[index].Key) ? null : value).ToList()).ToList();
        return (columns, maskedRows);
    }
}

public sealed class ListReportsHandler(IReportCatalogue catalogue)
    : IRequestHandler<ListReportsQuery, IReadOnlyList<ReportCatalogueDto>>
{
    public Task<IReadOnlyList<ReportCatalogueDto>> Handle(
        ListReportsQuery request, CancellationToken ct) =>
        Task.FromResult<IReadOnlyList<ReportCatalogueDto>>(
            catalogue.All.Select(ReportCatalogueMapping.Map).ToList());
}

public sealed class GetReportMetadataHandler(IReportCatalogue catalogue)
    : IRequestHandler<GetReportMetadataQuery, ReportCatalogueDto>
{
    public Task<ReportCatalogueDto> Handle(
        GetReportMetadataQuery request, CancellationToken ct) =>
        Task.FromResult(ReportCatalogueMapping.Map(catalogue.Get(request.ReportId)));
}

public sealed class PreviewReportHandler(
    IReportCatalogue catalogue, IReportDataStore data, ICurrentPrincipal principal)
    : IRequestHandler<PreviewReportQuery, ReportPreviewDto>
{
    public async Task<ReportPreviewDto> Handle(
        PreviewReportQuery request, CancellationToken ct)
    {
        var entry = catalogue.Get(request.ReportId);
        ReportAuthorization.EnsureAllowed(entry, principal);
        var values = ReportParameterValues.Bind(entry, request.Parameters);
        var definition = ReportReadModels.Get(entry.ReadModel);
        var page = await data.QueryAsync(definition, entry.RowCap, values, ct);
        var (columns, rows) = ReportDataMasking.Mask(page.Columns, page.Rows,
            definition.Fields, principal);
        return new ReportPreviewDto(entry.Id, entry.Title, columns, rows, page.Truncated,
            page.AppliedCap, page.AsOf, page.Stale, values.AsReadOnly());
    }
}

public sealed class GenerateReportHandler(
    IUnitOfWork unitOfWork, IReportCatalogue catalogue, IReportDataStore data,
    IReportRenderer renderer, ISalesDocumentStore salesStore,
    IPosDocumentRenderer posRenderer, IClaimStore claims, IClaimDocumentRenderer claimRenderer,
    IWholesaleInvoiceStore wholesaleInvoices, IWholesaleInvoiceDocumentRenderer wholesaleInvoiceRenderer,
    IWholesaleStatementStore wholesaleStatements, ICustomerStore customers,
    IReportRunStore runs, IAuditRecorder audit, ICurrentPrincipal principal)
    : IRequestHandler<GenerateReportCommand, ReportPrintResult>
{
    public Task<ReportPrintResult> Handle(GenerateReportCommand request, CancellationToken ct) =>
        unitOfWork.ExecuteInTransactionAsync(async token =>
        {
            var entry = catalogue.Get(request.ReportId);
            ReportAuthorization.EnsureAllowed(entry, principal);
            var parameters = request.Parameters ?? new Dictionary<string, string?>();
            var rendered = await ReportGeneration.GenerateAsync(entry, parameters,
                request.Duplicate, data, renderer, salesStore, posRenderer, claims,
                claimRenderer, wholesaleInvoices, wholesaleInvoiceRenderer,
                wholesaleStatements, customers, principal, token);
            var rowCount = rendered.RowCount;
            var truncated = rendered.Truncated;
            await runs.RecordAsync(entry.Id, principal.UserId, principal.BranchCode,
                parameters, request.Duplicate, rowCount, truncated, token);
            await audit.RecordAsync(new AuditRecord(
                request.Duplicate ? "report.reprint" : "report.generate", "Report", entry.Id,
                System.Text.Json.JsonSerializer.Serialize(new
                {
                    parameters, request.TerminalCode, request.Reason, request.Duplicate,
                    rowCount, truncated,
                })), token);
            return new ReportPrintResult(entry.Id, request.Duplicate,
                rendered.Document.FileName, rendered.Document.ContentType,
                rendered.Document.Content);
        }, ct);
}

public sealed class ExportReportHandler(
    IUnitOfWork unitOfWork, IReportCatalogue catalogue, IReportDataStore data,
    IReportRunStore runs, IAuditRecorder audit, ICurrentPrincipal principal)
    : IRequestHandler<ExportReportCommand, ReportExportResult>
{
    public Task<ReportExportResult> Handle(ExportReportCommand request, CancellationToken ct) =>
        unitOfWork.ExecuteInTransactionAsync(async token =>
        {
            var entry = catalogue.Get(request.ReportId);
            ReportAuthorization.EnsureAllowed(entry, principal);
            var values = ReportParameterValues.Bind(entry, request.Parameters);
            var definition = ReportReadModels.Get(entry.ReadModel);
            var page = await data.QueryAsync(definition, entry.RowCap, values, token);
            var (columns, rows) = ReportDataMasking.Mask(page.Columns, page.Rows,
                definition.Fields, principal);
            var csv = BuildCsv(columns, rows);
            await runs.RecordAsync(entry.Id, principal.UserId, principal.BranchCode,
                request.Parameters, false, rows.Count, page.Truncated, token);
            await audit.RecordAsync(new AuditRecord("report.export", "Report", entry.Id,
                System.Text.Json.JsonSerializer.Serialize(new
                {
                    request.Parameters, request.Reason, rows = rows.Count,
                    truncated = page.Truncated,
                })), token);
            return new ReportExportResult(entry.Id, $"{entry.Id}.csv", "text/csv",
                Encoding.UTF8.GetBytes(csv));
        }, ct);

    private static string BuildCsv(IReadOnlyList<ReportColumn> columns,
        IReadOnlyList<IReadOnlyList<object?>> rows)
    {
        var builder = new StringBuilder();
        builder.AppendLine(string.Join(',', columns.Select(column => Csv(column.Label))));
        foreach (var row in rows)
        {
            builder.AppendLine(string.Join(',', columns.Select((column, index) =>
                Csv(ReportLayout.Format(row[index], column.Type)))));
        }
        return builder.ToString();
    }

    private static string Csv(string value) =>
        value.Contains(',') || value.Contains('"') || value.Contains('\n')
            ? $"\"{value.Replace("\"", "\"\"")}\""
            : value;
}

public sealed record GeneratedReport(ReportPrintResult Document, int RowCount, bool Truncated);

internal static class ReportGeneration
{
    public static async Task<GeneratedReport> GenerateAsync(
        ReportCatalogueEntry entry, IReadOnlyDictionary<string, string?> parameters,
        bool duplicate, IReportDataStore data, IReportRenderer renderer,
        ISalesDocumentStore salesStore, IPosDocumentRenderer posRenderer,
        IClaimStore claims, IClaimDocumentRenderer claimRenderer,
        IWholesaleInvoiceStore wholesaleInvoices, IWholesaleInvoiceDocumentRenderer wholesaleInvoiceRenderer,
        IWholesaleStatementStore wholesaleStatements, ICustomerStore customers,
        ICurrentPrincipal principal, CancellationToken ct)
    {
        var values = ReportParameterValues.Bind(entry, parameters);
        if (entry.ReadModel == "wholesale" && entry.LayoutKey == "invoice")
        {
            var tx = Parameter(parameters, "DocumentNumber")
                ?? values.Get("AskTxNumberFrom")
                ?? throw Required("DocumentNumber");
            var invoice = await wholesaleInvoices.GetAsync(tx, ct)
                ?? throw new ValidationFailedException(new[]
                {
                    new ValidationFieldError("DocumentNumber", "not-found",
                        "Wholesale invoice was not found."),
                });
            var rendered = wholesaleInvoiceRenderer.Render(invoice, duplicate);
            return new GeneratedReport(new ReportPrintResult(entry.Id, duplicate,
                rendered.FileName, rendered.ContentType, rendered.Content),
                invoice.Lines.Count, false);
        }
        if (entry.LayoutKey is "invoice" or "order" or "receipt")
        {
            var tx = Parameter(parameters, "DocumentNumber")
                ?? values.Get("AskTxNumberFrom")
                ?? values.Get("AskTxNumberTo")
                ?? throw Required("DocumentNumber");
            var document = await salesStore.GetRenderAsync(tx, ct)
                ?? throw new ValidationFailedException(new[]
                {
                    new ValidationFieldError("DocumentNumber", "not-found",
                        "The sales document was not found."),
                });
            var format = entry.LayoutKey switch
            {
                "order" => "order",
                "receipt" => "receipt",
                _ => "invoice",
            };
            var rendered = posRenderer.Render(document with { Duplicate = duplicate }, format);
            return new GeneratedReport(new ReportPrintResult(entry.Id, duplicate,
                rendered.FileName, rendered.ContentType, rendered.Content), 1, false);
        }

        if (entry.LayoutKey == "claim-receipt")
        {
            var claimId = long.TryParse(Parameter(parameters, "ClaimId")
                ?? values.Get("AskTxNumberFrom"), out var id)
                ? id
                : throw Required("ClaimId");
            var receipt = await claims.GetReceiptAsync(claimId, ct)
                ?? throw new ValidationFailedException(new[]
                {
                    new ValidationFieldError("ClaimId", "not-found", "Claim was not found."),
                });
            var rendered = claimRenderer.RenderReceipt(receipt, duplicate);
            return new GeneratedReport(new ReportPrintResult(entry.Id, duplicate,
                rendered.FileName, rendered.ContentType, rendered.Content), 1, false);
        }

        if (entry.LayoutKey == "rbic")
        {
            var from = Date(parameters, "AskDateFrom", required: true);
            var to = Date(parameters, "AskDateTo", required: true);
            var rbicRows = await claims.GetRbicAsync(from, to, ct);
            var content = claimRenderer.RenderRbic(rbicRows, from, to);
            return new GeneratedReport(new ReportPrintResult(entry.Id, duplicate,
                $"rbic-{from:yyyyMMdd}-{to:yyyyMMdd}.csv", "text/csv", content),
                rbicRows.Count, false);
        }

        if (entry.LayoutKey == "packing-list")
        {
            var tx = Parameter(parameters, "DocumentNumber")
                ?? values.Get("AskTxNumberFrom")
                ?? throw Required("DocumentNumber");
            var invoice = await wholesaleInvoices.GetAsync(tx, ct)
                ?? throw new ValidationFailedException(new[]
                {
                    new ValidationFieldError("DocumentNumber", "not-found",
                        "Wholesale invoice was not found."),
                });
            var includePrices = principal.HasPermission(PermissionNames.ReportFinancial);
            var packing = new WholesalePackingListDto(invoice.TxNumber, invoice.Status,
                invoice.DateOfEntry, invoice.CustomerId, invoice.CustomerName,
                invoice.PurchaseOrderNumber, invoice.ShippingMethod, invoice.ShipToName,
                invoice.ShipToAddress, invoice.ShippingInstructions, includePrices,
                invoice.Lines.Select(line => new PackingListLineDto(line.RowNo, line.Sku,
                    line.Description, line.Quantity, line.BackorderQuantity,
                    includePrices ? line.UnitAmount : null,
                    includePrices ? line.Amount : null)).ToList());
            var rendered = renderer.RenderPackingList(packing, duplicate);
            return new GeneratedReport(new ReportPrintResult(entry.Id, duplicate,
                rendered.FileName, rendered.ContentType, rendered.Content), packing.Lines.Count,
                false);
        }

        if (entry.LayoutKey == "statement")
        {
            var customerId = int.TryParse(Parameter(parameters, "CustomerId")
                ?? values.Get("AskCustomerFrom"), out var parsed)
                ? parsed
                : throw Required("CustomerId");
            var from = Date(parameters, "AskDateFrom", required: true);
            var to = Date(parameters, "AskDateTo", required: true);
            var wholesale = await wholesaleStatements.GetStatementAsync(customerId, from, to, ct);
            if (wholesale is not null)
            {
                var rendered = renderer.RenderWholesaleStatement(wholesale, duplicate);
                return new GeneratedReport(new ReportPrintResult(entry.Id, duplicate,
                    rendered.FileName, rendered.ContentType, rendered.Content),
                    wholesale.Items.Count, false);
            }
            var statement = await BuildCustomerStatementAsync(customers, customerId, from, to, ct);
            var customerRendered = renderer.RenderCustomerStatement(statement, duplicate);
            return new GeneratedReport(new ReportPrintResult(entry.Id, duplicate,
                customerRendered.FileName, customerRendered.ContentType,
                customerRendered.Content), statement.Items.Count, false);
        }

        var definition = ReportReadModels.Get(entry.ReadModel);
        var page = await data.QueryAsync(definition, entry.RowCap, values, ct);
        var (columns, rows) = ReportDataMasking.Mask(page.Columns, page.Rows,
            definition.Fields, principal);
        var reportDocument = new ReportDocument(entry, columns, rows, values.AsReadOnly(),
            page.Truncated, page.AppliedCap, page.AsOf, page.Stale, duplicate);
        var report = renderer.RenderReport(reportDocument);
        return new GeneratedReport(new ReportPrintResult(entry.Id, duplicate,
            report.FileName, report.ContentType, report.Content), rows.Count, page.Truncated);
    }

    private static async Task<CustomerStatementDto> BuildCustomerStatementAsync(
        ICustomerStore store, int customerId, DateOnly from, DateOnly to, CancellationToken ct)
    {
        var canonical = await store.ResolveCanonicalIdAsync(customerId, ct)
            ?? throw new ValidationFailedException(new[]
            {
                new ValidationFieldError("CustomerId", "not-found", "Customer was not found."),
            });
        var ids = await store.ResolveGroupIdsAsync(canonical, ct);
        var all = await store.GetHistoryAsync(ids, null, to, ct);
        var start = new DateTimeOffset(from.ToDateTime(TimeOnly.MinValue), TimeSpan.Zero);
        var before = all.Where(row => row.DateOfEntry < start).ToList();
        var period = all.Where(row => row.DateOfEntry >= start).ToList();
        static decimal Charges(IEnumerable<CustomerPurchaseDto> rows) =>
            decimal.Round(rows.Where(row => row.TxType == "RC").Sum(row => row.TotalAmount), 4);
        static decimal Refunds(IEnumerable<CustomerPurchaseDto> rows) =>
            decimal.Round(rows.Where(row => row.TxType == "RS").Sum(row => row.TotalAmount), 4);
        static decimal Payments(IEnumerable<CustomerPurchaseDto> rows) =>
            decimal.Round(rows.Sum(row => row.Paid), 4);
        var opening = decimal.Round(Charges(before) + Refunds(before) - Payments(before), 4);
        var charges = Charges(period);
        var refunds = Refunds(period);
        var payments = Payments(period);
        var customer = await store.GetAsync(canonical, ct);
        return new CustomerStatementDto(canonical, from, to, opening, charges, payments,
            refunds, decimal.Round(opening + charges + refunds - payments, 4), period,
            customer?.FullName);
    }

    private static string? Parameter(IReadOnlyDictionary<string, string?> parameters,
        string key) => parameters.TryGetValue(key, out var value) ? value : null;

    private static ValidationFailedException Required(string name) => new(new[]
    {
        new ValidationFieldError(name, "required", $"{name} is required."),
    });

    private static DateOnly Date(IReadOnlyDictionary<string, string?> parameters,
        string key, bool required)
    {
        var raw = Parameter(parameters, key);
        if (DateOnly.TryParseExact(raw, "yyyy-MM-dd", CultureInfo.InvariantCulture,
                DateTimeStyles.None, out var date)) return date;
        if (!required) return DateOnly.MinValue;
        throw new ValidationFailedException(new[]
        {
            new ValidationFieldError(key, "date", $"{key} must be a date (yyyy-MM-dd)."),
        });
    }
}
