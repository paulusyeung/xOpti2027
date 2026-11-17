# Customer, prescription, optical, and claim operating procedures

This page is the operator-facing contract for customer records, prescription
versioning, optical orders, insurance claims, and RBIC export. Each procedure
names the automated tests that prove it.

## Customer records and duplicates

1. Search by name, phone, email, VIP code, or id.
2. Create or edit the customer with a reason.
3. Possible duplicates are warned before save. Confirm only after review.
4. Merge duplicates from the customer screen: choose the source, canonical
   target, conflicting values, and reason.

Merging leaves the source row in place and writes a
`platform.customer_alias`; all lookups and account/history queries resolve to
the canonical customer. Hard delete is not offered.

Tests: `CustomerTests.CustomerCreateSearchViewPiiAndDuplicateWarning`,
`CustomerTests.CustomerPaginationAndMergeResolveAliasesWithoutDeletingRows`.

## PII and PHI access

`customer:pii` controls contact/identity fields; `prescription:view` controls
clinical data; `prescription:enter` controls clinical writes. Without the
permission, fields are removed before the response leaves the API. PII access,
denial, prescription views, attachment access, and claim changes are audited.

Tests: `PiiAccessTests.ProtectedCustomerPrescriptionAndClaimData_AreNotLeakedWithoutPermission`,
`CustomerPiiAuditTests.PermittedPiiView_RecordsAccessAuditAndReturnsProtectedFields`.

## Prescriptions

1. Open the customer in Prescriptions.
2. Enter spectacle values for both eyes (sphere, cylinder, axis are required)
   or contact-lens values within the accepted ranges.
3. Save with a reason. Every save creates a new immutable version and moves the
   current pointer; prior versions remain visible.
4. Verify the current clinical version with a verifier note.
5. Record medical notes and upload PDF/JPEG/PNG attachments; files are stored
   under the customer namespace with size/type checks.

The verification policy is controlled by
`XOptiApi:RequirePrescriptionVerification`. When enabled, optical conversion is
blocked until the referenced version is verified.

Tests: `PrescriptionTests.PrescriptionVersions_AreImmutable_AndLegacyRowsRemainReadable`,
`PrescriptionTests.VerificationMedicalNotesAndAttachments_AreAuditedAndPermissioned`.

## Optical orders

1. Create or resume a sale order for the customer.
2. Open Optical orders with the SA number.
3. Capture frame, spectacle-lens, and/or contact-lens details, including lab
   instructions and the prescription version used.
4. Advance fulfillment through entered → ordered → received → dispensed. Each
   transition records actor, time, reference, and notes.
5. Conversion is blocked if an optical line has no prescription reference, or if
   the verification policy is on and the referenced version is unverified.

Approved optical details are included in the invoice reprint projection.

Tests: `OpticalOrderTests.OpticalDetails_LinkPrescription_BlockConversionWithoutReference_AndTrackFulfillment`,
`OpticalOrderTests.VerificationPolicy_BlocksUnverifiedOpticalConversion`,
`PosDocumentRenderingTests.OpticalDetails_AreIncludedInTheDocumentPlan`.

## Insurance plans, members, and claims

1. Create a plan version with coverage rules by SKU, category, or a generic rule.
   Each save creates a new current version; claims retain the version used.
2. Assign an eligible member to the customer and plan.
3. Create a claim from an eligible invoice, selecting the invoice lines.
   Duplicate active claims for the same invoice are rejected.
4. Review each line: covered and patient portions are calculated at four
   decimal places; ineligible lines show the reason and remain patient
   responsibility.
5. Adjudicate full or partial approval, reject with a reason, or resubmit a
   rejected claim with a reference. Every action appends a claim event.
6. Record insurer payments up to the remaining approved amount. The claim moves
   to paid when approved and paid agree.

Tests: `ClaimTests.ClaimLifecycle_CoverageAdjudicationRejectionResubmissionAndPayments`,
`ClaimTests.IneligibleLineAndMissingMember_AreRejectedClearly`.

## Claim receipt and RBIC

- Claim receipt data and the PDF are available from the claim detail.
- Reprints are marked duplicate, include the original claim/invoice/plan values,
  and are audited with terminal, actor, and time.
- RBIC export produces a period CSV with billed, covered, patient, approved, and
  paid columns. The export is audited and restricted to `report:financial`.
- Reconciliation reports invoice total, approved amount, paid amount, and the
  remaining difference; differences are reported, never silently adjusted.

Tests: `ClaimTests.ClaimReceiptAndRbicExport_AreAuditedAndPermissioned`,
`ClaimDocumentTests.ClaimReceiptLayout_IsGoldenAndDuplicateMarked`.

## Migrated-data rehearsal

`scripts/optical-claim-rehearsal.py` runs customer → prescription → verified
optical order → converted invoice → claim → approval → payment → receipt/RBIC
against a clone of the migrated legacy database. The reference run produced a
paid claim, invoice 56.00, covered/approved/paid 50.00, branch on-hand 19, and an
RBIC row containing the claim.

Preparation is the same as `scripts/pos-rehearsal.py`: clone the migrated
snapshot, apply app-owned migrations, record the schema baseline, seed disposable
accounts, and start the API against the clone.

## Open items

- The Crystal claim/RBIC reference output is not available in the repository;
  signed-off layout comparison remains **blocked** (task 5.3).
- Insurer-specific rules, EDI submission, and preauthorization workflow are
  configuration/policy decisions; the current plan rules are generic
  percentage/category rules.
