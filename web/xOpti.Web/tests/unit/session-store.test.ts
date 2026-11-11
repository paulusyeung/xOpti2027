import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'
import { createPinia, setActivePinia } from 'pinia'
import { api } from '@/api/client'
import { useSessionStore } from '@/stores/session'
import { draftCount, registerDraft } from '@/stores/drafts'
import { fakeFetch, json, problem } from '../support/fakeFetch'

const ME = '/api/v1/auth/me'
const SIGN_IN = '/api/v1/auth/sign-in'
const SIGN_OUT = '/api/v1/auth/sign-out'
const CSRF = '/api/v1/auth/csrf-token'

interface Account {
  username: string
  password: string
  permissions: string[]
}

/** A tiny server: one signed-in user at a time, idle-expiry simulated by `expireNow()`. */
function fakeServer(accounts: Account[]) {
  let current: Account | null = null
  let expired = false
  const { fn, calls } = fakeFetch((call) => {
    if (call.path === CSRF) return json(200, { token: 'tok' })
    if (call.path === SIGN_IN) {
      const body = JSON.parse(call.body ?? '{}') as { username: string; password: string }
      // ASP.NET Identity normalises user names, so lookup is case-insensitive.
      const match = accounts.find(
        (a) => a.username.toLowerCase() === body.username.toLowerCase() && a.password === body.password,
      )
      if (!match) return problem(401, 'https://errors.xopti/unauthenticated')
      current = match
      expired = false
      return json(200, { username: match.username, displayName: null })
    }
    if (call.path === ME) {
      if (expired) return problem(401, 'https://errors.xopti/session-expired')
      if (!current) return problem(401, 'https://errors.xopti/unauthenticated')
      return json(200, { username: current.username, displayName: null, permissions: current.permissions })
    }
    if (call.path === SIGN_OUT) {
      current = null
      return new Response(null, { status: 204 })
    }
    return json(404, {})
  })
  return {
    fn,
    calls,
    expireNow() {
      expired = true
    },
  }
}

const accounts: Account[] = [
  { username: 'manager', password: 'pw-manager', permissions: ['cost:view'] },
  { username: 'clerk', password: 'pw-clerk', permissions: [] },
]

describe('session store', () => {
  let server: ReturnType<typeof fakeServer>
  const registrations: (() => void)[] = []
  const draft = (reset: () => void) => {
    registrations.push(registerDraft(reset))
  }

  beforeEach(() => {
    setActivePinia(createPinia())
    server = fakeServer(accounts)
    vi.stubGlobal('fetch', server.fn)
    api.setSessionExpiredHandler(() => useSessionStore().expire())
  })

  afterEach(() => {
    for (const unregister of registrations.splice(0)) {
      unregister()
    }
    expect(draftCount()).toBe(0)
  })

  it('restores an existing session on start', async () => {
    await server.fn(new Request('http://localhost/api/v1/auth/sign-in', { method: 'POST', body: '{"username":"manager","password":"pw-manager"}' }))
    const session = useSessionStore()

    await session.restore()

    expect(session.status).toBe('authenticated')
    expect(session.hasPermission('cost:view')).toBe(true)
  })

  it('is anonymous when no session exists', async () => {
    const session = useSessionStore()
    await session.restore()
    expect(session.status).toBe('anonymous')
    expect(session.identity).toBeNull()
  })

  it('signs in and loads permissions from auth/me', async () => {
    const session = useSessionStore()
    const outcome = await session.signIn('manager', 'pw-manager')

    expect(outcome).toBe('new')
    expect(session.status).toBe('authenticated')
    expect(session.hasPermission('cost:view')).toBe(true)
  })

  it('does not store credentials or tokens in browser storage', async () => {
    const setItem = vi.spyOn(Storage.prototype, 'setItem')
    const session = useSessionStore()

    await session.signIn('manager', 'pw-manager')
    await session.signOut()

    expect(setItem).not.toHaveBeenCalled()
    expect(localStorage.length).toBe(0)
    expect(sessionStorage.length).toBe(0)
  })

  it('moves to expired on session expiry and keeps the last username', async () => {
    const session = useSessionStore()
    await session.signIn('manager', 'pw-manager')

    server.expireNow()
    await api.client.GET(ME)

    expect(session.status).toBe('expired')
    expect(session.identity).toBeNull()
    expect(session.lastUsername).toBe('manager')
    expect(session.hasPermission('cost:view')).toBe(false)
  })

  it('resumes with drafts kept when the same user signs in again (case-insensitive)', async () => {
    const session = useSessionStore()
    await session.signIn('manager', 'pw-manager')
    const reset = vi.fn()
    draft(reset)

    server.expireNow()
    await api.client.GET(ME)
    const outcome = await session.signIn('MANAGER', 'pw-manager')

    expect(outcome).toBe('resumed')
    expect(reset).not.toHaveBeenCalled()
    expect(session.status).toBe('authenticated')
  })

  it('purges drafts and reports a switch when a different user signs in after expiry', async () => {
    const session = useSessionStore()
    await session.signIn('manager', 'pw-manager')
    const reset = vi.fn()
    draft(reset)

    server.expireNow()
    await api.client.GET(ME)
    const outcome = await session.signIn('clerk', 'pw-clerk')

    expect(outcome).toBe('switched')
    expect(reset).toHaveBeenCalledTimes(1)
  })

  it('clears identity, cached permissions, token, and drafts on sign-out', async () => {
    const session = useSessionStore()
    await session.signIn('manager', 'pw-manager')
    const reset = vi.fn()
    draft(reset)

    await session.signOut()

    expect(session.status).toBe('anonymous')
    expect(session.identity).toBeNull()
    expect(session.hasPermission('cost:view')).toBe(false)
    expect(reset).toHaveBeenCalledTimes(1)
  })

  it('refreshes the anti-forgery token after sign-in so the next unsafe request is accepted', async () => {
    const session = useSessionStore()
    const tokensBefore = server.calls.filter((c) => c.path === CSRF).length

    await session.signIn('manager', 'pw-manager')

    const tokensAfter = server.calls.filter((c) => c.path === CSRF).length
    expect(tokensAfter).toBeGreaterThan(tokensBefore)
  })
})
