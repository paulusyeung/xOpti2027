#!/usr/bin/env python3
"""Extract the legacy security matrix into docs/parity/permissions.csv (task 3.1).

Legacy side: the `Security` level matrix and `Staff.SecurityLevel` distribution
from the production snapshot, plus the VB procedures that read them.

xOpti side: parsed from the real authorization sources, not hand-copied --
`src/xOpti.Application/Authorization/PermissionNames.cs`,
`src/xOpti.Infrastructure/Identity/RolesAndIdentity.cs` (role -> permission
matrix) and `LegacyUserSeeder.RoleForLevel`. If those files change shape the
script fails instead of emitting a stale matrix.

Every legacy level and capability is therefore reported as mapped, explicitly
denied, or a parity gap that needs the 3.2 customer decision. No staff names,
staff codes, or passwords are emitted.
"""

from __future__ import annotations

import argparse
import csv
import io
import os
import re
import subprocess
import sys
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PERMISSION_NAMES_CS = ROOT / "src/xOpti.Application/Authorization/PermissionNames.cs"
ROLES_AND_IDENTITY_CS = ROOT / "src/xOpti.Infrastructure/Identity/RolesAndIdentity.cs"
LEGACY_USER_SEEDER_CS = ROOT / "src/xOpti.Infrastructure/Identity/LegacyUserSeeder.cs"

# Legacy Security columns -> how xOpti replaces them.
# `xopti` is the real PermissionNames constant(s) that carry the capability, or
# empty when xOpti has no equivalent gate and the column is superseded.
# `enforcement` is the verified VB evidence for the column's runtime behaviour.
CAPABILITIES = [
    dict(
        id="PERM-001",
        field="Point_of_Sale",
        legacy_value="Point-of-sale menu access",
        xopti=("SalesOrderCreate", "SalesInvoicePost"),
        enforcement="Never read; no VB source references this column",
        notes="No menu-level gate exists; every staff row could open the POS menu. "
              "Replaced by per-action sales:order-create / sales:invoice-post, "
              "which every role holds at least one of.",
    ),
    dict(
        id="PERM-002",
        field="Inventory_Control",
        legacy_value="Inventory-control menu access",
        xopti=("InventoryReceive", "InventoryAdjust"),
        enforcement="Never read; no VB source references this column",
        notes="Split into inventory:receive (SR) and inventory:adjust (SJ).",
    ),
    dict(
        id="PERM-003",
        field="OLAP",
        legacy_value="Legacy OLAP sales/margin analysis",
        xopti=("ReportFinancial",),
        enforcement="Never read; no VB source references this column. "
                    "OLAP.frm/OLAPSales.frm/OLAPMargin.frm load unconditionally.",
        notes="xOpti has no dedicated analytics permission; nearest gate is "
              "report:financial. Margin views also depend on cost:view.",
    ),
    dict(
        id="PERM-004",
        field="Information_Centre",
        legacy_value="Information-centre customer lookup",
        xopti=("CustomerPii",),
        enforcement="Never read; no VB source references this column",
        notes="Maps onto the customer:pii visibility guard (PiiGuard).",
    ),
    dict(
        id="PERM-005",
        field="Coding",
        legacy_value="Coding tables (add/class/category/etc.)",
        xopti=("MasterDataMaintain",),
        enforcement="Never read; no VB source references this column",
        notes="frmMenuCoding.frm / frmCoding.frm open unconditionally.",
    ),
    dict(
        id="PERM-006",
        field="Report_Centre",
        legacy_value="Report-centre access",
        xopti=("ReportFinancial",),
        enforcement="Never read; no VB source references this column",
        notes="xOpti has no separate report-centre permission.",
    ),
    dict(
        id="PERM-007",
        field="Preference",
        legacy_value="Preference/system table access",
        xopti=("MasterDataMaintain",),
        enforcement="Never read; no VB source references this column",
        notes="frmPreference.frm / frmSystemProfile.frm open unconditionally.",
    ),
    dict(
        id="PERM-008",
        field="Cost",
        legacy_value="Cost, margin, and least-selling-price visibility",
        xopti=("CostView",),
        enforcement="Enforced: IsCostOK (AppValidation.bas:335-359) called from "
                    "pyHasCostLevel (AppUser.bas:16) and directly at "
                    "frmInfoSKU.frm:1770, frmInventoryChoice.frm:517, "
                    "frmSpeicalAnalysis.frm:402, each behind IsSecurityEnabled.",
        notes="Replaced by the cost:view claim and CostGuard masking.",
    ),
]

