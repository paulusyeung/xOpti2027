# xOpti.Migrations

A .NET command-line runner that ports the legacy Access database (`SynergyV.mdb`, from Synergy) into the
PostgreSQL `xOpti` database — end to end: extract, transform, reconcile, and gated cutover.

## Purpose & results

- Replaces the manual data load with a repeatable, verifiable pipeline for the optical-erp legacy migration.
- Streams all 70 MDB tables (~7.7M rows) into PostgreSQL, transforms them into the normalized snake_case
  `public` schema, and proves the result with automated reconciliation reports.
- Never writes to the source: the MDB is fingerprinted (SHA-256) before and verified unchanged after every run.
- Measured on the dev snapshot: extract ~17 min, transform ~15 min, reconcile ~2 min.
- Artifacts: `tools/legacy-migration/reports/reconciliation.md` + `reconciliation-workbook.csv`,
  plus run bookkeeping in `migration.run_log` and `migration.anomaly_quarantine`.

## Platform & approach

- **Platform:** .NET 10 console app (`net10.0`), Npgsql 10, Microsoft.Extensions.Configuration.
  Requires [mdbtools](https://github.com/brianb/mdbtools) ≥ 1.0.0 (`mdb-tables`, `mdb-schema`, `mdb-export`)
  on PATH and a reachable PostgreSQL target.
- **Pipeline:** `extract → stage (validate) → transform → reconcile`, or `sync` (extract+transform) and
  `cutover` (sync+reconcile, committed only if every check passes).
- **Extraction:** one streaming `mdb-export` process per table with a unit-separator (`0x1F`) delimiter,
  `\N` null marker, and ISO date formats; stdout is parsed by a quoting-aware CSV state machine and fed
  directly into `COPY ... FROM STDIN (FORMAT binary)` — no intermediate CSV files. Invalid UTF-8 is
  sanitized on the fly; the invalid Access date `1900-01-00` is substituted with `1899-12-30` during staging.
- **Staging:** the `legacy` schema mirrors the MDB 1:1 with TEXT-typed columns, plus a `legacy._mdb_columns`
  table recording each source column's real MDB type so transforms can apply type-aware normalization.
- **Mapping:** names are matched by a canonical form (lowercase, alphanumerics only — `tx_number` ≡ `txnumber`),
  with a small table of known source typo corrections (e.g. `paltform` → `platform`). The target schema is
  introspected live (`information_schema` + `pg_constraint`), so mapping follows the actual `xOpti` DDL.
- **Transform:** set-based, idempotent `INSERT ... SELECT ... ON CONFLICT DO UPDATE` per table, ordered
  master data → stock/opening → transactions → summaries. Each table runs in its own savepoint (a failing
  table is reported, not fatal); targets ≥ 50k staged rows have secondary indexes dropped and rebuilt inside
  the same savepoint. Sequences are `setval`-ed to the migrated maximum and `preference` / `pref_tx_number`
  control-number counters are advanced past all legacy values.
- **Anomalies:** child rows referencing a missing `txheader` get flagged synthetic stub headers
  (`tx_header.is_synthetic = TRUE`) and are quarantined in `migration.anomaly_quarantine`, keeping foreign
  keys and totals auditable.
- **Reconciliation:** read-only checks — per-table row counts, target-only row detection, financial
  aggregates by type, inventory qty/cost by SKU and lot, order-status counts, sequence positions, control
  numbers — compared within a configurable money tolerance (default 0.005).
- **Transactions & safety:** write commands run inside one transaction; `--dry-run` executes the full
  pipeline then rolls back, and a blocked cutover commits nothing.

## Usage guide

### 1. Prerequisites

- `mdbtools` on PATH (`apt install mdbtools` or equivalent)
- PostgreSQL target with the `xOpti` schema already created (the tool transforms into `public`; it does
  not create the target schema)
- .NET 10 SDK (to run from source)

### 2. Configuration

Create or reuse `eOptical6DAO/.env` (or export the variables; environment wins over the file):

```ini
SYNERGY_MDB=~/data/SynergyV.mdb            # path to the legacy Access database
XOPTI_DATABASE_URL=postgres://user:pass@host:5432/xOpti   # target (key=value strings also accepted)
DATABASE_URL=postgres://...                # optional read-only Synergy5 mirror, used by `stage`
MIGRATION_TOLERANCE=0.005                  # optional default money tolerance
```

The tool locates the repository root by walking up to `xOpti.sln`/`xOpti.slnx`, so run it from within the repo.

### 3. Typical session

```bash
set -a; . eOptical6DAO/.env; set +a

# 1. prove the pipeline without touching the target
dotnet run --project src/xOpti.Migrations -- cutover --dry-run

# 2. step by step (each command reports progress; exit code tells you if it passed)
dotnet run --project src/xOpti.Migrations -- extract      # MDB -> legacy staging schema
dotnet run --project src/xOpti.Migrations -- stage        # staged counts vs. Synergy5 mirror
dotnet run --project src/xOpti.Migrations -- transform    # set-based upserts into public
dotnet run --project src/xOpti.Migrations -- reconcile    # checks + reconciliation reports

# 3. refresh during the freeze window (extract + transform, idempotent)
dotnet run --project src/xOpti.Migrations -- sync

# 4. final cutover: sync + reconcile; commits only if every check passes
dotnet run --project src/xOpti.Migrations -- cutover
```

### 4. Cutover runbook

1. Freeze legacy writes (take the app/MDB offline).
2. Rehearse at least three times beforehand with `cutover --dry-run` against a copy.
3. `pg_dump` the target immediately before cutover so you can restore it if needed.
4. Run `cutover`. On non-zero exit: nothing was committed — inspect
   `tools/legacy-migration/reports/reconciliation.md`, fix the exceptions, rerun.
5. On success: switch the application to `xOpti`, keep the MDB read-only for the audit period.

### 5. Reading the output

- Console: per-table staging/transform status, sequence actions, and failing reconciliation rows.
- `reports/reconciliation.md`: full check table (check, scope, expected, actual, status, detail).
- `reports/reconciliation-workbook.csv`: same data for spreadsheet triage.
- `migration.run_log`: every run with command, mode (write/dry-run), source path + SHA-256, outcome, and a
  JSON detail blob. `migration.anomaly_quarantine`: samples of anomaly primary keys per run.

## Commands & options

### Commands

| Command     | What it does                                                                       | Writes? |
| ----------- | ---------------------------------------------------------------------------------- | ------- |
| `extract`   | Stream every MDB table into the `legacy` staging schema (COPY, no intermediate files) | yes¹  |
| `stage`     | Validate the staged snapshot row-by-row against the optional Synergy5 mirror        | no      |
| `transform` | Idempotent set-based upserts from `legacy` into `public`, sequences + counters      | yes¹    |
| `reconcile` | Read-only checks; writes reconciliation reports to disk                             | no¹     |
| `sync`      | extract + transform in one transaction (freeze-window refresh, captures in-place edits) | yes¹ |
| `cutover`   | sync + reconcile; commits only when every check passes, otherwise rolls back        | gated   |

¹ Inside one transaction; `--dry-run` rolls all of it back.

### Options

| Option               | Description                                                              |
| -------------------- | ------------------------------------------------------------------------ |
| `--dry-run`          | Execute staging, transforms, and checks, then roll back (target untouched) |
| `--env-file <path>`  | Use a different `.env` file (default: `eOptical6DAO/.env`)               |
| `--tolerance <n>`    | Absolute money tolerance for reconciliation (default `0.005`)            |
| `--only <a,b,c>`     | Restrict extract/transform to the named source tables (subset runs)      |
| `-h`, `--help`       | Show usage                                                               |

### Exit codes

| Code | Meaning                                                            |
| ---- | ------------------------------------------------------------------ |
| `0`  | Success                                                            |
| `2`  | Usage or configuration error (bad command, missing env, no MDB)    |
| `3`  | Validation/transform/reconciliation failures (see reports)         |
| `4`  | Cutover blocked by reconciliation — nothing was committed          |
