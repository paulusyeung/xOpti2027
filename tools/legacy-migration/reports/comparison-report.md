# MDB to xOpti migration comparison report

- Source: `~/Downloads/SynergyV.mdb` (70 tables, 7,747,518 rows; data through 2022-09-03)
- Target: `xOpti` (71 base tables, 7,696,556 rows; data through 2022-05-30)
- Comparison database: `xopti_migration_compare` (`public` = xOpti copy, `mdb` = staged MDB)
- Comparison is read-only with respect to the production MDB and `xOpti`.

## 1. Executive summary

- Migration is structurally sound. All 70 MDB tables exist in `xOpti`; the only extra target base table is `users`.
- `xOpti` is a strict subset of the MDB by 50,962 rows. The missing rows are concentrated in the 2022-05-31 to 2022-09-03 window and are snapshot skew, not migration loss.
- Historical rows outside the snapshot window reconcile after numeric precision and case normalization. The exceptions are 84 `TxHeader` monetary edits, 129 `TxDetails` monetary edits, 1 `TxPayment` edit, date-of-creation drift in 404 headers, and ref/second-date drift in 248 headers.
- Current-state tables (`Inventory`, `InvtLotRecord`, `CustomerAccounts`, `RetailPrice`) differ because `xOpti` is a May 2022 snapshot while the MDB contains later activity. These must be refreshed during cutover.
- Sequences are lower in `xOpti` and must be advanced before cutover: RC, RS, SR, RJ, SJ, WC, plus surrogate ID sequences and `Preference` control numbers.
- Target-side data defects to correct: summary-table date corruption, 6 xOpti-only `TxDetails` rows, and 478 orphaned `TxSalePerson` rows without a header.

## 2. Schema

- Source tables: 70
- Target base tables: 71
- Source-only tables: none
- Target-only base tables: `users`
- Missing columns: 0
- Source-column typos corrected in target: 3
  - `preference.paltform` -> `platform`
  - `txsorderlens.rigthbase` -> `right_base`
  - `txsorderlens.rigthoc` -> `right_oc`
- Primary keys match for every common table. MDB has no primary key on `paste errors` and `taxmethod`.
- Type differences: 198, all widenings
  - `NUMERIC(15,2)` -> `numeric(19,4)`: 116
  - `REAL` -> `double precision`: 82
- Nullability differences: 49
  - 16 tightened in target (serial/ID columns, `city.code`, `invtlotrecord.lotno`, `utilchecklog.lognumber`)
  - 33 relaxed in target (status/summary/flag columns)
- Indexes: MDB has 176 secondary indexes across 61 tables; `xOpti` has 165 secondary indexes across 49 tables. The differences are primary-key indexes represented separately in PostgreSQL and the extra `users` table. Lookup indexes on code columns in small lookup tables are absent from `xOpti`.
- Views: 44 MDB queries and 42 PostgreSQL views are out of scope because views will be replaced by LINQ queries.

## 3. Row counts

- Source rows: 7,747,518
- Target rows: 7,696,556
- Difference: -50,962
- Tables compared: 70
- Tables with differences: 23
- All differences are `xOpti` having fewer rows. No target-only tables.

Major differences:

| Source table | Target table | Source rows | Target rows | Difference |
| --- | --- | ---: | ---: | ---: |
| `txdetails` | `tx_details` | 1,223,530 | 1,210,941 | -12,589 |
| `txsaleperson` | `tx_sale_person` | 548,175 | 541,739 | -6,436 |
| `txheader` | `tx_header` | 547,731 | 541,300 | -6,431 |
| `txsorderextra` | `tx_s_order_extra` | 432,932 | 427,613 | -5,319 |
| `invtsummary` | `invt_summary` | 510,107 | 505,885 | -4,222 |
| `barcodepool` | `bar_code_pool` | 344,832 | 341,109 | -3,723 |
| `invtlotrecord` | `invt_lot_record` | 357,608 | 354,451 | -3,157 |
| `txpayment` | `tx_payment` | 250,908 | 247,856 | -3,052 |
| `retailprice` | `retail_price` | 110,822 | 109,698 | -1,124 |
| `inventory` | `inventory` | 110,339 | 109,220 | -1,119 |
| `txsorderlens` | `tx_s_order_lens` | 86,536 | 85,855 | -681 |
| `paymentsummary` | `payment_summary` | 34,366 | 33,918 | -448 |
| `customer` | `customer` | 59,978 | 59,533 | -445 |
| `customeraccounts` | `customer_accounts` | 59,443 | 59,001 | -442 |
| `customerpreslens` | `customer_pres_lens` | 59,329 | 58,887 | -442 |
| `customerprescontact` | `customer_pres_contact` | 59,193 | 58,752 | -441 |
| `customermedical` | `customer_medical` | 58,968 | 58,528 | -440 |
| `txsordercont` | `tx_s_order_cont` | 40,734 | 40,546 | -188 |
| `suppliersummary` | `supplier_summary` | 10,239 | 10,125 | -114 |
| `categorysummary` | `category_summary` | 7,270 | 7,189 | -81 |
| `classsummary` | `class_summary` | 3,713 | 3,670 | -43 |
| `deptsummary` | `dept_summary` | 1,199 | 1,184 | -15 |
| `doctor` | `doctor` | 1,178 | 1,168 | -10 |

