# Tasks

## 1. Security administration foundation

- [x] 1.1 Replace `RolePermissionMatrix` with the signed `PERM-*` matrix loaded from a versioned configuration file; verify the matrix test asserts every approved permission and default denial for unmapped levels.
- [x] 1.2 Extend staff seeding to map every legacy `Security`/`Staff` account to an Identity user and role without carrying legacy passwords; verify a seeded account cannot authenticate with the legacy password and can complete forced reset.
- [x] 1.3 Implement staff lifecycle commands (create, disable, re-enable, force reset, role change, branch scope); verify handler tests cover authorization, validation, audit, and session invalidation.
- [x] 1.4 Implement cost/PII-aware response projections; verify API integration tests omit cost and PII fields for users without `cost:view` or the corresponding PII permission.
- [x] 1.5 Add security audit entries for account, role, permission, and branch-scope changes; verify entries include actor, branch, target, before/after, reason, and cannot be edited by normal users.

## 2. Security administration API and UI

- [x] 2.1 Add versioned API endpoints for staff, roles, permissions, branch scope, and account reset; verify OpenAPI contract generation and permission policies.
- [x] 2.2 Build Vue administration screens for staff, roles, permissions, branch scope, and forced-reset status; verify component tests cover loading, forbidden, validation, and save states.
- [x] 2.3 Add Playwright coverage for an admin creating a staff account, assigning a role, forcing reset, and disabling the account; verify the effects on session access.

## 3. Reference data

- [x] 3.1 Map and expose branches, cities, provinces, countries, departments, classes, categories, brands, materials, tax methods, and payment methods; verify read-only directory tests return migrated records.
- [x] 3.2 Implement create/update/retire commands with uniqueness, referential checks, and audit for each reference type; verify duplicate and referenced-record failures are field-specific.
- [x] 3.3 Build the reference-data administration screens with search, keyset pagination, and retirement reason capture; verify component and API tests cover query and mutation paths.
- [x] 3.4 Implement supplier, supplier-contact, doctor, and branch directories; verify required fields, uniqueness, and branch deactivation safeguards.

## 4. Inventory catalogue and pricing

- [x] 4.1 Map the inventory, retail-price, wholesale-price, and barcode-pool tables and define per-slice DTOs; verify round-trip tests preserve money precision and legacy keys.
- [x] 4.2 Implement SKU create/update/retire with required attributes, uniqueness, costing method, tax code, lot flag, and branch behavior; verify validation and permission tests.
- [x] 4.3 Implement retail/wholesale price updates with forward-only effect and audit history; verify posted transactions are unchanged after a price change.
- [x] 4.4 Implement barcode pool and tag generation/reprint; verify duplicate barcode rejection and identical reprint output.
- [x] 4.5 Build SKU, pricing, and barcode administration screens; verify component tests cover search, edit, price change, retire, and tag reprint.

## 5. Preferences, numbering and imports

- [ ] 5.1 Map and expose company/branch preferences and control-number settings; verify all 13 legacy counter rows are visible and required families cannot be removed.
- [ ] 5.2 Implement preference updates with audit and permission checks; verify changes apply to new transactions only.
- [ ] 5.3 Implement dry-run and confirmed master-data import for SKUs, suppliers, and reference data; verify invalid rows write nothing and confirmed imports report created/updated/skipped/retired counts.
- [ ] 5.4 Add import screens with progress and error-report download; verify a failed chunk is resumable and no partial row is silently accepted.

## 6. Search, retirement and audit

- [ ] 6.1 Add case-insensitive search indexes or normalized keys for inventory, suppliers, doctors, staff, and branches; verify query plans and result parity on production-sized extracts.
- [ ] 6.2 Implement keyset pagination for all directory/catalogue queries; verify deep-page tests do not repeat or skip records.
- [ ] 6.3 Add `platform.entity_retirement` and filter retired records from selection lists; verify historical references still resolve and new transactions cannot select retired records.
- [ ] 6.4 Verify every master-data mutation emits one allow-listed audit entry with no secrets or unnecessary PII.

## 7. Integration and migration reconciliation

- [ ] 7.1 Reconcile master-data API counts and keys against the migrated `public` tables; verify inventory, supplier, doctor, staff, branch, category, and reference counts match.
- [ ] 7.2 Run permission-matrix tests across every administrative endpoint; verify no endpoint is accessible without its named permission.
- [ ] 7.3 Run Playwright and API integration suites against PostgreSQL; verify administration flows work end to end with realistic migrated data.

## Workflow follow-up

- Archive this change after security, master data, and import acceptance is signed.
- Update dependent module changes with any baseline ID or schema changes discovered here.
