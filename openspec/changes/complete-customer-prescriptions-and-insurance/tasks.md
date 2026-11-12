# Tasks

## 1. Customer foundation

- [ ] 1.1 Map customer, account, medical, and prescription tables with PII-aware DTOs; verify round-trip tests preserve legacy identifiers and do not expose protected fields by default.
- [ ] 1.2 Implement customer create/update/search/view with duplicate warnings and keyset pagination; verify API and component tests.
- [ ] 1.3 Implement customer PII permissions and access audit; verify unauthorized responses are redacted and permitted access is recorded.
- [ ] 1.4 Implement customer account balance, purchase history, and statement queries; verify totals reconcile to posted invoices, payments, and refunds.
- [ ] 1.5 Implement duplicate merge with alias records and conflict choices; verify merged history resolves to the canonical customer and no legacy row is deleted.
- [ ] 1.6 Build customer directory, detail, account, history, and statement screens; verify Playwright covers create, edit, merge, and statement generation.

## 2. Prescription capture

- [ ] 2.1 Map spectacle and contact-lens prescription versions, medical history, and prescriber links; verify migrated prescriptions remain readable.
- [ ] 2.2 Implement spectacle prescription version creation/amendment with validation, reason, and current pointer; verify old versions remain unchanged.
- [ ] 2.3 Implement contact-lens prescription version creation/amendment with parameter ranges and replacement schedule; verify invalid values are rejected.
- [ ] 2.4 Implement medical-history and attachment upload with file limits, namespace, permission checks, and audit; verify unsupported files and unauthorized access are rejected.
- [ ] 2.5 Implement prescription verification and policy enforcement before order conversion; verify unverified prescriptions are blocked when required.
- [ ] 2.6 Build prescription entry, history, verification, medical-history, and attachment screens; verify component and Playwright tests.

## 3. Optical order details

- [ ] 3.1 Map lens, frame, contact, extra, add, and continuation order-detail tables with sale-order links; verify round-trip tests.
- [ ] 3.2 Implement optical order-detail commands with measurement validation, prescription-version reference, and lab instructions; verify required fields block conversion.
- [ ] 3.3 Implement order fulfillment status events from entered through ordered, received, and dispensed; verify each transition records actor and time.
- [ ] 3.4 Build optical order-entry and fulfillment screens; verify Playwright covers frame/lens/contact entry and status progression.
- [ ] 3.5 Link optical details to POS order/invoice views without mutating posted documents; verify invoice reprint includes approved optical data.

## 4. Insurance plans and claims

- [ ] 4.1 Add `platform.claim`, `claim_line`, `claim_event`, and `claim_payment` tables through app-owned migrations; verify EF migration SQL contains no legacy table changes.
- [ ] 4.2 Implement plan, coverage-rule, member, and eligibility management with versioning; verify claim creation records the plan version used.
- [ ] 4.3 Implement claim creation from an eligible invoice with duplicate guards and line selection; verify ineligible lines and missing member data are handled.
- [ ] 4.4 Implement coverage calculation for insurer/patient portions with four-decimal money and retained inputs; verify approved test vectors.
- [ ] 4.5 Implement adjudication, partial approval, rejection, adjustment, resubmission, and claim events; verify transitions and history.
- [ ] 4.6 Implement claim payments and reconciliation against invoice/customer balances; verify differences are reported and not silently adjusted.
- [ ] 4.7 Build plan, eligibility, claim, adjudication, payment, and reconciliation screens; verify Playwright covers a complete claim lifecycle.

## 5. Claim documents and RBIC

- [ ] 5.1 Add claim-receipt and RBIC data projections from posted claims and invoices; verify totals reconcile within tolerance.
- [ ] 5.2 Implement claim-receipt and RBIC layouts through the reporting port; verify deterministic golden-file output and reprint audit.
- [ ] 5.3 Compare claim-receipt and RBIC output with the Windows/Crystal reference for representative cases; verify signed-off differences are documented.
- [ ] 5.4 Add claim/RBIC export permissions and audit; verify unauthorized users cannot view or export claim data.

## 6. Integration and rehearsal

- [ ] 6.1 Run a customer-to-prescription-to-order-to-claim-to-payment rehearsal against migrated data; verify all documents and balances reconcile.
- [ ] 6.2 Run PII/PHI access tests across every affected endpoint; verify no response leaks protected fields without permission.
- [ ] 6.3 Run API integration and Playwright suites against PostgreSQL; verify customer, Rx, optical order, and claim flows.
- [ ] 6.4 Document customer merge, prescription verification, claim adjudication, and RBIC operating procedures; verify the runbook matches automated flows.

## Workflow follow-up

- Archive this change after customer, prescription, and insurance acceptance is signed.
- Ensure reporting changes use the posted claim/RBIC projections rather than reimplementing calculations.
