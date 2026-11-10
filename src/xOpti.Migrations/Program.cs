using System.Text.Json;
using Npgsql;

namespace xOpti.Migrations;

public static class Program
{
    public static async Task<int> Main(string[] args)
    {
        CommandLine.Options options;
        try
        {
            options = CommandLine.Parse(args);
        }
        catch (MigrationException ex)
        {
            Console.Error.WriteLine("error: " + ex.Message);
            return 2;
        }

        if (options.ShowHelp)
        {
            Console.WriteLine(CommandLine.Help);
            return 0;
        }

        try
        {
            return await RunAsync(options);
        }
        catch (MigrationException ex)
        {
            Console.Error.WriteLine("error: " + ex.Message);
            return 2;
        }
    }

    private static async Task<int> RunAsync(CommandLine.Options options)
    {
        var config = MigrationConfig.Load(options.EnvFile, options.Tolerance);
        Console.WriteLine($"source:  {config.SynergyMdbPath}");

        var source = await SourceValidator.FingerprintAsync(config.SynergyMdbPath);
        Console.WriteLine($"         sha256 {source.Sha256} ({source.TableCount} tables)");
        Console.WriteLine($"target:  xOpti  mode: {(options.DryRun ? "DRY RUN (rollback)" : "WRITE")}");
        Console.WriteLine();

        var only = options.OnlyTables is null
            ? null
            : new HashSet<string>(options.OnlyTables.Select(NameNormalizer.Canonical), StringComparer.OrdinalIgnoreCase);

        await using var conn = Open(config.TargetConnectionString);
        await conn.OpenAsync();
        await MigrationJournal.EnsureSchemaAsync(conn, config.MigrationSchema);

        var writes = options.Command is "extract" or "transform" or "sync" or "cutover";
        await using var tx = writes ? await conn.BeginTransactionAsync() : null;
        var blocked = false;

        try
        {
            int exit;
        if (options.Command is "sync" or "cutover")
        {
            var (syncExit, syncBlocked) = await SyncAsync(
                conn, config, only, source, options.DryRun, gate: options.Command == "cutover");
            blocked = syncBlocked;
            exit = syncExit;
        }
        else
        {
            exit = options.Command switch
            {
                "extract" => await CommandExtractAsync(conn, config, only, source, options.DryRun),
                "stage" => await CommandStageAsync(conn, config),
                "transform" => await CommandTransformAsync(conn, config, source, options.DryRun),
                "reconcile" => await CommandReconcileAsync(conn, config, source, "reconcile", options.DryRun),
                _ => throw new MigrationException($"Unknown command '{options.Command}'."),
            };
        }

            var commit = writes && !options.DryRun && !blocked && tx is not null;
            if (commit && tx is not null)
                await tx.CommitAsync();
            else if (writes && tx is not null)
            {
                // Dry run (and blocked cutover) prove the full pipeline yet leave the target untouched.
                await SourceValidator.VerifyUnchangedAsync(source);
                await tx.RollbackAsync();
                if (options.DryRun)
                    Console.WriteLine("\ndry run: rolled back; source checksum verified unchanged.");
            }

            return exit;
        }
        catch
        {
            if (tx is not null)
                await tx.RollbackAsync();
            throw;
        }
        finally
        {
            await SourceValidator.VerifyUnchangedAsync(source);
        }
    }

    private static async Task<int> CommandExtractAsync(
        NpgsqlConnection conn, MigrationConfig config, HashSet<string>? only, SourceFingerprint source, bool dryRun)
    {
        var runId = await MigrationJournal.StartRunAsync(conn, config.MigrationSchema, "extract", dryRun, source);
        var result = await new ExtractionRunner(config).ExtractAsync(conn, only, source);
        await MigrationJournal.EndRunAsync(conn, config.MigrationSchema, runId, "done", ExtractionRunner.ToDetailsJson(result));
        Console.WriteLine($"\nstaged {result.Tables.Count} tables, {result.TotalRows:N0} rows, {result.TotalDateFixes} date defects fixed.");
        return 0;
    }

    private static async Task<int> CommandStageAsync(NpgsqlConnection conn, MigrationConfig config)
    {
        var (passed, failed) = await StageValidator.ValidateAsync(conn, config);
        Console.WriteLine($"\nstage validation: {passed} ok, {failed} failed.");
        return failed == 0 ? 0 : 3;
    }

    private static async Task<int> CommandTransformAsync(NpgsqlConnection conn, MigrationConfig config, SourceFingerprint source, bool dryRun)
    {
        return await TransformAsync(conn, config, source, dryRun);
    }

