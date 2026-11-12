#!/usr/bin/env python3
"""Inventory the legacy VB6 source tree into docs/parity/forms.csv (task 1.3).

Every root-level .frm/.bas/.cls gets a stable ID and either a target OpenSpec
change or an explicit deferral reason. Deterministic: sorted by file name.
"""

from __future__ import annotations

import argparse
import csv
import re
from dataclasses import dataclass
from pathlib import Path

CAPTION_RE = re.compile(r'^\s*Caption\s*=\s*"(.*)"\s*$', re.M)
VB_NAME_RE = re.compile(r'^Attribute VB_Name = "([^"]+)"', re.M)
PUBLIC_PROC_RE = re.compile(r"^(?:Public\s+)?(?:Sub|Function)\s+([A-Za-z0-9_]+)", re.M | re.I)
COMMENT_RE = re.compile(r"^'\s*(.+)$")

# Ordered: first match wins. Keys are lower-case fragments of file name + caption.
MODULE_RULES: list[tuple[tuple[str, ...], str]] = [
    (("wholesale", "wsale"), "complete-wholesale-operations"),
    (("customer", "patient", "doctor", "prescri", "medical", "insurance", "claim", "rx"),
     "complete-customer-prescriptions-and-insurance"),
    (("stock", "invt", "inventory", "sku", "supplier", "purchase", "pricing", "price",
      "barcode", "bar code", "category", "class", "dept", "department", "brand",
      "material", "markdown", "rbic"), "complete-inventory-and-purchasing"),
    (("report", "olap", "analysis", "graph", "summary", "ledger", "journal", "crystal",
      "print"), "complete-reporting-and-analytics"),
    (("sales", "invoice", "order", "pos", "payment", "refund", "tender", "cash",
      "discount", "tax", "receipt", "quote", "return", "oltp"), "complete-pos-sales-and-payments"),
    (("staff", "security", "user", "preference", "system", "profile", "branch", "backup",
      "util", "convert", "setup", "menu", "about", "logon", "main", "password", "password",
      "info exchange", "date range", "ask", "valid", "status"), "complete-master-data-and-security"),
]

DEFER_REASON = "Legacy framework/utility screen with no direct xOpti capability; deferred pending manual triage."

FRAMEWORK_PREFIXES = ("ofx", "sdvb")


@dataclass
class Entry:
    legacy_type: str
    path: Path
    legacy_name: str
    caption: str
    purpose: str
    entry_points: str
    target: str
    status: str
    notes: str


def read_text(path: Path) -> str:
    return path.read_text(encoding="latin-1", errors="replace")


def first_comment_block(text: str) -> str:
    lines: list[str] = []
    for line in text.splitlines()[:40]:
        match = COMMENT_RE.match(line)
        if match:
            value = match.group(1).strip()
            if value and not value.startswith(("SDVB", "-", "=", "Attribute")):
                lines.append(value)
        elif lines:
            break
    return " ".join(lines[:3])


def caption_for(text: str) -> str:
    match = CAPTION_RE.search(text)
    return match.group(1).strip() if match else ""


def public_procs(text: str) -> list[str]:
    return [m.group(1) for m in PUBLIC_PROC_RE.finditer(text) if m.group(1).lower() not in {"main"}]


def target_for(name: str, caption: str) -> tuple[str, str, str]:
    haystack = f"{name} {caption}".lower()
    for fragments, change in MODULE_RULES:
        if any(fragment in haystack for fragment in fragments):
            return change, "mapped", ""
    return "", "deferred", DEFER_REASON


def build(root: Path) -> list[Entry]:
    files = sorted(
        (p for p in root.iterdir() if p.is_file() and p.suffix.lower() in {".frm", ".bas", ".cls"}),
        key=lambda p: p.name.lower(),
    )
    counters = {"frm": 0, "bas": 0, "cls": 0}
    all_text = {p: read_text(p) for p in files}
    entries: list[Entry] = []
    for path in files:
        text = all_text[path]
        kind = path.suffix.lower().lstrip(".")
        counters[kind] += 1
        prefix = {"frm": "FORM", "bas": "MOD", "cls": "CLS"}[kind]
        legacy_name = (VB_NAME_RE.search(text) or re.match(r".*", "")) and (
            VB_NAME_RE.search(text).group(1) if VB_NAME_RE.search(text) else path.stem
        )
        caption = caption_for(text) if kind == "frm" else ""
        purpose = caption or first_comment_block(text) or path.stem
        refs: list[str] = []
        for other, other_text in all_text.items():
            if other == path:
                continue
            if re.search(rf"\b{re.escape(path.stem)}\b", other_text, re.I):
                refs.append(other.name)
        if kind == "frm":
            entry_points = f"opened by {len(refs)} source file(s): {', '.join(refs[:3])}" if refs else "no static caller found"
        else:
            procs = public_procs(text)
            entry_points = f"{len(procs)} public procedure(s): {', '.join(procs[:5])}" if procs else "no public procedure"
        target, status, notes = target_for(path.stem, caption)
        if status == "mapped" and path.stem.lower().startswith(FRAMEWORK_PREFIXES):
            target, status = "", "deferred"
            notes = "Shared VB6 framework module; reintroduced as platform code, not a business capability."
        entries.append(
            Entry(
                legacy_type=kind.lower(),
                path=path,
                legacy_name=legacy_name,
                caption=caption,
                purpose=purpose,
                entry_points=entry_points,
                target=target,
                status=status,
                notes=notes,
            )
        )
    return entries


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source", type=Path, default=Path("eOptical6DAO"))
    parser.add_argument("--out", type=Path, default=Path("docs/parity/forms.csv"))
    args = parser.parse_args()

    entries = build(args.source)
    counters: dict[str, int] = {}
    for entry in entries:
        counters[entry.legacy_type] = counters.get(entry.legacy_type, 0) + 1
    expected = {"frm": 110, "bas": 42, "cls": 8}
    if counters != expected:
        print(f"source count mismatch: found {counters}, expected {expected}", flush=True)

    args.out.parent.mkdir(parents=True, exist_ok=True)
    prefix_map = {"frm": "FORM", "bas": "MOD", "cls": "CLS"}
    sequence: dict[str, int] = {}
    with args.out.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.writer(handle)
        writer.writerow([
            "id", "type", "file", "legacy_name", "caption", "purpose",
            "entry_points", "target_change", "status", "notes",
        ])
        for entry in sorted(entries, key=lambda e: (e.legacy_type, e.path.name.lower())):
            sequence[entry.legacy_type] = sequence.get(entry.legacy_type, 0) + 1
            writer.writerow([
                f"{prefix_map[entry.legacy_type]}-{sequence[entry.legacy_type]:03d}",
                entry.legacy_type,
                entry.path.name,
                entry.legacy_name,
                entry.caption,
                entry.purpose,
                entry.entry_points,
                entry.target,
                entry.status,
                entry.notes,
            ])
    deferred = sum(1 for e in entries if e.status == "deferred")
    print(f"wrote {len(entries)} rows ({deferred} deferred) -> {args.out}")
    return 0 if counters == expected else 1


if __name__ == "__main__":
    raise SystemExit(main())
