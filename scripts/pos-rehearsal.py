"""End-to-end POS rehearsal against a clone of the migrated legacy database.

Start the API against the clone, then run this script. It creates a fresh
customer/SKU and exercises order conversion, direct invoice, split tender,
refund, drawer movements, drawer close, daily close, and journal reconciliation.

Environment:
  XOPTI_REHEARSAL_API   API base URL (default http://127.0.0.1:5199)
  XOPTI_REHEARSAL_DB    PostgreSQL database name (default xopti_pos_rehearsal)
  XOPTI_REHEARSAL_PSQL  psql container name (default psql-17)
"""
import datetime
import json
import os
import random
import subprocess
import uuid

import requests

BASE = os.environ.get("XOPTI_REHEARSAL_API", "http://127.0.0.1:5199")
DB = os.environ.get("XOPTI_REHEARSAL_DB", "xopti_pos_rehearsal")
PSQL_CONTAINER = os.environ.get("XOPTI_REHEARSAL_PSQL", "psql-17")

def psql(sql, capture=False):
    cmd = ["docker", "exec", "-i", PSQL_CONTAINER, "psql", "-U", "postgres", "-d", DB, "-v", "ON_ERROR_STOP=1"]
    if capture:
        cmd += ["-Atc", sql]
        out = subprocess.run(cmd, check=True, capture_output=True, text=True)
        return out.stdout.strip()
    out = subprocess.run(cmd, input=sql, check=True, capture_output=True, text=True)
    return out.stdout

customer_id = int(psql("select coalesce(max(id),0)+1 from public.customer", capture=True))
sku = "RH" + f"{random.randint(0, 99999999):08d}"
psql(f"""
INSERT INTO public.customer (id, full_name) VALUES ({customer_id}, 'Migrated Rehearsal Customer');
INSERT INTO public.category (department_code, class_code, category_code, category_name,
    costing_method, inventory_method, tax_method) VALUES ('09','09','09','POS','1','1','B')
ON CONFLICT (department_code, class_code, category_code) DO NOTHING;
UPDATE public.preference SET tax_a_rate = 5, tax_b_rate = 7;
DELETE FROM public.invt_lot_record WHERE sku = '{sku}';
INSERT INTO public.inventory (sku, department_code, class_code, category_code,
    supplier_code, brand_code, name, qty_total_on_hand, average_cost,
    inventory_lot_flag, retail_price_flag, whole_sale_price_flag)
VALUES ('{sku}', '09','09','09', '0001', '0001', 'Migrated Rehearsal Frame', 20, 30.0000,
    true, true, false);
INSERT INTO public.branch_inventory (branch_code, sku, qty_on_hand) VALUES ('01', '{sku}', 20)
ON CONFLICT (branch_code, sku) DO UPDATE SET qty_on_hand = 20;
INSERT INTO public.invt_lot_record (sku, lot_no, date_received, supplier_code,
    qty_purchased, qty_used, qty_on_hand, unit_amount_purchased, total_amount_purchased)
VALUES ('{sku}', 'REHLOT', now(), '0001', 20, 0, 20, 30.0000, 600.0000);
INSERT INTO public.retail_price (sku, retail_price) VALUES ('{sku}', 50.0000)
ON CONFLICT (sku) DO UPDATE SET retail_price = 50.0000;
""")

s = requests.Session()
r = s.get(f"{BASE}/api/v1/auth/csrf-token"); r.raise_for_status()
token = r.json()["token"]
r = s.post(f"{BASE}/api/v1/auth/sign-in", json={"username":"manager","password":"Test#Passw0rd1!"},
           headers={"X-CSRF-TOKEN": token})
assert r.status_code == 200, (r.status_code, r.text)
token = s.get(f"{BASE}/api/v1/auth/csrf-token").json()["token"]

def post(path, body, idem=True, expected=200):
    headers = {"X-CSRF-TOKEN": token}
    if idem: headers["Idempotency-Key"] = str(uuid.uuid4())
    r = s.post(BASE + path, json=body, headers=headers)
    assert r.status_code == expected, (path, r.status_code, r.text)
    return r

def get(path):
    r = s.get(BASE + path); assert r.status_code == 200, (path, r.status_code, r.text)
    return r

