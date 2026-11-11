import { afterEach, describe, expect, it, vi } from 'vitest'
import { flushPromises } from '@vue/test-utils'
import ForbiddenPage from '@/pages/ForbiddenPage.vue'
import NotFoundPage from '@/pages/NotFoundPage.vue'
import { createPinia, setActivePinia } from 'pinia'
import { useSessionStore } from '@/stores/session'
import { mountInApp } from './support'

afterEach(() => {
  vi.unstubAllGlobals()
})

describe('static pages', () => {
  it('forbidden page renders without issuing any data request', async () => {
    const fetchSpy = vi.fn()
    vi.stubGlobal('fetch', fetchSpy)

    const pinia = createPinia()
    setActivePinia(pinia)
    const session = useSessionStore(pinia)
    session.status = 'authenticated'
    session.identity = { username: 'clerk', displayName: null, permissions: [] }

    const { wrapper } = await mountInApp(ForbiddenPage, { path: '/forbidden', pinia })
    await flushPromises()

    expect(wrapper.find('[data-testid="forbidden-page"]').exists()).toBe(true)
    expect(fetchSpy).not.toHaveBeenCalled()
    wrapper.unmount()
  })

  it('not-found page renders with a way back home', async () => {
    const pinia = createPinia()
    setActivePinia(pinia)
    const session = useSessionStore(pinia)
    session.status = 'authenticated'
    session.identity = { username: 'clerk', displayName: null, permissions: [] }

    const { wrapper } = await mountInApp(NotFoundPage, { path: '/missing', pinia })
    await flushPromises()

    expect(wrapper.find('[data-testid="not-found-page"]').text()).toContain('Page not found')
    expect(wrapper.html()).toContain('href="/"')
    wrapper.unmount()
  })
})
