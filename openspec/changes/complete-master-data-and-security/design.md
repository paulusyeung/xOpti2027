# Design

## Context

See `proposal.md` for motivation. The target schema already contains the legacy master tables (`inventory`, `supplier`, `doctor`, `staff`, `branch`, `category`, `class`, `department`, `brand`, `material`, `tax_method`, `payment_methods`, `preference`, `pref_tx_number`, `bar_code_pool`, `retail_price`, and reference tables). `XOptiDbContext` maps only a small subset. Identity and the permission-claim middleware exist, but the role matrix is hardcoded and untested against the legacy matrix.

## Goals / Non-Goals

**Goals:**
- Make every master record needed by inventory, POS, purchasing, wholesale, and reporting maintainable before those modules start.
- Replace heuristic security with the signed permission matrix.
- Keep legacy identifiers and historical references stable.
- Provide one consistent query, validation, audit, and retirement pattern for administrative slices.

**Non-Goals:**
- Customer, prescription, stock-movement, transaction, or report behavior.
- Redesigning the legacy master tables or replacing natural keys with new surrogates.
- Building a generic metadata-driven CRUD engine.

## Decisions

### Decision: Preserve natural legacy keys and add retirement metadata in `platform`

Master records keep their existing keys (`branch_code`, `sku`, `supplier_code`, `doctor_code`, and so on) because transactions and reports reference them. Physical delete is not exposed. Records that must be retired use an additive `platform.entity_retirement` table keyed by entity type, entity key, branch, reason, actor, and timestamp. Queries filter retired records from selection lists while historical lookups still resolve them.

Alternatives considered: adding `is_deleted` columns to every legacy table. Rejected because those tables are excluded from EF migrations and would create a second, unmanaged schema-change path.

### Decision: One vertical slice per administrative use case

Each command/query gets its own Application slice under the owning module (`Inventory` for SKUs and categories, `Purchasing` for suppliers, `Identity` for staff, and so on), using the existing dispatcher, validation, permission, transaction, and audit pipeline. Shared DTOs are avoided where they would expose cost or PII fields to the wrong caller.

Alternatives considered: one generic `MasterDataController` with dynamic forms. Rejected because validation, permissions, and audit differ per entity and a generic path hides those rules.

### Decision: Signed permission claims replace SecurityLevel at runtime

The startup seeder maps legacy users to Identity accounts and assigns roles from the signed matrix. Permission claims are resolved from roles at sign-in. `SecurityLevel` remains legacy data for traceability but is never consulted for authorization after seeding. Unmapped levels receive no business claims. Cost visibility and PII are explicit permissions, not role-name checks.

Alternatives considered: translating SecurityLevel on every request. Rejected because it keeps an opaque legacy number in the authorization path and makes least privilege hard to prove.

### Decision: Explicit projection rules for sensitive fields

Responses use per-slice DTOs. Cost fields are omitted unless `cost:view` is present. Customer PII is out of scope here, but the same projection mechanism is used by later modules. A shared serializer must never decide redaction implicitly.

Alternatives considered: returning full entities and hiding fields in Vue. Rejected because the API would still leak sensitive data.

### Decision: Case-insensitive normalized search columns plus keyset pagination

Add app-owned generated/normalized search keys in `platform` or use PostgreSQL `lower(unaccent(...))` indexes where the target schema permits. Sort keys are explicit (`name, key`). Cursors encode the last sort key and primary key, not an offset. The exact choice is validated per table against query plans on production-sized data.

Alternatives considered: `ILIKE '%term%'` on unindexed columns. Rejected for the 110k-SKU inventory table and 60k-customer directory.

### Decision: Effective-on-next-transaction pricing with audit history

Current prices remain in the existing price tables; the audit log records old/new values and reason. Posted transactions are never repriced. If the signed baseline requires future-dated prices, add a small app-owned price schedule in `platform` rather than mutating the legacy table.

Alternatives considered: retroactive price updates. Rejected because posted financial documents must remain reproducible.

### Decision: Dry-run bulk import using the same validators

Import reads a streamed file, resolves each row through the same command validators, and writes a row-level result file without committing. Confirmed imports are chunked inside one or more explicit transactions; failures roll back the affected chunk and leave a resumable report.

Alternatives considered: direct SQL `COPY` for imports. Rejected because it bypasses business validation, audit, and permission checks.

## Risks / Trade-offs

- [Legacy natural keys are reused by historical rows] → Never expose hard delete; retirement metadata plus audit preserves history.
- [Search-index choices differ across tables] → Benchmark with production-sized extracts and adjust indexes before release.
- [Permission matrix may be incomplete] → Block module authorization tests until the customer signs the matrix; default deny the rest.
- [Bulk imports can overwhelm the API] → Stream, chunk, cap row counts, and expose progress rather than loading whole files into memory.
- [Price and tax changes can alter reporting] → Apply changes forward only and record effective timestamps so reports can explain historical totals.

## Migration Plan

1. Publish the signed permission matrix and seed roles/claims; verify every legacy account resolves to a role or explicit denial.
2. Map master tables and add retirement metadata; verify historical references still resolve.
3. Deliver read-only directory APIs and screens first, then write slices with audit and validation.
4. Import and reconcile reference data against the migrated database; verify row counts and key coverage.
5. Load-test search and keyset pagination on production-sized data.
6. Enable writes only after permission and audit tests pass.

Rollback: disable write slices and revert to read-only administration; retirement metadata and audit are additive and do not alter migrated rows.

## Open Questions

- Does the signed matrix require future-dated prices or only current prices with audit history?
- Which roles may act across branches versus only their assigned branch?
- Which legacy master records are intentionally obsolete and should be hidden at launch?
