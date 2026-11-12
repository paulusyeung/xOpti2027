# Proposal

## Why

The legacy system stores customer demographics, medical history, spectacle and contact-lens prescriptions, optical order details, and insurance/claim information, but xOpti exposes none of it. POS can sell a generic line item, yet an optical retailer cannot safely capture, verify, version, or fulfill a prescription, or produce the claim and RBIC documents the business depends on.

## What Changes

- Deliver customer records:
  - Maintain customer demographics, contacts, addresses, account/AR status, notes, and communication preferences.
  - Restrict and audit customer PII access.
  - Detect and resolve duplicate customers without destroying historical references.
  - Provide account balances, statements, purchase history, and customer search.
- Deliver prescription and optical order management:
  - Capture spectacle prescriptions (OD/OS sphere, cylinder, axis, add, prism, base, PD, notes) with prescriber, date, expiry, and verification status.
  - Capture contact-lens prescriptions including brand, base curve, diameter, power, cylinder, axis, and replacement schedule.
  - Capture medical history and attach supporting documents.
  - Keep prescription versions immutable and mark the current clinical version.
  - Capture lens, frame, contact, and extra order details, measurements, lab instructions, and order status through fulfillment.
  - Validate prescription expiry and required measurements before optical order conversion.
- Deliver insurance and claim support:
  - Record insurance plans, coverage rules, member information, and eligibility notes.
  - Create claims from invoices and optical order lines, calculate covered/patient portions, and record approvals, adjustments, and rejections.
  - Generate the approved claim receipt and RBIC workbook data.
  - Track claim status, resubmission, and reconciliation with payments.
- Out of scope: POS posting changes, report layout parity beyond the claim/RBIC documents, and wholesale transactions.

## Capabilities

### New Capabilities

- `customer-records`: customer directory, PII access, duplicate resolution, account balances, statements, and purchase history.
- `prescription-management`: spectacle and contact-lens prescriptions, medical history, document attachments, versioning, verification, optical order details, and fulfillment status.
- `insurance-claims`: insurance plans, coverage and eligibility, claim creation and adjudication, patient/insurer portions, claim receipts, RBIC data, and claim reconciliation.

### Modified Capabilities

None.

## Impact

- Affected code: `Application/Customers`, `Application/Prescriptions`, new claim slices; mappings for `customer*`, `customer_accounts`, `customer_medical`, `customer_pres_*`, `tx_s_order_*`, `tx_sale_person`, and additive `platform.claim_*` metadata; new API endpoints and Vue customer, Rx, order, and claims screens.
- Affected data: existing customer/prescription/order tables plus additive claim/attachment metadata. Historical documents remain immutable.
- Dependencies: `complete-master-data-and-security`, `complete-pos-sales-and-payments`, and approved claim/RBIC layouts.
- Follow-on changes: reporting consumes prescription, claim, and RBIC data; wholesale remains separate.
