# Spec Delta

## Purpose

Defines the stock receipt, rejection, adjustment, transfer, stock-take, lot, costing, availability, and valuation behavior needed for accurate on-prem optical inventory.

## ADDED Requirements

### Requirement: Stock receipt into lots
An authorized user SHALL receive stock into a branch with a supplier, control number, received date, quantity, and unit cost, creating or updating the matching lot and cost layer.

#### Scenario: Successful receipt
- **WHEN** a stock receipt is posted with valid supplier, SKU, lot, quantity, and cost
- **THEN** the branch on-hand quantity increases by the received quantity
- **AND** a cost layer is created or increased for that lot
- **AND** the receipt is retrievable by its SR control number

#### Scenario: Duplicate submission
- **WHEN** the same idempotency key is submitted twice
- **THEN** the second request returns the original result
- **AND** stock is increased only once

### Requirement: Stock rejection and supplier return
An authorized user SHALL reject or return stock to a supplier, reducing branch on-hand and the matching lot while preserving the original receipt reference.

#### Scenario: Reject received stock
- **WHEN** a rejection is posted for a received lot
- **THEN** quantity is reduced from the same lot and branch
- **AND** the rejection references the original receipt or supplier document
- **AND** the RJ control number is recorded

#### Scenario: Reject more than available
- **WHEN** a rejection exceeds the lot quantity available for rejection
- **THEN** the request is rejected with the available quantity
- **AND** no stock is changed

### Requirement: Stock adjustments
An authorized user SHALL post positive or negative stock adjustments with a reason code, branch, actor, and audit record.

#### Scenario: Negative adjustment
- **WHEN** an approved negative adjustment is posted with a reason
- **THEN** on-hand and the selected cost layer are reduced
- **AND** the variance value and actor are audited

#### Scenario: Adjustment below zero without permission
- **WHEN** a negative adjustment would make available stock negative without the approved deficit permission
- **THEN** the request is rejected and the shortfall is shown

### Requirement: Branch transfers
The system SHALL transfer stock between branches atomically, preserving lot, cost, and movement history.

#### Scenario: Transfer completes
- **WHEN** a transfer is posted
- **THEN** source on-hand decreases and destination on-hand increases by the same quantity
- **AND** both movements reference one transfer identifier

#### Scenario: Transfer fails midway
- **WHEN** the destination update fails
- **THEN** the source decrease is rolled back
- **AND** no partial transfer is visible

### Requirement: Stock take and variance posting
The system SHALL support stock takes from a frozen snapshot, counted-quantity import, variance review, approval, and adjustment posting.

#### Scenario: Count differs from snapshot
- **WHEN** a counted quantity differs from the frozen snapshot and the variance is approved
- **THEN** an SJ adjustment posts the difference with the stock-take reference
- **AND** the variance, approver, and reason are retained

#### Scenario: Unapproved stock take
- **WHEN** a stock take is not approved
- **THEN** no inventory quantity is changed

### Requirement: Lot and deficit tracking
The system SHALL track positive and negative cost layers by SKU, branch, and lot, and SHALL NOT block a sale because on-hand is negative.

#### Scenario: Sale beyond on-hand
- **WHEN** an issue consumes more than available lot quantity
- **THEN** the remaining quantity is recorded as a deficit layer
- **AND** the posting succeeds with the deficit visible to operators

#### Scenario: Receipt covers deficit
- **WHEN** a later receipt arrives for a SKU with a deficit
- **THEN** the deficit is reconciled against the receipt according to the approved policy
- **AND** the remaining positive or deficit quantity is reported

### Requirement: Costing method
The system SHALL value issues by the category's approved FIFO, LIFO, or average method using persistent cost layers and four-decimal money precision.

#### Scenario: FIFO issue
- **WHEN** an issue is posted for a FIFO category
- **THEN** the oldest available layers are consumed first

#### Scenario: LIFO issue
- **WHEN** an issue is posted for a LIFO category
- **THEN** the newest available layers are consumed first

#### Scenario: Average issue
- **WHEN** an issue is posted for an average category
- **THEN** the weighted average of available layers is used
- **AND** the resulting total cost reconciles within the approved tolerance

### Requirement: Availability and valuation
The system SHALL provide branch/SKU/lot availability, movement history, and inventory valuation for authorized users.

#### Scenario: Cost visibility
- **WHEN** a user without cost permission requests valuation
- **THEN** quantity and availability are returned without cost or margin values

#### Scenario: Valuation reconciliation
- **WHEN** valuation is compared with the posted lots and receipts
- **THEN** quantity and cost differences are reported within the approved tolerance

### Requirement: Inventory audit and history
Every inventory-changing operation MUST record actor, branch, timestamp, document reference, reason where applicable, and before/after quantities.

#### Scenario: Movement history
- **WHEN** an operator views a SKU's movement history
- **THEN** receipts, rejections, adjustments, transfers, stock takes, and sales issues are listed chronologically
- **AND** each entry links to its source document
