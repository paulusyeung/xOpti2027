# Proposal

## Why

xOpti has only a `HoldSale` stub. The business cannot take an order, invoice a sale, refund a customer, take payment, or close a cash drawer. POS posting is the highest-risk workflow because it must combine pricing, tax, discounts, inventory costing, control numbers, tenders, receipts, and audit atomically while remaining fast enough for counter use.

## What Changes

- Deliver POS order and sale flow:
  - Create and edit sale orders (SA) with customer, branch, sale person, line items, prices, discounts, taxes, and deposits.
  - Convert an order to a retail invoice (RC) or take a direct counter sale.
  - Refund or exchange against an original invoice (RS) with quantity and amount guards.
  - Reprint invoices, receipts, claims, and order documents without changing data.
  - Search and resume orders in progress and show deposit/balance status.
  - Enforce permissioned price overrides, discounts, cost visibility, and branch scope.
- Deliver payment processing:
  - Support split tenders, cash, debit/credit, configured manual methods, change, and refund tenders.
  - Capture terminal/reference information without storing card data.
  - Keep sale, payment, inventory, and control-number changes in one idempotent transaction.
- Deliver cash management:
  - Open, count, and close cash-drawer sessions by terminal and branch.
  - Record cash movements, opening/closing counts, over/short variance, deposits, and daily close.
  - Produce daily sales, refund, tax, tender, and cash journals for reconciliation.
- Out of scope: wholesale invoices/returns, prescription and insurance claim workflows, report layout implementation, and offline POS.

## Capabilities

### New Capabilities

- `pos-sales`: order entry, sale-order lifecycle, retail invoice/refund posting, discounts, pricing, tax snapshots, document reprints, and posting audit.
- `payment-processing`: tender capture, split payments, change, refunds, terminal references, idempotency, and payment reconciliation.
- `cash-management`: drawer sessions, cash counts, over/short, deposits, daily close, tender totals, and cash journals.

### Modified Capabilities

None.

## Impact

- Affected code: `Application/Sales`, new `Application/Payments` and `Application/Cash`, Infrastructure mappings for `tx_header`, `tx_details`, `tx_payment`, `tx_sale_person`, inventory posting, control numbers, and additive `platform.cash_*` tables; new API endpoints; new Vue POS, payment, and cash screens.
- Affected data: migrated transaction tables and inventory/cost layers; additive cash-session metadata only.
- Dependencies: `complete-master-data-and-security`, `complete-inventory-and-purchasing`, corrected control-number allocation, and approved receipt/claim document rendering.
- Follow-on changes: customer/prescription and insurance claims extend sale lines; wholesale reuses payment and inventory posting; reporting consumes posted totals.
