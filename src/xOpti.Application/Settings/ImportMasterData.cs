using System.Text.Json;
using FluentValidation;
using xOpti.Application.Authorization;
using xOpti.Application.Common;
using xOpti.Application.Ports;

namespace xOpti.Application.Settings;

public enum ImportKind
{
    Sku,
    Supplier,
    Brand,
}

public sealed record ImportRowError(int Row, string Field, string Message);

public sealed record ImportResultDto(
    ImportKind Kind,
    bool DryRun,
    int Created,
    int Updated,
    int Skipped,
    IReadOnlyList<ImportRowError> Errors,
    int? ResumeFrom);

public interface IImportStore
{
    Task<bool> ExistsAsync(ImportKind kind, string key, CancellationToken ct);
    Task UpsertAsync(ImportKind kind, IReadOnlyDictionary<string, string> row, CancellationToken ct);
}

public sealed record ImportMasterDataCommand(ImportKind Kind, string Csv, bool DryRun, string Reason)
    : ICommand<ImportResultDto>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.MasterDataMaintain };
}

public sealed class ImportMasterDataCommandValidator : AbstractValidator<ImportMasterDataCommand>
{
    public ImportMasterDataCommandValidator()
    {
        RuleFor(x => x.Csv).NotEmpty();
        RuleFor(x => x.Reason).NotEmpty().MinimumLength(3).MaximumLength(500);
    }
}

public sealed class ImportMasterDataHandler(
    IUnitOfWork unitOfWork, IImportStore store, IAuditRecorder audit)
    : IRequestHandler<ImportMasterDataCommand, ImportResultDto>
{
    public Task<ImportResultDto> Handle(ImportMasterDataCommand request, CancellationToken ct) =>
        unitOfWork.ExecuteInTransactionAsync(async token =>
        {
            var parsed = Parse(request.Kind, request.Csv);
            if (parsed.Errors.Count > 0)
            {
                return new ImportResultDto(request.Kind, request.DryRun, 0, 0, 0,
                    parsed.Errors, parsed.Errors[0].Row);
            }

            var created = 0;
            var updated = 0;
            var skipped = 0;
            foreach (var row in parsed.Rows)
            {
                var exists = await store.ExistsAsync(request.Kind, row[KeyColumn(request.Kind)], token);
                if (request.DryRun)
                {
                    if (exists) updated++; else created++;
                    continue;
                }

                if (exists) updated++; else created++;
                await store.UpsertAsync(request.Kind, row, token);
            }

            if (!request.DryRun)
            {
                await audit.RecordAsync(new AuditRecord("master-data.import", $"Import:{request.Kind}", "csv",
                    JsonSerializer.Serialize(new { reason = request.Reason, created, updated, skipped })), token);
            }

            return new ImportResultDto(request.Kind, request.DryRun, created, updated, skipped,
                Array.Empty<ImportRowError>(), null);
        }, ct);

    private static string KeyColumn(ImportKind kind) => kind switch
    {
        ImportKind.Sku => "sku",
        ImportKind.Supplier => "supplierCode",
        _ => "brandCode",
    };

    private static (List<Dictionary<string, string>> Rows, List<ImportRowError> Errors) Parse(
        ImportKind kind, string csv)
    {
        var rows = new List<Dictionary<string, string>>();
        var errors = new List<ImportRowError>();
        var lines = csv.Replace("\r\n", "\n").Split('\n', StringSplitOptions.RemoveEmptyEntries);
        if (lines.Length == 0)
        {
            errors.Add(new ImportRowError(0, "Csv", "The file is empty."));
            return (rows, errors);
        }

        var headers = lines[0].Split(',').Select(header => header.Trim()).ToArray();
        var key = KeyColumn(kind);
        if (!headers.Any(header => header.Equals(key, StringComparison.OrdinalIgnoreCase)))
        {
            errors.Add(new ImportRowError(1, key, $"The header must contain '{key}'."));
            return (rows, errors);
        }

        var seen = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        for (var index = 1; index < lines.Length; index++)
        {
            var values = lines[index].Split(',');
            var row = headers.Select((header, position) => (header, value: position < values.Length ? values[position].Trim() : string.Empty))
                .ToDictionary(pair => pair.header, pair => pair.value, StringComparer.OrdinalIgnoreCase);
            var rowNumber = index + 1;

            var keyValue = row.GetValueOrDefault(key, string.Empty);
            if (string.IsNullOrWhiteSpace(keyValue))
            {
                errors.Add(new ImportRowError(rowNumber, key, "A key value is required."));
                continue;
            }

            if (!seen.Add(keyValue))
            {
                errors.Add(new ImportRowError(rowNumber, key, $"Duplicate key '{keyValue}' in the file."));
                continue;
            }

            var nameKey = kind == ImportKind.Sku ? "name" : kind == ImportKind.Supplier ? "name" : "name";
            if (string.IsNullOrWhiteSpace(row.GetValueOrDefault(nameKey)))
            {
                errors.Add(new ImportRowError(rowNumber, nameKey, "A name is required."));
                continue;
            }

            rows.Add(row);
        }

        return (rows, errors);
    }
}
