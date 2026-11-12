# Transaction and posting rules (legacy baseline)

Scope: the posting behaviour of `eOptical6DAO/AppOLTP.bas` for `SR`, `RJ`, `SJ`,
`RC`, `RS`, `WC`, `WR`, and `SA`, plus the document-save entry points that call
it. Source snapshot: `$SYNERGY_MDB`, SHA-256
`55088a63b914f745a4bc6803ab07b11576b61e3d7c11e3f3c670bf11c2a5dd2e`.

Identifiers: `RULE-001` … `RULE-013`. Cite these IDs from module changes.

## Prefix taxonomy

| Prefix | Meaning | Sign of `Qty` / `Amount` | Source table |
| --- | --- | --- | --- |
| `SR` | Stock received from supplier | +ve | `PrefTxNumber` |
| `RJ` | Stock rejected to supplier | -ve | `PrefTxNumber` |
| `SJ` | Stock adjustment (increase/decrease) | +/- | `PrefTxNumber` |
| `RC` | Retail invoice | +ve | `PrefTxNumber` |
| `RS` | Restock / refund from customer | -ve | `PrefTxNumber` |
| `WC` | Wholesale invoice (supplier as customer) | +ve | `PrefTxNumber` |
| `WR` | Wholesale return | -ve | `PrefTxNumber` |
| `SA` | Sales order (not a stock movement until billed) | +ve | `PrefTxNumber` |
| `LA`, `PR`, `QT`, `TN`, `TU` | Layaway, purchase order, quotation, transfer in/out | reserved counters | `PrefTxNumber` |

`OLTP_IC` dispatches on the first two characters of the transaction number; the
prefix is the only transaction-type discriminator (`AppOLTP.bas:9-38`).

## Inventory-control posting — `OLTP_IC` (`AppOLTP.bas:9-38`)

Called by `frmStockReceived` (`SR`, line 1272), `frmStockRecEnhenced` (`SR`, line
1411), `frmStockReject` (`RJ`, line 1022), `frmStockAdjustment` (`SJ`, line 813),
and `frmStockTake` (`SJ`, line 2539). Order of effects:

| # | Procedure | Target table | `SR` | `RJ` | `SJ` |
| --- | --- | --- | --- | --- | --- |
| 1 | `OLTP_IC_SupplierSummary` (`:42-91`) | `SupplierSummary` | `QtyPurchased += TotalQty`, `AmtPurchased += TotalAmount` | `QtyRejected += TotalQty`, `AmtRejected += TotalAmount` | skipped |
| 2 | `OLTP_IC_InvtSummary` (`:95-158`) | `InvtSummary` (SKU/year/month) | `qtyCD += Qty`, `AmtCD += Amount`, `QtyPurchased += Qty`, `AmtPurchased += Amount` | `qtyCD += Qty`, `AmtCD += Amount`, `QtyRejected += Qty`, `AmtRejected += Amount` | `qtyCD += Qty`, `AmtCD += Amount`; sign of `Qty` routes to `QtyAdjDecr`/`QtyAdjIncr` |
| 3 | `OLTP_IC_InvtLotRecord` (`:161-258`) | `InvtLotRecord` | creates/updates lot keyed by `SKU + ControlNumber`; sets `DateReceived`, `SupplierCode`, `QtyPurchased`, `QtyOnHand`, `UnitAmountPurchased = UnitCost - MarkDownAmount` | consumes `FindFirst` (FIFO/Average) or `FindLast` (LIFO) lot; `QtyUsed += Qty` (negative), `QtyOnHand += Qty` | same as `RJ`, `SupplierCode` from `Inventory` |
| 4 | `OLTP_IC_Inventory` (`:260-330`) | `Inventory` | weighted average cost and least-selling-price; `QtyTotalOnhand += Qty`; reduces/clamps `QtyPurchaseOrder`; updates `DateLastReceived` | `QtyTotalOnhand += Qty`; updates `DateLastIssued` | `QtyTotalOnhand += Qty` |
| 5 | `OLTP_IC_Category` / `_Class` / `_Dept` (`:332-…`) | `CategorySummary`, `ClassSummary`, `DeptSummary` (monthly) | purchased/sold/CD aggregates | rejected aggregates | adjustment in/out aggregates |
| 6 | `OLTP_IC_BarCode` (`:545-…`) | `BarCodePool` | `SR` only | — | — |

`RULE-001` — `SJ` never writes `SupplierSummary`. `RULE-002` — lots are created
only for `SR`; rejection/adjustment always mutate an existing lot and may drive
`QtyOnHand` negative (deficit), never insert a replacement cost layer.
`RULE-003` — monthly summary rows are keyed by `(SKU|Department|Class|Category,
Year, Month)` and created on first use with `FirstDateOfMonth`.

## Point-of-sale posting — `OLTP_PoS` (`AppOLTP.bas:588-596`)

Called by `frmSalesOrder` when saving an invoice (`:3023`) or refund (`:3175`),
`frmWholesaleInvoice` (`:1695`), and `frmWholesaleReturn` (`:1714`).

