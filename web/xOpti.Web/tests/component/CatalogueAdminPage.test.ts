import { afterEach, describe, expect, it, vi } from 'vitest'
import { flushPromises } from '@vue/test-utils'
import CatalogueAdminPage from '@/features/admin/CatalogueAdminPage.vue'
import { mountInApp } from './support'

const sku = '30110359'
const row = {
  sku,
  name: 'Test Frame',
  departmentCode: '01',
  classCode: '01',
  categoryCode: '01',
  supplierCode: '0001',
  brandCode: '0001',
  materialCode: null,
  lotTracked: true,
  retailPriceFlag: true,
  wholesalePriceFlag: false,
  qtyOnHand: 10,
}
const page = { items: [row], nextCursor: null }
const tag = { barcode: sku, sku, labelText: sku, reprint: false }

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), { status, headers: { 'content-type': 'application/json' } })
}

function validation(field: string, message: string): Response {
  return json({ type: 'https://errors.xopti/validation', title: 'Validation failed', status: 400,
    errors: [{ field, code: 'invalid', message }] }, 400)
}

function stubApi(handler: (url: string, method: string) => Response | undefined = () => undefined) {
  const fetchMock = vi.fn(async (input: RequestInfo | URL, init?: RequestInit) => {
    const request = input instanceof Request ? input : null
    const url = request ? request.url : String(input)
    const method = request ? request.method : (init?.method ?? 'GET')
    if (url.includes('/api/v1/auth/csrf-token')) return json({ token: 'csrf' })
    if (url.includes('/api/v1/admin/skus') && method === 'GET' && !url.includes('/barcode')) return json(page)
    return handler(url, method) ?? json({}, 404)
  })
  vi.stubGlobal('fetch', fetchMock)
  return fetchMock
}

afterEach(() => vi.unstubAllGlobals())

describe('CatalogueAdminPage', () => {
  it('loads the catalogue and searches by term', async () => {
    const fetchMock = stubApi()
    const { wrapper } = await mountInApp(CatalogueAdminPage, { path: '/' })
    await flushPromises()

    expect(wrapper.find(`[data-testid="catalogue-row-${sku}"]`).text()).toContain('Test Frame')
    await wrapper.find('[data-testid="catalogue-search"] input').setValue('frame')
    await wrapper.find('[data-testid="catalogue-search-button"]').trigger('click')
    await flushPromises()

    expect(fetchMock.mock.calls.some(([input]) => {
      const request = input instanceof Request ? input : null
      return request?.url.includes('search=frame') ?? false
    })).toBe(true)
    wrapper.unmount()
  })

  it('edits a SKU and reloads the row', async () => {
    const fetchMock = stubApi((_url, method) =>
      method === 'PUT' ? json({ ...row, name: 'Renamed Frame' }) : undefined)
    const { wrapper } = await mountInApp(CatalogueAdminPage, { path: '/' })
    await flushPromises()

    await wrapper.find(`[data-testid="catalogue-edit-${sku}"]`).trigger('click')
    await wrapper.find('[data-testid="catalogue-name"] input').setValue('Renamed Frame')
    await wrapper.find('[data-testid="catalogue-reason"] input').setValue('rename sku')
    await wrapper.find('[data-testid="catalogue-submit"]').trigger('click')
    await flushPromises()

    expect(wrapper.find('[data-testid="catalogue-notice"]').text()).toContain('updated')
    expect(fetchMock.mock.calls.some(([input]) => (input instanceof Request ? input.method === 'PUT' : false))).toBe(true)
    wrapper.unmount()
  })

  it('shows a field error when a price has too many decimals', async () => {
    stubApi((_url, method) => method === 'PUT'
      ? validation('RetailPrice', 'Prices allow at most four decimal places and cannot be negative.')
      : undefined)
    const { wrapper } = await mountInApp(CatalogueAdminPage, { path: '/' })
    await flushPromises()

    await wrapper.find(`[data-testid="catalogue-prices-${sku}"]`).trigger('click')
    await wrapper.find('[data-testid="catalogue-retail-price"] input').setValue('1.23456')
    await wrapper.find('[data-testid="catalogue-reason"] input').setValue('too precise')
    await wrapper.find('[data-testid="catalogue-submit"]').trigger('click')
    await flushPromises()

    const form = wrapper.find('[data-testid="catalogue-form-prices"]')
    expect(form.exists()).toBe(true)
    expect(form.text()).toContain('at most four decimal places')
    wrapper.unmount()
  })

  it('blocks retirement while stock is on hand until confirmed', async () => {
    stubApi((url, method) => {
      if (method !== 'POST') return undefined
      return url.includes('/retire')
        ? json({ type: 'https://errors.xopti/validation', title: 'Validation failed', status: 400,
            errors: [{ field: 'ConfirmOnHand', code: 'on-hand',
              message: `SKU '${sku}' still has 10 on hand; confirm retirement explicitly.` }] }, 400)
        : undefined
    })
    const { wrapper } = await mountInApp(CatalogueAdminPage, { path: '/' })
    await flushPromises()

    await wrapper.find(`[data-testid="catalogue-retire-${sku}"]`).trigger('click')
    await wrapper.find('[data-testid="catalogue-reason"] input').setValue('obsolete')
    await wrapper.find('[data-testid="catalogue-submit"]').trigger('click')
    await flushPromises()

    expect(wrapper.find('[data-testid="catalogue-on-hand-hint"]').text()).toContain('10 on hand')
    wrapper.unmount()
  })

  it('generates a barcode tag and reports an identical reprint', async () => {
    let generated = false
    stubApi((url, method) => {
      if (url.includes('/barcode') && method === 'GET') {
        return generated ? json({ ...tag, reprint: true }) : validation('Sku', 'No barcode tag exists.')
      }
      if (url.includes('/barcode') && method === 'POST') {
        generated = true
        return json(tag)
      }
      return undefined
    })
    const { wrapper } = await mountInApp(CatalogueAdminPage, { path: '/' })
    await flushPromises()

    await wrapper.find(`[data-testid="catalogue-barcode-${sku}"]`).trigger('click')
    await flushPromises()
    expect(wrapper.find('[data-testid="catalogue-form-barcode"]').text()).toContain('Generate tag')

    await wrapper.find('[data-testid="catalogue-reason"] input').setValue('print tag')
    await wrapper.find('[data-testid="catalogue-submit"]').trigger('click')
    await flushPromises()
    expect(wrapper.find('[data-testid="catalogue-barcode-tag"]').text()).toContain(sku)

    await wrapper.find('[data-testid="catalogue-barcode-reprint-button"]').trigger('click')
    await flushPromises()
    expect(wrapper.find('[data-testid="catalogue-barcode-reprint"]').exists()).toBe(true)
    expect(wrapper.find('[data-testid="catalogue-barcode-tag"]').text()).toContain(sku)
    wrapper.unmount()
  })
})
