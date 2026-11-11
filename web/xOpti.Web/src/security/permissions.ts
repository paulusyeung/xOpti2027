/**
 * Permission claim names, mirrored from
 * src/xOpti.Application/Authorization/PermissionNames.cs. A unit test fails if
 * this list drifts from the backend source. The server remains the authority;
 * these values only drive navigation and route guards.
 */
export const PermissionNames = {
  CostView: 'cost:view',
  InventoryAdjust: 'inventory:adjust',
  ReportFinancial: 'report:financial',
  CustomerPii: 'customer:pii',
  InventoryReceive: 'inventory:receive',
  SalesPriceOverride: 'sales:price-override',
  SalesOrderCreate: 'sales:order-create',
  SalesInvoicePost: 'sales:invoice-post',
  WholesaleInvoicePost: 'wholesale:invoice-post',
  PrescriptionEnter: 'prescription:enter',
  PrescriptionView: 'prescription:view',
  MasterDataMaintain: 'master-data:maintain',
} as const

export type PermissionName = (typeof PermissionNames)[keyof typeof PermissionNames]
