import { PermissionNames } from '@/security/permissions'
import type { RuntimeConfig } from '@/runtime/config'
import { DEFAULT_REFERENCE_PAGE, referencePageByLabel, referencePath } from './referencePages'

export interface NavItem {
  to?: string
  title: string
  icon: string
  permission?: string
  feature?: 'analytics'
  /** Stable test hook, used when the legacy label differs from the xOpti screen name. */
  testId?: string
  children?: readonly NavItem[]
}

export interface NavGroup {
  title: string
  icon: string
  items: readonly NavItem[]
}

/** Builds a unique reference-screen URL so each legacy label highlights on its own. */
function referenceLink(legacy: string): string {
  return referencePath(referencePageByLabel(legacy) ?? DEFAULT_REFERENCE_PAGE)
}

/** Builds the leaf nodes of a legacy Report Centre tree node. */
function reportLeaves(
  titles: readonly string[],
  to: string,
  permission: string,
  icon = 'mdi-file-document-outline',
): NavItem[] {
  return titles.map((title) => ({ to, title, icon, permission }))
}

/**
 * Navigation mirrors the seven sections of the legacy eOptical6DAO switchboard,
 * in the same order and with the same labels. Each screen points at the closest
 * xOpti equivalent; screens that do not exist yet reuse the relevant admin page.
 */
