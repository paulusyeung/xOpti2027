# Costing and lot rules (legacy baseline)

Scope: `Category.CostingMethod`, receipt/rejection/adjustment/issue cost
effects, deficits, lot reconciliation, and the characterization contract in
`src/xOpti.Domain/Rules/CostingPolicy.cs`. Source snapshot SHA-256
`55088a63b914f745a4bc6803ab07b11576b61e3d7c11e3f3c670bf11c2a5dd2e`.

Identifiers: `RULE-009` … `RULE-014`.

## Method selection

- `Category.CostingMethod = "2"` means **LIFO**; every other value means
  **FIFO/Average** (`AppOLTP.bas:221-226`, `:740-745`; `MIGRATION_NOTES.md:237`).
- Legacy lot selection only distinguishes LIFO (`FindLast`) from everything
  else (`FindFirst`). The costing *name* lives on the category; the ledger uses
  `Inventory.AverageCost` for COGS on POS lines (`frmSalesOrder.frm:2419`,
  `AppOLTP.bas:689-690`).
- xOpti models three methods explicitly (`CategoryCostingMethod.Fifo`,
  `Average`, `Lifo`); `CostingMethodResolver.FromLegacyCode` maps `"2"` to
  `Lifo` and defaults everything else to `Fifo` (or a caller-supplied
  `Average`). The migration must map the category rows rather than infer from
  the default.

`RULE-009` — method is per category, resolved through
`DepartmentCode + ClassCode + CategoryCode`; it is never per SKU or per
transaction.

## Receipt (`SR`)

`OLTP_IC_InvtLotRecord` (`AppOLTP.bas:194-218`):

- Lot identity is `(SKU, ControlNumber)`. Repeated occurrences of the same SKU
  in one receipt accumulate into the same lot.
- On insert: `DateReceived = TxHeader.DateOfEntry`,
  `SupplierCode = TxHeader.SupplierCode`, `QtyPurchased = Qty`,
  `QtyOnHand = Qty`,
  `UnitAmountPurchased = TxDetails.UnitCost - TxDetails.MarkDownAmount`,
  `TotalAmountPurchased = TxDetails.Amount`.
- On update: only `QtyPurchased`, `QtyOnHand`, and `TotalAmountPurchased`
  accumulate; the unit cost of the existing lot is **not** re-weighted.

`OLTP_IC_Inventory` (`:284-313`) maintains the SKU-level weighted average:

```
if (onHand + qty) <> 0 and AverageCost > 0:
    AverageCost = (lineAmount + AverageCost * onHand) / (onHand + qty)
else:
    AverageCost = UnitCost - MarkDownAmount
AverageCost = Abs(AverageCost)
```

`LeastSellingPrice` uses the same weighted formula with `UnitLSP`.
`QtyPurchaseOrder` is reduced by the received quantity and clamped at zero.
`DateLastReceived` advances only forward.

`RULE-010` — average cost is a moving weighted average at SKU level; lots keep
their own `UnitAmountPurchased`, and the two can diverge.

## Issue, rejection, adjustment

`OLTP_IC_InvtLotRecord` (`:219-247`) and `OLTP_PoS_InvtLotRecord`
(`:737-784`):

- Candidate lot list is all lots for the SKU, ordered oldest-first by
  `DateReceived` (FIFO/Average) or newest-first (LIFO). Legacy `FindFirst` /
  `FindLast` operate on the table's natural order, which xOpti makes explicit
  with `CostLayer.CompareOrder` = `(ReceivedOn, Sequence)`.
- Issue consumes the selected lot: `QtyUsed += Qty` and `QtyOnHand += Qty`
  where `Qty` is negative for issues. Refunds/returns reverse the signs
  (`:761-783`).
- `Inventory.QtyTotalOnhand` changes by `Qty`; `DateLastIssued` advances only
  forward.
