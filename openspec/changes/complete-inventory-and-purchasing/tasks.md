# Tasks

## 1. Posting prerequisites

- [x] 1.1 Correct control-number semantics so a migrated counter and the allocator agree on the next number; verify the first allocation after migration is the expected maximum plus one for every required family.
- [x] 1.2 Add counter coverage and tests for RC, RS, SR, RJ, SJ, WC, WR, and SA; verify a missing family produces a configuration error and never falls back to another prefix.
- [x] 1.3 Map remaining inventory, lot, branch-inventory, stock-take, supplier, and SR/RJ/SJ transaction tables; verify round-trip tests preserve money, quantity, and legacy identifiers.

## 2. Inventory reads

- [x] 2.1 Implement branch/SKU/lot availability and movement-history queries; verify results against migrated inventory and lot records.
- [x] 2.2 Implement inventory valuation with cost visibility rules; verify users without `cost:view` receive quantities without cost or margin.
- [ ] 2.3 Build inventory list, SKU detail, lot, movement, valuation, and exception screens; verify component tests cover loading, forbidden, empty, and large-page states.
- [ ] 2.4 Add keyset pagination and case-insensitive search for inventory queries; verify production-sized query plans and stable deep pages.

## 3. Stock receipt and rejection

- [ ] 3.1 Implement the SR receipt command with control number, supplier, branch, lot, quantity, cost, tax, idempotency, and audit; verify handler and API tests cover success, duplicate submission, and validation failures.
- [ ] 3.2 Implement lot creation/increase and inventory total updates in the same transaction; verify a forced failure leaves both unchanged.
- [ ] 3.3 Implement the RJ rejection/return command with original-document reference and quantity guards; verify over-return is rejected with the available quantity.
- [ ] 3.4 Build receiving and rejection screens including line entry, totals, validation, and reprint; verify Playwright covers a full receive-and-reject flow.

## 4. Adjustments and transfers

- [ ] 4.1 Implement positive/negative SJ adjustments with reason codes, permissions, deficit rules, and audit; verify negative-stock behavior matches the signed baseline.
- [ ] 4.2 Implement branch transfer postings with paired movements and a shared transfer identifier; verify a forced destination failure rolls back the source.
- [ ] 4.3 Add adjustment and transfer screens; verify component tests cover permissions, reasons, validation, and confirmation.
- [ ] 4.4 Add reprints for adjustment and transfer documents; verify reprint output is identical and audited.

## 5. Stock take

- [ ] 5.1 Implement stock-take creation and frozen snapshot; verify snapshot rows match on-hand at freeze time and cannot change while frozen.
- [ ] 5.2 Implement counted-quantity import with row-level validation and dry run; verify invalid rows write nothing and valid rows are resumable.
- [ ] 5.3 Implement variance review and approval; verify unapproved variances do not change inventory.
- [ ] 5.4 Post approved variances as SJ adjustments with stock-take references; verify counts, values, and audit entries reconcile.
- [ ] 5.5 Build stock-take screens for create, count import, variance review, approval, and posting; verify Playwright covers a complete stock take.

## 6. Costing and deficits

- [ ] 6.1 Implement FIFO, LIFO, and average issue consumption against persisted lots; verify characterization tests reproduce legacy cost totals.
- [ ] 6.2 Implement deficit-layer creation and receipt reconciliation; verify negative on-hand never blocks a sale and later receipts reconcile per policy.
- [ ] 6.3 Add category cost-method selection and validation; verify an unsupported or missing method blocks posting with a clear error.
- [ ] 6.4 Add inventory total-versus-lot reconciliation; verify drift is reported with the affected SKU/lot and never silently corrected.
- [ ] 6.5 Rebuild inventory/category/class/department summaries as read models; verify totals match posted documents and migrated values within tolerance.

## 7. Purchasing documents and balances

- [ ] 7.1 Implement supplier receiving document queries, reprints, and supplier activity; verify SR documents reconcile to posted inventory movements.
- [ ] 7.2 Implement supplier rejection/return document queries and payable-relevant totals; verify RJ totals exclude reversed quantities and taxes correctly.
- [ ] 7.3 Implement supplier activity/balance reconciliation from posted documents; verify mismatches report the affected documents.
- [ ] 7.4 Build supplier activity, receiving, and return screens; verify Playwright covers a receive, return, and reprint flow.

## 8. Integration and rehearsal

- [ ] 8.1 Run inventory posting concurrency tests across receipt, adjustment, transfer, and sale-like issue; verify no lost updates or duplicate control numbers.
- [ ] 8.2 Reconcile inventory quantities and valuation against the migrated database after a full posting rehearsal; verify differences are explained by the test posting set.
- [ ] 8.3 Run Playwright and API integration suites for inventory and purchasing against PostgreSQL; verify all critical flows pass.
- [ ] 8.4 Document the inventory/purchasing operating rules, deficit policy, and stock-take freeze procedure; verify the documented steps match the automated tests.

## Workflow follow-up

- Archive this change after inventory and purchasing acceptance is signed.
- Ensure POS and wholesale changes use the posted inventory/costing APIs rather than writing stock directly.
