# Spec Delta

## Purpose

Defines how xOpti captures, allocates, reverses, and reconciles tenders for sales, orders, refunds, and cash operations without storing card data.

## ADDED Requirements

### Requirement: Tender capture
The system SHALL capture one or more tenders for a sale, order deposit, or refund using configured payment methods.

#### Scenario: Single tender
- **WHEN** a user tenders the full sale amount by cash or card
- **THEN** the payment is recorded against the document
- **AND** the remaining balance is zero

#### Scenario: Split tender
- **WHEN** a user pays with multiple methods
- **THEN** the system records each tender separately
- **AND** the sum of applied tenders equals the amount paid

### Requirement: Change and overpayment
The system SHALL calculate change for cash tenders and SHALL reject overpayment for non-cash tenders unless the method permits it.

#### Scenario: Cash overpayment
- **WHEN** cash tendered exceeds the balance
- **THEN** the system records the applied amount and computes change
- **AND** change is visible on the receipt and cash journal

#### Scenario: Card overpayment
- **WHEN** a card tender exceeds the remaining balance
- **THEN** the request is rejected with the permitted amount

### Requirement: Payment terminal references
The system SHALL store an opaque terminal or processor reference for card tenders and MUST NOT store card numbers, security codes, or track data.

#### Scenario: Approved terminal payment
- **WHEN** the terminal reports approval
- **THEN** the payment stores the method, amount, timestamp, and opaque reference
- **AND** no card data is persisted or logged

#### Scenario: Declined terminal payment
- **WHEN** the terminal reports decline or timeout
- **THEN** no payment is recorded as approved
- **AND** the sale remains unpaid or is cancelled according to the operator's choice

### Requirement: Refund tenders
The system SHALL refund through approved methods without exceeding the original tender allocation or approved store policy.

#### Scenario: Refund to original method
- **WHEN** a refund is posted against a card sale within policy
- **THEN** the refund tender references the original payment and terminal

#### Scenario: Refund over original
- **WHEN** a refund tender exceeds the remaining original amount for that method
- **THEN** the request is rejected with the available amount

### Requirement: Payment idempotency and atomicity
Payment commands MUST require an idempotency key and MUST commit payment, document status, inventory, control number, and cash movement together.

#### Scenario: Duplicate payment request
- **WHEN** the same payment request is retried
- **THEN** the original result is returned
- **AND** no duplicate tender is posted

#### Scenario: Posting failure
- **WHEN** any part of the document posting fails
- **THEN** no tender is left applied to an unposted document
- **AND** no cash movement is recorded

### Requirement: Payment reconciliation
The system SHALL reconcile recorded tenders against sales, refunds, and cash-session totals by method and period.

#### Scenario: Daily tender totals
- **WHEN** a user reviews a daily close
- **THEN** cash, card, and other method totals equal posted tenders less refunds

#### Scenario: Reconciliation difference
- **WHEN** recorded tenders differ from the expected document totals
- **THEN** the difference is reported with the affected documents and is not silently adjusted
