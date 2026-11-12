#!/usr/bin/env python3
"""Build the Richmond Crystal report catalogue into docs/parity/reports.csv (task 3.3).

Effective resolution follows `Rptlibvalid.SetRptFileName`, which looks for
`Rpt odbc\\<Name>.rpt` first and falls back to `Rpt\\<Name>.rpt`. The production
install copies the chosen store's overlay into `Rpt odbc\\`, so the effective
catalogue uses the precedence required by the change:

    Rpt ODBC/Richmond/HST > Rpt ODBC/Richmond > Rpt ODBC > Rpt DAO > Rpt

for each logical report name (case-insensitive file stem). Every effective
report gets its Crystal definition from the sibling `.txt` export, which is the
only in-repo source for parameters, selection formulas, and data dependencies.

Criticality is a proposed rule, not a customer decision: task 3.4 records the
in-scope/deferred and sign-off outcome. `signoff_status` starts as `pending`.
"""

from __future__ import annotations

import argparse
import csv
import re
import subprocess
import sys
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
LEGACY = ROOT / "eOptical6DAO"

TIERS = [
    ("hst", "Rpt ODBC/Richmond/HST"),
    ("richmond", "Rpt ODBC/Richmond"),
    ("odbc", "Rpt ODBC"),
    ("dao", "Rpt DAO"),
    ("rpt", "Rpt"),
]

# Financial or legally significant outputs. Used only to propose criticality.
FINANCIAL = re.compile(
    r"invoice|sales|journal|receipt|payment|refund|tax|hst|gst|pst|ledger|"
    r"daily cash|statement|deposit|credit",
    re.I,
)
OPERATIONAL = re.compile(
    r"stock|inventory|receive|received|reject|adjust|transfer|purchase|order|"
    r"wholesal|packing|barcode|bar code|label|tag",
    re.I,
)

PARAM_TYPE_PATTERNS = [
    (re.compile(r"^Ask(TxNumber|Invoice|Order)?(From|To)$", re.I), "document-number"),
    (re.compile(r"^Ask.*Date(From|To)?$|^AskDate", re.I), "date"),
    (re.compile(r"^AskPct", re.I), "percent"),
    (re.compile(r"^Ask(No|X|Zero|Exclude|Include|Has|With|Only)[A-Z]", re.I), "boolean"),
    (re.compile(r"^Ask(Days|Qty|Number|Amount|Count)$", re.I), "number"),
    (re.compile(r"^Ask(Dept|Class|Cat|Category|Customer|Country|Supplier|Brand|Province)", re.I), "text"),
]

TABLE_REF = re.compile(r"\{([A-Za-z_][A-Za-z0-9_ ]*)\.([A-Za-z_][A-Za-z0-9_ ]*)\}")
LEGACY_PROFILE = ROOT / "docs/parity/legacy-profile.csv"
ASK_PARAM = re.compile(r"\{@(Ask[A-Za-z0-9_]*)\}")
QUERY_PARAM = re.compile(r"\{\?([^}]*)\}")


def strip_instance(name: str) -> str:
    """Crystal aliases a table used twice as TxHeader_1, TxDetails_2, ..."""
    return re.sub(r"_\d+$", "", name.strip())


def load_definition(rpt: Path) -> tuple[str, Path | None]:
    for candidate in rpt.parent.iterdir():
        if candidate.suffix.lower() == ".txt" and candidate.stem.lower() == rpt.stem.lower():
            return candidate.read_text(encoding="latin-1", errors="replace"), candidate
    return "", None


def parse_definition(text: str) -> dict[str, object]:
    tables: set[str] = set()
    for table, _field in TABLE_REF.findall(text):
        table = strip_instance(table)
        if table and not table.startswith(("@", "?")):
            tables.add(table)

    parameters = sorted({m for m in ASK_PARAM.findall(text)})
    query_parameters = sorted({m.strip() for m in QUERY_PARAM.findall(text) if m.strip()})

    def param_type(name: str) -> str:
        for pattern, label in PARAM_TYPE_PATTERNS:
            if pattern.search(name):
                return label
        return "text"

    parameter_specs = [
        f"{name}:{param_type(name)}" for name in parameters
    ] + [f"{name}:query-link" for name in query_parameters]

    selection = ""
    match = re.search(r"4\.1 Record Selection Formula\s*\n(.*?)\n4\.2", text, re.S)
    if match:
        selection = " ".join(match.group(1).split())

    title = ""
    match = re.search(r"Report File:\s*(.+)", text)
    if match:
        title = match.group(1).strip()

    return {
        "tables": sorted(tables),
        "parameters": parameter_specs,
        "selection": selection,
        "title": title,
    }


METADATA_FIELDS = {
    "Title": "Subject",
    "Subject": "Author",
    "Comments": "Template",
    "Template": "Last Saved By",
    "Last Saved Time/Date": "Create Time/Date",
    "Number of Pages": None,
}


def known_legacy_tables() -> set[str]:
    if not LEGACY_PROFILE.exists():
        return set()
    with LEGACY_PROFILE.open(newline="", encoding="utf-8") as handle:
        return {row["table"] for row in csv.DictReader(handle) if row.get("table")}


