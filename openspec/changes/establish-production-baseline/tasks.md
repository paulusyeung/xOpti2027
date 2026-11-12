# Tasks

## 1. Parity source confirmation

- [ ] 1.1 Confirm and document the authoritative production `SynergyV.mdb`, snapshot date, SHA-256, store/branch count, and write-freeze owner in `docs/parity/source.md`; verify the checksum matches the file used for dry runs.
- [x] 1.2 Profile all 70 legacy tables for row counts, nullability, orphan keys, invalid dates, and PII-bearing columns; verify the profile is reproducible from the documented command.
- [x] 1.3 Inventory all 110 `.frm`, 42 `.bas`, and 8 `.cls` files into `docs/parity/forms.csv` with stable IDs, purpose, entry points, and target module; verify every form is mapped or explicitly deferred with a reason.

## 2. Transaction, costing, tax and numbering baseline

- [x] 2.1 Document the posting flow from `AppOLTP.bas` for SR, RJ, SJ, RC, RS, WC, WR, and SA, including header/detail/payment/sale-person/summary effects; verify each step names the source procedure and target table.
- [x] 2.2 Document FIFO/LIFO/average costing, deficit handling, lot reconciliation, and category cost-method rules with worked examples from legacy sample data; verify examples against the current characterization tests.
- [ ] 2.3 Document tax methods `N/B/G/P/g/p`, discount rules, rounding, refunds, and inclusive/exclusive calculations with source form references; verify each rule has at least one test vector from legacy data.
- [x] 2.4 Document control-number families, per-prefix counters, sale-order conversion, and reprint numbering; verify the baseline covers all 13 `PrefTxNumber` rows and the `RC/RS/SR/RJ/SJ/WC/WR/SA` taxonomy.

## 3. Permissions and report catalogue

- [x] 3.1 Extract the legacy security matrix from `AppValidation.bas`, `AppUser.bas`, `Security`, and `Staff` into `docs/parity/permissions.csv`; verify every legacy level and cost-visibility check maps to a named permission or explicit denial.
- [ ] 3.2 Obtain written customer approval of the permission matrix; verify the signed version is committed with a date and approver role.
- [x] 3.3 Build the Richmond report catalogue in `docs/parity/reports.csv` using precedence `Richmond/HST > Richmond > Rpt ODBC > Rpt DAO > Rpt`; verify every effective logical report has parameters, data dependencies, criticality, and sign-off status.
- [ ] 3.4 Review the catalogue with the customer and record roughly 80 logical reports as in-scope or explicitly deferred; verify no report file in the effective Richmond set is unclassified.

## 4. Device and client matrix

- [x] 4.1 Inventory every POS peripheral and client OS/browser requirement in `docs/parity/devices.csv`; verify each device records interface, driver/protocol, current Windows dependency, and proposed xOpti path.
- [ ] 4.2 Validate network ESC/POS receipt and label printing, barcode encoding, paper sizes, and cash-drawer kick-out on the approved printer path; verify a printed sample matches the legacy layout dimensions.
- [ ] 4.3 Validate scanner input, customer display, payment terminal, and signature capture paths; verify any unsupported device has an approved local-agent or replacement decision.

## 5. Fresh-database bootstrap

- [x] 5.1 Add a `bootstrap` deployment mode that applies `tools/legacy-migration/schema/xopti-schema.sql`, app-owned migrations, and reference seed data in one idempotent operation; verify it succeeds twice against an empty PostgreSQL 17 database.
- [x] 5.2 Record schema baseline version and checksum in platform metadata; verify a rerun with an incompatible baseline fails with a clear message and changes nothing.
- [x] 5.3 Add API readiness preflight for missing or outdated schema; verify the API reports unhealthy and business endpoints return a service-unavailable problem response against an empty database.
- [x] 5.4 Add a CI schema-drift check comparing the bootstrapped schema with `xopti-schema.sql`; verify an injected unexpected column fails the check.

## 6. Quality gates and solution hygiene

- [x] 6.1 Add `tests/xOpti.Infrastructure.Tests` to `xOpti.sln`; verify `dotnet test xOpti.sln` reports its 40 tests alongside the other projects.
- [x] 6.2 Add `scripts/ci.sh` running restore, build, all test projects, contract check, web typecheck/tests/build/bundle checks, and the migration reconciliation fixture; verify the script exits non-zero on an injected failure.
- [x] 6.3 Add compose smoke provisioning from an empty database and a smoke sign-in/branch/health check; verify the smoke stack reaches healthy and the checks pass in CI.
- [x] 6.4 Add a CI check that every `FORM-*`, `RULE-*`, `PERM-*`, and `RPT-*` baseline ID is referenced by a change or marked deferred; verify an unreferenced active ID fails the check.

## 7. Production security and operations

- [x] 7.1 Add TLS edge configuration, HTTP-to-HTTPS redirect, and secure cookie/CSRF settings for the on-prem stack; verify plain HTTP redirects and a missing CSRF token is rejected.
- [x] 7.2 Move all production secrets to protected runtime configuration and document rotation; verify a repository/image scan finds no database password, certificate key, or analytics licence key.
- [x] 7.3 Add structured logging with correlation IDs and PII redaction; verify a failed sign-in and a failed prescription/payment request produce correlated logs without credentials or PHI.
- [x] 7.4 Add liveness/readiness checks for PostgreSQL, schema baseline, and file volume; verify a stopped database or unwritable volume marks readiness unhealthy while liveness remains healthy.
- [x] 7.5 Add WAL archiving, scheduled base backups, retention, and monitoring; verify backup age is visible and a configured failure raises an alert.
- [ ] 7.6 Run and record a restore drill into an isolated environment; verify row counts and checksums match the selected restore point and the measured duration is recorded.

## 8. Deployment documentation and sign-off

- [x] 8.1 Write `docs/operations/deployment.md` covering host prerequisites, bootstrap, TLS, secrets, upgrades, and smoke checks; verify a clean host can be deployed by following it without undocumented steps.
- [x] 8.2 Write `docs/operations/recovery.md` covering backup restore, rollback, and disaster recovery; verify the restore drill steps match the recorded drill.
- [ ] 8.3 Write `docs/operations/support.md` covering logs, health endpoints, certificate renewal, backup ownership, and escalation; verify each operational owner is named.
- [ ] 8.4 Obtain sign-off for the production host, client/browser, device matrix, backup target, and support model; verify the signed prerequisites are committed.

## Workflow follow-up

- Archive this change after the platform, baseline, and operational prerequisites are accepted.
- Ensure dependent module changes cite the signed baseline IDs.
