# xOpti migration reconciliation report

- Command: `cutover` (dry run) at 2026-11-10 00:53 UTC
- Source: `/home/paulus/Downloads/SynergyV.mdb` sha256 `55088a63b914f745a4bc6803ab07b11576b61e3d7c11e3f3c670bf11c2a5dd2e` (70 tables)
- Tolerance: 0.005
- Result: **FAIL** (3 failing checks)

| Check | Scope | Expected | Actual | Status | Detail |
| --- | --- | ---: | ---: | --- | --- |
| row-count | payperiod -> pay_period | 4 | 4 | PASS |  |
| row-count | salutation -> salutation | 5 | 5 | PASS |  |
| row-count | security -> security | 5 | 5 | PASS |  |
| sequence | barcode_pool_id_seq vs bar_code_pool.id | >= max | ok | PASS |  |
| sequence | city_code_seq vs city.code | >= max | ok | PASS |  |
| sequence | customer_id_seq vs customer.id | >= max | ok | PASS |  |
| sequence | doctor_id_seq vs doctor.id | >= max | ok | PASS |  |
| sequence | hardening_id_seq vs hardening.id | >= max | ok | PASS |  |
| sequence | invt_st_details_id_seq vs invt_st_details.id | >= max | ok | PASS |  |
| sequence | invt_st_header_id_seq vs invt_st_header.id | >= max | ok | PASS |  |
| sequence | users_id_seq vs users.id | >= max | ok | PASS |  |
| sequence | util_check_log__log_number_seq vs util_check_log.log_number | >= max | ok | PASS |  |
| sequence | z_default_remarks_id_seq vs z__default_remarks.id | >= max | ok | PASS |  |
| control numbers ahead of migrated data | WR | 70.00 | 1577.00 | FAIL |  |
| control numbers ahead of migrated data | WC | 978.00 | 1710.00 | FAIL |  |
| control numbers ahead of migrated data | SA | 1.00 | 9144651.00 | FAIL |  |
| anomalies.synthetic-headers | tx_header | reported | 0 | PASS | orphaned children migrated under flagged synthetic headers |
| anomalies.quarantine-entries | migration.anomaly_quarantine | reported | 0 | PASS |  |
