# Spec Delta

## Purpose

Establishes the application-layer behavior contract all xOpti modules share: command/query dispatch with validation-before-handler execution, single-transaction command semantics, idempotent replays for financial writes, keyset-paged reads, and the ports infrastructure must satisfy.

## ADDED Requirements

### Requirement: Requests dispatch through a validation-first pipeline
Every command or query SHALL dispatch to exactly one handler, and validation SHALL run before the handler; a request that fails validation SHALL produce structured field errors and SHALL NOT execute handler logic or open a transaction.

#### Scenario: Invalid command rejected before handler
- **WHEN** a command with an invalid field is dispatched
- **THEN** the result contains the validation field errors and the handler's effects (writes, control-number allocation) did not occur

#### Scenario: Unknown request type
- **WHEN** a request with no registered handler is dispatched
- **THEN** dispatch fails with a distinct unsupported-request error

### Requirement: Commands execute inside one explicit transaction
Write operations SHALL execute within a single explicit transaction committed on success and rolled back on any handler failure, so no partial posting is ever visible.

#### Scenario: Handler failure rolls back
- **WHEN** a command handler throws after earlier writes in the same command
- **THEN** no data from that command is persisted and the failure surfaces as an error result

### Requirement: Financial writes are replay-safe via idempotency keys
Commands for sales, invoices, and payments SHALL require an idempotency key; a repeated submission with the same key SHALL return the original outcome without re-executing the posting, and concurrent submissions with the same key SHALL be guarded by an atomic reservation to prevent duplicate posting.

#### Scenario: Duplicate submission
- **WHEN** the same sale command is submitted twice with the same idempotency key
- **THEN** only one transaction is posted and the second call returns the first result

#### Scenario: Concurrent submission with same key
- **WHEN** two identical sale commands with the same key arrive simultaneously
- **THEN** only one command executes the transaction and the second receives a conflict or awaits the first outcome without double-posting

#### Scenario: Missing key
- **WHEN** a sale command is submitted without an idempotency key
- **THEN** the request is rejected before execution

### Requirement: Collection queries use keyset pagination
List queries SHALL return a page of items plus an opaque next cursor, SHALL order by a stable key, and SHALL NOT rely on offset paging.

#### Scenario: Cursor continues after concurrent insert
- **GIVEN** a first page was returned for a list query
- **WHEN** new rows are inserted and the next-cursor page is requested
- **THEN** previously returned rows are not repeated and the new rows appear on the appropriate page

### Requirement: Application layer depends on ports, not infrastructure
The application layer SHALL obtain persistence, unit of work, control-number allocation, clock, audit recording, idempotency storage, and document rendering exclusively through interfaces it defines; it SHALL NOT depend on any concrete hosting or storage technology.

#### Scenario: Reference slice runs against fakes
- **WHEN** the branch-listing query executes in tests with in-memory port implementations
- **THEN** it returns a correct keyset-paged result with no database present
