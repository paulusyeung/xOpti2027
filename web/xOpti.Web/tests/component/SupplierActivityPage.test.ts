import { afterEach, describe, expect, it, vi } from 'vitest'
import { flushPromises } from '@vue/test-utils'
import SupplierActivityPage from '@/features/admin/SupplierActivityPage.vue'
import { mountInApp } from './support'

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), { status, headers: { 'content-type': 'application/json' } })
}
const activity = { supplierCode: '0001', from: '2026-11-01', to: '2026-11-30', receiptCount: 1, returnCount: 1,
  receiptCost: 17.46, returnCost: 4.365, netCost: 13.095, taxTotal: 0.62,
  documentNumbers: ['SR00000001', 'RJ00000002'], mismatches: ['purchased 999 vs posted 17.46 (SR00000001)'] }
const doc = { txNumber: 'SR00000001', txType: 'SR', controlNumber: '00000001', dateOfEntry: '2026-11-10',
  totalCost: 17.46, taxA: 0.2, taxB: 0.3, totalAmount: 17.96, reprint: true,
  lines: [{ rowNo: 1, sku: '30110359', qty: 4, unitCost: 4.365, amount: 17.46 }] }

function stub() {
  vi.stubGlobal('fetch', vi.fn(async (input: RequestInfo | URL) => {
    const url = input instanceof Request ? input.url : String(input)
    if (url.includes('/activity')) return json(activity)
    if (url.includes('/purchasing/documents/')) return json(doc)
    return json({}, 404)
  }))
}
afterEach(() => vi.unstubAllGlobals())

describe('SupplierActivityPage', () => {
  it('loads activity totals, mismatches, and documents', async () => {
    stub()
    const { wrapper } = await mountInApp(SupplierActivityPage, { path: '/' })
    await wrapper.find('[data-testid="supplier-code"] input').setValue('0001')
    await wrapper.find('[data-testid="supplier-load"]').trigger('click')
    await flushPromises()
    expect(wrapper.find('[data-testid="supplier-totals"]').text()).toContain('Receipts 1')
    expect(wrapper.find('[data-testid="supplier-mismatches"]').text()).toContain('purchased 999')
    expect(wrapper.find('[data-testid="supplier-documents"]').text()).toContain('SR00000001')
  })

  it('opens and reprints a posted document', async () => {
    stub()
    const { wrapper } = await mountInApp(SupplierActivityPage, { path: '/' })
    await wrapper.find('[data-testid="supplier-code"] input').setValue('0001')
    await wrapper.find('[data-testid="supplier-load"]').trigger('click')
    await flushPromises()
    await wrapper.find('[data-testid="supplier-reprint-SR00000001"]').trigger('click')
    await flushPromises()
    expect(wrapper.find('[data-testid="supplier-document-lines"]').text()).toContain('30110359')
    expect(wrapper.find('[data-testid="supplier-reprinted"]').exists()).toBe(true)
  })
})
