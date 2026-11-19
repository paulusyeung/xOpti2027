import { PermissionNames } from '@/security/permissions'
import type { RuntimeConfig } from '@/runtime/config'

export interface NavItem {
  to: string
  title: string
  icon: string
  permission?: string
  feature?: 'analytics'
}

export interface NavGroup {
  title: string
  icon: string
  items: readonly NavItem[]
}

/**
 * Navigation follows the legacy eOptical6DAO top-level menus, mapped onto the
 * xOpti screens: Point-of-Service, Inventory Control, Coding, Information
 * Centre, reporting/analytics, and administration.
 */
export const NAV_GROUPS: readonly NavGroup[] = [
  {
    title: 'Point-of-Service',
    icon: 'mdi-point-of-sale',
    items: [
      {
        to: '/admin/pos',
        title: 'POS',
        icon: 'mdi-point-of-sale',
        permission: PermissionNames.SalesOrderCreate,
      },
      {
        to: '/admin/pos/sale',
        title: 'POS sale',
        icon: 'mdi-cash-register',
        permission: PermissionNames.SalesInvoicePost,
      },
      {
        to: '/admin/pos/refund',
        title: 'POS refund',
        icon: 'mdi-cash-refund',
        permission: PermissionNames.SalesInvoicePost,
      },
      {
        to: '/admin/pos/cash',
        title: 'Cash drawer',
        icon: 'mdi-cash-lock',
        permission: PermissionNames.SalesInvoicePost,
      },
    ],
  },
  {
    title: 'Inventory Control',
    icon: 'mdi-warehouse',
    items: [
      {
        to: '/admin/inventory',
        title: 'Inventory',
        icon: 'mdi-warehouse',
        permission: PermissionNames.InventoryAdjust,
      },
      {
        to: '/admin/stock-ops',
        title: 'Stock ops',
        icon: 'mdi-swap-horizontal',
        permission: PermissionNames.InventoryAdjust,
      },
      {
        to: '/admin/stock-take',
        title: 'Stock take',
        icon: 'mdi-clipboard-check-outline',
        permission: PermissionNames.InventoryAdjust,
      },
      {
        to: '/admin/purchasing',
        title: 'Purchasing',
        icon: 'mdi-truck-delivery-outline',
        permission: PermissionNames.InventoryReceive,
      },
      {
        to: '/admin/supplier-activity',
        title: 'Supplier activity',
        icon: 'mdi-account-cash-outline',
        permission: PermissionNames.InventoryReceive,
      },
      {
        to: '/admin/wholesale/invoices',
        title: 'Wholesale invoices',
        icon: 'mdi-file-document-outline',
        permission: PermissionNames.WholesaleInvoicePost,
      },
      {
        to: '/admin/wholesale/returns',
        title: 'Wholesale returns',
        icon: 'mdi-keyboard-return',
        permission: PermissionNames.WholesaleInvoicePost,
      },
    ],
  },
  {
    title: 'Coding',
    icon: 'mdi-format-list-bulleted-square',
    items: [
      {
        to: '/admin/customers',
        title: 'Customers',
        icon: 'mdi-account-group-outline',
        permission: PermissionNames.SalesOrderCreate,
      },
      {
        to: '/admin/catalogue',
        title: 'Catalogue',
        icon: 'mdi-package-variant-closed',
        permission: PermissionNames.InventoryAdjust,
      },
      {
        to: '/admin/reference',
        title: 'References',
        icon: 'mdi-format-list-bulleted-square',
        permission: PermissionNames.MasterDataMaintain,
      },
      {
        to: '/admin/wholesale',
        title: 'Wholesale',
        icon: 'mdi-truck-fast-outline',
        permission: PermissionNames.WholesaleInvoicePost,
      },
    ],
  },
  {
    title: 'Information Centre',
    icon: 'mdi-information-outline',
    items: [
      {
        to: '/admin/optical',
        title: 'Optical orders',
        icon: 'mdi-glasses',
        permission: PermissionNames.SalesOrderCreate,
      },
      {
        to: '/admin/prescriptions',
        title: 'Prescriptions',
        icon: 'mdi-eye-outline',
        permission: PermissionNames.PrescriptionView,
      },
      {
        to: '/admin/claims',
        title: 'Claims',
        icon: 'mdi-shield-check-outline',
        permission: PermissionNames.ReportFinancial,
      },
    ],
  },
  {
    title: 'Reports & Analytics',
    icon: 'mdi-file-chart-outline',
    items: [
      {
        to: '/admin/reports',
        title: 'Reports',
        icon: 'mdi-file-chart-outline',
        permission: PermissionNames.ReportFinancial,
      },
      {
        to: '/analytics',
        title: 'Analytics',
        icon: 'mdi-chart-box-outline',
        permission: PermissionNames.ReportFinancial,
        feature: 'analytics',
      },
    ],
  },
  {
    title: 'Administration',
    icon: 'mdi-cog-outline',
    items: [
      {
        to: '/admin/staff',
        title: 'Staff',
        icon: 'mdi-account-cog-outline',
        permission: PermissionNames.MasterDataMaintain,
      },
      {
        to: '/admin/import',
        title: 'Import',
        icon: 'mdi-file-upload-outline',
        permission: PermissionNames.MasterDataMaintain,
      },
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

/**
 * Builds the sidebar tree in the same shape as the legacy app menus: a flat
 * Home link followed by collapsible top-level groups. Groups (and empty
 * groups) are dropped when the signed-in user may not open any child.
 */
export function buildNavTree(
  session: { hasPermission(permission: string): boolean },
  config: RuntimeConfig,
): NavTreeNode[] {
  const nodes: NavTreeNode[] = [
    {
      title: HOME_ITEM.title,
      icon: HOME_ITEM.icon,
      to: HOME_ITEM.to,
      testId: 'nav-home',
    },
  ]

  for (const group of NAV_GROUPS) {
    const children = group.items
      .filter((item) => isNavItemVisible(item, session, config))
      .map((item) => ({
        title: item.title,
        icon: item.icon,
        to: item.to,
        testId: `nav-${item.title.toLowerCase()}`,
      }))

    if (children.length === 0) {
      continue
    }

    nodes.push({
      title: group.title,
      icon: group.icon,
      testId: `nav-group-${group.title
        .toLowerCase()
        .replace(/[^a-z0-9]+/g, '-')
        .replace(/^-|-$/g, '')}`,
      children,
    })
  }

  return nodes
}

/** Flattened entries retained for route/permission tests and callers that need a single list. */
export const NAV_ITEMS: readonly NavItem[] = [
  HOME_ITEM,
  ...NAV_GROUPS.flatMap((group) => group.items),
]

export function isFeatureEnabled(feature: NavItem['feature'], config: RuntimeConfig): boolean {
  if (feature === 'analytics') {
    return config.analyticsEnabled
  }
  return true
}

/** A nav entry is shown only when the user holds its permission and its feature is enabled. */
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
