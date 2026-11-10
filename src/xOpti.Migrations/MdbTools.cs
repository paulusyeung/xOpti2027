using System.Diagnostics;
using System.Runtime.CompilerServices;
using System.Text;
using System.Text.RegularExpressions;

namespace xOpti.Migrations;

public static partial class MdbTools
{
    /// <summary>ASCII unit separator (0x1F) used as the extraction field delimiter.</summary>
    public const char FieldSeparator = (char)0x1F;

    /// <summary>Literal marker mdb-export emits for NULL columns (backslash, capital N).</summary>
    public const string NullMarker = "\\N";

    public static async Task<string[]> ListTablesAsync(string mdbPath, CancellationToken ct = default)
    {
        var output = await RunAsync("mdb-tables", ["-1", mdbPath], ct);
        return output.Split('\n', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries);
    }

    public static async Task<List<StagingTable>> ReadSchemaAsync(string mdbPath, CancellationToken ct = default)
    {
        var ddl = await RunAsync("mdb-schema", [mdbPath, "postgres"], ct);
        var tables = new List<StagingTable>();
        foreach (Match tableMatch in TablePattern().Matches(ddl))
        {
            var columns = new List<StagingColumn>();
            foreach (Match colMatch in ColumnPattern().Matches(tableMatch.Groups["body"].Value))
                columns.Add(new StagingColumn(colMatch.Groups["col"].Value, colMatch.Groups["type"].Value.Trim()));
            if (columns.Count > 0)
                tables.Add(new StagingTable(tableMatch.Groups["name"].Value, columns));
        }
        return tables;
    }

    /// <summary>
    /// Streams one table: spawns mdb-export with the unit-separator delimiter, the literal null
    /// marker, ISO date/time formats, and no header row; then parses the output into records with
    /// quoting-aware handling for embedded delimiters and newlines. Invalid UTF-8 bytes are
    /// replaced during decoding (stream-level sanitization).
    /// </summary>
    public static async IAsyncEnumerable<IReadOnlyList<string?>> ExportRowsAsync(
        string mdbPath, string table, [EnumeratorCancellation] CancellationToken ct = default)
    {
        var psi = new ProcessStartInfo("mdb-export")
        {
            RedirectStandardOutput = true,
            RedirectStandardError = true,
            UseShellExecute = false,
        };
        psi.ArgumentList.Add("-H");
        psi.ArgumentList.Add("-d");
        psi.ArgumentList.Add(FieldSeparator.ToString());
        psi.ArgumentList.Add("-0");
        psi.ArgumentList.Add(NullMarker);
        psi.ArgumentList.Add("-D");
        psi.ArgumentList.Add("%Y-%m-%d");
        psi.ArgumentList.Add("-T");
        psi.ArgumentList.Add("%Y-%m-%d %H:%M:%S");
        psi.ArgumentList.Add(mdbPath);
        psi.ArgumentList.Add(table);

        using var process = Process.Start(psi) ?? throw new MigrationException("Failed to start mdb-export.");
        var parser = new RecordParser();
        var buffer = new char[16384];
        // The replacement fallback scrubs invalid UTF-8 bytes on the fly (task 3.3).
        using var reader = new StreamReader(
            process.StandardOutput.BaseStream, new UTF8Encoding(encoderShouldEmitUTF8Identifier: false));

        int read;
        while ((read = await reader.ReadAsync(buffer.AsMemory(), ct)) > 0)
        {
            foreach (var record in parser.Append(new string(buffer, 0, read)))
                yield return record;
        }

        foreach (var record in parser.Complete())
            yield return record;

        var stderr = await process.StandardError.ReadToEndAsync(ct);
        await process.WaitForExitAsync(ct);
        if (process.ExitCode != 0)
            throw new MigrationException($"mdb-export failed for table '{table}' (exit {process.ExitCode}): {stderr.Trim()}");
    }

