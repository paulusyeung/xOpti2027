#!/usr/bin/env python3
"""Reproducible structural/data profile of a legacy SynergyV.mdb snapshot.

Outputs (deterministic, no timestamps):
  docs/parity/legacy-profile.csv   one row per table/column observation
  docs/parity/legacy-profile.md    human-readable summary

Requires mdbtools (mdb-tables, mdb-export, mdb-schema). Python standard library only.
"""

from __future__ import annotations

import argparse
import csv
import datetime as dt
import hashlib
import io
import re
import subprocess
import sys
from dataclasses import dataclass, field
from pathlib import Path

PII_PATTERNS = [
    r"name", r"address", r"addr", r"phone", r"fax", r"email", r"birthday",
    r"^sin$", r"bank", r"salary", r"medical", r"prescri", r"cardnumber",
    r"authorization", r"remark", r"note", r"contact", r"postal", r"password",
    r"license", r"licence", r"health", r"doctor", r"patient",
]
DATE_NAME_RE = re.compile(r"(date|birthday|hired|leaved|expiry|expire|issuedon|issueddate|created|modified|lastpurchase)", re.I)


def is_date_column(column) -> bool:
    """A real date column, not a numeric/text field whose name merely contains 'issued'.

    Access stores some dates as DateTime and some legacy ones as Text, so the
    name heuristic only widens the check to text columns; integer ``IssuedByDr``
    and similar keys are excluded.
    """
    kind = column.type.lower()
    if kind.startswith(("date", "time")):
        return True
    return kind.startswith("text") and bool(DATE_NAME_RE.search(column.name))
DATE_FORMATS = [
    "%m/%d/%y %H:%M:%S", "%m/%d/%Y %H:%M:%S", "%Y-%m-%d %H:%M:%S",
    "%m/%d/%y", "%m/%d/%Y", "%Y-%m-%d", "%d/%m/%Y",
]
NULL_TOKENS = {"", "null", "none"}
TABLE_RE = re.compile(r"CREATE TABLE \[(?P<name>[^\]]+)\]\s*\((?P<body>.*?)\n\);", re.S)
COLUMN_RE = re.compile(
    r"\[(?P<name>[^\]]+)\]\s+(?P<type>[A-Za-z0-9 ()\-]+?)(?:\s+(?P<null>NOT NULL))?\s*,",
    re.S,
)


@dataclass
class Column:
    name: str
    type: str
    not_null: bool


@dataclass
class Table:
    name: str
    columns: list[Column] = field(default_factory=list)
    rows: int = 0
    nulls: dict[str, int] = field(default_factory=dict)
    invalid_dates: dict[str, int] = field(default_factory=dict)
    orphan_keys: list[str] = field(default_factory=list)
    keys: list[str] = field(default_factory=list)


def run(*args: str) -> str:
    result = subprocess.run(args, capture_output=True, text=True, errors="replace")
    if result.returncode != 0:
        raise RuntimeError(f"{' '.join(args)} failed: {result.stderr.strip()}")
    return result.stdout


def parse_schema(db: Path) -> dict[str, Table]:
    ddl = run("mdb-schema", str(db))
    tables: dict[str, Table] = {}
    for match in TABLE_RE.finditer(ddl):
        table = Table(name=match.group("name"))
        body = match.group("body")
        for col in COLUMN_RE.finditer(body + ",\n"):
            table.columns.append(
                Column(
                    name=col.group("name"),
                    type=" ".join(col.group("type").split()),
                    not_null=bool(col.group("null")),
                )
            )
        # Access has no enforced foreign keys in this schema dump; primary keys
        # are the first NOT NULL column by convention (see mdb-schema output).
        table.keys = [c.name for c in table.columns if c.not_null][:1]
        tables[table.name] = table
    return tables


def is_pii(column: str) -> bool:
    lowered = column.lower()
    return any(re.search(pattern, lowered) for pattern in PII_PATTERNS)


def parse_date(value: str) -> bool:
    value = value.strip()
    for fmt in DATE_FORMATS:
        try:
            parsed = dt.datetime.strptime(value, fmt)
        except ValueError:
            continue
        return 1900 <= parsed.year <= 2100
    return False


