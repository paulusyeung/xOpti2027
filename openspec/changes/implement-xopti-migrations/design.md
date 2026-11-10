# Design

## Context

See `proposal.md` for motivation. The current repository contains migration notes, a staged PostgreSQL target schema (`xOpti`), a comparison database workflow, and Python comparison helpers, but no .NET solution or migration runner. The target runtime is Linux, so legacy Access data must be read through `mdbtools` rather than Windows-only OLE DB/ODBC. PostgreSQL already contains the normalized target schema and comparison tooling has identified row-count, aggregate, anomaly, and sequence differences.

## Goals / Non-Goals

**Goals:**
- Provide one repeatable entry point for extraction, staging, transformation, reconciliation, and cutover preparation.
- Keep the legacy MDB read-only and make every target write idempotent and transactional.
- Preserve legacy identifiers and produce reconciliation evidence for each dry run.
- Surface known anomalies instead of silently normalizing them away.

**Non-Goals:**
- Replacing EF Core schema migrations owned by the application projects.
- Building the Vue/API application modules.
- Guaranteeing a Windows OLE DB extraction path as the primary workflow.
- Rewriting Crystal Reports or OLAP features.

## Decisions

### Decision: .NET 10 console runner with explicit modes
Implement `xOpti.Migrations` as a .NET 10 console application with commands such as `extract`, `stage`, `transform`, `reconcile`, `sync`, and `cutover`. This matches the planned .NET runtime and gives operators a single auditable entry point.

Alternatives considered: continuing with ad hoc Python/shell scripts. Rejected because the requested deliverable is `xOpti.Migrations`, and a compiled runner is easier to version, configure, and run in CI.

### Decision: In-database ELT with process streaming (`mdb-export` -> `COPY`)
Rather than pulling millions of rows into .NET memory or dumping gigabytes of intermediate CSV files to disk, .NET streams `mdb-export` stdout directly into PostgreSQL `COPY` (`legacy` schema) via `NpgsqlCopyTextWriter`. Transforms are compiled as embedded `.sql` scripts and executed directly in PostgreSQL using set-based operations (`INSERT INTO public.x SELECT ... FROM legacy.x ON CONFLICT ...`).

- Use ASCII Unit Separator `\x1f` (`-d $'\x1f' -0 '\N'`) to eliminate collisions with commas, quotes, and unescaped newlines in notes and addresses.
- Perform stream-level normalization (such as replacing `1900-01-00` with `1899-12-30` and scrubbing invalid multi-byte UTF-8 sequences) on the fly during the pipe.

Alternatives considered: in-memory ORM processing or disk-based CSV intermediates. Rejected because reading 7.75M rows over Npgsql into C# memory causes extreme latency and GC pressure, while writing intermediate CSVs creates disk I/O bottlenecks.

### Decision: Target the normalized 1:1 `xOpti` schema
The target of this migration runner is the normalized 1:1 `xOpti` schema (71 base tables in `public` schema with snake_case naming, `numeric(19,4)` currency, and `timestamptz` dates) preserving legacy primary keys (`txnumber`, `customerno`, etc.). Application-level surrogate keys and vertical slice restructuring are deferred to when `xOpti.Domain` entity models are developed.

Alternatives considered: introducing new surrogate keys during migration. Rejected because target application DDL does not exist yet and introducing artificial keys without entity mapping adds premature risk.

### Decision: Fast-reload staging and set-based upsert for freeze-window sync
Access/Jet has no transaction log, no CDC, and no rowversion column. Historical rows are frequently edited in place (as demonstrated by 84 `TxHeader` and 129 `TxDetails` monetary edits and inventory updates discovered in comparison). An incremental date-filtered delta (`WHERE txdate > last_run`) will miss historical corrections and corrupt AR/AP/inventory balances.

Because full streaming ingestion of the 1.5 GB MDB measures ~17 minutes on the dev snapshot (7.75M rows), and the set-based transform ~15 minutes with secondary-index deferral, the "freeze-window sync" (`sync` command) truncates the `legacy` schema, streams the latest MDB, and executes set-based upserts (`ON CONFLICT DO UPDATE`), ensuring zero missed edits within a roughly 35-minute window.

Alternatives considered: date-based incremental filtering. Rejected because Access lacks change tracking and in-place updates would be permanently lost.

