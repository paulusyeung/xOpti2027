# Spec Delta

## Purpose

Defines the administration, validation, search, pricing, numbering, and retirement behavior for the master data every operational module depends on.

## ADDED Requirements

### Requirement: Inventory catalogue administration
The system SHALL let authorized users create, update, retire, and search inventory/SKU records with unique SKU identity and required commercial attributes.

#### Scenario: Duplicate SKU
- **WHEN** a user creates a SKU that already exists, ignoring case and surrounding spaces
- **THEN** the request is rejected with a field-level conflict error
- **AND** no second record is created

#### Scenario: SKU used by stock
- **WHEN** a user retires a SKU that has on-hand stock
- **THEN** the system requires an explicit confirmation and reason
- **AND** the SKU remains readable for history while new sales and purchases are blocked

### Requirement: Supplier, doctor, staff and branch directories
The system SHALL maintain supplier, contact, doctor, staff, and branch directories with required identity fields and uniqueness rules.

#### Scenario: Supplier contact
- **WHEN** a supplier is created with a duplicate supplier code
- **THEN** the create request is rejected
- **AND** the existing supplier is returned for review

#### Scenario: Branch reference
- **WHEN** a user deactivates a branch that owns open transactions
- **THEN** deactivation is blocked until a target branch or closure decision is recorded

### Requirement: Reference data administration
The system SHALL maintain departments, classes, categories, brands, materials, tax methods, payment methods, cities, provinces, and countries with referential safeguards.

#### Scenario: Delete referenced category
- **WHEN** a user attempts to delete a category referenced by inventory
- **THEN** the delete is rejected and the referencing count is reported

#### Scenario: Tax method change
- **WHEN** an authorized user changes a tax method or rate
- **THEN** the change is effective for new transactions only
- **AND** existing posted tax amounts are not recalculated

### Requirement: Pricing and tax setup
The system SHALL maintain retail and wholesale prices and tax assignments with four-decimal money precision and an auditable change history.

#### Scenario: Price change
- **WHEN** a user changes a retail or wholesale price
- **THEN** the new price applies to transactions created after the change
- **AND** an audit entry records the old price, new price, actor, branch, and reason

#### Scenario: Invalid price
- **WHEN** a price has more than four decimal places or a negative value where not allowed
- **THEN** the request is rejected with a validation error

### Requirement: Company preferences and numbering
The system SHALL maintain company, branch, tax, receipt, and control-number preferences required by posting and printing.

#### Scenario: Counter preview
- **WHEN** an authorized user views numbering settings
- **THEN** the next number for each configured family is shown
- **AND** concurrent allocation does not display or consume a duplicate number

#### Scenario: Missing family
- **WHEN** a required transaction family has no counter row
- **THEN** the system reports a configuration error before any posting
- **AND** the user cannot silently allocate a number from another family

### Requirement: Barcode pools and tags
The system SHALL manage barcode pools and generate unique, printable barcode tags for identified SKUs or stock items.

#### Scenario: Duplicate barcode
- **WHEN** a generated or imported barcode already exists in the pool
- **THEN** it is rejected and the conflicting record is identified

#### Scenario: Tag reprint
- **WHEN** a user reprints a tag
- **THEN** the same barcode and label data are reproduced
- **AND** the reprint is audited

### Requirement: Search and pagination
Directory and catalogue queries SHALL support case-insensitive search, stable sorting, and keyset pagination.

#### Scenario: Case-insensitive search
- **WHEN** a user searches for `smith` or `SMITH`
- **THEN** matching names are returned regardless of case and surrounding spaces

#### Scenario: Deep page
- **WHEN** a user requests the next page with a cursor
- **THEN** results are stable and do not repeat or skip records changed before the cursor was issued

### Requirement: Retirement and audit
Records that cannot be physically deleted SHALL be retired with reason and attribution, and every master-data change SHALL be auditable.

#### Scenario: Retirement
- **WHEN** a user retires a referenced record
- **THEN** it is excluded from new selection lists
- **AND** historical references still resolve and display the record

#### Scenario: Audit review
- **WHEN** an administrator reviews a master-data change
- **THEN** the actor, branch, timestamp, before/after values, and reason are available

### Requirement: Bulk import with dry run
Authorized users SHALL be able to import master data from a validated file and preview the outcome before committing.

#### Scenario: Invalid import
- **WHEN** an import file contains a duplicate key or missing required field
- **THEN** the dry run reports row-level errors
- **AND** no records are written

#### Scenario: Successful import
- **WHEN** the dry run has no errors and the user confirms
- **THEN** all valid rows are committed in one transaction
- **AND** the import result records created, updated, skipped, and retired counts
