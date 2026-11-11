import { beforeEach, describe, expect, it, vi } from 'vitest'

// First navigation to a lazy page transforms Vuetify under jsdom; allow for it.
vi.setConfig({ testTimeout: 60000 })
import { createMemoryHistory } from 'vue-router'
import { createPinia, setActivePinia } from 'pinia'
import { createAppRouter, isChunkLoadError, recordNavigationError, safeRedirect } from '@/router'
import { setRuntimeConfigForTests } from '@/runtime/config'
import { useSessionStore } from '@/stores/session'
import { useShellStore } from '@/stores/shell'

function setup(options: { status: 'anonymous' | 'authenticated' | 'expired'; permissions?: string[]; analytics?: boolean }) {
  setActivePinia(createPinia())
  const session = useSessionStore()
  session.status = options.status
  session.identity = options.status === 'authenticated'
    ? { username: 'u', displayName: null, permissions: options.permissions ?? [] }
    : null
  setRuntimeConfigForTests({
    analyticsEnabled: options.analytics ?? false,
    wptLicenseKey: options.analytics ? 'k' : null,
  })
  // Route components are lazy; the guard is what these tests exercise.
  const router = createAppRouter(createMemoryHistory())
  vi.spyOn(session, 'restore').mockResolvedValue()
  return { router, session }
}

describe('route guards', () => {
  beforeEach(() => {
    setRuntimeConfigForTests({ analyticsEnabled: false, wptLicenseKey: null })
  })

  it('redirects anonymous users to sign-in and remembers the destination', async () => {
    const { router } = setup({ status: 'anonymous' })
    await router.push('/analytics')
    expect(router.currentRoute.value.name).toBe('sign-in')
    expect(router.currentRoute.value.query.redirect).toBe('/analytics')
  })

  it('keeps the current route open while the session is expired', async () => {
    const { router } = setup({ status: 'expired' })
    await router.push('/')
    expect(router.currentRoute.value.path).toBe('/')
  })

  it('sends users without the permission to the forbidden page', async () => {
    const { router } = setup({ status: 'authenticated', permissions: [], analytics: true })
    await router.push('/analytics')
    expect(router.currentRoute.value.path).toBe('/forbidden')
  })

  it('hides a feature-gated route when the feature is disabled', async () => {
    const { router } = setup({ status: 'authenticated', permissions: ['report:financial'], analytics: false })
    await router.push('/analytics')
    expect(router.currentRoute.value.path).toBe('/')
  })

  it('allows the route when the permission and feature are both present', async () => {
    const { router } = setup({ status: 'authenticated', permissions: ['report:financial'], analytics: true })
    await router.push('/analytics')
    expect(router.currentRoute.value.path).toBe('/analytics')
  })

  it('shows unknown paths as not found', async () => {
    const { router } = setup({ status: 'authenticated' })
    await router.push('/no/such/page')
    expect(router.currentRoute.value.name).toBe('not-found')
  })

  it('redirects signed-in users away from sign-in', async () => {
    const { router } = setup({ status: 'authenticated' })
    await router.push('/sign-in')
    expect(router.currentRoute.value.path).toBe('/')
  })
})

describe('chunk load failures', () => {
  it('recognises browser chunk-load messages', () => {
    expect(isChunkLoadError(new TypeError('Failed to fetch dynamically imported module: /x.js'))).toBe(true)
    expect(isChunkLoadError(new Error('Importing a module script failed.'))).toBe(true)
    expect(isChunkLoadError(new Error('Something else'))).toBe(false)
  })

  it('records the failed path in the shell store so the shell can offer a retry', () => {
    setActivePinia(createPinia())
    recordNavigationError(new TypeError('Failed to fetch dynamically imported module'), { fullPath: '/analytics' })
    expect(useShellStore().chunkErrorPath).toBe('/analytics')
  })

  it('ignores ordinary navigation errors', () => {
    setActivePinia(createPinia())
    recordNavigationError(new Error('boom'), { fullPath: '/analytics' })
    expect(useShellStore().chunkErrorPath).toBeNull()
  })
})

describe('safeRedirect', () => {
  it.each([
    ['/analytics', '/analytics'],
    ['//evil.example', null],
    ['/\\evil.example', null],
    ['https://evil.example', null],
    [undefined, null],
    [['/x'], null],
  ])('%j -> %j', (input, expected) => {
    expect(safeRedirect(input)).toBe(expected)
  })
})
