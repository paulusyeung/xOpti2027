# Spec Delta

## Purpose

Defines wholesale accounts, pricing, invoices, returns, packing lists, backorders, credit balances, statements, and document posting for xOpti.

## ADDED Requirements

### Requirement: Wholesale account setup
Authorized users SHALL identify wholesale customers and maintain their account, credit terms, tax treatment, price list, and sales representative.

#### Scenario: Assign wholesale terms
- **WHEN** a customer is approved as wholesale
- **THEN** the account records terms, credit limit, price list, tax treatment, and representative
- **AND** wholesale pricing is available on new documents

#### Scenario: Missing terms
- **WHEN** a wholesale invoice is started without required terms
- **THEN** posting is blocked with the missing configuration

### Requirement: Wholesale pricing
The system SHALL apply the customer's assigned wholesale price list and permissioned overrides to invoice lines.

#### Scenario: Assigned price list
- **WHEN** a line is added to a wholesale invoice
- **THEN** the assigned wholesale price is used
- **AND** the applied price list and version are recorded on the line

#### Scenario: Unauthorized override
- **WHEN** a user without wholesale override permission changes a price
- **THEN** the request is denied and the original price remains

### Requirement: Wholesale invoice
Authorized users SHALL create and post wholesale invoices (WC) with customer, shipping, line items, quantities, prices, discounts, taxes, payments, and control numbers.

#### Scenario: Post invoice
- **WHEN** a valid WC invoice is posted
- **THEN** a unique WC number is allocated
- **AND** inventory is issued and customer balance updated atomically
- **AND** the invoice is reprintable

#### Scenario: Partial fulfillment
- **WHEN** the signed baseline supports backorders and only part of a line ships
- **THEN** the shipped quantity is invoiced
- **AND** the remaining quantity is retained as a backorder with status

### Requirement: Wholesale return
Authorized users SHALL post wholesale returns (WR) against original invoices with quantity, amount, tax, and credit guards.

#### Scenario: Return against invoice
- **WHEN** a valid WR is posted
- **THEN** it references the original invoice and line
- **AND** credit and inventory are adjusted once
- **AND** a unique WR number is allocated

#### Scenario: Over-return
- **WHEN** a return exceeds the remaining invoiced quantity or amount
- **THEN** the request is rejected with the available balance

### Requirement: Packing and shipping documents
The system SHALL generate packing lists and shipping documents from posted or approved wholesale documents.

#### Scenario: Packing list
- **WHEN** a user prints a packing list
- **THEN** it shows the approved lines, quantities, shipping details, and document reference
- **AND** it does not expose prices unless the approved layout includes them

#### Scenario: Reprint
- **WHEN** a document is reprinted
- **THEN** the original data is reproduced and the reprint is audited

### Requirement: Wholesale balances and statements
The system SHALL track invoice, payment, credit, return, and outstanding balances per wholesale customer and generate statements.

#### Scenario: Account balance
- **WHEN** an authorized user views a wholesale account
- **THEN** balance equals invoices less payments, credits, and returns within tolerance

#### Scenario: Statement
- **WHEN** a statement is generated for a period
- **THEN** opening balance, invoices, returns, payments, credits, and closing balance reconcile to posted documents

### Requirement: Wholesale posting atomicity and audit
Every wholesale invoice, return, payment, and override MUST commit or roll back as one transaction and record actor, branch, timestamp, and document references.

#### Scenario: Payment failure
- **WHEN** payment capture fails during WC posting
- **THEN** invoice, inventory, control number, and payment are all rolled back

#### Scenario: Audit review
- **WHEN** an auditor reviews a wholesale document
- **THEN** pricing, discounts, returns, payments, and approvals are visible
