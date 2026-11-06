# xOpti Migration Notes

Working notes for rewriting the legacy **eOptical VI 6.1.184** VB6 desktop application as a modern web application named **xOpti**.

See `README.md` for the legacy system analysis.

## Locked Decisions

| Decision | Choice |
| --- | --- |
| Deployment / tenancy | Single company, on-premises |
| POS connectivity | Online-only (no offline mode required) |
| Report scope | Full parity with the legacy reports |
| Report profile | Richmond customer overlay (confirmed) |
| Cutover | Hard cutover, full history migrated |
| Runtime | .NET 10 LTS (not .NET 8 - .NET 8 support ends 10 Nov 2026) |
| Frontend | Vue 3 + Vuetify 3 |
| Backend | ASP.NET Core 10 + EF Core 10 + Npgsql 10 |
| Database | PostgreSQL (manually migrated) |
| Documents | QuestPDF |
| OLAP / analytics | WebPivotTable v7 web component in `xOpti.Web` (replaces DynamiCube/`dcube.ocx`) |

## Target Architecture

### Runtime topology (on-prem)

`docker-compose` on a Linux host:

| Service | Purpose |
| --- | --- |
| `postgres:17` | Primary database; WAL archiving plus nightly `pg_dump`/`pgBackRest` backups and retention |
| `api` | ASP.NET Core 10 API; EF migrations run as a separate one-shot job, never on startup |
| `web` | Built Vue SPA served by nginx, reverse-proxying `/api` to the API |
| `caddy` | TLS termination and internal CA for the LAN |
| optional observability | Seq or Loki/Grafana for logs |
| file volume | `/var/lib/xopti/files` for generated PDFs and attachments |

Single-tenant means no tenant columns and no row-level security. Keep authentication simple but strong: ASP.NET Core Identity with same-origin HttpOnly cookie auth and CSRF protection, since the SPA and API share an origin. Add session expiry and lockout.

### Solution layout

```
xOpti.sln
  src/
    xOpti.Api                   ASP.NET Core 10, versioned Minimal APIs
    xOpti.Domain                Entities, value objects (Money, TaxCode, Rx, Sku, Lot, CostLayer)
    xOpti.Application           Vertical slices, command/query handlers, validators, DTOs
    xOpti.Infrastructure        EF Core 10, Npgsql, Identity, QuestPDF, file storage, jobs
    xOpti.Migrations            EF migrations and seed
  tests/
    xOpti.Domain.Tests
    xOpti.Application.Tests
    xOpti.Api.IntegrationTests     Testcontainers PostgreSQL
    xOpti.Reports.Tests            QuestPDF golden-file tests
  web/
    xOpti.Web                      Vue 3 + TypeScript + Vuetify 3 + Vite + Pinia
  tools/
    legacy-migration               MDB -> legacy schema -> transform -> app schema
  docker/
```

Use a **modular monolith**, not microservices. Enforce module boundaries through project references and namespaces. Organize the application layer as vertical slices per module: `Sales`, `Inventory`, `Purchasing`, `Customers`, `Prescriptions`, `Wholesale`, `Reporting`, `Identity`.

### Backend conventions

- API versioning under `/api/v1`, `ProblemDetails`, `FluentValidation`, request/response DTOs, keyset pagination, and a global exception handler.
- Generate the TypeScript API client from OpenAPI and run contract checks in CI.
- PostgreSQL types: `numeric(19,4)` for money (never floating point), `timestamptz` for time, `snake_case` naming (`EFCore.NamingConventions`), `xmin` as the optimistic concurrency token.
- One explicit transaction per POS/inventory posting.
- **Idempotency keys** on sale, invoice, and payment endpoints for safe retries.
- Auth: ASP.NET Core Identity; re-hash or force-reset legacy passwords, never migrate them as-is.
- Replace the legacy integer `SecurityLevel` and `pyUserHasCostLevel` with roles plus granular permission claims such as `cost:view`, `inventory:adjust`, `report:financial`, `customer:pii`.
- Audit log for financial and inventory changes; soft delete with reason codes; user and branch attribution on every record.

### Persistence: redesign, do not copy

