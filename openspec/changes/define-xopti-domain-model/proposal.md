# Proposal

## Why

`xOpti.Migrations` has landed the normalized PostgreSQL schema and full legacy history, but the four application projects (`xOpti.Domain`, `xOpti.Application`, `xOpti.Infrastructure`, `xOpti.Api`) do not exist yet. Every later module (inventory, POS, prescriptions, wholesale, reporting) depends on a shared set of domain types and preserved business rules (tax methods, costing, transaction types, control numbers). Establishing `xOpti.Domain` first prevents those rules from being re-invented inconsistently inside each module.

## What Changes

- Create the `xOpti.Domain` class library (.NET 10) with no dependencies on EF Core, ASP.NET, or Npgsql, referenced by all other projects.
- Add value objects with enforced invariants: `Money` (`numeric(19,4)` semantics, never floating point), `Quantity`, `Sku`, `Lot`, `TaxCode`, `CostLayer`, `Rx`, `ControlNumber`.
- Add the preserved legacy transaction taxonomy as a domain enum/typed model: `SR`, `RJ`, `SJ`, `RC`, `RS`, `WC`, `WR`, `SA`.
- Implement domain rules extracted from the legacy forms and notes: the tax methods (`N`, `B`, `G`, `P`, `g`, `p` - including `N` for tax-exempt/excluded lines per `frmPriceWizard.frm` and Canadian optical dispensing rules), costing method semantics (LIFO when `Category.CostingMethod = "2"`, otherwise average/FIFO) with cost-layer consumption and deficit-layer policies to prevent POS blocking on negative inventory, and soft delete with reason codes plus user/branch attribution invariants.
- Add characterization tests for tax, discount, costing, and refund rules using exported legacy sample data.

## Capabilities

### New Capabilities

- `domain-value-types`: value objects and their invariants (Money, Quantity, Sku, Lot, TaxCode, CostLayer, Rx, ControlNumber) that all layers share.
- `domain-business-rules`: preserved legacy business semantics - transaction type taxonomy, tax calculation methods, inventory costing (LIFO/average/FIFO) ordering, and audit/attribution invariants (soft delete with reason codes, user and branch on every record).

### Modified Capabilities

None.

## Impact

- Affected code: new `src/xOpti.Domain` project added to `xOpti.sln`; new `tests/xOpti.Domain.Tests` project.
- Follow-on changes depend on this: `build-xopti-application-layer`, `implement-xopti-infrastructure`, `establish-xopti-api`.
- No database, API, or frontend behavior changes; the migrated PostgreSQL schema is untouched.
- Dependencies: .NET 10 and the existing test stack only; deliberately no persistence or hosting packages.
