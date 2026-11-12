# Tasks

## 1. Report catalogue and framework

- [ ] 1.1 Finalize the signed Richmond catalogue with effective layout, parameters, permissions, read model, row cap, and sign-off status; verify every effective report file is classified.
- [ ] 1.2 Implement the catalogue-driven report registry and permission checks; verify an uncatalogued or unauthorized report cannot be generated.
- [ ] 1.3 Build the shared QuestPDF component library for headers, addresses, tables, totals, tax summaries, signatures, page numbers, barcodes, and labels; verify component golden tests.
- [ ] 1.4 Add deterministic fonts, locale, time zone, barcode assets, and PDF metadata normalization; verify identical inputs produce identical output apart from permitted metadata.
- [ ] 1.5 Implement parameter selection, preview, print, PDF download, and generation audit; verify invalid parameters return field-level errors.

## 2. Reporting read models

- [ ] 2.1 Create read models/views for customer, inventory, purchasing, sales, orders, wholesale, prescriptions, claims, cash, and tax reporting; verify totals against posted documents.
- [ ] 2.2 Add refresh jobs and as-of metadata for materialized read models; verify freshness is visible and stale reports warn or block per catalogue.
- [ ] 2.3 Add report row caps and streaming; verify a large listing is truncated with an explicit notice and does not exhaust memory.
- [ ] 2.4 Add report query performance tests with production-sized extracts; verify critical reports meet the approved interaction/print time.

## 3. Critical documents

- [ ] 3.1 Implement the approved invoice, order, and receipt layouts; verify golden files and POS reprint integration.
- [ ] 3.2 Implement the claim receipt and RBIC layouts; verify totals and data against posted claims and the Windows reference.
- [ ] 3.3 Implement daily cash receipts, sales reports, and tax/HST reports; verify period and branch totals.
- [ ] 3.4 Implement customer/wholesale statements; verify opening, activity, and closing balances reconcile.
- [ ] 3.5 Compare critical documents with the Windows/Crystal reference for representative cases; verify differences are recorded and signed off.

## 4. Report families

- [ ] 4.1 Implement customer reports (lists, history, account, statement, labels) and verify catalogue sign-off.
- [ ] 4.2 Implement inventory reports (stock status, valuation, movement, reorder, lot, stock take) and verify catalogue sign-off.
- [ ] 4.3 Implement purchasing reports (receiving, returns, supplier activity, AP) and verify catalogue sign-off.
- [ ] 4.4 Implement sales and order reports (invoice list, sales journal, sales by period, order status, refunds) and verify catalogue sign-off.
- [ ] 4.5 Implement wholesale reports (invoice, return, packing list, statements, activity) and verify catalogue sign-off.
- [ ] 4.6 Implement prescription and insurance/claim reports (Rx history, claims, RBIC, insurer activity) and verify catalogue sign-off.
- [ ] 4.7 Implement bar-code tag and label reports; verify symbology, sizing, and scan testing.
- [ ] 4.8 Implement remaining catalogue reports by priority; verify each has a golden file and signed-off acceptance evidence.
- [ ] 4.9 Add report favorites/recently used and a printable report index if required by the catalogue; verify permission-aware visibility.

## 5. Analytics read models and API

- [ ] 5.1 Build Sales by Cost, Sales by LSP, Orders in Progress, and Category Summary read models; verify field definitions and totals against legacy OLAP exports.
- [ ] 5.2 Implement analytics API feeds returning `{ fields, data }` with permissions, row/payload caps, and as-of timestamps; verify no direct database access is exposed.
- [ ] 5.3 Implement saved analytics views with owner/sharing rules and server-side storage; verify save, reopen, and unauthorized access behavior.
- [ ] 5.4 Implement CSV/text/Excel export with visibility filtering and audit; verify restricted cost/margin fields are omitted.
- [ ] 5.5 Add refresh jobs and freshness monitoring for analytics read models; verify stale data is marked and warned.

## 6. Analytics frontend and licensing

- [ ] 6.1 Integrate self-hosted WebPivotTable v7 with lazy route loading and locale assets; verify the initial bundle excludes the pivot dependency.
- [ ] 6.2 Build the analytics route, view selector, filters, save/open, export, and error/stale states; verify component and Playwright tests.
- [ ] 6.3 Validate analytics against legacy OLAP for representative periods and branches; verify row and total parity within tolerance.
- [ ] 6.4 Record WebPivotTable and Highcharts licence evidence and enforce licence configuration; verify production blocks or degrades correctly without a licence.
- [ ] 6.5 Verify on-prem self-hosting with no public CDN or AI dependency; verify network requests stay on the xOpti origin.

## 7. Parity, operations and sign-off

- [ ] 7.1 Run report comparison on the Windows reference VM for every critical report; verify signed evidence is stored per catalogue ID.
- [ ] 7.2 Add golden-file tests for every implemented report; verify the test suite fails on unintended layout or total changes.
- [ ] 7.3 Run a full print/reprint rehearsal on the approved POS printers; verify paper size, fonts, barcodes, and page breaks.
- [ ] 7.4 Document report operation, reprint procedure, freshness, truncation, and licence obligations; verify the runbook matches automated behavior.
- [ ] 7.5 Obtain final report-parity sign-off and update the catalogue status; verify no critical report remains unsigned.

## Workflow follow-up

- Archive this change after report parity and analytics acceptance is signed.
- Keep the Windows reference VM available through the agreed post-cutover audit period.
