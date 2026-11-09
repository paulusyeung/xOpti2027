#!/usr/bin/env python3
import argparse
import csv
import io
import os
import re
import subprocess
import sys
from pathlib import Path
from urllib.parse import urlsplit, urlunsplit

ROOT = Path(__file__).resolve().parents[2]
ENV_FILE = ROOT / "eOptical6DAO" / ".env"
SCRATCH_DB = "xopti_migration_compare"

KNOWN_RENAMES = {
    ("preference", "paltform"): "platform",
    ("txsorderlens", "rigthbase"): "right_base",
    ("txsorderlens", "rigthoc"): "right_oc",
}


def load_env():
    env = dict(os.environ)
    if ENV_FILE.exists():
        for raw in ENV_FILE.read_text().splitlines():
            line = raw.strip()
            if not line or line.startswith("#") or "=" not in line:
                continue
            key, value = line.split("=", 1)
            env.setdefault(key, value.strip().strip("'").strip('"'))
    return env


ENV = load_env()


def scratch_url():
    if ENV.get("SCRATCH_DATABASE_URL"):
        return ENV["SCRATCH_DATABASE_URL"]
    url = ENV.get("DATABASE_URL") or os.environ.get("DATABASE_URL")
    if not url:
        raise SystemExit("DATABASE_URL or SCRATCH_DATABASE_URL is required")
    parts = urlsplit(url)
    return urlunsplit((parts.scheme, parts.netloc, "/" + SCRATCH_DB, parts.query, parts.fragment))


URL = scratch_url()


def psql(sql):
    proc = subprocess.run(
        ["psql", URL, "-v", "ON_ERROR_STOP=1", "--csv", "-P", "footer=off", "-c", sql],
        capture_output=True,
        text=True,
    )
    if proc.returncode:
        raise SystemExit(proc.stderr.strip())
    return list(csv.DictReader(io.StringIO(proc.stdout)))


def canon(value):
    return re.sub(r"[^a-z0-9]", "", value.lower())


def qident(value):
    return '"' + value.replace('"', '""') + '"'


def mdb_schema():
    source = ENV.get("SYNERGY_MDB", str(Path.home() / "Downloads" / "SynergyV.mdb"))
    proc = subprocess.run(
        ["mdb-schema", "--no-indexes", "--no-relations", "--no-comments", source, "postgres"],
        capture_output=True,
        text=True,
    )
    if proc.returncode:
        raise SystemExit(proc.stderr.strip())
    tables = {}
    for match in re.finditer(r'CREATE TABLE IF NOT EXISTS\s+"([^"]+)"\s*\((.*?)\n\);', proc.stdout, re.S):
        table, body = match.group(1), match.group(2)
        columns = []
        for line in body.splitlines():
            line = line.strip().rstrip(",")
            col = re.match(r'"([^"]+)"\s+(.+)$', line)
            if not col:
                continue
            name, rest = col.group(1), col.group(2).strip()
            not_null = bool(re.search(r"\bNOT NULL\b", rest))
            sql_type = re.sub(r"\s+NOT NULL\b", "", rest).strip()
            columns.append((name, sql_type, not_null))
        tables[canon(table)] = {"name": table, "columns": columns}
    return tables


def type_class(sql_type):
    value = re.sub(r"\s+", " ", sql_type.upper()).strip()
    match = re.match(r"VARCHAR\s*\((\d+)\)", value)
    if match:
        return ("varchar", int(match.group(1)))
    match = re.match(r"NUMERIC\s*\((\d+),\s*(\d+)\)", value)
    if match:
        return ("numeric", int(match.group(1)), int(match.group(2)))
    if value == "NUMERIC":
        return ("numeric", None, None)
    if value in ("INTEGER", "SERIAL"):
        return ("int",)
    if value == "SMALLINT":
        return ("smallint",)
    if value == "BIGINT":
        return ("bigint",)
    if value == "REAL":
        return ("real",)
    if value == "DOUBLE PRECISION":
        return ("double",)
    if value.startswith("TIMESTAMP"):
        return ("timestamp",)
    if value == "BOOLEAN":
        return ("bool",)
    if value == "TEXT":
        return ("text",)
    return ("other", value)


