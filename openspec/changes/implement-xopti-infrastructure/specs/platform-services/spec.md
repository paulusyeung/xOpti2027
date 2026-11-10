# Spec Delta

## Purpose

Provides the shared backend services the application ports demand: race-safe control-number allocation, append-only audit recording, idempotency storage, document rendering with deterministic fonts, and file storage on the deployment volume.

## ADDED Requirements

### Requirement: Control-number allocation is atomic under concurrency
Concurrent requests for the next control number within a family SHALL never receive the same number, and allocated numbers SHALL be consistent with both database sequences and the `Preference`/`TxNextNumber` counters.

#### Scenario: Parallel allocation
- **WHEN** fifty concurrent allocations are requested for family `RC`
- **THEN** fifty distinct, increasing numbers are returned with no duplicates or gaps caused by lost updates

#### Scenario: Counters stay synchronized
- **WHEN** an allocation for family `WC` succeeds
- **THEN** the stored next-number row reflects the new high-water value

### Requirement: Financial and inventory changes are audited
Every committed posting or inventory mutation SHALL produce an append-only audit entry naming the actor, branch, affected records, and change content; audit entries SHALL NOT be updatable or deletable through the application.

#### Scenario: Adjustment audit
- **WHEN** a stock adjustment command commits
- **THEN** one audit entry exists with actor, branch, timestamp, and the before/after quantities

### Requirement: Idempotency records outlive replays but are retained boundedly
The idempotency store SHALL acquire atomic reservation leases before command execution to prevent race conditions, SHALL return the recorded first result for a replayed key, and SHALL expire records after a configurable retention period.

#### Scenario: Replay within window
- **WHEN** a recorded key is replayed inside the retention period
- **THEN** the stored result is returned and no new execution occurs

#### Scenario: Concurrent in-flight key collision
- **WHEN** a concurrent lease request arrives for a key currently being processed
- **THEN** the lease acquisition fails and the second execution is rejected

### Requirement: Rendered documents use controlled fonts and storage
Document rendering SHALL use bundled, deterministic fonts on Linux and store generated files under the configured file volume path, never in ephemeral container-local directories only.

#### Scenario: Barcode font available
- **WHEN** a document requiring the barcode font renders
- **THEN** rendering succeeds on the Linux runtime with the bundled font and the file lands in the configured storage path