The legacy design writes transactions and then re-derives denormalized summary tables in `AppOLTP.bas` (`InvtSummary`, `CategorySummary`, `ClassSummary`, `DeptSummary`, `SupplierSummary`, `PaymentSummary`).

In the rewrite:

- Write only to normalized core tables.
- Derive summaries through views or materialized views (refreshed on schedule or concurrently).
- Remove the dual-write posting subsystem entirely.
- Use a separate `analytics` schema/star model or a BI tool for OLAP; do not carry the report complexity into the OLTP schema.
- Preserve legacy identifiers for traceability: `legacy_id`, `legacy_control_number`, `legacy_tx_number`; generate new surrogate keys alongside them.

## Report Parity

The report folders are **layered overrides**, not three independent report sets:

- `Rpt` (90 `.rpt`) is the core/base report set.
- `Rpt DAO` (9 `.rpt`) uses DAO as its data source. For a given report name it **supersedes `Rpt`**. All 9 names also exist in `Rpt ODBC`, so DAO currently adds no unique logical report.
- `Rpt ODBC` (91 `.rpt`) uses ODBC as its data source and **supersedes both `Rpt DAO` and `Rpt`** for the same name. It also adds seven `2010` variants not present below it.
- Effective default set with precedence `Rpt ODBC > Rpt DAO > Rpt`: **97 file names** (91 from ODBC + 6 core-only: `Inventory Purchase`, `Invoice ON`, `Order ON`, `Order.dao`, `Receipts Report.dao`, `Stock Adjustment00`).
- **Customer overlays inside `Rpt ODBC`:**
  - `Rpt ODBC/Pacific` — 91 reports customized for Pacific.
  - `Rpt ODBC/Pacific/20220911` — 3 later wholesales variants (`Wholesales Invoice`, `Wholesales Packing List`, `Wholesales Return`) that override the Pacific overlay.
  - `Rpt ODBC/Richmond` — 69 reports customized for Richmond, plus `Copy of Sales Report`.
  - `Rpt ODBC/Richmond/HST` — 7 tax/HST variants (`Daily Cash Receipts`, `Invoice List (By Date)`, `Invoice List (By Invoice No.)`, `Invoice`, `Order`, `Sales Report`, `Sales Return Journal`) that override the Richmond overlay.
- Full precedence in a deployment: **nested customer overlay > customer overlay > `Rpt ODBC` > `Rpt DAO` > `Rpt`**.
- Compare report **designs/exports**, not file hashes; binary `.rpt` files differ by connection strings and timestamps even when the layout is unchanged.
- **Selected target profile: Richmond.** The effective Richmond set is **98 file names**:
  - 62 from `Rpt ODBC/Richmond`
  - 7 from `Rpt ODBC/Richmond/HST`
  - 23 falling back to `Rpt ODBC`
  - 6 core-only reports falling back to `Rpt`
  - `Rpt DAO` contributes nothing (fully superseded by `Rpt ODBC`)
  - `Rpt ODBC/Pacific` and `Pacific/20220911` are out of scope
- Excluding obsolete variants (`Old`, `s16`, `sON`, `2010`, `.dao`, `bk`) and the misplaced `Copy of Sales Report`, a realistic target is roughly **80 distinct logical reports**.

Plan:

1. **Build a report catalogue in Phase 0.** One row per logical report: legacy name, winning layer, customer profile, purpose, parameters, required data, frequency, audience, criticality, and sign-off. This defines "full parity" precisely.
2. **Build a reusable QuestPDF framework.** Base document with company header/logo, tax summary, line-item table builder, totals, page numbering, signatures, and barcode/label components. One layout equals one small class, not copy-paste.
3. **Model the overlay precedence in the catalogue**, not in code branches: resolve each report name to one effective layout for the deployment's customer profile. Migrate only the selected profile, or make the profile a configuration dimension if both Pacific and Richmond must be supported.
4. **Expose read-only `reporting` views** so report SQL is decoupled from the application schema.
5. **Add golden-file PDF tests** for every report using deterministic fonts and data.
6. **Stream and cap rows** for large listings.

Effort warning: QuestPDF has no Crystal Reports import/converter. Budget roughly **2-4 days per report** including query, layout, and testing. About 80 reports is **6-12 months of report work alone**, and is the critical path to full parity. If the target date is aggressive, add a dedicated report developer, overlap report work with the modules, or consider a reporting tool with a designer used alongside QuestPDF.