s1 = post("/api/v1/cash/sessions", {"branchCode":"01","terminalCode":"31","openingFloat":100,"reason":"rehearsal drawer"}, expected=201).json()
s2 = post("/api/v1/cash/sessions", {"branchCode":"01","terminalCode":"32","openingFloat":100,"reason":"rehearsal drawer"}, expected=201).json()
sid1, sid2 = s1["id"], s2["id"]

order = post("/api/v1/sales/orders", {
  "customerId": customer_id, "staffCode":"0007", "depositAmount":20, "reason":"migrated rehearsal order",
  "lines":[{"sku":sku,"quantity":2,"unitAmount":50,"discountAmount":0,"taxCode":"B"}]}, expected=201).json()
order_no = order["txNumber"]
conv = post(f"/api/v1/sales/orders/{order_no}/convert", {
  "sessionId": sid1, "reason":"migrated rehearsal conversion",
  "tenders":[{"method":"C","amount":92,"reference":None}]}, expected=200).json()
order_invoice = conv["txNumber"]

direct = post("/api/v1/sales/invoices", {
  "customerId": customer_id, "staffCode":"0007", "sessionId": sid2,
  "reason":"migrated rehearsal split",
  "lines":[{"sku":sku,"quantity":2,"unitAmount":50,"discountAmount":0,"taxCode":"B"}],
  "tenders":[{"method":"C","amount":60,"reference":None},{"method":"K","amount":52,"reference":"AUTH-MIGR"}]},
  expected=201).json()
direct_no = direct["txNumber"]

refund = post("/api/v1/sales/refunds", {
  "originalTxNumber": direct_no, "staffCode":"0007", "sessionId": sid2,
  "reason":"migrated rehearsal refund",
  "lines":[{"originalRowNo":1,"quantity":1,"restock":False}],
  "replacements":[],
  "refundTenders":[{"method":"C","amount":56,"reference":None,"originalPaymentLineNo":1}],
  "saleTenders":[]}, expected=201).json()
refund_no = refund["txNumber"]

for body in ({"kind":"paid-in","amount":10,"reason":"float top-up","destinationReference":None},):
    post(f"/api/v1/cash/sessions/{sid1}/movements", body)
post(f"/api/v1/cash/sessions/{sid1}/movements", {"kind":"pickup","amount":20,"reason":"midday pickup","destinationReference":"SAFE-1"})
post(f"/api/v1/cash/sessions/{sid2}/movements", {"kind":"deposit","amount":5,"reason":"bank deposit","destinationReference":"BANK-1"})

post(f"/api/v1/cash/sessions/{sid1}/close", {"countedCash":182,"varianceReason":None,"reason":"close terminal 31"})
post(f"/api/v1/cash/sessions/{sid2}/close", {"countedCash":99,"varianceReason":None,"reason":"close terminal 32"})
business_date = datetime.date.today().isoformat()
close = post("/api/v1/cash/daily-closes", {"branchCode":"01","businessDate":business_date,"reason":"migrated full-day rehearsal"}).json()
journal = get(f"/api/v1/cash/journal?branchCode=01&businessDate={business_date}").json()

expected = {
  "totalSales": 200, "totalRefunds": 50, "taxA": 7.5, "taxB": 10.5,
  "cashTenders": 96, "cardTenders": 52, "paidIn": 10, "paidOut": 0,
  "pickups": 20, "deposits": 5, "expectedCash": 281, "countedCash": 281,
  "variance": 0,
}
for key, value in expected.items():
    assert abs(float(close[key]) - value) < 0.0001, (key, close[key], value)
assert close["status"] == "final" and len(close["documents"]) == 3
assert journal["expectedCash"] == close["expectedCash"]

qty = int(psql(f"select qty_total_on_hand from public.inventory where sku = '{sku}'", capture=True))
branch_qty = int(psql(f"select qty_on_hand from public.branch_inventory where branch_code='01' and sku='{sku}'", capture=True))
links = psql(f"select count(*) from platform.cash_session_tx where tx_number in ('{order_invoice}','{direct_no}','{refund_no}')", capture=True)
legacy = int(psql("select count(*) from public.tx_header", capture=True))
print(json.dumps({
  "sku": sku, "customerId": customer_id, "order": order_no, "converted": order_invoice,
  "direct": direct_no, "refund": refund_no, "inventory": qty, "branchInventory": branch_qty,
  "sessionLinks": links, "legacyTransactions": legacy,
  "totals": {key: close[key] for key in expected},
  "documents": [d["txNumber"] for d in close["documents"]],
}, indent=2))