def pg_type_class(row):
    data_type = row["data_type"]
    if data_type == "character varying":
        return ("varchar", int(row["char_len"]) if row["char_len"] else None)
    if data_type == "numeric":
        return ("numeric", int(row["num_prec"]) if row["num_prec"] else None, int(row["num_scale"]) if row["num_scale"] else None)
    if data_type == "integer":
        return ("int",)
    if data_type == "smallint":
        return ("smallint",)
    if data_type == "bigint":
        return ("bigint",)
    if data_type == "real":
        return ("real",)
    if data_type == "double precision":
        return ("double",)
    if data_type.startswith("timestamp"):
        return ("timestamp",)
    if data_type == "boolean":
        return ("bool",)
    if data_type == "text":
        return ("text",)
    return ("other", data_type)


def pg_columns():
    rows = psql(
        """
        select c.table_name, c.column_name, c.data_type, c.is_nullable,
               c.character_maximum_length as char_len,
               c.numeric_precision as num_prec, c.numeric_scale as num_scale
        from information_schema.columns c
        join information_schema.tables t
          on t.table_schema = c.table_schema and t.table_name = c.table_name
        where c.table_schema = 'public' and t.table_type = 'BASE TABLE'
        order by c.table_name, c.ordinal_position
        """
    )
    tables = {}
    for row in rows:
        tables.setdefault(canon(row["table_name"]), {"name": row["table_name"], "columns": []})["columns"].append(row)
    return tables


def schema_report():
    mdb = mdb_schema()
    pg = pg_columns()
    mdb_only = sorted(mdb[key]["name"] for key in set(mdb) - set(pg))
    pg_only = sorted(pg[key]["name"] for key in set(pg) - set(mdb))
    missing_columns = []
    renamed_columns = []
    type_diffs = []
    null_diffs = []
    for key in sorted(set(mdb) & set(pg)):
        mt, pt = mdb[key], pg[key]
        mcol = {canon(name): (name, sql_type, not_null) for name, sql_type, not_null in mt["columns"]}
        pcol = {canon(row["column_name"]): row for row in pt["columns"]}
        for col_key in sorted(set(mcol) - set(pcol)):
            mname = mcol[col_key][0]
            target_name = KNOWN_RENAMES.get((canon(mt["name"]), col_key))
            if target_name:
                renamed_columns.append((mt["name"], mname, target_name))
            else:
                missing_columns.append((mt["name"], mname))
        for col_key in sorted(set(mcol) & set(pcol)):
            mname, msql, mnotnull = mcol[col_key]
            prow = pcol[col_key]
            if mnotnull != (prow["is_nullable"] == "NO"):
                kind = "tightened" if (not mnotnull and prow["is_nullable"] == "NO") else "relaxed"
                null_diffs.append((kind, mt["name"], mname, prow["column_name"], mnotnull, prow["is_nullable"]))
            mtype, ptype = type_class(msql), pg_type_class(prow)
            if mtype != ptype:
                type_diffs.append((mt["name"], mname, prow["column_name"], msql, prow["data_type"], prow["char_len"], prow["num_prec"], prow["num_scale"], mtype, ptype))

    print("## Schema\n")
    print(f"- Source tables: {len(mdb)}")
    print(f"- Target base tables: {len(pg)}")
    print(f"- Source-only tables: {', '.join(mdb_only) if mdb_only else 'none'}")
    print(f"- Target-only base tables: {', '.join(pg_only) if pg_only else 'none'}")
    print(f"- Missing columns: {len(missing_columns)}")
    if missing_columns:
        print("\n| Table | Source column |\n| --- | --- |")
        for table, column in missing_columns:
            print(f"| `{table}` | `{column}` |")
    print(f"- Corrected source typos: {len(renamed_columns)}")
    for table, source, target in renamed_columns:
        print(f"  - `{table}.{source}` -> `{target}`")
    widening = {}
    unexpected = []
    for row in type_diffs:
        table, mname, pname, msql, ptype, clen, prec, scale, mtype, ptype_class = row
        if mtype == ("real",) and ptype_class == ("double",):
            widening["REAL -> double precision"] = widening.get("REAL -> double precision", 0) + 1
        elif mtype[:1] == ("numeric",) and mtype[1:] == (15, 2) and ptype_class == ("numeric", 19, 4):
            widening["NUMERIC(15,2) -> numeric(19,4)"] = widening.get("NUMERIC(15,2) -> numeric(19,4)", 0) + 1
        elif mtype == ("int",) and ptype in ("integer",):
            pass
        else:
            unexpected.append(row)
    print(f"- Type differences: {len(type_diffs)}")
    for label, count in sorted(widening.items()):
        print(f"  - {label}: {count}")
    print(f"- Unexpected type differences: {len(unexpected)}")
    for row in unexpected:
        print(f"  - `{row[0]}.{row[1]}`: `{row[3]}` -> `{row[4]}`")
    tightened = sum(1 for row in null_diffs if row[0] == "tightened")
    relaxed = len(null_diffs) - tightened
    print(f"- Nullability differences: {len(null_diffs)} ({tightened} tightened, {relaxed} relaxed)")