Confirm the **QuestPDF commercial license** requirements for on-prem commercial use (the Community license has a revenue threshold).

## OLAP Replacement: WebPivotTable

The legacy OLAP feature is **not** part of the Crystal report set. It is an interactive DynamiCube (`dcube.ocx`) module reading the pre-aggregated tables `OlapSales`, `OlapSalesLSP`, `OlapOrderInProgress`, and `OlapCategorySummary`, with pivot grids, Highcharts-style graphs, print preview, save, and Excel/text export.

The replacement is **[WebPivotTable (WPT)](https://webpivottable.com)** version 7 in `xOpti.Web`.

### Vue 3 compatibility

Confirmed: WPT v7 ships as a standard **Web Component** (`<web-pivot-table>`), is framework-agnostic, and has an official Vue 3 integration example plus full TypeScript declarations (v7.1.1+). It is not Vue-specific; Vue 3 treats the custom element like any other DOM element.

```vue
<template>
  <web-pivot-table ref="wptRef" style="width: 100%; height: 600px" />
</template>

<script setup lang="ts">
import { onMounted, onUnmounted, ref } from 'vue'
import 'webpivottable'

const wptRef = ref<HTMLElement | null>(null)
let unsub: (() => void) | null = null

onMounted(async () => {
  const wpt = wptRef.value as any
  wpt.setOptions({ locale: 'en', licenseKey: import.meta.env.VITE_WPT_LICENSE_KEY })
  await wpt.setWptFromWebService('/api/analytics/olap-sales')
  unsub = wpt.eventBus.on('PIVOT_CHANGED', () => {})
})

onUnmounted(() => unsub?.())
</script>
```

### Integration rules

- **Lazy-load the route.** Import `webpivottable` only inside the analytics route (`defineAsyncComponent` or `import()`), because the package is about 15 MB unpacked and bundles React, Zustand, and Highcharts. Do not put it in the initial bundle.
- **Wait for `wpt:ready`** when loading the component dynamically (`import()`), and call methods directly when the script is statically imported.
- **Feed data from the API, not the browser.** Expose analytics endpoints returning `{ fields, data }` (`setWptFromWebService`) or CSV (`setWptFromCsvUrl`). The browser must never connect directly to PostgreSQL.
- **Use aggregated data.** Feed the equivalent of the legacy OLAP summary tables, not raw transactions. Aim for a few thousand rows; Memory mode is suited to roughly 100 MB and client-side processing.
- **Self-host everything on-prem.** Ship the WPT bundle and locale JSON from our own server; do not depend on `cdn.webpivottable.com` in production.
- **Persist saved views server-side.** Use the `SAVE_WPT`/`OPEN_WPT` event hooks to store the `.wpt` JSON through the API (`/api/analytics/views`), so user-defined pivots survive across sessions.
- **Rebuild the four legacy views** as analytics queries: Sales by Cost (`OlapSales`), Sales by LSP (`OlapSalesLSP`), Orders in Progress (`OlapOrderInProgress`), and category summary (`OlapCategorySummary`).
- **Do not enable the AI features initially.** If enabled later, proxy the provider through the API; never ship an LLM API key in the browser.
- **Skip OLAP/MDX mode.** The legacy "OLAP" is not a real multidimensional cube; use Memory mode against PostgreSQL aggregates. XMLA/DuckDB modes are unnecessary complexity here.

### Licensing (verified 2026-11-06)

WPT is **proprietary commercial software**, not open source. The authoritative terms are the Software License Agreement at <https://webpivottable.com/policy> (effective 1 March 2026, governed by Ontario law). The key findings:

- **Community (free)** is licensed for **Non-Commercial Use only**. The "Powered by WPT" badge must remain visible, unmodified, and linked to `webpivottable.com`; hiding or removing it by CSS, overlays, DOM mutation, or source changes is a material breach and copyright infringement (Sections 5.1-5.3). Use inside a for-profit company, even for internal tools, counts as Commercial Use (Section 2.1).
- **Developer:** USD 299 one-time, 1 named developer, perpetual, unlimited deployments, badge removable via license key.
- **Team:** USD 699/year, up to 5 developers, all version updates.
- **Enterprise:** negotiated white-label/OEM.
- Because this rewrite is commercial, the **Community license is not usable**; budget Developer or Team.

Two procurement issues found during verification:

1. **Missing license file.** The npm package (`webpivottable@7.1.1`) and the `wpt-v7.1.0-self-host.zip` contain no `LICENSE` file, and the GitHub repo root has none. `package.json` declares `"license": "SEE LICENSE IN LICENSE"`, but that file is absent; the README only links to the policy page. The website policy is incorporated by reference (Section 15.1), so it is legally authoritative, but obtain the license text and commercial terms **in writing** before purchase.
2. **Highcharts is licensed separately.** WPT bundles Highcharts 11, and Sections 7.1-7.2 explicitly state that WPT's commercial license does **not** include a Highcharts commercial license. Budget/verify Highcharts licensing for a commercial on-prem deployment.

Other operational constraints:

- **License key handling.** Keys are domain-locked and confidential (Sections 6.2, 6.4). `localhost` and private LAN ranges are allowed for development. The SPA embeds the key client-side, so never publish the frontend bundle or key in a public repo; the on-prem model is compatible, but treat the key as a secret.
- **Self-hosted bundle.** Pricing lists the self-hosted bundle with Team/Enterprise; the Developer tier is npm/CDN. Confirm with the vendor that bundling the npm package into the on-prem app under Developer is acceptable, or purchase Team.

Add a WPT license line (and a Highcharts license line) to the Open Items.

## Data Migration: Hard Cutover, Full History

Without a parallel run, the migration must be rehearsed aggressively.

1. **Confirm the actual production MDB.** The 2008/2011/2016 archives belong to different customers; the root `SynergyV.mdb` is a template/sample. Do not migrate the wrong source.
2. **Extract** using `mdbtools` (`mdb-export`/`mdb-schema`) or Access/ODBC to CSV.
3. **Load raw** into a PostgreSQL `legacy` schema that preserves the original table and column shape.
4. **Transform** with versioned, idempotent, re-runnable scripts into the new `app` schema:
   - Access booleans (`-1`/`0`) to PostgreSQL booleans
   - Currency to `numeric(19,4)`
   - Dates to `timestamptz`
   - Text encoding cleanup
   - Null handling, deduplication, orphan foreign keys, reserved words
5. **Reconcile every dry run** with automated checks:
   - Row counts per table
   - Sales, tax, payment, and refund totals by period
   - Inventory quantity and cost by SKU and lot
   - AR/AP balances
   - Invoice and control-number sequences
   - Order status counts
6. **Handle known anomalies.** The `Patches/2015-05-02` scripts show historical missing `TxHeader` rows; detect and resolve these explicitly rather than copying bad data silently.
7. **Run at least three full dry runs** on recent copies and measure the freeze-window duration. The 913 MB snapshot provides a realistic upper bound.
8. **Cut over:** freeze legacy writes, run the final delta migration, reconcile, switch the proxy, keep the legacy database read-only for an agreed audit period, and retain a rollback plan.

Sequence: migrate master data first, then opening balances and stock, then historical transactions as read-only records.

## Domain Rules to Preserve

- **Transaction types:** `SR` stock received, `RJ` stock rejected, `SJ` stock adjustment, `RC` retail invoice, `RS` retail refund, `WC` wholesale invoice, `WR` wholesale return, `SA` sale order.
- **Tax methods:** `B` (GST + PST), `G` (GST), `P` (PST), `g` (GST included), `p` (PST on GST). See `frmPriceWizard.frm`.
- **Costing:** `Category.CostingMethod` of `"2"` means LIFO; otherwise average/FIFO. Cost layers must be modeled explicitly and reconciled against legacy before POS work.
- **Control/invoice numbering:** `GetNextControlNumber` and `Preference`/`TxNextNumber` must be made race-safe in PostgreSQL.
- **Cost visibility:** `pyUserHasCostLevel` is a real authorization requirement, not cosmetic.
- **Critical documents:** RBIC workbook and claim receipt (`Rptlibvalid.bas`) must be reproduced.

## Roadmap

| Phase | Scope | Estimate |
| --- | --- | --- |
| 0. Discovery | Schema extraction, rules, report catalogue, permission matrix, data profile, production-DB confirmation | 4-6 weeks |
| 1. Foundation | Solution, Docker/Postgres, Identity/RBAC, audit, CI/CD, Vue shell | 4-6 weeks |
| 2. Master data | Customers, suppliers, staff, doctors, inventory/SKU, categories, branches, tax, preferences | 6-8 weeks |
| 3. Inventory and purchasing | Receive/reject/adjust/transfer, stock take, lots, FIFO/LIFO/average costing, barcodes | 8-10 weeks |
| 4. POS and sales | Order entry, retail invoice/refund, tenders, payments, reprints, daily close, idempotency | 10-12 weeks |
| 5. Customers, Rx, insurance | Prescriptions, contact/lens, claims/RBIC, order planner | 8-10 weeks |
| 6. Wholesale | Invoice/return, packing lists | 4-6 weeks |
| 7. Reporting and analytics | QuestPDF framework plus about 80 report layouts and exports; WebPivotTable analytics views replacing the four legacy OLAP screens | 20-30 weeks (overlap) |
| 8. Migration and cutover | Dry runs, reconciliation, freeze window, go-live | 8-10 weeks |

With 2-4 developers and report work overlapping, realistically **15-20 months**; report parity is the critical path. A trimmed first release (master data, inventory, POS, critical documents) could go live sooner, but that conflicts with full parity at cutover, so the schedule must absorb the report effort.

## Risks and Mitigations

| Risk | Mitigation |
| --- | --- |
| Report parity with QuestPDF | Catalogue, fixed framework, dedicated capacity; consider a designer-based tool if the date slips |
| Inventory costing semantics (LIFO/average/FIFO) | Define cost-layer behavior and reconcile against legacy before POS work |
| Historical data anomalies | Reconciliation suite and explicit exception handling |
| POS hardware (receipt/label printers, scanners, payment terminals) | Inventory in Phase 0; plan a local device/print agent if browser APIs fall short |
| Permission mapping from `SecurityLevel` | Explicit permission matrix; never expose cost/margin unintentionally |
| Hard-cutover downtime | Rehearse, measure, and communicate the freeze window |
| WebPivotTable licensing and bundle size | Confirm commercial/self-hosted tier in Phase 0; lazy-load the component; keep it out of the initial bundle |
| Highcharts licensing | WPT does not include a Highcharts commercial license; confirm and budget it separately |
| WebPivotTable vendor lock-in | Keep `.wpt` view definitions as plain JSON behind our own API so views can be re-rendered by another pivot component if needed |

## Testing Strategy

- Characterization tests for legacy business rules using exported sample data: tax, discounts, costing, refunds.
- Integration tests on real PostgreSQL through Testcontainers; Respawn for isolation.
- Playwright end-to-end tests for critical POS flows.
- Golden-file PDF tests for QuestPDF output.
- Component tests for the WebPivotTable wrapper (data load, saved-view round-trip, event unsubscribe).
- Migration reconciliation suite run on every dry run.

## Immediate Next Steps (Phase 0)

1. Confirm the production MDB source and the current store/branch count.
2. Extract the full schema and build the report catalogue from `Rpt/*.txt` and the `.rpt` definitions, resolving the effective layout with the `Rpt ODBC > Rpt DAO > Rpt` and customer-overlay precedence.
3. Confirm which customer profile the deployment represents: resolved to **Richmond**.
4. Produce the transaction-flow and costing specification from `AppOLTP.bas` and the POS forms.
5. Produce the permission matrix from `AppValidation.bas` and `AppUser.bas`.
6. Prototype WebPivotTable in `xOpti.Web` against a `OlapSales` export to validate Vue 3 integration, locale self-hosting, and saved-view persistence.
7. Confirm team size and target go-live so the roadmap can be compressed or staffed accordingly.

## Open Items

- Which database file is the production source?
- Team size and target go-live date?
- Which POS hardware and payment terminals must be supported?
- QuestPDF licensing tier?
- WebPivotTable license tier (Developer vs Team) and confirmation that the npm bundle may be self-hosted in an on-prem deployment?
- Highcharts commercial license, since WPT does not include it?
- Written copy of the WPT license terms, because the npm package and self-host zip ship no `LICENSE` file?
