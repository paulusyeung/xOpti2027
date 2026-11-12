# Spec Delta

## Purpose

Defines report catalogue governance, read models, parameterized rendering, permissions, deterministic output, critical documents, reprints, and parity sign-off for xOpti.

## ADDED Requirements

### Requirement: Effective report catalogue
The system SHALL render only reports approved for the Richmond deployment, with one effective layout per logical report.

#### Scenario: Catalogue lookup
- **WHEN** a user opens the report list
- **THEN** each report shows its catalogue ID, purpose, parameters, and required permission
- **AND** superseded or out-of-profile variants are not selectable

#### Scenario: Uncatalogued report
- **WHEN** a report request does not match the signed catalogue
- **THEN** the request is rejected
- **AND** no ad-hoc SQL or layout is exposed

### Requirement: Parameterized report generation
Authorized users SHALL select report parameters, preview the result, print or download a PDF/export, and retain the parameter set used.

#### Scenario: Generate report
- **WHEN** a user supplies valid parameters
- **THEN** the report renders with the approved layout and data
- **AND** the generated document records catalogue ID, parameters, actor, and time

#### Scenario: Invalid parameters
- **WHEN** required parameters are missing or out of range
- **THEN** the request is rejected with field-level errors
- **AND** no empty or partial report is returned

### Requirement: Reporting read models
Reports SHALL read from dedicated reporting views or materialized views rather than joining operational tables directly.

#### Scenario: Reporting view refresh
- **WHEN** a report depends on a refreshed read model
- **THEN** the report shows the read-model as-of timestamp
- **AND** the refresh status is visible to authorized users

#### Scenario: Stale read model
- **WHEN** the read model is older than the approved freshness threshold
- **THEN** the report warns the user or blocks generation according to the catalogue rule

### Requirement: Critical documents
The system SHALL render the critical documents listed in the catalogue, including invoice, order, claim receipt, RBIC, daily cash receipts, sales reports, statements, and tax/HST reports.

#### Scenario: Critical document parity
- **WHEN** a critical document is generated for representative migrated data
- **THEN** its content and totals match the signed Richmond reference within the approved tolerance
- **AND** the comparison evidence is recorded

#### Scenario: Missing critical layout
- **WHEN** a critical document is not signed off
- **THEN** the related go-live gate remains blocked

### Requirement: Report permissions
The system SHALL deny report access without the permission named in the catalogue.

#### Scenario: Financial report
- **WHEN** a user without financial-report permission requests a financial report
- **THEN** the request is denied
- **AND** the attempt is audited

#### Scenario: Cost/margin report
- **WHEN** a user without cost visibility requests a cost or margin report
- **THEN** cost and margin values are not exposed

### Requirement: Deterministic output
Reports SHALL use bundled fonts, fixed locale, fixed time zone, and deterministic layout rules so identical inputs produce reproducible output.

#### Scenario: Golden-file comparison
- **WHEN** the same report is generated twice with the same data and parameters
- **THEN** the PDF content is identical apart from permitted generation metadata
- **AND** the golden-file test passes

#### Scenario: Barcode and label rendering
- **WHEN** a report containing a barcode or label is generated
- **THEN** the approved symbology, size, and quiet zone are used
- **AND** scanning the output resolves the expected value

### Requirement: Large report handling
The system SHALL stream or cap large report listings and SHALL report when output is truncated.

#### Scenario: Row cap reached
- **WHEN** a listing exceeds the catalogue row cap
- **THEN** the output states that it is truncated and includes the applied cap
- **AND** the server does not exhaust memory

#### Scenario: Large PDF
- **WHEN** a large report is generated
- **THEN** the response streams without buffering the entire document in memory

### Requirement: Reprint audit
Every report and document reprint MUST record actor, branch, catalogue ID, parameters, document reference, and time.

#### Scenario: Reprint invoice
- **WHEN** a user reprints an invoice
- **THEN** the original values are reproduced
- **AND** the reprint is distinguishable from the original in the audit trail

#### Scenario: Unauthorized reprint
- **WHEN** a user lacks report or document permission
- **THEN** the reprint is denied and audited

### Requirement: Report parity sign-off
Each catalogue report SHALL have signed-off acceptance evidence before it is marked production-ready.

#### Scenario: Report accepted
- **WHEN** a report matches the reference for approved representative cases
- **THEN** the catalogue records the sign-off, date, and evidence location

#### Scenario: Deferred report
- **WHEN** a report is deferred
- **THEN** the catalogue records customer approval and the operational workaround
