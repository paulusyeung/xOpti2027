# Proposal

## Why

The legacy system includes substantial wholesale invoicing and return workflows (`frmWholesaleInvoice.frm`, `frmWholesaleReturn.frm`, 2,100+ lines each), including packing lists, wholesale pricing, and returns. xOpti currently supports neither, so wholesale customers cannot be served and the WC/WR transaction history has no operational replacement.

## What Changes

- Deliver wholesale account and pricing support:
  - Identify wholesale customers, accounts, credit terms, tax treatment, and sales representatives.
  - Maintain wholesale price lists and customer-specific price assignments.
- Deliver wholesale documents:
  - Create, post, void/reverse, and reprint wholesale invoices (WC) with line items, quantities, prices, discounts, taxes, shipping, and payments.
  - Create, post, and reprint wholesale returns (WR) against original invoices with quantity and credit guards.
  - Generate packing lists and shipping documents.
  - Support backorders/partial fulfillment where the signed baseline requires them.
  - Track invoice, payment, credit, and return balances per wholesale customer.
- Reuse the POS payment, inventory, control-number, audit, and document-render foundations rather than duplicating posting logic.
- Produce wholesale statements and activity history for reconciliation.
- Out of scope: retail POS behavior, prescription/insurance claims, and report-layout parity beyond wholesale documents, packing lists, and statements.

## Capabilities

### New Capabilities

- `wholesale-sales`: wholesale accounts, price lists, invoices, returns, packing lists, backorders, credit balances, statements, and document posting.

### Modified Capabilities

None.

## Impact

- Affected code: new `Application/Wholesale` slices, mappings for wholesale customer/price tables and WC/WR transaction rows, reuse of inventory/payment services, new API endpoints and Vue wholesale screens.
- Affected data: existing `tx_header`, `tx_details`, `tx_payment`, wholesale price, customer account, and inventory tables; additive metadata only where required.
- Dependencies: `complete-master-data-and-security`, `complete-inventory-and-purchasing`, `complete-pos-sales-and-payments`, and the signed baseline.
- Follow-on changes: reporting consumes wholesale documents and statements.
