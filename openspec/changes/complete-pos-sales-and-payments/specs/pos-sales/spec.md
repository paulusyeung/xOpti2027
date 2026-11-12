# Spec Delta

## Purpose

Defines counter order entry, sale-order conversion, retail invoicing, refunds, pricing, discounts, tax snapshots, reprints, and posting audit for xOpti POS.

## ADDED Requirements

### Requirement: Sale order entry
An authorized user SHALL create and edit a sale order with customer, branch, sale person, line items, quantities, prices, discounts, taxes, and deposits.

#### Scenario: Valid order
- **WHEN** a user saves a sale order with valid lines
- **THEN** the order receives an SA control number
- **AND** it can be found by customer, number, or status
- **AND** inventory is not consumed until invoicing

#### Scenario: Invalid quantity
- **WHEN** a line has a zero or negative quantity not permitted by the document type
- **THEN** the request is rejected with a field-level error
- **AND** the order is not saved

### Requirement: Order to invoice conversion
The system SHALL convert an approved sale order into a retail invoice, consume inventory, allocate an RC control number, and apply deposits without double counting.

#### Scenario: Convert with deposit
- **WHEN** an order with a deposit is invoiced for the full balance
- **THEN** the invoice shows the order reference, total, deposit applied, and balance due
- **AND** only the outstanding balance is tendered
- **AND** inventory is issued once

#### Scenario: Repeated conversion
- **WHEN** the same order conversion is retried with the same idempotency key
- **THEN** the original invoice is returned
- **AND** no second invoice or inventory issue is created

### Requirement: Direct retail invoice
An authorized user SHALL take a direct counter sale without a prior sale order.

#### Scenario: Direct invoice
- **WHEN** a user posts a direct retail invoice with valid lines and payment
- **THEN** an RC control number is allocated
- **AND** inventory cost layers are consumed by the configured costing method
- **AND** the invoice is immediately reprintable

### Requirement: Retail refund and exchange
The system SHALL post refunds or exchanges against an original invoice with quantity, amount, tax, and tender guards.

#### Scenario: Partial refund
- **WHEN** a user refunds less than the original invoiced quantity
- **THEN** the refund references the original invoice and line
- **AND** the refundable balance decreases by exactly the refunded amount
- **AND** returned stock is recorded per the approved restock policy

#### Scenario: Over-refund
- **WHEN** a refund exceeds the remaining refundable quantity or amount
- **THEN** the request is rejected with the available balance
- **AND** no payment or inventory change occurs

### Requirement: Discounts and price overrides
The system SHALL apply configured discounts and SHALL require the approved permission and reason for manual price overrides.

#### Scenario: Authorized override
- **WHEN** an authorized user overrides a line price
- **THEN** the override, reason, actor, and original price are audited

#### Scenario: Unauthorized discount
- **WHEN** a user exceeds the permitted discount threshold
- **THEN** the request is denied with the threshold
- **AND** the line remains at the permitted price

### Requirement: Tax and price snapshots
Posted lines MUST retain the price, tax method, tax rate, discount, and tax amounts used at posting.

#### Scenario: Later price change
- **WHEN** a SKU price or tax rate changes after an invoice is posted
- **THEN** reprinting and reporting the invoice show the original posted values

#### Scenario: Refund after tax change
- **WHEN** a refund is posted after a tax change
- **THEN** the refund reverses the original tax treatment unless an approved adjustment is recorded

### Requirement: Document reprints
The system SHALL reprint invoices, receipts, claims, and sale orders from posted data without mutation.

#### Scenario: Receipt reprint
- **WHEN** a user reprints a receipt
- **THEN** the same document number, lines, totals, taxes, and payment details are rendered
- **AND** the reprint is audited

#### Scenario: Claim reprint
- **WHEN** a user reprints a claim document
- **THEN** the approved claim layout and original data are reproduced

### Requirement: Posting atomicity and audit
Every sale, conversion, refund, and override MUST commit or roll back as one transaction and record actor, branch, terminal, timestamp, and document references.

#### Scenario: Payment fails
- **WHEN** payment capture fails after lines are staged
- **THEN** the invoice, inventory issue, control number, and payment are all rolled back

#### Scenario: Audit review
- **WHEN** an auditor reviews a posted sale
- **THEN** the actor, branch, terminal, price overrides, discounts, and refunds are available
