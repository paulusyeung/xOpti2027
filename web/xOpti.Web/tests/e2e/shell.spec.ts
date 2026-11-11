import { expect, test } from '@playwright/test'
import { expectSignedIn, signIn } from './helpers'

test('shell serves the same origin and the runtime config is no-store', async ({ page, request }) => {
  const config = await request.get('/config.json')
  expect(config.status()).toBe(200)
  expect(config.headers()['cache-control']).toBe('no-store')

  await page.goto('/sign-in')
  await expect(page.getByTestId('sign-in-page')).toBeVisible()
  await signIn(page, 'manager')
  await expect(page.getByTestId('home-title')).toBeVisible()
})

test('unknown client route shows the not-found page', async ({ page }) => {
  await page.goto('/sign-in')
  await signIn(page, 'manager')
  await expectSignedIn(page)
  await page.goto('/no/such/page')
  await expect(page.getByTestId('not-found-page')).toBeVisible()
})
