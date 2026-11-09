# Tasks

## 1. Solution and project scaffolding

- [ ] 1.1 Create `xOpti.sln` and `src/xOpti.Migrations` as a .NET 10 console project, and verify `dotnet build` succeeds.
- [ ] 1.2 Add Npgsql and configuration packages to the migration project, and verify package restore succeeds.
- [ ] 1.3 Add command-line entry points for `extract`, `stage`, `transform`, `reconcile`, `sync`, and `cutover`, and verify `--help` lists every command.

## 2. Configuration and source validation

- [ ] 2.1 Load `SYNERGY_MDB`, `DATABASE_URL`, and `XOPTI_DATABASE_URL` from environment variables, and verify missing values fail with a clear error.
- [ ] 2.2 Validate that the legacy MDB exists, is readable by `mdbtools`, and is not modified by the runner, and verify a checksum before and after a dry run.
- [ ] 2.3 Validate target and staging PostgreSQL connections using read-only credentials where available, and verify connection tests pass.

## 3. MDB extraction and staging

- [ ] 3.1 Implement `mdbtools` process invocation with direct pipe streaming (`mdb-export` stdout piped to PostgreSQL `COPY` using Unit Separator `E'\x1f'` and `-0 '\N'`), and verify all 70 source tables stream directly without creating intermediate disk CSV files.
- [ ] 3.2 Stage all source tables into the PostgreSQL `legacy` schema with source-shaped columns, and verify staged row counts match `mdb-export` row counts.
- [ ] 3.3 Normalize known extraction defects: map Access `-1`/`0` booleans, round `REAL` float precision on `rowno`/`linenumber` via `ROUND(val::numeric)::integer`, substitute `1900-01-00` dates to `1899-12-30`, and sanitize non-UTF-8 bytes during stream pipe.

## 4. Transformation to target schema

- [ ] 4.1 Implement idempotent set-based SQL master-data transforms with legacy primary keys preserved, and verify rerunning does not change row counts.
- [ ] 4.2 Implement set-based opening-balance and stock transforms, including lots and cost layers, and verify inventory and lot aggregates reconcile.
- [ ] 4.3 Implement set-based historical transaction transforms for headers, details, payments, sale persons, and order data, and verify transaction totals reconcile.
- [ ] 4.4 Implement anomaly handling for missing `TxHeader` rows and orphaned child rows (including the 478 `TxSalePerson` and 6 `TxDetails` orphans) via `anomaly_quarantine` or flagged synthetic stub headers, and verify anomaly reports include counts and affected identifiers without violating foreign keys.

## 5. Reconciliation and reporting

- [ ] 5.1 Implement row-count reconciliation for every staged and target table, and verify the report lists pass or fail per table.
- [ ] 5.2 Implement aggregate reconciliation for sales, tax, payments, refunds, inventory, AR/AP, sequences, and order status counts, and verify tolerance rules are applied.
- [ ] 5.3 Generate Markdown and CSV reconciliation reports under `tools/legacy-migration/reports`, and verify files are created on every run.

## 6. Sequence and control-number advancement

- [ ] 6.1 Advance PostgreSQL sequences to at least the migrated maximum primary key IDs, and verify `currval`/`last_value` checks pass.
- [ ] 6.2 Advance `Preference` and `TxNextNumber` control numbers for RC, RS, SR, RJ, SJ, and WC by parsing numeric suffixes with regex, and verify no collision with migrated numbers.

## 7. Migration modes and cutover

- [ ] 7.1 Implement dry-run mode with no writes to source or target, and verify no target rows change during a dry run.
- [ ] 7.2 Implement freeze-window sync mode (fast staging reload and set-based upserts to capture in-place legacy edits without date filtering), and verify all historical edits and inventory state update cleanly.
- [ ] 7.3 Implement cutover preparation checks requiring reconciliation pass before completion, and verify cutover fails when any check fails.

## 8. Verification and documentation

- [ ] 8.1 Add unit tests for normalization, idempotency, anomaly detection, and sequence advancement, and verify all tests pass.
- [ ] 8.2 Add integration tests against a PostgreSQL Testcontainers or local comparison database, and verify a full dry run completes.
- [ ] 8.3 Document runner commands, required environment variables, and rollback steps in `tools/legacy-migration/README.md`, and verify documented commands run as written.

## Workflow follow-up

- Archive the change after implementation and review requirements are satisfied.
- Verify the archived result.
