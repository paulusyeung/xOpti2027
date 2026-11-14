import { afterEach, describe, expect, it, vi } from 'vitest'
import { flushPromises } from '@vue/test-utils'
import StockOpsPage from '@/features/admin/StockOpsPage.vue'
import { mountInApp } from './support'

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), { status, headers: { 'content-type': 'application/json' } })
}
const adjustResult = { txNumber: 'SJ00000001', controlNumber: '00000001', quantityDelta: -2, newOnHand: 8 }
const transferResult = { transferId: 'TRABCDEFGH', sourceTxNumber: 'SJ00000002', destinationTxNumber: 'SJ00000003', sku: '30110359', quantity: 3 }

function stub(response: () => Response) {
  vi.stubGlobal('fetch', vi.fn(async (input: RequestInfo | URL, init?: RequestInit) => {
    const request = input instanceof Request ? input : null
    const url = request ? request.url : String(input)
    const method = request ? request.method : (init?.method ?? 'GET')
    if (url.includes('/auth/csrf-token')) return json({ token: 'csrf' })
    return method === 'POST' ? response() : json({}, 404)
  }))
}
afterEach(() => vi.unstubAllGlobals())

describe('StockOpsPage', () => {
  it('requires confirmation before posting an adjustment', async () => {
    stub(() => json(adjustResult, 201))
    const { wrapper } = await mountInApp(StockOpsPage, { path: '/' })
    await wrapper.find('[data-testid="stock-ops-sku"] input').setValue('30110359')
    await wrapper.find('[data-testid="stock-ops-delta"] input').setValue('-2')
    await wrapper.find('[data-testid="stock-ops-reason"] input').setValue('damaged stock')
    await wrapper.find('[data-testid="stock-ops-submit"]').trigger('click')
    expect(wrapper.find('[data-testid="stock-ops-confirmation"]').text()).toContain('-2')
    await wrapper.find('[data-testid="stock-ops-confirm"]').trigger('click')
    await flushPromises()
    expect(wrapper.find('[data-testid="stock-ops-result"]').text()).toContain('on hand now 8')
  })

  it('shows the deficit/shortfall validation', async () => {
    stub(() => json({ type: 'https://errors.xopti/validation', title: 'Validation failed', status: 400,
      errors: [{ field: 'QuantityDelta', code: 'below-zero', message: 'Adjustment would leave -10; shortfall is 20.' }] }, 400))
    const { wrapper } = await mountInApp(StockOpsPage, { path: '/' })
    await wrapper.find('[data-testid="stock-ops-sku"] input').setValue('30110359')
    await wrapper.find('[data-testid="stock-ops-confirm"]').exists()
    await wrapper.find('[data-testid="stock-ops-submit"]').trigger('click')
    await wrapper.find('[data-testid="stock-ops-confirm"]').trigger('click')
    await flushPromises()
    expect(wrapper.find('[data-testid="stock-ops-error"]').text()).toContain('shortfall is 20')
  })

  it('switches to transfer mode with from/to fields and confirms', async () => {
    stub(() => json(transferResult, 201))
    const { wrapper } = await mountInApp(StockOpsPage, { path: '/' })
    await wrapper.find('[data-testid="stock-ops-transfer"]').trigger('click')
    expect(wrapper.find('[data-testid="stock-ops-from"]').exists()).toBe(true)
    await wrapper.find('[data-testid="stock-ops-sku"] input').setValue('30110359')
    await wrapper.find('[data-testid="stock-ops-quantity"] input').setValue('3')
    await wrapper.find('[data-testid="stock-ops-reason"] input').setValue('transfer')
    await wrapper.find('[data-testid="stock-ops-submit"]').trigger('click')
    expect(wrapper.find('[data-testid="stock-ops-confirmation"]').text()).toContain('from 01 to 02')
    await wrapper.find('[data-testid="stock-ops-confirm"]').trigger('click')
    await flushPromises()
    expect(wrapper.find('[data-testid="stock-ops-result"]').text()).toContain('TRABCDEFGH')
  })

  it('shows forbidden when the API denies access', async () => {
    vi.stubGlobal('fetch', vi.fn(async () => json({ type: 'https://errors.xopti/authorization', title: 'Forbidden', status: 403 }, 403)))
    const { wrapper } = await mountInApp(StockOpsPage, { path: '/' })
    await wrapper.find('[data-testid="stock-ops-sku"] input').setValue('30110359')
    await wrapper.find('[data-testid="stock-ops-submit"]').trigger('click')
    await wrapper.find('[data-testid="stock-ops-confirm"]').trigger('click')
    await flushPromises()
    expect(wrapper.find('[data-testid="stock-ops-forbidden"]').exists()).toBe(true)
  })
})
