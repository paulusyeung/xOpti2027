# Proposal

## Why

The migration runner is substantial, but the recorded dry run still fails reconciliation and the migrated dataset is not cutover-ready. Control-number counters are inconsistent (WR/WC/SA), current-state tables can be stale, historical edits and date drift remain unresolved, and there is no rehearsed freeze/sync/rollback runbook. A hard cutover with full history requires a zero-FAIL, signed, repeatable cutover rather than a best-effort transform.

## What Changes

- Harden the migration dataset and transform:
  - Fix control-number semantics, all family coverage, and the off-by-one between migrated counters and runtime allocation.
  - Refresh current-state inventory, lot, customer-account, and retail-price data from the final production snapshot.
  - Resolve or formally quarantine the known TxHeader/TxDetails/TxPayment edits, date drift, target-only rows, orphaned sale-person rows, and extra detail rows.
  - Rebuild legacy summary tables as read models or remove them from the operational path; verify derived totals.
  - Re-run schema comparison and reconciliation against the final production MDB with zero unexpected differences.
- Harden cutover operations:
  - Produce a signed exception workbook with owner, disposition, and evidence for every remaining difference.
  - Rehearse at least three full freeze/sync/cutover cycles using production-sized snapshots and measure the freeze window.
  - Add final-cutover commands for source fingerprint verification, full staging reload, set-based upsert, reconciliation gate, post-cutover validation, and rollback.
  - Validate inventory, AR/AP, tax, tender, control-number, and report totals after cutover.
  - Keep the legacy database read-only for the agreed audit period and define deletion/retention rules for PII.
- Produce the cutover runbook, communications plan, rollback criteria, and go/no-go checklist.
- Out of scope: building business features or report layouts; this change assumes they are delivered and signed.

## Capabilities

### New Capabilities

- `data-cutover`: final-source verification, reconciliation gates, exception disposition, rehearseable freeze/sync/cutover, post-cutover validation, rollback, and legacy retirement.

### Modified Capabilities

None.

## Impact

- Affected code: `src/xOpti.Migrations` transform/reconcile/cutover commands, control-number advancement, current-state refresh, summary/read-model rebuild, report generation, and cutover scripts.
- Affected data: PostgreSQL production database, final `SynergyV.mdb` snapshot, migration staging schema, exception/quarantine tables, and retained backups.
- Affected operations: write freeze, final sync, go/no-go, traffic switch, rollback, and legacy read-only retention.
- Dependencies: `establish-production-baseline` and all operational/reporting changes; the production MDB and host must be confirmed.
- Go-live risk: high. The change cannot be accepted while any reconciliation check fails without a signed exception.
