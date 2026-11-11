import { describe, expect, it } from 'vitest'
import { CsrfTokenStore } from '@/api/csrf'
import { AppError } from '@/api/problems'
import { fakeFetch, json, problem } from '../support/fakeFetch'

describe('CsrfTokenStore', () => {
  it('caches the token until invalidated', async () => {
    const { fn } = fakeFetch(() => json(200, { token: 'a' }))
    const store = new CsrfTokenStore(fn)

    expect(await store.get()).toBe('a')
    expect(await store.get()).toBe('a')
    expect(fn).toHaveBeenCalledTimes(1)

    store.invalidate()
    await store.get()
    expect(fn).toHaveBeenCalledTimes(2)
  })

  it('refresh always fetches a new token', async () => {
    let n = 0
    const { fn } = fakeFetch(() => json(200, { token: `t${++n}` }))
    const store = new CsrfTokenStore(fn)

    await store.get()
    expect(await store.refresh()).toBe('t2')
    expect(await store.get()).toBe('t2')
  })

  it('surfaces a failed token fetch as an AppError', async () => {
    const { fn } = fakeFetch(() => problem(500, 'https://errors.xopti/unhandled', { correlationId: 'c-1' }))
    const store = new CsrfTokenStore(fn)

    await expect(store.get()).rejects.toBeInstanceOf(AppError)
  })

  it('keeps the token only in memory', async () => {
    const { fn } = fakeFetch(() => json(200, { token: 'secret-token' }))
    const store = new CsrfTokenStore(fn)
    await store.get()

    expect(JSON.stringify(Object.keys(localStorage))).not.toContain('secret')
    expect(sessionStorage.length).toBe(0)
  })
})
