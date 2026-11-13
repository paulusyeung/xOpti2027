import { createRouter, createWebHistory, type RouteRecordRaw, type Router, type RouterHistory } from 'vue-router'
import { getRuntimeConfig } from '@/runtime/config'
import { useSessionStore } from '@/stores/session'
import { useShellStore } from '@/stores/shell'
import { isFeatureEnabled } from './nav'
import { PermissionNames } from '@/security/permissions'

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
    path: '/admin/staff',
    name: 'staff-admin',
    component: () => import('@/features/admin/StaffAdminPage.vue'),
    meta: { permission: PermissionNames.MasterDataMaintain, title: 'Staff' },
  },
  {
    path: '/admin/reference',
    name: 'reference-admin',
    component: () => import('@/features/admin/ReferenceAdminPage.vue'),
    meta: { permission: PermissionNames.MasterDataMaintain, title: 'References' },
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
