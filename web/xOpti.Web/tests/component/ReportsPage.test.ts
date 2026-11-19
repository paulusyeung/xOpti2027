import { afterEach, describe, expect, it, vi } from 'vitest'
import { flushPromises } from '@vue/test-utils'
import { createPinia, setActivePinia } from 'pinia'
import ReportsPage from '@/features/reports/ReportsPage.vue'
import { PermissionNames } from '@/security/permissions'
import { useSessionStore } from '@/stores/session'
import { mountInApp } from './support'

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), { status, headers: { 'content-type': 'application/json' } })
}

const customerReport = {
  id: 'RPT-014', logicalName: 'Customer Listing (Active)',
  title: 'The Optical Centre, Richmond - Customer Listing (Active)',
  subject: 'Customer Listing (Active)',
  parameters: [
    { name: 'AskDays', type: 'number', required: false },
    { name: 'AskZeroPurchase', type: 'boolean', required: false },
  ],
  readModel: 'customer', layoutKey: 'table',
  requiredPermissions: ['report:financial'], rowCap: 10000, criticality: 'low',
  criticalDocument: false, inScope: 'provisional', signoffStatus: 'pending',
}
const costReport = {
  ...customerReport, id: 'RPT-013', logicalName: 'Cost and Margin of Goods Sold',
  requiredPermissions: ['report:financial', 'cost:view'], readModel: 'cost',
}

afterEach(() => vi.unstubAllGlobals())

describe('ReportsPage', () => {
  it('previews, prints, exports, and favorites a catalogue report', async () => {
    const calls: string[] = []
    vi.stubGlobal('fetch', vi.fn(async (input: RequestInfo | URL, init?: RequestInit) => {
      const request = input instanceof Request ? input : null
      const url = request ? request.url : String(input)
      const method = request ? request.method : (init?.method ?? 'GET')
      calls.push(`${method} ${url}`)
      if (url.includes('/auth/csrf-token')) return json({ token: 'csrf' })
      if (url.endsWith('/api/v1/reports') && method === 'GET') {
        return json([customerReport, costReport])
      }
      if (url.includes('/preview')) {
        return json({
          reportId: 'RPT-014', title: customerReport.title,
          columns: [{ key: 'customer_id', label: 'Customer', type: 'number' },
            { key: 'full_name', label: 'Name', type: 'text' }],
          rows: [[7, 'Ada Lens']], truncated: false, appliedCap: 10000,
          asOf: '2026-11-18T10:00:00Z', stale: false, parameters: {},
        })
      }
      if (url.includes('/print')) {
        return new Response(new Blob(['%PDF-1.4']), {
          status: 200, headers: { 'content-type': 'application/pdf' },
        })
      }
      if (url.includes('/export')) {
        return new Response('Customer,Name\n7,Ada Lens', {
          status: 200, headers: { 'content-type': 'text/csv' },
        })
      }
      return json({}, 404)
    }))

    const pinia = createPinia()
    setActivePinia(pinia)
    const store = useSessionStore(pinia)
    store.status = 'authenticated'
    store.identity = {
      username: 'manager', displayName: 'manager',
      permissions: [PermissionNames.ReportFinancial, PermissionNames.CostView],
    }

    const { wrapper } = await mountInApp(ReportsPage, { path: '/admin/reports', pinia })
    await flushPromises()
    expect(wrapper.find('[data-testid="report-list"]').text()).toContain('Customer Listing')
    expect(wrapper.find('[data-testid="report-list"]').text()).toContain('Cost and Margin')

    await wrapper.find('[data-testid="report-select-RPT-014"]').trigger('click')
    await wrapper.find('[data-testid="report-param-AskDays"] input').setValue('0')
    await wrapper.find('[data-testid="report-preview"]').trigger('click')
    await flushPromises()
    expect(wrapper.find('[data-testid="report-preview-table"]').text()).toContain('Ada Lens')

    await wrapper.find('[data-testid="report-print"]').trigger('click')
    await flushPromises()
    expect(wrapper.find('[data-testid="report-notice"]').text()).toContain('generated')

    await wrapper.find('[data-testid="report-export"]').trigger('click')
    await flushPromises()
    expect(wrapper.find('[data-testid="report-notice"]').text()).toContain('Export generated')

    await wrapper.find('[data-testid="report-favorite"]').trigger('click')
    expect(wrapper.find('[data-testid="report-favorite"]').text()).toContain('★ Favorite')

    expect(calls.some((call) => call.includes('/reports/RPT-014/preview'))).toBe(true)
    expect(calls.some((call) => call.includes('/reports/RPT-014/print'))).toBe(true)
    wrapper.unmount()
  })
})
