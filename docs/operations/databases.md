# Databases and schemas

xOpti needs **one PostgreSQL database** in production. The additional databases
on a development machine are scratch copies used by migration, comparison, and
reconciliation tooling. They must not be created on the production host.

The deployment runbook is [`deployment.md`](deployment.md); this document is the
inventory of what lives where.

## 1. Database inventory

The following is the local development inventory observed on 2026-11-21.

| Database | Purpose | Required in production? |
| --- | --- | --- |
| `xopti` | **Application database** created by `docker compose.yml`. Lowercase name. | **Yes** |
| `xOpti` | PascalCase local development database used by `appsettings.Development.json`. | No — dev only |
| `Synergy5` | Read-only PascalCase mirror of the legacy MDB, used by `xOpti.Migrations -- stage`. | No — migration reference only |
| `postgres` | Maintenance database. Locally it has accidentally accumulated legacy scratch tables; xOpti does not use it. | No |
| `xopti_design` | Local scratch database containing only `platform` + ASP.NET Identity tables. Not referenced by code or docs. | No |
| `xopti_infra_dev` | Local legacy staging copy with `public` (71 legacy tables) and `migration` bookkeeping. | No |
| `xopti_migration_compare` | Disposable comparison DB: `public` = copy of xOpti, `mdb` = staged MDB tables. Created by `tools/legacy-migration/README.md`. | No |
| `xopti_migration_test` | Disposable scratch DB used by `tests/xOpti.Migrations.Tests` (`legacy`, `migration`, `public`). | No |
| `xopti_wholesale_reconciliation` | Disposable clone used by `scripts/wholesale-reconciliation.py`; contains the full migrated schema. | No |

> **Name casing matters.** `docker/compose.yml` creates `xopti` (lowercase),
> while `src/xOpti.Api/appsettings.Development.json` points at `xOpti`
> (PascalCase). On Linux these are different databases. Standardise on
> **lowercase `xopti`** for deployment and avoid creating a second one with an
> unquoted `CREATE DATABASE` command.

## 2. Schemas in the application database

`xopti` (and the local `xOpti`) contains four application-visible schemas.

| Schema | Owner / migration authority | Contents |
| --- | --- | --- |
| `public` | Legacy migration (`tools/legacy-migration/schema/xopti-schema.sql`); EF mappings are `ExcludeFromMigrations()` | Migrated legacy tables such as `customer`, `staff`, `inventory`, `tx_header`, `tx_details`, `branch`, `brand`, plus ASP.NET Identity tables and `__EFMigrationsHistory` |
| `platform` | EF Core migrations owned by xOpti | App-owned tables: `schema_baseline`, `audit_log`, `entity_retirement`, `idempotency_record`, and the POS, claims, optical, wholesale and refund tables |
| `migration` | `src/xOpti.Migrations` runner | `run_log`, `anomaly_quarantine` — migration run bookkeeping only |
| `reporting` | EF Core migrations + `ReportingRefreshJob` | `read_model_state`, `report_run`, `analytics_saved_view`, reporting views (`v_sales`, `v_cash`, …) and four materialised OLAP views (`mv_olap_*`) |

Local counts for `xOpti` at the time of writing:

```text
migration  2 base tables
platform  33 base tables
public    79 base tables + 42 views
reporting  3 base tables + 12 views
```

### `public` — legacy data

These tables are the migrated source data. They keep legacy natural keys and
column names. They are **not** created or altered by EF migrations; their DDL
lives in `tools/legacy-migration/schema/xopti-schema.sql`. Reference-backed
screens read from tables such as `city`, `brand`, `add`, `doctor`, `branch`,
`job_title`, `job_nature` and `salutation`.

`public` also contains the ASP.NET Identity tables (`asp_net_users`,
`asp_net_roles`, …) and `__EFMigrationsHistory`, both owned by EF.

### `platform` — xOpti-owned data

Tables created and evolved by EF migrations. Notable ones:

- `schema_baseline` — checksum guard used by `--bootstrap` / readiness
- `audit_log` — audit events, including `reference.create`, `reference.update`, `reference.retire`
- `entity_retirement` — soft-delete markers for reference kinds (composite key `entity_type`, `entity_key`)
- `idempotency_record` — safe replay of unsafe API requests
- POS, claim, prescription, optical-order and wholesale tables

### `migration` — migration runner bookkeeping

Only `xOpti.Migrations` writes here. `run_log` records each extract/transform/
reconcile/cutover run; `anomaly_quarantine` holds synthetic headers created for
orphaned child rows. Do not confuse this schema with the `migration` schema in
`xopti_infra_dev`, which is a scratch copy.

### `reporting` — read models

`reporting.read_model_state` tracks the last refresh of each materialised view.
`ReportingRefreshJob` refreshes `mv_olap_sales_by_cost`, `mv_olap_sales_by_lsp`,
`mv_olap_orders_in_progress` and `mv_olap_category_summary`. The `v_*` views are
read-only reporting projections.

## 3. Deployment expectations

A fresh production host only needs:

1. PostgreSQL 17 with an empty **lowercase** `xopti` database.
2. `docker compose -p xopti -f docker/compose.yml run --rm api --bootstrap`.
3. `docker compose -p xopti -f docker/compose.yml up -d api web`.

`--bootstrap` installs the legacy schema, runs EF migrations, and seeds
reference/smoke data. `--migrate` applies only app-owned EF migrations later.

Do **not** create `Synergy5`, `xopti_migration_*`, `xopti_infra_dev`,
`xopti_design`, or `xopti_wholesale_reconciliation` on the production host. They
are developer tools.

## 4. Verification queries

```sql
-- Which database and schemas am I connected to?
SELECT current_database(), current_schema();

SELECT table_schema, table_type, count(*)
FROM information_schema.tables
WHERE table_schema NOT IN ('pg_catalog', 'information_schema')
GROUP BY 1, 2
ORDER BY 1, 2;

-- All databases on the server (expect only xopti + postgres + template DBs in prod)
SELECT datname, pg_get_userbyid(datdba) AS owner
FROM pg_database
WHERE datistemplate = false
ORDER BY datname;

-- Schema baseline guard used by readiness
SELECT * FROM platform.schema_baseline;

-- Retirement marker example
SELECT * FROM platform.entity_retirement
WHERE entity_type = 'Country' AND entity_key = 'CA';
```

## 5. Related documents

- [`deployment.md`](deployment.md) — production install and upgrade runbook
- [`recovery.md`](recovery.md) — backups, rollback and snapshot restore
- [`../parity/source.md`](../parity/source.md) — legacy source and mirror conventions
- `tools/legacy-migration/README.md` — MDB staging and comparison workflow
- `src/xOpti.Migrations/README.md` — migration runner stages and cutover gate
