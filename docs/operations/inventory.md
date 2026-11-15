# Inventory and purchasing operating rules

This page is the operator-facing contract for stock posting. Each rule names the
automated test that proves it. Source behaviour is recorded in
`docs/parity/transaction-rules.md`, `costing-rules.md`, and
`tax-rules.md`.

## Control numbers and transaction numbers

- Every posting allocates a prefixed transaction number (`SR`, `RJ`, `SJ`,
  `WC`, `WR`, `SA`, `RC`, `RS`) and a separate eight-digit inventory control
  number.
- The stored counter value is the **next** number. Posting consumes it and
  advances the counter; a missing family fails with a clear configuration
  error and never borrows another family.
- Allocation and the control counter are atomic under concurrency.

Tests:
`ControlNumberAllocatorTests.EveryRequiredFamily_AllocatesFromItsOwnCounter`,
`ControlNumberAllocatorTests.MissingFamily_FailsClearly_WithoutBorrowingAnotherCounter`,
`InventoryConcurrencyTests.ConcurrentPosting_HasNoLostUpdatesOrDuplicateNumbers`.

## Receiving (SR)

1. Choose supplier and branch.
2. Enter one or more lines: SKU, lot, quantity, unit cost, GST/PST, tax code.
3. Post with an idempotency key and a reason.

Effects, in one transaction: SR document and lines, lot create/increase,
weighted-average cost and on-hand, branch inventory, audit. Replaying the same
idempotency key returns the original document and does not increase stock again.

Tests: `ReceiveStockTests.Receipt_PostsOnce_PersistsLotAndInventory_AndIsIdempotent`,
`ReceiptAtomicityTests.ForcedFailure_RollsBackBothLotAndInventoryTotals`.

## Rejection / return (RJ)

- Optional original SR reference; quantity cannot exceed the lot’s available
  quantity.
- Over-return is rejected with the available quantity and changes nothing.
- Header and line quantities/amounts/taxes are negative; the lot, SKU on-hand,
  and branch inventory decrease together.

Tests: `RejectStockTests.Rejection_GuardsAvailableQuantity_AndReferencesTheReceipt`.

## Adjustments (SJ)

- Reason code must be one of `COUNT`, `DAMAGE`, `FOUND`, `CORRECTION`, `THEFT`,
  `EXPIRY`; a reason is mandatory.
- Positive adjustments create an adjustment lot.
- A negative adjustment that would go below zero is rejected with the shortfall
  unless the operator explicitly confirms the deficit.
- Posting updates the document, on-hand, branch inventory, and audit atomically.

Tests: `StockAdjustmentTests.Adjustments_PostBothDirections_AndBlockUnexpectedDeficits`.

## Branch transfers

- Source and destination branches must exist; quantity cannot exceed source
  on-hand.
- Two SJ movements share one transfer identifier (`tx_header.tracking_number`).
- The source decrease and destination increase commit or roll back together.

Tests: `TransferStockTests.Transfer_PostsPairedMovementsSharingOneIdentifier`,
`TransferStockTests.ForcedDestinationFailure_RollsBackTheSourceDecrease`.

## Costing and deficits

- Category `costing_method`: `1` = FIFO, `2` = LIFO, `3` = average. Missing or
  other codes block posting.
- Issues consume persistent lots in method order; average uses the weighted
  cost of available layers, rounded to four decimals.
- Issuing beyond on-hand persists a deficit lot (`DEF…`). Sales are not blocked.
- A later receipt into that deficit lot reconciles it toward zero.

Tests: `CostingAndReconciliationTests.LIFO_FIFO_Deficits_MethodValidation_AndReconciliationDrift`,
`LegacyCharacterizationTests` (domain fixtures).

## Stock-take procedure

1. **Create / freeze** a stock take (`POST /inventory/stock-takes`). The
   computer quantity is copied at freeze time and does not follow later
   inventory changes.
2. **Count** offline, then import `sku,qty` CSV. Use dry run first; invalid
   rows (unknown/duplicate SKU, bad quantity) write nothing and report a resume
   row.
3. **Review variances**: system vs counted vs difference, with average cost.
4. **Approve** only after every snapshot row is counted. Approval changes no
   inventory.
5. **Post** the approved variances. One SJ document references the take
   (`RefNumber = STK{id}`), one line per difference; header status becomes
   posted and reposting is rejected.

Tests: `StockTakeSnapshotTests.FrozenSnapshot_MatchesOnHand_AndDoesNotChangeWithInventory`,
`StockTakeCountImportTests.CountImport_RejectsInvalidRows_AndDryRunWritesNothing`,
`StockTakeVarianceTests.VarianceApproval_DoesNotChangeInventory`,
`StockTakePostingTests.ApprovedVariances_PostAsOneReferencedSJ_AndCannotPostTwice`.

## Availability, valuation, and reconciliation

- Availability shows on-hand, branch quantities, and lots.
- Movement history is keyset-paged from posted transaction lines.
- Valuation omits cost/margin fields without `cost:view`.
- `GET /inventory/reconciliation` reports SKUs where inventory differs from
  lot sums, with affected lots. It never corrects quantities automatically.

Tests: `AvailabilityAndMovementTests`, `InventoryValuationTests`,
`CostingAndReconciliationTests`, `InventoryPaginationTests`,
`InventorySummaryTests`.

## Supplier documents and activity

- `GET /purchasing/documents/{txNumber}` reprints SR/RJ documents and audits
  every reprint.
- Activity summarizes receipts, returns, taxes, net cost, and document numbers
  for a supplier and period.
- Calculated activity is compared with migrated `supplier_summary`; mismatches
  name the affected documents and are never written back.

Tests: `SupplierDocumentTests.SupplierDocuments_ActivityAndSummaryMismatch`.

## Concurrency checklist for operators

- Use one idempotency key per intended posting; retries reuse the key.
- Do not delete or edit posted documents; use rejection/return or adjustment.
- If a posting fails, nothing was committed; re-post after fixing the input.
- After a batch rehearsal, run `GET /inventory/reconciliation` before go-live.
