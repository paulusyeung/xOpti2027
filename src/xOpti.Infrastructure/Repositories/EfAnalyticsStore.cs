using System.Data;
using System.Text;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Storage;
using Npgsql;
using xOpti.Application.Analytics;
using xOpti.Infrastructure.Persistence;
using xOpti.Infrastructure.Persistence.Entities;

namespace xOpti.Infrastructure.Repositories;

public sealed class EfAnalyticsStore(XOptiDbContext context) : IAnalyticsStore
{
    public async Task<AnalyticsFeedDto> GetFeedAsync(string viewKey, string? from, string? to,
        string? branch, string? staff, string? department, string? classCode,
        string? category, bool includeSensitive, int rowCap, CancellationToken ct)
    {
        var definition = AnalyticsViews.Get(viewKey);
        var fields = definition.Fields
            .Where(field => includeSensitive || !field.Sensitive).ToList();
        var cap = Math.Clamp(rowCap, 1, 20_000);
        var where = new List<string>();
        var parameters = new List<NpgsqlParameter>();
        void Add(string clause, object value)
        {
            var name = $"@p{parameters.Count}";
            where.Add(clause.Replace("{p}", name));
            parameters.Add(new NpgsqlParameter(name, value));
        }

        if (viewKey is "sales_by_cost" or "sales_by_lsp" or "category_summary")
        {
            var fromPeriod = Period(from);
            var toPeriod = Period(to);
            if (viewKey == "category_summary")
            {
                // category_summary has no period column; period is applied upstream.
            }
            else
            {
                if (fromPeriod is not null) Add("\"period\" >= {p}", fromPeriod);
                if (toPeriod is not null) Add("\"period\" <= {p}", toPeriod);
            }
        }
        else if (viewKey == "orders_in_progress")
        {
            if (from is not null) Add("\"date_of_entry\" >= {p}::date", from);
            if (to is not null) Add("\"date_of_entry\" < ({p}::date + interval '1 day')", to);
        }

        if (!string.IsNullOrWhiteSpace(branch) && definition.Fields.Any(f => f.Key == "branch"))
            Add("\"branch\" = {p}", branch.Trim());
        if (!string.IsNullOrWhiteSpace(staff) && definition.Fields.Any(f => f.Key == "staff_code"))
            Add("\"staff_code\" = {p}", staff.Trim());
        if (!string.IsNullOrWhiteSpace(department)
            && definition.Fields.Any(f => f.Key == "department_code"))
            Add("\"department_code\" = {p}", department.Trim());
        if (!string.IsNullOrWhiteSpace(classCode)
            && definition.Fields.Any(f => f.Key == "class_code"))
            Add("\"class_code\" = {p}", classCode.Trim());
        if (!string.IsNullOrWhiteSpace(category)
            && definition.Fields.Any(f => f.Key == "category_code"))
            Add("\"category_code\" = {p}", category.Trim());

        var sql = new StringBuilder("SELECT ");
        sql.Append(string.Join(", ", fields.Select(field => $"\"{field.Key}\"")));
        sql.Append(" FROM ").Append(definition.ReadModel);
        if (where.Count > 0) sql.Append(" WHERE ").Append(string.Join(" AND ", where));
        sql.Append(" LIMIT ").Append(cap + 1);

        var connection = context.Database.GetDbConnection();
        if (connection.State != ConnectionState.Open) await connection.OpenAsync(ct);
        await using var command = connection.CreateCommand();
        command.CommandText = sql.ToString();
        command.Transaction = context.Database.CurrentTransaction?.GetDbTransaction();
        foreach (var parameter in parameters) command.Parameters.Add(parameter);
        var data = new List<IReadOnlyList<object?>>();
        await using var reader = await command.ExecuteReaderAsync(ct);
        while (await reader.ReadAsync(ct))
        {
            var row = new object?[reader.FieldCount];
            for (var index = 0; index < reader.FieldCount; index++)
                row[index] = reader.IsDBNull(index) ? null : reader.GetValue(index);
            data.Add(row);
        }
        await reader.DisposeAsync();
        var truncated = data.Count > cap;
        if (truncated) data.RemoveAt(data.Count - 1);

        var state = await context.ReadModelStates.AsNoTracking()
            .SingleOrDefaultAsync(row => row.ModelKey == definition.Key, ct);
        var asOf = state?.AsOf ?? DateTimeOffset.UtcNow;
        var stale = state?.AsOf is null
            || DateTimeOffset.UtcNow - state.AsOf.Value > TimeSpan.FromHours(24);
        return new AnalyticsFeedDto(definition.Key, definition.Name, fields, data, asOf,
            stale, truncated, cap);
    }

    public async Task<IReadOnlyList<AnalyticsViewDto>> ListSavedAsync(string ownerUserId,
        CancellationToken ct) =>
        await context.AnalyticsSavedViews.AsNoTracking()
            .Where(row => row.OwnerUserId == ownerUserId || row.IsShared)
            .OrderByDescending(row => row.UpdatedAt)
            .Select(row => new AnalyticsViewDto(row.Id, row.ViewKey, row.Name, row.IsShared,
                row.OwnerUserId, row.ConfigJson, row.CreatedAt, row.UpdatedAt,
                row.OwnerUserId == ownerUserId))
            .ToListAsync(ct);

    public async Task<AnalyticsViewDto> SaveAsync(string viewKey, string name, bool isShared,
        string configJson, string ownerUserId, CancellationToken ct)
    {
        AnalyticsViews.Get(viewKey);
        var now = DateTimeOffset.UtcNow;
        var row = new AnalyticsSavedView
        {
            ViewKey = viewKey, Name = name.Trim(), IsShared = isShared,
            ConfigJson = configJson, OwnerUserId = ownerUserId,
            CreatedAt = now, UpdatedAt = now,
        };
        context.AnalyticsSavedViews.Add(row);
        await context.SaveChangesAsync(ct);
        return new AnalyticsViewDto(row.Id, row.ViewKey, row.Name, row.IsShared,
            row.OwnerUserId, row.ConfigJson, row.CreatedAt, row.UpdatedAt, true);
    }

    public async Task<AnalyticsViewDto?> GetSavedAsync(long id, string userId,
        CancellationToken ct)
    {
        var row = await context.AnalyticsSavedViews.AsNoTracking()
            .SingleOrDefaultAsync(item => item.Id == id, ct);
        if (row is null) return null;
        if (row.OwnerUserId != userId && !row.IsShared) return null;
        return new AnalyticsViewDto(row.Id, row.ViewKey, row.Name, row.IsShared,
            row.OwnerUserId, row.ConfigJson, row.CreatedAt, row.UpdatedAt,
            row.OwnerUserId == userId);
    }

    public async Task DeleteSavedAsync(long id, string userId, CancellationToken ct)
    {
        var row = await context.AnalyticsSavedViews
            .SingleOrDefaultAsync(item => item.Id == id && item.OwnerUserId == userId, ct);
        if (row is null) return;
        context.AnalyticsSavedViews.Remove(row);
        await context.SaveChangesAsync(ct);
    }

    private static string? Period(string? value)
    {
        if (string.IsNullOrWhiteSpace(value)) return null;
        var trimmed = value.Trim();
        if (trimmed.Length >= 7 && trimmed[4] == '-') return trimmed[..7];
        return trimmed;
    }
}
