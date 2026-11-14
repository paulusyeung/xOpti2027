import { afterEach, describe, expect, it, vi } from 'vitest'
import { flushPromises } from '@vue/test-utils'
import ImportPage from '@/features/admin/ImportPage.vue'
import { mountInApp } from './support'

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), { status, headers: { 'content-type': 'application/json' } })
}

function stub(post: () => Response) {
  vi.stubGlobal('fetch', vi.fn(async (input: RequestInfo | URL, init?: RequestInit) => {
    const request = input instanceof Request ? input : null
    const url = request ? request.url : String(input)
    if (url.includes('/auth/csrf-token')) return json({ token: 'csrf' })
    if ((request?.method ?? init?.method) === 'POST') return post()
    return json({}, 404)
  }))
}

afterEach(() => vi.unstubAllGlobals())

describe('ImportPage', () => {
  it('shows dry-run counts without committing', async () => {
    stub(() => json({ kind: 'Supplier', dryRun: true, created: 2, updated: 1, skipped: 0, errors: [], resumeFrom: null }))
    const { wrapper } = await mountInApp(ImportPage, { path: '/' })
    await wrapper.find('[data-testid="import-reason"] input').setValue('dry run')
    await wrapper.find('[data-testid="import-dry-run"]').trigger('click')
    await flushPromises()
    expect(wrapper.find('[data-testid="import-counts"]').text()).toContain('Created: 2')
    expect(wrapper.find('[data-testid="import-message"]').text()).toContain('nothing was written')
    wrapper.unmount()
  })

  it('reports row errors and offers the error download', async () => {
    stub(() => json({
      kind: 'Supplier', dryRun: false, created: 0, updated: 0, skipped: 0,
      errors: [{ row: 2, field: 'name', message: 'A name is required.' }], resumeFrom: 2,
    }, 200))
    const { wrapper } = await mountInApp(ImportPage, { path: '/' })
    await wrapper.find('[data-testid="import-reason"] input').setValue('confirmed')
    await wrapper.find('[data-testid="import-confirm"]').trigger('click')
    await flushPromises()
    expect(wrapper.find('[data-testid="import-errors"]').text()).toContain('A name is required.')
    expect(wrapper.find('[data-testid="import-download"]').exists()).toBe(true)
    expect(wrapper.find('[data-testid="import-message"]').text()).toContain('row 2')
    wrapper.unmount()
  })
})