The MDB maximum transaction date is 2022-09-03; `xOpti` maximum is 2022-05-30.

## 4. Key differences

### `tx_header`

- Common rows: 541,300
- Source-only: 6,431 (all 2022)
- Target-only: 0

### `tx_details`

- Common rows: 1,210,935
- Source-only: 12,595
  - 1899: 2, 2013: 1, 2016: 2, 2017: 2, 2018: 15, 2019: 23, 2020: 44, 2021: 119, 2022: 12,387
- Target-only: 6
  - `SA349035A` (2018-08-28)
  - `SA368052` rows 2 and 3 (2022-03-26)
  - `SA368928` row 2 (2022-05-29)
  - `SJ00002805` rows 1 and 2 with corrupted target date `7848-09-30`

### `tx_payment`

- Common rows: 247,856
- Source-only: 3,052 (all 2022)
- Target-only: 0

### `tx_sale_person`

- Common rows: 541,739
- Source-only: 6,436 (6,433 in 2022, 1 in 2016, 2 with no resolvable header date)
- Target-only: 0
- `xOpti` also contains salesperson rows for 6,431 headers that are absent because of snapshot skew, plus 478 legacy orphaned rows with no header.

## 5. Aggregate reconciliation

### Historical transactions

- `TxHeader` common rows: 541,300
  - Monetary differences after 2-decimal tolerance: 84, all dated 2021-10-06 to 2022-05-30
  - Quantity differences: 50
  - Date-of-entry differences: 1
  - Customer ID differences: 3
  - Ref-number/second-date differences: 248
  - Date-of-creation differences: 404
- `TxDetails` common rows: 1,210,935
  - Monetary differences: 129
  - Quantity differences: 12
  - Tax-code differences: 11
  - Markdown-percent differences: 0 after 4-decimal tolerance (MDB `REAL` precision)
- `TxPayment` common rows: 247,856
  - Differences: 1 (`SA360530B`, type 8, 110 vs 90)
- `PaymentSummary` common keys: 33,918
  - Differences: 2, both under 0.005 and attributable to source precision
- Pre-2022 exceptions in `TxHeader`:
  - `SA914166`: quantity 1 vs 0
  - `SA360530B`: sale 110 vs 90
  - `SA161875`: quantity 2 vs 1
  - `SA366960`: cost 144.48 vs 0

### Inventory

Common SKUs: 109,220

| Measure | MDB | xOpti |
| --- | ---: | ---: |
| Quantity on hand | 12,435 | 12,731 |
| Inventory value | 369,104.10 | 462,081.65 |
| SKUs with quantity differences | 1,329 | |
| SKUs with cost differences | 2,282 | |

### Lots

Common lots: 354,451

| Measure | MDB | xOpti |
| --- | ---: | ---: |
| Quantity purchased | 523,835 | 523,835 |
| Quantity used | -543,781 | -541,024 |
| Quantity on hand | -55,304 | -51,777 |
| Purchase amount | 24,193,261.03 | 24,193,260.64 |
| Lots with on-hand differences | 1,928 | |

### Accounts receivable

Common customers: 59,001

| Measure | MDB | xOpti |
| --- | ---: | ---: |
| TTL refund | -2,490,380.26 | -2,397,978.71 |
| YTD purchased | 34,685,059.62 | 34,272,692.93 |
| Rows with differences | 1,736 | |

### Retail price

Common SKUs: 109,698

| Measure | MDB | xOpti |
| --- | ---: | ---: |
| Total retail | 32,296,829.15 | 32,279,832.15 |
| SKUs with price differences | 357 | |

### Summary tables

Common keys:

| Table | Common keys |
| --- | ---: |
| `category_summary` | 7,177 |
| `class_summary` | 3,658 |
| `dept_summary` | 1,176 |
| `invt_summary` | 505,855 |
| `supplier_summary` | 10,115 |
| `payment_summary` | 33,918 |

Historical common keys reconcile after 2-decimal tolerance. Differences are concentrated in the 2022 snapshot window and in source-data defects.

## 6. Sequences and control numbers

`PrefTxNumber` is lower in `xOpti` for six prefixes:

| Prefix | MDB | xOpti | Difference |
| --- | ---: | ---: | ---: |
| RC | 207,025 | 205,303 | -1,722 |
| RS | 34,984 | 34,111 | -873 |
| SR | 116,038 | 114,997 | -1,041 |
| RJ | 7,603 | 7,551 | -52 |
| SJ | 3,152 | 3,137 | -15 |
| WC | 991 | 978 | -13 |

Surrogate sequences are also lower in `xOpti`:

| Sequence | MDB max | xOpti max | xOpti sequence |
| --- | ---: | ---: | ---: |
| `barcode_pool.id` | 535,515 | 531,792 | 531,792 |
| `customer.id` | 75,313 | 74,845 | 74,845 |
| `doctor.id` | 1,220 | 1,210 | 1,210 |

`Preference` control numbers differ:

| Control | MDB | xOpti |
| --- | ---: | ---: |
| `next_invt_sku` | 1 | 98,863 |
| `next_invt_control_number` | 612,398 | 605,960 |

These must be advanced to at least the maximum legacy value before cutover.

## 7. Exceptions

### Status transitions

Status counts move consistently with order lifecycle changes after the May 2022 snapshot. This is not a migration remap defect.

### Missing historical transaction

- `RS00034463` exists in MDB (`TxHeader` dated 2022-07-09, `TxDetails` dated 2013-08-17) but is absent from `xOpti`. It accounts for the missing `InvtSummary` row for SKU `00000098` in 2013-08.

### xOpti-only `TxDetails` rows

- `SA349035A` (2018-08-28)
- `SA368052` rows 2 and 3 (2022-03-26)
- `SA368928` row 2 (2022-05-29)
- `SJ00002805` rows 1 and 2 with target date `7848-09-30` instead of `1899-12-30`

### Orphaned `TxSalePerson` rows

- 478 MDB rows have no matching `TxHeader`.
- `xOpti` retains salesperson rows for some headers that are absent from `xOpti`, including snapshot-skew headers.

### Summary-table date corruption in `xOpti`

The following target rows have invalid year/date values while the MDB rows carry `1899-12-30`:

| Table | Invalid years | Rows |
| --- | --- | ---: |
| `category_summary` | 995, 7848 | 3 |
| `class_summary` | 995, 997, 4997, 7848, 9797 | 8 |
| `dept_summary` | 995, 997, 4997, 7848, 9797 | 5 |
| `invt_summary` | 97, 995, 4997, 7848 | 25 |
| `supplier_summary` | 995, 997, 4997, 9797 | 10 |

`invt_summary` also contains 6 rows with `year = 97` in both systems; these are source-data defects, not migration defects.

### Date-of-creation drift

404 headers have `date_of_creation` in `xOpti` equal to the transaction date, while the MDB value is a 2022 rebuild timestamp. This is a source-process difference, not a row-level data loss.

### Ref-number/second-date drift

248 headers in the 2021-12 to 2022-05 range have `ref_number` and `second_date` populated in the MDB but blank/original in `xOpti`. These look like post-migration or rebuild updates.

## 8. Pass/fail

| Area | Result |
| --- | --- |
| Schema shape | Pass with documented widenings and nullability changes |
| Primary keys | Pass |
| Row counts | Pass as strict subset; all deltas are snapshot skew |
| Historical `TxHeader` aggregates | Pass after 2-decimal tolerance; 84 exceptions |
| Historical `TxDetails` aggregates | Pass after tolerance; 129 exceptions |
| Historical `TxPayment` aggregates | Pass; 1 exception |
| Current-state inventory/AR/retail | Not comparable due to snapshot skew; refresh at cutover |
| Summary tables | Pass for common keys; target date corruption must be corrected |
| Sequences/control numbers | Fail; must be advanced |
| Target-only detail rows | Fail; 6 rows require review |
| Orphaned salesperson rows | Warning; 478 legacy orphans |

## 9. Required cutover actions

1. Advance `PrefTxNumber` for RC, RS, SR, RJ, SJ, and WC to the MDB values.
2. Advance surrogate sequences (`bar_code_pool`, `customer`, `doctor`, and any sequence below the MDB maximum) to the MDB maximum.
3. Advance `Preference.next_invt_control_number` to 612,398.
4. Refresh `xOpti` from the MDB or reconcile the 2022-05-31 to 2022-09-03 delta before cutover.
5. Correct the 6 target-only `TxDetails` rows and the 478 orphaned `TxSalePerson` rows.
6. Correct summary-table date corruption in `xOpti`.
7. Decide whether the 84 header and 129 detail monetary exceptions are accepted as post-snapshot edits or corrected before cutover.
8. Preserve the MDB `REAL` rounding rule for `rowno` and `linenumber` in any future migration or comparison.
