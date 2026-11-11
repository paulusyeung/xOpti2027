import { afterEach, describe, expect, it } from 'vitest'
import { flushPromises } from '@vue/test-utils'
import AnalyticsPage from '@/features/analytics/AnalyticsPage.vue'
import { setRuntimeConfigForTests } from '@/runtime/config'
import { mockState } from '../mocks/webpivottable'
import { mountInApp } from './support'

afterEach(() => {
  setRuntimeConfigForTests({ analyticsEnabled: false, wptLicenseKey: null })
  document.body.innerHTML = ''
})

describe('analytics licence gating', () => {
  it('shows a configuration error and never creates the component without a licence key', async () => {
    setRuntimeConfigForTests({ analyticsEnabled: true, wptLicenseKey: null })
    const before = mockState.moduleLoads

    const { wrapper } = await mountInApp(AnalyticsPage, { path: '/analytics' })
    await flushPromises()

    expect(wrapper.find('[data-testid="analytics-config-error"]').exists()).toBe(true)
    expect(wrapper.find('[data-testid="wpt-view"]').exists()).toBe(false)
    expect(mockState.moduleLoads).toBe(before)
    expect(document.querySelector('web-pivot-table')).toBeNull()
    wrapper.unmount()
  })

  it('creates the component when a licence key is configured', async () => {
    setRuntimeConfigForTests({ analyticsEnabled: true, wptLicenseKey: 'KEY' })

    const { wrapper } = await mountInApp(AnalyticsPage, { path: '/analytics' })
    await flushPromises()

    expect(wrapper.find('[data-testid="analytics-config-error"]').exists()).toBe(false)
    expect(document.querySelector('web-pivot-table')).not.toBeNull()
    wrapper.unmount()
  })
})

describe('analytics component lifecycle', () => {
  it('releases the component on unmount and creates exactly one on remount', async () => {
    setRuntimeConfigForTests({ analyticsEnabled: true, wptLicenseKey: 'KEY' })

    const first = await mountInApp(AnalyticsPage, { path: '/analytics' })
    await flushPromises()
    expect(document.querySelectorAll('web-pivot-table')).toHaveLength(1)

    first.wrapper.unmount()
    await flushPromises()
    expect(document.querySelectorAll('web-pivot-table')).toHaveLength(0)

    const second = await mountInApp(AnalyticsPage, { path: '/analytics' })
    await flushPromises()
    expect(document.querySelectorAll('web-pivot-table')).toHaveLength(1)
    second.wrapper.unmount()
  })
})

describe('analytics data source', () => {
  it('loads rows from the configured same-origin URL when no fixture is supplied', async () => {
    const requested: string[] = []
    vi.stubGlobal(
      'fetch',
      vi.fn(async (input: RequestInfo | URL) => {
        requested.push(new URL(input instanceof Request ? input.url : String(input), 'http://localhost').pathname)
        return new Response(JSON.stringify({ data: [{ Branch: 'Richmond', Sales: 1 }] }), {
          status: 200,
          headers: { 'content-type': 'application/json' },
        })
      }),
    )
    const { mount } = await import('@vue/test-utils')
    const { default: WptPivotView } = await import('@/features/analytics/WptPivotView.vue')
    const { vuetify } = await import('@/plugins/vuetify')
    const { mockState } = await import('../mocks/webpivottable')

    const wrapper = mount(WptPivotView, {
      props: { licenseKey: 'KEY', fixtureRows: null, dataUrl: '/api/v1/analytics/custom-source' },
      global: { plugins: [vuetify] },
      attachTo: document.body,
    })
    await vi.waitFor(() => expect(mockState.rows).toEqual([{ Branch: 'Richmond', Sales: 1 }]))

    expect(requested).toEqual(['/api/v1/analytics/custom-source'])
    wrapper.unmount()
  })

  it('shows the mapped problem, with a support reference for unhandled failures', async () => {
    vi.stubGlobal(
      'fetch',
      vi.fn(async () =>
        new Response(JSON.stringify({ type: 'https://errors.xopti/unhandled', status: 500, correlationId: 'corr-42' }), {
          status: 500,
          headers: { 'content-type': 'application/problem+json' },
        }),
      ),
    )
    const { mount, flushPromises } = await import('@vue/test-utils')
    const { default: WptPivotView } = await import('@/features/analytics/WptPivotView.vue')
    const { vuetify } = await import('@/plugins/vuetify')

    const wrapper = mount(WptPivotView, {
      props: { licenseKey: 'KEY', fixtureRows: null, dataUrl: '/api/v1/analytics/missing' },
      global: { plugins: [vuetify] },
      attachTo: document.body,
    })
    await flushPromises()

    const error = wrapper.find('[data-testid="wpt-error"]').text()
    expect(error).toContain('Something went wrong')
    expect(error).toContain('Reference: corr-42')
    expect(document.querySelector('web-pivot-table')).toBeNull()
    wrapper.unmount()
  })
})
