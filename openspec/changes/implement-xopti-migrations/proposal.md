# Proposal

## Why

The legacy eOptical 6.1.184 data must move from `SynergyV.mdb` into PostgreSQL `xOpti` for the hard cutover, but today that work is manual and only partially scripted under `tools/legacy-migration`. A repeatable, idempotent `xOpti.Migrations` runner is needed so extraction, staging, transformation, reconciliation, sequence advancement, and cutover checks can be rehearsed and executed consistently instead of by hand.

## What Changes

- Add an `xOpti.Migrations` .NET 10 console runner (and solution scaffolding) that orchestrates ELT migration using Linux-native `mdbtools` streaming directly into PostgreSQL.
- Implement stream-based MDB extraction piping `mdb-export` stdout directly into PostgreSQL `COPY` (`legacy` schema) using ASCII Unit Separator (`\x1f`) delimiters and null markers (`-0 '\N'`), avoiding multi-gigabyte disk writes.
- Implement versioned, idempotent, set-based SQL transforms from `legacy` into the normalized `xOpti` schema (`public`, snake_case), handling Access `-1`/`0` booleans, `REAL` float drift on line numbers, `1900-01-00` date normalization, and text encoding cleanup.
- Target the normalized 1:1 `xOpti` relational schema directly, deferring domain-level surrogate key redesign until entity models are built.
- Handle known historical anomalies explicitly (quarantine or synthetic stub headers for orphaned `TxSalePerson` and `TxDetails` rows) so foreign key constraints do not abort migration.
- Implement automated reconciliation checks (row counts, sales/tax/payment/refund totals, inventory quantity and cost by SKU/lot, AR/AP balances, control-number sequences, order status counts) with pass/fail output.
- Advance PostgreSQL sequences and `Preference`/`TxNextNumber` alphanumeric control numbers (`RC`, `RS`, `SR`, `RJ`, `SJ`, `WC`) using regex-extracted numeric maximums.
- Provide dry-run, freeze-window sync (fast full staging reload + set-based upsert to capture in-place legacy edits), and cutover modes with read-only source access.

## Capabilities

### New Capabilities

- `legacy-data-migration`: automated, repeatable, idempotent port of legacy Access (`SynergyV.mdb`) data into PostgreSQL `xOpti`, including extraction, staging, transformation, reconciliation, sequence advancement, and cutover handling.

### Modified Capabilities

None.

## Impact

- Affected code: new `src/xOpti.Migrations` project, solution file, and supporting migration scripts under `tools/legacy-migration`.
- Affected systems: PostgreSQL `xOpti` (and a staging/comparison database), `SynergyV.mdb` (read-only source), `mdbtools`, and `.env`-based configuration.
- Dependencies: .NET 10, Npgsql, EF Core/Npgsql where schema access is needed, and the external `mdbtools` binaries.
- No application API or frontend behavior changes are included in this change.
