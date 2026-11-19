using System.Data;
using System.Globalization;
using System.Text;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Storage;
using Npgsql;
using xOpti.Application.Reporting;
using xOpti.Infrastructure.Persistence;

namespace xOpti.Infrastructure.Repositories;

public sealed class EfReportDataStore(XOptiDbContext context) : IReportDataStore
{
    public async Task<ReportDataPage> QueryAsync(
        ReportReadModelDefinition definition,
        int rowCap,
        ReportParameterValues parameters,
        CancellationToken ct)
    {
        var columns = definition.Fields
            .Select(field => new ReportColumn(field.Key, field.Label, field.Type))
            .ToList();
        var cap = rowCap <= 0 ? 100_000 : rowCap;
        var where = new List<string>();
        var sqlParameters = new List<NpgsqlParameter>();
        void Add(string clause, object value)
        {
            var name = $"@p{sqlParameters.Count}";
            where.Add(clause.Replace("{p}", name));
            sqlParameters.Add(new NpgsqlParameter(name, value));
        }

        var dateFrom = parameters.Get("AskDateFrom") ?? parameters.Get("AskLedgerDateFrom");
        var dateTo = parameters.Get("AskDateTo");
        if (definition.DateColumn is not null)
        {
            if (dateFrom is not null)
                Add($"\"{definition.DateColumn}\" >= {{p}}::date", DateOnly.Parse(dateFrom, CultureInfo.InvariantCulture));
            if (dateTo is not null)
                Add($"\"{definition.DateColumn}\" < ({{p}}::date + interval '1 day')", DateOnly.Parse(dateTo, CultureInfo.InvariantCulture));
        }

        if (definition.TxNumberColumn is not null)
        {
            if (parameters.Get("AskTxNumberFrom") is { } txFrom)
                Add($"\"{definition.TxNumberColumn}\" >= {{p}}", txFrom);
            if (parameters.Get("AskTxNumberTo") is { } txTo)
                Add($"\"{definition.TxNumberColumn}\" <= {{p}}", txTo);
        }

        if (definition.DepartmentColumn is not null && parameters.Get("AskDept") is { } dept)
            Add($"\"{definition.DepartmentColumn}\" = {{p}}", dept);
        if (definition.ClassColumn is not null && parameters.Get("AskClass") is { } clazz)
            Add($"\"{definition.ClassColumn}\" = {{p}}", clazz);
        if (definition.CategoryColumn is not null && parameters.Get("AskCat") is { } category)
            Add($"\"{definition.CategoryColumn}\" = {{p}}", category);
        if (definition.SkuColumn is not null && parameters.Get("AskSku") is { } sku)
            Add($"\"{definition.SkuColumn}\" ILIKE {{p}}", $"%{sku}%");
        if (definition.StaffColumn is not null && parameters.Get("AskStaff") is { } staff)
            Add($"\"{definition.StaffColumn}\" = {{p}}", staff);
        if (definition.BranchColumn is not null && parameters.Get("AskBranch") is { } branch)
            Add($"\"{definition.BranchColumn}\" = {{p}}", branch);

        if (definition.CustomerColumn is not null
            && parameters.Get("AskCustomerFrom") is { } customer)
        {
            if (int.TryParse(customer, out var customerId))
                Add($"\"{definition.CustomerColumn}\" = {{p}}", customerId);
            else if (definition.Fields.Any(field => field.Key == "customer_name"))
                Add("\"customer_name\" ILIKE {p}", $"%{customer}%");
            else
                Add($"\"{definition.CustomerColumn}\"::text ILIKE {{p}}", $"%{customer}%");
        }

        var sql = new StringBuilder("SELECT ");
        sql.Append(string.Join(", ", definition.Fields.Select(field => $"\"{field.Key}\"")));
        sql.Append(" FROM ").Append(definition.View);
        if (where.Count > 0)
            sql.Append(" WHERE ").Append(string.Join(" AND ", where));
        if (!string.IsNullOrWhiteSpace(definition.DefaultSort))
            sql.Append(" ORDER BY ").Append(definition.DefaultSort);
        sql.Append(" LIMIT ").Append(cap + 1);

        var connection = context.Database.GetDbConnection();
        if (connection.State != ConnectionState.Open) await connection.OpenAsync(ct);
        await using var command = connection.CreateCommand();
        command.CommandText = sql.ToString();
        command.Transaction = context.Database.CurrentTransaction?.GetDbTransaction();
        foreach (var parameter in sqlParameters) command.Parameters.Add(parameter);

        var rows = new List<IReadOnlyList<object?>>();
        await using var reader = await command.ExecuteReaderAsync(ct);
        while (await reader.ReadAsync(ct))
        {
            var row = new object?[reader.FieldCount];
            for (var index = 0; index < reader.FieldCount; index++)
                row[index] = reader.IsDBNull(index) ? null : reader.GetValue(index);
            rows.Add(row);
        }
        await reader.DisposeAsync();
        var truncated = rows.Count > cap;
        if (truncated) rows.RemoveAt(rows.Count - 1);

        var state = await context.ReadModelStates.AsNoTracking()
            .SingleOrDefaultAsync(row => row.ModelKey == "report_views", ct);
        var asOf = state?.AsOf ?? DateTimeOffset.UtcNow;
        return new ReportDataPage(columns, rows, truncated, cap, asOf, false);
    }
}
