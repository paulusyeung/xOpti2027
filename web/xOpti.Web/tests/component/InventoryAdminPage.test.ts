import { afterEach, describe, expect, it, vi } from 'vitest'
import { flushPromises } from '@vue/test-utils'
import InventoryAdminPage from '@/features/admin/InventoryAdminPage.vue'
import { mountInApp } from './support'

const row = { sku: '30000001', name: 'Frame', qtyOnHand: 4, lotTracked: true }
const zero = { sku: '30000002', name: 'Out', qtyOnHand: 0, lotTracked: false }
const page = { items: [row, zero], nextCursor: null }
const more = { items: [{ sku: '30000003', name: 'Second Page', qtyOnHand: 2, lotTracked: false }], nextCursor: null }

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), { status, headers: { 'content-type': 'application/json' } })
}

function stub(handler: (url: string) => Response | undefined = () => undefined) {
  vi.stubGlobal('fetch', vi.fn(async (input: RequestInfo | URL) => {
    const url = input instanceof Request ? input.url : String(input)
    if (url.includes('/api/v1/admin/skus')) {
      return json(url.includes('cursor=') ? more : page)
    }
    if (url.includes('/availability')) {
      return json({ sku: row.sku, qtyTotalOnHand: 4, qtySaleOrder: 0, qtyPurchaseOrder: 0,
        branches: [{ branchCode: '01', qtyOnHand: 4 }],
        lots: [{ lotNo: 'L1', supplierCode: '0001', dateReceived: '2026-11-01', qtyPurchased: 4, qtyUsed: 0, qtyOnHand: 4 }] })
    }
    if (url.includes('/movements')) {
      return json({ items: [{ dateOfEntry: '2026-11-01', txType: 'SR', txNumber: 'SR00000001', rowNo: 1, qty: 4,
        unitAmount: { amount: 4 }, amount: { amount: 16 }, taxCode: 'N' }], nextCursor: null })
    }
    if (url.includes('/valuation')) {
      return json({ sku: row.sku, qtyOnHand: 4, averageCost: { amount: 4 }, extendedCost: { amount: 16 },
        lots: [{ lotNo: 'L1', qtyOnHand: 4, unitCost: { amount: 4 }, extendedCost: { amount: 16 } }] })
    }
    return handler(url) ?? json({}, 404)
  }))
}

afterEach(() => vi.unstubAllGlobals())

describe('InventoryAdminPage', () => {
  it('lists inventory and counts exceptions', async () => {
    stub()
    const { wrapper } = await mountInApp(InventoryAdminPage, { path: '/' })
    await flushPromises()
    expect(wrapper.find('[data-testid="inventory-row-30000001"]').text()).toContain('Frame')
    expect(wrapper.find('[data-testid="inventory-exception-count"]').text()).toContain('1 exception')
    wrapper.unmount()
  })

  it('shows forbidden when the API denies access', async () => {
    vi.stubGlobal('fetch', vi.fn(async () =>
      json({ type: 'https://errors.xopti/authorization', title: 'Forbidden', status: 403 }, 403)))
    const { wrapper } = await mountInApp(InventoryAdminPage, { path: '/' })
    await flushPromises()
    expect(wrapper.find('[data-testid="inventory-forbidden"]').exists()).toBe(true)
    expect(wrapper.find('[data-testid="inventory-table"]').exists()).toBe(false)
    wrapper.unmount()
  })

  it('shows an empty state and supports loading a second page', async () => {
    vi.stubGlobal('fetch', vi.fn(async (input: RequestInfo | URL) => {
      const url = input instanceof Request ? input.url : String(input)
      if (url.includes('/api/v1/admin/skus')) {
        return json(url.includes('cursor=') ? more : { items: [], nextCursor: 'next' })
      }
      return json({}, 404)
    }))
    const { wrapper } = await mountInApp(InventoryAdminPage, { path: '/' })
    await flushPromises()
    expect(wrapper.find('[data-testid="inventory-empty"]').exists()).toBe(true)
    await wrapper.find('[data-testid="inventory-load-more"]').trigger('click')
    await flushPromises()
    expect(wrapper.find('[data-testid="inventory-row-30000003"]').exists()).toBe(true)
    wrapper.unmount()
  })

  it('opens detail with lots, movements, and valuation', async () => {
    stub()
    const { wrapper } = await mountInApp(InventoryAdminPage, { path: '/' })
    await flushPromises()
    await wrapper.find('[data-testid="inventory-open-30000001"]').trigger('click')
    await flushPromises()
    expect(wrapper.find('[data-testid="inventory-detail"]').text()).toContain('30000001')
    expect(wrapper.find('[data-testid="inventory-lots"]').text()).toContain('L1')
    expect(wrapper.find('[data-testid="inventory-movements"]').text()).toContain('SR00000001')
    expect(wrapper.find('[data-testid="inventory-valuation"]').text()).toContain('Average cost: 4')
    wrapper.unmount()
  })
})
