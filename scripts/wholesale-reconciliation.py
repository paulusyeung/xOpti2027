"""Reconcile posted WC/WR test documents against migrated wholesale history.

Run against a disposable clone of the migrated database after app migrations and
smoke seeding. Environment: XOPTI_WHOLESALE_API, XOPTI_WHOLESALE_DB,
XOPTI_WHOLESALE_PSQL.
"""
import datetime
import json
import os
import random
import subprocess
import uuid

import requests

BASE = os.environ.get("XOPTI_WHOLESALE_API", "http://127.0.0.1:5199")
DB = os.environ.get("XOPTI_WHOLESALE_DB", "xopti_wholesale_reconciliation")
PSQL = os.environ.get("XOPTI_WHOLESALE_PSQL", "psql-17")


def psql(sql, capture=False):
    cmd = ["docker", "exec", "-i", PSQL, "psql", "-U", "postgres", "-d", DB,
           "-v", "ON_ERROR_STOP=1"]
    if capture:
        return subprocess.run(cmd + ["-Atc", sql], check=True, capture_output=True,
                              text=True).stdout.strip()
    subprocess.run(cmd, input=sql, check=True, capture_output=True, text=True)


def scalar(sql):
    value = psql(sql, capture=True)
    return value.splitlines()[0] if value else ""


sku = "WS" + f"{random.randint(0, 99999999):08d}"
customer_name = "Wholesale Reconciliation " + uuid.uuid4().hex[:6]

psql(f"""
INSERT INTO public.category (department_code, class_code, category_code, category_name,
    costing_method, inventory_method, tax_method) VALUES ('09','09','09','Wholesale','1','1','B')
ON CONFLICT (department_code, class_code, category_code) DO NOTHING;
DELETE FROM public.invt_lot_record WHERE sku = '{sku}';
INSERT INTO public.inventory (sku, department_code, class_code, category_code,
    supplier_code, brand_code, name, qty_total_on_hand, average_cost,
    inventory_lot_flag, retail_price_flag, whole_sale_price_flag)
VALUES ('{sku}', '09','09','09', '0001', '0001', 'Wholesale Reconciliation Item', 10, 5.0000,
    true, true, true);
INSERT INTO public.branch_inventory (branch_code, sku, qty_on_hand)
VALUES ('01', '{sku}', 10) ON CONFLICT (branch_code, sku) DO UPDATE SET qty_on_hand = 10;
INSERT INTO public.invt_lot_record (sku, lot_no, date_received, supplier_code,
    qty_purchased, qty_used, qty_on_hand, unit_amount_purchased, total_amount_purchased)
VALUES ('{sku}', 'WSRLOT', now(), '0001', 10, 0, 10, 5.0000, 50.0000);
UPDATE public.preference SET tax_a_rate = 5, tax_b_rate = 7;
""")

baseline = {
    "wcCount": int(scalar("select count(*) from public.tx_header where tx_type='WC'")),
    "wrCount": int(scalar("select count(*) from public.tx_header where tx_type='WR'")),
    "wcTotal": float(scalar(
        "select coalesce(sum(total_amount),0) from public.tx_header where tx_type='WC'")),
    "wrTotal": float(scalar(
        "select coalesce(sum(total_amount),0) from public.tx_header where tx_type='WR'")),
}

s = requests.Session()
token = s.get(f"{BASE}/api/v1/auth/csrf-token").json()["token"]
r = s.post(f"{BASE}/api/v1/auth/sign-in",
           json={"username": "manager", "password": "Test#Passw0rd1!"},
           headers={"X-CSRF-TOKEN": token})
assert r.status_code == 200, r.text
token = s.get(f"{BASE}/api/v1/auth/csrf-token").json()["token"]


def put(path, body, expected=200):
    response = s.put(BASE + path, json=body, headers={"X-CSRF-TOKEN": token})
    assert response.status_code == expected, (path, response.status_code, response.text)
    return response


def post(path, body, expected=200, idem=True):
    headers = {"X-CSRF-TOKEN": token}
    if idem:
        headers["Idempotency-Key"] = str(uuid.uuid4())
    response = s.post(BASE + path, json=body, headers=headers)
    assert response.status_code == expected, (path, response.status_code, response.text)
    return response


customer = post("/api/v1/customers", {
    "input": {"fullName": customer_name, "homePhone": "6045550177",
              "email": "wholesale-reconciliation@example.test"},
    "confirmDuplicate": True, "reason": "wholesale reconciliation"}, expected=201).json()
