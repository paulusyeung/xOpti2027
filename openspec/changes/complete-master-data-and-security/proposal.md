# Proposal

## Why

The migrated database contains the legacy master tables, but the application has no way to administer them. Staff, roles, branches, suppliers, doctors, SKUs, categories, prices, tax codes, preferences, and numbering cannot be maintained, so no business module can operate. The current SecurityLevel mapping is also heuristic and can expose cost, margin, or customer PII incorrectly.

## What Changes

- Deliver security administration:
  - Replace the heuristic SecurityLevel mapping with the signed permission matrix from the production baseline.
  - Manage staff accounts, role assignment, branch scope, force-reset, disable/enable, lockout, and session policy.
  - Enforce default-deny permissions, cost visibility (`cost:view`), PII access, and report permissions at handler and endpoint level.
  - Audit security, permission, and account changes with actor, branch, before/after, and reason.
- Deliver master-data management for:
  - Branches, staff, suppliers and contacts, doctors, cities/provinces/countries.
  - Inventory/SKU catalogue including department, class, category, brand, material, supplier, tax code, costing method, lots flag, retail/wholesale flags, and image attachments.
  - Categories, classes, departments, brands, materials, payment methods, tax methods/rates, and preference/company settings.
  - Retail and wholesale pricing, price changes, barcode pools/tags, and control-number settings.
  - Bulk import/export with validation and dry-run for migrated or externally maintained master data.
- Add case-insensitive, indexed search and keyset pagination for all directories.
- Preserve legacy identifiers, add retirement metadata for records that must not be deleted, and keep every change auditable.
- Out of scope: customer records, prescriptions, inventory movements, sales, purchasing, wholesale transactions, and reports.

## Capabilities

### New Capabilities

- `security-administration`: staff identity lifecycle, role/permission administration, branch scoping, forced reset, cost/PII authorization, and security audit.
- `master-data-management`: administration of branches, people, suppliers, inventory/SKU catalogue, reference data, pricing, tax, preferences, numbering, barcodes, search, and data retirement.

### Modified Capabilities

None.

## Impact

- Affected code: new `Application` slices under `Identity`, `Sales`-adjacent master data, `Inventory` catalogue, `Purchasing` supplier directory, and `Reporting` permission hooks; new API endpoints; new Vue administration screens; new EF repositories and mappings for master tables.
- Affected data: existing `public` master tables plus additive `platform` retirement/audit metadata. No destructive legacy schema change.
- Dependencies: existing Identity, EF Core, Npgsql, FluentValidation, Vue/Vuetify, and the signed parity baseline.
- Follow-on changes: inventory/purchasing, POS, customers/prescriptions, wholesale, and reporting depend on this change.