    public static async Task<string> RunAsync(string file, IEnumerable<string> args, CancellationToken ct = default)
    {
        var psi = new ProcessStartInfo(file)
        {
            RedirectStandardOutput = true,
            RedirectStandardError = true,
            UseShellExecute = false,
        };
        foreach (var a in args) psi.ArgumentList.Add(a);
        using var process = Process.Start(psi) ?? throw new MigrationException($"Failed to start {file}.");
        var stdout = await process.StandardOutput.ReadToEndAsync(ct);
        var stderr = await process.StandardError.ReadToEndAsync(ct);
        await process.WaitForExitAsync(ct);
        if (process.ExitCode != 0)
            throw new MigrationException($"{file} failed (exit {process.ExitCode}): {stderr.Trim()}");
        return stdout;
    }

    [GeneratedRegex(@"CREATE TABLE IF NOT EXISTS ""(?<name>[^""]+)""\s*\((?<body>.*?)\n\);", RegexOptions.Singleline)]
    private static partial Regex TablePattern();

    [GeneratedRegex(@"""(?<col>[^""]+)""\s+(?<type>[A-Z0-9]+(?:\s*\([0-9]+(?:\s*,\s*[0-9]+)?(?:\s*,\s*[0-9]+)?\))?)")]
    private static partial Regex ColumnPattern();
}

/// <summary>
/// Incremental CSV state machine for the unit-separator format emitted by mdb-export:
/// quoted fields may contain the separator and raw newlines; doubled quotes inside a quoted
/// field are literal quotes; an unquoted null marker is NULL; an unquoted empty field is
/// the empty string.
/// </summary>
public sealed class RecordParser
{
    private List<string?> _fields = [];
    private readonly StringBuilder _current = new();
    private bool _inQuotes;
    private bool _quoteMayBeEscape;
    private bool _fieldWasQuoted;
    private bool _sawSeparator;
    private bool _sawQuoted;
    private bool _recordOpen;

    public IEnumerable<List<string?>> Append(string chunk)
    {
        foreach (var c in chunk)
        {
            _recordOpen = true;
            if (_inQuotes)
            {
                if (_quoteMayBeEscape)
                {
                    _quoteMayBeEscape = false;
                    if (c == '"')
                    {
                        _current.Append('"');
                        continue;
                    }
                    _inQuotes = false;
                    // Fall through: dispatch this character in the unquoted state.
                }
                else if (c == '"')
                {
                    _quoteMayBeEscape = true;
                    continue;
                }
                else
                {
                    _current.Append(c);
                    continue;
                }
            }

            switch (c)
            {
                case var sep when sep == MdbTools.FieldSeparator:
                    _sawSeparator = true;
                    EndField();
                    break;
                case '\r':
                    break;
                case '\n':
                    var record = EndRecord();
                    if (record is not null)
                        yield return record;
                    break;
                case '"' when _current.Length == 0:
                    _inQuotes = true;
                    _fieldWasQuoted = true;
                    _sawQuoted = true;
                    break;
                default:
                    _current.Append(c);
                    break;
            }
        }
    }

    public IEnumerable<List<string?>> Complete()
    {
        if (_recordOpen)
        {
            var record = EndRecord();
            if (record is not null)
                yield return record;
        }
    }

    private void EndField()
    {
        _fields.Add(CompleteField());
        ResetField();
    }

    private List<string?>? EndRecord()
    {
        _fields.Add(CompleteField());

        // A stray blank line yields a single unquoted empty field: discard it. Real records may
        // contain an empty quoted field, so quoting/separator evidence must be read pre-reset.
        var discard = _fields.Count == 1 && !_sawSeparator && !_sawQuoted && _fields[0] == string.Empty;
        ResetField();
        var result = discard ? null : _fields;
        _fields = [];
        _recordOpen = false;
        return result;
    }

    private void ResetField()
    {
        _current.Clear();
        _fieldWasQuoted = false;
        _inQuotes = false;
        _quoteMayBeEscape = false;
        _sawSeparator = false;
        _sawQuoted = false;
    }

    private string? CompleteField()
    {
        var value = _current.ToString();
        return !_fieldWasQuoted && value == MdbTools.NullMarker ? null : value;
    }
}
