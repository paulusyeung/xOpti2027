# Tasks

## 1. Wholesale account and pricing foundation

- [ ] 1.1 Map wholesale customer, account, term, representative, and price-list tables; verify round-trip tests preserve legacy identifiers and money precision.
- [ ] 1.2 Implement wholesale account setup and terms with credit limit, tax treatment, price list, representative, and audit; verify validation and permission tests.
- [ ] 1.3 Implement wholesale price-list assignment and line pricing with snapshotted list/version and permissioned overrides; verify posted prices do not change after list updates.
- [ ] 1.4 Build wholesale account and price-list screens; verify component tests cover customer terms, price assignment, and overrides.

## 2. Wholesale invoice

- [ ] 2.1 Implement WC invoice create/update with customer, shipping, lines, quantities, prices, discounts, taxes, and payment; verify handler and API tests.
- [ ] 2.2 Implement WC posting with control numbers, shared inventory issue, payments, atomicity, idempotency, and audit; verify a forced failure rolls back all effects.
- [ ] 2.3 Implement invoice reprint data and approved WC layout; verify reprints preserve original values and are audited.
- [ ] 2.4 Implement partial fulfillment/backorders if required by the signed baseline; verify remaining quantities and status are tracked.
- [ ] 2.5 Build wholesale invoice and fulfillment screens; verify Playwright covers invoice creation, partial shipment, and reprint.

## 3. Wholesale return

- [ ] 3.1 Implement WR return creation against original invoice lines with quantity, amount, tax, and credit guards; verify over-return rejection.
- [ ] 3.2 Implement WR posting with shared inventory restoration, payment/credit handling, control numbers, idempotency, and audit; verify atomic rollback.
- [ ] 3.3 Implement return disposition (restock/write-off) with reason and audit; verify inventory and credit reflect the chosen disposition.
- [ ] 3.4 Build wholesale return screens and reprint; verify Playwright covers full and partial returns.

## 4. Packing lists and statements

- [ ] 4.1 Implement packing-list projections from posted or approved wholesale documents; verify quantities, shipping details, and price visibility rules.
- [ ] 4.2 Implement approved packing-list layouts through the reporting port; verify deterministic output and reprint audit.
- [ ] 4.3 Implement wholesale account balance and statement queries from posted invoices, returns, payments, and credits; verify reconciliation.
- [ ] 4.4 Build packing-list and statement actions in the wholesale UI; verify component and Playwright tests.

## 5. Integration and rehearsal

- [ ] 5.1 Reconcile posted WC/WR test documents against migrated wholesale history and inventory; verify differences are explained by the test set.
- [ ] 5.2 Run concurrency tests for wholesale invoice and return posting; verify no duplicate numbers, lost inventory updates, or double credits.
- [ ] 5.3 Run API integration and Playwright suites against PostgreSQL; verify wholesale account, invoice, return, packing list, and statement flows.
- [ ] 5.4 Document wholesale terms, pricing, returns, backorders, and statement procedures; verify the runbook matches automated behavior.

## Workflow follow-up

- Archive this change after wholesale acceptance is signed.
- Ensure reporting changes consume posted wholesale documents and statements.
