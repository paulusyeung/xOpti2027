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