- When the consumed quantity exceeds available lots, the remainder becomes a
  **deficit**: the layer's remaining quantity goes negative. Legacy leaves the
  negative lot in place; xOpti returns `DeficitQuantity` and a deficit
  `CostLayer` priced at the caller's `fallbackCost` so the sale is not
  blocked (`CostingPolicy.cs:113-124`).

`RULE-011` — sold-before-received stock must never abort a sale; it creates a
deficit layer that is cleared by the eventual receipt.
`RULE-012` — a receipt that reconciles a deficit is not a new cost basis for
the deficit quantity; over-covering a deficit is an error
(`CostLayer.Reconcile`, `CostLayer.cs:127-150`).

## xOpti consumption contract

`CostingPolicy.Issue` (`CostingPolicy.cs`):

| Method | Layer ordering | Unit cost charged |
| --- | --- | --- |
| `Fifo` | oldest `(ReceivedOn, Sequence)` first | each layer's own `UnitCost` |
| `Lifo` | newest first | each layer's own `UnitCost` |
| `Average` | oldest first, for traceability | blended `Σ(qty × unitCost) / onHand`, rounded to cost scale |
| any, exhausted | deficit at `fallbackCost` | `fallbackCost` for the shortfall |

Deficit layers are excluded from ordinary issue candidates and are only
changed through `Reconcile`. Rounding defaults to `MidpointRounding.AwayFromZero`
at `Money.StorageScale` (4 dp), matching the legacy `Format(..., "####0.00")`
two-decimal outputs at the presentation boundary.

## Worked examples from legacy sample data

Fixture: `tests/xOpti.Domain.Tests/Data/lots_sample.csv` (real `InvtLotRecord`
rows, PII-free). SKU `00000008`:

| Lot | Received | QtyPurchased | QtyUsed | QtyOnHand | UnitAmountPurchased |
| --- | --- | --- | ---: | ---: | ---: |
| `00029121` | 1998-07-29 | 24 | -88 | -64 | 4.3650 |
| `00041482` | 1999-02-23 | 24 | 0 | 24 | 4.3650 |
| `00057404` | 1999-09-28 | 24 | 0 | 24 | 4.2800 |
| `00142751` | 2002-08-23 | 24 | 0 | 24 | 2.9400 |

1. **FIFO, issue 26** — consumes `24 @ 4.365` from `00041482` and `2 @ 4.28`
   from `00057404`; total cost `104.76 + 8.56 = 113.32`. Test:
   `FifoCharacterization_consumes_real_legacy_layers_oldest_first`.
2. **LIFO, issue 2** — consumes `2 @ 2.94` from `00142751`; total `5.88`. Test:
   `LifoCharacterization_consumes_real_legacy_layers_newest_first`.
3. **Average, issue 10** — blended cost over 72 units:
   `(24×4.365 + 24×4.28 + 24×2.94) / 72 = 3.8617`; total `38.617`. Test:
   `AverageCharacterization_blends_real_legacy_layer_costs`.
4. **FIFO across six receipts** — SKU `00000551`, issue 3 consumes
   `2 @ 7.90` (lot `00188170`) and `1 @ 2.00` (lot `00295453`); total `17.80`.
   Test: `SixLayerSkuCharacterization_fifo_across_real_receipt_spread`.
5. **Deficit sale** — SKU `00000008`, issue 80 against 72 on hand leaves
   `8` short and flags a deficit layer at `fallbackCost = 4.365`. Test:
   `DeficitCharacterization_sale_beyond_real_onhand_flags_deficit_not_abort`.
6. **Deficit reconciliation** — the legacy `-64` lot is reconciled by receipts
   of 60 then 4; it stays a deficit after 60, clears to zero after 4. Test:
   `DeficitReconciliationCharacterization_covers_legacy_deficit_by_receipt`.

## Verification

```bash
dotnet test tests/xOpti.Domain.Tests --filter "FullyQualifiedName~LegacyCharacterizationTests"
```

All six cases above pass against the committed fixture. Any change to
`CostingPolicy` or `CostLayer` that breaks them is a parity regression until
the baseline is re-signed.
