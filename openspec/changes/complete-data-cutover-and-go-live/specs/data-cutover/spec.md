# Spec Delta

## Purpose

Defines the repeatable, evidence-backed cutover from the legacy Access database to xOpti, including source verification, reconciliation gates, exceptions, rehearsals, rollback, and legacy retirement.

## ADDED Requirements

### Requirement: Authoritative source verification
Every cutover run MUST verify the production source file, snapshot time, SHA-256, schema, and table inventory before writing target data.

#### Scenario: Correct source
- **WHEN** a cutover run starts with the approved source file and checksum
- **THEN** the run records the fingerprint, snapshot time, and row counts
- **AND** the run may proceed

#### Scenario: Wrong source
- **WHEN** the source checksum or table inventory differs from the approved baseline
- **THEN** the run aborts before staging
- **AND** no target data is changed

### Requirement: Full freeze-window synchronization
The final synchronization SHALL reload the complete source into staging and apply a set-based upsert that captures historical in-place edits, not only rows newer than a date.

#### Scenario: Historical edit captured
- **WHEN** a legacy row outside the latest date range was edited in place before the freeze
- **THEN** the final synchronization updates the target row

#### Scenario: Incomplete sync
- **WHEN** any source table is missing, truncated, or fails to load
- **THEN** the cutover aborts
- **AND** the previous target state remains recoverable

### Requirement: Reconciliation release gate
Cutover SHALL require zero failing reconciliation checks or a written, signed exception for every difference.

#### Scenario: All checks pass
- **WHEN** row counts, financial totals, inventory quantities and costs, AR/AP, control numbers, sequences, and orphan checks pass within tolerance
- **THEN** the run is marked eligible for go/no-go

#### Scenario: Unexpected failure
- **WHEN** a check fails without a signed exception
- **THEN** cutover is blocked
- **AND** the failure is reported with the affected scope and evidence

### Requirement: Control-number correctness
Migrated counters and runtime allocation MUST agree on the next number for every required family, with no duplicates or unexplained gaps.

#### Scenario: First post-cutover number
- **WHEN** the first SR, RJ, SJ, RC, RS, WC, WR, or SA document is posted after cutover
- **THEN** its number is the approved next value for that family
- **AND** it is not already present in history

#### Scenario: Counter mismatch
- **WHEN** a counter is behind the migrated maximum or a required family row is missing
- **THEN** cutover is blocked until corrected

### Requirement: Exception disposition
Every known data defect MUST be resolved, quarantined, or represented by a flagged synthetic parent with a recorded owner and disposition.

#### Scenario: Orphan child
- **WHEN** a child transaction has no resolvable parent
- **THEN** it is quarantined or attached to a synthetic parent flagged as synthetic
- **AND** the disposition is recorded in the exception workbook

#### Scenario: Financial edit
- **WHEN** a historical monetary value differs from the expected source value
- **THEN** the approved source value is migrated or the difference is signed off with evidence

### Requirement: Current-state refresh
Current-state tables MUST reflect the final production snapshot at cutover, not an earlier dry-run snapshot.

#### Scenario: Inventory refresh
- **WHEN** final synchronization completes
- **THEN** inventory quantity, lot, cost, customer-account, and retail-price state match the final source within tolerance

#### Scenario: Stale current state
- **WHEN** a current-state table is older than the final source
- **THEN** cutover is blocked

### Requirement: Cutover rehearsal
The team SHALL complete at least three full dry runs on production-sized snapshots and record timing, failures, and corrective actions.

#### Scenario: Rehearsal evidence
- **WHEN** a rehearsal completes
- **THEN** the freeze window, extract/transform/reconcile durations, and failures are recorded

#### Scenario: Unrehearsed change
- **WHEN** the cutover procedure changes after the last rehearsal
- **THEN** another full rehearsal is required before production

### Requirement: Post-cutover validation
Immediately after cutover, the team SHALL validate authentication, master data, POS, inventory, payments, cash, claims, reports, and critical totals against the signed acceptance set.

#### Scenario: Validation passes
- **WHEN** all post-cutover checks pass
- **THEN** the system is declared live and the legacy source becomes read-only

#### Scenario: Validation fails
- **WHEN** a critical post-cutover check fails
- **THEN** the go/no-go owner invokes rollback or an approved remediation plan
- **AND** the failure and decision are recorded

### Requirement: Rollback
A tested rollback SHALL restore the pre-cutover database and configuration within the approved window.

#### Scenario: Rollback invoked
- **WHEN** the go/no-go owner invokes rollback
- **THEN** the database is restored from the pre-cutover backup
- **AND** the application is returned to the prior operable state
- **AND** the restore time is recorded

#### Scenario: Rollback not possible
- **WHEN** the rollback target is missing, corrupt, or older than the approved recovery point
- **THEN** go-live is blocked

### Requirement: Legacy retirement and retention
After cutover, the legacy database SHALL be read-only for the agreed audit period and SHALL be retained and destroyed under the approved PII policy.

#### Scenario: Audit access
- **WHEN** an auditor requests a historical document during the retention period
- **THEN** the legacy read-only copy or new-system evidence is available

#### Scenario: Retention expiry
- **WHEN** the retention period ends
- **THEN** legacy data is destroyed according to the signed policy
- **AND** the destruction is recorded
