import { afterEach, describe, expect, it, vi } from 'vitest'
import { flushPromises } from '@vue/test-utils'
import RetailRefundPage from '@/features/pos/RetailRefundPage.vue'
import { mountInApp } from './support'

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), { status, headers: { 'content-type': 'application/json' } })
}

const refundable = {
  txNumber: 'RC00001001',
  customerId: 500001,
  customerName: 'Retail Customer',
  dateOfEntry: '2026-11-15T12:00:00Z',
  totalSale: 150,
  taxA: 7.5,
  taxB: 10.5,
  totalAmount: 168,
  refundedTaxA: 0,
  refundedTaxB: 0,
  lines: [{
    rowNo: 1, sku: '99000004', originalQuantity: 3, refundedQuantity: 0, refundableQuantity: 3,
    unitAmount: 50, discountAmount: 0, amount: 150, taxA: 7.5, taxB: 10.5, taxCode: 'B',
  }],
}

const invoice = {
  txNumber: 'RC00001001',
  controlNumber: '00001001',
  kind: 'Invoice',
  status: '0',
  statusLabel: 'Open',
  customerId: 500001,
  customerName: 'Retail Customer',
  refNumber: null,
  totalSale: 150, taxA: 7.5, taxB: 10.5, grossSale: 168, change: 0, totalAmount: 168,
  totalQty: 3, paid: 168, balance: 0,
  lines: [{ rowNo: 1, sku: '99000004', qty: 3, unitAmount: 50, discountAmount: 0,
    unitCost: 30, amount: 150, taxCode: 'B' }],
  payments: [],
}

const refund = {
  ...invoice,
  txNumber: 'RS00001001',
  kind: 'Refund',
  totalSale: -50, taxA: -2.5, taxB: -3.5, grossSale: -56, totalAmount: -56,
  totalQty: -1, paid: 0, balance: -56,
  lines: [{ rowNo: 1, sku: '99000004', qty: -1, unitAmount: 50, discountAmount: 0,
    unitCost: 30, amount: -50, taxCode: 'B' }],
}

interface Call {
  url: string
  method: string
  body: unknown
}

function stubApi(handler: (call: Call) => Response | undefined = () => undefined) {
  const calls: Call[] = []
  vi.stubGlobal('fetch', vi.fn(async (input: RequestInfo | URL, init?: RequestInit) => {
    const request = input instanceof Request ? input : null
    const url = request ? request.url : String(input)
    const method = request ? request.method : (init?.method ?? 'GET')
    const text = request ? await request.clone().text() : null
    const body = text ? JSON.parse(text) : init?.body ? JSON.parse(String(init.body)) : undefined
    calls.push({ url, method, body })
    if (url.includes('/auth/csrf-token')) return json({ token: 'csrf' })
    if (url.includes('/sales/order-entry/context')) return json({ taxARate: 5, taxBRate: 7 })
    if (url.includes('/refundable')) return json(refundable)
    if (url.includes('/sales/items')) {
      return json([{ sku: '99000004', name: 'Retail Frame', retailPrice: 50, taxCode: 'B', qtyOnHand: 10 }])
    }
    if (url.includes('/sales/documents/')) return json(invoice)
    return handler({ url, method, body }) ?? json({}, 404)
  }))
  return calls
}

afterEach(() => vi.unstubAllGlobals())

describe('RetailRefundPage', () => {
  it('loads refundable lines, posts a partial refund with an exchange, and reprints', async () => {
    const calls = stubApi((call) =>
      call.method === 'POST' && call.url.includes('/sales/refunds') ? json(refund, 201) : undefined)

    const { wrapper } = await mountInApp(RetailRefundPage, { path: '/' })
    await flushPromises()

    await wrapper.find('[data-testid="pos-refund-invoice"] input').setValue('RC00001001')
    await wrapper.find('[data-testid="pos-refund-load"]').trigger('click')
    await flushPromises()
    expect(wrapper.find('[data-testid="pos-refund-lines"]').text()).toContain('99000004')

    await wrapper.find('[data-testid="pos-refund-line-1-qty"] input').setValue('1')
    await flushPromises()
    expect(wrapper.find('[data-testid="pos-refund-value"]').text()).toBe('50.00')

    await wrapper.find('[data-testid="pos-refund-sku-search"] input').setValue('9900')
    await wrapper.find('[data-testid="pos-refund-sku-find"]').trigger('click')
    await flushPromises()
    await wrapper.find('[data-testid="pos-refund-sku-option-99000004"]').trigger('click')
    await flushPromises()
    expect(wrapper.find('[data-testid="pos-refund-net"]').text()).toBe('0.00')

    await wrapper.find('[data-testid="pos-refund-submit"]').trigger('click')
    await flushPromises()

    expect(wrapper.find('[data-testid="pos-refund-notice"]').text()).toContain('RS00001001')
    const posted = calls.find((call) => call.method === 'POST' && call.url.includes('/sales/refunds'))
    expect(posted?.body).toMatchObject({
      originalTxNumber: 'RC00001001',
      lines: [{ originalRowNo: 1, quantity: 1, restock: true }],
      replacements: [{ sku: '99000004', quantity: 1, unitAmount: 50, discountAmount: 0, taxCode: 'B' }],
    })

    await wrapper.find('[data-testid="pos-refund-reprint"]').trigger('click')
    await flushPromises()
    expect(wrapper.find('[data-testid="pos-refund-reprinted"]').text()).toContain('RC00001001')
    wrapper.unmount()
  })

  it('shows the server over-refund message', async () => {
    stubApi((call) => {
      if (call.method === 'POST' && call.url.includes('/sales/refunds')) {
        return json({ type: 'https://errors.xopti/validation', title: 'Validation failed', status: 400,
          errors: [{ field: 'Quantity', code: 'over-refund',
            message: 'Line 1 (99000004) has 2 refundable unit(s).' }] }, 400)
      }
      return undefined
    })

    const { wrapper } = await mountInApp(RetailRefundPage, { path: '/' })
    await flushPromises()
    await wrapper.find('[data-testid="pos-refund-invoice"] input').setValue('RC00001001')
    await wrapper.find('[data-testid="pos-refund-load"]').trigger('click')
    await flushPromises()
    await wrapper.find('[data-testid="pos-refund-line-1-qty"] input').setValue('3')
    await wrapper.find('[data-testid="pos-refund-submit"]').trigger('click')
    await flushPromises()

    expect(wrapper.find('[data-testid="pos-refund-error"]').text()).toContain('2 refundable unit(s)')
    wrapper.unmount()
  })
})
