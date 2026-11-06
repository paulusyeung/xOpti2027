# xOpti Database Migration Comparison Notes

Working notes for validating the manual **MDB -> PostgreSQL** migration. Companion to `MIGRATION_NOTES.md`.

## Purpose

The legacy database and the migrated PostgreSQL database must be compared before cutover. This validates the migration beyond "it imported without errors" and provides the reconciliation evidence required by the hard-cutover plan.

Comparison covers, in order:

1. Schema shape: tables, columns, types, keys, indexes, nullability.
2. Row counts per table.
3. Aggregate reconciliation: sales, tax, payments, refunds, AR/AP, inventory quantity and cost by SKU/lot, control-number sequences, order status counts.
4. Row-level differences where aggregates disagree or where business rules require it.

The comparison is **read-only**. No writes to the production MDB or to the target PostgreSQL database.

## Platform

**Primary: Linux desktop.** Use one Windows VM only as a fallback/reference.

| Platform | Suitability | Use for |
| --- | --- | --- |
| Linux (recommended) | Best | `mdbtools`, `psql`, `pg_dump`, CSV/scripting, Docker, reconciliation checks |
| WSL2 on Windows | Acceptable | Same tooling when the desktop must remain Windows |
| Windows native | Limited | Access/ODBC fallback, legacy VB6 application, Crystal Reports reference, Windows-only vendor tools |

Why Linux is preferred:

- `mdbtools` is native; no Access/ODBC bridge is required.
- `psql`/`pg_dump`, Docker, `grep`, `diff`, and CSV tooling are native and match the target on-prem stack.
- Scripts are reproducible and can run unchanged in CI.
- Linux filesystem, locale, and encoding behavior surfaces migration issues early.

Keep one **Windows VM** for:

- Fallback extraction when an MDB uses Access workgroup security or encryption that `mdbtools` cannot read.
- Running the legacy VB6 application and Crystal Reports side-by-side for parity checks.
- Windows-only peripheral or payment-terminal tooling.

If the desktop must stay Windows, use **WSL2**. Native Linux is cleaner.

## Inputs required

| Item | Needed for | Notes |
| --- | --- | --- |
| Confirmed production MDB | Source of truth | Not the root `SynergyV.mdb` template/sample. Confirm whether the 2016 `OpticalRmd` snapshot is the baseline. |
| Access workgroup/DB password, if any | Extraction | `mdbtools` may not handle encrypted/workgroup-secured files. |
| Read-only PostgreSQL connection | Target comparison | Host, port, database, user, password. Supply via environment variable or session secret; never commit. |
| Or schema/data dumps | Target comparison | `pg_dump --schema-only` plus data/CSV exports if the database is not reachable from the work machine. |
| Manual mapping decisions | Semantic validation | Table/column renames, type conversions, null/boolean/date handling, legacy-to-surrogate ID mapping, dropped/merged tables. |
| Reconciliation definitions | Expected results | Legacy queries or report outputs treated as authoritative for sales, tax, refunds, payments, inventory, AR/AP, sequences, order status. |
| PII authorization and handling | Compliance | Confirm whether an anonymized/masked copy or aggregates-only comparison is required. |
| Tolerance rules | Match criteria | Rounding tolerance for money, tax, and costing; definition of "match". |

## Environment prerequisites

Current work machine status:

- `mdbtools`, `psql`, and `pg_dump`: **not installed**.
- `docker`: available.
- PostgreSQL connection: **not configured**.
- Root `SynergyV.mdb`: template/sample only.

Install on Linux:

```bash
sudo apt install mdbtools postgresql-client
```

Or run `mdbtools` and the PostgreSQL client from containers if packages should not be installed on the desktop.

Useful extraction commands:

```bash
mdb-tables -1 SynergyV.mdb
mdb-schema SynergyV.mdb postgres
mdb-export SynergyV.mdb TxHeader > TxHeader.csv
pg_dump --schema-only "$DATABASE_URL" > target-schema.sql
psql "$DATABASE_URL" -c '\dt'
```

`mdb-schema ... postgres` is a starting point, not a production DDL.

## PII and security rules

- Use a read-only PostgreSQL role for comparison.
- Do not copy the production MDB, PostgreSQL dumps, or row-level PII into the repository.
- Prefer aggregates or an anonymized copy where possible.
- Keep credentials out of chat, files, and git; provide them through environment variables or a local secret store.
- The production snapshots already committed to git remain a separate cleanup item (see `README.md`).

## Deliverables

- Schema/shape diff report: missing tables/columns, type mismatches, key/index differences.
- Row-count reconciliation table.
- Aggregate reconciliation table with tolerances and explicit pass/fail.
- Exception workbook for disagreements, with suspected cause and owner.
- Row-level diff extracts only where needed.
- Repeatable scripts under `tools/legacy-migration/` so every dry run produces the same reports.

## Open questions

- Which MDB is the confirmed production source, and is it encrypted or workgroup-secured?
- Is a read-only PostgreSQL connection available, or should comparison use dumps?
- Where are the manual mapping decisions and transform scripts recorded?
- Which legacy queries/reports are authoritative for each reconciliation total?
- Is an anonymized copy required, or are aggregates sufficient?
- What rounding tolerances are acceptable?
- Is a Windows reference VM available for fallback extraction and Crystal Reports comparison?
