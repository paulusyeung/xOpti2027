# Proposal

## Why

`xOpti.Domain` defines the shared types and rules, but the application layer that the API and modules will sit on does not exist. Without an agreed vertical-slice structure (command/query handlers, validators, DTOs, ports to persistence/clock/control numbers/audit) and a permission vocabulary replacing the legacy integer `SecurityLevel`, every module (Sales, Inventory, Purchasing, ...) would invent its own conventions, and cost-visibility requirements like `pyUserHasCostLevel` would be re-implemented inconsistently.

## What Changes

- Create `xOpti.Application` (.NET 10 class library) referencing only `xOpti.Domain`; it defines ports (interfaces) that `xOpti.Infrastructure` will implement: unit of work, repositories/collections per aggregate, control-number allocation, audit sink, clock, idempotency store, and file/document rendering abstractions.
- Establish the vertical-slice convention: one folder per module (`Sales`, `Inventory`, `Purchasing`, `Customers`, `Prescriptions`, `Wholesale`, `Reporting`, `Identity`) containing command/query + handler + FluentValidation validator + request/response DTOs, dispatched through a pipeline (validation first, then handler, inside one explicit transaction for commands).
- Define the authorization model vocabulary: permission claim constants (`cost:view`, `inventory:adjust`, `report:financial`, `customer:pii`, and the full matrix derived from the legacy `SecurityLevel`), handler-level permission requirements, and the cost-visibility rule that replaces `pyUserHasCostLevel`.
- Define idempotency and keyset-pagination contracts used by all write/read slices (idempotency key requirement on sale/invoice/payment commands; cursor-based page results for queries).
- Prove the architecture with one reference slice (list branches with keyset pagination) implemented against in-memory fakes in tests.

## Capabilities

### New Capabilities

- `application-vertical-slices`: command/query dispatch, validation-before-handler pipeline, per-module organization, transaction and idempotency behavior for commands, keyset pagination for queries, and the ports the application layer requires from infrastructure.
- `authorization-model`: the permission-claim vocabulary and its enforcement semantics at handler level, including granular cost visibility replacing the legacy cost-level flag.

### Modified Capabilities

None.

## Impact

- Affected code: new `src/xOpti.Application` and `tests/xOpti.Application.Tests` projects added to `xOpti.sln`.
- Depends on: `define-xopti-domain-model` (types and rules).
- Unblocks: `implement-xopti-infrastructure` (implements the ports) and `establish-xopti-api` (hosts the dispatcher).
- New NuGet dependencies confined to Application: `FluentValidation`. No EF Core, ASP.NET, or Npgsql references.
