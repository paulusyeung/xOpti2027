# Proposal

## Why

The current repository has a sound platform foundation, but it cannot yet be deployed or used as the system of record for the legacy business. "Full parity" is still undefined, the production Access database and POS hardware are unconfirmed, the deployment stack does not provision the legacy target schema, and no CI or restore drill protects the hard cutover. This change establishes the authoritative parity baseline and the production operating envelope that every later module and the final cutover depend on.

## What Changes

- Establish Phase 0 parity baselines as versioned, sign-off-ready artifacts:
  - Confirm the production `SynergyV.mdb` source, snapshot date, checksum, data profile, and freeze policy.
  - Build a report catalogue for the selected Richmond profile from the layered `.rpt` sets, resolving precedence and identifying roughly 80 logical reports.
  - Derive the permission matrix from `AppValidation.bas`, `AppUser.bas`, `Security`, and `Staff`, replacing the heuristic SecurityLevel mapping.
  - Document transaction-flow, posting, tax, discount, costing, numbering, and audit rules from `AppOLTP.bas` and the main POS/inventory/wholesale forms.
  - Produce a POS device and peripheral matrix for receipt/label printers, scanners, cash drawers, customer displays, payment terminals, and signature capture.
  - Define non-functional targets, acceptance criteria, licensing obligations, and a traceability matrix linking legacy forms, reports, and rules to the new OpenSpec changes.
- Harden the platform for on-prem production:
  - Add an idempotent bootstrap job that creates the legacy target schema, applies app-owned EF migrations, and seeds reference data on a fresh PostgreSQL database.
  - Add CI gates covering every test project (including the currently omitted `xOpti.Infrastructure.Tests`), contract checks, frontend typecheck/tests/build/bundle, compose smoke, and migration reconciliation.
  - Add TLS/reverse-proxy configuration, secret handling, backup/WAL archiving, restore drills, structured logging, health checks, and operational runbooks.
  - Validate the supported client OS/browser and peripheral paths, including a local print/device agent if browser APIs cannot meet receipt/label requirements.
- Out of scope: business-module implementation, report layouts, and the final data cutover. Those are delivered by the dependent changes.

## Capabilities

### New Capabilities

- `production-operations`: a reproducible, secure, backed-up, observable on-prem deployment of xOpti, including fresh-database bootstrap, schema/version preflight, quality gates, supported POS client/peripheral behavior, and documented recovery.

### Modified Capabilities

None.

## Impact

- Affected code: `docker/`, `scripts/`, solution/test configuration, API startup/health checks, and new deployment/bootstrap jobs. No business-module behavior is added.
- Affected systems: PostgreSQL 17, Docker Compose, TLS reverse proxy, file volume, backup storage, and the Windows reference VM used for Crystal Reports and Access fallback.
- New documentation: `docs/parity/`, `docs/adr/`, `docs/operations/`, and signed-off catalogue/matrix exports.
- Dependencies: existing `.NET 10`, Vue 3, PostgreSQL, and Testcontainers stack; no new runtime business dependency.
