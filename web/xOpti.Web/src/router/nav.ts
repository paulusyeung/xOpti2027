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
