# xOpti migration reconciliation report

- Command: `cutover` (dry run) at 2026-11-10 00:14 UTC
- Source: `/home/paulus/Downloads/SynergyV.mdb` sha256 `55088a63b914f745a4bc6803ab07b11576b61e3d7c11e3f3c670bf11c2a5dd2e` (70 tables)
- Tolerance: 0.005
- Result: **FAIL** (14 failing checks)

| Check | Scope | Expected | Actual | Status | Detail |
| --- | --- | ---: | ---: | --- | --- |
| row-count | add -> add | 6 | 6 | PASS |  |
| row-count | barcodepool -> bar_code_pool | 344832 | 344832 | PASS |  |
| row-count | branch -> branch | 1 | 1 | PASS |  |
| row-count | branchinventory -> branch_inventory | 0 | 0 | PASS |  |
| row-count | branchsummary -> branch_summary | 0 | 0 | PASS |  |
| row-count | brand -> brand | 577 | 577 | PASS |  |
| row-count | category -> category | 53 | 53 | PASS |  |
| row-count | categorysummary -> category_summary | 7270 | 7282 | FAIL | difference 12 |
| row-count | city -> city | 335 | 335 | PASS |  |
| row-count | class -> class | 29 | 29 | PASS |  |
| row-count | classsummary -> class_summary | 3713 | 3725 | FAIL | difference 12 |
| row-count | costingmethod -> costing_method | 3 | 3 | PASS |  |
| row-count | country -> country | 66 | 66 | PASS |  |
| row-count | customer -> customer | 59978 | 59978 | PASS |  |
| row-count | customeraccounts -> customer_accounts | 59443 | 59443 | PASS |  |
| row-count | customermedical -> customer_medical | 58968 | 58968 | PASS |  |
| row-count | customerprescontact -> customer_pres_contact | 59193 | 59193 | PASS |  |
| row-count | customerpreslens -> customer_pres_lens | 59329 | 59329 | PASS |  |
| row-count | department -> department | 5 | 5 | PASS |  |
| row-count | deptsummary -> dept_summary | 1199 | 1207 | FAIL | difference 8 |
| row-count | doctor -> doctor | 1178 | 1178 | PASS |  |
| row-count | footer -> footer | 0 | 0 | PASS |  |
| row-count | hardening -> hardening | 0 | 0 | PASS |  |
| row-count | inventory -> inventory | 110339 | 110339 | PASS |  |
| row-count | invtlotrecord -> invt_lot_record | 357608 | 357608 | PASS |  |
| row-count | invtmethod -> invt_method | 2 | 2 | PASS |  |
| row-count | invtstdetails -> invt_st_details | 2819162 | 2819162 | PASS |  |
| row-count | invtstheader -> invt_st_header | 119 | 119 | PASS |  |
| row-count | invtstimport -> invt_st_import | 2 | 2 | PASS |  |
| row-count | invtststatus -> invt_st_status | 6 | 6 | PASS |  |
| row-count | invtsummary -> invt_summary | 510107 | 510137 | FAIL | difference 30 |
| row-count | jobnature -> job_nature | 5 | 5 | PASS |  |
| row-count | jobstatus -> job_status | 0 | 0 | PASS |  |
| row-count | jobtitle -> job_title | 8 | 8 | PASS |  |
| row-count | maritalstatus -> marital_status | 5 | 5 | PASS |  |
| row-count | material -> material | 9 | 9 | PASS |  |
| row-count | paste errors -> paste_errors | 1 | 1 | PASS |  |
| row-count | paymentmethods -> payment_methods | 12 | 12 | PASS |  |
| row-count | paymentsummary -> payment_summary | 34366 | 34366 | PASS |  |
| row-count | payper -> pay_per | 4 | 4 | PASS |  |
| row-count | payperiod -> pay_period | 4 | 4 | PASS |  |
| row-count | preference -> preference | 1 | 1 | PASS |  |
| row-count | preftxnumber -> pref_tx_number | 13 | 13 | PASS |  |
| row-count | province -> province | 66 | 66 | PASS |  |
| row-count | rebuildcost -> rebuild_cost | 6780 | 6780 | PASS |  |
| row-count | remarks -> remarks | 0 | 0 | PASS |  |
| row-count | retailprice -> retail_price | 110822 | 110822 | PASS |  |
| row-count | salesorderstatus -> sales_order_status | 10 | 10 | PASS |  |
| row-count | salutation -> salutation | 5 | 5 | PASS |  |
| row-count | security -> security | 5 | 5 | PASS |  |
| row-count | sex -> sex | 2 | 2 | PASS |  |
| row-count | staff -> staff | 61 | 61 | PASS |  |
| row-count | staffhistory -> staff_history | 125 | 125 | PASS |  |
| row-count | supplier -> supplier | 202 | 202 | PASS |  |
| row-count | suppliercontactperson -> supplier_contact_person | 19 | 19 | PASS |  |
| row-count | suppliersummary -> supplier_summary | 10239 | 10249 | FAIL | difference 10 |
| row-count | taxmethod -> tax_method | 6 | 6 | PASS |  |
| row-count | txdetails -> tx_details | 1223530 | 1223578 | FAIL | difference 48 |
| row-count | txheader -> tx_header | 547731 | 547731 (+4619 synthetic) | PASS |  |
| row-count | txpayment -> tx_payment | 250908 | 250908 | PASS |  |
| row-count | txsaleperson -> tx_sale_person | 548175 | 548175 | PASS |  |
| row-count | txsorderadd -> tx_s_order_add | 148 | 148 | PASS |  |
| row-count | txsordercont -> tx_s_order_cont | 40734 | 40734 | PASS |  |
| row-count | txsorderextra -> tx_s_order_extra | 432932 | 432932 | PASS |  |
| row-count | txsorderframe -> tx_s_order_frame | 24 | 24 | PASS |  |
| row-count | txsorderlens -> tx_s_order_lens | 86536 | 86536 | PASS |  |
| row-count | utilchecklog -> util_check_log | 490 | 490 | PASS |  |
| row-count | wholesaleprice -> wholesale_price | 0 | 0 | PASS |  |
| row-count | z_defaultclass -> z__default_class | 14 | 14 | PASS |  |
| row-count | z_defaultremarks -> z__default_remarks | 3 | 3 | PASS |  |
| target-only-rows | category_summary | 0 | 12 | FAIL | target rows have no staged legacy counterpart; delete or investigate (exception workbook) |
| target-only-rows | class_summary | 0 | 12 | FAIL | target rows have no staged legacy counterpart; delete or investigate (exception workbook) |
| target-only-rows | dept_summary | 0 | 8 | FAIL | target rows have no staged legacy counterpart; delete or investigate (exception workbook) |
| target-only-rows | invt_summary | 0 | 30 | FAIL | target rows have no staged legacy counterpart; delete or investigate (exception workbook) |
| target-only-rows | supplier_summary | 0 | 10 | FAIL | target rows have no staged legacy counterpart; delete or investigate (exception workbook) |
| target-only-rows | tx_details | 0 | 48 | FAIL | target rows have no staged legacy counterpart; delete or investigate (exception workbook) |
| tx_header.total_amount by type | groups | equal within tolerance | equal | PASS |  |
| tx_header.gross_sale by type | groups | equal within tolerance | equal | PASS |  |
| tx_header.tax by type | groups | equal within tolerance | equal | PASS |  |
| tx_header.refunds.total (RS+WR) | all | -8399888.9122 | -8399888.9122 | PASS |  |
| tx_payment.tender by type | groups | equal within tolerance | equal | PASS |  |
| tx_payment.total_paid | all | 35822187.4852 | 35822187.4852 | PASS |  |
| tx_details.qty | all | 1260480.00 | 1260527.00 | FAIL | diff -47.00 |
| tx_details.amount | all | 88450235.926 | 88456952.526 | FAIL | diff -6716.60 |
| customer_accounts.purchased (AR) | all | 0.00 | 0.00 | PASS |  |
| customer_accounts.refunds (AR) | all | -2495251.4487 | -2495251.4487 | PASS |  |
| tx_header.status counts by type | groups | equal within tolerance | equal | PASS |  |
| inventory.qty by sku | rows | equal | equal | PASS |  |
| inventory.cost by sku | rows | equal | equal | PASS |  |
| inventory.qty by lot | rows | equal | equal | PASS |  |
| inventory.lot cost by lot | rows | equal | equal | PASS |  |
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
| control numbers ahead of migrated data | groups | equal within tolerance | equal | PASS |  |
| anomalies.synthetic-headers | tx_header | reported | 4619 | INFO | orphaned children migrated under flagged synthetic headers |
| anomalies.quarantine-entries | migration.anomaly_quarantine | reported | 1000 | INFO |  |
