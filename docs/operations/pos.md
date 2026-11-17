# POS operator procedures

This page is the operator-facing contract for counter sales, refunds, payments,
cash drawers, daily close, and reprints. Each procedure names the automated test
that proves it. Legacy behaviour is recorded in
`docs/parity/transaction-rules.md`, `tax-rules.md`, and `numbering-rules.md`.

## Permissions

- `sales:order-create` — save, edit, cancel, and deposit against sale orders.
- `sales:invoice-post` — post invoices, refunds, payments, and drawer
  open/count/movement/close operations.
- `sales:price-override` — change a catalogue price or exceed the configured
  discount threshold.
- `report:financial` — read the cash journal and finalize the business day.

The permission matrix is provisional pending sign-off; see
`openspec/changes/establish-production-baseline`.

## Sale order (SA)

1. Select the customer (name, VIP code, or id).
2. Search by SKU, add lines, and edit quantity, price, discount, and tax code.
3. Take an optional deposit and save with a reason.
4. Resume the order later from the open-orders list.

Orders do not consume stock. Order deposits are recorded as tender rows, and a
deposit may not exceed the order total. An order can only be edited, cancelled,
or invoiced while open. Cancelling an order records an audit event; deposits are
not refunded by cancellation.

Tests: `OrderEntryTests.OrderLifecycle_LinesValidation_ConversionWithDeposit_AndIdempotentRetry`,
`RetailSaleTests.OrderDeposit_IsIdempotent_AndRequiresCardReference`.

## Convert an order to an invoice (RC)

1. Resume the open order.
2. Tender exactly the outstanding balance (total less deposits).
3. Confirm conversion.

Conversion creates a new RC invoice, links it to the order (`ref_number`),
applies the deposit once, chooses an open drawer session when supplied, consumes
cost layers, and sets the order to completed. Retrying with the same idempotency
key returns the original invoice; a different key does not create a second one
while the order is already completed.

Tests: `OrderEntryTests.OrderLifecycle_LinesValidation_ConversionWithDeposit_AndIdempotentRetry`,
`PosFullDayRehearsalTests.FullDay_OrdersInvoicesRefundsSplitTendersCashSessions_Reconcile`.

## Counter sale and tenders

- A sale posts one or more tenders; cash may exceed the balance and records
  change. Non-cash tenders may not exceed the remaining balance.
- Card/manual tenders require an opaque terminal approval reference. The API
  rejects card-number-like references and never stores or returns card data.
- Choose the open drawer session so the sale is attributed to that terminal.
- The invoice snapshots prices, discounts, tax codes, tax totals, tenders, and
  change. Later price or tax changes do not alter the posted document.

Tests: `RetailSaleTests.DirectInvoice_PostsCashChangeInventoryAudit_AndReprintKeepsSnapshots`,
`RetailSaleTests.SplitTender_WithCardReference_AndExactTotals`,
`RetailSaleTests.CardTender_RequiresManualReference_AndNeverStoresCardData`,
`RetailSaleTests.TerminalDeclineAndTimeout_RejectsWithoutPosting`,
`PosConcurrencyTests.ConcurrentTerminalSales_KeepInventoryAndCountersExact`.

## Price overrides and discounts

- A unit price different from the current retail price requires
  `sales:price-override` and a reason.
- A discount above the configured threshold
  (`XOptiApi:PosDiscountThresholdPercent`, default `0` until the signed policy
  is supplied) also requires the permission.
- Unauthorized overrides are rejected with the current price or threshold.
- Authorized overrides write `sales.price-override` or
  `sales.discount-override` audit rows with original value, applied value,
  threshold, actor, branch, and reason.

Tests: `RetailSaleTests.PriceOverrideAndDiscount_RequirePermission_AndAreAudited`.

## Refund and exchange (RS)

1. Load the original invoice by number.
2. Select refundable quantity per line; the API enforces the remaining
   quantity and rejects over-refunds.
3. Choose whether each returned line is restocked.
4. Refunds are allocated back to the original tenders, never beyond the
   remaining amount or a different method.
5. Add replacement lines for an exchange. A positive balance uses the sale
   tender panel; a negative balance is refunded to the original tenders.

Refund tax is taken from the posted original tax, not recalculated. Refunds
reference the original invoice and line, are linked to the drawer session, and
mark the invoice refunded only when every line is fully returned.

Tests: `RetailSaleTests.PartialRefund_OverRefundExchange_AndFullyRefundedStatus`,
`RetailSaleTests.RefundTender_CannotExceedTheOriginalPaymentBalance`,
`CashManagementTests.RefundLinkedToSession_ReducesExpectedCash_AndReconcilesInJournal`.

## Cash drawer

1. Open a drawer for a branch and terminal with the declared float. A terminal
   may have only one open/suspended session.
2. Resume after a break, or suspend before handing over.
3. Record interim counts and paid-in, paid-out, pickup, or deposit movements
   with a reason and destination where applicable.
4. Close with the counted cash. A non-zero variance requires a reason.

Expected cash = opening float + cash tenders + paid-in − paid-out − pickups −
deposits. If blind counting is enabled (`XOptiApi:BlindCashCount`), expected
cash is hidden until a non-opening count is submitted.

Tests: `CashManagementTests.DrawerLifecycle_AssociatesSales_CountsMovements_Close_AndFinalize`,
`CashManagementTests.BlindCount_HidesExpectedUntilACountIsSubmitted`.

## Daily close and journal

1. Close every terminal drawer for the branch and business date.
2. Finalize the day with a reason.
3. Print or review the journal.

Daily close stores sales, refunds, tax, tender totals, cash movements,
expected/counted/variance, session summaries, and affected documents. Finalized
totals are immutable; attempting to finalize again is rejected and requires a
future approved correction workflow. The journal is restricted to
`report:financial`. Branch and terminal separation follows the drawer session.

Tests: `CashManagementTests.DrawerLifecycle_AssociatesSales_CountsMovements_Close_AndFinalize`,
`CashManagementTests.CashJournal_RequiresFinancialPermission`,
`PosFullDayRehearsalTests.FullDay_OrdersInvoicesRefundsSplitTendersCashSessions_Reconcile`.

## Reprints and printing

- Reprints render from posted data without recalculating or mutating the
  document.
- Every print/reprint records actor, branch, terminal, timestamp, document,
  format, and reason.
- Duplicate copies are marked `DUPLICATE COPY — REPRINT` and use a
  `-duplicate.pdf` filename.
- Current layouts: 80 mm receipt and A4 invoice/order. Approved
  customer-specific layouts, claim layouts, physical printer models, and paper
  dimensions are still pending sign-off.

Tests: `RetailSaleTests.Reprint_MarksDuplicate_AuditsActorTerminalAndTime_AndDoesNotMutateTheDocument`,
`PosDocumentRenderingTests.ReceiptLayout_PlanIsGolden_AndUses80mmStock`,
`PosDocumentRenderingTests.DuplicateReprint_IsMarkedAndDiffersFromTheOriginal`.

## Branch and company scope

xOpti is single-company with no tenant columns. Drawer operations are scoped by
branch and terminal; a sale consumes the branch inventory belonging to its
drawer session, and branch journals only include their own sessions and
documents.

Tests: `PosTenantBranchTests.SaleUsesTheDrawerBranchInventory_AndBranchQueriesStaySeparate`.

## Open policy items

- Signed discount threshold, refund, and restock policy.
- Approved card terminal/provider integration (manual reference fallback is
  active).
- Approved receipt, order, and claim layouts; claim data model.
- Printer models, paper sizes, and barcode baseline for on-site printing.
- Approved correction/reopen workflow for finalized daily closes.
