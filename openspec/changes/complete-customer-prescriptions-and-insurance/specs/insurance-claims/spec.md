# Spec Delta

## Purpose

Defines insurance plans, eligibility, claim creation, adjudication, patient/insurer portions, claim documents, RBIC data, and reconciliation for xOpti.

## ADDED Requirements

### Requirement: Insurance plan and member data
Authorized users SHALL record insurance plans, coverage rules, member identifiers, and eligibility notes for a customer.

#### Scenario: Assign plan
- **WHEN** a user assigns an insurance plan with valid member data
- **THEN** the customer's coverage is available when creating a claim
- **AND** the plan version used is recorded

#### Scenario: Missing member data
- **WHEN** required member data is missing
- **THEN** claim creation is blocked with the missing fields

### Requirement: Claim creation from invoice
Authorized users SHALL create a claim from an eligible invoice and optical order, selecting covered lines and coverage rules.

#### Scenario: Eligible claim
- **WHEN** a claim is created from an invoice with a valid plan
- **THEN** the claim records the invoice, customer, plan, lines, billed amounts, and coverage calculations

#### Scenario: Duplicate claim
- **WHEN** a claim already exists for the same invoice and coverage period
- **THEN** the request is rejected or requires an approved resubmission reason

### Requirement: Coverage calculation
The system SHALL calculate the insurer and patient portions using the approved coverage rules and SHALL retain the calculation inputs.

#### Scenario: Covered amount
- **WHEN** a claim is calculated
- **THEN** the covered and patient portions equal the approved rule applied to eligible line amounts
- **AND** rounding follows the signed money rule

#### Scenario: Ineligible line
- **WHEN** a line is not covered
- **THEN** it is assigned to the patient portion with the reason

### Requirement: Claim adjudication
Authorized users SHALL record approval, partial approval, rejection, adjustment, and resubmission with reasons and references.

#### Scenario: Partial approval
- **WHEN** an insurer approves less than claimed
- **THEN** the system records the approved amount, adjustment reason, and resulting patient balance

#### Scenario: Rejection
- **WHEN** a claim is rejected
- **THEN** the status, reason, and next action are visible
- **AND** a permitted user can resubmit with a new reference

### Requirement: Claim receipt and RBIC data
The system SHALL generate the approved claim receipt and RBIC workbook data from posted claim and invoice values.

#### Scenario: Claim receipt
- **WHEN** a user prints a claim receipt
- **THEN** the approved layout shows the original invoice, patient, plan, covered amount, and patient portion
- **AND** the reprint is audited

#### Scenario: RBIC export
- **WHEN** an authorized user exports RBIC data for a period
- **THEN** the output reconciles to posted claims and invoices within tolerance

### Requirement: Claim reconciliation
The system SHALL reconcile claim approvals and insurer payments against the customer and claim balances.

#### Scenario: Insurer payment
- **WHEN** an insurer payment is recorded
- **THEN** the claim balance decreases by the applied amount
- **AND** the remaining patient responsibility is updated

#### Scenario: Reconciliation difference
- **WHEN** claim, payment, or invoice totals differ outside tolerance
- **THEN** the difference is reported with the affected documents and is not silently adjusted

### Requirement: Claim audit
Every plan, eligibility, claim, adjudication, payment, and resubmission change MUST record actor, branch, timestamp, and before/after values.

#### Scenario: Claim audit trail
- **WHEN** an auditor reviews a claim
- **THEN** plan data, calculation inputs, submissions, decisions, payments, and documents are visible in order

#### Scenario: Unauthorized claim change
- **WHEN** a user without claim permission attempts a change
- **THEN** the operation is denied and recorded
