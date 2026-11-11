import { expect, type Page } from '@playwright/test'

export const SESSION_COOKIE = 'xopti.session'

/** Demo accounts seeded by the smoke bootstrap (see tests/xOpti.Api.IntegrationTests/Support/SeedData.cs). */
export const accounts = {
  manager: { username: 'manager', password: 'Test#Passw0rd1!' },
  clerk: { username: 'clerk', password: 'Test#Passw0rd1!' },
} as const

export async function signIn(page: Page, account: keyof typeof accounts): Promise<void> {
  const { username, password } = accounts[account]
  await page.getByLabel('Username').fill(username)
  await page.getByLabel('Password').fill(password)
  await page.getByTestId('sign-in-submit').click()
}

export async function expectSignedIn(page: Page): Promise<void> {
  await expect(page.getByTestId('nav-menu')).toBeVisible()
}

/**
 * Makes the server treat the current session as expired while the browser still
 * holds a session cookie. The API then answers with the session-expired problem.
 */
export async function expireSessionCookie(page: Page): Promise<void> {
  const url = new URL(page.url())
  await page.context().addCookies([
    { name: SESSION_COOKIE, value: 'expired-by-test', domain: url.hostname, path: '/', httpOnly: true, sameSite: 'Strict' },
  ])
}

/** Records responses with status 403 (rejected anti-forgery or authorization). */
export function trackForbiddenResponses(page: Page): string[] {
  const forbidden: string[] = []
  page.on('response', (response) => {
    if (response.status() === 403) {
      forbidden.push(`${response.request().method()} ${new URL(response.url()).pathname}`)
    }
  })
  return forbidden
}

/**
 * The SPA's only protected data call in the current scope is the analytics data
 * endpoint, which the API does not implement yet (it answers 404 for any session).
 * To drive the real expiry path, the next call to that endpoint is answered with the
 * session-expired problem exactly as the API does for a protected route.
 */
export async function failNextAnalyticsCallAsExpired(page: Page): Promise<void> {
  let served = false
  await page.route('**/api/v1/analytics/olap-sales', async (route) => {
    if (served) {
      await route.fallback()
      return
    }
    served = true
    await route.fulfill({
      status: 401,
      contentType: 'application/problem+json',
      body: JSON.stringify({
        type: 'https://errors.xopti/session-expired',
        title: 'Session expired',
        status: 401,
        detail: 'The session is no longer valid; sign in again.',
        correlationId: 'e2e-expired',
      }),
    })
  })
}
