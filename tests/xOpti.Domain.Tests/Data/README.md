# Legacy characterization fixtures

Source: production snapshot `SynergyV.mdb` (sha256 `55088a63b914f745...`, the
read-only copy used by `xOpti.Migrations` reconciliation runs, see
`tools/legacy-migration/reports/reconciliation-cutover-dryrun.md`).

Rows were extracted read-only with `mdb-export` and filtered to:

- `tax_lines_sample.csv`: single-line retail invoices (`RC`) and sales orders
  (`SA`) across tax codes `N`/`B`/`G`/`g`/`P`, spanning 2000-2015 rate eras.
  `p` (PST on GST) has no production rows in the snapshot; it is covered by a
  synthetic unit test in `TaxCalculatorTests` only. Columns carry the line net, the
  rates the store used for that era (GST 7%/6%/5%, PST 7%), and the legacy
  computed `TaxA`/`TaxB`/`TotalAmount` as the expected outputs.
- `lots_sample.csv`: all `InvtLotRecord` rows for two SKUs (`00000008`,
  `00000551`) with multiple lots, including the legacy deficit lots (negative
  `QtyOnHand`) that sold-before-receipted stock produces.

PII hygiene: no customer ids/names, no staff, no supplier names (only numeric
supplier codes), no addresses. SKUs and control numbers are inventory/payment
mechanical identifiers kept for traceability, consistent with the migration
notes preserving legacy identifiers.
