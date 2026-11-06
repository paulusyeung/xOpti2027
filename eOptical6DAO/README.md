# eOptical6DAO

Legacy **Visual Basic 6** optical-retail point-of-sale and inventory management system.

- **Product:** eOptical VI, version 6.1.184
- **Description:** "Optical Retail System"
- **Vendor:** Synergy Technologies, Inc. (copyright 1995-2003)
- **Project file:** `OPTICAL.VBP`
- **Startup object:** `Sub Main` (`OfxInitExit.bas`)
- **Status:** Archived legacy source tree. This is a reference implementation, not a maintainable modern codebase.

This folder is the only content of the `xOpti2027` repository. It contains the full source tree, a compiled `eOptical.EXE`, an installer, Crystal Reports definitions, and several database snapshots.

## Tech Stack

| Area | Technology |
| --- | --- |
| Language / runtime | Visual Basic 6 (COM desktop application) |
| Database | DAO 3.6 / Microsoft Access Jet (`SynergyV.mdb`) |
| Reporting | Crystal Reports (`crystl32.ocx`, `.rpt` files) |
| UI controls | Sheridan 3D / SS controls, `MSCOMCTL.OCX`, `MSCHRT20.OCX`, `MSMASK32.OCX`, `MSRDC20.OCX`, `SSCALB32.OCX`, `SSCALA32.OCX` |
| Application framework | "Start Developing for VB" (SDVB / Ofx) framework (`Ofx*.bas`, `Ofx*.cls`, "SDVB autocode" comments) |
| UI model | Single-document interface (`OFXOPT_MDI = 0`) with switchboard-style menus (`frmMenuPoS`, `frmMenuIC`, `frmMenuCoding`, ...) |

The `OPTICAL.VBP` conditional compilation constants disable the framework's alternative database backends:

```
DBOPT_JET = 0 : DBOPT_ODBC = 0 : DBOPT_RDO = 0 : DBOPT_VBSQL = 0
```

Although the Ofx framework includes a `CDatabaseHolder` abstraction, the application uses direct DAO calls throughout.

## Scale and Layout

- Approximately **97,000 LOC** of root source
- **110 `.frm`** forms, **42 `.bas`** modules, **8 `.cls`** classes
- Plus 14 stale `.FrK` / `.VBT` / `.baK` backup variants
- Repository size (git pack): approximately **176 MiB**

Largest source files (by lines):

| File | LOC |
| --- | --- |
| `frmSalesOrder.frm` | 4,182 |
| `frmCustomer.frm` | 4,129 |
| `frmInfoCustomer.frm` | 3,710 |
| `frmStockTake.frm` | 2,928 |
| `frmInvt.frm` | 2,871 |
| `MSODBC.Bas` | 2,117 |
| `frmWholesaleInvoice.frm` | 2,107 |
| `frmWholesaleReturn.frm` | 2,106 |
| `frmInfoSKU.frm` | 2,014 |

Key directories:

| Path | Contents |
| --- | --- |
| `Setup/` | `eOptical.msi` and InstallShield `eOptical.wsi` installer artifacts |
| `Rpt/` | Core Crystal Reports definitions and matching `.txt` exports |
| `Rpt DAO/` | DAO data-source variants; override `Rpt` for the same report name |
| `Rpt ODBC/` | ODBC data-source variants; override `Rpt DAO` and `Rpt` for the same report name |
| `Rpt ODBC/Pacific/`, `Rpt ODBC/Richmond/` | Customer-specific report overlays (Pacific and Richmond), including nested `20220911` and `HST` variants |
| `Patches/2015-05-02/` | SQL repair scripts for missing transaction headers |
| `Graphics/`, `Glasses Picture/` | Icons, bitmaps and product images |
| `OpticalRbs/`, `OpticalPacific/`, `OpticalRmd/` | Customer database snapshots and JobGen Pro installer |

## Functional Scope

The system covers the full retail/wholesale workflow of an optical store:

- **Point of sale:** order entry, retail and wholesale invoice, refunds, tender/payment, claim reprint, order/invoice reprint, daily closing.
- **Inventory control:** stock received, stock rejected, stock adjustment, stock transfer, stock take and import, lot and serial tracking, bar-code pools and tags.
- **Master data:** customers, suppliers, staff, doctors, inventory/SKU, brands, classes, categories, departments, materials, cities, provinces, countries, payment methods, branches.
- **Optical specifics:** prescriptions (`CustomerPresContact`, `CustomerPresLens`, `CustomerMedical`), lens/contact/frame order details, insurance/claims, RBIC costing workbook.
- **Analytics:** OLAP sales, cost, margin, sales by LSP, order-in-progress; GST/PST tax handling; multi-branch support; preferences.
- **Reporting:** customer, inventory, sales, orders, wholesale, prescriptions, insurance, statements, journals, bar-code tags, and more (about 90 report definitions under `Rpt/`).

### Transaction Types