| # | Procedure | Target table | `RC` / `WC` (invoice) | `RS` / `WR` (refund/return) |
| --- | --- | --- | --- | --- |
| 1 | `OLTP_PoS_CustomerSummary` (`:598-647`) | `CustomerAccounts` | `RC`: `YTDAmtPurchased += TotalSale`, `LastPurchaseDate` | `RS`: `TTLAmtRefund += TotalSale`; `WC`/`WR` skipped |
| 2 | `OLTP_PoS_InvtSummary` (`:649-703`) | `InvtSummary` | `qtyCD -= Qty`, `AmtCD -= Amount`, `QtySold += Qty`, `AmtSold += Amount`, `AmtCostOfGoodsSold += Qty * UnitCost` | `qtyCD -= Qty`, `AmtCD -= Amount`, `QtyRestocked += Qty`, `AmtRestocked += Amount` |
| 3 | `OLTP_PoS_InvtLotRecord` (`:705-794`) | `InvtLotRecord` | consumes FIFO/average first or LIFO last; `QtyUsed -= Qty`, `QtyOnHand -= Qty` | restocks same lot ordering; `QtyUsed -= Qty`, `QtyOnHand += Qty`; creates a lot if none exists |
| 4 | `OLTP_PoS_Inventory` (`:796-849`) | `Inventory` | `QtyTotalOnhand -= Qty`; `QtySaleOrder` reduced/clamped; `DateLastIssued` | `QtyTotalOnhand -= Qty` (line `Qty` is negative, so this restocks); `DateLastReceived` |
| 5 | `OLTP_PoS_Category` / `_Class` / `_Dept` (`:851-1035`) | monthly summaries | sold/CD/COGS aggregates | restocked/CD aggregates |

`RULE-004` — `SA` is not posted through the invoice branches. Saving a sales
order calls `OLTP_PoS_Inventory` directly (`frmSalesOrder.frm:2703`), which adds
`Qty` to `Inventory.QtySaleOrder` (`AppOLTP.bas:823-824`). Billing the order
creates an `RC` invoice, sets the original `SA` header `Status = 3` and
`RefNumber = <new RC number>` (`frmSalesOrder.frm:2992-3023`); the `RC` posting
then reduces `QtySaleOrder` and `QtyTotalOnhand`.
`RULE-005` — voiding/refunding a completed order sets the `SA` header `Status =
2` and, when the original was completed (`Status = 3`), sets the original
invoice `Status = 1` (refunded) and restocks via `OLTP_PoS` (`frmSalesOrder.frm:3121-3175`).

## Document save and payment effects

- Invoice save (`SaveInvoice`, `frmSalesOrder.frm:2992`): allocate control
  number and `RC` number, write `TxHeader`, `TxSalePerson`, `TxSOrderExtra`,
  `TxDetails`, `TxPayment`, then post (`:3023`).
- Order save (`SaveOrder`, `:2676`): allocate control/`SA` numbers, write the
  same document tables, then update `Inventory.QtySaleOrder` and
  `PaymentSummary` only (`:2700-2703`).
- Refund save (`SaveRefund`, `:3121`): allocate control number and `RS` number;
  header amounts and line quantities are negated in `SaveRefund_TxHeader`
  (`:3219`) and `SaveRefund_TxDetails_Each` (`:3187`).
- Payment summary (`OLTP_PoS_PaymentSummary`, `AppOLTP.bas:1238-1309`): grouped
  by `TxPayment.Type` and date. `AmountTender > 0` increments
  `AmtSold`/`NumberOfSold`; `AmountTender < 0` increments
  `AmtRefund`/`NumberOfRefund`; change is recorded against payment code `0` in
  `AmtChanged` (`:1283-1304`).
- `PoS_Refund` (`AppOLTP.bas:1042-1232`) is the alternate clone-based refund
  path: new `RS` header, copied details with negated `Qty`/`Amount`, copied
  payment lines **without** negating `AmountTender`, one sales-person row, and
  copied order-extra flags. `RULE-006` — both refund paths must be reconciled;
  the `frmSalesOrder` path negates header totals while the clone path negates
  header totals and details but not tender amounts.

## Header/detail/payment/audit field contract

`TxHeader` carries the document identity (`ControlNumber`, `TxType`,
`TxNumber`, `DateOfEntry`, `RefNumber`, `TrackingNumber`), party (`CustomerID`,
`SupplierCode`), totals (`TotalCost`, `TotalSale`, `TaxA/B/C`,
`OtherCharges`, `GrossSale`, `SalesDiscount`, `TotalAmount`, `TotalQty`,
`PreviousPaid`, `ThisPaid`, `Change`), links (`PaymentLink`,
`SalesPersonLink`), `Status`, and `PrintCounter`. `TxDetails` repeats the
control number/type and stores per-line `Qty`, `UnitAmount`, `UnitCost`,
`UnitLSP`, markdown, `Amount`, and `TaxCode`. `TxPayment` stores tender type,
card/authorization references, amount, exchange rate, surcharge, and total.
`TxSalePerson` and `TxSOrderExtra` are one-row-per-document side tables.

`RULE-007` — every posting write is per-document and non-transactional in the
legacy code (separate DAO recordsets, no rollback). xOpti must post a document
atomically and expose idempotent re-posting.
`RULE-008` — summary tables are mutable aggregates, not derivable history; they
must be rebuilt from documents during migration and compared against the
legacy snapshot before cutover.

## Verification

- Every claim above names the source procedure and target table.
- Prefix rows match the 13 rows in the production `PrefTxNumber` table
  (`docs/parity/numbering-rules.md`).
- Posting summaries are compared against migrated data by the migration
  reconciliation tests (`tools/legacy-migration/reports/reconciliation*.md`).
