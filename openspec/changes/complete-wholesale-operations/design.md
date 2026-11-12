# Design

## Context

See `proposal.md` for motivation. The legacy system posts wholesale invoices and returns through the same `tx_header`/`tx_details`/`tx_payment` model using WC and WR prefixes and has wholesale price tables. The POS and inventory changes provide the posting transaction, cost-layer consumption, payments, control numbers, and document-render foundations. Wholesale must reuse those services rather than create a second posting engine.

## Goals / Non-Goals

**Goals:**
- Serve wholesale customers with correct pricing, credit, shipping, and returns.
- Reuse POS/inventory/payment services so stock and financial totals stay consistent.
- Produce packing lists and statements from posted data.
- Keep wholesale documents auditable and reprintable.

**Non-Goals:**
- EDI/electronic ordering unless the signed baseline requires it.
- Retail POS changes or prescription/insurance claims.
- Full report-layout parity beyond wholesale documents, packing lists, and statements.
- Separate inventory or payment implementations.

## Decisions

### Decision: Wholesale is a document workflow on the shared posting engine

WC and WR commands use the same transaction, inventory, payment, control-number, audit, and idempotency building blocks as POS. Differences are pricing source, terms, shipping fields, document layouts, and approval rules, not a separate ledger.

Alternatives considered: a separate wholesale inventory/payment subsystem. Rejected because it would double-count stock and break reconciliation.

### Decision: Price list assignment is explicit and snapshotted

Each wholesale customer has an assigned price list. A line stores the list/version and applied price. Customer-specific overrides are permissioned and audited. Later price-list changes never reprice posted documents.

Alternatives considered: resolving the current price at print time. Rejected because it changes historical invoices.

### Decision: Returns reference the original invoice line

WR lines store the original invoice/line and can only consume remaining invoiced quantity and amount. Credits and inventory restoration follow the signed return policy. Returns without a resolvable original require an approved exception workflow.

Alternatives considered: free-standing credit notes. Rejected because over-crediting and inventory errors become hard to detect.

### Decision: Backorders are line-level remainder records

If the baseline requires partial fulfillment, the unshipped quantity is recorded as a backorder linked to the original order/invoice line. Fulfillment creates a new document for the remainder and updates the backorder status. If the baseline does not require backorders, the feature remains disabled by configuration.

Alternatives considered: silently dropping unshipped quantity. Rejected because customer obligations would be lost.

### Decision: Shipping and packing data are document fields, not a separate shipment subsystem

Store shipping method, address, instructions, and packing status on the wholesale document and optional app-owned shipment metadata. Packing lists derive from posted lines. A full warehouse-management system is out of scope.

Alternatives considered: a shipment aggregate with its own inventory reservations. Rejected as unnecessary for single-company wholesale.

### Decision: Statements reuse the account-statement projection

Wholesale statements use the customer ledger projection with wholesale documents and terms. They do not duplicate balance calculations in the reporting layer.

Alternatives considered: report-specific SQL. Rejected because balances would diverge between screens and documents.

## Risks / Trade-offs

- [Wholesale credit terms differ by customer] → Use signed account terms and enforce credit limits at posting, with permissioned overrides.
- [Returns may be restocked or written off] → Make the policy explicit and record the chosen disposition per line.
- [Backorders can create duplicate fulfillment] → Link backorder fulfillment to the original line and make it idempotent.
- [Packing-list prices may leak to recipients] → Use an approved layout that omits prices unless explicitly required.
- [Wholesale customers overlap with retail customers] → Use account type/terms rather than a separate customer table; preserve history.
- [Pricing changes mid-order] → Snapshot prices on lines and revalidate only unposted drafts.

## Migration Plan

1. Map wholesale account, price, and customer-term data from the migrated schema.
2. Deliver read-only wholesale invoices, returns, balances, and statements.
3. Implement WC posting with shared inventory/payment services behind a feature flag.
4. Implement WR returns, packing lists, and backorders if required.
5. Reconcile posted wholesale totals against migrated WC/WR history.
6. Enable pilot wholesale accounts, then all accounts.

Rollback: disable wholesale posting and return to read-only lookup; posted documents are reversed, never deleted.

## Open Questions

- Does the signed baseline require backorders/partial fulfillment?
- Which wholesale price lists, customer-specific overrides, and credit terms are in scope?
- Are packing lists printed, emailed, or both?
- Is EDI/electronic ordering required for any wholesale customer?
