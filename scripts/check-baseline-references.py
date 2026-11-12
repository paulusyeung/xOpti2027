#!/usr/bin/env python3
"""CI gate: every parity baseline ID is owned by a change or explicitly deferred (task 6.4).

Reads docs/parity/coverage.csv (built by scripts/parity/build_coverage.py) and
compares it with the actual baseline artefacts. Fails when:

- an artefact ID is not listed in coverage (an unreferenced active ID);
- an active row names a change that does not exist;
- coverage lists an ID the artefacts no longer contain.
"""

from __future__ import annotations

import argparse
import csv
import re
import sys
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PARITY = ROOT / "docs/parity"
CHANGES = ROOT / "openspec/changes"


def ids_from_csv(name: str) -> set[str]:
    with (PARITY / name).open(newline="", encoding="utf-8") as handle:
        return {row["id"] for row in csv.DictReader(handle)}


def rule_ids() -> set[str]:
    ids: set[str] = set()
    for path in sorted(PARITY.glob("*-rules.md")):
        ids.update(re.findall(r"RULE-\d{3}", path.read_text(encoding="utf-8")))
    return ids


def artefact_ids() -> dict[str, set[str]]:
    return {
        "FORM/MOD/CLS": ids_from_csv("forms.csv"),
        "PERM": ids_from_csv("permissions.csv"),
        "RPT": ids_from_csv("reports.csv"),
        "RULE": rule_ids(),
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--coverage", type=Path, default=PARITY / "coverage.csv")
    args = parser.parse_args()

    if not args.coverage.exists():
        print(f"missing {args.coverage}; run scripts/parity/build_coverage.py", file=sys.stderr)
        return 1

    with args.coverage.open(newline="", encoding="utf-8") as handle:
        coverage = list(csv.DictReader(handle))

    errors: list[str] = []
    covered: dict[str, dict[str, str]] = {}
    for row in coverage:
        ident = row["id"]
        if ident in covered:
            errors.append(f"{ident}: duplicate coverage row")
        covered[ident] = row

        if row["status"] == "deferred":
            continue

        target = row["target_change"].strip()
        if not target:
            errors.append(f"{ident}: active baseline ID has no target change")
            continue
        if not (CHANGES / target).is_dir():
            errors.append(f"{ident}: target change '{target}' does not exist under openspec/changes")

    actual = artefact_ids()
    for label, ids in actual.items():
        for ident in sorted(ids - covered.keys()):
            errors.append(f"{ident}: {label} baseline ID is not referenced by a change or marked deferred")
        for ident in sorted(covered.keys() - ids):
            entry = covered[ident]
            if entry["kind"] in label.split("/") or (label == "FORM/MOD/CLS" and entry["kind"] in ("FORM", "MOD", "CLS")):
                errors.append(f"{ident}: coverage row no longer matches any {label} artefact")

    kinds = Counter(row["kind"] for row in coverage)
    deferred = sum(1 for row in coverage if row["status"] == "deferred")
    active = len(coverage) - deferred
    print(
        f"baseline coverage: {len(coverage)} IDs, {active} active, {deferred} deferred "
        f"({', '.join(f'{kind}={count}' for kind, count in sorted(kinds.items()))})"
    )

    if errors:
        for error in errors:
            print("  " + error, file=sys.stderr)
        print(f"{len(errors)} baseline reference problem(s).", file=sys.stderr)
        return 1

    print("All baseline IDs are referenced by a change or explicitly deferred.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
