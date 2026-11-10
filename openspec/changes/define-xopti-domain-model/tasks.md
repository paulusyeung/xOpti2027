# Tasks

## 1. Project scaffolding

- [ ] 1.1 Create `src/xOpti.Domain` as a .NET 10 class library with no package references and add it to `xOpti.sln`, and verify `dotnet build` succeeds.
- [ ] 1.2 Create `tests/xOpti.Domain.Tests` using the same xUnit setup as `tests/xOpti.Migrations.Tests` and wire it into the solution, and verify `dotnet test` passes with one placeholder test.

## 2. Value objects

- [ ] 2.1 Implement `Money` (decimal, 4-dp normalization, deterministic rounding/allocation) and verify unit tests cover precision round-trip, allocation remainder distribution, and rejection of floating-point construction.
- [ ] 2.2 Implement `Quantity` and verify tests assert non-negative constraints for stock contexts and value equality.
- [ ] 2.3 Implement typed identifiers `Sku`, `Lot`, `Rx`, and `ControlNumber` with legacy prefix parsing for RC/RS/SR/RJ/SJ/WC/WR/SA and verify tests cover valid parses, unknown-prefix rejection, and value equality/hashing.
- [ ] 2.4 Implement `TaxCode` (method enum including `N` + rates carrier) and `CostLayer` (source document, unit cost, received/remaining quantity, consumption, deficit representation) and verify tests cover partial consumption, over-consumption rejection on discrete layers, deficit allocation, and layer immutability after failed consumption.

## 3. Business rules

- [ ] 3.1 Implement `TransactionType` with the closed SR/RJ/SJ/RC/RS/WC/WR/SA taxonomy and legacy-code parsing, and verify tests cover every valid code and rejection of unknown codes.
- [ ] 3.2 Implement `TaxCalculator` for methods `N`, `B`, `G`, `P`, `g`, `p` using caller-supplied rates, and verify characterization tests reproduce expected amounts for each method (including `N` yielding 0 tax, and `p` stacking PST on the GST-inclusive base).
- [ ] 3.3 Implement `CostingPolicy` selecting LIFO (category costing method `"2"`), average, and FIFO consumption ordering over `CostLayer` sets, including deficit layer allocation when available quantity is zero or depleted, and verify tests assert consumed-layer selection order, issued unit costs, and deficit tracking for each method.
- [ ] 3.4 Implement `AuditInfo` with created/modified user and branch plus soft-delete-requires-reason-code enforcement, and verify tests cover rejection of reason-less deletes and required attribution on creation.
- [ ] 3.5 Add control-number monotonicity semantics (per-family sequence comparison and validation helpers) and verify tests assert strictly increasing behavior per family and cross-family independence.

## 4. Legacy characterization

- [ ] 4.1 Select representative sample rows (transactions, prices, lots) from the migrated comparison database or `tools/legacy-migration` exports as test fixtures without PII, and verify fixtures are checked in under `tests/xOpti.Domain.Tests/Data`.
- [ ] 4.2 Write characterization tests comparing `TaxCalculator` and `CostingPolicy` outputs against legacy-computed values from the fixtures, and verify the suite passes or explicitly documents unresolved edge cases with `[Skip]` reasons tied to open questions.