def staging_tables():
    rows = psql(
        """
        select table_name
        from information_schema.tables
        where table_schema = 'mdb' and table_type = 'BASE TABLE'
        order by table_name
        """
    )
    return {canon(row["table_name"]): row["table_name"] for row in rows}


def count_report(limit=40):
    mdb = staging_tables()
    pg = pg_columns()
    rows = []
    for key in sorted(set(mdb) & set(pg)):
        mname, pname = mdb[key], pg[key]["name"]
        mcount = int(psql(f"select count(*) as n from mdb.{qident(mname)}")[0]["n"])
        pcount = int(psql(f"select count(*) as n from public.{qident(pname)}")[0]["n"])
        rows.append((mname, pname, mcount, pcount, pcount - mcount))
    total_m = sum(row[2] for row in rows)
    total_p = sum(row[3] for row in rows)
    differing = [row for row in rows if row[4] != 0]
    print("## Row counts\n")
    print(f"- Source rows: {total_m:,}")
    print(f"- Target rows: {total_p:,}")
    print(f"- Difference: {total_p - total_m:+,}")
    print(f"- Tables compared: {len(rows)}")
    print(f"- Tables with differences: {len(differing)}")
    print("\n| Source table | Target table | Source rows | Target rows | Difference |")
    print("| --- | --- | ---: | ---: | ---: |")
    for mname, pname, mcount, pcount, diff in sorted(rows, key=lambda item: item[4])[:limit]:
        print(f"| `{mname}` | `{pname}` | {mcount:,} | {pcount:,} | {diff:+,} |")


def key_diff(join, mdb_table, pg_table, date_expr, label):
    mdb_name = staging_tables().get(canon(mdb_table))
    pg_name = pg_columns().get(canon(pg_table), {}).get("name")
    if not mdb_name or not pg_name:
        return
    print(f"\n### {label}\n")
    for side, table, other, not_exists in (
        ("source-only", f"mdb.{qident(mdb_name)}", f"public.{qident(pg_name)}", join),
        ("target-only", f"public.{qident(pg_name)}", f"mdb.{qident(mdb_name)}", join),
    ):
        alias = "m" if side == "source-only" else "p"
        other_alias = "p" if side == "source-only" else "m"
        source = f'upper({alias}."txnumber")' if alias == "m" else f'upper({alias}."tx_number")'
        if mdb_table == "txheader":
            match = f'upper({other_alias}."tx_number") = upper({alias}."txnumber")' if alias == "m" else f'upper({other_alias}."txnumber") = upper({alias}."tx_number")'
        elif mdb_table == "txdetails":
            match = f'upper({other_alias}."tx_number") = upper({alias}."txnumber") and {other_alias}.date_of_entry = {alias}.dateofentry and {other_alias}.row_no = round({alias}.rowno::numeric)' if alias == "m" else f'upper({other_alias}."txnumber") = upper({alias}."tx_number") and {other_alias}.dateofentry = {alias}.date_of_entry and round({other_alias}.rowno::numeric) = {alias}.row_no'
        elif mdb_table == "txpayment":
            match = f'upper({other_alias}."tx_number") = upper({alias}."txnumber") and {other_alias}.payment_line_no = round({alias}.paymentlineno::numeric) and {other_alias}.type = {alias}.type' if alias == "m" else f'upper({other_alias}."txnumber") = upper({alias}."tx_number") and round({other_alias}.paymentlineno::numeric) = {alias}.payment_line_no and {other_alias}.type = {alias}.type'
        else:
            match = f'upper({other_alias}."tx_number") = upper({alias}."txnumber") and {other_alias}.sales_row_no = round({alias}.salesrowno::numeric) and {other_alias}.staff_code = {alias}.staffcode' if alias == "m" else f'upper({other_alias}."txnumber") = upper({alias}."tx_number") and round({other_alias}.salesrowno::numeric) = {alias}.sales_row_no and {other_alias}.staffcode = {alias}.staff_code'
        sql = f"""
        with x as (
            select {date_expr(alias)} as yr
            from {table} {alias}
            where not exists (select 1 from {other} {other_alias} where {match})
        )
        select yr, count(*) as n from x group by yr order by yr nulls first
        """
        result = psql(sql)
        total = sum(int(row["n"]) for row in result)
        print(f"- {side}: {total:,}")
        for row in result:
            print(f"  - {row['yr'] or 'unknown'}: {int(row['n']):,}")