export const NAV_GROUPS: readonly NavGroup[] = [
  {
    title: 'Point-of-Sale',
    icon: 'mdi-point-of-sale',
    items: [
      { to: '/admin/pos', title: 'Order Entry', icon: 'mdi-cash-register', permission: PermissionNames.SalesOrderCreate },
      { to: '/admin/pos/cash', title: 'Daily Closing', icon: 'mdi-cash-lock', permission: PermissionNames.SalesInvoicePost },
      { to: '/admin/pos', title: 'Re-Print Order', icon: 'mdi-printer', permission: PermissionNames.SalesOrderCreate },
      { to: '/admin/pos/sale', title: 'Re-Print Invoice', icon: 'mdi-printer', permission: PermissionNames.SalesInvoicePost },
      { to: '/admin/claims', title: 'Re-Print Claim Form', icon: 'mdi-printer', permission: PermissionNames.ReportFinancial },
    ],
  },
  {
    title: 'Inventory Control',
    icon: 'mdi-warehouse',
    items: [
      { to: '/admin/purchasing', title: 'Stock Received', icon: 'mdi-truck-delivery-outline', permission: PermissionNames.InventoryReceive },
      { to: '/admin/stock-ops', title: 'Stock Rejected', icon: 'mdi-close-circle-outline', permission: PermissionNames.InventoryAdjust },
      { to: '/admin/stock-ops', title: 'Stock Adjustment', icon: 'mdi-tune-variant', permission: PermissionNames.InventoryAdjust },
      { to: '/admin/stock-take', title: 'Stock Take', icon: 'mdi-clipboard-check-outline', permission: PermissionNames.InventoryAdjust },
      { to: '/admin/wholesale/invoices', title: 'Wholesale Invoice', icon: 'mdi-file-document-outline', permission: PermissionNames.WholesaleInvoicePost },
      { to: '/admin/wholesale/returns', title: 'Wholesale Return', icon: 'mdi-keyboard-return', permission: PermissionNames.WholesaleInvoicePost },
    ],
  },
  {
    title: 'OLAP',
    icon: 'mdi-chart-box-outline',
    items: [
      {
        to: '/analytics',
        title: 'Sales by Cost',
        icon: 'mdi-chart-line',
        permission: PermissionNames.ReportFinancial,
        feature: 'analytics',
        testId: 'nav-analytics',
      },
      {
        to: '/analytics',
        title: 'Sales by LSP',
        icon: 'mdi-chart-areaspline',
        permission: PermissionNames.ReportFinancial,
        feature: 'analytics',
      },
      { to: '/admin/reports', title: 'Order In Progress', icon: 'mdi-progress-clock', permission: PermissionNames.ReportFinancial },
    ],
  },
  {
    title: 'Information Centre',
    icon: 'mdi-information-outline',
    items: [
      { to: '/admin/catalogue', title: 'SKU Info', icon: 'mdi-package-variant-closed', permission: PermissionNames.InventoryAdjust },
      { to: '/admin/supplier-activity', title: 'Supplier Info', icon: 'mdi-account-cash-outline', permission: PermissionNames.InventoryReceive },
      { to: '/admin/customers', title: 'Customer Info', icon: 'mdi-account-group-outline', permission: PermissionNames.SalesOrderCreate },
      { to: '/admin/optical', title: 'Order Planner', icon: 'mdi-calendar-clock-outline', permission: PermissionNames.SalesOrderCreate },
    ],
  },
  {
    title: 'Coding',
    icon: 'mdi-format-list-bulleted-square',
    items: [
      { title: 'Department', icon: 'mdi-sitemap-outline', permission: PermissionNames.MasterDataMaintain, to: referenceLink('Department') },
      { title: 'Class', icon: 'mdi-shape-outline', permission: PermissionNames.MasterDataMaintain, to: referenceLink('Class') },
      { title: 'Category', icon: 'mdi-tag-multiple-outline', permission: PermissionNames.MasterDataMaintain, to: referenceLink('Category') },
      { to: '/admin/inventory', title: 'Inventory', icon: 'mdi-warehouse', permission: PermissionNames.InventoryAdjust },
      { title: 'Brand', icon: 'mdi-label-outline', permission: PermissionNames.MasterDataMaintain, to: referenceLink('Brand') },
      { title: 'Add', icon: 'mdi-plus-box-outline', permission: PermissionNames.MasterDataMaintain, to: referenceLink('Add') },
      { title: 'Material', icon: 'mdi-layers-outline', permission: PermissionNames.MasterDataMaintain, to: referenceLink('Material') },
      { title: 'Doctor', icon: 'mdi-stethoscope', permission: PermissionNames.MasterDataMaintain, to: referenceLink('Doctor') },
      { to: '/admin/supplier-activity', title: 'Supplier', icon: 'mdi-truck-outline', permission: PermissionNames.InventoryReceive },
      { to: '/admin/customers', title: 'Customer', icon: 'mdi-account-group-outline', permission: PermissionNames.SalesOrderCreate },
      { to: '/admin/staff', title: 'Staff', icon: 'mdi-account-cog-outline', permission: PermissionNames.MasterDataMaintain, testId: 'nav-staff' },
      { title: 'Branch', icon: 'mdi-store-outline', permission: PermissionNames.MasterDataMaintain, to: referenceLink('Branch') },
      { title: 'Payment', icon: 'mdi-credit-card-outline', permission: PermissionNames.MasterDataMaintain, to: referenceLink('Payment') },
    ],
  },
  {
    title: 'Report',
    icon: 'mdi-file-chart-outline',
    items: [
      {
        title: 'Coding',
        icon: 'mdi-format-list-bulleted-square',
        permission: PermissionNames.MasterDataMaintain,
        testId: 'nav-report-coding',
        children: [
          { to: referenceLink('Add Code Listing'), title: 'Add Code Listing', icon: 'mdi-file-document-outline', permission: PermissionNames.MasterDataMaintain },
          { to: referenceLink('Brand Code Listing'), title: 'Brand Code Listing', icon: 'mdi-file-document-outline', permission: PermissionNames.MasterDataMaintain },
          { to: referenceLink('Category Code Listing'), title: 'Category Code Listing', icon: 'mdi-file-document-outline', permission: PermissionNames.MasterDataMaintain },
          { to: referenceLink('Class Code Listing'), title: 'Class Code Listing', icon: 'mdi-file-document-outline', permission: PermissionNames.MasterDataMaintain },
          { to: referenceLink('Department Code Listing'), title: 'Department Code Listing', icon: 'mdi-file-document-outline', permission: PermissionNames.MasterDataMaintain },
          { to: referenceLink('Material Code Listing'), title: 'Material Code Listing', icon: 'mdi-file-document-outline', permission: PermissionNames.MasterDataMaintain },
        ],
      },
      {
        to: '/admin/customers',
        title: 'Customer',
        icon: 'mdi-account-group-outline',
        permission: PermissionNames.SalesOrderCreate,
        testId: 'nav-report-customer',
        children: reportLeaves([
          'Birthday Reminder',
          'Customer Listing (Active)',
          'Customer Listing (General)',
          'Customer Listing (Inactive)',
          'Insurance Reminder',
          'Prescription Reminder',
          'VIP Listing (Inactive)',
        ], '/admin/customers', PermissionNames.SalesOrderCreate),
      },
      {
        to: '/admin/staff',
        title: 'Employee',
        icon: 'mdi-account-tie-outline',
        permission: PermissionNames.MasterDataMaintain,
        testId: 'nav-report-employee',
        children: reportLeaves([
          'Employee Listing',
        ], '/admin/staff', PermissionNames.MasterDataMaintain),
      },
      {
        to: '/admin/inventory',
        title: 'Inventory',
        icon: 'mdi-warehouse',
        permission: PermissionNames.InventoryAdjust,
        testId: 'nav-report-inventory',
        children: reportLeaves([
          'Insufficient Stock Listing',
          'Inventory Ledger',
          'Inventory Listing (By LSP)',
          'Inventory Listing (Short)',
          'Inventory On Hand Summary',
          'Inventory Special On Hand Analysis',
          'Inventory Special Purchase Analysis',
          'Re-stocking Report',
          'Sales by Category',
          'Slow Movement Inventory Listing',
          'Stock Adjustment',
          'Stock Received',
          'Stock Received (By Supplier)',
          'Stock Rejected',
        ], '/admin/inventory', PermissionNames.InventoryAdjust),
      },
      {
        to: '/admin/reports',
        title: 'Sales',
        icon: 'mdi-chart-line',
        permission: PermissionNames.ReportFinancial,
        testId: 'nav-report-sales',
        children: reportLeaves([
          'Cost and Margin of Goods Sold',
          'Daily Cash Receipts',
          'Exceptional Sales Report',
          'Invoice List (By Date)',
          'Invoice List (By Invoice No.)',
          'Orders Report (By Date)',
          'Orders Report (By Order No.)',
          'Outstanding Orders on hand',
          'Receipts Report',
          'Sales Return Journal',
          'Sales Report',
        ], '/admin/reports', PermissionNames.ReportFinancial, 'mdi-chart-line'),
      },
      {
        to: '/admin/reports',
        title: 'Various Special Reports',
        icon: 'mdi-file-document-multiple-outline',
        permission: PermissionNames.CostView,
        testId: 'nav-report-special',
        children: [{
          to: '/admin/reports',
          title: 'Various Special Reports',
          icon: 'mdi-file-document-outline',
          permission: PermissionNames.CostView,
          testId: 'nav-report-special-leaf',
        }],
      },
      {
        to: '/admin/wholesale',
        title: 'WholeSales',
        icon: 'mdi-truck-fast-outline',
        permission: PermissionNames.WholesaleInvoicePost,
        testId: 'nav-report-wholesales',
        children: reportLeaves([
          'Wholesales Summary (By Date)',
          'Wholesales Summary (By No.)',
        ], '/admin/wholesale', PermissionNames.WholesaleInvoicePost),
      },
    ],
  },
  {
    title: 'Preference',
    icon: 'mdi-cog-outline',
    items: [
      { title: 'City', icon: 'mdi-map-marker-outline', permission: PermissionNames.MasterDataMaintain, to: referenceLink('City') },
      { title: 'Province', icon: 'mdi-map-outline', permission: PermissionNames.MasterDataMaintain, to: referenceLink('Province') },
      { title: 'Country', icon: 'mdi-earth', permission: PermissionNames.MasterDataMaintain, to: referenceLink('Country') },
      { title: 'Job Title', icon: 'mdi-briefcase-outline', permission: PermissionNames.MasterDataMaintain, to: referenceLink('Job Title') },
      { title: 'Job Nature', icon: 'mdi-account-hard-hat-outline', permission: PermissionNames.MasterDataMaintain, to: referenceLink('Job Nature') },
      { title: 'Salutation', icon: 'mdi-handshake-outline', permission: PermissionNames.MasterDataMaintain, to: referenceLink('Salutation') },
      { to: '/admin/security', title: 'Security', icon: 'mdi-shield-key-outline', permission: PermissionNames.MasterDataMaintain },
      { to: '/admin/special-reports', title: 'Special Report', icon: 'mdi-file-document-outline', permission: PermissionNames.ReportFinancial },
    ],
  },
]

