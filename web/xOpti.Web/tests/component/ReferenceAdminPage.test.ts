import { afterEach, describe, expect, it, vi } from 'vitest'
import { DOMWrapper, flushPromises } from '@vue/test-utils'
import { createPinia, setActivePinia } from 'pinia'
import ReferenceAdminPage from '@/features/admin/ReferenceAdminPage.vue'
import { useSessionStore } from '@/stores/session'
import { mountInApp } from './support'
import {
  REFERENCE_PAGES,
  referencePageByLabel,
  referencePageByPath,
  referencePath,
} from '@/router/referencePages'

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

afterEach(() => {
  vi.unstubAllGlobals()
  localStorage.clear()
})

function dialogWrapper(): DOMWrapper<Element> {
  const element = document.body.querySelector(
    '[data-testid^="reference-form-"], [data-testid="reference-retire-form"]',
  )
  if (!element) throw new Error('Reference dialog was not rendered')
  return new DOMWrapper(element)
}

function authenticatedPinia() {
  const pinia = createPinia()
  setActivePinia(pinia)
  const session = useSessionStore(pinia)
  session.status = 'authenticated'
  session.identity = {
    username: 'admin',
    displayName: 'Admin',
    permissions: ['master-data:maintain'],
  }
  return pinia
}

describe('ReferenceAdminPage', () => {
  it('loads the directory and exposes create/edit/retire actions', async () => {
    stubApi()
    const { wrapper } = await mountInApp(ReferenceAdminPage, { path: '/' })
    await flushPromises()

    expect(wrapper.find('[data-testid="grid-table"]').exists()).toBe(true)
    expect(wrapper.find('[data-testid="grid-row-B1"]').text()).toContain('Beta Brand')
    expect(wrapper.find('[data-testid="reference-edit-B1"]').exists()).toBe(true)
    expect(wrapper.find('[data-testid="reference-retire-B1"]').exists()).toBe(true)
    wrapper.unmount()
  })

  it('uses the page configuration for the route', async () => {
    const fetchMock = stubApi()
    const pinia = createPinia()
    setActivePinia(pinia)
    const session = useSessionStore(pinia)
    session.status = 'authenticated'
    session.identity = { username: 'admin', displayName: 'Admin', permissions: ['master-data:maintain'] }
    const { wrapper } = await mountInApp(ReferenceAdminPage, {
      path: '/admin/reference/countries',
      pinia,
    })
    await flushPromises()

    const headers = wrapper.findAll('thead th').map((th) => th.text())
    expect(headers).toEqual(['Code', 'Country', 'Actions'])
    expect(wrapper.find('[data-testid="reference-kind"]').exists()).toBe(false)

    const urls = fetchMock.mock.calls.map(([input]) => {
      const request = input instanceof Request ? input : null
      return request ? request.url : String(input)
    })
    expect(urls.some((url) => url.includes('/api/v1/admin/reference/Country')), urls.join('\n')).toBe(true)
    wrapper.unmount()
  })

  it('shows the grid toolbar with the four customisation controls', async () => {
    stubApi()
    const pinia = authenticatedPinia()
    const { wrapper } = await mountInApp(ReferenceAdminPage, {
      path: '/admin/reference/countries',
      pinia,
    })
    await flushPromises()

    for (const testId of [
      'grid-columns-button', 'grid-sort-button', 'grid-checkbox-button', 'grid-views-button',
    ]) {
      expect(wrapper.find(`[data-testid="${testId}"]`).exists(), testId).toBe(true)
    }
    expect(wrapper.find('[data-testid="grid-style-button"]').exists()).toBe(false)
    expect(wrapper.find('[data-testid="grid-color-button"]').exists()).toBe(false)
    wrapper.unmount()
  })

  it('persists checkbox mode and the selected view', async () => {
    stubApi()
    const pinia = authenticatedPinia()
    const { wrapper } = await mountInApp(ReferenceAdminPage, {
      path: '/admin/reference/countries',
      pinia,
    })
    await flushPromises()

    expect(wrapper.find('[data-testid="grid-reset-button"]').exists()).toBe(false)
    await wrapper.get('[data-testid="grid-checkbox-button"]').trigger('click')
    await flushPromises()
    expect(document.querySelector('[data-testid="grid-row-checkbox"]')).not.toBeNull()

    await wrapper.get('[data-testid="grid-views-button"]').trigger('click')
    await flushPromises()
    const resetOption = document.querySelector('[data-testid="grid-reset-button"]')
    expect(resetOption).not.toBeNull()
    const cardOption = document.querySelector('[data-testid="grid-view-card"]')
    expect(cardOption).not.toBeNull()
    cardOption!.dispatchEvent(new MouseEvent('click', { bubbles: true }))
    await flushPromises()
    expect(document.querySelector('[data-testid="grid-card-B1"]')).not.toBeNull()

    const stored = JSON.parse(localStorage.getItem('xopti.grid.view.countries') ?? '{}')
    expect(stored.checkboxMode).toBe(true)
    expect(stored.viewMode).toBe('card')
    wrapper.unmount()
  })

  it('opens a dialog with the complete record when Edit is clicked', async () => {
    stubApi()
    const pinia = authenticatedPinia()
    const { wrapper } = await mountInApp(ReferenceAdminPage, {
      path: '/admin/reference/countries',
      pinia,
    })
    await flushPromises()

    await wrapper.get('[data-testid="reference-edit-B1"]').trigger('click')
    await flushPromises()

    const dialog = dialogWrapper()
    expect(dialog.find('[data-testid="reference-key"]').exists()).toBe(true)
    expect(dialog.find('[data-testid="reference-name"]').exists()).toBe(true)
    expect(dialog.text()).toContain('Countries')
    wrapper.unmount()
  })

  it('shows kind-specific headers and subtitle for doctors', async () => {
    stubApi()
    const pinia = createPinia()
    setActivePinia(pinia)
    const session = useSessionStore(pinia)
    session.status = 'authenticated'
    session.identity = { username: 'admin', displayName: 'Admin', permissions: ['master-data:maintain'] }
    const { wrapper } = await mountInApp(ReferenceAdminPage, {
      path: '/admin/reference/doctors',
      pinia,
    })
    await flushPromises()

    expect(wrapper.findAll('thead th').map((th) => th.text()))
      .toEqual(['ID', 'Doctor', 'Address', 'Actions'])
    wrapper.unmount()
  })

  it('shows the forbidden state without the master-data permission', async () => {
    vi.stubGlobal('fetch', vi.fn(async () =>
      json({ type: 'https://errors.xopti/authorization', title: 'Forbidden', status: 403 }, 403)))
    const { wrapper } = await mountInApp(ReferenceAdminPage, { path: '/' })
    await flushPromises()

    expect(wrapper.find('[data-testid="reference-forbidden"]').exists()).toBe(true)
    expect(wrapper.find('[data-testid="grid-table"]').exists()).toBe(false)
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
    await dialogWrapper().find('[data-testid="reference-key"] input').setValue('B1')
    await dialogWrapper().find('[data-testid="reference-name"] input').setValue('Duplicate')
    await dialogWrapper().find('[data-testid="reference-reason"] input').setValue('duplicate probe')
    await dialogWrapper().find('[data-testid="reference-submit"]').trigger('click')
    await flushPromises()

    const form = dialogWrapper()
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
    await dialogWrapper().find('[data-testid="reference-key"] input').setValue('B1')
    await dialogWrapper().find('[data-testid="reference-name"] input').setValue('Created Brand')
    await dialogWrapper().find('[data-testid="reference-reason"] input').setValue('new brand')
    await dialogWrapper().find('[data-testid="reference-submit"]').trigger('click')
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
    await dialogWrapper().find('[data-testid="reference-reason"] input').setValue('obsolete')
    await dialogWrapper().find('[data-testid="reference-submit"]').trigger('click')
    await flushPromises()

    expect(dialogWrapper().find('[data-testid="reference-referenced-hint"]').exists()).toBe(true)
    expect(dialogWrapper().text()).toContain('referenced by 2 record')
    wrapper.unmount()
  })
})

describe('reference pages', () => {
  it('gives every legacy menu label its own page', () => {
    const labels = REFERENCE_PAGES.map((page) => page.label)
    expect(new Set(labels).size).toBe(labels.length)
  })

  it('uses unique paths and route ids', () => {
    const ids = REFERENCE_PAGES.map((page) => page.id)
    const paths = REFERENCE_PAGES.map(referencePath)
    expect(new Set(ids).size).toBe(ids.length)
    expect(new Set(paths).size).toBe(paths.length)
  })

  it('provides a title, subtitle and column labels for every page', () => {
    for (const page of REFERENCE_PAGES) {
      expect(page.title.length, page.id).toBeGreaterThan(0)
      expect(page.subtitle.length, page.id).toBeGreaterThan(0)
      expect(page.keyLabel.length, page.id).toBeGreaterThan(0)
      expect(page.nameLabel.length, page.id).toBeGreaterThan(0)
      expect(referencePageByLabel(page.label)).toBe(page)
      expect(referencePageByPath(referencePath(page))).toBe(page)
    }
  })
})
