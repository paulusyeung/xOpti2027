# Reports, critical documents, and analytics

This page is the operator-facing contract for the report catalogue, reporting
read models, critical documents, reprints, and analytics. Customer sign-off
remains pending: the catalogue is provisional and every entry records
`signoff_status = pending`.

## Report catalogue

The provisional catalogue is generated from `docs/parity/reports.csv` and
contains all 98 effective Richmond report files plus system documents for
invoice, order, receipt, customer statement, wholesale statement, daily cash,
sales, and tax/HST.

Every entry records:

- catalogue ID and logical report name
- parameter definitions
- required permission (`report:financial` or `cost:view`)
- reporting read model
- layout key
- row cap (0 means an approved document is never row-capped)
- criticality, critical-document flag, in-scope state, and sign-off state

An unknown catalogue ID is rejected with a field-level error. A user without
the catalogued permission is denied. The report UI lists only the catalogue and
supports search, favorites, recently used, and a printable index.

Tests: `ReportingGoldenTests.EveryEffectiveReportFile_IsClassifiedInTheCatalogue`,
`ReportingTests.Catalogue_ListsEveryEffectiveReport_RejectsUnknownAndUnauthorized`.

## Parameters, preview, print, export, and reprint

1. Open **Reports** and select a catalogue entry.
2. Enter the catalogue parameters (dates, department/class/category, transaction
   range, customer, or the document/claim/customer reference required by a
   critical layout).
3. **Preview** shows the read-model columns, rows, as-of timestamp, freshness,
   and truncation notice.
4. **Print PDF** generates the approved layout and records the catalogue ID,
   parameters, actor, branch, time, row count, and truncation state.
5. **Duplicate** records a reprint and marks the output duplicate.
6. **Export CSV** applies the same visibility rules and is audited.

Invalid parameters return field-level errors and no partial report.

Tests: `ReportingTests.PreviewPrintExport_UseReadModelsParametersAndAudit`,
`ReportingSecurityTests.RequiredAndTypedParameters_ReturnFieldLevelErrors`.

## Read models, refresh, and freshness

Reports read from `reporting.v_*` views. Analytics read from
`reporting.mv_olap_*` materialized views. `reporting.read_model_state` records
the as-of and refresh result per model.

- The hourly reporting refresh job refreshes the four analytics models and
  updates their state.
- `POST /api/v1/reports/refresh` performs the same refresh on demand and is
  audited.
- Analytics feeds expose `asOf`, `stale`, `truncated`, and `rowCap`.
- The UI warns when a read model is stale or a result is truncated.

Tests: `ReportingTests.CriticalInvoiceAndAnalyticsFeedsSavedViewsAndExports_Work`,
`ReportPerformanceTests.ProductionSizedListing_IsCappedWithinInteractionBudget`.

## Critical documents

- Invoice/order/receipt: `SYS-INVOICE`, `SYS-ORDER`, `SYS-RECEIPT` delegate to
  the existing POS document renderer and preserve reprint behaviour.
- Claim receipt: `RPT-010` delegates to the claim receipt renderer.
- RBIC: `RPT-062` and `RPT-063` delegate to the RBIC CSV renderer.
- Customer statement: `SYS-CUST-STATEMENT`.
- Wholesale statement: `SYS-WS-STATEMENT`.
- Daily cash: `SYS-DAILY-CASH`.
- Sales report: `SYS-SALES-REPORT`.
- Tax/HST: `SYS-TAX-HST`.
- Packing list: `RPT-094` delegates to the wholesale packing-list renderer.

Tests: `ReportingTests.CriticalOrderClaimsStatementsCashAndTaxReports_Render`,
`ReportingTests.CriticalInvoiceAndAnalyticsFeedsSavedViewsAndExports_Work`,
`WholesaleReportingTests.PackingList_HidesPricesByDefaultAndPrintsWithAudit`.

## Deterministic output and golden files

Reports use bundled fonts, invariant formatting, fixed date formats, and
normalized metadata. The golden catalogue covers every catalogue entry and the
generic report PDF is checked for byte stability after normalizing permitted
metadata.

Tests: `ReportingGoldenTests.CatalogueLayouts_AreDeterministicAndGolden`,
`ReportingGoldenTests.GenericReportPdf_IsByteStableAfterMetadataNormalization`,
`ReportingGoldenTests.SharedComponents_RenderHeaderTableTotalsBarcodeAndPageNumbers`.
Golden file: `docs/reports/golden-catalogue.txt`.

## Analytics

1. Open **Analytics**. The licensed self-hosted WebPivotTable v7 component loads
   only on this route.
2. Select Sales by Cost, Sales by LSP, Orders in Progress, or Category Summary.
3. Apply period, branch, staff, department, class, or category filters.
4. Save a named view; the configuration is stored server-side with owner and
   sharing state. Reopen restores the view and filters.
5. Export CSV; cost and margin fields are omitted for users without
   `cost:view`.
6. Stale and truncated results display a warning.

The browser receives aggregated rows from the API only; it never connects to
PostgreSQL. Assets and locales are served from the xOpti origin, with no public
CDN or AI dependency.

Tests: `AnalyticsPage.test.ts`, `analytics.test.ts`,
`ReportingTests.CriticalInvoiceAndAnalyticsFeedsSavedViewsAndExports_Work`.

## Licensing and open items

Analytics requires a WebPivotTable licence key at runtime and may require a
separate Highcharts licence. Without a licence key the route shows a
configuration error and does not import the pivot component.

Still pending before final acceptance:

- customer sign-off for every catalogue entry
- Windows/Crystal comparison evidence for critical documents
- approved printer/paper profile rehearsal
- written WebPivotTable and Highcharts licence evidence
- legacy OLAP export parity for representative periods

Runbook check: `ReportingRunbookTests.ReportingRunbookCoversAutomatedBehaviour`.