    private static async Task<int> TransformAsync(
        NpgsqlConnection conn, MigrationConfig config, SourceFingerprint source, bool dryRun, long? existingRunId = null)
    {
        var staged = await ExtractionRunner.ReadStagedMetadataAsync(conn, config.LegacySchema);
        if (staged.Count == 0)
            throw new MigrationException($"Nothing staged in schema '{config.LegacySchema}'. Run extract first.");

        var catalog = await TargetCatalog.LoadAsync(conn);
        var runId = existingRunId ?? await MigrationJournal.StartRunAsync(conn, config.MigrationSchema, "transform", dryRun, source);
        var report = await new TransformRunner(config).RunAsync(conn, runId, staged, catalog);

        Console.WriteLine($"transform: {report.Tables.Count(t => t.Status is "upserted" or "loaded")} table(s) written, " +
                          $"{report.Tables.Count(t => t.Status == "failed")} failed, " +
                          $"{report.Tables.Count(t => t.Status.StartsWith("skipped"))} skipped.");
        foreach (var row in report.Tables.Where(t => t.Status is "failed" or "no-target"))
            Console.WriteLine($"  {row.Status}: {row.SourceTable} -> {row.TargetTable ?? "-"}: {row.Detail}");
        foreach (var action in report.SequenceActions)
            Console.WriteLine("  " + action);

        await MigrationJournal.EndRunAsync(conn, config.MigrationSchema, runId,
            report.AllOk ? "done" : "done-with-failures",
            JsonSerializer.Serialize(new
            {
                tables = report.Tables.Select(t => new { t.SourceTable, t.TargetTable, t.Status, t.Rows, t.Detail }),
                anomalies = report.Anomalies.Select(a => new { a.Kind, a.Table, a.Detail, a.Count }),
            }));

        return report.AllOk ? 0 : 3;
    }

    private static async Task<int> CommandReconcileAsync(
        NpgsqlConnection conn, MigrationConfig config, SourceFingerprint source, string command, bool dryRun)
    {
        var catalog = await TargetCatalog.LoadAsync(conn);
        var report = await new ReconcileRunner(config).RunAsync(conn, catalog);
        var (md, csv) = ReconcileReportWriter.Write(config, report, command, dryRun, source);

        foreach (var row in report.Rows.Where(r => r.Status is "FAIL" or "INFO"))
            Console.WriteLine($"  {row.Status}: {row.Check} [{row.Scope}] expected={row.Expected} actual={row.Actual} {row.Detail}");
        Console.WriteLine($"\nreconciliation: {(report.Passed ? "PASS" : $"FAIL ({report.FailCount})")} " +
                          $"({report.Rows.Count} checks) -> {Path.GetRelativePath(config.RepositoryRoot, md)}");
        return report.Passed ? 0 : 3;
    }

    /// <summary>sync/cutover: staging reload + set-based upserts in one transaction, optional gating.</summary>
    private static async Task<(int Exit, bool Blocked)> SyncAsync(
        NpgsqlConnection conn, MigrationConfig config, HashSet<string>? only,
        SourceFingerprint source, bool dryRun, bool gate)
    {
        var label = gate ? "cutover" : "sync";
        var runId = await MigrationJournal.StartRunAsync(conn, config.MigrationSchema, label, dryRun, source);

        Console.WriteLine($"[{label}] extracting...");
        var extract = await new ExtractionRunner(config).ExtractAsync(conn, only, source);

        Console.WriteLine($"[{label}] transforming...");
        var transformExit = await TransformAsync(conn, config, source, dryRun, runId);

        Console.WriteLine($"[{label}] reconciling...");
        var reconcileExit = await CommandReconcileAsync(conn, config, source, label, dryRun);

        var outcome = (transformExit, reconcileExit) switch
        {
            (0, 0) => "reconciled",
            (_, 0) => "reconciled-with-notes",
            _ => "reconciliation-failed",
        };
        await MigrationJournal.EndRunAsync(conn, config.MigrationSchema, runId, outcome,
            JsonSerializer.Serialize(new { rows = extract.TotalRows, dateFixes = extract.TotalDateFixes, transformExit, reconcileExit }));

        var blocked = gate && (reconcileExit != 0 || transformExit != 0);
        if (blocked)
            Console.Error.WriteLine($"cutover blocked: reconciliation failed ({outcome}). Changes will be rolled back.");
        else
            Console.WriteLine($"\n{label} complete: {extract.TotalRows:N0} rows staged, outcome={outcome}.");

        return (blocked ? 4 : 0, blocked);
    }

    private static NpgsqlConnection Open(string connectionString) =>
        new(ToNpgsqlConnectionString(connectionString));

    /// <summary>Accepts either key=value connection strings or postgres:// URIs (percent-decoded).</summary>
    public static string ToNpgsqlConnectionString(string connectionString)
    {
        NpgsqlConnectionStringBuilder builder;
        if (connectionString.StartsWith("postgres://", StringComparison.OrdinalIgnoreCase)
            || connectionString.StartsWith("postgresql://", StringComparison.OrdinalIgnoreCase))
        {
            var uri = new Uri(connectionString.Replace("postgresql://", "postgres://", StringComparison.OrdinalIgnoreCase));
            builder = new NpgsqlConnectionStringBuilder
            {
                Host = uri.Host,
                Port = uri.Port > 0 ? uri.Port : 5432,
                Database = uri.AbsolutePath.Trim('/'),
            };
            var userInfo = uri.UserInfo.Split(':', 2);
            builder.Username = Uri.UnescapeDataString(userInfo[0]);
            if (userInfo.Length > 1)
                builder.Password = Uri.UnescapeDataString(userInfo[1]);
            foreach (var pair in uri.Query.TrimStart('?').Split('&', StringSplitOptions.RemoveEmptyEntries))
            {
                var kv = pair.Split('=', 2);
                if (kv.Length == 2)
                    builder[kv[0]] = Uri.UnescapeDataString(kv[1]);
            }
        }
        else
        {
            builder = new NpgsqlConnectionStringBuilder(connectionString);
        }

        builder.Timeout = 60;
        builder.CommandTimeout = 1800;
        return builder.ConnectionString;
    }
}