customer_id = customer["customer"]["id"]
put(f"/api/v1/wholesale/accounts/{customer_id}", {
    "input": {"priceGrade": "A", "termsCode": "NET30", "termsDays": 30,
              "creditLimit": 50000, "taxTreatment": "GST",
              "representativeStaffCode": None, "creditHold": False,
              "notes": "reconciliation"},
    "reason": "wholesale reconciliation account"})
post("/api/v1/wholesale/price-lists", {
    "input": {"code": "A", "name": "Reconciliation list",
              "items": [{"sku": sku, "price": 10.0}]},
    "reason": "wholesale reconciliation price"})

invoice = post("/api/v1/wholesale/invoices", {
    "customerId": customer_id, "staffCode": "0007",
    "lines": [{"sku": sku, "quantity": 2, "unitAmount": 10.0, "discountAmount": 0,
               "taxCode": "B", "overrideReason": None, "description": "reconciliation",
               "backorderQuantity": 0}],
    "tenders": [], "shipping": {
        "shippingMethod": "Courier", "shipToName": "Dock", "shipToAddress": "1 Way",
        "shippingInstructions": None, "purchaseOrderNumber": "PO-REC",
        "dueDate": None},
    "reason": "wholesale reconciliation invoice"}, expected=201).json()
invoice_number = invoice["txNumber"]
post(f"/api/v1/wholesale/invoices/{invoice_number}/post", {
    "tenders": [{"method": "C", "amount": 22.4, "reference": None}],
    "reason": "post reconciliation invoice"})

return_one = post("/api/v1/wholesale/returns", {
    "originalInvoiceNumber": invoice_number, "staffCode": "0007",
    "lines": [{"originalRowNo": 1, "quantity": 1, "restock": True,
               "dispositionReason": None}],
    "tenders": [], "reason": "reconciliation partial return"}, expected=201).json()
post(f"/api/v1/wholesale/returns/{return_one['txNumber']}/post", {
    "tenders": [{"method": "C", "amount": 11.2, "reference": None}],
    "reason": "post partial return"})
return_two = post("/api/v1/wholesale/returns", {
    "originalInvoiceNumber": invoice_number, "staffCode": "0007",
    "lines": [{"originalRowNo": 1, "quantity": 1, "restock": False,
               "dispositionReason": "damaged"}],
    "tenders": [], "reason": "reconciliation write-off return"}, expected=201).json()
post(f"/api/v1/wholesale/returns/{return_two['txNumber']}/post", {
    "tenders": [{"method": "C", "amount": 11.2, "reference": None}],
    "reason": "post write-off return"})

after = {
    "wcCount": int(scalar("select count(*) from public.tx_header where tx_type='WC'")),
    "wrCount": int(scalar("select count(*) from public.tx_header where tx_type='WR'")),
    "wcTotal": float(scalar(
        "select coalesce(sum(total_amount),0) from public.tx_header where tx_type='WC'")),
    "wrTotal": float(scalar(
        "select coalesce(sum(total_amount),0) from public.tx_header where tx_type='WR'")),
}
inventory_qty = int(scalar(
    f"select qty_on_hand from public.branch_inventory where branch_code='01' and sku='{sku}'"))
balance = s.get(BASE + f"/api/v1/wholesale/customers/{customer_id}/balance").json()
history = psql(f"""
select tx_type, tx_number, control_number, total_amount
from public.tx_header where customer_id = {customer_id}
order by tx_type, tx_number;""", capture=True).splitlines()
control_numbers = [row.split("|")[2] for row in history]
expected = {
    "wcCountDelta": 1,
    "wrCountDelta": 2,
    "wcTotalDelta": 22.4,
    "wrTotalDelta": -22.4,
    "inventoryQty": 9,
    "balance": 0.0,
    "historyRows": 3,
    "uniqueControls": 3,
}
actual = {
    "wcCountDelta": after["wcCount"] - baseline["wcCount"],
    "wrCountDelta": after["wrCount"] - baseline["wrCount"],
    "wcTotalDelta": round(after["wcTotal"] - baseline["wcTotal"], 4),
    "wrTotalDelta": round(after["wrTotal"] - baseline["wrTotal"], 4),
    "inventoryQty": inventory_qty,
    "balance": float(balance["balance"]),
    "historyRows": len(history),
    "uniqueControls": len(set(control_numbers)),
}
differences = {
    key: {"expected": expected[key], "actual": actual[key]}
    for key in expected if expected[key] != actual[key]
}

print(json.dumps({
    "sku": sku,
    "customerId": customer_id,
    "invoice": invoice_number,
    "returns": [return_one["txNumber"], return_two["txNumber"]],
    "baseline": baseline,
    "after": after,
    "expected": expected,
    "actual": actual,
    "differences": differences,
    "history": history,
}, indent=2))
if differences:
    raise SystemExit(1)
