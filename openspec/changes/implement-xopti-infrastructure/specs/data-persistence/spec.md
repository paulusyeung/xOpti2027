# Spec Delta

## Purpose

Persists xOpti domain aggregates onto the already-migrated PostgreSQL schema with exact money/time fidelity, optimistic concurrency, and additive-only schema evolution, so application-layer transactions behave identically against the real database as against fakes.

## ADDED Requirements

### Requirement: Money and time round-trip exactly
Persistence SHALL store and reload monetary values at four-decimal precision and timestamps with time-zone correctness, with no floating-point or local-time loss anywhere in the round trip.

#### Scenario: Money fidelity
- **WHEN** an aggregate containing a `Money` value of `1234.5678` is saved and reloaded
- **THEN** the reloaded value equals the original

#### Scenario: DST boundary timestamp
- **WHEN** a timestamped record near a daylight-saving boundary is saved and reloaded
- **THEN** the absolute instant is unchanged

### Requirement: Existing migrated schema is respected and evolved additively
Persistence SHALL map onto the migrated `public` schema using its existing table, column, and key names, legacy tables SHALL be excluded from EF migration scaffolding, and any structural change SHALL be delivered as an additive, versioned migration applied only by the dedicated migration job.

#### Scenario: Legacy key preserved
- **WHEN** a migrated transaction row is loaded through the persistence layer
- **THEN** its legacy control number remains the identifying key and is unchanged on write

#### Scenario: Existing tables excluded from migration scripts
- **WHEN** EF Core migrations are scaffolded or scripted
- **THEN** no DDL statements are generated for legacy migrated tables

#### Scenario: New columns arrive as migrations
- **WHEN** the persistence layer needs a column that does not exist
- **THEN** the change ships as a versioned migration and no code path alters schema at application startup

### Requirement: Concurrent updates are detected
Two writers editing the same record SHALL NOT silently overwrite each other; the loser of the race SHALL receive a concurrency failure mapped from the database concurrency token.

#### Scenario: Lost update prevented
- **GIVEN** two sessions loaded the same inventory record
- **WHEN** both save modifications
- **THEN** the second save fails with a concurrency conflict and the first save's data is intact

### Requirement: Unit of work matches caller scope
The persistence unit of work SHALL commit only what the calling command wrote inside its scope, honoring the application-layer rule of one explicit transaction per posting.

#### Scenario: Nested failure
- **WHEN** a command writes two aggregates and the second fails validation in the database
- **THEN** neither aggregate row is committed
