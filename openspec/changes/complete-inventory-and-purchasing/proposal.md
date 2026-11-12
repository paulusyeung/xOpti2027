# Proposal

## Why

Inventory control is the operational core of the legacy business, but xOpti currently has only read-oriented master data. Without receiving, rejection, adjustment, transfer, stock take, lot tracking, costing, and supplier balances, POS sales cannot post correctly and the migrated stock position cannot be trusted.

## What Changes

- Deliver inventory control:
  - Receive stock from suppliers (SR) into branch lots with quantity, unit cost, received date, supplier, and control number.
  - Reject or return stock to suppliers (RJ) with reason, cost, and quantity reversal.
  - Post positive and negative stock adjustments (SJ) with reason codes, attribution, and audit.
  - Transfer stock between branches with atomic source/destination updates and reconciliation.
  - Perform stock takes from a frozen snapshot, import counted quantities, review variances, and post approved adjustments.
  - Track lots, deficits, and on-hand quantities by branch, SKU, and lot.
  - Apply FIFO, LIFO, or average costing by category, including persistent cost layers, deficit layers, and deficit reconciliation on receipt.
  - Provide inventory valuation, availability, movement history, and reorder/exception views.
- Deliver purchasing support:
  - Maintain supplier receiving and rejection/return documents with SR/RJ numbering.
  - Record supplier costs, taxes, and payable-relevant totals.
  - Reprint receiving/rejection documents and labels.
  - Reconcile supplier activity and balances against posted documents.
- Keep posting atomic and idempotent, preserve legacy identifiers, and never dual-write the legacy summary tables.
- Out of scope: retail/wholesale sales, customer prescriptions, payment processing, and report layout implementation.

## Capabilities

### New Capabilities

- `inventory-control`: stock receipt, rejection, adjustment, transfer, stock take, lot/deficit tracking, costing, valuation, availability, and movement history.
- `purchasing`: supplier receiving and rejection/return documents, supplier costs and payable-relevant totals, document reprints, and supplier activity reconciliation.

### Modified Capabilities

None.

## Impact

- Affected code: `Application/Inventory`, `Application/Purchasing`, new Infrastructure repositories and mappings for `inventory`, `invt_lot_record`, `branch_inventory`, `invt_st_*`, `supplier*`, `tx_header`/`tx_details` for SR/RJ/SJ, and new API/Web inventory and purchasing screens.
- Affected data: existing migrated inventory, lot, stock-take, supplier, and transaction tables; no destructive schema changes. Additive app-owned metadata only where required for audit/retirement.
- Dependencies: `complete-master-data-and-security`, the signed parity baseline, and corrected control-number allocation.
- Follow-on changes: POS, wholesale, and reporting depend on inventory posting and costing.
