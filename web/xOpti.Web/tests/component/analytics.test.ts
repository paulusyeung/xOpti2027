import { afterEach, describe, expect, it } from 'vitest'
import { flushPromises } from '@vue/test-utils'
import AnalyticsPage from '@/features/analytics/AnalyticsPage.vue'
import { setRuntimeConfigForTests } from '@/runtime/config'
import { mockState } from '../mocks/webpivottable'
import { mountInApp } from './support'

afterEach(() => {
  vi.unstubAllGlobals()
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


describe('analytics view selection, freshness, saved views and export', () => {
  it('loads a stale feed, saves and opens a view, and exports CSV', async () => {
    setRuntimeConfigForTests({ analyticsEnabled: true, wptLicenseKey: 'KEY' })
    const calls: string[] = []
    vi.stubGlobal('fetch', vi.fn(async (input: RequestInfo | URL, init?: RequestInit) => {
      const request = input instanceof Request ? input : null
      const url = request ? request.url : String(input)
      const method = request ? request.method : (init?.method ?? 'GET')
      calls.push(`${method} ${url}`)
      const json = (body: unknown) => new Response(JSON.stringify(body), {
        status: 200, headers: { 'content-type': 'application/json' },
      })
      if (url.includes('/auth/csrf-token')) return json({ token: 'csrf' })
      if (url.includes('/analytics/views/sales_by_cost/export')) {
        return new Response('Sales,Margin\n100,20', {
          status: 200, headers: { 'content-type': 'text/csv' },
        })
      }
      if (url.includes('/analytics/views/sales_by_cost')) {
        return json({
          viewKey: 'sales_by_cost', name: 'Sales by Cost',
          fields: [{ key: 'period', label: 'Period', type: 'text', sensitive: false },
            { key: 'sales', label: 'Sales', type: 'money', sensitive: false }],
          data: [['2026-11', 100]], asOf: '2026-11-18T10:00:00Z',
          stale: true, truncated: true, rowCap: 5000,
        })
      }
      if (url.includes('/analytics/views')) {
        return json([{ key: 'sales_by_cost', name: 'Sales by Cost', fields: [] }])
      }
      if (url.includes('/analytics/saved') && method === 'POST') {
        return json({ id: 1, viewKey: 'sales_by_cost', name: 'Cost review',
          isShared: true, ownerUserId: 'manager',
          configJson: '{"viewKey":"sales_by_cost","filters":{}}',
          createdAt: '2026-11-18T10:00:00Z', updatedAt: '2026-11-18T10:00:00Z',
          canEdit: true })
      }
      if (url.includes('/analytics/saved/1')) {
        return json({ id: 1, viewKey: 'sales_by_cost', name: 'Cost review',
          isShared: true, ownerUserId: 'manager',
          configJson: '{"viewKey":"sales_by_cost","filters":{"branch":"01"}}',
          createdAt: '2026-11-18T10:00:00Z', updatedAt: '2026-11-18T10:00:00Z',
          canEdit: true })
      }
      if (url.includes('/analytics/saved')) return json([])
      return json({})
    }))

    const { wrapper } = await mountInApp(AnalyticsPage, { path: '/analytics' })
    await flushPromises()
    await flushPromises()
    expect(wrapper.find('[data-testid="analytics-stale"]').exists()).toBe(true)
    expect(wrapper.find('[data-testid="analytics-truncated"]').exists()).toBe(true)
    expect(wrapper.find('[data-testid="wpt-view"]').exists()).toBe(true)

    await wrapper.find('[data-testid="analytics-save-name"] input').setValue('Cost review')
    await wrapper.find('[data-testid="analytics-save"]').trigger('click')
    await flushPromises()
    expect(wrapper.find('[data-testid="analytics-notice"]').text()).toContain('Saved analytics view')

    await wrapper.find('[data-testid="analytics-export"]').trigger('click')
    await flushPromises()
    expect(wrapper.find('[data-testid="analytics-notice"]').text()).toContain('export generated')
    expect(calls.some((call) => call.includes('/analytics/views/sales_by_cost/export'))).toBe(true)
    wrapper.unmount()
  })
})
