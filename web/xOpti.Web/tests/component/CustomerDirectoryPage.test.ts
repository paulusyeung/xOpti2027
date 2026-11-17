import { afterEach, describe, expect, it, vi } from 'vitest'
import { flushPromises } from '@vue/test-utils'
import CustomerDirectoryPage from '@/features/customers/CustomerDirectoryPage.vue'
import { mountInApp } from './support'

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), { status, headers: { 'content-type': 'application/json' } })
}

const customer = {
  id: 1, vipCode: 'V1', salutation: null, firstName: '***', initial: null,
  lastName: '***', fullName: '***', birthday: null, homeAddress: null, homeCity: 0,
  homeProvince: null, homePostalCode: null, homeCountry: null, homePhone: null,
  homeFax: null, cellular: null, email: null, bizCompanyName: null, bizJobTitle: null,
  bizAddress: null, bizCity: 0, bizProvince: null, bizPostalCode: null, bizCountry: null,
  bizPhone: null, bizFax: null, creditLimit: 250, paymentTerms: '30', vipMarkDownPct: 0,
  summaryFlag: false, accountingFlag: false, remarks: null,
}
const view = { customer, resolvedFrom: null }
const summary = {
  id: 1, vipCode: 'V1', displayName: '***', homePhone: null, email: null,
  homeCity: '1', accountNumber: 'V1',
}
const balance = {
  customerId: 1, charges: 112, payments: 112, refunds: 0, balance: 0,
  creditLimit: 250, overCreditLimit: false,
}
const history = {
  customerId: 1,
  items: [{ txNumber: 'RC00000001', txType: 'RC', dateOfEntry: '2026-11-17T10:00:00Z',
    totalAmount: 112, paid: 112, status: '0', refNumber: null }],
}
const statement = {
  customerId: 1, from: '2026-11-01', to: '2026-11-30', openingBalance: 0,
  charges: 112, payments: 112, refunds: 0, closingBalance: 0, items: history.items,
}

interface Call { url: string; method: string; body: unknown }

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
    if (url.includes('/customers/1/account')) return json(balance)
    if (url.includes('/customers/1/history')) return json(history)
    if (url.includes('/customers/1/statement')) return json(statement)
    if (url.includes('/customers/1') && method === 'GET') return json(view)
    if (url.includes('/customers/merge') && method === 'POST') return json({ ...view, resolvedFrom: 2 })
    if (url.includes('/customers/1') && method === 'PUT') return json(view)
    const handled = handler({ url, method, body })
    if (handled) return handled
    if (url.includes('/customers') && method === 'POST') return json(view, 201)
    if (url.includes('/customers') && method === 'GET') {
      return json({ items: [summary], nextCursor: null })
    }
    return json({}, 404)
  }))
  return calls
}

afterEach(() => vi.unstubAllGlobals())

describe('CustomerDirectoryPage', () => {
  it('creates, confirms a duplicate warning, edits, merges, and generates a statement', async () => {
    let duplicatePending = true
    const calls = stubApi((call) => {
      if (call.url.includes('/customers') && call.method === 'POST'
        && !call.url.includes('/merge') && duplicatePending) {
        duplicatePending = false
        return json({ type: 'https://errors.xopti/validation', title: 'Validation failed', status: 400,
          errors: [{ field: 'Duplicate', code: 'duplicate-candidate',
            message: 'Possible duplicate customer(s): 7.' }] }, 400)
      }
      return undefined
    })

    const { wrapper } = await mountInApp(CustomerDirectoryPage, { path: '/' })
    await flushPromises()
    expect(wrapper.find('[data-testid="customer-list"]').text()).toContain('***')

    await wrapper.find('[data-testid="customer-new"]').trigger('click')
    await wrapper.find('[data-testid="customer-full-name"] input').setValue('Ada Lens')
    await wrapper.find('[data-testid="customer-phone"] input').setValue('6045550100')
    await wrapper.find('[data-testid="customer-email"] input').setValue('ada@example.test')
    await wrapper.find('[data-testid="customer-save"]').trigger('click')
    await flushPromises()
    expect(wrapper.find('[data-testid="customer-duplicate-confirm"]').exists()).toBe(true)

    await wrapper.find('[data-testid="customer-duplicate-confirm"] input').setValue(true)
    await wrapper.find('[data-testid="customer-save"]').trigger('click')
    await flushPromises()
    expect(wrapper.find('[data-testid="customer-notice"]').text()).toContain('Customer 1 saved')

    await wrapper.find('[data-testid="customer-select-1"]').trigger('click')
    await flushPromises()
    expect(wrapper.find('[data-testid="customer-account"]').text()).toContain('Balance 0.00')

    await wrapper.find('[data-testid="customer-edit"]').trigger('click')
    await wrapper.find('[data-testid="customer-credit-limit"] input').setValue('500')
    await wrapper.find('[data-testid="customer-save"]').trigger('click')
    await flushPromises()
    const update = calls.find((call) => call.method === 'PUT')
    expect((update?.body as { input: { creditLimit: number } }).input.creditLimit).toBe(500)

    await wrapper.find('[data-testid="customer-merge-open"]').trigger('click')
    await wrapper.find('[data-testid="customer-merge-source"] input').setValue('2')
    await wrapper.find('[data-testid="customer-merge-target"] input').setValue('1')
    await wrapper.find('[data-testid="customer-merge-name"] input').setValue('Canonical Name')
    await wrapper.find('[data-testid="customer-merge-reason"] input').setValue('same person')
    await wrapper.find('[data-testid="customer-merge-submit"]').trigger('click')
    await flushPromises()
    expect(wrapper.find('[data-testid="customer-notice"]').text()).toContain('Merged 2 into 1')

    await wrapper.find('[data-testid="customer-statement-load"]').trigger('click')
    await flushPromises()
    expect(wrapper.find('[data-testid="customer-statement"]').text()).toContain('Closing 0.00')
    wrapper.unmount()
  })
})
