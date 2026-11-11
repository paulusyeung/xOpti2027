import { describe, expect, it, vi } from 'vitest'
import { createApi } from '@/api/client'
import { CSRF_HEADER } from '@/api/csrf'
import { fakeFetch, json, problem } from '../support/fakeFetch'

const CSRF_PATH = '/api/v1/auth/csrf-token'
const ME_PATH = '/api/v1/auth/me'
const SIGN_OUT_PATH = '/api/v1/auth/sign-out'
const AUTHZ = 'https://errors.xopti/authorization'
const SESSION_EXPIRED = 'https://errors.xopti/session-expired'

describe('API transport', () => {
  it('sends an x-correlation-id on GET and POST', async () => {
    const { fn, calls } = fakeFetch((call) => {
      if (call.path === CSRF_PATH) return json(200, { token: 't1' })
      if (call.path === ME_PATH) return json(200, { username: 'a', displayName: null, permissions: [] })
      return new Response(null, { status: 204 })
    })
    const api = createApi({ fetchImpl: fn, origin: 'http://localhost' })

    await api.client.GET(ME_PATH)
    await api.client.POST(SIGN_OUT_PATH)

    const me = calls.find((c) => c.path === ME_PATH)!
    const out = calls.find((c) => c.path === SIGN_OUT_PATH)!
    expect(me.headers.get('x-correlation-id')).toBeTruthy()
    expect(out.headers.get('x-correlation-id')).toBeTruthy()
  })

  it('sends the anti-forgery token only on unsafe verbs', async () => {
    const { fn, calls } = fakeFetch((call) => {
      if (call.path === CSRF_PATH) return json(200, { token: 'tok' })
      return json(200, { username: 'a', displayName: null, permissions: [] })
    })
    const api = createApi({ fetchImpl: fn, origin: 'http://localhost' })

    await api.client.GET(ME_PATH)
    expect(calls.find((c) => c.path === ME_PATH)!.headers.get(CSRF_HEADER)).toBeNull()

    await api.client.POST(SIGN_OUT_PATH)
    expect(calls.find((c) => c.path === SIGN_OUT_PATH)!.headers.get(CSRF_HEADER)).toBe('tok')
  })

  it('shares one token fetch between concurrent unsafe requests', async () => {
    let tokenFetches = 0
    const { fn, calls } = fakeFetch(async (call) => {
      if (call.path === CSRF_PATH) {
        tokenFetches += 1
        await new Promise((r) => setTimeout(r, 5))
        return json(200, { token: `tok-${tokenFetches}` })
      }
      return new Response(null, { status: 204 })
    })
    const api = createApi({ fetchImpl: fn, origin: 'http://localhost' })

    await Promise.all([api.client.POST(SIGN_OUT_PATH), api.client.POST(SIGN_OUT_PATH), api.client.POST(SIGN_OUT_PATH)])

    expect(tokenFetches).toBe(1)
    const tokens = calls.filter((c) => c.path === SIGN_OUT_PATH).map((c) => c.headers.get(CSRF_HEADER))
    expect(new Set(tokens)).toEqual(new Set(['tok-1']))
  })

  it('refreshes the token and retries an unsafe request once on an authorization rejection', async () => {
    let issued = 0
    let attempts = 0
    const { fn, calls } = fakeFetch((call) => {
      if (call.path === CSRF_PATH) {
        issued += 1
        return json(200, { token: `tok-${issued}` })
      }
      attempts += 1
      if (attempts === 1) return problem(403, AUTHZ, { detail: 'Missing or invalid CSRF token.' })
      return new Response(null, { status: 204 })
    })
    const api = createApi({ fetchImpl: fn, origin: 'http://localhost' })

    const result = await api.client.POST(SIGN_OUT_PATH)

    expect(result.response.status).toBe(204)
    expect(issued).toBe(2)
    const posts = calls.filter((c) => c.path === SIGN_OUT_PATH)
    expect(posts).toHaveLength(2)
    expect(posts[0].headers.get(CSRF_HEADER)).toBe('tok-1')
    expect(posts[1].headers.get(CSRF_HEADER)).toBe('tok-2')
  })

  it('does not retry a second time when the rejection persists', async () => {
    const { fn, calls } = fakeFetch((call) => {
      if (call.path === CSRF_PATH) return json(200, { token: 't' })
      return problem(403, AUTHZ)
    })
    const api = createApi({ fetchImpl: fn, origin: 'http://localhost' })

    const result = await api.client.POST(SIGN_OUT_PATH)

    expect(result.response.status).toBe(403)
    expect(calls.filter((c) => c.path === SIGN_OUT_PATH)).toHaveLength(2)
  })

  it('reports session expiry to the registered handler', async () => {
    const onExpired = vi.fn()
    const { fn } = fakeFetch((call) => {
      if (call.path === ME_PATH) return problem(401, SESSION_EXPIRED)
      return json(200, {})
    })
    const api = createApi({ fetchImpl: fn, origin: 'http://localhost' })
    api.setSessionExpiredHandler(onExpired)

    await api.client.GET(ME_PATH)

    expect(onExpired).toHaveBeenCalledTimes(1)
  })

  it('does not treat a plain unauthenticated response as expiry', async () => {
    const onExpired = vi.fn()
    const { fn } = fakeFetch(() => problem(401, 'https://errors.xopti/unauthenticated'))
    const api = createApi({ fetchImpl: fn, origin: 'http://localhost' })
    api.setSessionExpiredHandler(onExpired)

    await api.client.GET(ME_PATH)

    expect(onExpired).not.toHaveBeenCalled()
  })
})
