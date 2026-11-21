import { createRouter, createWebHistory, type RouteRecordRaw, type Router, type RouterHistory } from 'vue-router'
import { getRuntimeConfig } from '@/runtime/config'
import { useSessionStore } from '@/stores/session'
import { useShellStore } from '@/stores/shell'
import { isFeatureEnabled } from './nav'
import { REFERENCE_PAGES, referencePath } from './referencePages'
import { PermissionNames } from '@/security/permissions'

const referenceAdminPage = () => import('@/features/admin/ReferenceAdminPage.vue')

declare module 'vue-router' {
  interface RouteMeta {
    /** Reachable without a session (sign-in only). */
    public?: boolean
    /** Permission claim required to open the route. */
    permission?: string
    /** Deployment feature that must be enabled for the route to exist. */
    feature?: 'analytics'
    title?: string
  }
}

export const routes: RouteRecordRaw[] = [
  {
    path: '/sign-in',
    name: 'sign-in',
    component: () => import('@/pages/SignInPage.vue'),
    meta: { public: true, title: 'Sign in' },
  },
  {
    path: '/',
    name: 'home',
    component: () => import('@/pages/HomePage.vue'),
    meta: { title: 'Home' },
  },
  {
    path: '/analytics',
    name: 'analytics',
    component: () => import('@/features/analytics/AnalyticsPage.vue'),
    meta: { permission: PermissionNames.ReportFinancial, feature: 'analytics', title: 'Analytics' },
  },
  {
    path: '/admin/wholesale/returns',
    name: 'wholesale-returns',
    component: () => import('@/features/wholesale/WholesaleReturnPage.vue'),
    meta: { permission: PermissionNames.WholesaleInvoicePost, title: 'Wholesale returns' },
  },
  {
    path: '/admin/wholesale/invoices',
    name: 'wholesale-invoices',
    component: () => import('@/features/wholesale/WholesaleInvoicePage.vue'),
    meta: { permission: PermissionNames.WholesaleInvoicePost, title: 'Wholesale invoices' },
  },
  {
    path: '/admin/wholesale',
    name: 'wholesale',
    component: () => import('@/features/wholesale/WholesalePage.vue'),
    meta: { permission: PermissionNames.WholesaleInvoicePost, title: 'Wholesale' },
  },
  {
    path: '/admin/reports',
    name: 'reports',
    component: () => import('@/features/reports/ReportsPage.vue'),
    meta: { permission: PermissionNames.ReportFinancial, title: 'Reports' },
  },
  {
    path: '/admin/claims',
    name: 'claims',
    component: () => import('@/features/claims/ClaimsPage.vue'),
    meta: { permission: PermissionNames.ReportFinancial, title: 'Claims' },
  },
  {
    path: '/admin/optical',
    name: 'optical-orders',
    component: () => import('@/features/optical/OpticalOrderPage.vue'),
    meta: { permission: PermissionNames.SalesOrderCreate, title: 'Optical orders' },
  },
  {
    path: '/admin/prescriptions',
    name: 'prescriptions',
    component: () => import('@/features/prescriptions/PrescriptionPage.vue'),
    meta: { permission: PermissionNames.PrescriptionView, title: 'Prescriptions' },
  },
  {
    path: '/admin/customers',
    name: 'customer-directory',
    component: () => import('@/features/customers/CustomerDirectoryPage.vue'),
    meta: { permission: PermissionNames.SalesOrderCreate, title: 'Customers' },
  },
  {
    path: '/admin/pos',
    name: 'pos-order-entry',
    component: () => import('@/features/pos/OrderEntryPage.vue'),
    meta: { permission: PermissionNames.SalesOrderCreate, title: 'POS' },
  },
  {
    path: '/admin/pos/sale',
    name: 'pos-sale',
    component: () => import('@/features/pos/RetailSalePage.vue'),
    meta: { permission: PermissionNames.SalesInvoicePost, title: 'POS sale' },
  },
  {
    path: '/admin/pos/refund',
    name: 'pos-refund',
    component: () => import('@/features/pos/RetailRefundPage.vue'),
    meta: { permission: PermissionNames.SalesInvoicePost, title: 'POS refund' },
  },
  {
    path: '/admin/pos/cash',
    name: 'pos-cash',
    component: () => import('@/features/pos/CashManagementPage.vue'),
    meta: { permission: PermissionNames.SalesInvoicePost, title: 'Cash drawer' },
  },
  {
    path: '/admin/staff',
    name: 'staff-admin',
    component: () => import('@/features/admin/StaffAdminPage.vue'),
    meta: { permission: PermissionNames.MasterDataMaintain, title: 'Staff' },
  },
  {
    path: '/admin/reference',
    redirect: referencePath(REFERENCE_PAGES[0]!),
  },
  ...REFERENCE_PAGES.map((page) => ({
    path: referencePath(page),
    name: `reference-${page.id}`,
    component: referenceAdminPage,
    meta: {
      permission: PermissionNames.MasterDataMaintain,
      title: page.title,
    },
  })),
  {
    path: '/admin/catalogue',
    name: 'catalogue-admin',
    component: () => import('@/features/admin/CatalogueAdminPage.vue'),
    meta: { permission: PermissionNames.InventoryAdjust, title: 'Catalogue' },
  },
  {
    path: '/admin/import',
    name: 'import-admin',
    component: () => import('@/features/admin/ImportPage.vue'),
    meta: { permission: PermissionNames.MasterDataMaintain, title: 'Import' },
  },
  {
    path: '/admin/inventory',
    name: 'inventory-admin',
    component: () => import('@/features/admin/InventoryAdminPage.vue'),
    meta: { permission: PermissionNames.InventoryAdjust, title: 'Inventory' },
  },
  {
    path: '/admin/purchasing',
    name: 'purchasing-admin',
    component: () => import('@/features/admin/PurchasingPage.vue'),
    meta: { permission: PermissionNames.InventoryReceive, title: 'Purchasing' },
  },
  {
    path: '/admin/stock-ops',
    name: 'stock-ops',
    component: () => import('@/features/admin/StockOpsPage.vue'),
    meta: { permission: PermissionNames.InventoryAdjust, title: 'Stock ops' },
  },
  {
    path: '/admin/stock-take',
    name: 'stock-take',
    component: () => import('@/features/admin/StockTakePage.vue'),
    meta: { permission: PermissionNames.InventoryAdjust, title: 'Stock take' },
  },
  {
    path: '/admin/supplier-activity',
    name: 'supplier-activity',
    component: () => import('@/features/admin/SupplierActivityPage.vue'),
    meta: { permission: PermissionNames.InventoryReceive, title: 'Supplier activity' },
  },
  {
    path: '/forbidden',
    name: 'forbidden',
    component: () => import('@/pages/ForbiddenPage.vue'),
    meta: { title: 'Not permitted' },
  },
  {
    path: '/:pathMatch(.*)*',
    name: 'not-found',
    component: () => import('@/pages/NotFoundPage.vue'),
    meta: { title: 'Not found' },
  },
]

