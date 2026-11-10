# Design

## Context

See `proposal.md`. The PostgreSQL target (`xopti` database) already holds the 1:1 migrated schema from `xOpti.Migrations` (snake_case, legacy keys like `txnumber`, 10 sequences, view-based query helpers; no `xmin` columns were added by the migration). Application ports and permission vocabulary come from `build-xopti-application-layer`. The notes mandate: EF Core 10 + Npgsql, `EFCore.NamingConventions`, `xmin` concurrency, one transaction per posting, Identity with cookie auth (hosting in Api), QuestPDF on Linux with bundled fonts, and EF migrations run only as a one-shot job.

## Goals / Non-Goals

**Goals:**
- All Application ports have production implementations.
- Map domain onto the existing schema with value converters, without re-designing tables prematurely.
- Additive app-owned schema (Identity, audit, idempotency tables; `xmin` where concurrency is needed) delivered as versioned EF migrations.

**Non-Goals:**
- HTTP/auth middleware and cookie/CSRF configuration (Api change).
- Real report layouts or analytics endpoints (Reporting module changes).
- Rewriting `xOpti.Migrations` ELT or changing migrated data content.

## Decisions

### Decision: DbContext maps to existing `public` schema; app-owned tables coexist
Use `EFCore.NamingConventions` for snake_case, explicit `HasColumnName` only for legacy oddities, and place new app-owned tables (Identity `AspNet*` renamed to snake_case, `platform.audit_log`, `platform.idempotency_record`) in the same database. All legacy migrated table mappings are configured with `.ToTable("...", t => t.ExcludeFromMigrations())` so that EF Core migration scaffolding never attempts to generate `CreateTable` statements for the pre-existing 70+ tables, ensuring generated migrations remain purely additive. Alternatives: separate database or split contexts (`AppPlatformDbContext` vs `XOptiDbContext`). Exclude-from-migrations within a unified context keeps cross-table queries direct while avoiding schema collisions.

### Decision: Entity classes mirror legacy tables; domain mapping stays thin initially
Because the schema is 1:1 legacy, EF entity classes are close table mirrors with `Money`↔`decimal(19,4)` and enum↔code converters mapping to/from Domain value objects on aggregate roots only (transaction header, inventory item, lot). Full clean-architecture entity separation deferred; risk contained by keeping mapping configuration in one `Infrastructure/Persistence/Mapping` area. Alternative: hand-written DTO-only Dapper reads. Rejected: notes already locked EF Core 10.

### Decision: `xmin` added by migration, used as concurrency token
Legacy tables lacked row versioning; add `xmin` implicitly - PostgreSQL provides `xmin` for free on every table, so EF maps `Property<uint>("xmin").IsRowVersion()` without DDL changes. Verified assumption; if any required table lacks it, no migration is needed since `xmin` is system-supplied.

### Decision: Control numbers via `SELECT ... FOR UPDATE` on counter rows
`IControlNumberAllocator` increments the `pref_tx_number`/`Preference` row under `FOR UPDATE` (or a PostgreSQL sequence behind a thin formatter for pure-numeric families) within the active transaction scope. Row locks inside the transaction guarantee strict, gap-free sequence monotonicity required for financial/invoicing compliance (`RC`), rolling back the counter state if posting fails. Advisory locks rejected in favor of row locks: simpler, matches legacy counter semantics, and race behavior is directly testable with parallel tasks.

### Decision: Idempotency store with atomic reservation leases
`IIdempotencyStore` maps to `platform.idempotency_record` (unique key constraint, status: in-progress vs completed, payload, created_at, expires_at). `TryAcquireAsync` performs an atomic insert-or-fail lease: concurrent attempts for the same key fail the lease immediately, preventing duplicate transaction execution in the application pipeline.

### Decision: Identity stores on app-owned tables, legacy `users`/`security` read-only
Migrated `users`/`security`/`job_nature` rows seed app Identity users/roles via a one-shot seeding routine with forced password reset tokens; legacy tables remain the historical source (traceability) but are never auth tables. Roles map to permission claim sets defined by the Phase 0 matrix; incomplete matrix entries seed a conservative default-deny set.

### Decision: Audit via EF SaveChanges interceptor
Append-only `platform.audit_log` written by a `SaveChangesInterceptor` diffing tracked financial/inventory entities, capturing actor/branch from `ICurrentPrincipal`/`IClock`. Alternative: per-handler explicit audit. Rejected: interceptor guarantees coverage; handlers can still add semantic detail.

### Decision: QuestPDF + Skia on Linux via containerized font setup
Fonts (including `3of9.TTF`) copied into the API image and registered through `QuestPDF.Settings.License`/font options plus fontconfig; rendering implemented behind the Application document port. File storage writes under configured root (`/var/lib/xopti/files`), keys namespaced by module/date; path normalization rules from the notes apply (case-sensitive lookups).

### Decision: Jobs use built-in hosted-service timers for MVP
Materialized-view refresh jobs run as a single-instance hosted service (cron-lite schedule expressions), acceptable for one API instance on one host; Hangfire/quartz rejected until multi-instance is real.

## Risks / Trade-offs

- [Mirrored entities let legacy schema quirks leak into code] → Keep converters and naming in one place; later module changes may refactor hot aggregates without breaking ports.
- [Seeding/forcing resets for ~thousands of migrated staff accounts is operationally sensitive] → Produce a runbook and reconciliation report of seeded accounts; require admin sign-off before cutover.
- [Interceptor-based audit could log PII] → Audit payloads are allow-listed per entity; customer PII columns excluded by default.
- [Single-instance jobs assumption breaks if API scales out] → Document constraint; job registration is feature-flagged.

## Open Questions

- Do all concurrency-sensitive legacy tables need explicit unique constraints added, or is `xmin` sufficient for Phase 1? Deferred until POS module tests reveal hot rows.
- Retention period for idempotency records: 24h assumed pending operations review.
