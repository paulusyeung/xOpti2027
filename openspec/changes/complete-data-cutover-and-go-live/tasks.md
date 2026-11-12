# Tasks

## 1. Final-source baseline

- [ ] 1.1 Confirm and fingerprint the final production `SynergyV.mdb` and record snapshot time, SHA-256, table inventory, and approval; verify the cutover command aborts on any mismatch.
- [ ] 1.2 Re-run schema comparison against the final source and confirm only documented typo/type/nullability differences remain; verify unexpected differences fail the gate.
- [ ] 1.3 Re-run the full extract/stage/transform against the final source into a clean target; verify no test-posting data or prior dry-run fixups are present.

## 2. Control-number correctness

- [ ] 2.1 Choose and document the counter contract (`tx_next_number` means next or high-water) and make transform and allocator agree; verify the first allocation after migration equals the expected next number.
- [ ] 2.2 Add and verify counters for every required family, including WR and SA; verify a missing family blocks cutover instead of falling back.
- [ ] 2.3 Add reconciliation tests for duplicates, gaps, and counter-ahead/behind conditions; verify zero failures on the final snapshot.

## 3. Current-state and summary rebuild

- [ ] 3.1 Refresh inventory, lot, customer-account, and retail-price current state from the final source; verify row counts and values match the source within tolerance.
- [ ] 3.2 Rebuild inventory/category/class/department/supplier/payment summaries from posted documents and lots; verify rebuilt totals against legacy totals.
- [ ] 3.3 Remove summary tables from the application write path and expose them only as read models; verify posting does not dual-write.
- [ ] 3.4 Reconcile current-state and summary rebuilds against the final source; verify every difference is explained or signed off.

## 4. Known exception disposition

- [ ] 4.1 Reconcile the 84 TxHeader, 129 TxDetails, and 1 TxPayment historical monetary differences; verify each uses the approved source value or has signed evidence.
- [ ] 4.2 Reconcile the 404 date-of-creation and 248 reference/second-date drifts; verify date-only or time-zone rules are documented and applied consistently.
- [ ] 4.3 Resolve the 478 orphaned TxSalePerson rows and 6 target-only TxDetails rows; verify quarantine or synthetic-parent dispositions are recorded.
- [ ] 4.4 Reconcile target-only summary rows and corrupted summary dates; verify they are rebuilt, removed, or signed off.
- [ ] 4.5 Generate the exception workbook with category, source key, expected, actual, cause, disposition, owner, approval, and evidence; verify every FAIL maps to an approved row.

## 5. Cutover command hardening

- [ ] 5.1 Implement source-verify, stage-reload, transform, rebuild, reconcile, and exception-gate commands with timing and evidence output; verify each can abort without switching traffic.
- [ ] 5.2 Implement final-sync and post-sync reconciliation commands; verify a missing or short table aborts and preserves the prior target.
- [ ] 5.3 Implement pre-cutover backup, configuration capture, and rollback command; verify a rollback drill restores the prior database and application state.
- [ ] 5.4 Make reconciliation emit a machine-readable release gate result; verify any unsigned failure exits non-zero and blocks go-live.
- [ ] 5.5 Add cutover logging with no PII and retained evidence per run; verify logs and reports can be attached to the go/no-go record.

## 6. Rehearsals

- [ ] 6.1 Run rehearsal 1 on a production-sized snapshot and record extract/transform/reconcile/validation timings and failures; verify the run produces complete evidence.
- [ ] 6.2 Run rehearsal 2 after corrective actions and record the measured freeze window; verify previously failing checks now pass or are signed off.
- [ ] 6.3 Run rehearsal 3 including a rollback drill and post-cutover validation; verify the rollback meets the approved recovery time.
- [ ] 6.4 Re-run the full cutover after any procedure change; verify the last rehearsal matches the production runbook exactly.

## 7. Post-cutover validation and go-live

- [ ] 7.1 Validate sign-in, permissions, master data, POS, inventory, payments, cash, claims, and reports using the signed acceptance set; verify critical totals against the legacy reference.
- [ ] 7.2 Validate inventory quantities/valuation, AR/AP, tax, tender, control numbers, and report totals after final sync; verify differences are explained.
- [ ] 7.3 Execute the go/no-go checklist with named owners and record the decision; verify no critical failure remains unsigned.
- [ ] 7.4 Execute the traffic switch and monitor health, errors, and critical transactions; verify the system remains live or rollback is invoked within the approved window.
- [ ] 7.5 Set the legacy database read-only and verify historical lookups remain available during the audit period.

## 8. Retention and closure

- [ ] 8.1 Document the legacy retention period, access procedure, PII destruction policy, and owner; verify the signed policy is committed.
- [ ] 8.2 Execute and record retention/destruction at the agreed time; verify destruction evidence is retained without retaining the data.
- [ ] 8.3 Hold a cutover retrospective and record corrective actions; verify open actions have owners and dates.

## Workflow follow-up

- Archive this change only after go-live, rollback readiness, and retention obligations are signed off.
- Keep the final reconciliation, exception workbook, rehearsal timings, and go/no-go evidence with the archived change.