export const HOME_ITEM: NavItem = { to: '/', title: 'Home', icon: 'mdi-home-outline' }

/** Recursive menu shape consumed by the sidebar renderer. */
export interface NavTreeNode {
  title: string
  icon?: string
  to?: string
  testId?: string
  children?: NavTreeNode[]
}

function slug(value: string): string {
  return value
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-|-$/g, '')
}

/**
 * Builds the sidebar tree in the same shape as the legacy switchboard: a flat
 * Home link followed by the seven top-level groups. Groups (and empty groups)
 * are dropped when the signed-in user may not open any child.
 */
export function buildNavTree(
  session: { hasPermission(permission: string): boolean },
  config: RuntimeConfig,
): NavTreeNode[] {
  const nodes: NavTreeNode[] = [
    { title: HOME_ITEM.title, icon: HOME_ITEM.icon, to: HOME_ITEM.to, testId: 'nav-home' },
  ]

  for (const group of NAV_GROUPS) {
    const children = group.items
      .map((item) => toNode(item, session, config))
      .filter((item): item is NavTreeNode => item !== null)

    if (children.length === 0) {
      continue
    }

    nodes.push({
      title: group.title,
      icon: group.icon,
      testId: `nav-group-${slug(group.title)}`,
      children,
    })
  }

  return nodes
}

