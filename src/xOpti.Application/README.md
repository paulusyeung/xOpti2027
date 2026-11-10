# xOpti.Application

The application layer for xOpti: vertical slices, the dispatch pipeline, and
the ports that `xOpti.Infrastructure` implements. This layer references only
`xOpti.Domain` (plus `FluentValidation` and DI abstractions) - never EF Core,
Npgsql, or ASP.NET.

## Folder convention (one folder per module, one subfolder per use case)

```
xOpti.Application/
  Sales/ Inventory/ Purchasing/ Customers/
  Prescriptions/ Wholesale/ Reporting/ Identity/   <- business modules
    <UseCase>/                                      e.g. Identity/ListBranches/
      XxxCommand.cs / XxxQuery.cs                   request (ICommand<T> / IQuery<T>)
      XxxCommandHandler.cs                          handler (IRequestHandler<,>)
      XxxCommandValidator.cs                        FluentValidation validator
      XxxDto.cs / XxxResult.cs                      flat record DTOs
  Common/      IRequest, ICommand, IQuery, Dispatcher, PagedResult, markers
  Pipeline/    IBehavior + the four behaviors + pipeline error types
  Ports/       interfaces Infrastructure implements
  Authorization/  PermissionNames + cost/PII guards
```

Architecture tests enforce this layout; see `tests/xOpti.Application.Tests/ArchitectureTests.cs`.

## Dispatch pipeline

Register with `services.AddXOptiApplication()` (scans handlers and validators),
then inject `IRequestDispatcher` and call `DispatchAsync(request, cancellationToken)`.
The cancellation token propagates through every behavior to the handler.

Behavior order is fixed in `ApplicationServiceCollectionExtensions`:

```
permission -> validation -> idempotency -> transaction -> handler
```

- PermissionBehavior: requests implement `IHasPermissions`; denied calls throw
  `AuthorizationFailedException` with no side effects (cheapest check first,
  and validation detail is never leaked to unauthorized callers).
- ValidationBehavior: all `IValidator<TRequest>` run before anything else;
  failures throw `ValidationFailedException` with structured field errors.
- IdempotencyBehavior: commands implementing `IRequiresIdempotencyKey` reserve
  the key atomically via `IIdempotencyStore.TryAcquireAsync` before the
  transaction opens. Replay returns the stored result; an in-flight duplicate
  gets `IdempotencyConflictException`; failures release the reservation.
- TransactionBehavior: `ICommand<T>` executions run inside one explicit
  `IUnitOfWork` transaction; queries never open one.

Errors are exceptions with stable shapes (`Pipeline/PipelineErrors.cs`); the
API layer maps them to ProblemDetails.

## Ports (implemented by xOpti.Infrastructure)

| Port | Purpose |
| --- | --- |
| `IUnitOfWork` | one explicit transaction per posting |
| `IClock` | testable UTC time |
| `ICurrentPrincipal` | acting user, branch, permission claims |
| `IAuditRecorder` | append-only audit entries for financial/inventory changes |
| `IControlNumberAllocator` | race-safe legacy-prefixed control numbers |
| `IIdempotencyStore` | atomic key reservation, replay storage, release |

Repositories are aggregate-oriented (e.g. `IBranchRepository`) and return
domain types (`xOpti.Domain.Entities.Branch`); never `IRepository<T>`.

## Authorization vocabulary

`PermissionNames` (kebab-case `resource:action` claims) replaces the legacy
integer `SecurityLevel`. Sensitive data is masked handler-side:

- `CostGuard.MaskCosts/MaskCost` - clears cost/margin members unless the
  principal holds `cost:view` (replaces `pyUserHasCostLevel`).
- `PiiGuard.MaskPii/Mask` - clears contact members unless the principal holds
  `customer:pii`.

DTOs opt in by implementing `ICanMaskCosts<TSelf>` / `ICanMaskPii<TSelf>`.

## Reference slice

`Identity/ListBranches` (`ListBranchesQuery` + handler + validator + DTO) is
the copy-this-shape example, including keyset pagination via `PagedResult<T>`
and `KeysetCursor` (opaque cursor, stable `BranchCode` ordering, no offsets).
