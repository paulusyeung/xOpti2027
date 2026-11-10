# Spec Delta

## Purpose

Defines the granular permission vocabulary (replacing the legacy integer `SecurityLevel`) and its enforcement semantics at the application layer, including controlled visibility of cost and margin data and PII.

## ADDED Requirements

### Requirement: Permissions are a stable claim vocabulary
The system SHALL define a closed set of permission claims (including at least `cost:view`, `inventory:adjust`, `report:financial`, `customer:pii`) derived from the Phase 0 permission matrix, and access decisions SHALL be made on these claims rather than on the legacy numeric security level.

#### Scenario: Legacy level is not an authorization input
- **WHEN** an access decision is evaluated
- **THEN** it is made against permission claims and no rule reads the legacy `SecurityLevel` integer

### Requirement: Handlers declare required permissions
Each command or query SHALL declare the permissions it requires, and dispatching without a required permission SHALL fail with an authorization error and no side effects.

#### Scenario: Adjust without permission
- **WHEN** a stock-adjustment command is dispatched by a principal lacking `inventory:adjust`
- **THEN** dispatch is denied and no inventory records change

#### Scenario: Adjust with permission
- **WHEN** the same command is dispatched by a principal holding `inventory:adjust`
- **THEN** the command proceeds to validation and execution

### Requirement: Cost data is hidden without cost visibility
Results of any read that would expose supplier cost or margin SHALL omit those fields when the principal lacks `cost:view`, reproducing the legacy `pyUserHasCostLevel` requirement.

#### Scenario: Inventory listing for a no-cost principal
- **WHEN** a user without `cost:view` queries inventory with cost columns
- **THEN** the returned data contains no cost or margin values

#### Scenario: Inventory listing for a cost-level user
- **WHEN** a user with `cost:view` runs the same query
- **THEN** cost and margin values are present

### Requirement: Customer PII is gated
Reads that return customer contact details beyond the caller's need SHALL require the `customer:pii` permission.

#### Scenario: Prescription lookup without PII permission
- **WHEN** a principal without `customer:pii` retrieves a prescription record
- **THEN** identifying contact fields are withheld or masked in the result
