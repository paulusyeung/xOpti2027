# Spec Delta

## Purpose

Defines spectacle and contact-lens prescriptions, medical history, attachments, versioning, verification, optical order details, and fulfillment status.

## ADDED Requirements

### Requirement: Spectacle prescription capture
Authorized users SHALL capture and maintain spectacle prescriptions with OD/OS values, prescriber, issue date, expiry, and verification status.

#### Scenario: Valid prescription
- **WHEN** a user saves a spectacle prescription with required values for each eye
- **THEN** the prescription is stored as a new immutable version
- **AND** it becomes the current clinical version

#### Scenario: Missing required eye value
- **WHEN** a required value is missing for an eye
- **THEN** the save is rejected with the specific field
- **AND** no partial version is stored

### Requirement: Contact-lens prescription capture
Authorized users SHALL capture contact-lens prescriptions with brand, base curve, diameter, power, cylinder, axis, and replacement schedule where applicable.

#### Scenario: Contact lens version
- **WHEN** a contact-lens prescription is saved
- **THEN** it is stored as an immutable version linked to the customer and prescriber
- **AND** previous versions remain retrievable

#### Scenario: Invalid lens parameter
- **WHEN** a parameter is outside the approved range or missing
- **THEN** the save is rejected with the field and accepted range

### Requirement: Prescription versioning and current pointer
Prescription changes SHALL create new versions and SHALL NOT overwrite historical clinical data.

#### Scenario: Amend prescription
- **WHEN** a user amends an existing prescription
- **THEN** a new version is created with the reason and actor
- **AND** the previous version remains unchanged

#### Scenario: Historical order
- **WHEN** an order linked to an older version is viewed
- **THEN** it displays the values used at order time

### Requirement: Medical history and attachments
Authorized users SHALL record medical history, notes, and supporting documents with PII controls.

#### Scenario: Attachment upload
- **WHEN** a user uploads an approved document type
- **THEN** the file is stored under the customer/prescription namespace
- **AND** access requires the approved prescription permission

#### Scenario: Unsupported file
- **WHEN** a file type or size exceeds the approved limits
- **THEN** the upload is rejected without storing the file

### Requirement: Prescription verification
The system SHALL record whether a prescription has been verified, by whom, when, and any verification note.

#### Scenario: Verified prescription
- **WHEN** an authorized user marks a prescription verified
- **THEN** the version records verifier, time, and note
- **AND** the status is visible on order creation

#### Scenario: Unverified prescription policy
- **WHEN** the signed policy requires verification before order conversion
- **THEN** conversion is blocked until verification is recorded

### Requirement: Optical order details
Authorized users SHALL capture lens, frame, contact, and extra order details, measurements, lab instructions, and fulfillment status.

#### Scenario: Frame and lens order
- **WHEN** an optical order is saved with frame, lens, and measurement details
- **THEN** all line details link to the sale order and prescription version used
- **AND** required measurements are validated before conversion

#### Scenario: Order status progression
- **WHEN** an order moves from entered to ordered, received, and dispensed
- **THEN** each transition records actor, time, and applicable reference

### Requirement: Prescription and order audit
Every prescription, medical-history, attachment, and order-detail change MUST record actor, branch, timestamp, and before/after values where applicable.

#### Scenario: Clinical audit
- **WHEN** an auditor reviews a prescription change
- **THEN** all versions, verifier actions, and order links are visible

#### Scenario: Unauthorized clinical change
- **WHEN** a user without prescription permission attempts a change
- **THEN** the operation is denied and recorded
