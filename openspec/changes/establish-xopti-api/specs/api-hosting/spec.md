# Spec Delta

## Purpose

Defines the xOpti HTTP surface contract shared by every module endpoint: versioned routing under `/api/v1`, a uniform problem-details error vocabulary, idempotency and pagination conventions, health reporting, and a machine-readable OpenAPI description used to generate the web client.

## ADDED Requirements

### Requirement: Endpoints are versioned under a stable prefix
All API endpoints SHALL live under `/api/v1` (version segment in the path), and adding a new API version SHALL NOT break existing v1 clients.

#### Scenario: Unknown route
- **WHEN** a client calls a path outside any registered version
- **THEN** the response is a 404 problem document, never a fallback page

### Requirement: Errors use a uniform problem document
Validation failures, authorization denials, concurrency conflicts, and unexpected errors SHALL each return `application/problem+json` with a stable `type` discriminator, and SHALL NOT include stack traces, SQL, or PII.

#### Scenario: Validation failure shape
- **WHEN** a POST body fails request validation
- **THEN** the response is 400 with a problem document listing per-field errors

#### Scenario: Concurrency conflict shape
- **WHEN** a command loses an update race
- **THEN** the response is 409 with the conflict problem type

#### Scenario: Server fault hides details
- **WHEN** an unhandled exception occurs
- **THEN** the response is 500 with a correlation identifier and no internal details

### Requirement: Financial endpoints require an idempotency key
Sale, invoice, and payment POST endpoints SHALL reject requests without an idempotency-key header, and replays of the same key SHALL return the original result instead of posting twice.

#### Scenario: Missing key
- **WHEN** a payment POST arrives without the idempotency header
- **THEN** the request is rejected with 400 before any posting work

#### Scenario: Replay
- **WHEN** the identical sale POST with the same key is sent again
- **THEN** the response equals the first response and no second transaction exists

### Requirement: Lists expose keyset pagination parameters
Collection GETs SHALL accept a cursor and page-size query parameters and return items plus a next cursor, matching the application-layer contract.

#### Scenario: Page traversal
- **WHEN** a client walks pages until the next cursor is absent
- **THEN** every row appears exactly once

### Requirement: OpenAPI description and generated client are authoritative
The service SHALL publish an OpenAPI document for v1, and a generated TypeScript client SHALL be produced from it in a form CI can contract-check.

#### Scenario: Contract drift
- **WHEN** the OpenAPI document changes incompatibly and the contract check runs
- **THEN** CI fails with the breaking-change report

### Requirement: Health checks cover critical dependencies
The service SHALL expose liveness and readiness endpoints reporting database connectivity and file-volume writability.

#### Scenario: Database down
- **WHEN** the database is unreachable
- **THEN** readiness reports unhealthy while liveness still reports alive
