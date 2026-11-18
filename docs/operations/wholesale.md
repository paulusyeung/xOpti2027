# Wholesale terms, pricing, invoices, returns, and statements

This page is the operator-facing contract for wholesale accounts, pricing,
invoices (WC), returns (WR), packing lists, and statements. Each procedure names
the automated tests that prove it.

## Account and terms

1. Open **Wholesale** and load the customer by id.
2. Record the price grade, terms code and days, credit limit, tax treatment,
   sales representative, and any credit hold.
3. Save with a reason. Account changes are audited.

New wholesale documents require an account and a current price list. A missing
account, missing grade, or a credit hold blocks quoting and posting with a
specific configuration error.

Tests: `WholesaleAccountTests.SaveWholesaleAccount_RecordsTermsAndAudit_AndValidates`,
`WholesaleAccountTests.MissingWholesaleAccount_ReturnsClearConfigurationError`.

## Price lists and overrides

1. Publish a grade (A/B/C) with a code, name, and `SKU,price` items.
2. Every publish creates a new immutable version and makes it current.
3. Existing documents keep the list code, version, and applied price that were
   snapshotted on the line.
4. Import legacy wholesale grades from the migrated `wholesale_price` table when
   the lists have not been published yet.

Changing a line price requires the `sales:price-override` permission and a
reason. The override, list price, list version, actor, and reason are recorded.

Tests: `WholesalePricingTests.PublishedListVersions_SnapshotHistoricalLinePrices`,
`WholesalePricingTests.Override_RequiresPermissionAndReason_AndIsRecorded`,
`WholesalePricingApiTests.PublishQuoteOverrideAndPermissions_WorkThroughTheApi`,
`WholesalePostingTests.Reprint_PreservesOriginalPricesAndIsAudited`.

## Wholesale invoice (WC)

1. Open **Wholesale invoices** and start a new invoice for the customer.
2. Add lines with quantity, optional price, discount, tax code, description, and
   optional backorder quantity. Set shipping method, ship-to, PO, and
   instructions.
3. Add refund/payment intent if required and save the draft. Drafts can be
   updated; totals and line snapshots are recalculated only while draft.
4. Post the invoice. Posting allocates the WC number at draft creation and the
   control number at posting, issues stock through the shared inventory
   service, writes payments, and commits atomically.

If any step fails, the invoice, inventory, control number, and payments roll
back together. Posting is idempotent: replaying the same key returns the same
document without another stock issue.

Tests: `WholesaleInvoiceTests.CreateAndUpdateDraftInvoice_ComputesPricesTaxesShippingAndTenders`,
`WholesaleInvoiceTests.IdempotentCreate_ReplaysAndValidationRejectsBadPaymentsPermissions`,
`WholesalePostingTests.PostInvoice_IssuesInventoryRecordsPaymentsAndReplaysIdempotently`,
`WholesalePostingTests.ForcedFailureDuringPosting_RollsBackInventoryControlNumberPaymentsAndStatus`.

## Backorders and partial fulfilment

Backorders are enabled only when the signed baseline requires them
(`XOptiApi:WholesaleBackordersEnabled`; default **false**).

When enabled, enter the unshipped quantity on the invoice line. The shipped
quantity is invoiced; the remainder is stored as an open backorder with ordered,
shipped, and remaining quantities. When disabled, a partial shipment is rejected.

Tests: `WholesalePostingTests.Backorders_WhenEnabled_TrackRemainingQuantityAndOpenOnPosting`,
`WholesalePostingTests.Backorders_WhenDisabled_RejectPartialShipment`.

## Wholesale return (WR)

1. Open **Wholesale returns** and load the original posted invoice.
2. Select the original lines and enter the return quantity.
3. Choose **restock** or **write-off** (a write-off requires a reason).
4. Save the draft, then post. A return cannot exceed the remaining invoiced
   quantity or credit. Over-returns are rejected with the available quantity.

Posting restores stock only for restock lines, writes any refund tender as a
negative payment, and leaves the remaining credit on the account when no tender
is supplied. Returns reference the original invoice and line and are idempotent.

Tests: `WholesaleReturnTests.CreateAndUpdateReturn_GuardsQuantityAndAmountAndTracksDisposition`,
`WholesaleReturnTests.PostReturn_RestocksInventoryRecordsRefundAndReplaysIdempotently`,
`WholesaleReturnTests.ForcedFailureDuringReturnPosting_RollsBackRestockControlAndPayments`,
`WholesaleReturnTests.WriteOffDisposition_LeavesInventoryAndCreditsCustomerAudibly`.

## Packing lists and price visibility

The packing list is generated from a posted invoice and includes approved lines,
shipped quantity, backordered quantity, ship-to details, PO, and instructions.
Prices are hidden by default. Including prices requires `report:financial`.

Printing and reprinting are audited. The layout is deterministic for the same
projection.

Tests: `WholesaleReportingTests.PackingList_HidesPricesByDefaultAndPrintsWithAudit`,
`WholesaleInvoicePage.test.ts`.

## Balances and statements

The **Wholesale** page shows the customer balance and a period statement.

- Balance = posted invoices + posted returns - net payments.
- The statement shows opening balance, invoices, returns, payments, and closing
  balance with every document and payment line.
- Differences are reported, never silently adjusted.
- Statement printing and reprinting are audited.

Tests: `WholesaleReportingTests.BalanceAndStatement_ReconcileInvoicesReturnsAndPayments`,
`WholesalePage.test.ts`.

## Concurrency and numbering

WC and WR numbers and inventory control numbers are allocated under row locks.
Stock issue/restock locks the SKU row. Return creation locks the original invoice
so concurrent returns cannot exceed the remaining quantity; posting locks the
document so a replay cannot restock or refund twice.

Tests: `WholesaleConcurrencyTests.ConcurrentInvoicesAndReturns_HaveUniqueNumbersExactStockAndNoDoubleCredit`.

## Migrated-data reconciliation

`scripts/wholesale-reconciliation.py` clones the migrated database, posts a known
WC invoice and two WR returns (partial restock and write-off), and compares the
WC/WR counts, totals, control numbers, customer balance, and inventory against
the expected test set. The reference run:

- WC count +1 and total +22.4000
- WR count +2 and total -22.4000
- inventory 10 -> 9 after shipping 2 and restocking 1
- customer balance 0.0000
- three unique control numbers

Prepare the clone the same way as the POS rehearsal: apply app-owned migrations,
record the schema baseline, seed disposable accounts, and start the API against
the clone.

## Open items

- Backorders remain configuration-gated pending the signed baseline decision.
- Packing-list, invoice, return, and statement layouts are implemented and
  audited but remain provisional until the signed wholesale layouts arrive.
- EDI/electronic wholesale ordering is out of scope unless the baseline requires
  it.
