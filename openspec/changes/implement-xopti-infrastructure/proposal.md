# Proposal

## Why

`xOpti.Application` defines ports (unit of work, repositories, control-number allocation, audit, idempotency, current principal) but nothing implements them. `xOpti.Infrastructure` is the project that connects those contracts to the already-migrated PostgreSQL schema with EF Core 10/Npgsql, provides ASP.NET Core Identity with the permission-claim vocabulary, and hosts the platform services the notes require (race-safe control numbers, audit logging, QuestPDF, file storage).

## What Changes

- Create `xOpti.Infrastructure` (.NET 10 class library) implementing all Application ports with EF Core 10 + Npgsql, mapping onto the existing migrated `public` schema (snake_case via `EFCore.NamingConventions`, `numeric(19,4)` value converters for `Money`, `timestamptz`) with legacy tables explicitly marked with `ExcludeFromMigrations()` rather than creating a parallel schema; add `xmin` optimistic concurrency mapping (schema gain columns via a versioned migration as needed).
- Implement ASP.NET Core Identity stores for users/roles with a permission-claim service (roles map to claim sets; `cost:view` etc.), password re-hash/forced-reset handling for migrated legacy accounts, lockout, and session state.
- Implement race-safe control-number allocation (PostgreSQL sequences + advisory/row locks with `SELECT ... FOR UPDATE` inside the command transaction for `Preference`/`TxNextNumber` alphanumeric families) satisfying `IControlNumberAllocator`.
- Implement `IAuditRecorder` (append-only audit log for financial/inventory changes with user/branch attribution), `IIdempotencyStore` (atomic reservation and keyed store with retention), and the `IClock`/`ICurrentPrincipal` adapters.
- Add QuestPDF configuration (Linux font setup, bundled fonts such as `3of9.TTF`) with a document-render port implementation and a filesystem-backed file storage implementation under `/var/lib/xopti/files`.
- Add background-job scaffolding (scheduled materialized-view refresh hooks) without implementing report content.

## Capabilities

### New Capabilities

- `data-persistence`: EF Core persistence of domain aggregates against the migrated PostgreSQL schema with concurrency, transaction, and type-mapping guarantees.
- `identity-access`: user/store credential lifecycle and permission-claim issuance used by the authorization model.
- `platform-services`: race-safe control-number allocation, audit recording, idempotency storage, document rendering, and file storage.

### Modified Capabilities

None.

## Impact

- Affected code: new `src/xOpti.Infrastructure` project added to `xOpti.sln`; new integration test project or expanded `tests/` coverage against Testcontainers PostgreSQL.
- Depends on: `define-xopti-domain-model` and `build-xopti-application-layer` (implements its ports).
- Databases: operates against the `xopti` target database populated by `xOpti.Migrations`; may add a small number of additive columns/tables (Identity tables, audit, idempotency) as owned EF migrations applied by the one-shot `xOpti.Migrations`-adjacent job, never on API startup.
- New dependencies: `Microsoft.EntityFrameworkCore` 10, `Npgsql.EntityFrameworkCore.PostgreSQL`, `EFCore.NamingConventions`, `Microsoft.AspNetCore.Identity.EntityFrameworkCore`, `QuestPDF`.
