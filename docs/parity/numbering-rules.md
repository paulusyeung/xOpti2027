# Control and transaction numbering (legacy baseline)

Scope: transaction-number families, per-prefix counters, control numbers,
sale-order conversion, and reprint behaviour. Source:
`AppMain.Bas:581-654`, `AppOLTP.bas:1042-1054`, `frmSalesOrder.frm:2676-3023`,
`frmMenuPoS.frm:35-85`. Snapshot SHA-256
`55088a63b914f745a4bc6803ab07b11576b61e3d7c11e3f3c670bf11c2a5dd2e`.

Identifiers: `RULE-021` … `RULE-025`.

## Per-prefix transaction counters

`GetNextTxNumber(prefix)` (`AppMain.Bas:616-654`) opens `PrefTxNumber`
exclusively, finds the row by `TxPrefix`, returns the stored `TxNextNumber`,
increments it, and formats the result as:

```
<prefix> + zero-pad(TxNextNumber, 8)      e.g. RC00023376
```

`PrefTxNumber` has exactly 13 rows in the snapshot, all accounted for:

| Prefix | Next number (snapshot) | Sign | Description | Remarks |
| --- | ---: | --- | --- | --- |
| `LA` | 1 | +ve | Layaway | |
| `PR` | 1 | +ve | Purchase Order | |
| `QT` | 1 | +ve | Quotation | |
| `RC` | 207025 | +ve | Retail Invoice | |
| `RJ` | 7603 | -ve | Stock Rejected | To Supplier |
| `RS` | 34984 | -ve | Restock, Refund | From Customer |
| `SA` | 1 | +ve | Sales Order | |
| `SJ` | 3152 | +/- | Stock Adjustment (decr/incr) | |
| `SR` | 116038 | +ve | Stock Received | From supplier |
| `TN` | 1 | +ve | Transfer In | |
| `TU` | 1 | -ve | Transfer Out | |
| `WC` | 991 | +ve | Wholesales Invoice | Using Supplier as Customer |
| `WR` | 70 | -ve | Wholesales Return | Using Supplier as Customer |

`RULE-021` — the eight active document prefixes in module scope are
`RC/RS/SR/RJ/SJ/WC/WR/SA`; `LA/PR/QT/TN/TU` are reserved and must not be
silently dropped from the migration.
`RULE-022` — counters are global per prefix, not per branch, and are read at
document creation time. The legacy `dbDenyWrite` lock is the only concurrency
control; PostgreSQL must allocate from a row lock or sequence while preserving
the exact human-readable shape (prefix + 8 digits, leading zeros).

## Control numbers

`GetNextControlNumber` (`AppMain.Bas:581-612`) reads
`Preference.NextInvtControlNumber`, increments it, and zero-pads to 8 digits.
Control numbers are shared by receipts, rejects, adjustments, invoices,
wholesale documents, and refunds; they are independent of the transaction
prefix. Lot identity is `(SKU, ControlNumber)`, so a control number must be
reserved once per document even when the document has multiple lines.

`RULE-023` — control numbers and transaction numbers are separate sequences;
neither may be reused after a failed save. Migration keeps both as data.

## Sale-order conversion

Saving an order uses `GetNextTxNumber("SA")` (`frmSalesOrder.frm:2676`), while
billing it allocates a fresh control number and `GetNextTxNumber("RC")`
(`:3000-3001`). The original `SA` row is then updated:

- `RefNumber = <new RC number>`
- `SecondDate = <delivery date entered on the invoice>`
- `Status = 3` (completed)

`RULE-024` — the `SA` number remains the customer-facing order number
(`"SA" & order number`); the `RC` number is the invoice number. Reports must
resolve the pair through `RefNumber`, not by reusing one number for both.
Voiding/refunding marks the order `Status = 2` and the invoice `Status = 1`
(`:3121-3175`).

## Reprints

The POS menu exposes `Re-Print Invoice`, `Re-Print Order`, and `Re-Print Claim
Form` (`frmMenuPoS.frm:35-85`). No reprint path calls `GetNextTxNumber` or
`GetNextControlNumber`; reprints re-render the original document and its
stored numbers. `TxHeader.PrintCounter` exists in the schema but has no writer
in the VB source.

`RULE-025` — reprinting never consumes a counter and never changes the
document identity. Print auditing, if required, must be additive and must not
alter `TxNumber`/`ControlNumber`; `PrintCounter` is unverified legacy data and
must be migrated verbatim.

## Verification

- All 13 `PrefTxNumber` rows were read from the production snapshot with
  `mdb-export "$SYNERGY_MDB" PrefTxNumber`.
- Prefix usage was cross-checked against `GetNextTxNumber` call sites:
  `RC/RS/SA` in `frmSalesOrder`, `SR` in `frmStockReceived`/`frmStockRecEnhenced`,
  `RJ` in `frmStockReject`, `SJ` in `frmStockAdjustment`/`frmStockTake`,
  `WC` in `frmWholesaleInvoice`, `WR` in `frmWholesaleReturn`.
- The 8-digit shape is implemented by `String((8 - Len(n)), "0") & n`
  (`AppMain.Bas:605`, `:646`).
