import { afterEach, describe, expect, it, vi } from 'vitest'
import { flushPromises } from '@vue/test-utils'
import { createPinia, setActivePinia } from 'pinia'
import WholesaleInvoicePage from '@/features/wholesale/WholesaleInvoicePage.vue'
import { PermissionNames } from '@/security/permissions'
import { useSessionStore } from '@/stores/session'
import { mountInApp } from './support'

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), { status, headers: { 'content-type': 'application/json' } })
}

const invoice = {
  txNumber: 'WC00000001', customerId: 7, customerName: 'Wholesale Buyer',
  status: 'posted', dateOfEntry: '2026-11-18T10:00:00Z', totalSale: 40,
  taxA: 2, taxB: 2.8, totalAmount: 44.8, paid: 44.8, termsCode: 'NET30',
  dueDate: '2026-12-18', shippingMethod: 'Courier', shipToName: 'Receiving Dock',
  shipToAddress: '10 Wholesale Way', shippingInstructions: 'Call', purchaseOrderNumber: 'PO-1',
  lines: [{
    rowNo: 1, sku: 'WS1', description: 'item', quantity: 2, unitAmount: 20,
    discountAmount: 0, amount: 40, taxCode: 'B', backorderQuantity: 0,
    overrideReason: null,
  }],
  tenders: [{ method: 'C', amount: 44.8, reference: null }],
}
const packingBase = {
  txNumber: 'WC00000001', status: 'posted', dateOfEntry: '2026-11-18T10:00:00Z',
  customerId: 7, customerName: 'Wholesale Buyer', purchaseOrderNumber: 'PO-1',
  shippingMethod: 'Courier', shipToName: 'Receiving Dock',
  shipToAddress: '10 Wholesale Way', shippingInstructions: 'Call',
  lines: [{ rowNo: 1, sku: 'WS1', description: 'item', quantity: 2,
    backorderQuantity: 0, unitAmount: null, amount: null }],
}

function stubApi() {
  vi.stubGlobal('fetch', vi.fn(async (input: RequestInfo | URL, init?: RequestInit) => {
    const request = input instanceof Request ? input : null
    const url = request ? request.url : String(input)
    const method = request ? request.method : (init?.method ?? 'GET')
    if (url.includes('/auth/csrf-token')) return json({ token: 'csrf' })
    if (url.includes('/packing-list/prints')) {
      return new Response(new Blob(['%PDF-1.4']), {
        status: 200, headers: { 'content-type': 'application/pdf' },
      })
    }
    if (url.includes('/packing-list')) {
      const prices = url.includes('includePrices=true')
      return json({ ...packingBase, includesPrices: prices,
        lines: packingBase.lines.map((line) => ({ ...line,
          unitAmount: prices ? 20 : null, amount: prices ? 40 : null })) })
    }
    if (url.includes('/backorders')) return json([])
    if (url.includes('/wholesale/invoices/WC00000001') && method === 'GET') return json(invoice)
    if (url.includes('/wholesale/invoices') && method === 'GET') {
      return json({ items: [invoice], nextCursor: null })
    }
    return json({}, 404)
  }))
}

afterEach(() => vi.unstubAllGlobals())

describe('WholesaleInvoicePage', () => {
  it('shows the packing list without prices by default and prints a reprint', async () => {
    stubApi()
    const pinia = createPinia()
    setActivePinia(pinia)
    const store = useSessionStore(pinia)
    store.status = 'authenticated'
    store.identity = {
      username: 'manager', displayName: 'manager',
      permissions: [PermissionNames.WholesaleInvoicePost, PermissionNames.ReportFinancial],
    }

    const { wrapper } = await mountInApp(WholesaleInvoicePage, {
      path: '/admin/wholesale/invoices', pinia,
    })
    await flushPromises()
    await wrapper.find('[data-testid="invoice-select-WC00000001"]').trigger('click')
    await flushPromises()
    expect(wrapper.find('[data-testid="invoice-status"]').text()).toContain('posted')

    await wrapper.find('[data-testid="packing-list-open"]').trigger('click')
    await flushPromises()
    const hidden = wrapper.find('[data-testid="packing-list-result"]').text()
    expect(hidden).toContain('Receiving Dock')
    expect(hidden).toContain('PO-1')
    expect(hidden).not.toContain('unit')

    await wrapper.find('[data-testid="packing-list-prices"] input').setValue(true)
    await wrapper.find('[data-testid="packing-list-open"]').trigger('click')
    await flushPromises()
    expect(wrapper.find('[data-testid="packing-list-result"]').text()).toContain('unit 20.0000')

    await wrapper.find('[data-testid="packing-list-reprint"]').trigger('click')
    await flushPromises()
    expect(wrapper.find('[data-testid="invoice-notice"]').text())
      .toContain('Packing-list reprint generated')
    wrapper.unmount()
  })
})
