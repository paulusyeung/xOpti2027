import { afterEach, describe, expect, it, vi } from 'vitest'
import { flushPromises } from '@vue/test-utils'
import RetailSalePage from '@/features/pos/RetailSalePage.vue'
import { mountInApp } from './support'

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), { status, headers: { 'content-type': 'application/json' } })
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
  totalSale: 100,
  taxA: 5,
  taxB: 7,
  grossSale: 112,
  change: 8,
  totalAmount: 112,
  totalQty: 2,
  paid: 112,
  balance: 0,
  lines: [{ rowNo: 1, sku: '99000002', qty: 2, unitAmount: 50, discountAmount: 0,
    unitCost: 30, amount: 100, taxCode: 'B' }],
  payments: [{ paymentLineNo: 1, type: 'C', amountTender: 120, appliedAmount: 112, reference: null }],
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
    if (url.includes('/prints') && method === 'POST') {
      return new Response('%PDF', { status: 200, headers: { 'content-type': 'application/pdf' } })
    }
    if (url.includes('/cash/sessions/open')) return json([])
    if (url.includes('/sales/payment-methods')) {
      return json([
        { code: 'C', nameShort: 'CSH', nameLong: 'Cash' },
        { code: 'K', nameShort: 'CRD', nameLong: 'Card' },
      ])
    }
    if (url.includes('/sales/customers')) return json([{ id: 500001, fullName: 'Retail Customer', vipCode: null }])
    if (url.includes('/sales/items')) {
      return json([{ sku: '99000002', name: 'Retail Frame', retailPrice: 50, taxCode: 'B', qtyOnHand: 10 }])
    }
    if (url.includes('/sales/documents/')) return json(invoice)
    return handler({ url, method, body }) ?? json({}, 404)
  }))
  return calls
}

afterEach(() => vi.unstubAllGlobals())

describe('RetailSalePage', () => {
  it('totals a cash sale with change, posts it, and reprints the snapshot', async () => {
    const calls = stubApi((call) =>
      call.method === 'POST' && call.url.includes('/sales/invoices')
        ? json(invoice, 201)
        : undefined)

    const { wrapper } = await mountInApp(RetailSalePage, { path: '/' })
    await flushPromises()

    await wrapper.find('[data-testid="pos-sale-customer-search"] input').setValue('Retail')
    await wrapper.find('[data-testid="pos-sale-customer-find"]').trigger('click')
    await flushPromises()
    await wrapper.find('[data-testid="pos-sale-customer-option-500001"]').trigger('click')

    await wrapper.find('[data-testid="pos-sale-sku-search"] input').setValue('9900')
    await wrapper.find('[data-testid="pos-sale-sku-find"]').trigger('click')
    await flushPromises()
    await wrapper.find('[data-testid="pos-sale-sku-option-99000002"]').trigger('click')
    await wrapper.find('[data-testid="pos-sale-line-0-qty"] input').setValue('2')
    await wrapper.find('[data-testid="pos-sale-payment-amount-0"] input').setValue('120')
    await flushPromises()

    expect(wrapper.find('[data-testid="pos-sale-total"]').text()).toBe('112.00')
    expect(wrapper.find('[data-testid="pos-sale-payment-change"]').text()).toBe('8.00')

    await wrapper.find('[data-testid="pos-sale-submit"]').trigger('click')
    await flushPromises()

    expect(wrapper.find('[data-testid="pos-sale-notice"]').text()).toContain('RC00001001')
    const posted = calls.find((call) => call.method === 'POST' && call.url.includes('/sales/invoices'))
    expect(posted?.body).toMatchObject({
      customerId: 500001,
      tenders: [{ method: 'C', amount: 120, reference: null }],
      lines: [{ sku: '99000002', quantity: 2, unitAmount: 50, discountAmount: 0, taxCode: 'B' }],
    })

    await wrapper.find('[data-testid="pos-sale-reprint"]').trigger('click')
    await flushPromises()
    expect(wrapper.find('[data-testid="pos-sale-reprinted"]').text()).toContain('RC00001001')
    expect(wrapper.findAll('[data-testid="pos-document-total"]')[0].text()).toBe('112.00')
    wrapper.unmount()
  })

  it.each([
    ['declined', 'terminal-declined', 'declined'],
    ['timeout', 'terminal-timeout', 'timed out'],
  ])('shows a terminal %s message', async (_label, code, message) => {
    stubApi((call) => {
      if (call.method === 'POST' && call.url.includes('/sales/invoices')) {
        return json({ type: 'https://errors.xopti/validation', title: 'Validation failed', status: 400,
          errors: [{ field: 'Tenders', code, message: `The simulated terminal ${message}.` }] }, 400)
      }
      return undefined
    })
    const { wrapper } = await mountInApp(RetailSalePage, { path: '/' })
    await flushPromises()
    await wrapper.find('[data-testid="pos-sale-customer-search"] input').setValue('Retail')
    await wrapper.find('[data-testid="pos-sale-customer-find"]').trigger('click')
    await flushPromises()
    await wrapper.find('[data-testid="pos-sale-customer-option-500001"]').trigger('click')
    await wrapper.find('[data-testid="pos-sale-sku-search"] input').setValue('9900')
    await wrapper.find('[data-testid="pos-sale-sku-find"]').trigger('click')
    await flushPromises()
    await wrapper.find('[data-testid="pos-sale-sku-option-99000002"]').trigger('click')
    await wrapper.find('[data-testid="pos-sale-submit"]').trigger('click')
    await flushPromises()
    expect(wrapper.find('[data-testid="pos-sale-error"]').text()).toContain(message)
    wrapper.unmount()
  })

  it('shows forbidden when the API denies invoice posting', async () => {
    vi.stubGlobal('fetch', vi.fn(async (input: RequestInfo | URL) => {
      const url = input instanceof Request ? input.url : String(input)
      if (url.includes('/auth/csrf-token')) return json({ token: 'csrf' })
      return json({ type: 'https://errors.xopti/authorization', title: 'Forbidden', status: 403 }, 403)
    }))

    const { wrapper } = await mountInApp(RetailSalePage, { path: '/' })
    await flushPromises()
    expect(wrapper.find('[data-testid="pos-sale-forbidden"]').exists()).toBe(true)
    wrapper.unmount()
  })
})
