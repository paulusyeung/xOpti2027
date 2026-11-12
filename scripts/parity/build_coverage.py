#!/usr/bin/env python3
"""Build the parity baseline coverage map (task 6.4).

For every `FORM-*`, `MOD-*`, `CLS-*`, `RULE-*`, `PERM-*`, and `RPT-*` baseline
ID this writes one row naming the change that owns it, or marking it deferred.
`scripts/check-baseline-references.py` verifies the map in CI, so a new active
baseline ID cannot be added without a destination.
"""

from __future__ import annotations

import argparse
import csv
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PARITY = ROOT / "docs/parity"
CHANGES = ROOT / "openspec/changes"

# Which module change implements each rule family. Ranges are explicit so a new
# rule number fails the build instead of being silently mapped to the wrong slice.
RULE_TARGETS = [
    (range(1, 4), "complete-inventory-and-purchasing"),   # SR/RJ/SJ posting
    (range(4, 9), "complete-pos-sales-and-payments"),      # RC/RS/SA posting and payments
    (range(9, 15), "complete-inventory-and-purchasing"),   # FIFO/LIFO/average, lots, deficits
    (range(15, 21), "complete-pos-sales-and-payments"),    # tax, discounts, refunds
    (range(21, 26), "complete-pos-sales-and-payments"),    # control and transaction numbering
]

PERM_TARGET = "complete-master-data-and-security"
RPT_TARGET = "complete-reporting-and-analytics"


def rule_target(number: int) -> str:
    for numbers, target in RULE_TARGETS:
        if number in numbers:
            return target
    raise SystemExit(
        f"RULE-{number:03d} has no target change; add it to RULE_TARGETS in {Path(__file__).name}")


def read_csv(path: Path) -> list[dict[str, str]]:
    with path.open(newline="", encoding="utf-8") as handle:
        return list(csv.DictReader(handle))


def forms_rows() -> list[dict[str, str]]:
    rows = []
    for row in read_csv(PARITY / "forms.csv"):
        deferred = row["status"] == "deferred" or not row["target_change"].strip()
        rows.append({
            "id": row["id"],
            "kind": row["id"].split("-", 1)[0],
            "source": "docs/parity/forms.csv",
            "target_change": "" if deferred else row["target_change"],
            "status": "deferred" if deferred else "active",
            "note": row["notes"],
        })
    return rows


def rule_rows() -> list[dict[str, str]]:
    ids: set[str] = set()
    for path in sorted(PARITY.glob("*-rules.md")):
        ids.update(re.findall(r"RULE-\d{3}", path.read_text(encoding="utf-8")))
    rows = []
    for ident in sorted(ids):
        number = int(ident.split("-")[1])
        rows.append({
            "id": ident,
            "kind": "RULE",
            "source": "docs/parity/*-rules.md",
            "target_change": rule_target(number),
            "status": "active",
            "note": "",
        })
    return rows


def permission_rows() -> list[dict[str, str]]:
    return [
        {
            "id": row["id"],
            "kind": "PERM",
            "source": "docs/parity/permissions.csv",
            "target_change": PERM_TARGET,
            "status": "active",
            "note": f"status={row['status']} parity={row['parity']}",
        }
        for row in read_csv(PARITY / "permissions.csv")
    ]


def report_rows() -> list[dict[str, str]]:
    rows = []
    for row in read_csv(PARITY / "reports.csv"):
        deferred = row["in_scope"] == "deferred"
        rows.append({
            "id": row["id"],
            "kind": "RPT",
            "source": "docs/parity/reports.csv",
            "target_change": "" if deferred else RPT_TARGET,
            "status": "deferred" if deferred else "active",
            "note": row["criticality"],
        })
    return rows


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--out", type=Path, default=PARITY / "coverage.csv")
    args = parser.parse_args()

    rows = forms_rows() + rule_rows() + permission_rows() + report_rows()
    rows.sort(key=lambda row: (row["kind"], row["id"]))

    seen: dict[str, int] = {}
    duplicates: list[str] = []
    for row in rows:
        seen[row["id"]] = seen.get(row["id"], 0) + 1
        if seen[row["id"]] == 2:
            duplicates.append(row["id"])
    if duplicates:
        print("duplicate baseline ids: " + ", ".join(sorted(duplicates)), file=sys.stderr)
        return 1

    args.out.parent.mkdir(parents=True, exist_ok=True)
    with args.out.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(
            handle, fieldnames=["id", "kind", "source", "target_change", "status", "note"])
        writer.writeheader()
        writer.writerows(rows)

    from collections import Counter
    kinds = Counter(row["kind"] for row in rows)
    deferred = sum(1 for row in rows if row["status"] == "deferred")
    print(f"wrote {len(rows)} coverage rows ({deferred} deferred) -> {args.out}")
    print("  " + ", ".join(f"{kind}={count}" for kind, count in sorted(kinds.items())))
    return 0


if __name__ == "__main__":
    sys.exit(main())
