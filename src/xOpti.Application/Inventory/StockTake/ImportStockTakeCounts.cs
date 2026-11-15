using System.Text.Json;
using FluentValidation;
using xOpti.Application.Authorization;
using xOpti.Application.Common;
using xOpti.Application.Ports;

namespace xOpti.Application.Inventory.StockTake;

public sealed record CountRowError(int Row, string Field, string Message);

public sealed record ImportStockTakeCountsCommand(
    int HeaderId, string Csv, bool DryRun, string Reason)
    : ICommand<ImportStockTakeCountsResult>, IHasPermissions
{
    public IReadOnlyList<string> RequiredPermissions => new[] { PermissionNames.InventoryAdjust };
}

public sealed record ImportStockTakeCountsResult(
    int HeaderId, bool DryRun, int Accepted, int? ResumeFrom,
    IReadOnlyList<CountRowError> Errors);

public interface IStockTakeCountStore
{
    Task<bool> FrozenHeaderExistsAsync(int headerId, CancellationToken ct);
    Task<bool> SkuInSnapshotAsync(int headerId, string sku, CancellationToken ct);
    Task UpsertCountAsync(int headerId, string sku, int qty, CancellationToken ct);
}

public sealed class ImportStockTakeCountsCommandValidator : AbstractValidator<ImportStockTakeCountsCommand>
{
    public ImportStockTakeCountsCommandValidator()
    {
        RuleFor(x => x.HeaderId).GreaterThan(0);
        RuleFor(x => x.Csv).NotEmpty();
        RuleFor(x => x.Reason).NotEmpty().MinimumLength(3).MaximumLength(500);
    }
}

public sealed class ImportStockTakeCountsHandler(
    IUnitOfWork unitOfWork, IStockTakeCountStore store, IAuditRecorder audit)
    : IRequestHandler<ImportStockTakeCountsCommand, ImportStockTakeCountsResult>
{
    public Task<ImportStockTakeCountsResult> Handle(
        ImportStockTakeCountsCommand request, CancellationToken ct) =>
        unitOfWork.ExecuteInTransactionAsync(async token =>
        {
            if (!await store.FrozenHeaderExistsAsync(request.HeaderId, token))
            {
                return new ImportStockTakeCountsResult(request.HeaderId, request.DryRun, 0, null,
                    new[] { new CountRowError(0, "HeaderId", "A frozen stock take with that id was not found.") });
            }

            var rows = new List<(int Row, string Sku, int Qty)>();
            var errors = new List<CountRowError>();
            var seen = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
            var lines = request.Csv.Replace("\r\n", "\n").Split('\n', StringSplitOptions.RemoveEmptyEntries);
            for (var index = 0; index < lines.Length; index++)
            {
                if (index == 0 && lines[0].Contains("sku", StringComparison.OrdinalIgnoreCase))
                {
                    continue; // header row
                }

                var parts = lines[index].Split(',');
                var rowNumber = index + 1;
                var sku = parts.Length > 0 ? parts[0].Trim() : string.Empty;
                if (string.IsNullOrWhiteSpace(sku))
                {
                    errors.Add(new CountRowError(rowNumber, "sku", "SKU is required."));
                    continue;
                }

                if (!int.TryParse(parts.Length > 1 ? parts[1].Trim() : string.Empty, out var qty) || qty < 0)
                {
                    errors.Add(new CountRowError(rowNumber, "qty", "Quantity must be a non-negative integer."));
                    continue;
                }

                if (!seen.Add(sku))
                {
                    errors.Add(new CountRowError(rowNumber, "sku", $"Duplicate SKU '{sku}' in the file."));
                    continue;
                }

                if (!await store.SkuInSnapshotAsync(request.HeaderId, sku, token))
                {
                    errors.Add(new CountRowError(rowNumber, "sku", $"SKU '{sku}' is not in the frozen snapshot."));
                    continue;
                }

                rows.Add((rowNumber, sku, qty));
            }

            if (errors.Count > 0)
            {
                return new ImportStockTakeCountsResult(request.HeaderId, request.DryRun, 0,
                    errors[0].Row, errors);
            }

            if (!request.DryRun)
            {
                foreach (var row in rows)
                {
                    await store.UpsertCountAsync(request.HeaderId, row.Sku, row.Qty, token);
                }

                await audit.RecordAsync(new AuditRecord("stocktake.count-import", "InvtSTHeader",
                    request.HeaderId.ToString(),
                    JsonSerializer.Serialize(new { reason = request.Reason, accepted = rows.Count })), token);
            }

            return new ImportStockTakeCountsResult(request.HeaderId, request.DryRun, rows.Count, null,
                Array.Empty<CountRowError>());
        }, ct);
}
