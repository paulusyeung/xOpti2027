import { expect, test } from '@playwright/test'
import { accounts } from './helpers'

// Stack-level smoke through the web container's /api proxy: sign-in, branch listing,
// and a CSRF-protected state-changing request (rejected without the token).
test('api smoke: sign-in, branch listing, and CSRF enforcement through the proxy', async ({ request }) => {
  const csrf = await request.get('/api/v1/auth/csrf-token')
  expect(csrf.status()).toBe(200)
  const { token } = (await csrf.json()) as { token: string }

  const unprotected = await request.post('/api/v1/auth/sign-out')
  expect(unprotected.status()).toBe(403)

  const signIn = await request.post('/api/v1/auth/sign-in', {
    headers: { 'X-CSRF-TOKEN': token },
    data: accounts.manager,
  })
  expect(signIn.status()).toBe(200)

  const me = await request.get('/api/v1/auth/me')
  expect(me.status()).toBe(200)
  expect(((await me.json()) as { username: string }).username).toBe('manager')

  const branches = await request.get('/api/v1/branches?pageSize=3')
  expect(branches.status()).toBe(200)
  const body = (await branches.json()) as { items: unknown[] }
  expect(body.items.length).toBeGreaterThan(0)
})
