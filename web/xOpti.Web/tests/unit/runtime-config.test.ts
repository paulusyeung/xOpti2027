import { describe, expect, it } from 'vitest'
import { DISABLED_CONFIG, loadRuntimeConfig, parseRuntimeConfig } from '@/runtime/config'

describe('runtime configuration', () => {
  it('treats a missing file as fully disabled', async () => {
    const fetchImpl = (async () => new Response('not found', { status: 404 })) as typeof fetch
    expect(await loadRuntimeConfig(fetchImpl)).toEqual(DISABLED_CONFIG)
  })

  it('treats an SPA fallback HTML response as disabled', async () => {
    const fetchImpl = (async () =>
      new Response('<!doctype html>', { status: 200, headers: { 'content-type': 'text/html' } })) as typeof fetch
    expect(await loadRuntimeConfig(fetchImpl)).toEqual(DISABLED_CONFIG)
  })

  it('treats a network failure as disabled', async () => {
    const fetchImpl = (async () => {
      throw new TypeError('offline')
    }) as typeof fetch
    expect(await loadRuntimeConfig(fetchImpl)).toEqual(DISABLED_CONFIG)
  })

  it('treats malformed JSON as disabled', async () => {
    const fetchImpl = (async () =>
      new Response('{nope', { status: 200, headers: { 'content-type': 'application/json' } })) as typeof fetch
    expect(await loadRuntimeConfig(fetchImpl)).toEqual(DISABLED_CONFIG)
  })

  it('requests the file without caching', async () => {
    let init: RequestInit | undefined
    const fetchImpl = (async (_input: RequestInfo | URL, i?: RequestInit) => {
      init = i
      return new Response('{}', { status: 200, headers: { 'content-type': 'application/json' } })
    }) as typeof fetch
    await loadRuntimeConfig(fetchImpl)
    expect(init?.cache).toBe('no-store')
  })

  it('reads enablement and a trimmed licence key', () => {
    expect(parseRuntimeConfig({ analyticsEnabled: true, wptLicenseKey: '  key-123  ' })).toEqual({
      analyticsEnabled: true,
      wptLicenseKey: 'key-123',
    })
  })

  it('treats a blank or non-string key as absent and non-true enablement as off', () => {
    expect(parseRuntimeConfig({ analyticsEnabled: 'yes', wptLicenseKey: '   ' })).toEqual({
      analyticsEnabled: false,
      wptLicenseKey: null,
    })
  })
})
