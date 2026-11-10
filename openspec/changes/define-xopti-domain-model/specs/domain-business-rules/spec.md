# Spec Delta

## Purpose

Preserves the legacy eOptical business semantics that migrated data depends on: the transaction type taxonomy, the five tax calculation methods, inventory costing order (LIFO/average/FIFO), and record-level audit and soft-delete invariants.

## ADDED Requirements

### Requirement: Transaction types are a closed taxonomy
Every posted transaction SHALL carry one of the legacy transaction types `SR` (stock received), `RJ` (stock rejected), `SJ` (stock adjustment), `RC` (retail invoice), `RS` (retail refund), `WC` (wholesale invoice), `WR` (wholesale return), or `SA` (sale order), and the domain SHALL reject any other code.

#### Scenario: Valid type accepted
- **WHEN** a transaction is typed `RC`
- **THEN** the type resolves to the retail invoice semantics

#### Scenario: Unknown type rejected
- **WHEN** a transaction is typed `ZZ`
- **THEN** the domain rejects it with a validation error

### Requirement: Tax methods follow legacy calculation rules
The domain SHALL implement the legacy tax methods: `N` (tax exempt/excluded), `B` (GST + PST), `G` (GST only), `P` (PST only), `g` (GST included in price), and `p` (PST applied on top of GST), computing tax amounts from line price, quantity, and tax rates.

#### Scenario: Method N produces zero tax
- **GIVEN** an exempt line priced `100.00`
- **WHEN** tax is calculated with method `N`
- **THEN** GST is `0.00`, PST is `0.00`, and the gross total is `100.00`

#### Scenario: Method B adds both taxes
- **GIVEN** a line priced `100.00` with GST 5% and PST 8%
- **WHEN** tax is calculated with method `B`
- **THEN** GST is `5.00`, PST is `8.00`, and the gross total is `113.00`

#### Scenario: Method g extracts included GST
- **GIVEN** a line priced `105.00` with GST 5% marked as included
- **WHEN** tax is calculated with method `g`
- **THEN** the extracted GST is `5.00` and the net is `100.00`

#### Scenario: Method p stacks PST on GST
- **GIVEN** a line priced `100.00` with GST 5% and PST 8%
- **WHEN** tax is calculated with method `p`
- **THEN** PST is computed on the GST-inclusive base of `105.00`, yielding `8.40`

### Requirement: Costing method determines cost-layer consumption order
Inventory issues SHALL consume cost layers in the order defined by the category costing method: LIFO when the category costing method is `"2"`, otherwise average or FIFO, and every issue SHALL reference the layers it consumed.

#### Scenario: LIFO category consumes newest layer first
- **GIVEN** a SKU in a category with costing method `"2"` and layers received oldest-to-newest at costs `10`, `12`, `14`
- **WHEN** 3 units are issued with 3 available in the newest layer
- **THEN** the issued cost is `14.00` per unit from the newest layer

#### Scenario: Average category blends cost
- **GIVEN** a category whose costing method is not `"2"` with mixed remaining layers
- **WHEN** units are issued
- **THEN** the issued unit cost is the weighted average of remaining layers

#### Scenario: Deficit issue allows POS completion
- **GIVEN** a category with zero remaining layer quantity
- **WHEN** units are issued for a retail sale
- **THEN** the issue succeeds using standard/fallback unit cost and flags a deficit layer for reconciliation

### Requirement: Financial and inventory changes are attributable
Every domain record subject to audit SHALL carry created/last-modified user and branch attribution, and deletion SHALL be a soft delete that requires a reason code.

#### Scenario: Soft delete requires reason
- **WHEN** a record is marked deleted without a reason code
- **THEN** the domain rejects the operation

#### Scenario: Attribution present on write
- **WHEN** a sale or inventory adjustment record is created
- **THEN** user and branch identifiers are present and non-empty

### Requirement: Control numbers are typed per transaction family
Control number allocation semantics SHALL be defined per transaction family (`RC`, `RS`, `SR`, `RJ`, `SJ`, `WC`, `WR`, `SA`) with monotonically increasing sequence behavior and legacy-compatible prefixed formats.

#### Scenario: Sequence never goes backwards
- **WHEN** two successive control numbers are requested for family `RC`
- **THEN** the second number is strictly greater than the first for that family
