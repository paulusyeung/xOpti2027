# Design

## Context

See `proposal.md` for motivation. The legacy report set is layered: `Richmond/HST > Richmond > Rpt ODBC > Rpt DAO > Rpt`. The selected target is the Richmond profile: 98 effective file names, roughly 80 distinct logical reports after removing obsolete and duplicate variants. Crystal `.rpt` files cannot render on Linux and there is no QuestPDF importer. The repository currently contains a WebPivotTable shell and an analytics route but no server feed or report framework.

## Goals / Non-Goals

**Goals:**
- Deliver signed-off report parity for the effective Richmond catalogue.
- Make reports deterministic, permissioned, testable, and operable at production data volumes.
- Replace the four legacy OLAP views with a supported self-hosted analytics path.
- Keep report layouts and data access decoupled from operational modules.

**Non-Goals:**
- Automatically converting `.rpt` files.
- Migrating Pacific or non-selected overlays.
- Ad-hoc reporting against operational tables.
- AI/LLM analytics features.

## Decisions

### Decision: Catalogue-driven layout registry

Each logical report has one catalogue row and one QuestPDF layout class. The registry resolves catalogue ID to layout, parameters, required permission, read model, row cap, and sign-off status. A report not in the registry cannot be generated. Obsolete variants are excluded by the catalogue, not by code branches.

Alternatives considered: one generic report renderer with conditional layout switches. Rejected because 80 layouts would become unmaintainable and untestable.

### Decision: Read-only reporting views, refreshed on a schedule

Create a `reporting` schema (or read-only views in `public`) over posted documents, inventory, customers, claims, and cash. Materialized views are refreshed by the existing job runner with concurrency and freshness tracking. Reports display the as-of timestamp and warn or block when stale.

Alternatives considered: queries directly against `tx_*` tables. Rejected because report SQL would couple to storage details and risk expensive scans.

### Decision: Deterministic QuestPDF components with bundled assets

Build a shared component library for headers, addresses, tables, totals, tax summaries, signatures, page numbers, barcodes, and labels. Bundle fonts (including `3of9.TTF` where licensed) and set fixed locale/time zone. Golden-file tests compare rendered PDFs for representative fixtures; permitted metadata differences are normalized.

Alternatives considered: HTML-to-PDF. Rejected because deterministic pagination, fonts, and barcode control are weaker and the project has selected QuestPDF.

### Decision: Windows reference VM for parity evidence

A Windows VM retains the legacy application, Crystal Reports runtime, and printers. Each report is compared against the reference for representative parameter sets. Differences are recorded and signed off explicitly; the goal is business equivalence, not pixel identity where fonts or printers differ.

Alternatives considered: relying only on data totals. Rejected because layout, grouping, subtotals, and tax presentation are part of report parity.

### Decision: Stream and cap large reports

Listings use server-side streaming and catalogue row caps. When a cap is reached, the report states the truncation and offers a narrower parameter set or export. POS-critical documents are never capped silently.

Alternatives considered: generating unlimited PDFs in memory. Rejected because large listings would exhaust memory and block the API.

### Decision: Analytics read models are pre-aggregated, not raw transactions

Build four analytics read models equivalent to `OlapSales`, `OlapSalesLSP`, `OlapOrderInProgress`, and `OlapCategorySummary`. The API returns `{ fields, data }` for WebPivotTable memory mode, with row/payload caps. Saved views store `.wpt` JSON server-side scoped by owner and sharing permission.

Alternatives considered: feeding raw transactions to the browser. Rejected for payload size, performance, and data exposure.

### Decision: Self-host and lazy-load WPT

Ship the WebPivotTable bundle and locales from the xOpti origin. Import the component only inside the analytics route. Keep the licence key in runtime configuration and never in the repository. Track the separate Highcharts licence requirement.

Alternatives considered: loading from the vendor CDN. Rejected for on-prem isolation and availability.

## Risks / Trade-offs

- [Report parity is the schedule critical path] → Staff dedicated report capacity, deliver catalogue-first, and overlap report work with modules.
- [Crystal layout behavior is hard to reproduce] → Compare against the reference VM early and record accepted differences per report.
- [80 layouts create long-term maintenance] → Enforce shared components and golden tests; reject copy-pasted layouts.
- [Materialized views become stale] → Expose freshness and block or warn per report rule.
- [Large reports exhaust resources] → Stream, cap, and test with production-sized data.
- [WPT/Highcharts licensing is unresolved] → Block production analytics until written licences are recorded.
- [Report permissions leak financial or cost data] → Catalogue permission is mandatory and tested for every report.

## Migration Plan

1. Finalize and sign the report catalogue; select the critical set for pilot.
2. Build reporting views, freshness tracking, and the shared QuestPDF component library.
3. Implement critical documents and compare with the Crystal reference.
4. Deliver remaining report families in catalogue priority order with golden tests.
5. Build analytics read models and API feeds; integrate and licence WebPivotTable.
6. Run report sign-off with the customer, then enable production printing.
7. Keep the Windows reference available through the audit period.

Rollback: disable individual report catalogue entries without redeploying; keep the legacy reference VM available for manual issuance during any report outage.

## Open Questions

- Which reports are mandatory for pilot versus final cutover?
- Who signs off each report, and how many representative cases are required?
- Which printer/paper profiles define physical parity?
- Are WPT Developer or Team and Highcharts licences approved in writing?
- Is Excel export required for every analytics view or only selected views?