def read_table(db: Path, table: Table) -> list[dict[str, str]]:
    raw = run("mdb-export", str(db), table.name)
    if not raw.strip():
        return []
    reader = csv.reader(io.StringIO(raw))
    try:
        header = [h.strip() for h in next(reader)]
    except StopIteration:
        return []
    rows: list[dict[str, str]] = []
    for record in reader:
        if not record:
            continue
        rows.append({name: (record[i] if i < len(record) else "") for i, name in enumerate(header)})
    return rows


def candidate_target(column: str, tables: dict[str, Table]) -> tuple[str, str] | None:
    """Infer a look-up relationship from a naming convention, not from DDL."""
    for suffix in ("Code", "ID"):
        if not column.endswith(suffix) or len(column) <= len(suffix):
            continue
        prefix = column[: -len(suffix)]
        for candidate in (prefix, prefix + "s", prefix + "e", prefix[:-1] if prefix.endswith("e") else prefix):
            for table_name, table in tables.items():
                if table_name.lower() != candidate.lower():
                    continue
                names = {c.name for c in table.columns}
                # Prefer an identically named key, then the conventional
                # synthetic key (Customer.ID, Supplier.Code, ...).
                for candidate_key in (column, "ID", prefix + "ID", prefix + "Code"):
                    if candidate_key in names:
                        return table_name, candidate_key
                first = table.columns[0].name if table.columns else ""
                if first.endswith(("ID", "Code")):
                    return table_name, first
    return None


def profile(db: Path, tables: dict[str, Table], infer_orphans: bool) -> list[Table]:
    # Only pricey value sets for columns that participate in an inferred
    # relationship; exporting 1.2M TxDetails rows must not build a set per column.
    relationships: dict[tuple[str, str], tuple[str, str]] = {}
    tracked: set[str] = set()
    if infer_orphans:
        for table in tables.values():
            for column in table.columns:
                target = candidate_target(column.name, tables)
                if not target:
                    continue
                target_table, target_key = target
                if target_table == table.name:
                    continue
                relationships[(table.name, column.name)] = (target_table, target_key)
                tracked.add(column.name)
                tracked.add(target_key)
    values: dict[str, set[str]] = {name: set() for name in tracked}

    for table in tables.values():
        rows = read_table(db, table)
        table.rows = len(rows)
        table.nulls = {c.name: 0 for c in table.columns}
        table.invalid_dates = {}
        date_columns = [c.name for c in table.columns if is_date_column(c)]
        table.invalid_dates = {name: 0 for name in date_columns}
        for row in rows:
            for column in table.columns:
                value = row.get(column.name, "").strip()
                if value.lower() in NULL_TOKENS:
                    table.nulls[column.name] += 1
                if column.name in values:
                    values[column.name].add(value)
            for name in date_columns:
                value = row.get(name, "").strip()
                if value.lower() not in NULL_TOKENS and not parse_date(value):
                    table.invalid_dates[name] += 1
    if infer_orphans:
        for (table_name, column), (target_table, target_key) in sorted(relationships.items()):
            known = values.get(target_key, set()) - NULL_TOKENS
            orphans = values.get(column, set()) - NULL_TOKENS - known
            if orphans:
                tables[table_name].orphan_keys.append(
                    f"{column}->{target_table}.{target_key} ({len(orphans)} unmatched)"
                )
    return sorted(tables.values(), key=lambda t: t.name.lower())


def write_csv(tables: list[Table], out: Path) -> None:
    with out.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.writer(handle)
        writer.writerow([
            "table", "rows", "columns", "not_null_columns", "pii_columns",
            "observed_null_columns", "invalid_date_columns", "orphan_key_checks",
        ])
        for table in tables:
            nulls = [f"{name}:{count}" for name, count in sorted(table.nulls.items()) if count]
            invalid = [f"{name}:{count}" for name, count in sorted(table.invalid_dates.items()) if count]
            writer.writerow([
                table.name,
                table.rows,
                len(table.columns),
                ";".join(c.name for c in table.columns if c.not_null),
                ";".join(c.name for c in table.columns if is_pii(c.name)),
                ";".join(nulls),
                ";".join(invalid),
                ";".join(table.orphan_keys),
            ])


