# Spec Delta

## Purpose

Defines the reproducible, secure, backed-up and observable on-premises operating envelope for xOpti, including fresh-database bootstrap, deployment preflight, quality gates, supported POS peripherals and recovery evidence.

## ADDED Requirements

### Requirement: Fresh database bootstrap
The deployment SHALL provision a complete xOpti database from an empty PostgreSQL instance without manual SQL steps.

#### Scenario: Empty database is provisioned
- **WHEN** an operator runs the documented bootstrap command against an empty database
- **THEN** the target schema, app-owned migrations, reference seed data, and required extensions are created
- **AND** the command completes idempotently when run a second time

#### Scenario: Bootstrap failure is atomic
- **WHEN** any bootstrap step fails
- **THEN** the deployment reports the failing step and does not report the database as ready
- **AND** rerunning bootstrap after correction succeeds without manual cleanup

### Requirement: Schema readiness preflight
The API SHALL refuse to serve business traffic when the database schema is missing, incompatible, or older than the deployed application version.

#### Scenario: Missing target schema
- **WHEN** the API starts against a database without the target business tables
- **THEN** the readiness health check reports unhealthy with a schema-specific reason
- **AND** business endpoints return a service-unavailable problem response rather than leaking database errors

#### Scenario: Compatible schema
- **WHEN** the target schema version matches the application's required version
- **THEN** readiness reports healthy and business endpoints are served normally

### Requirement: Automated quality gates
Every change SHALL pass the full backend, frontend, contract, deployment-smoke, and migration-reconciliation gates before it can be released.

#### Scenario: Test project is not omitted
- **WHEN** the solution test gate runs
- **THEN** Domain, Application, Infrastructure, API integration, and Migrations tests all execute
- **AND** the run fails if any project is excluded from the solution or produces a failing test

#### Scenario: Frontend and contract regressions
- **WHEN** the web build, typecheck, unit test, bundle budget, or OpenAPI contract check fails
- **THEN** the release gate fails and reports the failing command

#### Scenario: Smoke deployment gate
- **WHEN** the release gate builds and starts the compose stack from an empty database
- **THEN** a smoke sign-in, branch read, and health check succeed against the provisioned stack

### Requirement: Backup and restore evidence
Production SHALL maintain continuous WAL archiving plus scheduled base backups, with a tested restore procedure.

#### Scenario: Point-in-time recovery target
- **WHEN** production is operating normally
- **THEN** recovery point objective is no greater than 15 minutes and recovery time objective is no greater than 4 hours
- **AND** backup success and age are exposed through monitoring

#### Scenario: Restore drill
- **WHEN** the scheduled restore drill runs
- **THEN** a recent backup is restored into an isolated environment and integrity checks pass
- **AND** the drill result, duration, and restore point are recorded

### Requirement: Secure transport and session handling
Production SHALL serve the SPA and API over TLS and SHALL protect session and CSRF cookies.

#### Scenario: Plain HTTP request
- **WHEN** a client reaches the production edge over plain HTTP
- **THEN** the request is redirected to HTTPS
- **AND** authentication cookies are marked Secure, HttpOnly, and SameSite

#### Scenario: Cross-site state change
- **WHEN** a state-changing API request omits a valid CSRF token
- **THEN** the request is rejected without changing data

### Requirement: Secret and configuration hygiene
Production secrets MUST NOT be stored in the repository, container images, client bundles, logs, or support artifacts.

#### Scenario: Configuration inspection
- **WHEN** deployment configuration and images are inspected
- **THEN** database passwords, certificate keys, analytics licence keys, and signing material are supplied only through protected runtime configuration

#### Scenario: Log redaction
- **WHEN** authentication, payment, customer, or prescription failures are logged
- **THEN** logs contain correlation identifiers and error codes but no credentials, card data, or protected health information

### Requirement: Observability and health
The deployment SHALL expose liveness and readiness checks and SHALL produce structured logs correlating API requests, jobs, and database failures.

#### Scenario: Degraded dependency
- **WHEN** PostgreSQL, the file volume, or a required migration is unavailable
- **THEN** the readiness check reports unhealthy and identifies the failed dependency
- **AND** liveness remains healthy so the process is not restarted for a dependency outage

#### Scenario: Support investigation
- **WHEN** an operator investigates a failed request using its correlation identifier
- **THEN** matching API, job, and error log entries are retrievable without exposing PII

### Requirement: Supported POS client and peripherals
The system SHALL support the approved POS client environment and peripheral interfaces recorded in the signed device matrix.

#### Scenario: Receipt and label printing
- **WHEN** an approved receipt or label is printed from a supported POS client
- **THEN** the output uses the approved printer path, paper size, fonts, and barcode encoding
- **AND** the path works without a Windows-only runtime

#### Scenario: Unsupported device is detected
- **WHEN** an operator connects a device not approved in the matrix
- **THEN** the deployment documentation identifies it as unsupported and recommends the nearest approved alternative

### Requirement: Release traceability baseline
A release SHALL be traceable to an approved parity baseline covering legacy forms, reports, rules, permissions, and devices.

#### Scenario: Scope sign-off
- **WHEN** a module or report is proposed for release
- **THEN** its legacy source and acceptance evidence are recorded in the parity catalogue
- **AND** unlisted legacy behavior is either deferred with customer approval or blocked from release