| Code | Meaning |
| --- | --- |
| `SR` | Stock Received from supplier |
| `RJ` | Stock Rejected to supplier |
| `SJ` | Stock Adjustment (increase/decrease) |
| `RC` | Retail Invoice / claim |
| `RS` | Retail Refund |
| `WC` | Wholesale Invoice |
| `WR` | Wholesale Return |
| `SA` | Sale Order |

## Database Model

The database is transaction-centric, with a set of **pre-computed OLTP summary tables**. `AppOLTP.bas` posts each transaction into rollup tables after it is committed.

Core tables:

- `TxHeader`, `TxDetails`, `TxPayment`, `TxSalePerson`
- `TxSOrderLens`, `TxSOrderCont`, `TxSOrderFrame`, `TxSOrderExtra`, `TxSOrderAdd`

Summary / rollup tables:

- `InvtSummary`, `CategorySummary`, `ClassSummary`, `DeptSummary`
- `SupplierSummary`, `PaymentSummary`, `InvtLotRecord`

Master and reference tables:

- `Inventory`, `RetailPrice`, `Customer*`, `Supplier*`, `Staff`, `Security`, `Preference`
- `Category`, `Class`, `Dept`, `Brand`, `Material`, `City`, `Province`, `Country`
- `InvtSTHeader`, `InvtSTDetails`, `InvtSTImport` (stock take)

Costing is supported through inventory methods (`InvtMethod`, including FIFO/LIFO) and lot records (`InvtLotRecord`).

## Architecture Notes

- **Entry point:** `Sub Main` in `OfxInitExit.bas` calls `ofx_Initialize()`, shows the splash screen, then `InitInstance()` in `AppMain.Bas`, which loads the SDI main form (`AppSDI.Frm`).
- **Business logic lives in form event handlers.** There is no service, domain, or repository layer.
- **Database access is scattered and hard-coded.** Each form opens `SynergyV.mdb` directly.
- **The database must be present in the process working directory.** Paths are relative, not configurable.
- **Posting is performed by `AppOLTP.bas`**, which maintains denormalized summary tables for fast reporting and OLAP.
- **Reports are rendered with Crystal Reports 32-bit OCX**, driven by formulas and selection formulas set from the calling forms.
- **The framework's multi-database abstraction is unused in practice**, even though it is present in the source.

## Risks and Code Quality

1. **Hard-coded database coupling.** `"SynergyV.mdb"` is referenced in 59 files across 70 `OpenDatabase` calls; 55 of the 110 forms open the database directly. There is no central connection configuration.
2. **Plaintext passwords.** `IsSecurityPassed()` in `AppValidation.bas` compares `Staff.Password` with a plain string equality check. A default user `9999` with security level 1 is auto-created by `GetDefaultUser()` when absent.
3. **Fragile error handling.** There are more than 400 `On Error Resume Next` sites; errors are frequently swallowed, including in data-access paths.
4. **SQL injection and quoting fragility.** Queries are built by string concatenation (hundreds of expressions), with user/input values interpolated directly into SQL.
5. **No automated tests and no dependency isolation.** UI, business logic, and persistence are tightly interleaved.
6. **Stale and duplicated artifacts.** `.FrK`, `.VBT`, `.baK`, `VB1D.tmp`, and duplicated report sets (`Rpt`, `Rpt DAO`, `Rpt ODBC`) remain in the tree.
7. **No source-level build reproducibility.** The project depends on several discontinued COM controls and a specific Crystal Reports runtime.

## Repository Hygiene Concern

**Production customer database snapshots are committed to git and tracked.** The git pack is roughly 176 MiB and includes:

| File | Uncompressed database size |
| --- | --- |
| `OpticalRbs/SynergyV_20081208.rar` | 233 MB (2008) |
| `OpticalPacific/SynergyV_20110923.rar` | 468 MB (2011) |
| `OpticalRmd/SynergyV_20160315.7z` | 913 MB (2016) |
| `SynergyV.mdb` (root) | 2.2 MB schema/sample database |
| `eOptical.EXE` | 6.2 MB compiled binary |
| `Setup/eOptical.msi` | 21 MB installer |
| `OpticalRmd/JobGen Pro/jgp5ins.exe` | 7.2 MB installer |

These databases likely contain customer PII, medical/prescription data, payment details, and other sensitive business records. They should not be stored in source control. The `.gitignore` excludes `*.rar`, `*.7z` and `*.bak`, but these files were committed before that rule existed and are still tracked.

## Recommendation

Treat `eOptical6DAO` as an **archival reference and behavioral specification** for a rewrite/migration rather than a maintainable base. Any modernization effort should:

1. Extract and document the schema and transaction flows from `AppOLTP.bas` and the main forms.
2. Remove committed customer databases and large binaries from the repository history.
3. Replace direct DAO calls with a data-access layer and a configurable connection.
4. Introduce hashed credentials, centralized authorization, and parameterized queries.
5. Rebuild the reporting layer on a supported engine and migrate data into a modern relational database.

## Further Analysis Options

The following deep dives can be produced on request:

- Full database schema extraction (tables, columns, keys, relationships)
- Module-by-module call and data-flow map
- Security and PII audit of the committed snapshots
- Detailed modernization and data-migration plan
