# Design

## Context

See `proposal.md` for motivation. The existing foundation provides Identity, the request pipeline, a Vue shell, and a legacy ETL runner, but `docker/compose.yml` starts an empty database and applies only EF app-owned migrations. `xOpti-schema.sql` is loaded only by test fixtures. `xOpti.Infrastructure.Tests` is present but absent from `xOpti.sln`. There is no CI workflow, root deployment runbook, restore drill, or agreed parity catalogue. The legacy source is 97k LOC across 110 forms, 42 modules, and roughly 80 effective Richmond reports.

## Goals / Non-Goals

**Goals:**
- Make a fresh on-prem installation reproducible and supportable.
- Turn "full parity" and security expectations into signed, versioned baselines.
- Prove deployment, backup, and peripheral paths before module work scales.
- Keep the baseline in the repository so later changes can cite stable identifiers.

**Non-Goals:**
- Implementing business modules, report layouts, or the final data cutover.
- Selecting new business functionality beyond what is needed to operate the platform.
- Migrating production data during this change; only bootstrap and rehearsal plumbing are included.

## Decisions

### Decision: Baseline artifacts live in `docs/parity` with stable IDs

Create `forms.csv`, `use-cases.csv`, `transaction-rules.md`, `permissions.csv`, `reports.csv`, `devices.csv`, and `traceability.csv` under `docs/parity`. Each row gets a stable ID such as `FORM-007`, `RULE-012`, `RPT-021`, and `PERM-004`. OpenSpec changes cite those IDs in tasks and acceptance evidence.

Alternatives considered: keeping the analysis in chat or spreadsheets outside git. Rejected because acceptance, tests, and report sign-off need a reviewable source of truth.

### Decision: Resolve the report baseline by layered precedence, not file count

The catalogue resolves each logical report through `Richmond/HST > Richmond > Rpt ODBC > Rpt DAO > Rpt`. The target is the effective Richmond set (98 file names, roughly 80 distinct logical reports after removing obsolete and duplicate variants). The catalogue records parameters, data dependencies, audience, frequency, criticality, and sign-off status.

Alternatives considered: migrating every `.rpt` file. Rejected because the repository contains superseded connection variants and customer-specific overlays that are not part of the Richmond deployment.

### Decision: Derive security from legacy behavior and explicit approval

Extract permissions from `AppValidation.bas`, `AppUser.bas`, `Security`, `Staff`, and cost-visibility checks, then map them to named permissions. Unmapped legacy levels default to deny. The customer signs the matrix before module authorization tests are written.

Alternatives considered: keeping the current heuristic SecurityLevel thresholds. Rejected because it can expose cost, margin, or PII incorrectly.

### Decision: One idempotent bootstrap job owns schema creation

Add a `bootstrap` mode to the deployment tooling that:
1. verifies the database is empty or already at a known baseline,
2. applies `tools/legacy-migration/schema/xopti-schema.sql` inside a transaction,
3. runs EF app-owned migrations,
4. seeds reference/system data,
5. records a schema baseline version and checksum in platform metadata.

The API never creates schema at startup. A readiness preflight compares the database baseline with the application's required baseline. The ETL transform remains the only writer of migrated business data.

Alternatives considered: relying on `xopti-schema.sql` as a manual operator step. Rejected because the smoke stack and disaster recovery must be reproducible.

### Decision: A single repository CI entry point, callable by any CI vendor

Add `scripts/ci.sh` (plus focused scripts) that restores, builds, runs every test project explicitly, checks the OpenAPI contract, runs web typecheck/tests/build/bundle checks, starts the smoke stack from an empty database, and runs a migration reconciliation fixture. The script is the contract used by the eventual CI provider. Add `xOpti.Infrastructure.Tests` to `xOpti.sln` in the same change.

Alternatives considered: committing directly to a specific CI vendor before the host is chosen. Rejected because the deployment target and source host are not yet confirmed.

### Decision: pgBackRest-style WAL archiving with a documented fallback

Target continuous WAL archiving plus scheduled base backups, and a nightly logical dump fallback. Restore drills run into an isolated environment on a schedule. If the customer cannot provide off-host storage, document the degraded retention and require explicit acceptance.

Alternatives considered: nightly `pg_dump` only. Rejected because a 15-minute RPO is not achievable with daily dumps.

### Decision: TLS at the edge with same-origin SPA and API

Use Caddy or the customer-approved reverse proxy for LAN TLS and HTTP-to-HTTPS redirection. Cookies remain same-origin, Secure, HttpOnly, SameSite=Strict, with CSRF tokens on unsafe methods. Internal CA distribution is documented as an operational task.

Alternatives considered: exposing the API directly on plain HTTP. Rejected for credential and PHI protection.

### Decision: Browser-first POS with a narrow device-agent escape hatch

Prefer network ESC/POS printers, keyboard-wedge scanners, printer-driven cash drawers, and semi-integrated payment terminals. If a required Windows-only device cannot be replaced, define a small local agent exposing a stable localhost interface rather than embedding Windows drivers in the server. The device matrix records interface, driver, and verified status for each item.

Alternatives considered: assuming browser printing is sufficient. Rejected because receipt/label fidelity and cash-drawer kick-out are hard requirements.

## Risks / Trade-offs

- [Production MDB is still unconfirmed] → Make source confirmation the first baseline task and block final cutover planning until the checksum is signed.
- [Customer hardware cannot meet Linux/browser constraints] → Complete the device matrix early; budget a Windows client or local agent before POS work locks in.
- [Report count is larger than the roadmap estimate] → Catalogue and sign off logical reports before building layouts; treat report work as the critical path.
- [Backup storage is unavailable] → Record the degraded RPO/RTO and require written acceptance or provide an appliance-backed target.
- [Schema bootstrap diverges from the ETL schema] → Compare the bootstrapped schema with `xopti-schema.sql` in CI and fail on unexpected drift.
- [Baseline documents become stale] → Add a CI check that every active form/report ID is referenced by a change or explicitly deferred.

## Migration Plan

1. Publish and sign the parity baseline for the confirmed production database and Richmond profile.
2. Add bootstrap, preflight, and smoke-stack provisioning; verify against an empty database.
3. Add all test projects and CI gates; verify a deliberately failing test blocks release.
4. Configure TLS, secrets, backups, and restore drills in a staging environment.
5. Validate the device matrix on the approved POS client and printers.
6. Publish operations runbooks and obtain sign-off for the production host and support model.

Rollback: keep deployment changes additive and feature-flagged; a failed bootstrap leaves the prior database untouched. Restore the pre-change container configuration and database snapshot if production validation fails.

## Open Questions

- Which production `SynergyV.mdb` file and snapshot date are authoritative?
- Which Linux distribution, host architecture, and client OS/browser are approved?
- Which receipt/label printers, scanners, cash drawers, and payment terminals must be supported?
- Is off-host backup storage available, and who owns restore drills?