NULL_TOKENS = {"", "null", "none"}


def export(db: Path, table: str) -> list[dict[str, str]]:
    raw = subprocess.run(
        ["mdb-export", str(db), table], capture_output=True, text=True, check=True
    ).stdout
    return list(csv.DictReader(io.StringIO(raw)))


def truthy(value: str) -> bool:
    return value.strip().lower() in {"1", "true", "-1", "yes"}


# --------------------------------------------------------------------------- #
# xOpti authorization model, parsed from source
# --------------------------------------------------------------------------- #

def read_permission_names(text: str) -> tuple[dict[str, str], set[str]]:
    names = dict(re.findall(r'public const string (\w+) = "([^"]+)";', text))
    all_block = re.search(r"All\s*=\s*new\[\]\s*\{(.*?)\};", text, re.S)
    if not all_block:
        raise SystemExit(f"cannot find PermissionNames.All in {PERMISSION_NAMES_CS}")
    members = {m.strip() for m in all_block.group(1).split(",") if m.strip()}
    missing = members - names.keys()
    if missing:
        raise SystemExit(f"PermissionNames.All references unknown constants: {sorted(missing)}")
    return names, members


def read_role_constants(text: str) -> dict[str, str]:
    """Map C# constant names (Clerk) to stored role values (clerk)."""
    constants = dict(re.findall(r'public const string (\w+) = "([^"]+)";', text))
    if not constants:
        raise SystemExit(f"cannot find RolePermissionMatrix role constants in {ROLES_AND_IDENTITY_CS}")
    return constants


def read_role_matrix(
    text: str, permission_names: dict[str, str], all_members: set[str]
) -> dict[str, list[str]]:
    constants = read_role_constants(text)
    body = re.search(r"private static IEnumerable<string> ForRole\(string role\) => role switch\s*\{(.*?)\n    \};", text, re.S)
    if not body:
        raise SystemExit(f"cannot find RolePermissionMatrix.ForRole in {ROLES_AND_IDENTITY_CS}")

    matrix: dict[str, list[str]] = {}
    arm_re = re.compile(
        r"(\w+|_)\s*=>\s*(?:new\[\]\s*\{(.*?)\}|Array\.Empty<string>\(\)|PermissionNames\.All)",
        re.S,
    )
    for name, listed in arm_re.findall(body.group(1)):
        if name == "_":
            continue
        role = constants.get(name, name)
        if listed is None:
            matrix[role] = (
                [permission_names[m] for m in all_members]
                if re.search(rf"{name}\s*=>\s*PermissionNames\.All", body.group(1))
                else []
            )
            continue
        used = re.findall(r"PermissionNames\.(\w+)", listed)
        unknown = set(used) - permission_names.keys()
        if unknown:
            raise SystemExit(f"role {name} references unknown permissions: {sorted(unknown)}")
        matrix[role] = [permission_names[c] for c in used]
    if not matrix:
        raise SystemExit("parsed an empty role matrix")
    return matrix


