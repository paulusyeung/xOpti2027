# Legacy MDB to xOpti comparison

Repeatable comparison of the legacy Access database (`SynergyV.mdb`) against the
staged PostgreSQL comparison database. The final target schema/database is
`xOpti`; `Synergy5` is only a PascalCase reference mirror.

## Prerequisites

- `mdbtools` v1.0.0 or newer
- `psql` client matching the PostgreSQL server
- Docker container `psql-17` on `localhost:5432`, or an equivalent PostgreSQL 17 server
- `eOptical6DAO/.env` with `DATABASE_URL`, `XOPTI_DATABASE_URL`, and `SYNERGY_MDB`

Load the environment before running anything:

```bash
set -a; . eOptical6DAO/.env; set +a
```

The comparison database is `xopti_migration_compare`. It contains:

- `public` schema: a copy of `xOpti`
- `mdb` schema: the 70 MDB tables staged from `SynergyV.mdb`

The comparison is read-only with respect to the production MDB and `xOpti`.

## Stage the comparison database

```bash
docker exec psql-17 psql -U postgres -c 'drop database if exists xopti_migration_compare;'
docker exec psql-17 psql -U postgres -c 'create database xopti_migration_compare;'
pg_dump --schema-only --no-owner --no-privileges "$XOPTI_DATABASE_URL" \
  | docker exec -i psql-17 psql -U postgres -d xopti_migration_compare
# data copy and MDB staging are performed by the migration runbook in MIGRATE_DB_NOTES.md
```

The MDB staging load must use `mdb-export -H -d $'\x1f' -0 '\N'`
with `-D '%Y-%m-%d' -T '%Y-%m-%d %H:%M:%S'`, followed by replacement of
`1900-01-00` with `1899-12-30`.

## Run

```bash
python3 tools/legacy-migration/compare.py schema
python3 tools/legacy-migration/compare.py counts
python3 tools/legacy-migration/compare.py keys
```

Outputs are Markdown on stdout. Save them with shell redirection when a report
artifact is required.

## Outputs

- `reports/comparison-report.md`: consolidated findings and pass/fail summary
- `reports/exception-workbook.csv`: exception inventory with suspected cause and action

## Notes

- `mdb-count` undercounts rows. Counts in this project use `mdb-export | wc -l`.
- `txdetails.rowno` and `txsorderadd.linenumber` are MDB `REAL` values and must be
  rounded before joining to the integer target columns.
- `txdetails.txnumber` suffix casing differs between source and target; joins use
  `upper()`.
- Summary-table year values such as `97`, `995`, `997`, `4997`, `7848`, and `9797`
  are source-data defects preserved by both systems; they are reported, not
  normalized, during comparison.

## xOpti.Migrations runner

`src/xOpti.Migrations` automates the port itself (extract, transform, reconcile, cutover)
so the data load no longer has to be done manually.

```bash
set -a; . eOptical6DAO/.env; set +a        # SYNERGY_MDB + connection URLs

dotnet run --project src/xOpti.Migrations -- --help
dotnet run --project src/xOpti.Migrations -- extract           # stream MDB -> legacy staging schema
dotnet run --project src/xOpti.Migrations -- stage             # validate staging vs Synergy5 mirror
dotnet run --project src/xOpti.Migrations -- transform         # set-based idempotent upserts
dotnet run --project src/xOpti.Migrations -- reconcile         # row counts, aggregates, sequences
dotnet run --project src/xOpti.Migrations -- sync              # extract + transform in one pass
dotnet run --project src/xOpti.Migrations -- cutover           # sync + reconcile, gated on PASS
dotnet run --project src/xOpti.Migrations -- cutover --dry-run # full pipeline, rolled back
```

- `--only Table1,Table2` restricts extract to a table subset; `--tolerance 0.005` overrides
  the reconciliation money tolerance; `--env-file` points elsewhere.
- The runner streams `mdb-export` stdout directly into PostgreSQL `COPY` (no intermediate
  CSVs) and performs set-based transforms inside one transaction. A blocked cutover or a
  dry run rolls everything back; the source MDB checksum is verified unchanged after every run.
- Orphaned child rows get flagged synthetic `tx_header` rows (`is_synthetic = true`) and are
  listed in `migration.anomaly_quarantine`; run bookkeeping lands in `migration.run_log`.
- Reconciliation writes `reports/reconciliation.md` and `reports/reconciliation-workbook.csv`
  (the comparison tool keeps its own `comparison-report.md` / `exception-workbook.csv`).

### Cutover sequence (runbook)

1. Freeze legacy writes.
2. `dotnet run --project src/xOpti.Migrations -- cutover`
   (rehearsed at least three times beforehand with `cutover --dry-run` against a copy).
3. On non-zero exit: nothing was committed; inspect `reports/reconciliation.md`, fix the
   exceptions, rerun.
4. On success: switch the proxy, keep the MDB read-only for the audit period.

Rollback: `docker exec psql-17 psql -U postgres -c 'drop database if exists xOpti_rollback;'`
style snapshot restore — take `pg_dump` of `xOpti` immediately before cutover and restore
that snapshot if a rerun is needed.

Measured on the dev snapshot (70 tables, 7.7M rows): extract ~17 min, transform ~15 min
(index maintenance deferred inside the load transaction), reconcile ~2 min. Rehearse on the
production copy to measure the real freeze window.
