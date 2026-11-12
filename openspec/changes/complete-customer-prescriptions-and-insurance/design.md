# Design

## Context

See `proposal.md` for motivation. The migrated schema already has `customer`, `customer_accounts`, `customer_medical`, `customer_pres_contact`, `customer_pres_lens`, multiple `tx_s_order_*` tables, and claim-related legacy fields. The current application maps only a minimal customer entity. POS posting is delivered by the preceding change and exposes sale-order detail extension points.

## Goals / Non-Goals

**Goals:**
- Make optical prescribing, order capture, and insurance claims usable and auditable.
- Preserve clinical and financial history through immutable versions and posted documents.
- Keep PII/PHI access tightly permissioned and auditable.
- Produce claim/RBIC documents from the same posted data used by reporting.

**Non-Goals:**
- Replacing the POS or inventory posting engine.
- Electronic data interchange with insurers unless the signed baseline requires it.
- Full report layout parity beyond claim receipt and RBIC outputs.
- Storing card or payment credentials.

## Decisions

### Decision: Customers use legacy numeric identity plus merge aliases

Keep the migrated customer identifier for historical references. A merge creates a `platform.customer_alias` mapping from the retired identifier to the canonical customer. Transactions are not rewritten. Lookup resolves aliases to the canonical record; audit preserves the merge decision.

Alternatives considered: repointing all historical transactions. Rejected because it destroys the historical identity and increases cutover risk.

### Decision: Prescriptions are immutable versions with a current pointer

Each creation or amendment writes a new version row with reason, actor, and timestamp. A current-version marker on the customer/prescription family points to the active clinical version. Orders store the version used. Previous versions are never edited.

Alternatives considered: updating one prescription row. Rejected because clinical and claim history must remain reproducible.

### Decision: Optical order details extend the sale order, not a parallel order

Use the existing `tx_s_order_*` tables linked to the sale-order header. Lens/frame/contact/extra lines reference posted POS sale lines where applicable. Measurements and lab instructions are stored with the order details and validated before conversion. Fulfillment status transitions are recorded as order events.

Alternatives considered: a separate optical-order domain disconnected from sales. Rejected because billing, inventory, and claims need one document chain.

### Decision: PII/PHI protection is enforced at the API projection and storage boundary

Per-slice DTOs omit protected fields without permission. Attachments use the existing file-storage port with a customer/prescription namespace and permission checks. Logs redact identifiers and clinical values. Database backups are encrypted through the production-operations change.

Alternatives considered: hiding fields in the SPA. Rejected because the API would still expose data.

### Decision: Claims are app-owned records linked to posted invoices

Add `platform.claim`, `platform.claim_line`, `platform.claim_event`, and `platform.claim_payment` tables. Claim rows reference posted invoices and order details; coverage rules are versioned configuration. Adjudication and payments append events rather than overwriting history. Claim receipts and RBIC exports read the posted claim/invoice values.

Alternatives considered: storing claim state only in legacy fields. Rejected because the legacy model lacks a clear claim lifecycle, event history, and reconciliation.

### Decision: Claim documents are generated through the reporting port

The claim receipt and RBIC workbook use the approved QuestPDF/reporting layouts and deterministic values. POS/reporting do not duplicate layout logic. If the target profile requires an EDI file, it is produced by a dedicated adapter with a signed format specification.

Alternatives considered: bespoke HTML/PDF code in the claims module. Rejected because report parity and golden-file tests need one rendering path.

### Decision: Duplicate detection is advisory before merge

Use normalized name plus phone/email/address signals. The system warns and requires review; it never auto-merges. Merge conflicts require explicit field selection and audit.

Alternatives considered: automatic merges based on fuzzy matching. Rejected because incorrect medical/customer merges are irreversible in practice.

## Risks / Trade-offs

- [Legacy prescription fields are incomplete or inconsistent] → Profile migrated values and define required fields from the signed baseline before enabling validation.
- [Claim rules vary by insurer and change over time] → Version plan/coverage configuration and record the version used per claim.
- [PHI appears in attachments or logs] → Enforce file-type/size limits, redact logs, audit access, and encrypt backups.
- [Duplicate merge chooses the wrong record] → Require human review, field-level conflict choices, and alias-based rollback.
- [RBIC/claim layout is not in the report catalogue] → Block claim go-live until the catalogue lists and signs these documents.
- [Insurance EDI is required late] → Keep claim data model and document adapter separate so an EDI adapter can be added without rewriting adjudication.

## Migration Plan

1. Map customer, medical, prescription, order-detail, and account tables; profile required fields.
2. Deliver read-only customer, prescription history, order, and claim lookup.
3. Implement customer create/update/merge with PII permissions and audit.
4. Implement prescription versioning, attachments, verification, and optical order details.
5. Implement plan, claim, adjudication, payment, and reconciliation records.
6. Generate and sign off claim receipt and RBIC outputs against the Windows reference.
7. Enable write workflows behind permissioned feature flags.

Rollback: disable clinical/claim writes and retain read-only history; additive claim/alias tables can be dropped without touching legacy records.

## Open Questions

- Which insurer plans, coverage rules, and claim formats are in scope for launch?
- Is EDI submission required, or are printed/exported claims sufficient?
- Which prescription fields are mandatory for each document type?
- What is the approved duplicate-merge policy for protected identifiers?
