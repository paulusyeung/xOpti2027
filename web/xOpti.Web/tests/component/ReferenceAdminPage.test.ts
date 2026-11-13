import { afterEach, describe, expect, it, vi } from 'vitest'
import { flushPromises } from '@vue/test-utils'
import ReferenceAdminPage from '@/features/admin/ReferenceAdminPage.vue'
import { mountInApp } from './support'

const page = {
  items: [{ kind: 'Brand', key: 'B1', name: 'Beta Brand', parent: null, detail: null }],
  nextCursor: null,
}

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { 'content-type': 'application/json' },
  })
}

function stubApi(handler: (url: string, method: string) => Response | undefined = () => undefined) {
  const fetchMock = vi.fn(async (input: RequestInfo | URL, init?: RequestInit) => {
    const request = input instanceof Request ? input : null
    const url = request ? request.url : String(input)
    const method = request ? request.method : (init?.method ?? 'GET')
    if (url.includes('/api/v1/auth/csrf-token')) return json({ token: 'csrf' })
    if (url.includes('/api/v1/admin/reference') && method === 'GET') return json(page)
    return handler(url, method) ?? json({}, 404)
  })
  vi.stubGlobal('fetch', fetchMock)
  return fetchMock
}

afterEach(() => vi.unstubAllGlobals())

describe('ReferenceAdminPage', () => {
  it('loads the directory and exposes create/edit/retire actions', async () => {
    stubApi()
    const { wrapper } = await mountInApp(ReferenceAdminPage, { path: '/' })
    await flushPromises()

    expect(wrapper.find('[data-testid="reference-table"]').exists()).toBe(true)
    expect(wrapper.find('[data-testid="reference-row-B1"]').text()).toContain('Beta Brand')
    expect(wrapper.find('[data-testid="reference-edit-B1"]').exists()).toBe(true)
    expect(wrapper.find('[data-testid="reference-retire-B1"]').exists()).toBe(true)
    wrapper.unmount()
  })

  it('shows the forbidden state without the master-data permission', async () => {
    vi.stubGlobal('fetch', vi.fn(async () =>
      json({ type: 'https://errors.xopti/authorization', title: 'Forbidden', status: 403 }, 403)))
    const { wrapper } = await mountInApp(ReferenceAdminPage, { path: '/' })
    await flushPromises()

    expect(wrapper.find('[data-testid="reference-forbidden"]').exists()).toBe(true)
    expect(wrapper.find('[data-testid="reference-table"]').exists()).toBe(false)
    wrapper.unmount()
  })

  it('renders a field error for a duplicate key and keeps the form open', async () => {
    stubApi((_url, method) =>
      method === 'POST'
        ? json({
            type: 'https://errors.xopti/validation',
            title: 'Validation failed',
            status: 400,
            errors: [{ field: 'Key', code: 'duplicate', message: "Brand key 'B1' already exists." }],
          }, 400)
        : undefined)

    const { wrapper } = await mountInApp(ReferenceAdminPage, { path: '/' })
    await flushPromises()

    await wrapper.find('[data-testid="reference-create-open"]').trigger('click')
    await wrapper.find('[data-testid="reference-key"] input').setValue('B1')
    await wrapper.find('[data-testid="reference-name"] input').setValue('Duplicate')
    await wrapper.find('[data-testid="reference-reason"] input').setValue('duplicate probe')
    await wrapper.find('[data-testid="reference-submit"]').trigger('click')
    await flushPromises()

    const form = wrapper.find('[data-testid="reference-form-create"]')
    expect(form.exists()).toBe(true)
    expect(form.text()).toContain("Brand key 'B1' already exists.")
    wrapper.unmount()
  })

  it('creates a reference record and reloads the directory', async () => {
    const fetchMock = stubApi((_url, method) =>
      method === 'POST'
        ? json({ kind: 'Brand', key: 'B1', name: 'Duplicate', parent: null, detail: null }, 201)
        : undefined)

    const { wrapper } = await mountInApp(ReferenceAdminPage, { path: '/' })
    await flushPromises()

    await wrapper.find('[data-testid="reference-create-open"]').trigger('click')
    await wrapper.find('[data-testid="reference-key"] input').setValue('B1')
    await wrapper.find('[data-testid="reference-name"] input').setValue('Created Brand')
    await wrapper.find('[data-testid="reference-reason"] input').setValue('new brand')
    await wrapper.find('[data-testid="reference-submit"]').trigger('click')
    await flushPromises()

    expect(wrapper.find('[data-testid="reference-notice"]').text()).toContain("'B1' created")
    expect(fetchMock.mock.calls.filter(([input]) => {
      const request = input instanceof Request ? input : null
      return request?.method === 'GET' && request.url.includes('/admin/reference')
    }).length).toBeGreaterThan(1)
    wrapper.unmount()
  })

  it('requires explicit confirmation before retiring a referenced record', async () => {
    stubApi((_url, method) =>
      method === 'POST'
        ? json({
            type: 'https://errors.xopti/validation',
            title: 'Validation failed',
            status: 400,
            errors: [{
              field: 'ConfirmReferenced',
              code: 'referenced',
              message: "Brand 'B1' is referenced by 2 record(s); confirm retirement explicitly.",
            }],
          }, 400)
        : undefined)

    const { wrapper } = await mountInApp(ReferenceAdminPage, { path: '/' })
    await flushPromises()

    await wrapper.find('[data-testid="reference-retire-B1"]').trigger('click')
    await wrapper.find('[data-testid="reference-reason"] input').setValue('obsolete')
    await wrapper.find('[data-testid="reference-submit"]').trigger('click')
    await flushPromises()

    expect(wrapper.find('[data-testid="reference-referenced-hint"]').exists()).toBe(true)
    expect(wrapper.find('[data-testid="reference-retire-form"]').text()).toContain('referenced by 2 record')
    wrapper.unmount()
  })
})
