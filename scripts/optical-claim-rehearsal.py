"""Optical customer -> prescription -> order -> claim -> payment rehearsal.

Run against an API pointed at a disposable clone of the migrated database.
Environment: XOPTI_REHEARSAL_API, XOPTI_REHEARSAL_DB, XOPTI_REHEARSAL_PSQL.
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
PSQL = os.environ.get("XOPTI_REHEARSAL_PSQL", "psql-17")


def psql(sql, capture=False):
    cmd = ["docker", "exec", "-i", PSQL, "psql", "-U", "postgres", "-d", DB,
           "-v", "ON_ERROR_STOP=1"]
    if capture:
        return subprocess.run(cmd + ["-Atc", sql], check=True, capture_output=True,
                              text=True).stdout.strip()
    subprocess.run(cmd, input=sql, check=True, capture_output=True, text=True)


sku = "OC" + f"{random.randint(0, 99999999):08d}"
psql(f"""
INSERT INTO public.category (department_code, class_code, category_code, category_name,
    costing_method, inventory_method, tax_method) VALUES ('09','09','09','Optical','1','1','B')
ON CONFLICT (department_code, class_code, category_code) DO NOTHING;
DELETE FROM public.invt_lot_record WHERE sku = '{sku}';
INSERT INTO public.inventory (sku, department_code, class_code, category_code,
    supplier_code, brand_code, name, qty_total_on_hand, average_cost,
    inventory_lot_flag, retail_price_flag, whole_sale_price_flag)
VALUES ('{sku}', '09','09','09', '0001', '0001', 'Optical Claim Frame', 20, 20.0000,
    true, true, false);
INSERT INTO public.branch_inventory (branch_code, sku, qty_on_hand)
VALUES ('01', '{sku}', 20) ON CONFLICT (branch_code, sku) DO UPDATE SET qty_on_hand = 20;
INSERT INTO public.invt_lot_record (sku, lot_no, date_received, supplier_code,
    qty_purchased, qty_used, qty_on_hand, unit_amount_purchased, total_amount_purchased)
