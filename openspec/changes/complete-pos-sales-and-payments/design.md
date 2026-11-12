# Design

## Context

See `proposal.md` for motivation. The target schema already models `tx_header`, `tx_details`, `tx_payment`, `tx_sale_person`, sale-order detail tables, and control numbers. The application currently has a stub `HoldSale` command and no POS UI. Inventory posting and control-number fixes are delivered by the preceding changes.

## Goals / Non-Goals

**Goals:**
- Post counter sales, orders, refunds, and payments correctly and quickly.
- Preserve posted prices, taxes, costs, and tender allocations.
- Make retries safe and cash reconciliation explainable.
- Integrate cleanly with later prescription and insurance extensions.

**Non-Goals:**
- Offline POS.
- Storing or processing raw card data.
- Wholesale invoice/return and report layout implementation.
- Replacing the payment terminal provider's own reconciliation.

## Decisions

### Decision: One posting transaction owns header, details, payments, stock, and numbering

The sale/order/refund command allocates the control number, consumes or restores inventory, writes payment rows, and records audit in one PostgreSQL transaction. Any failure rolls back all effects. The API requires an idempotency key; the existing idempotency store reserves the key before the transaction and saves the result after commit.

Alternatives considered: separate sale and payment endpoints. Rejected because a paid invoice must never exist without its tender, and an unpaid tender must never exist without its document.

### Decision: Orders and invoices are linked documents, not mutable statuses

An SA order becomes an RC invoice by creating the invoice and linking it to the order. Deposits remain attached to the order and are applied once at conversion. The order becomes read-only for financial fields after conversion. This avoids rewriting historical documents and makes deposits auditable.

Alternatives considered: changing the order's transaction type in place. Rejected because it loses the order history and complicates control-number and reporting semantics.

### Decision: Snapshot commercial values on posted lines

Each line stores the applied price, discount, tax method, tax rate, and tax amount. Reprints and reports read the snapshot. Later price or tax changes do not recalculate posted documents. Refunds reverse the original line's snapshot unless an approved adjustment is recorded.

Alternatives considered: joining current price/tax tables at print time. Rejected because it changes historical documents.

### Decision: Permissioned overrides are first-class audit events

Discounts and price overrides are validated against thresholds and permissions, then recorded with original value, new value, actor, reason, and branch. Cost fields are omitted unless `cost:view` is present.

Alternatives considered: logging overrides only in application logs. Rejected because financial audit must be queryable with the document.

### Decision: Payments are tender rows, not a single balance field

Each tender is a `tx_payment` row with method, amount applied, change, opaque terminal reference, and original-payment link for refunds. The sale balance is derived from the document total minus applied tenders. Cash sessions aggregate cash tenders and movements.

Alternatives considered: one payment row with a JSON tender list. Rejected because reconciliation and reporting need queryable per-method amounts.

### Decision: Cash sessions are app-owned platform data

Add `platform.cash_session`, `platform.cash_count`, and `platform.cash_movement` keyed by branch, terminal, and session. They reference posted payments but do not alter legacy transaction tables. Finalized sessions and daily closes are immutable; corrections create new audited records.

Alternatives considered: storing cash state in `preference` or summary tables. Rejected because those tables are legacy-shaped and lack session semantics.

### Decision: Receipts use the document-render port; terminal integration stays behind an adapter

POS composes the approved receipt/claim layout through the existing document-render abstraction. Card terminals are integrated through a server-side adapter and/or local device agent, returning an opaque approval reference. The browser never receives card data. If the approved terminal has no usable integration, manual reference capture is supported with an explicit reconciliation flag.

Alternatives considered: direct browser-to-terminal integrations for every device. Rejected because device models and protocols vary and the server must remain the system of record.

## Risks / Trade-offs

- [Concurrent POS terminals contend on counters or inventory rows] → Allocate counters with row locks, lock inventory in deterministic order, and benchmark peak terminal concurrency.
- [Deposits are applied twice during order conversion] → Make conversion idempotent and store the applied deposit reference on the invoice.
- [Refund policy differs by tender and item condition] → Get the signed refund/restock policy before enabling refunds.
- [Payment terminal integration slips] → Keep manual-reference capture as a supported fallback and flag those tenders for reconciliation.
- [Receipt layout is not ready] → Block POS go-live on approved receipt/claim layouts, not just data posting.
- [Cash variance is used to hide theft or error] → Require reasons, immutable closes, and permissioned corrections with audit.

## Migration Plan

1. Correct numbering and map POS transaction/payment tables.
2. Implement read-only order/invoice/refund lookup and reprints.
3. Implement order entry and direct invoice posting behind a feature flag.
4. Add payment capture and cash sessions; test split tenders and rollback.
5. Validate receipt/claim output and terminal behavior on the approved POS client.
6. Run a full day-close rehearsal against a copy of migrated data.
7. Enable POS for pilot terminals, then all terminals.

Rollback: disable POS posting and return to read-only lookup; void unposted drafts only. Posted documents are corrected by reversal, never deletion.

## Open Questions

- Which payment terminals and integration protocols are approved?
- What are the signed refund, restock, and discount-threshold policies?
- Does the sale-order workflow require layaway, expiry, or cancellation rules not present in the baseline?
- Which receipt and claim layouts must be available on day one?