def binary_table_fallback(rpt: Path, tables: set[str]) -> list[str]:
    """Recover linked table names from the .rpt when the text export is a stub.

    `strings` also surfaces lookup values and captions, so this is only used
    when the definition export lists no tables, and the method is recorded.
    """
    try:
        out = subprocess.run(
            ["strings", "-n", "5", str(rpt)], capture_output=True, text=True, check=True
        ).stdout
    except (OSError, subprocess.CalledProcessError):
        return []
    tokens = set(out.splitlines())
    return sorted(tables & tokens)


def ole_metadata(rpt: Path) -> dict[str, str]:
    """Title/Subject/Template/Last saved from the OLE summary information.

    Values may legitimately contain commas, so each field runs to the next
    known key rather than to the first comma.
    """
    try:
        out = subprocess.run(["file", "-b", str(rpt)], capture_output=True, text=True, check=True).stdout
    except (OSError, subprocess.CalledProcessError):
        return {}
    fields: dict[str, str] = {}
    for key, terminator in METADATA_FIELDS.items():
        stop = rf",\s*{re.escape(terminator)}:" if terminator else r",\s*\w"
        match = re.search(rf"{re.escape(key)}: (.*?)(?:{stop})", out, re.S)
        if match:
            fields[key] = " ".join(match.group(1).split())
    return fields


TRANSACTION_TABLES = {"TxHeader", "TxDetails", "TxPayment", "TxSalePerson"}


def propose_criticality(name: str, tables: list[str]) -> tuple[str, str]:
    """Propose criticality from the report name and its data dependencies.

    This is a triage default for the 3.4 review, not a customer decision.
    """
    if FINANCIAL.search(name):
        return "high", "name matches financial/legal vocabulary"
    if TRANSACTION_TABLES & set(tables):
        return "high", "reads financial transaction tables"
    if OPERATIONAL.search(name):
        return "medium", "name matches inventory/stock/wholesale operations"
    return "low", "listing/lookup of non-transaction data"


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--legacy", type=Path, default=LEGACY)
    parser.add_argument("--out", type=Path, default=ROOT / "docs/parity/reports.csv")
    args = parser.parse_args()

    if not args.legacy.is_dir():
        raise SystemExit(f"legacy source folder not found: {args.legacy}")

    effective: dict[str, dict[str, object]] = {}
    superseded: Counter[str] = Counter()
    for tier, rel in TIERS:
        folder = args.legacy / rel
        if not folder.is_dir():
            raise SystemExit(f"missing report tier: {folder}")
        for path in sorted(folder.iterdir()):
            if path.suffix.lower() != ".rpt":
                continue
            key = path.stem.strip().lower()
            if key in effective:
                superseded[key] += 1
                continue
            effective[key] = {"tier": tier, "path": path}

    rows: list[dict[str, str]] = []
    for index, key in enumerate(sorted(effective), start=1):
        entry = effective[key]
        path = entry["path"]
        assert isinstance(path, Path)
        text, definition = load_definition(path)
        parsed = parse_definition(text) if text else {
            "tables": [], "parameters": [], "selection": "", "title": ""
        }
        meta = ole_metadata(path)
        tables = list(parsed["tables"])  # type: ignore[arg-type]
        tables_source = "definition"
        if not tables:
            tables = binary_table_fallback(path, known_legacy_tables())
            tables_source = "binary-fallback" if tables else "none"
        parameters = list(parsed["parameters"])  # type: ignore[arg-type]
        criticality, basis = propose_criticality(key, tables)

        notes = []
        if not text:
            notes.append("no Crystal definition export found")
        elif tables_source == "binary-fallback":
            notes.append("definition export is a stub; table names recovered from .rpt strings, "
                         "confirm joins with the customer before 3.4")
        elif not tables:
            notes.append("no table references found in the definition or the .rpt")
        if not parameters:
            notes.append("no parameters")
        if superseded[key]:
            notes.append(f"{superseded[key]} lower-precedence copies superseded")

        rows.append({
            "id": f"RPT-{index:03d}",
            "logical_name": path.stem,
            "title": meta.get("Title", ""),
            "source_tier": entry["tier"],
            "source_file": path.relative_to(args.legacy).as_posix(),
            "definition_export": definition.relative_to(args.legacy).as_posix() if definition else "",
            "subject": meta.get("Subject", ""),
            "template": meta.get("Template", ""),
            "last_saved": meta.get("Last Saved Time/Date", ""),
            "parameters": ";".join(parameters),
            "parameter_count": str(len(parameters)),
            "data_tables": ";".join(tables),
            "data_tables_source": tables_source,
            "table_count": str(len(tables)),
            "selection_formula": "yes" if parsed["selection"] else "no",
            "criticality": criticality,
            "criticality_basis": basis,
            "in_scope": "pending",
            "signoff_status": "pending",
            "notes": "; ".join(notes),
        })

    args.out.parent.mkdir(parents=True, exist_ok=True)
    with args.out.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=list(rows[0].keys()))
        writer.writeheader()
        writer.writerows(rows)

    tiers = Counter(row["source_tier"] for row in rows)
    no_tables = [row["id"] for row in rows if row["table_count"] == "0"]
    missing_def = [row["id"] for row in rows if not row["definition_export"]]
    print(f"wrote {len(rows)} effective reports -> {args.out}")
    print("by tier: " + ", ".join(f"{tier}={count}" for tier, count in sorted(tiers.items())))
    print(f"without table references: {len(no_tables)} {no_tables[:10]}")
    print(f"without definition export: {len(missing_def)} {missing_def[:10]}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
