# Design

## Context

See `proposal.md` for motivation. The migrated schema already has `inventory`, `invt_lot_record`, `branch_inventory`, `invt_st_header`, `invt_st_details`, `invt_st_import`, `supplier`, `supplier_summary`, `tx_header`, `tx_details`, and `pref_tx_number`. The current application maps inventory and lots only for test/seed purposes. The legacy posting logic lives in `AppOLTP.bas`; costing behavior has characterization tests but no posting implementation.

## Goals / Non-Goals

**Goals:**
- Make stock receipt, rejection, adjustment, transfer, and stock take safe under concurrency.
- Preserve legacy lot and cost-layer semantics, including deficits.
- Keep on-hand and valuation explainable from immutable movements.
- Reuse the existing transaction and control-number model for SR/RJ/SJ.

**Non-Goals:**
- Rebuilding the legacy summary-table dual-write subsystem.
- Sales, wholesale, payment, prescription, or report rendering.
- Purchase-order procurement workflow unless the signed baseline identifies it as legacy behavior.

## Decisions

### Decision: Lots are the cost-layer source of truth; inventory totals are a transactional cache

`invt_lot_record` rows represent positive and negative cost layers. Each posting updates lot rows and the branch/SKU on-hand totals in one transaction. A scheduled reconciliation compares cached totals with lot sums and reports drift; it never silently corrects without an audit entry.

Alternatives considered: deriving on-hand from lots on every query. Rejected for POS latency on 110k SKUs and 357k lots. Alternatives considered: treating cached totals as authoritative. Rejected because cost layers would drift.

### Decision: Explicit deficit layers, not blocked sales

A deficit is a negative lot/cost layer created when an issue exceeds available quantity. Receipts reconcile against deficit layers using the approved policy. Cost visibility and deficit indicators are permission-controlled. This preserves the legacy behavior where negative inventory does not stop checkout.

Alternatives considered: rejecting sales that would go negative. Rejected because the legacy system allows it and the business depends on it.

### Decision: One transaction per posting with row locks

Each SR/RJ/SJ command allocates its control number, writes header/detail/lot/inventory changes, and writes audit in one PostgreSQL transaction. Inventory and lot rows are locked in deterministic key order to avoid deadlocks. Idempotency keys are required on API posting commands and replayed results are returned without re-posting.

Alternatives considered: eventual consistency or background posting. Rejected because stock and financial documents must be immediately consistent.

### Decision: Stock take uses snapshot, staging, variance approval, then adjustment

Freeze a snapshot into the existing stock-take header/detail tables, import counts into `invt_st_import`, calculate variances against the snapshot, require approval, then post one SJ adjustment per approved variance. Unapproved counts never mutate inventory.

Alternatives considered: posting counts directly. Rejected because it destroys the ability to review variances and distinguish count errors from shrinkage.

### Decision: Transfers are paired movements under one identifier

A branch transfer writes a transfer identifier with a source decrease and destination increase. Both sides reference the same transfer and lot/cost information. The transaction commits or rolls back as a unit; no in-transit state is introduced unless the signed baseline requires it.

Alternatives considered: asynchronous in-transit transfer. Rejected as unnecessary for the single-company on-prem deployment.

### Decision: Summary tables are read models, not posting targets

Inventory/category/class/department/supplier summaries are exposed through views or refreshed materialized views derived from posted documents. The application never recreates the legacy dual-write. Reports and analytics consume the read models.

Alternatives considered: continuing to dual-write summaries. Rejected by `MIGRATION_NOTES.md` and because it creates two competing truths.

### Decision: Control-number allocation must be fixed before posting

The migration currently seeds `tx_next_number` one above the maximum while the allocator returns `current + 1`, which skips a number. This change depends on correcting that contract and covering all required families, including WR/SA, before SR/RJ/SJ posting is enabled.

Alternatives considered: tolerating gaps. Rejected because reconciliation and audit expect deterministic numbering.

## Risks / Trade-offs

- [Concurrent postings contend on the same SKU/lot] → Lock in deterministic key order; benchmark peak POS concurrency.
- [Cost-layer semantics differ from legacy edge cases] → Expand characterization fixtures from production rows before enabling adjustments and returns.
- [Cached inventory totals drift] → Run reconciliation after every batch import and nightly; alert on drift.
- [Stock-take snapshots become stale during counting] → Define and enforce a freeze window per stock take; block or flag movements during the frozen period.
- [Supplier summary tables are inconsistent after migration] → Treat them as derived read models and rebuild from posted documents before comparing.
- [Deficit reconciliation policy is ambiguous] → Get the signed baseline rule before enabling receipt-to-deficit reconciliation.

## Migration Plan

1. Fix control-number allocation and add coverage for all required families.
2. Map remaining inventory, lot, stock-take, supplier, and transaction tables.
3. Implement read-only availability, valuation, movement history, and supplier activity.
4. Implement and test SR, RJ, and SJ posting against a copy of migrated data.
5. Enable transfers and stock takes after concurrency and variance tests pass.
6. Rebuild summary read models and reconcile with migrated totals.
7. Rehearse inventory-heavy transactions before POS go-live.

Rollback: disable posting endpoints, restore the pre-change database snapshot, and keep read-only inventory views available; no summary table is dual-written.

## Open Questions

- Does the signed baseline require purchase orders, or only receiving/rejection/returns?
- What is the approved deficit-reconciliation policy for receipts?
- Are branch transfers immediate or in-transit in the target operating model?
- What freeze window is acceptable for stock takes?