def write_markdown(db: Path, tables: list[Table], out: Path, digest: str, label: str) -> None:
    total_rows = sum(t.rows for t in tables)
    pii = sorted({c.name for t in tables for c in t.columns if is_pii(c.name)})
    date_columns = sorted({c.name for t in tables for c in t.columns if is_date_column(c)})
    not_null = sum(1 for t in tables for c in t.columns if c.not_null)
    columns = sum(len(t.columns) for t in tables)
    invalid = sum(sum(t.invalid_dates.values()) for t in tables)
    orphans = sum(len(t.orphan_keys) for t in tables)
    lines = [
        "# Legacy database profile",
        "",
        "Generated by `scripts/parity/profile-legacy-db.sh`; do not edit by hand.",
        "",
        f"- Source: {label}",
        f"- SHA-256: `{digest}`",
        f"- Tables: {len(tables)}",
        f"- Columns: {columns} ({not_null} declared `NOT NULL`)",
        f"- Rows observed in this snapshot: {total_rows}",
        f"- Invalid-date values: {invalid}",
        f"- Inferred orphan-key violations: {orphans}",
        "",
        "## Method",
        "",
        "- Row counts and column null counts come from `mdb-export` CSV exports.",
        "- Schema nullability comes from `mdb-schema` (`NOT NULL` markers).",
        "- Access/Jet enforces no foreign keys in this schema; orphan checks infer",
        "  relationships from `*ID`/`*Code` naming and compare value sets.",
        "- Invalid dates are non-empty values that do not parse as a date between",
        "  1900 and 2100.",
        "- PII-bearing columns are a name-based classification and require human",
        "  confirmation before use in test data or logs.",
        "",
        "## Snapshot caveat",
        "",
        "If `Rows observed` is 0, the checked-in `SynergyV.mdb` is a schema-only",
        "snapshot. Data-quality findings (orphans, invalid dates, PII volume) are",
        "then vacuous and MUST be regenerated from the authoritative production",
        "snapshot once task 1.1 supplies it. The command is the verification:",
        "",
        "```bash",
        "scripts/parity/profile-legacy-db.sh [path/to/SynergyV.mdb]",
        "```",
        "",
        "## Tables",
        "",
        "| Table | Rows | Columns | PII columns | Invalid dates | Orphan checks |",
        "| --- | ---: | ---: | --- | ---: | --- |",
    ]
    for table in tables:
        lines.append(
            "| {name} | {rows} | {cols} | {pii} | {invalid} | {orphans} |".format(
                name=table.name,
                rows=table.rows,
                cols=len(table.columns),
                pii=", ".join(c.name for c in table.columns if is_pii(c.name)) or "-",
                invalid=sum(table.invalid_dates.values()),
                orphans="; ".join(table.orphan_keys) or "-",
            )
        )
    lines += [
        "",
        "## PII-bearing columns (name-based)",
        "",
        ", ".join(f"`{name}`" for name in pii) or "None identified.",
        "",
        "## Date-bearing columns",
        "",
        ", ".join(f"`{name}`" for name in date_columns) or "None identified.",
        "",
    ]
    out.write_text("\n".join(lines), encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("db", type=Path, nargs="?", default=Path("eOptical6DAO/SynergyV.mdb"))
    parser.add_argument("--out-dir", type=Path, default=Path("docs/parity"))
    parser.add_argument("--no-orphan-inference", action="store_true")
    parser.add_argument("--label", default="", help="source label for the report (defaults to the path)")
    args = parser.parse_args()

    if not args.db.is_file():
        print(f"database not found: {args.db}", file=sys.stderr)
        return 2
    for tool in ("mdb-schema", "mdb-tables", "mdb-export"):
        if subprocess.run(["sh", "-c", f"command -v {tool}"], capture_output=True).returncode != 0:
            print(f"required tool missing: {tool} (install mdbtools)", file=sys.stderr)
            return 2

    digest = hashlib.sha256(args.db.read_bytes()).hexdigest()
    tables = parse_schema(args.db)
    listed = {name.strip() for name in run("mdb-tables", "-1", str(args.db)).splitlines() if name.strip()}
    missing = listed - set(tables)
    if missing:
        print(f"schema parse missed tables: {sorted(missing)}", file=sys.stderr)
        return 3
    profiled = profile(args.db, tables, infer_orphans=not args.no_orphan_inference)
    args.out_dir.mkdir(parents=True, exist_ok=True)
    write_csv(profiled, args.out_dir / "legacy-profile.csv")
    label = args.label or f"`{args.db.as_posix()}`"
    write_markdown(args.db, profiled, args.out_dir / "legacy-profile.md", digest, label)
    print(f"profiled {len(profiled)} tables -> {args.out_dir}/legacy-profile.{{csv,md}}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