### Decision: Handling Access data defects
Normalize known Access quirks inside the staging/transform pipeline:
- **Booleans**: Access exports `-1` (True) and `0` (False). PostgreSQL `COPY` into `boolean` fails on `-1`. Transform evaluates `legacy_col = -1` (or imports staging as `smallint`).
- **Floating-point line numbers**: `txdetails.rowno` and `txsorderadd.linenumber` are MDB `REAL` (single-precision float) columns that drift (e.g. `1.00000004`). Transforms must cast via `ROUND(rowno::numeric)::integer`.
- **Date defects**: Normalizing `1900-01-00` to `1899-12-30`.

### Decision: Orphan quarantine and synthetic stub strategy
Known legacy anomalies include 478 orphaned `TxSalePerson` rows and 6 orphaned `TxDetails` rows with missing parent `TxHeader` records. If target foreign keys are active, direct load fails.
- Runner routes unresolvable child records into an `anomaly_quarantine` table, or synthesizes stub parent headers flagged with `is_synthetic = true` to preserve foreign key constraints while keeping financial totals auditable.

### Decision: Alphanumeric sequence and counter advancement
Legacy control numbers are prefixed strings (`RC`, `RS`, `SR`, `RJ`, `SJ`, `WC`). PostgreSQL sequences only support integers.
- Advance sequences by extracting the numeric suffix using regex: `COALESCE(MAX(SUBSTRING(txnumber FROM '[0-9]+')::bigint), 0)`.
- Advance both the PostgreSQL sequences AND the `Preference`/`TxNextNumber` table rows so application-level counters and database sequences remain synchronized.

### Decision: Reconciliation as a first-class command
Reconciliation shall run independently and emit Markdown/CSV reports with pass/fail status, measured differences, and tolerance rules. It shall be runnable against the comparison database without writes.

Alternatives considered: embedding checks only inside transform. Rejected because reconciliation must be repeatable and independently auditable.

### Decision: Transaction-scoped secondary-index deferral (added during implementation)
On multi-million-row tables, `ON CONFLICT DO UPDATE` against tables with many secondary indexes dominated transform time (customer: 60k rows took 37s with indexes, 15s without). Because the entire run happens inside one PostgreSQL transaction, the transform drops and rebuilds each bulk table's non-constraint secondary indexes inside that table's savepoint; a failure or rollback restores both data and index definitions atomically.

### Decision: Hash-join-friendly anti-patterns only (added during implementation)
Legacy `NOT IN (SELECT ...)` and `IS NOT DISTINCT FROM` join conditions degrade to per-row SubPlans/nested loops on 1M+ row tables (a header-orphan probe ran >25 minutes before correction). The orphan and target-only checks use `NOT EXISTS` and plain PK equality.

## Risks / Trade-offs

- [mdbtools parsing or type inference differs from Access] → Validate staged row counts and types against an Access/ODBC reference on a Windows VM for anomalies.
- [Historical anomalies such as missing `TxHeader` rows] → Route to quarantine table or synthetic stubs with flags; report them explicitly and avoid breaking foreign keys.
- [Date defects such as `1900-01-00`] → Apply documented normalization (`1899-12-30`) and report affected rows.
- [Case sensitivity and collation differences] → Use explicit normalization and ICU/citext rules where searches depend on casing.
- [PII in logs or reports] → Log counts and identifiers only where needed; keep row-level PII out of repository artifacts.
- [Large migration runtime] → Use streaming process pipes (`mdb-export` stdout to `COPY` with `\x1f` delimiter) and set-based in-database SQL; measure freeze-window duration during dry runs.
- [Schema drift between staged and target databases] → Run schema comparison before each dry run and fail on unexpected differences.

## Migration Plan

1. Confirm the production MDB source and prepare read-only database connections.
2. Create or refresh the `legacy` staging schema and load raw MDB data via streaming pipe.
3. Run schema and row-count comparison against the target.
4. Transform master data, then opening balances and stock, then historical transactions using set-based SQL.
5. Run reconciliation and anomaly reports; resolve exceptions.
6. Advance sequences and control numbers.
7. Freeze legacy writes, run the freeze-window sync (fast staging reload + upsert), reconcile, switch traffic, and retain legacy read-only for audit.

Rollback: restore the pre-cutover `pg_dump` snapshot and keep the legacy database as the system of record until reconciliation passes.

## Open Questions

- What rounding tolerances are acceptable for money, tax, and costing reconciliation?
- Is an anonymized copy required, or are aggregates sufficient for comparison?
- Which legacy queries or reports are authoritative for each reconciliation total?
- Is a Windows reference VM available for fallback extraction and Crystal Reports comparison?
