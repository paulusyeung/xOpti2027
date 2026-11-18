import { afterEach, describe, expect, it, vi } from 'vitest'
import { flushPromises } from '@vue/test-utils'
import { createPinia, setActivePinia } from 'pinia'
import WholesalePage from '@/features/wholesale/WholesalePage.vue'
import { PermissionNames } from '@/security/permissions'
import { useSessionStore } from '@/stores/session'
import { mountInApp } from './support'

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), { status, headers: { 'content-type': 'application/json' } })
}

const account = {
  customerId: 7, isWholesale: true, priceGrade: 'B', termsCode: 'NET30',
  termsDays: 30, creditLimit: 25000.1234, taxTreatment: 'EXEMPT',
  representativeStaffCode: '0042', creditHold: false, notes: 'wholesale terms',
}
const list = {
  id: 1, code: 'A', name: 'Wholesale list', version: 1, isCurrent: true,
  items: [{ sku: 'WS1', price: 10.1111 }],
}
const balance = {
  customerId: 7, invoiced: 44.8, returned: -22.4, payments: 22.4, balance: 0,
  creditLimit: 25000.1234, overCreditLimit: false,
}
const statement = {
  customerId: 7, from: '2026-11-01', to: '2026-11-30', openingBalance: 0,
  invoiced: 44.8, returned: -22.4, payments: 22.4, closingBalance: 0,
  creditLimit: 25000.1234, overCreditLimit: false,
  items: [
    { documentType: 'invoice', txNumber: 'WC00000001', date: '2026-11-18',
      amount: 44.8, description: 'Wholesale invoice' },
  ],
}
const quote = {
  customerId: 7, sku: 'WS1', priceListCode: 'B', priceListVersion: 2,
  listUnitPrice: 14.4444, appliedUnitPrice: 12.3456, isOverride: true,
  overrideReason: 'volume discount',
}

interface Call { url: string; method: string; body: unknown }

function stubApi() {
  const calls: Call[] = []
  vi.stubGlobal('fetch', vi.fn(async (input: RequestInfo | URL, init?: RequestInit) => {
    const request = input instanceof Request ? input : null
    const url = request ? request.url : String(input)
    const method = request ? request.method : (init?.method ?? 'GET')
    const text = request ? await request.clone().text() : null
    const body = text ? JSON.parse(text) : init?.body ? JSON.parse(String(init.body)) : undefined
    calls.push({ url, method, body })
    if (url.includes('/auth/csrf-token')) return json({ token: 'csrf' })
    if (url.includes('/wholesale/accounts/7') && method === 'GET') return json(account)
    if (url.includes('/wholesale/accounts/7') && method === 'PUT') return json(account)
    if (url.includes('/balance')) return json(balance)
    if (url.includes('/statement/prints')) {
      return new Response(new Blob(['%PDF-1.4']), {
        status: 200, headers: { 'content-type': 'application/pdf' },
      })
    }
    if (url.includes('/statement')) return json(statement)
    if (url.includes('/wholesale/price-lists/import-legacy')) return json(2)
    if (url.includes('/wholesale/price-lists') && method === 'POST') return json({ ...list, code: 'A', version: 2 })
    if (url.includes('/wholesale/price-lists') && method === 'GET') return json([list])
    if (url.includes('/wholesale/customers/7/price')) return json(quote)
    return json({}, 404)
  }))
  return calls
}

afterEach(() => vi.unstubAllGlobals())

describe('WholesalePage', () => {
  it('loads terms, saves credit, publishes a list, and resolves an override', async () => {
    const calls = stubApi()
    const pinia = createPinia()
    setActivePinia(pinia)
    const store = useSessionStore(pinia)
    store.status = 'authenticated'
    store.identity = {
      username: 'manager', displayName: 'manager',
      permissions: [
        PermissionNames.WholesaleInvoicePost,
        PermissionNames.MasterDataMaintain,
        PermissionNames.SalesPriceOverride,
      ],
    }

    const { wrapper } = await mountInApp(WholesalePage, {
      path: '/admin/wholesale', pinia,
    })
    await flushPromises()
    expect(wrapper.find('[data-testid="wholesale-price-lists"]').text()).toContain('A')

    await wrapper.find('[data-testid="wholesale-customer"] input').setValue('7')
    await wrapper.find('[data-testid="wholesale-load"]').trigger('click')
    await flushPromises()
    expect((wrapper.find('[data-testid="wholesale-terms"] input').element as HTMLInputElement).value)
      .toBe('NET30')
    expect((wrapper.find('[data-testid="wholesale-credit"] input').element as HTMLInputElement).value)
      .toBe('25000.1234')
    expect((wrapper.find('[data-testid="wholesale-representative"] input').element as HTMLInputElement).value)
      .toBe('0042')

    await wrapper.find('[data-testid="wholesale-credit"] input').setValue('30000')
    await wrapper.find('[data-testid="wholesale-save"]').trigger('click')
    await flushPromises()
    expect(wrapper.find('[data-testid="wholesale-notice"]').text()).toContain('saved')
    const save = calls.find((call) => call.method === 'PUT')
    expect((save?.body as { input: { creditLimit: number } }).input.creditLimit).toBe(30000)

    await wrapper.find('[data-testid="wholesale-price-code"] input').setValue('A')
    await wrapper.find('[data-testid="wholesale-price-name"] input').setValue('Wholesale list')
    await wrapper.find('[data-testid="wholesale-price-items"] textarea').setValue('WS1,10.1111\nWS2,20.2222')
    await wrapper.find('[data-testid="wholesale-publish"]').trigger('click')
    await flushPromises()
    expect(wrapper.find('[data-testid="wholesale-notice"]').text()).toContain('published')
    const publish = calls.find((call) => call.method === 'POST' && call.url.includes('/price-lists'))
    expect((publish?.body as { input: { items: unknown[] } }).input.items).toHaveLength(2)

    await wrapper.find('[data-testid="wholesale-quote-sku"] input').setValue('WS1')
    await wrapper.find('[data-testid="wholesale-quote-price"] input').setValue('12.3456')
    await wrapper.find('[data-testid="wholesale-quote-reason"] input').setValue('volume discount')
    await wrapper.find('[data-testid="wholesale-quote-load"]').trigger('click')
    await flushPromises()
    const result = wrapper.find('[data-testid="wholesale-quote-result"]').text()
    expect(result).toContain('List B v2')
    expect(result).toContain('Applied 12.3456')
    expect(result).toContain('Override: volume discount')
    const quoteCall = calls.find((call) => call.url.includes('/customers/7/price'))
    expect(quoteCall?.url).toContain('sku=WS1')
    expect(quoteCall?.url).toContain('unitPrice=12.3456')

    await wrapper.find('[data-testid="wholesale-balance-load"]').trigger('click')
    await flushPromises()
    expect(wrapper.find('[data-testid="wholesale-balance"]').text()).toContain('balance 0.0000')

    await wrapper.find('[data-testid="wholesale-statement-load"]').trigger('click')
    await flushPromises()
    expect(wrapper.find('[data-testid="wholesale-statement"]').text()).toContain('closing 0.0000')

    await wrapper.find('[data-testid="wholesale-statement-print"]').trigger('click')
    await flushPromises()
    expect(wrapper.find('[data-testid="wholesale-notice"]').text()).toContain('Statement printed')
    wrapper.unmount()
  })
})
