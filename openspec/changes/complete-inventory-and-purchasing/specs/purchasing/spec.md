# Spec Delta

## Purpose

Defines supplier receiving, rejection/return, cost capture, payable-relevant totals, document reprints, and activity reconciliation for xOpti purchasing.

## ADDED Requirements

### Requirement: Supplier receiving document
An authorized user SHALL create a supplier receiving document with SR numbering, supplier, branch, line items, quantities, costs, taxes, and received dates.

#### Scenario: Post receiving
- **WHEN** a valid receiving document is posted
- **THEN** SR control numbers are allocated uniquely
- **AND** inventory lots and supplier activity are updated atomically
- **AND** the document can be retrieved by number

#### Scenario: Missing supplier or cost
- **WHEN** a line lacks a valid supplier or required cost
- **THEN** the document is rejected with field-level errors
- **AND** no stock or payable total changes

### Requirement: Supplier rejection and return document
An authorized user SHALL create a supplier rejection/return document with RJ numbering that references the original receipt or supplier document where available.

#### Scenario: Return with reference
- **WHEN** a return is posted against a receipt
- **THEN** the returned quantity cannot exceed the original received quantity less prior returns
- **AND** the RJ document references the receipt

#### Scenario: Return without reference
- **WHEN** a legacy return has no resolvable receipt
- **THEN** the system requires an explicit exception reason and approver
- **AND** the exception is retained for audit

### Requirement: Supplier costs and payable totals
The system SHALL record supplier line cost, tax, and document totals in four-decimal money precision and SHALL expose payable-relevant activity to authorized users.

#### Scenario: Document totals
- **WHEN** a receiving document is posted
- **THEN** line and document totals equal the sum of posted quantities, costs, and taxes within the approved tolerance

#### Scenario: Unauthorized cost view
- **WHEN** a user without cost or payable permission views supplier documents
- **THEN** cost and payable fields are omitted

### Requirement: Reprints and labels
The system SHALL reprint supplier receiving, rejection, and stock labels from posted documents without changing data.

#### Scenario: Reprint receiving
- **WHEN** a user reprints a posted receiving document
- **THEN** the same document number, lines, quantities, and costs are rendered
- **AND** the reprint is audited

#### Scenario: Label reprint
- **WHEN** a user reprints a stock label
- **THEN** the same barcode, SKU, lot, and quantity data are reproduced

### Requirement: Supplier activity reconciliation
The system SHALL provide supplier activity and balance reconciliation from posted receiving, rejection, and return documents.

#### Scenario: Supplier balance review
- **WHEN** an authorized user reviews a supplier's activity for a period
- **THEN** receipts, returns, taxes, and net payable-relevant totals are shown

#### Scenario: Reconciliation mismatch
- **WHEN** calculated supplier activity differs from the migrated supplier summary outside tolerance
- **THEN** the mismatch is reported with the affected documents
- **AND** the user cannot silently overwrite the summary

### Requirement: Purchasing audit
Every purchasing change MUST record actor, branch, timestamp, document reference, and before/after values where an update occurs.

#### Scenario: Amendment
- **WHEN** an authorized user amends an unposted purchasing document
- **THEN** an audit entry records the changed lines and values

#### Scenario: Posted document protection
- **WHEN** a user attempts to amend a posted receiving or return document
- **THEN** the system requires a reversal or correction document instead of an in-place edit
