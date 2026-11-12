using System.Text.RegularExpressions;
using Npgsql;

namespace xOpti.Infrastructure.Bootstrap;

/// <summary>
/// Compares a bootstrapped database with the canonical <c>xopti-schema.sql</c>.
/// Only tables declared by the script are compared; app-owned objects created by
/// EF migrations (<c>platform.*</c>, identity tables) are intentionally ignored.
/// </summary>
public static partial class SchemaDrift
{
    public sealed record ExpectedColumn(string Type, bool NotNull);

    public static IReadOnlyDictionary<string, IReadOnlyDictionary<string, ExpectedColumn>> Parse(string schemaFilePath)
    {
        var tables = new Dictionary<string, IReadOnlyDictionary<string, ExpectedColumn>>(StringComparer.Ordinal);
        Dictionary<string, ExpectedColumn>? current = null;
        string? currentName = null;

        foreach (var raw in File.ReadLines(schemaFilePath))
        {
            var line = raw.TrimEnd('\r');
            if (current is null)
            {
                var header = TableHeader().Match(line);
                if (header.Success)
                {
                    currentName = $"{header.Groups["schema"].Value}.{header.Groups["table"].Value}";
                    current = new Dictionary<string, ExpectedColumn>(StringComparer.Ordinal);
                }

                continue;
            }

            if (line.TrimStart().StartsWith(");", StringComparison.Ordinal))
            {
                tables[currentName!] = current;
                current = null;
                currentName = null;
                continue;
            }

            var column = ColumnLine().Match(line);
            if (!column.Success)
            {
                continue;
            }

            var name = column.Groups["name"].Value.Trim('"');
            if (name is "CONSTRAINT" or "PRIMARY" or "UNIQUE" or "CHECK" or "FOREIGN")
            {
                continue;
            }

            var rest = column.Groups["rest"].Value;
            var notNull = rest.Contains("NOT NULL", StringComparison.OrdinalIgnoreCase);
            current[name] = new ExpectedColumn(NormalizeType(rest), notNull);
        }

        return tables;
    }

    public static async Task<IReadOnlyList<string>> CompareAsync(
        string connectionString,
        string schemaFilePath,
        CancellationToken cancellationToken = default)
    {
        var expected = Parse(schemaFilePath);
        var differences = new List<string>();

        await using var connection = new NpgsqlConnection(Persistence.ConnectionStrings.ToNpgsql(connectionString));
        await connection.OpenAsync(cancellationToken);

        foreach (var (table, columns) in expected)
        {
            var parts = table.Split('.', 2);
            var actual = await ReadColumnsAsync(connection, parts[0], parts[1], cancellationToken);
            if (actual is null)
            {
                differences.Add($"{table}: table is missing from the database");
                continue;
            }

            foreach (var (name, column) in columns)
            {
                if (!actual.TryGetValue(name, out var found))
                {
                    differences.Add($"{table}.{name}: column is missing from the database");
                    continue;
                }

                if (!string.Equals(found.Type, column.Type, StringComparison.Ordinal))
                {
                    differences.Add($"{table}.{name}: type differs (expected {column.Type}, found {found.Type})");
                }

                if (found.NotNull != column.NotNull)
                {
                    differences.Add($"{table}.{name}: nullability differs (expected "
                        + $"{(column.NotNull ? "NOT NULL" : "nullable")}, found {(found.NotNull ? "NOT NULL" : "nullable")})");
                }
            }

            foreach (var extra in actual.Keys.Except(columns.Keys, StringComparer.Ordinal))
            {
                differences.Add($"{table}.{extra}: column exists in the database but not in xopti-schema.sql");
            }
        }

        return differences;
    }

    private static async Task<Dictionary<string, ExpectedColumn>?> ReadColumnsAsync(
        NpgsqlConnection connection,
        string schema,
        string table,
        CancellationToken cancellationToken)
    {
        await using var command = connection.CreateCommand();
        command.CommandText = """
            SELECT column_name, data_type, is_nullable
            FROM information_schema.columns
            WHERE table_schema = @schema AND table_name = @table
            """;
        command.Parameters.AddWithValue("schema", schema);
        command.Parameters.AddWithValue("table", table);

        var columns = new Dictionary<string, ExpectedColumn>(StringComparer.Ordinal);
        await using var reader = await command.ExecuteReaderAsync(cancellationToken);
        while (await reader.ReadAsync(cancellationToken))
        {
            columns[reader.GetString(0)] = new ExpectedColumn(
                reader.GetString(1).ToLowerInvariant(),
                string.Equals(reader.GetString(2), "NO", StringComparison.Ordinal));
        }

        return columns.Count == 0 ? null : columns;
    }

    private static string NormalizeType(string rest)
    {
        var type = rest;
        foreach (var marker in new[] { " NOT NULL", " DEFAULT ", " COLLATE ", " GENERATED " })
        {
            var index = type.IndexOf(marker, StringComparison.OrdinalIgnoreCase);
            if (index >= 0)
            {
                type = type[..index];
            }
        }

        type = type.Trim().TrimEnd(',');
        // Strip modifiers such as varying(40) or numeric(12,4); information_schema
        // reports only the base type name.
        var parenthesis = type.IndexOf('(');
        if (parenthesis >= 0)
        {
            type = type[..parenthesis];
        }

        return type.Trim().ToLowerInvariant();
    }

    [GeneratedRegex(@"^CREATE TABLE ""?(?<schema>[a-zA-Z0-9_]+)""?\.(?:""?(?<table>[a-zA-Z0-9_]+)""?) \($")]
    private static partial Regex TableHeader();

    [GeneratedRegex(@"^ {4}""?(?<name>[a-zA-Z0-9_]+)""?\s+(?<rest>.+?),?\s*$")]
    private static partial Regex ColumnLine();
}