def key_report():
    def header_year(alias):
        return f"extract(year from {alias}.dateofentry)::int" if alias == "m" else f"extract(year from {alias}.date_of_entry)::int"

    print("## Key differences")
    key_diff("", "txheader", "tx_header", header_year, "tx_header")
    key_diff("", "txdetails", "tx_details", header_year, "tx_details")

    for label, mdb_table, pg_table, mdb_key, pg_key in (
        ("tx_payment", "txpayment", "tx_payment", "upper(m.txnumber)=upper(p.tx_number) and round(m.paymentlineno::numeric)=p.payment_line_no and m.type=p.type", "upper(m.txnumber)=upper(p.tx_number) and round(m.paymentlineno::numeric)=p.payment_line_no and m.type=p.type"),
        ("tx_sale_person", "txsaleperson", "tx_sale_person", "upper(m.txnumber)=upper(p.tx_number) and round(m.salesrowno::numeric)=p.sales_row_no and m.staffcode=p.staff_code", "upper(m.txnumber)=upper(p.tx_number) and round(m.salesrowno::numeric)=p.sales_row_no and m.staffcode=p.staff_code"),
    ):
        print(f"\n### {label}\n")
        if label == "tx_payment":
            sql = """
            with x as (
              select coalesce(extract(year from h.dateofentry), extract(year from ph.date_of_entry))::int yr,
                     (m.txnumber is null) pg_only
              from mdb.txpayment m full join public.tx_payment p
                on upper(p.tx_number)=upper(m.txnumber)
               and p.payment_line_no=round(m.paymentlineno::numeric)
               and p.type=m.type
              left join mdb.txheader h on upper(h.txnumber)=upper(m.txnumber)
              left join public.tx_header ph on upper(ph.tx_number)=upper(p.tx_number)
              where m.txnumber is null or p.tx_number is null
            )
            select yr, pg_only, count(*) n from x group by 1,2 order by 1,2
            """
        else:
            sql = """
            with x as (
              select coalesce(extract(year from h.dateofentry), extract(year from ph.date_of_entry))::int yr,
                     (m.txnumber is null) pg_only
              from mdb.txsaleperson m full join public.tx_sale_person p
                on upper(p.tx_number)=upper(m.txnumber)
               and p.sales_row_no=round(m.salesrowno::numeric)
               and p.staff_code=m.staffcode
              left join mdb.txheader h on upper(h.txnumber)=upper(m.txnumber)
              left join public.tx_header ph on upper(ph.tx_number)=upper(p.tx_number)
              where m.txnumber is null or p.tx_number is null
            )
            select yr, pg_only, count(*) n from x group by 1,2 order by 1,2
            """
        result = psql(sql)
        for side in (False, True):
            total = sum(int(row["n"]) for row in result if row["pg_only"] == ("t" if side else "f"))
            print(f"- {'target-only' if side else 'source-only'}: {total:,}")
            for row in result:
                if row["pg_only"] == ("t" if side else "f"):
                    print(f"  - {row['yr'] or 'unknown'}: {int(row['n']):,}")


def main():
    parser = argparse.ArgumentParser(description="Compare staged MDB data with xOpti PostgreSQL data.")
    parser.add_argument("section", nargs="?", default="all", choices=("all", "schema", "counts", "keys"))
    args = parser.parse_args()
    print("# MDB to xOpti comparison\n")
    if args.section in ("all", "schema"):
        schema_report()
        print()
    if args.section in ("all", "counts"):
        count_report()
        print()
    if args.section in ("all", "keys"):
        key_report()


if __name__ == "__main__":
    main()
