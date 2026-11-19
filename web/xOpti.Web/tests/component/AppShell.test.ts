import { afterEach, describe, expect, it, vi } from 'vitest'
import { nextTick } from 'vue'
import { flushPromises } from '@vue/test-utils'
import AppShell from '@/layout/AppShell.vue'
import { useSessionStore } from '@/stores/session'
import { useShellStore } from '@/stores/shell'
import { useThemeStore } from '@/stores/theme'
import { setRuntimeConfigForTests } from '@/runtime/config'
import { isNavItemVisible, NAV_ITEMS } from '@/router/nav'
import { mountInApp } from './support'
import { createPinia, setActivePinia } from 'pinia'

afterEach(() => {
  setRuntimeConfigForTests({ analyticsEnabled: false, wptLicenseKey: null })
  localStorage.clear()
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

  it('groups navigation like the legacy top-level menus', async () => {
    const { pinia } = signedInSession([
      'sales:order-create', 'sales:invoice-post', 'inventory:adjust',
      'inventory:receive', 'wholesale:invoice-post', 'master-data:maintain',
      'report:financial', 'prescription:view',
    ])
    setRuntimeConfigForTests({ analyticsEnabled: true, wptLicenseKey: 'k' })
    const { wrapper } = await mountInApp(AppShell, { path: '/', pinia })
    await flushPromises()

    const text = wrapper.find('[data-testid="nav-menu"]').text()
    for (const group of [
      'Point-of-Service', 'Inventory Control', 'Coding',
      'Information Centre', 'Reports & Analytics', 'Administration',
    ]) {
      expect(text).toContain(group)
    }
    expect(wrapper.find('[data-testid="nav-group-point-of-service"]').exists()).toBe(true)
    expect(wrapper.find('[data-testid="nav-group-inventory-control"]').exists()).toBe(true)
    wrapper.unmount()
  })

  it('collapses the sidebar into a rail from the topbar', async () => {
    const { pinia } = signedInSession([])
    const { wrapper } = await mountInApp(AppShell, { path: '/', pinia })
    await flushPromises()

    expect(wrapper.find('.v-navigation-drawer').classes())
      .not.toContain('v-navigation-drawer--rail')

    await wrapper.get('button[aria-label="Collapse navigation"]').trigger('click')
    await nextTick()

    expect(wrapper.find('.v-navigation-drawer').classes())
      .toContain('v-navigation-drawer--rail')
    expect(wrapper.find('button[aria-label="Expand navigation"]').exists()).toBe(true)
    wrapper.unmount()
  })

  it('opens only Point-of-Service by default', async () => {
    const { pinia } = signedInSession([
      'sales:order-create', 'sales:invoice-post', 'inventory:adjust',
      'inventory:receive', 'wholesale:invoice-post', 'master-data:maintain',
      'report:financial',
    ])
    const { wrapper } = await mountInApp(AppShell, { path: '/', pinia })
    await flushPromises()

    const expanded = (slug: string) =>
      wrapper.get(`[data-testid="nav-group-${slug}"]`).attributes('aria-expanded')

    expect(expanded('point-of-service')).toBe('true')
    expect(expanded('inventory-control')).toBe('false')
    expect(expanded('coding')).toBe('false')
    expect(expanded('reports-analytics')).toBe('false')
    wrapper.unmount()
  })

  it('closes the open group when another group is opened', async () => {
    const { pinia } = signedInSession([
      'sales:order-create', 'sales:invoice-post', 'inventory:adjust',
      'report:financial',
    ])
    const { wrapper } = await mountInApp(AppShell, { path: '/', pinia })
    await flushPromises()

    const expanded = (slug: string) =>
      wrapper.get(`[data-testid="nav-group-${slug}"]`).attributes('aria-expanded')

    expect(expanded('point-of-service')).toBe('true')

    await wrapper.get('[data-testid="nav-group-inventory-control"]').trigger('click')
    await nextTick()

    expect(expanded('point-of-service')).toBe('false')
    expect(expanded('inventory-control')).toBe('true')

    await wrapper.get('[data-testid="nav-group-reports-analytics"]').trigger('click')
    await nextTick()

    expect(expanded('inventory-control')).toBe('false')
    expect(expanded('reports-analytics')).toBe('true')
    wrapper.unmount()
  })

  it('collapses and reopens a legacy menu group', async () => {
    const { pinia } = signedInSession(['sales:order-create'])
    const { wrapper } = await mountInApp(AppShell, { path: '/', pinia })
    await flushPromises()

    const activator = wrapper.get('[data-testid="nav-group-point-of-service"]')
    expect(activator.attributes('aria-expanded')).toBe('true')

    await activator.trigger('click')
    await nextTick()
    expect(activator.attributes('aria-expanded')).toBe('false')

    await activator.trigger('click')
    await nextTick()
    expect(activator.attributes('aria-expanded')).toBe('true')
    wrapper.unmount()
  })

  it('exposes light and dark theme switching from the topbar', async () => {
    const { pinia } = signedInSession([])
    useThemeStore(pinia).setMode('light')
    const { wrapper } = await mountInApp(AppShell, { path: '/', pinia })
    await flushPromises()

    const toggle = () => wrapper.get('[data-testid="theme-toggle"]')
    const icon = () => toggle().find('.v-icon')
    expect(toggle().attributes('aria-label')).toBe('Theme settings')
    expect(icon().classes()).toContain('mdi-white-balance-sunny')

    const theme = useThemeStore(pinia)
    theme.setMode('dark')
    await nextTick()

    expect(icon().classes()).toContain('mdi-weather-night')
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
