# Tasks

## 1. Project scaffolding

- [ ] 1.1 Create `src/xOpti.Infrastructure` (.NET 10 class library) referencing `xOpti.Domain` and `xOpti.Application`, add EF Core 10, `Npgsql.EntityFrameworkCore.PostgreSQL`, `EFCore.NamingConventions`, `Microsoft.AspNetCore.Identity.EntityFrameworkCore`, and `QuestPDF`, and verify `dotnet build` succeeds.
- [ ] 1.2 Add an integration test project `tests/xOpti.Infrastructure.Tests` with Testcontainers PostgreSQL reusing the comparison-database approach from `xOpti.Migrations.Tests`, and verify a trivial container-backed test passes.

## 2. DbContext and mapping

- [ ] 2.1 Create the `DbContext` with snake_case naming, schema scoping to the existing `public` schema, `.ExcludeFromMigrations()` on legacy mapped tables, and connection-string-driven configuration, and verify `dotnet ef dbcontext info` succeeds against a Testcontainers database seeded from `xopti-schema.sql`.
- [ ] 2.2 Map core aggregates (transaction header/detail/payment, inventory item, lot, branch, customer, preference) with `Money` value converters (four-decimal), enum-to-code converters, and `timestamptz` handling, and verify round-trip tests assert exact money and instant fidelity, including a DST boundary case.
- [ ] 2.3 Map PostgreSQL `xmin` as the concurrency token on the mapped aggregates and verify a parallel-update test fails the loser with a concurrency conflict.
- [ ] 2.4 Implement `IUnitOfWork` over the `DbContext` honoring an ambient transaction with no nested re-open, and verify a two-aggregate failure test commits nothing.

## 3. App-owned schema

- [ ] 3.1 Define the app-owned tables (Identity `asp_net_*`, `platform.audit_log`, `platform.idempotency_record`) as the initial EF migration set and verify `dotnet ef migrations script` produces additive-only SQL containing 0 statements for legacy migrated tables.
- [ ] 3.2 Wire migration deployment into the one-shot migration job pattern (never at API startup) and verify the job applies migrations idempotently on an already-migrated database.

## 4. Platform services

- [ ] 4.1 Implement `IControlNumberAllocator` using counter-row `SELECT ... FOR UPDATE` with regex-safe numeric parsing for RC/RS/SR/RJ/SJ/WC, and verify a 50-way concurrent allocation test returns distinct increasing numbers and updates the stored counters.
- [ ] 4.2 Implement `IIdempotencyStore` with atomic lease reservation (`TryAcquireAsync`), retention expiry, and first-result replay, and verify replay-within-window, concurrent duplicate conflict, and expiry tests pass.
- [ ] 4.3 Implement the audit `SaveChangesInterceptor` with per-entity allow-listed payloads and actor/branch capture, and verify an adjustment-commit test produces one correct audit entry and PII columns are excluded.
- [ ] 4.4 Implement `IClock` (system) and `ICurrentPrincipal` (claims-based) adapters, and verify unit tests cover claim extraction and UTC behavior.

## 5. Identity and permission seeding

- [ ] 5.1 Configure ASP.NET Core Identity stores with lockout and password policy options, and verify lockout-after-threshold and hash verification tests pass against Testcontainers.
- [ ] 5.2 Implement the role-to-permission-claim mapping service for the authorization-model vocabulary, and verify a signed-in principal's claims match the seeded role matrix, including default-deny for unmapped legacy levels.
- [ ] 5.3 Implement the one-shot seeder that converts legacy `users`/`security`/staff rows into Identity users with forced reset (never carrying legacy password material) and verify seeded accounts cannot authenticate with legacy values but can complete a reset flow.

## 6. Documents and storage

- [ ] 6.1 Implement the document-render port with QuestPDF configured for bundled fonts on Linux (including the barcode font), and verify a smoke render containing the barcode font succeeds in a Linux container.
- [ ] 6.2 Implement file storage rooted at the configured volume path with namespaced keys and normalized case-sensitive paths, and verify writes land under the configured root and path-traversal attempts are rejected.

## 7. Jobs and verification

- [ ] 7.1 Add the single-instance hosted job runner (feature-flagged) with a scheduled materialized-view refresh example, and verify enable/disable flags start/stop the job in integration tests.
- [ ] 7.2 Run the Application reference slice against real Infrastructure implementations (replace fakes with DI composition in tests) and verify the full `ListBranches` pipeline behaves identically to the fake-backed result.