function toNode(
  item: NavItem,
  session: { hasPermission(permission: string): boolean },
  config: RuntimeConfig,
): NavTreeNode | null {
  if (!isNavItemVisible(item, session, config)) {
    return null
  }

  const children = item.children
    ?.map((child) => toNode(child, session, config))
    .filter((child): child is NavTreeNode => child !== null)

  if (item.children && (!children || children.length === 0)) {
    return null
  }

  return {
    title: item.title,
    icon: item.icon,
    to: item.to,
    testId: item.testId ?? `nav-${slug(item.title)}`,
    children: children?.length ? children : undefined,
  }
}

function flatten(items: readonly NavItem[]): NavItem[] {
  return items.flatMap((item) =>
    item.children ? [item, ...flatten(item.children)] : [item],
  )
}

/** Flattened entries retained for route/permission tests and other callers. */
export const NAV_ITEMS: readonly NavItem[] = [
  HOME_ITEM,
  ...flatten(NAV_GROUPS.flatMap((group) => group.items)),
]

export function isFeatureEnabled(feature: NavItem['feature'], config: RuntimeConfig): boolean {
  if (feature === 'analytics') {
    return config.analyticsEnabled
  }
  return true
}

/** A nav entry is shown only when its user holds its permission and its feature is enabled. */
export function isNavItemVisible(
  item: NavItem,
  session: { hasPermission(permission: string): boolean },
  config: RuntimeConfig,
): boolean {
  if (!isFeatureEnabled(item.feature, config)) {
    return false
  }
  return item.permission === undefined || session.hasPermission(item.permission)
}
