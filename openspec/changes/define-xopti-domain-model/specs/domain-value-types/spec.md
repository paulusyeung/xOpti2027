# Spec Delta

## Purpose

Defines the shared, framework-free value types (money, quantities, identifiers, cost layers, prescriptions, control numbers) that every xOpti layer uses to represent optical retail data without loss of precision or invariants.

## ADDED Requirements

### Requirement: Money uses fixed decimal semantics
All monetary amounts SHALL be represented as decimal values with a scale of four decimal places (matching `numeric(19,4)`), and the system SHALL NOT use binary floating-point types for money.

#### Scenario: Money round-trip preserves precision
- **WHEN** a `Money` value is created from `1234.5678`
- **THEN** the value compares equal to `1234.5678` with no rounding loss

#### Scenario: Floating point is rejected
- **WHEN** code attempts to construct `Money` from a `double`
- **THEN** no such implicit path exists and the compile fails

### Requirement: Money arithmetic is deterministic
`Money` addition, subtraction, comparison, and percentage operations SHALL be decimal-based, and multiplication or allocation SHALL produce deterministic rounding with a documented remainder rule.

#### Scenario: Allocating a total across lines
- **WHEN** a total of `100.00` is allocated across three lines
- **THEN** the allocated amounts sum exactly to `100.00` and the remainder distribution is deterministic

#### Scenario: Rounding at display scale
- **WHEN** a `Money` amount is rounded to two decimal places for display
- **THEN** the rounding mode is an explicit domain parameter, not ambient floating-point behavior

### Requirement: Domain identifiers are typed value objects
`Sku`, `Lot`, `ControlNumber`, and `Rx` SHALL be distinct typed value objects with validation of their legacy-derived formats, SHALL provide value equality, and SHALL NOT be interchangeable.

#### Scenario: Control number prefix validation
- **WHEN** a `ControlNumber` is parsed from `RC000123`
- **THEN** parsing succeeds and the type and sequence parts are retrievable

#### Scenario: Unknown transaction prefix rejected
- **WHEN** a `ControlNumber` is parsed from `XX000123`
- **THEN** parsing fails with a validation error

#### Scenario: Value equality
- **WHEN** two `Sku` instances are created from the same string
- **THEN** they compare equal and hash equal

### Requirement: Cost layer captures unit cost and remaining quantity
A `CostLayer` SHALL carry source document, unit cost (`Money`), received quantity, and remaining quantity; individual positive layers SHALL reject consumption below zero remaining quantity, while the costing domain model SHALL support explicit deficit layer representation to prevent POS checkout blocking on un-receipted stock.

#### Scenario: Consuming beyond the layer
- **WHEN** a consumption of 5 units is applied to a positive layer with 3 remaining
- **THEN** direct consumption on that discrete layer is rejected and the layer is unchanged

#### Scenario: Partial consumption
- **WHEN** a consumption of 2 units is applied to a layer with 5 remaining
- **THEN** the layer reports 3 remaining and the consumed quantity equals 2

#### Scenario: Deficit layer tracks un-receipted sales
- **WHEN** a sale is posted with no available positive cost layers
- **THEN** a deficit cost layer is produced with negative or zero balance at standard/fallback cost, enabling post-receiving reconciliation

### Requirement: Quantities and lot identity are explicit
`Quantity` SHALL be a decimal value object distinct from money, and `Lot` SHALL bind a quantity to a lot identifier and its supplier/receipt provenance.

#### Scenario: Lot quantity never negative
- **WHEN** a `Lot` adjustment would drive its quantity below zero
- **THEN** the domain rejects the adjustment
