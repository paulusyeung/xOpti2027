import { afterEach, describe, expect, it, vi } from 'vitest'
import { flushPromises } from '@vue/test-utils'
import OrderEntryPage from '@/features/pos/OrderEntryPage.vue'
import { mountInApp } from './support'

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), { status, headers: { 'content-type': 'application/json' } })
}

const openOrder = {
  txNumber: 'SA00001001',
  controlNumber: '00001001',
  kind: 'Order',
  status: '0',
  statusLabel: 'Open',
  customerId: 700001,
  customerName: 'POS Customer',
  refNumber: null,
  totalSale: 45,
  taxA: 2.25,
  taxB: 3.15,
  grossSale: 50.4,
  totalAmount: 50.4,
  totalQty: 1,
  paid: 0,
  balance: 50.4,
  lines: [{
    rowNo: 1, sku: '99000001', qty: 1, unitAmount: 50, discountAmount: 5,
    unitCost: null, amount: 45, taxCode: 'B',
  }],
}

interface Call {
  url: string
  method: string
  body: unknown
}

function stubApi(handler: (call: Call) => Response | undefined = () => undefined) {
  const calls: Call[] = []
  const fetchMock = vi.fn(async (input: RequestInfo | URL, init?: RequestInit) => {
    const request = input instanceof Request ? input : null
    const url = request ? request.url : String(input)
    const method = request ? request.method : (init?.method ?? 'GET')
    const requestText = request ? await request.clone().text() : null
    const body = requestText
      ? JSON.parse(requestText)
      : init?.body ? JSON.parse(String(init.body)) : undefined
    calls.push({ url, method, body })
    if (url.includes('/auth/csrf-token')) return json({ token: 'csrf' })
    if (url.includes('/api/v1/sales/order-entry/context')) return json({ taxARate: 5, taxBRate: 7 })
    if (url.includes('/api/v1/sales/customers')) {
      return json([{ id: 700001, fullName: 'POS Customer', vipCode: 'V1' }])
    }
    if (url.includes('/api/v1/sales/items')) {
      return json([{ sku: '99000001', name: 'POS Frame', retailPrice: 50, taxCode: 'B', qtyOnHand: 10 }])
    }
    if (url.includes('/api/v1/sales/documents/')) return json(openOrder)
    if (url.includes('/api/v1/sales/orders') && method === 'GET') {
      return json({ items: [openOrder], nextCursor: null })
    }
    return handler({ url, method, body }) ?? json({}, 404)
  })
  vi.stubGlobal('fetch', fetchMock)
  return { fetchMock, calls }
}

afterEach(() => vi.unstubAllGlobals())

describe('OrderEntryPage', () => {
  it('searches customers and items, previews totals, and saves a new order', async () => {
    const { calls } = stubApi((call) =>
      call.method === 'POST' && call.url.includes('/api/v1/sales/orders')
        ? json({ ...openOrder, totalSale: 95, taxA: 4.75, taxB: 6.65, grossSale: 106.4,
          totalAmount: 106.4, totalQty: 2, paid: 20, balance: 86.4 }, 201)
        : undefined)

    const { wrapper } = await mountInApp(OrderEntryPage, { path: '/' })
    await flushPromises()

    await wrapper.find('[data-testid="pos-customer-search"] input').setValue('POS')
    await wrapper.find('[data-testid="pos-customer-find"]').trigger('click')
    await flushPromises()
    await wrapper.find('[data-testid="pos-customer-option-700001"]').trigger('click')
    expect(wrapper.find('[data-testid="pos-customer-selected"]').text()).toContain('POS Customer')

    await wrapper.find('[data-testid="pos-sku-search"] input').setValue('9900')
    await wrapper.find('[data-testid="pos-sku-find"]').trigger('click')
    await flushPromises()
    await wrapper.find('[data-testid="pos-sku-option-99000001"]').trigger('click')

    await wrapper.find('[data-testid="pos-line-0-qty"] input').setValue('2')
    await wrapper.find('[data-testid="pos-line-0-discount"] input').setValue('5')
    await wrapper.find('[data-testid="pos-deposit"] input').setValue('20')
    await flushPromises()

    expect(wrapper.find('[data-testid="pos-subtotal"]').text()).toBe('95.00')
    expect(wrapper.find('[data-testid="pos-tax-a"]').text()).toBe('4.75')
    expect(wrapper.find('[data-testid="pos-tax-b"]').text()).toBe('6.65')
    expect(wrapper.find('[data-testid="pos-total"]').text()).toBe('106.40')
    expect(wrapper.find('[data-testid="pos-balance"]').text()).toBe('86.40')

    await wrapper.find('[data-testid="pos-save"]').trigger('click')
    await flushPromises()

    expect(wrapper.find('[data-testid="pos-notice"]').text()).toContain('SA00001001')
    const posted = calls.find((call) => call.method === 'POST' && call.url.endsWith('/api/v1/sales/orders'))
    const body = posted?.body as {
      depositAmount: number
      lines: Array<{ sku: string; quantity: number; unitAmount: number; discountAmount: number; taxCode: string }>
    }
    expect(body.depositAmount).toBe(20)
    expect(body.lines[0]).toMatchObject({
      sku: '99000001', quantity: 2, unitAmount: 50, discountAmount: 5, taxCode: 'B',
    })
    wrapper.unmount()
  })

  it('resumes an open order and updates it', async () => {
    const { calls } = stubApi((call) =>
      call.method === 'PUT' ? json(openOrder) : undefined)

    const { wrapper } = await mountInApp(OrderEntryPage, { path: '/' })
    await flushPromises()

    await wrapper.find('[data-testid="pos-resume-SA00001001"]').trigger('click')
    await flushPromises()

    expect(wrapper.find('[data-testid="pos-lines"]').text()).toContain('99000001')
    expect(wrapper.find('[data-testid="pos-total"]').text()).toBe('50.40')
    expect(wrapper.find('[data-testid="pos-line-0-discount"] input').element)
      .toHaveProperty('value', '5')

    await wrapper.find('[data-testid="pos-save"]').trigger('click')
    await flushPromises()

    expect(calls.some((call) =>
      call.method === 'PUT' && call.url.endsWith('/api/v1/sales/orders/SA00001001'))).toBe(true)
    wrapper.unmount()
  })

  it('shows forbidden when the API denies access', async () => {
    vi.stubGlobal('fetch', vi.fn(async () =>
      json({ type: 'https://errors.xopti/authorization', title: 'Forbidden', status: 403 }, 403)))

    const { wrapper } = await mountInApp(OrderEntryPage, { path: '/' })
    await flushPromises()

    expect(wrapper.find('[data-testid="pos-forbidden"]').exists()).toBe(true)
    wrapper.unmount()
  })
})
