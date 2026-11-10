# Design

## Context

See `proposal.md` for motivation. The repository currently contains only `xOpti.Migrations`, its tests, migration notes, and the staged PostgreSQL schema (`tools/legacy-migration/schema/xopti-schema.sql`, 73 objects in `public`/`migration`). `xOpti.Domain` is greenfield: no class library or test project exists yet. The authoritative rule sources are the migration notes ("Domain Rules to Preserve"), `eOptical6DAO/README.md`, and the legacy VB6 forms (`frmPriceWizard.frm`, `AppOLTP.bas`) available under `eOptical6DAO/`.

## Goals / Non-Goals

**Goals:**
- One shared vocabulary (types + rules) that Application, Infrastructure, and Api build on without redefinition.
- Rules that are testable against exported legacy sample data without any database or host.
- Types whose shape maps cleanly onto the already-migrated snake_case schema, so Infrastructure mapping is mechanical.

**Non-Goals:**
- Module features (POS flows, stock take, claims) - those arrive with later module changes.
- Persistence concerns: no EF Core attributes, no repository interfaces in Domain.
- Final entity graph completeness; aggregate roots for the first modules may be extended by later changes.

## Decisions

### Decision: Pure .NET 10 class library with record-based value objects
`xOpti.Domain` uses `record struct`/`record` types, private constructors with static factory methods returning `Result`-style validation, and no package references beyond the base framework. Alternative: NodaMoney or custom `decimal` wrappers everywhere. Rejected: the numeric(19,4) + legacy rounding semantics are project-specific and must be characterized against legacy output.

### Decision: Money backed by decimal with explicit scale policy
`Money` wraps `decimal` and normalizes to 4 decimal places (the `numeric(19,4)` contract); two-decimal display rounding is an explicit operation with a caller-chosen `MidpointRounding`. Alternative: store cents as long. Rejected: legacy VB6 arithmetic used floats/currency loosely against `numeric(19,4)` columns, and reconciliation requires 4-dp fidelity through the pipeline.

### Decision: Tax methods as an enum with a calculation service, not strategy hierarchies
The tax methods (`N` for exempt/excluded, `B`, `G`, `P`, `g`, `p`) represent a closed set derived from `frmPriceWizard.frm` and optical retail exemptions, so a single pure `TaxCalculator` keyed by `TaxMethod` enum keeps characterization tests direct. Rates are passed in (they live in `Preference`/tax tables), not hard-coded. Alternative: per-method strategy classes. Rejected as ceremony for a closed set.

### Decision: Cost layers are domain-owned, consumption order is a domain policy with deficit handling
`CostLayer` holds quantities and unit cost; `CostingPolicy` selects layer ordering from the category costing method (`"2"` = LIFO, otherwise average/FIFO per the notes). Individual positive cost layers reject over-consumption, but `CostingPolicy` supports deficit allocation (allocating an unassigned/deficit layer at fallback standard cost) when stock-on-hand is depleted or pending receipt. This matches legacy eOptical behavior where physical sales occur before receiving slips (`SR`) are entered, avoiding POS register aborts. Aggregate of consumed layers stays referable so Infrastructure can persist `invt_lot_record`-style rows. Alternative: compute cost in SQL. Rejected: rules must be unit-testable and reused by POS, adjustments, and reports.

### Decision: TransactionType as enum with explicit legacy code mapping
Mapping table in code (`SR`, `RJ`, `SJ`, `RC`, `RS`, `WC`, `WR`, `SA`), with parsing helpers tolerant of legacy padding/whitespace. Control number types derive from `TransactionType` where families match.

### Decision: Attribution and soft delete as a small base, not a framework
A shared `AuditInfo` value object (created/modified user+branch, soft-delete flag + reason code) embedded by entities; no base-class inheritance requirements beyond plain composition. Persistence layer maps it to columns; enforcement of presence is at the domain factory level.

## Risks / Trade-offs

- [Legacy rules are incompletely documented (e.g., rounding edge cases in refunds)] → Characterization tests pull expected values from exported legacy data and flag unresolved cases rather than guessing.
- [Domain schema mismatch: the migrated schema is a 1:1 shape and later redesign may rename/restructure] → Keep types independent of column names; Infrastructure owns all mapping.
- [Overfitting to sample data from the wrong customer (archives belong to different customers)] → Rules encode only the notes' confirmed Richmond profile; anything else is configuration (rates), not code.

## Open Questions

- Are discount rules (multi-tier, staff pricing) part of this change's characterization set, or deferred to the POS module change? Assumed deferred; only tax/costing are in scope now.
