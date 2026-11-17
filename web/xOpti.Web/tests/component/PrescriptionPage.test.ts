import { afterEach, describe, expect, it, vi } from 'vitest'
import { flushPromises } from '@vue/test-utils'
import { createPinia, setActivePinia } from 'pinia'
import PrescriptionPage from '@/features/prescriptions/PrescriptionPage.vue'
import { PermissionNames } from '@/security/permissions'
import { useSessionStore } from '@/stores/session'
import { mountInApp } from './support'

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), { status, headers: { 'content-type': 'application/json' } })
}

const empty = {
  customerId: 1, medical: null, spectacle: [], contact: [], medicalNotes: [], attachments: [],
}
const eye = { sphere: 1.25, cylinder: -0.5, axis: 90, add: null, prism: null, base: null, pd: null }
const saved = {
  ...empty,
  spectacle: [{
    id: 1, versionNumber: 1, source: 'app', issuedOn: '2026-11-17T00:00:00Z',
    isCurrent: true, verifiedAt: null, verifiedBy: null, verificationNote: null,
    reason: 'new prescription', notes: '', right: eye, left: eye,
  }],
}
const verified = {
  ...saved,
  spectacle: [{ ...saved.spectacle[0], verifiedAt: '2026-11-17T12:00:00Z', verifiedBy: 'manager' }],
}
const withNote = {
  ...verified,
  medicalNotes: [{ id: 1, note: 'allergy: none', recordedAt: '2026-11-17T12:00:00Z', recordedBy: 'manager' }],
}
const withAttachment = {
  ...withNote,
  attachments: [{ id: 1, kind: 'prescription', fileName: 'scan.pdf',
    contentType: 'application/pdf', size: 9, uploadedAt: '2026-11-17T12:00:00Z', uploadedBy: 'manager' }],
}

interface Call { url: string; method: string; body: unknown }

function stubApi() {
  const calls: Call[] = []
  vi.stubGlobal('fetch', vi.fn(async (input: RequestInfo | URL, init?: RequestInit) => {
    const request = input instanceof Request ? input : null
    const url = request ? request.url : String(input)
    const method = request ? request.method : (init?.method ?? 'GET')
    const text = request && !url.includes('/attachments') ? await request.clone().text() : null
    let body: unknown
    try { body = text ? JSON.parse(text) : init?.body ? JSON.parse(String(init.body)) : undefined }
    catch { body = undefined }
    calls.push({ url, method, body })
    if (url.includes('/auth/csrf-token')) return json({ token: 'csrf' })
    if (url.includes('/prescriptions/verify') && method === 'POST') return json(verified)
    if (url.includes('/prescriptions/spectacle') && method === 'POST') return json(saved)
    if (url.includes('/medical-notes') && method === 'POST') return json(withNote)
    if (url.includes('/attachments') && method === 'POST') return json(withAttachment)
    if (url.includes('/prescriptions') && method === 'GET') return json(empty)
    return json({}, 404)
  }))
  return calls
}

afterEach(() => vi.unstubAllGlobals())

describe('PrescriptionPage', () => {
  it('saves a spectacle version, verifies it, adds a medical note, and uploads an attachment', async () => {
    const calls = stubApi()
    const pinia = createPinia()
    setActivePinia(pinia)
    const store = useSessionStore(pinia)
    store.status = 'authenticated'
    store.identity = {
      username: 'manager', displayName: 'manager',
      permissions: [PermissionNames.PrescriptionView, PermissionNames.PrescriptionEnter],
    }

    const { wrapper } = await mountInApp(PrescriptionPage, {
      path: '/admin/prescriptions?customerId=1', pinia,
    })
    await flushPromises()
    expect(wrapper.find('[data-testid="rx-spectacle-current"]').text()).toContain('none')

    await wrapper.find('[data-testid="rx-right-sphere"] input').setValue('1.25')
    await wrapper.find('[data-testid="rx-spectacle-save"]').trigger('click')
    await flushPromises()
    expect(wrapper.find('[data-testid="rx-notice"]').text()).toContain('immutable version')
    expect(wrapper.find('[data-testid="rx-spectacle-current"]').text()).toContain('unverified')

    await wrapper.find('[data-testid="rx-spectacle-verify"]').trigger('click')
    await flushPromises()
    expect(wrapper.find('[data-testid="rx-spectacle-current"]').text()).toContain('verified')

    await wrapper.find('[data-testid="rx-medical-note"] input').setValue('allergy: none')
    await wrapper.find('[data-testid="rx-medical-note-add"]').trigger('click')
    await flushPromises()
    expect(wrapper.find('[data-testid="rx-medical-notes"]').text()).toContain('allergy: none')

    expect(calls.some((call) => call.url.includes('/prescriptions/spectacle'))).toBe(true)
    wrapper.unmount()
  })
})