VALUES ('{sku}', 'OCLOT', now(), '0001', 20, 0, 20, 20.0000, 400.0000);
INSERT INTO public.retail_price (sku, retail_price) VALUES ('{sku}', 50.0000)
ON CONFLICT (sku) DO UPDATE SET retail_price = 50.0000;
UPDATE public.preference SET tax_a_rate = 5, tax_b_rate = 7;
""")

s = requests.Session()
token = s.get(f"{BASE}/api/v1/auth/csrf-token").json()["token"]
r = s.post(f"{BASE}/api/v1/auth/sign-in",
           json={"username": "manager", "password": "Test#Passw0rd1!"},
           headers={"X-CSRF-TOKEN": token})
assert r.status_code == 200, r.text
token = s.get(f"{BASE}/api/v1/auth/csrf-token").json()["token"]


def post(path, body, expected=200, idem=True):
    headers = {"X-CSRF-TOKEN": token}
    if idem:
        headers["Idempotency-Key"] = str(uuid.uuid4())
    r = s.post(BASE + path, json=body, headers=headers)
    assert r.status_code == expected, (path, r.status_code, r.text)
    return r


def put(path, body):
    r = s.put(BASE + path, json=body, headers={"X-CSRF-TOKEN": token})
    assert r.status_code == 200, (path, r.status_code, r.text)
    return r


customer = post("/api/v1/customers", {
    "input": {"fullName": "Optical Rehearsal Customer",
              "homePhone": "6045550199", "email": "optical-rehearsal@example.test"},
    "confirmDuplicate": True, "reason": "optical claim rehearsal"}, expected=201).json()
customer_id = customer["customer"]["id"]
rx = post(f"/api/v1/customers/{customer_id}/prescriptions/spectacle", {
    "issuedOn": datetime.datetime.now(datetime.timezone.utc).isoformat(),
    "prescriberId": 1,
    "right": {"sphere": 1.25, "cylinder": -0.5, "axis": 90, "add": 2, "prism": 0,
              "base": 0, "pd": 32},
    "left": {"sphere": -1.75, "cylinder": -1.25, "axis": 85, "add": 2, "prism": 0,
             "base": 0, "pd": 31},
    "notes": "rehearsal prescription", "reason": "rehearsal rx"}).json()
version_id = [v for v in rx["spectacle"] if v["source"] == "app"][-1]["id"]
post(f"/api/v1/customers/{customer_id}/prescriptions/verify", {
    "type": "spectacle", "versionId": version_id, "note": "verified", "reason": "rehearsal"})

order = post("/api/v1/sales/orders", {
    "customerId": customer_id, "staffCode": "0007", "depositAmount": 0,
    "reason": "rehearsal optical order",
    "lines": [{"sku": sku, "quantity": 1, "unitAmount": 50, "discountAmount": 0,
               "taxCode": "B"}]}, expected=201).json()
order_no = order["txNumber"]
put(f"/api/v1/sales/orders/{order_no}/optical", {
    "frames": [{"lineNumber": 1, "supply": True, "enclosed": False, "follow": False,
                "lenses": True, "mode": "Full rim", "color": "Black", "eyeSize": "52",
                "bridge": 18, "temple": 140, "r1": "", "r2": "", "r3": "", "a": "52",
                "b": "40", "specialInstruction": "rehearsal"}],
    "lenses": [{"lineNumber": 1, "prescriptionVersionId": version_id,
                "right": {"sphere": 1.25, "cylinder": -0.5, "axis": 90, "pd": 32,
                          "add": 2, "prism": 0, "base": 0, "segHeight": 0, "oc": 0, "vd": 12},
                "left": {"sphere": -1.75, "cylinder": -1.25, "axis": 85, "pd": 31,
                         "add": 2, "prism": 0, "base": 0, "segHeight": 0, "oc": 0, "vd": 12},
                "rightStyle": "SV", "leftStyle": "SV", "type": "Single vision",
                "hardening": "Standard", "material": "CR", "coating": "AR", "tint": "Clear",
                "others": "", "hardCoat": True, "arCoat": True, "uv": True}],
    "contacts": [], "reason": "rehearsal optical details"})
invoice = post(f"/api/v1/sales/orders/{order_no}/convert", {
    "sessionId": None, "reason": "rehearsal convert",
    "tenders": [{"method": "C", "amount": float(order["balance"]), "reference": None}]}).json()
invoice_no = invoice["txNumber"]

plan = post("/api/v1/claims/plans", {
    "planCode": "REH" + sku[-6:], "name": "Rehearsal Plan", "payerName": "Rehearsal Payer",
    "rules": [{"categoryCode": "09", "sku": None, "coveragePercent": 100,
               "annualMaximum": 0, "requiresPreauthorization": False}],
    "reason": "rehearsal plan"}).json()
today = datetime.date.today().isoformat()
member = post("/api/v1/claims/members", {
    "customerId": customer_id, "planId": plan["id"], "memberNumber": "REH-1",
    "groupNumber": None, "effectiveFrom": today, "effectiveTo": None,
    "eligibilityNote": None, "reason": "rehearsal member"}).json()
claim = post("/api/v1/claims", {
    "invoiceTxNumber": invoice_no, "memberId": member["id"], "invoiceRowNumbers": [1],
    "reason": "rehearsal claim"}, expected=201).json()
approved = post(f"/api/v1/claims/{claim['id']}/adjudicate", {
    "approvedAmount": float(claim["coveredAmount"]), "reason": "rehearsal approval",
    "reference": "REH-AUTH", "note": None}).json()
paid = post(f"/api/v1/claims/{claim['id']}/payments", {
    "amount": float(approved["approvedAmount"]), "method": "EFT", "reference": "REH-PAY",
    "reason": "rehearsal payment"}).json()
receipt = s.get(BASE + f"/api/v1/claims/{claim['id']}/receipt").json()
rbic = s.get(BASE + f"/api/v1/claims/rbic?from={today}&to={today}&reason=rehearsal")
assert rbic.status_code == 200 and claim["claimNumber"] in rbic.text
assert paid["status"] == "paid"
assert abs(float(receipt["coveredAmount"]) - float(claim["coveredAmount"])) < 0.0001

branch_qty = int(psql(f"select qty_on_hand from branch_inventory where branch_code='01' and sku='{sku}'", True))
print(json.dumps({
    "customerId": customer_id, "sku": sku, "prescriptionVersionId": version_id,
    "order": order_no, "invoice": invoice_no, "claim": claim["claimNumber"],
    "claimStatus": paid["status"], "covered": claim["coveredAmount"],
    "approved": approved["approvedAmount"], "paid": paid["paidAmount"],
    "invoiceTotal": invoice["totalAmount"], "branchOnHand": branch_qty,
    "rbicContainsClaim": claim["claimNumber"] in rbic.text,
}, indent=2))
