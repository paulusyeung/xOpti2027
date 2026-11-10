# Design

## Context

See `proposal.md` for motivation. `xOpti.Domain` (from `define-xopti-domain-model`) provides `Money`, `CostLayer`, `TransactionType`, tax/costing policies, and audit info. The migrated schema (`tools/legacy-migration/schema/xopti-schema.sql`) is 1:1 with legacy shapes; Application must not bake those shapes in. Migration notes mandate vertical slices, FluentValidation, one transaction per posting, idempotency keys on sale/invoice/payment, keyset pagination, and permission claims replacing `SecurityLevel`.

## Goals / Non-Goals

**Goals:**
- A dispatch pipeline and folder/namespace convention modules copy mechanically.
- Ports that Infrastructure can implement without Application knowing EF internals.
- Cost-visibility and PII gating expressed once, applied per-slice declaratively.

**Non-Goals:**
- Implementing real handlers against the database (later module changes).
- HTTP concerns: status codes, routing, problem-details formatting (Api change).
- Role management UI or Identity persistence (Infrastructure + later Identity module).

## Decisions

### Decision: Hand-rolled mediator over MediatR
Define a minimal `IRequest<TResponse>` / `IRequestHandler<TRequest,TResponse>` with pipeline behaviors (`ValidationBehavior`, `TransactionBehavior`, `PermissionBehavior`, `IdempotencyBehavior`). All dispatchers, handlers, and behaviors accept and propagate `CancellationToken` to ensure client aborts propagate cleanly to persistence. MediatR is unmaintained since the Liscio acquisition; an explicit ~200-line dispatcher plus behavior chain avoids dependency risk and keeps ordering visible. Alternative: built-in .NET DI `IEnumerable` handlers with decorators. Same shape; the behavior-chain naming documents intent.

### Decision: Behavior ordering fixed in the composition root
Order: permission → validation → idempotency → transaction → handler. Permission first denies without cost; validation before transaction; idempotency check before transaction so replays don't reopen work; transaction wraps only the handler. To prevent race conditions from concurrent duplicate submissions (e.g. quick double-clicks), `IdempotencyBehavior` acquires an atomic key reservation via `IIdempotencyStore.TryAcquireAsync` before delegating to `TransactionBehavior`, persists the cached response after successful commit, or releases/cancels the reservation on unhandled exception. Alternatives (validation first) rejected because permission checks are cheaper and must not leak validation detail to unauthorized callers.

### Decision: Module namespaces mirror the notes, one folder per use case
`xOpti.Application/{Module}/{UseCase}/` containing `XxxCommand.cs`, `XxxCommandHandler.cs`, `XxxCommandValidator.cs`, `XxxResult.cs`. Boundaries enforced by namespace + later analyzer or test convention check, not physical projects, matching the modular-monolith decision.

### Decision: Ports are aggregate-oriented, not generic repositories
`IBranchRepository`, `IInventoryItemRepository`, ... returning domain types; plus cross-cutting ports `IUnitOfWork`, `IControlNumberAllocator`, `IClock`, `IAuditRecorder`, `IIdempotencyStore`, `ICurrentPrincipal`. Generic `IRepository<T>` rejected: it invites leaky query composition into Application and hides aggregate intent.

### Decision: Permission claims are constants + attributes on request types
`PermissionNames` holds kebab-case claim values; requests declare requirements via a `IHasPermissions` member or metadata token consumed by `PermissionBehavior`. The full matrix (legacy `SecurityLevel` -> claims) is seeded from the Phase 0 permission matrix; incomplete mapping is tracked in Infrastructure seed data, not guessed here.

### Decision: DTOs are flat records; cost/margin fields are separate DTO members
Results expose `Cost`/`Margin` members as nullable and a masking step in `PermissionBehavior` (or handler-side check via `ICurrentPrincipal`) clears them when `cost:view` is absent — chosen handler-side masking so behavior stays declarative and testable per slice.

## Risks / Trade-offs

- [Behavior chain becomes "magic" for newcomers] → Reference slice plus architecture tests (every handler resolvable, every command validated) document the path explicitly.
- [Idempotency contract without a real store is unproven] → The fakes exercise replay logic; real semantics (TTL, key scope per endpoint) land with Infrastructure and integration tests.
- [Permission matrix incomplete until Phase 0 finishes] → Constants and gating ship now; seeds and role mappings are explicitly deferred tasks in the Infrastructure change.

## Open Questions

- Should queries also run inside a read-only transaction, or rely on snapshot isolation alone? Deferred: default to no transaction for reads until contention evidence appears.
