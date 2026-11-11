import { afterEach, describe, expect, it, vi } from 'vitest'
import { nextTick } from 'vue'
import { flushPromises } from '@vue/test-utils'
import AppShell from '@/layout/AppShell.vue'
import { useSessionStore } from '@/stores/session'
import { useShellStore } from '@/stores/shell'
import { setRuntimeConfigForTests } from '@/runtime/config'
import { isNavItemVisible, NAV_ITEMS } from '@/router/nav'
import { mountInApp } from './support'
import { createPinia, setActivePinia } from 'pinia'

afterEach(() => {
  setRuntimeConfigForTests({ analyticsEnabled: false, wptLicenseKey: null })
})

function signedInSession(permissions: string[]) {
  const pinia = createPinia()
  setActivePinia(pinia)
  const session = useSessionStore(pinia)
  session.status = 'authenticated'
  session.identity = { username: 'clerk', displayName: 'Clerk One', permissions }
  return { pinia, session }
}

describe('navigation visibility', () => {
  const withPermission = { hasPermission: (p: string) => p === 'report:financial' }
  const without = { hasPermission: () => false }

  it('shows analytics only with the permission and the feature enabled', () => {
    const analytics = NAV_ITEMS.find((i) => i.to === '/analytics')!
    expect(isNavItemVisible(analytics, withPermission, { analyticsEnabled: true, wptLicenseKey: 'k' })).toBe(true)
    expect(isNavItemVisible(analytics, withPermission, { analyticsEnabled: false, wptLicenseKey: null })).toBe(false)
    expect(isNavItemVisible(analytics, without, { analyticsEnabled: true, wptLicenseKey: 'k' })).toBe(false)
  })

  it('always shows the home entry', () => {
    const home = NAV_ITEMS.find((i) => i.to === '/')!
    expect(isNavItemVisible(home, without, { analyticsEnabled: false, wptLicenseKey: null })).toBe(true)
  })
})

describe('AppShell', () => {
  it('lists only the navigation entries the user may open', async () => {
    const { pinia } = signedInSession([])
    setRuntimeConfigForTests({ analyticsEnabled: true, wptLicenseKey: 'k' })
    const { wrapper } = await mountInApp(AppShell, { path: '/', pinia })
    await flushPromises()

    const text = wrapper.find('[data-testid="nav-menu"]').text()
    expect(text).toContain('Home')
    expect(text).not.toContain('Analytics')
    wrapper.unmount()
  })

  it('shows analytics to a user with the permission when the feature is enabled', async () => {
    const { pinia } = signedInSession(['report:financial'])
    setRuntimeConfigForTests({ analyticsEnabled: true, wptLicenseKey: 'k' })
    const { wrapper } = await mountInApp(AppShell, { path: '/', pinia })
    await flushPromises()

    expect(wrapper.find('[data-testid="nav-menu"]').text()).toContain('Analytics')
    wrapper.unmount()
  })

  it('offers a retry for a failed lazy route and navigates to it', async () => {
    const { pinia } = signedInSession([])
    const { wrapper, router } = await mountInApp(AppShell, { path: '/', pinia })
    const shell = useShellStore(pinia)
    shell.setChunkError('/')
    await nextTick()

    expect(wrapper.find('[data-testid="chunk-error"]').exists()).toBe(true)
    const push = vi.spyOn(router, 'push')
    await wrapper.find('[data-testid="chunk-retry"]').trigger('click')
    await flushPromises()

    expect(push).toHaveBeenCalledWith('/')
    expect(shell.chunkErrorPath).toBeNull()
    wrapper.unmount()
  })

  it('signs out through the session store and returns to sign-in', async () => {
    const { pinia, session } = signedInSession([])
    const signOut = vi.spyOn(session, 'signOut').mockImplementation(async () => {
      session.status = 'anonymous'
      session.identity = null
    })
    const { wrapper, router } = await mountInApp(AppShell, { path: '/', pinia })

    await wrapper.find('[data-testid="sign-out"]').trigger('click')
    await flushPromises()

    expect(signOut).toHaveBeenCalledTimes(1)
    // The sign-in page is a lazy chunk; wait for the navigation rather than the microtask queue.
    await vi.waitFor(() => expect(router.currentRoute.value.name).toBe('sign-in'))
    wrapper.unmount()
  })
})