/** Accepts only same-origin application paths, to prevent open redirects. */
export function safeRedirect(value: unknown): string | null {
  if (typeof value !== 'string' || !value.startsWith('/') || value.startsWith('//') || value.startsWith('/\\')) {
    return null
  }
  return value
}

export function createAppRouter(history: RouterHistory = createWebHistory(import.meta.env.BASE_URL)): Router {
  const router = createRouter({ history, routes })

  router.beforeEach(async (to) => {
    const session = useSessionStore()

    if (session.status === 'unknown') {
      await session.restore()
    }

    if (to.meta.public) {
      if (session.isShellVisible && to.name === 'sign-in') {
        return { path: '/' }
      }
      return true
    }

    if (session.status === 'anonymous') {
      return { name: 'sign-in', query: { redirect: to.fullPath } }
    }

    // 'expired' keeps the current route mounted; the session dialog handles re-authentication.
    if (to.meta.feature && !isFeatureEnabled(to.meta.feature, getRuntimeConfig())) {
      return { path: '/' }
    }

    if (to.meta.permission && !session.hasPermission(to.meta.permission)) {
      return { path: '/forbidden' }
    }

    return true
  })

  router.onError(recordNavigationError)

  return router
}

/** Remembers a lazy route whose module failed to load so the shell can offer a retry. */
export function recordNavigationError(error: unknown, to: { fullPath: string }): void {
  if (isChunkLoadError(error)) {
    useShellStore().setChunkError(to.fullPath)
  }
}

/** Matches the messages browsers raise when a dynamically imported module cannot be fetched. */
export function isChunkLoadError(error: unknown): boolean {
  const message = error instanceof Error ? error.message : String(error)
  return /Failed to fetch dynamically imported module|Importing a module script failed|error loading dynamically imported module|ChunkLoadError/i.test(
    message,
  )
}
