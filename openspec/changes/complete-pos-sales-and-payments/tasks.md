# Tasks

## 1. POS data foundation

- [ ] 1.1 Map POS transaction, detail, payment, sale-person, and order-detail tables with money and timestamp converters; verify round-trip tests preserve posted values and legacy identifiers.
- [ ] 1.2 Implement order, invoice, and refund read models with customer, line, tax, payment, deposit, and status projections; verify queries against migrated transactions.
- [ ] 1.3 Add additive `platform.cash_session`, `cash_count`, and `cash_movement` tables through app-owned migrations; verify EF migration SQL contains no legacy table changes.

## 2. Order entry and conversion

- [ ] 2.1 Implement sale-order create/update/cancel commands with line validation, pricing, tax, discount, and sale-person attribution; verify handler and API tests cover valid and invalid orders.
- [ ] 2.2 Implement SA control-number allocation and order search/resume; verify concurrent order creation produces distinct numbers.
- [ ] 2.3 Implement order-to-invoice conversion with deposit application, inventory issue, RC numbering, idempotency, and audit; verify repeated conversion returns the original invoice.
- [ ] 2.4 Build the POS order-entry screen with customer, SKU search, line editing, discount controls, totals, and save/resume; verify component tests and Playwright order flow.

## 3. Retail invoice and refund

- [ ] 3.1 Implement direct retail invoice posting with pricing, tax, discount, inventory costing, tender, and audit; verify a failed payment rolls back all effects.
- [ ] 3.2 Implement invoice lookup and reprint data; verify reprints preserve original prices, taxes, tenders, and document numbers.
- [ ] 3.3 Implement refund/exchange posting with original-line references, refundable balances, restock policy, and RS numbering; verify over-refund is rejected.
- [ ] 3.4 Build the POS invoice and refund screens; verify Playwright covers sale, partial refund, exchange, and reprint.
- [ ] 3.5 Enforce permissioned price overrides and discount thresholds; verify unauthorized overrides are denied and authorized overrides are audited.

## 4. Payments

- [ ] 4.1 Implement tender allocation for cash, card, and configured manual methods including split tender and change; verify totals and remaining balances.
- [ ] 4.2 Implement card-terminal adapter and manual-reference fallback with opaque references; verify no card data is stored, logged, or returned by the API.
- [ ] 4.3 Implement refund tenders linked to original payments and method limits; verify refunds cannot exceed remaining original amounts.
- [ ] 4.4 Require idempotency on sale, order-deposit, and refund payment commands; verify duplicate requests return the original result.
- [ ] 4.5 Build the payment panel and tender selection UI; verify component and Playwright tests cover split tender, decline, timeout, change, and refund.

## 5. Cash management

- [ ] 5.1 Implement drawer open/resume/close with terminal, branch, float, and duplicate-session guards; verify session tests.
- [ ] 5.2 Implement counts, over/short, blind-count policy, paid-in/paid-out, pickups, and deposits; verify expected-cash calculations.
- [ ] 5.3 Implement daily close with terminal completeness, totals by tender, tax, refund, and cash movement; verify finalized totals are immutable.
- [ ] 5.4 Implement the daily sales/refund/tender/cash journal; verify totals reconcile to posted documents.
- [ ] 5.5 Build cash-session, count, movement, deposit, and daily-close screens; verify Playwright covers open, sale, paid-out, close, and variance.

## 6. Documents and printing

- [ ] 6.1 Implement invoice, receipt, order, and claim render data and approved layouts through the document-render port; verify deterministic PDF golden tests.
- [ ] 6.2 Integrate receipt and claim printing on the approved POS client/printer path; verify printed samples match baseline dimensions and barcode encoding.
- [ ] 6.3 Implement reprint audit and duplicate-copy marking; verify each reprint records actor, terminal, document, and time.

## 7. Integration and rehearsal

- [ ] 7.1 Run POS concurrency tests across multiple terminals posting the same SKUs and counters; verify no lost updates, duplicate numbers, or negative cached totals.
- [ ] 7.2 Run a full-day rehearsal against migrated data: orders, invoices, refunds, split tenders, cash sessions, and daily close; verify all totals reconcile.
- [ ] 7.3 Run API integration and Playwright suites against PostgreSQL; verify tenant-free single-company behavior and branch scoping.
- [ ] 7.4 Document POS operator procedures, override policy, refund policy, and end-of-day close; verify the runbook matches automated flows.

## Workflow follow-up

- Archive this change after POS, payments, and cash acceptance is signed.
- Ensure prescription/insurance and wholesale changes extend posted POS documents without mutating them.
