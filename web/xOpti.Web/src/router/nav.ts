import { PermissionNames } from '@/security/permissions'
import type { RuntimeConfig } from '@/runtime/config'

export interface NavItem {
  to: string
  title: string
  icon: string
  permission?: string
  feature?: 'analytics'
}

export const NAV_ITEMS: readonly NavItem[] = [
  { to: '/', title: 'Home', icon: 'mdi-home-outline' },
  {
    to: '/admin/pos',
    title: 'POS',
    icon: 'mdi-point-of-sale',
    permission: PermissionNames.SalesOrderCreate,
  },
  {
    to: '/admin/staff',
    title: 'Staff',
    icon: 'mdi-account-cog-outline',
    permission: PermissionNames.MasterDataMaintain,
  },
  {
    to: '/admin/reference',
    title: 'References',
    icon: 'mdi-format-list-bulleted-square',
    permission: PermissionNames.MasterDataMaintain,
  },
  {
    to: '/admin/catalogue',
    title: 'Catalogue',
    icon: 'mdi-package-variant-closed',
    permission: PermissionNames.InventoryAdjust,
  },
  {
    to: '/admin/import',
    title: 'Import',
    icon: 'mdi-file-upload-outline',
    permission: PermissionNames.MasterDataMaintain,
  },
  {
    to: '/admin/inventory',
    title: 'Inventory',
    icon: 'mdi-warehouse',
    permission: PermissionNames.InventoryAdjust,
  },
  {
    to: '/admin/purchasing',
    title: 'Purchasing',
    icon: 'mdi-truck-delivery-outline',
    permission: PermissionNames.InventoryReceive,
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
    to: '/admin/supplier-activity',
    title: 'Supplier activity',
    icon: 'mdi-account-cash-outline',
    permission: PermissionNames.InventoryReceive,
  },
  {
    to: '/analytics',
    title: 'Analytics',
    icon: 'mdi-chart-box-outline',
    permission: PermissionNames.ReportFinancial,
    feature: 'analytics',
  },
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
