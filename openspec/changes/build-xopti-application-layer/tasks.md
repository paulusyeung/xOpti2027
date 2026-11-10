# Tasks

## 1. Project scaffolding

- [ ] 1.1 Create `src/xOpti.Application` (.NET 10 class library) referencing `xOpti.Domain`, add `FluentValidation`, and verify `dotnet build` succeeds with no references to EF Core, Npgsql, or ASP.NET packages.
- [ ] 1.2 Create `tests/xOpti.Application.Tests` and add module folders (`Sales`, `Inventory`, `Purchasing`, `Customers`, `Prescriptions`, `Wholesale`, `Reporting`, `Identity`) with an architecture test asserting each folder maps to the expected namespace, and verify `dotnet test` passes.

## 2. Ports and contracts

- [ ] 2.1 Define cross-cutting ports `IUnitOfWork`, `IClock`, `ICurrentPrincipal`, `IAuditRecorder`, `IControlNumberAllocator`, `IIdempotencyStore` (with `TryAcquireAsync` reservation and `SaveResultAsync` contracts accepting `CancellationToken`) and verify they compile with only Domain types in signatures.
- [ ] 2.2 Define aggregate-oriented repository interfaces for the reference slice (`IBranchRepository`) and verify no interface exposes persistence types.

## 3. Dispatch pipeline

- [ ] 3.1 Implement `IRequest<TResponse>`/`IRequestHandler` dispatcher with full `CancellationToken` propagation resolved via .NET DI and verify tests cover single-handler resolution and a distinct unsupported-request error for unknown types.
- [ ] 3.2 Implement `ValidationBehavior` with FluentValidation producing structured field errors, and verify a test asserts the handler never executes for an invalid request.
- [ ] 3.3 Implement `TransactionBehavior` (one explicit `IUnitOfWork` transaction per command, commit on success, rollback on failure) and verify a fake-UnitOfWork test proves rollback after a mid-handler throw.
- [ ] 3.4 Implement `IdempotencyBehavior` for financial commands keyed by a required idempotency key with atomic reservation before transaction, and verify tests cover replay-returns-original-result, missing-key rejection, and concurrent duplicate rejection/conflict.
- [ ] 3.5 Fix and document behavior order (permission -> validation -> idempotency -> transaction -> handler) in the composition helper, and verify an ordered-execution test asserts the chain sequence.

## 4. Authorization model

- [ ] 4.1 Add `PermissionNames` constants (`cost:view`, `inventory:adjust`, `report:financial`, `customer:pii`, plus the mapped matrix entries) and verify a test asserts claim values match the kebab-case contract.
- [ ] 4.2 Implement `PermissionBehavior` consuming declared permissions of a request, and verify denied dispatch yields an authorization error with no side effects.
- [ ] 4.3 Implement handler-side cost masking (null out cost/margin DTO members without `cost:view`) and verify tests for both visibility states using inventory-shaped fixtures.
- [ ] 4.4 Implement PII gating for customer contact fields and verify a test shows masked output without `customer:pii` and full output with it.

## 5. Query conventions and reference slice

- [ ] 5.1 Define `PagedResult<T>` with opaque next-cursor and stable key ordering, and verify serialization tests show no offset members.
- [ ] 5.2 Implement the reference slice `ListBranches` (query, handler, validator, DTO) against in-memory fakes, and verify keyset paging tests cover full traversal and cursor continuation after a concurrent insert.
- [ ] 5.3 Write module onboarding documentation in `src/xOpti.Application/README.md` describing the folder convention, behavior chain, and port list, and verify a new contributor can locate each piece from the doc.
