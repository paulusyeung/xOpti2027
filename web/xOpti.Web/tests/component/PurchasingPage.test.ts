import { afterEach, describe, expect, it, vi } from 'vitest'
import { flushPromises } from '@vue/test-utils'
import PurchasingPage from '@/features/admin/PurchasingPage.vue'
import { mountInApp } from './support'

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), { status, headers: { 'content-type': 'application/json' } })
}

const posted = { txNumber: 'SR00001234', controlNumber: '00001234', totalQuantity: 5, totalCost: 21.825, totalTax: 0.53 }

function stub(response: () => Response = () => json(posted, 201)) {
  const fetchMock = vi.fn(async (input: RequestInfo | URL, init?: RequestInit) => {
    const request = input instanceof Request ? input : null
    const url = request ? request.url : String(input)
    const method = request ? request.method : (init?.method ?? 'GET')
    if (url.includes('/auth/csrf-token')) return json({ token: 'csrf' })
    if (method === 'POST') return response()
    return json({}, 404)
  })
  vi.stubGlobal('fetch', fetchMock)
  return fetchMock
}

afterEach(() => vi.unstubAllGlobals())

describe('PurchasingPage', () => {
  it('computes line totals from quantity, cost, and tax', async () => {
    stub()
    const { wrapper } = await mountInApp(PurchasingPage, { path: '/' })
    await wrapper.find('[data-testid="line-sku-0"] input').setValue('30110359')
    await wrapper.find('[data-testid="line-lot-0"] input').setValue('LOT1')
    await wrapper.find('[data-testid="line-qty-0"] input').setValue('5')
    await wrapper.find('[data-testid="line-cost-0"] input').setValue('4.365')
    await wrapper.find('[data-testid="line-gst-0"] input').setValue('0.22')
    await flushPromises()
    expect(wrapper.find('[data-testid="purchasing-totals"]').text()).toContain('Qty 5')
    expect(wrapper.find('[data-testid="purchasing-totals"]').text()).toContain('21.8250')
  })

  it('posts a receipt and reprints identical document data', async () => {
    stub()
    const { wrapper } = await mountInApp(PurchasingPage, { path: '/' })
    await wrapper.find('[data-testid="purchasing-supplier"] input').setValue('0001')
    await wrapper.find('[data-testid="line-sku-0"] input').setValue('30110359')
    await wrapper.find('[data-testid="line-lot-0"] input').setValue('LOT1')
    await wrapper.find('[data-testid="line-qty-0"] input').setValue('5')
    await wrapper.find('[data-testid="line-cost-0"] input').setValue('4.365')
    await wrapper.find('[data-testid="purchasing-reason"] input').setValue('receive stock')
    await wrapper.find('[data-testid="purchasing-submit"]').trigger('click')
    await flushPromises()
    expect(wrapper.find('[data-testid="purchasing-posted"]').text()).toContain('SR00001234')
    expect(wrapper.find('[data-testid="purchasing-posted-summary"]').text()).toContain('21.8250')
    await wrapper.find('[data-testid="purchasing-reprint"]').trigger('click')
    expect(wrapper.find('[data-testid="purchasing-reprinted"]').text()).toContain('identical numbers')
  })

  it('shows the available-quantity validation from a rejected return', async () => {
    stub(() => json({ type: 'https://errors.xopti/validation', title: 'Validation failed', status: 400,
      errors: [{ field: 'Quantity', code: 'insufficient', message: 'Only 5 unit(s) available for SKU 30110359.' }] }, 400))
    const { wrapper } = await mountInApp(PurchasingPage, { path: '/' })
    await wrapper.find('[data-testid="purchasing-mode-reject"]').trigger('click')
    await wrapper.find('[data-testid="purchasing-supplier"] input').setValue('0001')
    await wrapper.find('[data-testid="purchasing-original"] input').setValue('SR00000001')
    await wrapper.find('[data-testid="line-sku-0"] input').setValue('30110359')
    await wrapper.find('[data-testid="line-qty-0"] input').setValue('6')
    await wrapper.find('[data-testid="purchasing-reason"] input').setValue('over return')
    await wrapper.find('[data-testid="purchasing-submit"]').trigger('click')
    await flushPromises()
    expect(wrapper.find('[data-testid="purchasing-error"]').text()).toContain('5 unit(s) available')
  })

  it('switches to rejection mode with the original document field', async () => {
    stub()
    const { wrapper } = await mountInApp(PurchasingPage, { path: '/' })
    expect(wrapper.find('[data-testid="purchasing-original"]').exists()).toBe(false)
    await wrapper.find('[data-testid="purchasing-mode-reject"]').trigger('click')
    expect(wrapper.find('[data-testid="purchasing-original"]').exists()).toBe(true)
    expect(wrapper.find('[data-testid="purchasing-submit"]').text()).toContain('rejection')
  })
})