def read_level_roles(text: str, constants: dict[str, str]) -> list[tuple[str, str | None, str]]:
    """Return [(operator, threshold, role)] in source order, plus catch-all."""
    body = re.search(r"private static string RoleForLevel\(int level\) => level switch\s*\{(.*?)\n    \};", text, re.S)
    if not body:
        raise SystemExit(f"cannot find LegacyUserSeeder.RoleForLevel in {LEGACY_USER_SEEDER_CS}")
    arms = re.findall(r"(_|(?:>=|<=|>|<)\s*\d+)\s*=>\s*RolePermissionMatrix\.(\w+)", body.group(1))
    if not arms:
        raise SystemExit("parsed no RoleForLevel arms")
    parsed: list[tuple[str, str | None, str]] = []
    for condition, role in arms:
        if condition == "_":
            parsed.append(("_", None, role))
            continue
        op, number = re.match(r"(>=|<=|>|<)\s*(\d+)", condition).groups()
        parsed.append((op, number, role))
    return [(op, number, constants.get(role, role)) for op, number, role in parsed]


def role_for_level(level: int, arms: list[tuple[str, str | None, str]]) -> str:
    for op, threshold, role in arms:
        if op == "_":
            return role
        assert threshold is not None
        bound = int(threshold)
        if (op == ">=" and level >= bound) or (op == ">" and level > bound) \
                or (op == "<=" and level <= bound) or (op == "<" and level < bound):
            return role
    return ""


def staff_levels(staff: list[dict[str, str]]) -> Counter[str]:
    return Counter((row.get("SecurityLevel") or "").strip() for row in staff)


def staff_count_for(levels: set[str], counts: Counter[str]) -> int:
    return sum(counts[level] for level in levels)


# --------------------------------------------------------------------------- #
# Parity comparison
# --------------------------------------------------------------------------- #

