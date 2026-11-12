# Spec Delta

## Purpose

Defines customer identity, contact, PII access, duplicate resolution, account balance, history, and statement behavior for xOpti.

## ADDED Requirements

### Requirement: Customer directory
Authorized users SHALL create, update, search, and view customers with required identity and contact fields.

#### Scenario: Create customer
- **WHEN** a user creates a customer with a valid name and required contact fields
- **THEN** the customer receives a stable identifier
- **AND** the customer can be found by name, phone, email, or account number

#### Scenario: Duplicate candidate
- **WHEN** a new or edited customer matches an existing customer on the approved duplicate signals
- **THEN** the system warns the user and requires confirmation or merge review

### Requirement: PII access control
Customer PII SHALL be visible only to users with the approved permission and every restricted access MUST be audited.

#### Scenario: Unauthorized field access
- **WHEN** a user without customer-PII permission views a customer
- **THEN** protected fields are redacted
- **AND** the response does not include the original values

#### Scenario: Restricted access audit
- **WHEN** a permitted user opens protected customer details
- **THEN** the actor, branch, customer, time, and fields accessed are recorded

### Requirement: Duplicate resolution
Authorized users SHALL merge duplicate customers without deleting historical transactions or prescriptions.

#### Scenario: Merge duplicates
- **WHEN** two customers are merged
- **THEN** one canonical customer remains searchable
- **AND** the merged identity redirects to the canonical record
- **AND** historical documents still resolve to the canonical customer

#### Scenario: Merge conflict
- **WHEN** both customers have conflicting protected identifiers
- **THEN** the merge requires an explicit field choice and reason
- **AND** the decision is audited

### Requirement: Customer accounts and balances
The system SHALL show customer account status, charges, payments, credits, refunds, and current balance from posted documents.

#### Scenario: Balance review
- **WHEN** an authorized user views a customer account
- **THEN** the balance equals posted charges less payments, credits, and refunds within tolerance

#### Scenario: Credit limit
- **WHEN** a sale would exceed the approved customer credit limit
- **THEN** the system warns or blocks according to the signed policy

### Requirement: Purchase and prescription history
The system SHALL provide customer purchase and prescription history with permission-aware projections.

#### Scenario: Purchase history
- **WHEN** a user views a customer's history
- **THEN** invoices, refunds, orders, and claims are listed chronologically
- **AND** each entry links to its source document

#### Scenario: Prescription history
- **WHEN** a user without prescription permission views history
- **THEN** clinical prescription details are omitted

### Requirement: Customer statements
The system SHALL generate customer account statements for a requested period and delivery method.

#### Scenario: Generate statement
- **WHEN** an authorized user generates a statement
- **THEN** opening balance, charges, payments, credits, refunds, and closing balance reconcile to posted documents

#### Scenario: No activity
- **WHEN** the customer has no activity in the period
- **THEN** the system reports no statement or produces an approved zero-activity form

### Requirement: Customer audit
Every customer create, update, merge, retirement, and PII access MUST record actor, branch, timestamp, and before/after values for changed fields.

#### Scenario: Contact change
- **WHEN** a user changes a customer phone number
- **THEN** an audit entry records the old and new values and the actor

#### Scenario: Hard delete attempt
- **WHEN** a user attempts to permanently delete a customer with history
- **THEN** the operation is denied and retirement is offered instead
