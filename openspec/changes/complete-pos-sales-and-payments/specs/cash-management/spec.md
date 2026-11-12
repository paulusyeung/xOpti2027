# Spec Delta

## Purpose

Defines cash-drawer sessions, counts, over/short, deposits, daily close, tender journals, and cash audit for each branch and POS terminal.

## ADDED Requirements

### Requirement: Drawer session lifecycle
The system SHALL open, suspend, resume, and close a cash-drawer session for an authorized branch and terminal.

#### Scenario: Open drawer
- **WHEN** an authorized operator opens a drawer with a declared float
- **THEN** the session records branch, terminal, actor, opening time, and opening float
- **AND** sales on that terminal are associated with the session

#### Scenario: Duplicate open session
- **WHEN** an operator tries to open a second session for the same terminal
- **THEN** the request is rejected or requires the existing session to be closed first

### Requirement: Cash counts and variance
The system SHALL record opening, interim, and closing cash counts and SHALL calculate over/short against expected cash.

#### Scenario: Closing count differs
- **WHEN** the closing count differs from expected cash
- **THEN** the system records the variance and requires a reason
- **AND** the variance is visible on the close report

#### Scenario: Blind count
- **WHEN** the approved policy requires a blind count
- **THEN** the expected amount is hidden from the operator until the count is submitted

### Requirement: Cash movements
The system SHALL record paid-in, paid-out, pickup, and deposit movements with reason, actor, and timestamp.

#### Scenario: Paid-out
- **WHEN** an authorized user records a cash paid-out
- **THEN** expected cash decreases by the amount
- **AND** the movement is audited

#### Scenario: Deposit
- **WHEN** cash is deposited from a session
- **THEN** the deposit records the amount, destination reference, actor, and time
- **AND** the session expected cash reflects the removal

### Requirement: Daily close
The system SHALL produce a daily close for a branch and date showing sales, refunds, taxes, discounts, tenders, cash movements, over/short, and deposit totals.

#### Scenario: Completed close
- **WHEN** an authorized user closes the business day
- **THEN** the close can be finalized only after all terminals are closed or explicitly accounted for
- **AND** the finalized totals are immutable

#### Scenario: Reopen finalized close
- **WHEN** a user attempts to reopen a finalized day
- **THEN** the system requires an approved correction workflow and records the reason

### Requirement: Cash and sales journal
The system SHALL provide a printable journal of posted sales, refunds, tenders, taxes, and cash movements by branch, terminal, and date.

#### Scenario: Journal totals
- **WHEN** a user prints or exports a daily journal
- **THEN** document counts and totals reconcile to posted transaction and payment records within tolerance

#### Scenario: Restricted access
- **WHEN** a user without cash or financial reporting permission requests a journal
- **THEN** the request is denied

### Requirement: Cash audit
Every cash session, count, movement, close, and correction MUST record actor, branch, terminal, timestamp, and before/after values.

#### Scenario: Audit trail
- **WHEN** an auditor reviews a cash session
- **THEN** opening float, counts, movements, sales tenders, deposits, variance, and close are visible in order

#### Scenario: Unauthorized adjustment
- **WHEN** a user without the approved permission attempts to alter a finalized count or close
- **THEN** the operation is denied and recorded
