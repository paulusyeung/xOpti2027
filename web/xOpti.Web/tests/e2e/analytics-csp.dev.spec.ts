import { readFileSync } from 'node:fs'
import { resolve } from 'node:path'
import { expect, test, type Page } from '@playwright/test'
import { signIn } from './helpers'

/**
 * Task 7.6: the WebPivotTable route must run under the production content security
 * policy. The production image carries no fixture data, so this runs against the
 * Vite dev server (fixture build) with the exact CSP from docker/nginx.conf applied to
 * document responses. Enable with XOPTI_E2E_DEV_SERVER=1 and XOPTI_E2E_BASE_URL=http://127.0.0.1:5173.
 */
test.skip(!process.env.XOPTI_E2E_DEV_SERVER, 'dev-server fixture check; set XOPTI_E2E_DEV_SERVER=1')

function productionCsp(): string {
  const nginx = readFileSync(resolve(process.cwd(), '../../docker/nginx.conf'), 'utf8')
  // The `/` location carries the shell policy; every location shares the same value.
  const match = nginx.match(/location \/ \{[\s\S]*?add_header Content-Security-Policy "([^"]+)"/)
  if (!match) {
    throw new Error('Content-Security-Policy not found in docker/nginx.conf')
  }
  return match[1]
}

/**
 * Vite's dev HMR socket (ws://localhost:<port>/?token=...) is blocked by the production
 * `connect-src 'self'` because the dev client targets localhost. The production build
 * opens no websocket, so this is excluded from the check and nothing else is.
 */
function isViteHmrSocket(text: string): boolean {
  return /connect-src/.test(text) && /ws:\/\/[^']+\/\?token=/.test(text)
}

async function applyProductionHeaders(page: Page, csp: string): Promise<void> {
  await page.route('**/*', async (route) => {
    const request = route.request()
    if (request.resourceType() === 'document' || request.url().endsWith('/config.json')) {
      const response = await route.fetch()
      await route.fulfill({
        response,
        headers: { ...response.headers(), 'content-security-policy': csp },
      })
      return
    }
    await route.continue()
  })
}

test('analytics component runs under the production CSP without violations or third-party requests', async ({ page }) => {
  const csp = productionCsp()
  const violations: string[] = []
  const thirdParty: string[] = []
  const baseOrigin = new URL(process.env.XOPTI_E2E_BASE_URL ?? 'http://127.0.0.1:5173').origin

  page.on('console', (message) => {
    const text = message.text()
    if (/Content Security Policy|Refused to/i.test(text) && !isViteHmrSocket(text)) {
      violations.push(text)
    }
  })
  page.on('pageerror', (error) => violations.push(`page error: ${error.message}`))
  page.on('request', (request) => {
    if (new URL(request.url()).origin !== baseOrigin) {
      thirdParty.push(request.url())
    }
  })

  await applyProductionHeaders(page, csp)
  // Analytics is enabled for this check; the licence key is a test value.
  await page.route('**/config.json', (route) =>
    route.fulfill({
      status: 200,
      contentType: 'application/json',
      body: JSON.stringify({ analyticsEnabled: true, wptLicenseKey: 'e2e-test-key' }),
    }),
  )

  await page.goto('/sign-in')
  await signIn(page, 'manager')
  await page.getByTestId('nav-analytics').click()

  await expect(page.locator('web-pivot-table')).toHaveCount(1)
  await expect(page.getByTestId('wpt-loading')).toHaveCount(0)

  // Locale resources come from this origin.
  await expect.poll(() => page.evaluate(() => performance.getEntriesByType('resource').map((e) => e.name).some((n) => n.includes('/vendor/webpivottable/locales/')))).toBe(true)

  expect(violations).toEqual([])
  expect(thirdParty).toEqual([])
})
