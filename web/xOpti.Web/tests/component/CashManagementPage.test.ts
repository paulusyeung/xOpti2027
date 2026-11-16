import { afterEach, describe, expect, it, vi } from 'vitest'
import { flushPromises } from '@vue/test-utils'
import { createPinia, setActivePinia } from 'pinia'
import CashManagementPage from '@/features/pos/CashManagementPage.vue'
import { PermissionNames } from '@/security/permissions'
import { useSessionStore } from '@/stores/session'
import { mountInApp } from './support'

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), { status, headers: { 'content-type': 'application/json' } })
}

const openSession = {
  id: 1, branchCode: '01', terminalCode: '01', businessDate: '2026-11-16', status: 'open',
  openedAt: '2026-11-16T08:00:00Z', openedBy: 'manager', openingFloat: 100, expectedCash: 100,
  suspendedAt: null, closedAt: null, closedBy: null, countedCash: null, variance: null,
  varianceReason: null,
}
const closedSession = {
  ...openSession, status: 'closed', expectedCash: 100, countedCash: 90, variance: -10,
  varianceReason: 'short', closedAt: '2026-11-16T18:00:00Z', closedBy: 'manager',
}
const draftJournal = {
  branchCode: '01', businessDate: '2026-11-16', status: 'draft', finalizedAt: null,
  finalizedBy: null, reason: null, totalSales: 0, totalRefunds: 0, taxA: 0, taxB: 0,
  cashTenders: 0, cardTenders: 0, otherTenders: 0, paidIn: 0, paidOut: 10, pickups: 0,
  deposits: 0, expectedCash: 90, countedCash: 90, variance: 0, sessions: [], documents: [],
  movements: [],
}
const finalJournal = {
  ...draftJournal, status: 'final', finalizedAt: '2026-11-16T19:00:00Z',
  finalizedBy: 'manager', reason: 'end of day', countedCash: 90, variance: -10,
}

interface Call { url: string; method: string; body: unknown }

function stubApi() {
  const calls: Call[] = []
  let opened = false
  let closed = false
  vi.stubGlobal('fetch', vi.fn(async (input: RequestInfo | URL, init?: RequestInit) => {
    const request = input instanceof Request ? input : null
    const url = request ? request.url : String(input)
    const method = request ? request.method : (init?.method ?? 'GET')
    const text = request ? await request.clone().text() : null
    const body = text ? JSON.parse(text) : init?.body ? JSON.parse(String(init.body)) : undefined
    calls.push({ url, method, body })
    if (url.includes('/auth/csrf-token')) return json({ token: 'csrf' })
    if (url.includes('/cash/sessions/open')) return json(opened && !closed ? [openSession] : [])
    if (url.includes('/cash/sessions/1/count-context')) {
      return json({
        sessionId: 1, openingFloat: 100, expectedCash: closed ? 100 : 100, blind: false,
        counts: [], movements: closed ? [] : [],
      })
    }
    if (url.includes('/cash/sessions/1') && method === 'GET') {
      return json({
        session: closed ? closedSession : openSession, counts: [],
        movements: closed ? [] : [],
      })
    }
    if (url.includes('/cash/sessions') && method === 'POST' && !url.match(/sessions\/\d/)) {
      opened = true
      return json(openSession, 201)
    }
    if (url.includes('/movements') && method === 'POST') {
      return json({
        session: openSession, counts: [],
        movements: [{ id: 1, kind: 'paid-out', amount: 10, reason: 'petty cash',
          occurredAt: '2026-11-16T10:00:00Z', actor: 'manager', destinationReference: 'EXP-1' }],
      })
    }
    if (url.includes('/close') && method === 'POST') {
      closed = true
      return json(closedSession)
    }
    if (url.includes('/cash/journal')) return json(finalJournal.status === 'final' && closed ? draftJournal : draftJournal)
    if (url.includes('/cash/daily-closes') && method === 'POST') return json(finalJournal)
    return json({}, 404)
  }))
  return calls
}

afterEach(() => vi.unstubAllGlobals())

describe('CashManagementPage', () => {
  it('opens a drawer, records a paid-out, closes with variance, and finalizes the day', async () => {
    const calls = stubApi()
    const pinia = createPinia()
    setActivePinia(pinia)
    const store = useSessionStore(pinia)
    store.status = 'authenticated'
    store.identity = {
      username: 'manager', displayName: 'manager',
      permissions: [PermissionNames.SalesInvoicePost, PermissionNames.ReportFinancial],
    }

    const { wrapper } = await mountInApp(CashManagementPage, { path: '/', pinia })
    await flushPromises()

    await wrapper.find('[data-testid="cash-float"] input').setValue('100')
    await wrapper.find('[data-testid="cash-open"]').trigger('click')
    await flushPromises()
    expect(wrapper.find('[data-testid="cash-notice"]').text()).toContain('Opened')
    expect(wrapper.find('[data-testid="cash-expected"]').text()).toContain('100.00')
    expect(calls.some((call) => call.method === 'POST' && call.url.endsWith('/cash/sessions'))).toBe(true)

    await wrapper.find('[data-testid="cash-movement-amount"] input').setValue('10')
    await wrapper.find('[data-testid="cash-movement-reason"] input').setValue('petty cash')
    await wrapper.find('[data-testid="cash-movement-destination"] input').setValue('EXP-1')
    await wrapper.find('[data-testid="cash-movement-submit"]').trigger('click')
    await flushPromises()
    const movement = calls.find((call) => call.method === 'POST' && call.url.includes('/movements'))
    expect(movement?.body).toMatchObject({
      kind: 'paid-out', amount: 10, reason: 'petty cash', destinationReference: 'EXP-1',
    })

    await wrapper.find('[data-testid="cash-close-count"] input').setValue('90')
    await wrapper.find('[data-testid="cash-variance-reason"] input').setValue('short')
    await wrapper.find('[data-testid="cash-close-submit"]').trigger('click')
    await flushPromises()
    expect(wrapper.find('[data-testid="cash-notice"]').text()).toContain('-10.00')

    await wrapper.find('[data-testid="cash-finalize"]').trigger('click')
    await flushPromises()
    expect(wrapper.find('[data-testid="cash-journal-status"]').text()).toContain('final')
    wrapper.unmount()
  })
})
