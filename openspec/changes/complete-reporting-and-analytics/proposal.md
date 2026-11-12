# Proposal

## Why

Full report parity is a locked cutover requirement and the critical path for the rewrite. The legacy Crystal Reports layer contains roughly 80 effective Richmond logical reports, plus four OLAP views and critical documents such as invoices, claims, RBIC, statements, journals, and bar-code tags. xOpti has only a QuestPDF dependency and an analytics shell; no report catalogue, reporting views, golden-file tests, or production report rendering exists.

## What Changes

- Deliver the QuestPDF reporting framework and report catalogue:
  - Implement the signed Richmond report catalogue with one effective layout per logical report and explicit sign-off status.
  - Build shared document components for company header, addresses, tax summaries, line tables, totals, signatures, page numbering, barcodes, and labels.
  - Expose read-only reporting views/read models so layouts do not depend on operational tables.
  - Implement parameter selection, preview, print, PDF/export, reprint, row caps, streaming, and permission checks.
  - Deliver report families for customers, inventory, purchasing, sales, orders, wholesale, prescriptions, insurance/claims, statements, journals, cash, bar-code tags, and tax/HST.
  - Produce critical documents: invoice, order, claim receipt, RBIC workbook, daily cash receipts, sales reports, and tax reports.
  - Add golden-file PDF tests with deterministic fonts and data, plus Windows/Crystal comparison evidence for sign-off.
- Deliver analytics:
  - Rebuild the four legacy views (Sales by Cost, Sales by LSP, Orders in Progress, Category Summary) as server-side analytics feeds.
  - Integrate self-hosted WebPivotTable v7 with lazy loading, saved views, and export.
  - Enforce report/analytics permissions and refresh/freshness rules.
- Out of scope: business-module behavior changes; reports not present in the signed catalogue are explicitly deferred.

## Capabilities

### New Capabilities

- `reporting`: report catalogue, read models, parameterized rendering, permissions, reprints, exports, deterministic PDFs, critical documents, and parity sign-off.
- `analytics`: the four legacy OLAP views, WebPivotTable integration, saved views, exports, access control, and freshness.

### Modified Capabilities

None.

## Impact

- Affected code: `Application/Reporting`, new `xOpti.Reports` rendering project or namespace, QuestPDF layouts, reporting schema views/materialized views, API report endpoints, Vue report/analytics screens, and licensed WebPivotTable assets.
- Affected data: read-only reporting views over posted transactions, inventory, customers, claims, and accounting data; no operational table rewrites.
- Dependencies: all operational module changes, the signed report catalogue, production baseline, QuestPDF/Highcharts/WebPivotTable licences, deterministic fonts, and a Windows reference VM.
- Schedule risk: at roughly 2-4 days per logical report, the catalogue is expected to take 6-12 months of dedicated effort and must overlap module delivery.
