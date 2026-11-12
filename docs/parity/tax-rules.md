# Tax, discount, and rounding rules (legacy baseline)

Scope: tax methods `N/B/G/P/g/p`, markdown/discount handling, rounding, and
refund behaviour. Source: `frmSalesOrder.frm:2389-2464` (authoritative
per-line calculation), `frmPriceWizard.frm:276-286` (code semantics),
`AppOLTP.bas:1056-1103` (refund clone). Snapshot SHA-256
`55088a63b914f745a4bc6803ab07b11576b61e3d7c11e3f3c670bf11c2a5dd2e`.

Identifiers: `RULE-015` … `RULE-020`.

## Methods

`TaxA` = GST component, `TaxB` = PST component. `TaxARate`/`TaxBRate` come from
`Preference` and are stored as percentages (5 and 7 in the snapshot).

| Code | Meaning | GST | PST | Gross |
| --- | --- | --- | --- | --- |
| `N` | Exempt / no tax | 0 | 0 | `amount` |
| `B` | GST + PST | `round(amount × A / 100)` | `round(amount × B / 100)` | `amount + GST + PST` |
| `G` | GST only | `round(amount × A / 100)` | 0 | `amount + GST` |
| `P` | PST only | 0 | `round(amount × B / 100)` | `amount + PST` |
| `g` | GST included | `amount − round(amount × 100 / (100 + A))` | 0 | legacy: `amount + GST` |
| `p` | PST on GST | `round(amount × A / 100)` | `round((amount + GST) × B / 100)` | `amount + GST + PST` |

Legacy selection is a `Select Case` on the `TxDetails.TaxCode` string; `Case
Else` and `Null` produce zero tax (`frmSalesOrder.frm:2425-2448`).

`RULE-015` — rates are per receipt era (GST 7% → 6% → 5%; PST 7%), read from
`Preference` at posting time. Tax is not recalculated historically; persisted
`TaxA`/`TaxB` are the source of truth for migrated documents.
`RULE-016` — `p` taxes the GST-inclusive base, unlike `B`.

## Rounding

Legacy rounds each component with `Format(value, "####0.00")` immediately after
multiplication, before summing (`:2430-2444`). This is half-even/format
rounding in VB6 and is the historical source of one-cent differences.

xOpti rounds with `MidpointRounding.AwayFromZero` at a configurable scale
(default 2) and applies it per component before summing
(`TaxCalculator.cs:19-79`). Characterization vectors from legacy data pin the
observable result; do not change the rounding mode without re-running them.

`RULE-017` — round each of GST and PST separately to two decimals, then sum;
never round the combined tax once.

## Discounts and markdown

- Line markdown is stored as `TxDetails.MarkDownPercent` and
  `MarkDownAmount`; the sold amount is the grid `Amount` after markdown, and
  tax is calculated on that amount (`frmSalesOrder.frm:2409-2411`).
- Receipt cost uses `UnitCost − MarkDownAmount` for the lot's
  `UnitAmountPurchased` (`AppOLTP.bas:206`, `:240`).
- `TxHeader.SalesDiscount` exists and is negated on the clone-refund path
  (`AppOLTP.bas:1089`), but no writer is present in the VB source. Treat the
  field as **unverified legacy data**: migrate it verbatim, default to zero,
  and confirm with the customer whether any historical discount scheme used it.

`RULE-018` — tax is calculated on the post-markdown line amount; markdown never
changes the stored unit cost except through the lot receipt formula above.

## Refunds

- The `frmSalesOrder` refund path negates header totals and line
  `Qty`/`Amount` and reuses the original tax codes (`frmSalesOrder.frm:3121-3290`).
  It does not recompute tax.
- `TaxCalculator` rejects a negative base by design; refunds are represented by
  negated persisted totals, not by calling the calculator with negative money.
- The clone path `PoS_Refund` copies `AmountTender` unchanged
  (`AppOLTP.bas:1146-1179`); the `frmSalesOrder` path writes refund tenders
  through `SaveRefund_TxPayment`. Reconcile both before implementing refund
  reporting.

`RULE-019` — refund tax is the negated persisted tax, never a fresh
calculation.
`RULE-020` — a refund must reference the original document (`TrackingNumber`
for clone refunds; `RefNumber`/status transitions for order refunds).

## Verification vectors

Fixture: `tests/xOpti.Domain.Tests/Data/tax_lines_sample.csv`. The
characterization test asserts GST, PST, and gross for every row.

| Control | Code | Amount | GST rate | PST rate | Legacy GST | Legacy PST | Legacy gross |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: |
| `00063493` | N | 95.00 | 0 | 0 | 0.00 | 0.00 | 95.00 |
| `00063501` | B | 89.48 | 7% | 7% | 6.26 | 6.26 | 102.00 |
| `00276438` | G | 16.98 | 6% | 0 | 1.02 | 0.00 | 18.00 |
| `SA312305` | P | 349.00 | 0 | 7% | 0.00 | 24.43 | 373.43 |
| `SA78144` | g | 25.00 | 7% | 0 | 1.64 | 0.00 | 26.64 *(see gap below)* |
| — | p | 100.00 | 5% | 8% | 5.00 | 8.40 | 113.40 *(synthetic test only)* |

Tests: `LegacyCharacterizationTests.TaxCharacterization_reproduces_legacy_tax_amounts_and_totals`
and `TaxCalculatorTests` (`Method_N/B/G/P/g/p`).

### Known parity gaps

1. **`g` gross-total divergence.** Legacy computes the included GST by
   extracting `amount/(1+rate)` and then sets gross to `amount + GST`
   (`frmSalesOrder.frm:2438-2441`, `:2456`). For `SA78144` that is
   `25.00 + 1.64 = 26.64`. `TaxCalculator` correctly treats the amount as
   GST-inclusive and returns gross `25.00`. The legacy behaviour double-counts
   the extracted tax in the gross total. This needs an explicit customer/parity
   decision before `g` invoices can be called verified; the legacy vector is
   therefore excluded from the passing characterization fixture and must not be
   copied blindly into report totals.
2. **`p` has no production rows** in the snapshot; only the synthetic
   `TaxCalculatorTests.Method_p_stacks_pst_on_gst_inclusive_base` vector exists.
3. **`g` is rare** (5 production lines); `P` has 4, `B` 96k, `G` 40, `N` 709k.
   Report totals for `g`/`P` are low-volume but still legally relevant.

These gaps are recorded so module work does not silently assume verified
parity. They are not resolved by this baseline.