def compare(legacy_levels: set[str], xopti_levels: set[str], counts: Counter[str]) -> tuple[str, str]:
    legacy_staff = {level for level in legacy_levels if counts[level]}
    xopti_staff = {level for level in xopti_levels if counts[level]}
    if not xopti_staff:
        return "none", ""
    if legacy_staff == xopti_staff:
        return "exact", ""
    if legacy_staff < xopti_staff:
        return "widened", "more staff gain the capability"
    if xopti_staff < legacy_staff:
        return "narrowed", "fewer staff keep the capability"
    if not (legacy_staff & xopti_staff):
        return "disjoint", "a different staff population holds the capability"
    return "partial", "access overlaps but the staff populations differ"


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("db", nargs="?", default=os.environ.get("SYNERGY_MDB", "eOptical6DAO/SynergyV.mdb"))
    parser.add_argument("--out", type=Path, default=ROOT / "docs/parity/permissions.csv")
    args = parser.parse_args()

    db = Path(args.db)
    if not db.exists():
        raise SystemExit(f"legacy database not found: {db}")

    security = export(db, "Security")
    staff = export(db, "Staff")
    counts = staff_levels(staff)
    defined_levels = sorted({(row["LeveL"] or "").strip() for row in security if row.get("LeveL")}, key=int)
    security_by_level = {(row["LeveL"] or "").strip(): row for row in security}

    permission_names, all_members = read_permission_names(PERMISSION_NAMES_CS.read_text())
    roles = read_role_matrix(ROLES_AND_IDENTITY_CS.read_text(), permission_names, all_members)
    level_arms = read_level_roles(
        LEGACY_USER_SEEDER_CS.read_text(), read_role_constants(ROLES_AND_IDENTITY_CS.read_text())
    )

    role_by_level = {level: role_for_level(int(level), level_arms) for level in defined_levels}
    levels_by_permission: dict[str, set[str]] = {}
    for level, role in role_by_level.items():
        for permission in roles.get(role, []):
            levels_by_permission.setdefault(permission, set()).add(level)

    rows: list[dict[str, str]] = []

    for capability in CAPABILITIES:
        field = capability["field"]
        granted = {
            level for level in defined_levels
            if truthy(security_by_level[level].get(field, ""))
        }
        xopti_permission = ";".join(permission_names[name] for name in capability["xopti"])
        xopti_levels: set[str] = set()
        for name in capability["xopti"]:
            xopti_levels |= levels_by_permission.get(permission_names[name], set())
        parity, parity_note = compare(granted, xopti_levels, counts)
        if not granted:
            status = "explicit-deny"
        elif not capability["xopti"]:
            status = "no-equivalent"
        elif parity == "exact":
            status = "mapped"
        else:
            status = "gap"

        notes = capability["notes"]
        if xopti_levels:
            notes += f" xOpti grants it at levels {','.join(sorted(xopti_levels, key=int))}."
        else:
            notes += " No xOpti role grants it."
        if parity_note and parity_note not in notes:
            notes += f" {parity_note.capitalize()}."
        if status == "gap":
            notes += " Requires a 3.2 customer decision."

        rows.append({
            "id": capability["id"],
            "kind": "capability",
            "legacy_source": "Security",
            "legacy_field": field,
            "legacy_value": capability["legacy_value"],
            "levels_granted": ",".join(sorted(granted, key=int)) or "none",
            "legacy_staff": str(staff_count_for(granted, counts)),
            "xopti_role": "",
            "xopti_permission": xopti_permission or "none",
            "xopti_staff": str(staff_count_for(xopti_levels, counts)),
            "legacy_enforcement": capability["enforcement"],
            "parity": parity,
            "status": status,
            "notes": notes,
        })

    for level in defined_levels:
        role = role_by_level[level]
        permissions = roles.get(role, [])
        legacy_fields = [
            capability["field"] for capability in CAPABILITIES
            if truthy(security_by_level[level].get(capability["field"], ""))
        ]
        legacy_permissions = {
            permission_names[name]
            for capability in CAPABILITIES if capability["field"] in legacy_fields
            for name in capability["xopti"]
        }
        missing = sorted(set(permissions) - legacy_permissions)
        absent = sorted(legacy_permissions - set(permissions))
        status = "mapped" if not absent else "gap"
        notes = f"Legacy capabilities: {','.join(legacy_fields) or 'none'}."
        if absent:
            notes += f" Legacy grants dropped by role '{role}': {','.join(absent)}."
        if missing:
            notes += f" Role adds: {','.join(missing)}."
        if not counts[level]:
            notes += " Level defined but unassigned in this snapshot."

        rows.append({
            "id": f"PERM-1{int(level):02d}",
            "kind": "level",
            "legacy_source": "Staff.SecurityLevel -> Security.LeveL",
            "legacy_field": "SecurityLevel",
            "legacy_value": f"Level {level}",
            "levels_granted": level,
            "legacy_staff": str(counts[level]),
            "xopti_role": role,
            "xopti_permission": ";".join(permissions) or "deny-all",
            "xopti_staff": str(counts[level]),
            "legacy_enforcement": "Level is stored per staff row; only Cost is checked at runtime",
            "parity": "exact" if not absent and not missing else ("narrowed" if absent else "widened"),
            "status": status,
            "notes": notes,
        })

    unassigned_roles = sorted(set(roles) - set(role_by_level.values()))
    for level in sorted({(row.get("SecurityLevel") or "").strip() for row in staff} - set(defined_levels), key=int):
        rows.append({
            "id": f"PERM-8{int(level):02d}",
            "kind": "unmapped-level",
            "legacy_source": "Staff.SecurityLevel",
            "legacy_field": "SecurityLevel",
            "legacy_value": f"Level {level}",
            "levels_granted": level,
            "legacy_staff": str(counts[level]),
            "xopti_role": role_for_level(int(level), level_arms),
            "xopti_permission": "deny-all",
            "xopti_staff": str(counts[level]),
            "legacy_enforcement": "No Security row; IsCostOK returns False and no level grants exist",
            "parity": "none",
            "status": "explicit-deny",
            "notes": "Unmapped legacy level denies by default.",
        })

    rows += [
        {
            "id": "PERM-009",
            "kind": "authentication",
            "legacy_source": "AppValidation.IsSecurityPassed (AppValidation.bas:206-230)",
            "legacy_field": "Staff.Password",
            "legacy_value": "Plaintext equality against the stored password",
            "levels_granted": "any staff row",
            "legacy_staff": str(len(staff)),
            "xopti_role": "n/a",
            "xopti_permission": "identity sign-in",
            "xopti_staff": str(len(staff)),
            "legacy_enforcement": "Enforced at logon only; password stored in plaintext",
            "parity": "n/a",
            "status": "mapped",
            "notes": "Do not migrate password values; xOpti forces a credential reset via "
                     "LegacyUserSeeder.ResetRequired.",
        },
        {
            "id": "PERM-010",
            "kind": "authentication",
            "legacy_source": "AppValidation.IsSecurityEnabled (AppValidation.bas:187-203)",
            "legacy_field": "Security row count",
            "legacy_value": ">1 row means security enabled",
            "levels_granted": "n/a",
            "legacy_staff": str(len(staff)),
            "xopti_role": "n/a",
            "xopti_permission": "always enforced",
            "xopti_staff": str(len(staff)),
            "legacy_enforcement": "Only gates the three IsCostOK call sites; "
                                  "a one-row Security table disables cost masking",
            "parity": "n/a",
            "status": "mapped",
            "notes": "xOpti always enforces authorization; there is no disabled state.",
        },
        {
            "id": "PERM-011",
            "kind": "bootstrap",
            "legacy_source": "AppValidation.GetDefaultUser (AppValidation.bas:239-266)",
            "legacy_field": "StaffCode 9999",
            "legacy_value": "Reserved user created on demand, SecurityLevel 1",
            "levels_granted": "1",
            "legacy_staff": "1 (synthetic)",
            "xopti_role": "none",
            "xopti_permission": "deny-all",
            "xopti_staff": "0",
            "legacy_enforcement": "Created when no staff code matches",
            "parity": "exact",
            "status": "mapped",
            "notes": "xOpti must require a real administrator and must not create staff 9999.",
        },
        {
            "id": "PERM-012",
            "kind": "policy",
            "legacy_source": "AppUser.SetUserProfile (AppUser.bas:10-20)",
            "legacy_field": "pyUserSLevel / pyHasCostLevel",
            "legacy_value": "Caches the level and cost bit for the session at logon",
            "levels_granted": "all",
            "legacy_staff": str(len(staff)),
            "xopti_role": "all",
            "xopti_permission": "xopti:permission claims per request",
            "xopti_staff": str(len(staff)),
            "legacy_enforcement": "Set once at logon; never re-read during the session",
            "parity": "n/a",
            "status": "mapped",
            "notes": "xOpti evaluates claims per request (ClaimsCurrentPrincipal.HasPermission), "
                     "so a revoked role takes effect without re-login.",
        },
    ]

    if unassigned_roles:
        rows.append({
            "id": "PERM-013",
            "kind": "policy",
            "legacy_source": "LegacyUserSeeder.RoleForLevel",
            "legacy_field": "xOpti role reachability",
            "legacy_value": f"No validated staff level reaches: {','.join(unassigned_roles)}",
            "levels_granted": "n/a",
            "legacy_staff": "0",
            "xopti_role": ",".join(unassigned_roles),
            "xopti_permission": "n/a",
            "xopti_staff": "0",
            "legacy_enforcement": "RoleForLevel maps levels >=7 to admin, but Security defines only levels 1-5",
            "parity": "none",
            "status": "gap",
            "notes": f"No migrated staff can hold {', '.join(unassigned_roles)}; assign "
                     "administrators and purchasers explicitly before cutover (task 3.2).",
        })

    args.out.parent.mkdir(parents=True, exist_ok=True)
    fieldnames = [
        "id", "kind", "legacy_source", "legacy_field", "legacy_value",
        "levels_granted", "legacy_staff", "xopti_role", "xopti_permission",
        "xopti_staff", "legacy_enforcement", "parity", "status", "notes",
    ]
    with args.out.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)

    gaps = [row["id"] for row in rows if row["status"] == "gap"]
    print(f"wrote {len(rows)} permission rows ({len(security)} levels, {len(staff)} staff) -> {args.out}")
    print(f"parity gaps needing sign-off: {', '.join(gaps) or 'none'}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
