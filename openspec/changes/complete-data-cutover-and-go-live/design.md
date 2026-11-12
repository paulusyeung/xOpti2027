# Design

## Context

See `proposal.md` for motivation. `xOpti.Migrations` already supports extract, stage, transform, reconcile, sync, and cutover. The recorded `reconciliation.md` shows failing control numbers for WR, WC, and SA; the earlier dry run showed summary/current-state row differences, orphan children, target-only rows, and financial/date drift. The comparison report also records snapshot skew, 84 TxHeader and 129 TxDetails monetary edits, one TxPayment edit, 404 date-of-creation diffs, 248 reference/second-date diffs, 478 orphaned TxSalePerson rows, and 6 target-only TxDetails rows. The runtime allocator returns `current + 1` while the transform seeds `max + 1`.

## Goals / Non-Goals

**Goals:**
- Produce a zero-FAIL or signed-exception migration from the final production snapshot.
- Make the freeze window measurable, rehearsed, and reversible.
- Prove post-cutover business totals and critical documents.
- Retire the legacy source safely.

**Non-Goals:**
- Adding new business features or reports during cutover.
- Parallel running both systems for daily operations.
- Preserving obsolete legacy summary tables as operational write targets.
- Changing the signed business rules established by the module changes.

## Decisions

### Decision: Treat the final production MDB as a new migration baseline

Do not incrementally patch prior dry-run databases. Confirm the final source checksum, truncate/reload `legacy`, rerun the full transform, rebuild read models, and reconcile. This eliminates snapshot skew and accidental carry-over of test fixups.

Alternatives considered: patching the existing target from prior dry runs. Rejected because the source snapshot changed and data defects may have shifted.

### Decision: Reconcile control numbers to allocator semantics

Adopt one contract: `tx_next_number` stores the next number to allocate. The transform sets it to `max + 1`; the allocator reads it, uses it, and increments. The allocator must be fixed to return the stored value rather than `current + 1`, or the transform must store `max` - pick one contract and test it across all required families. Update WR/WC/SA and every other required prefix, and fail if a family row is missing.

Alternatives considered: allowing gaps. Rejected because legacy numbering and audit expectations are deterministic.

### Decision: Rebuild summary tables as derived read models

Inventory/category/class/department/supplier/payment summaries are recalculated from posted documents and lots after transform, not trusted from the legacy MDB. The application does not dual-write them. Reconcile the rebuilt values against legacy totals; differences are expected only where the source summary is corrupted or stale, and each difference is dispositioned.

Alternatives considered: copying legacy summary rows. Rejected because the comparison already found target-only and date-corrupted summary rows.

### Decision: Exception workbook is the only allowed reconciliation waiver

Every failing or differing item gets a workbook row with category, source key, expected, actual, cause, disposition, owner, approval, and evidence. The cutover command emits this workbook automatically. A cutover is blocked unless every failure maps to an approved disposition. Quarantined rows and synthetic parents are included, not hidden.

Alternatives considered: accepting a percentage tolerance. Rejected because financial and inventory differences must be individually explained.

### Decision: Full-reload sync inside the freeze window

The final sync truncates staging, streams the complete source, and upserts the target. There is no date-based delta because Access has no reliable change tracking. The measured extract/transform/reconcile duration defines the freeze window; if the window is too long, optimize or negotiate downtime rather than adding unsafe incremental logic.

Alternatives considered: incremental sync. Rejected by the migration notes and known in-place edits.

### Decision: Cutover is a gated command sequence with explicit abort points

Commands run in order: source verify, stage reload, transform, rebuild summaries/read models, reconcile, exception gate, backup, final sync, post-sync reconcile, smoke validation, traffic switch. Each step records timing and evidence and can abort without switching traffic. The API remains read-only or offline during the final window.

Alternatives considered: a single opaque cutover command. Rejected because operators need clear abort points and evidence.

### Decision: Rollback restores a pre-cutover snapshot and configuration

Take a verified database backup and capture container/configuration state before the final sync. Rollback restores the backup, restarts the prior application version/configuration, and records the recovery point and time. The legacy source remains read-only and available for document lookup during the audit period.

Alternatives considered: rolling back by re-running the reverse migration. Rejected because it cannot reliably restore prior configuration or data changed after switch.

## Risks / Trade-offs

- [Freeze window exceeds business tolerance] → Measure in three rehearsals; optimize hot tables/indexes or negotiate a longer window.
- [Final source changes after rehearsal] → Fingerprint and freeze; any change forces a fresh rehearsal.
- [Unexplained financial or inventory difference] → Block cutover; resolve with the exception workbook and customer sign-off.
- [Post-cutover defect requires rollback] → Keep pre-cutover backup, prior images/config, and legacy read-only copy ready through the audit window.
- [PII retention] → Define retention and destruction in the runbook and record execution.
- [Current-state refresh conflicts with test postings] → Run final cutover into a clean target; test-posting databases are never promoted.

## Migration Plan

1. Fix counter semantics and required family coverage; verify with unit and database tests.
2. Add current-state refresh and summary/read-model rebuild; verify against final source totals.
3. Produce the exception workbook and resolve or sign off every item.
4. Run three full rehearsals on production-sized snapshots; record timing, failures, and rollback drills.
5. Freeze legacy writes; verify source fingerprint; run final stage/transform/reconcile.
6. Take pre-cutover backup; run final sync and post-sync checks.
7. Execute post-cutover smoke and business validation; hold go/no-go.
8. Switch traffic, monitor, keep legacy read-only, and schedule retention/destruction.

Rollback: restore the verified pre-cutover database backup, restore prior application images/configuration, confirm health and sign-in, and record the restore point and time.

## Open Questions

- What freeze window is acceptable to the business?
- Who owns go/no-go and exception sign-off?
- What is the legacy read-only retention period and PII destruction policy?
- Which reports and totals are mandatory for post-cutover validation?
