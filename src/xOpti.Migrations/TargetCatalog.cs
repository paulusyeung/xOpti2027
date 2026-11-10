using Npgsql;

namespace xOpti.Migrations;

public sealed record TargetColumn(string Name, string DataType, int? MaxLength, bool IsNullable);

public sealed class TargetTable
{
    public required string Name { get; init; }
    public required IReadOnlyList<TargetColumn> Columns { get; init; }
    public required IReadOnlyList<string> PrimaryKey { get; init; }
    public IReadOnlyList<(string Column, string Sequence)> Sequences { get; init; } = [];
    public string CanonicalName => NameNormalizer.Canonical(Name);
}

public static class TargetCatalog
{
    public static async Task<Dictionary<string, TargetTable>> LoadAsync(
        NpgsqlConnection conn, string schema = "public", CancellationToken ct = default)
    {
        var byTable = new Dictionary<string, List<TargetColumn>>(StringComparer.Ordinal);
        await using (var cmd = conn.CreateCommand())
        {
            cmd.CommandText = """
                SELECT t.table_name, c.column_name, c.data_type, c.character_maximum_length, c.is_nullable
                FROM information_schema.tables t
                JOIN information_schema.columns c USING (table_schema, table_name)
                WHERE t.table_schema = :schema AND t.table_type = 'BASE TABLE'
                ORDER BY t.table_name, c.ordinal_position;
                """;
            cmd.Parameters.AddWithValue("schema", schema);
            await using var reader = await cmd.ExecuteReaderAsync(ct);
            while (await reader.ReadAsync(ct))
            {
                var table = reader.GetString(0);
                if (!byTable.TryGetValue(table, out var cols))
                    byTable[table] = cols = [];
                cols.Add(new TargetColumn(
                    reader.GetString(1),
                    reader.GetString(2),
                    reader.IsDBNull(3) ? null : reader.GetInt32(3),
                    reader.GetString(4) == "YES"));
            }
        }

        var pkByTable = new Dictionary<string, List<string>>(StringComparer.Ordinal);
        await using (var cmd = conn.CreateCommand())
        {
            cmd.CommandText = """
                SELECT c.conrelid::regclass::text AS tbl, a.attname
                FROM pg_constraint c
                CROSS JOIN LATERAL unnest(c.conkey) WITH ORDINALITY x(attnum, n)
                JOIN pg_attribute a ON a.attrelid = c.conrelid AND a.attnum = x.attnum
                WHERE c.contype = 'p' AND c.connamespace = :schema::regnamespace
                ORDER BY tbl, x.n;
                """;
            cmd.Parameters.AddWithValue("schema", schema);
            await using var reader = await cmd.ExecuteReaderAsync(ct);
            while (await reader.ReadAsync(ct))
            {
                var table = reader.GetString(0);
                if (!pkByTable.TryGetValue(table, out var keys))
                    pkByTable[table] = keys = [];
                keys.Add(reader.GetString(1));
            }
        }

        var seqByTable = new Dictionary<string, List<(string, string)>>(StringComparer.Ordinal);
        await using (var cmd = conn.CreateCommand())
        {
            cmd.CommandText = """
                SELECT t.relname, a.attname, s.oid::regclass::text
                FROM pg_class s
                JOIN pg_depend d ON d.objid = s.oid AND d.deptype = 'a'
                JOIN pg_class t ON t.oid = d.refobjid AND t.relkind = 'r'
                JOIN pg_attribute a ON a.attrelid = t.oid AND a.attnum = d.refobjsubid
                JOIN pg_namespace n ON n.oid = t.relnamespace
                WHERE s.relkind = 'S' AND n.nspname = :schema
                ORDER BY t.relname;
                """;
            cmd.Parameters.AddWithValue("schema", schema);
            await using var reader = await cmd.ExecuteReaderAsync(ct);
            while (await reader.ReadAsync(ct))
            {
                var table = reader.GetString(0);
                if (!seqByTable.TryGetValue(table, out var seqs))
                    seqByTable[table] = seqs = [];
                seqs.Add((reader.GetString(1), reader.GetString(2)));
            }
        }

        return byTable.ToDictionary(
            kv => kv.Key,
            kv => new TargetTable
            {
                Name = kv.Key,
                Columns = kv.Value,
                PrimaryKey = pkByTable.GetValueOrDefault(kv.Key) ?? [],
                Sequences = seqByTable.GetValueOrDefault(kv.Key) ?? [],
            },
            StringComparer.Ordinal);
    }
}
