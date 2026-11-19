# Final data cutover and go-live

This runbook is the operator contract for the final Access-to-PostgreSQL cutover.
It is provisional until the final production `SynergyV.mdb`, approver, freeze
window, go/no-go owner, printer evidence, and report sign-offs are recorded.

## Derived summaries

Legacy inventory/category/class/department/supplier/payment summary tables are
not application write targets. Posting writes transaction, payment, lot, and
inventory rows; supplier activity reads the legacy summary table read-only and
reporting uses the `reporting` views/materialized views. Rebuilding the legacy
summary tables remains an explicit cutover step; no operational code dual-writes
them.

## Source baseline

The final source must be approved and fingerprinted before any target write.

- `MIGRATION_EXPECTED_SHA256` — approved SHA-256 of the final MDB
- `MIGRATION_EXPECTED_TABLES` — approved table count
- `MIGRATION_SNAPSHOT_TIME` — approved snapshot timestamp
- `MIGRATION_APPROVED_BY` — approver recorded with the run

`source-verify` writes `tools/legacy-migration/reports/source-verification.json`.
`cutover` and final `sync` abort before staging when the hash or table count does
not match. Dry runs may proceed without a baseline, but never switch traffic.

Tests: `CutoverGateTests.SourceBaseline_*`, `CutoverGateTests.CommandLine_RecognisesCutoverCommands`.

## Counter contract

`pref_tx_number.tx_next_number` stores **the next number to allocate**. The
transform sets it to `max + 1` when the migrated maximum is at or above the
current value. The runtime allocator reads the stored value, returns it, and
increments the row. The first post-cutover allocation therefore equals the
stored counter, not `counter + 1`.

Required families are `RC`, `RS`, `SR`, `RJ`, `SJ`, `WC`, `WR`, and `SA`.
A missing family fails reconciliation; allocation never falls back to another
prefix. Duplicate transaction numbers fail the gate. Historical numbering gaps
are reported as INFO because legacy documents were deleted, never reused.

Tests: `ControlNumberContractTests.Allocator_ReturnsStoredNextNumber_ThenAdvances`,
`ReconciliationFixtureTests.RequiredControlFamilies_CoverEveryPostingPrefix`.

## Reconciliation gate and exceptions

`reconcile` and `gate` write:

- `reconciliation.md`
- `reconciliation-workbook.csv`
- `reconciliation-gate.json`
- `exception-workbook.csv`

The gate is PASS only when every check is PASS or INFO. Every FAIL is an OPEN
exception row with source key, expected, actual, cause, disposition, owner,
approval, and evidence. A cutover with any unsigned FAIL exits non-zero and
does not switch traffic. The exception workbook is the only permitted waiver.

Tests: `ReconciliationFixtureTests.Writer_RoundTripsTheFixture_WithQuotedDetail`,
`CutoverGateTests`.

## Command sequence

Run in order; each step can abort without switching traffic:

1. `source-verify` — fingerprint and approve the final MDB.
2. `stage-reload` — drop and reload the complete staging schema (no date delta).
3. `transform` — set-based upsert into the target.
4. `reconcile` or `gate` — row counts, totals, inventory, AR/AP, sequences,
   control numbers, duplicates, gaps, and anomalies.
5. `backup` — pre-cutover PostgreSQL backup and configuration capture.
6. `final-sync` — full staging reload + transform inside the freeze window.
7. `post-sync` — reconcile again after the final sync.
8. Post-cutover validation and go/no-go.
9. Traffic switch; legacy becomes read-only.

The legacy source is opened read-only and verified unchanged at the end of each
run. The staging schema is dropped and rebuilt by `stage-reload`; prior dry-run
fixups and test postings are never promoted.

## Rehearsals

At least three full production-sized rehearsals are required before go-live.
Record:

- source fingerprint and table count
- extract, transform, reconcile, and validation durations
- measured freeze window
- failures and corrective actions
- rollback drill duration and restore point
- the last rehearsal must match the production runbook exactly

Rehearsal evidence belongs with the archived change. A procedure change after
the last rehearsal forces another full rehearsal.

## Rollback

Before final sync:

- take a verified `pg_dump` backup
- capture image tags, environment, and runtime configuration
- record the recovery point and operator

Rollback restores the pre-cutover backup, restarts the prior images/config, and
records the restore time. Go-live is blocked if the backup is missing, corrupt,
or older than the approved recovery point. The legacy read-only database stays
available for document lookup.

## Post-cutover validation

Validate authentication, permissions, master data, POS, inventory, payments,
cash, claims, reports, control numbers, tax, tender, AR/AP, inventory valuation,
and critical totals against the signed acceptance set. A critical failure goes
to the go/no-go owner, who either invokes rollback or records an approved
remediation.

## Retention and destruction

Define the legacy read-only retention period, access procedure, PII destruction
policy, and owner. At expiry, destroy the data under the signed policy and retain
only destruction evidence. The legacy copy must not be retained beyond the
approved period.

## Evidence and PII

`migration.run_log` records command, mode, source path, SHA-256, timestamps,
outcome, and structured details. Reports and logs must not contain customer PII,
payment credentials, or database passwords. Attach the gate JSON, exception
workbook, timings, and go/no-go decision to the cutover record.

Runbook check: `CutoverRunbookTests.RunbookCoversTheCutoverGate`.
