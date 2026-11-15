import { afterEach, describe, expect, it, vi } from 'vitest'
import { flushPromises } from '@vue/test-utils'
import StockTakePage from '@/features/admin/StockTakePage.vue'
import { mountInApp } from './support'

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), { status, headers: { 'content-type': 'application/json' } })
}
const variance = { headerId: 1, name: 'Count', status: 1, rows: [
  { sku: '30110359', computerQty: 10, countedQty: 8, difference: -2, averageCost: 4.365 },
] }

function stub(handler: (url: string, method: string) => Response | undefined) {
  vi.stubGlobal('fetch', vi.fn(async (input: RequestInfo | URL, init?: RequestInit) => {
    const request = input instanceof Request ? input : null
    const url = request ? request.url : String(input)
    const method = request ? request.method : (init?.method ?? 'GET')
    if (url.includes('/auth/csrf-token')) return json({ token: 'csrf' })
    return handler(url, method) ?? json({}, 404)
  }))
}
afterEach(() => vi.unstubAllGlobals())

describe('StockTakePage', () => {
  it('creates a frozen stock take and loads variances', async () => {
    stub((url, method) => {
      if (method === 'POST' && url.endsWith('/stock-takes')) return json({ id: 1, name: 'Count', status: 1, rowCount: 1, frozenAt: '' }, 201)
      if (url.includes('/variances')) return json(variance)
      return undefined
    })
    const { wrapper } = await mountInApp(StockTakePage, { path: '/' })
    await wrapper.find('[data-testid="stock-take-name"] input').setValue('Count')
    await wrapper.find('[data-testid="stock-take-reason"] input').setValue('monthly')
    await wrapper.find('[data-testid="stock-take-create"]').trigger('click')
    await flushPromises()
    expect(wrapper.find('[data-testid="stock-take-header"]').text()).toContain('#1')
    expect(wrapper.find('[data-testid="stock-take-variances"]').text()).toContain('-2')
  })

  it('shows import counts and row errors', async () => {
    stub((url, method) => {
      if (method === 'POST' && url.endsWith('/stock-takes')) return json({ id: 1, name: 'Count', status: 1, rowCount: 1 }, 201)
      if (url.includes('/counts')) return json({ headerId: 1, dryRun: false, accepted: 0, resumeFrom: 2,
        errors: [{ row: 2, field: 'sku', message: 'SKU is not in the frozen snapshot.' }] })
      if (url.includes('/variances')) return json(variance)
      return undefined
    })
    const { wrapper } = await mountInApp(StockTakePage, { path: '/' })
    await wrapper.find('[data-testid="stock-take-name"] input').setValue('Count')
    await wrapper.find('[data-testid="stock-take-reason"] input').setValue('monthly')
    await wrapper.find('[data-testid="stock-take-create"]').trigger('click')
    await flushPromises()
    await wrapper.find('[data-testid="stock-take-import-reason"] input').setValue('counts')
    await wrapper.find('[data-testid="stock-take-import"]').trigger('click')
    await flushPromises()
    expect(wrapper.find('[data-testid="stock-take-import-result"]').text()).toContain('resume from row 2')
    expect(wrapper.find('[data-testid="stock-take-import-result"]').text()).toContain('not in the frozen snapshot')
  })

  it('approves and posts variances', async () => {
    stub((url, method) => {
      if (method === 'POST' && url.endsWith('/stock-takes')) return json({ id: 1, name: 'Count', status: 1 }, 201)
      if (url.includes('/approve')) return json({ ...variance, status: 2 })
      if (url.includes('/post')) return json({ headerId: 1, txNumber: 'SJ00000001', adjustedRows: 1, totalDifference: -2, totalValue: -8.73 })
      if (url.includes('/variances')) return json(variance)
      return undefined
    })
    const { wrapper } = await mountInApp(StockTakePage, { path: '/' })
    await wrapper.find('[data-testid="stock-take-name"] input').setValue('Count')
    await wrapper.find('[data-testid="stock-take-reason"] input').setValue('monthly')
    await wrapper.find('[data-testid="stock-take-create"]').trigger('click')
    await flushPromises()
    await wrapper.find('[data-testid="stock-take-approval-reason"] input').setValue('approve')
    await wrapper.find('[data-testid="stock-take-approve"]').trigger('click')
    await flushPromises()
    await wrapper.find('[data-testid="stock-take-posting-reason"] input').setValue('post')
    await wrapper.find('[data-testid="stock-take-post"]').trigger('click')
    await flushPromises()
    expect(wrapper.find('[data-testid="stock-take-posted"]').text()).toContain('SJ00000001')
  })
})
