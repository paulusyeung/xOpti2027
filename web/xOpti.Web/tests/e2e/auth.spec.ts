import { expect, test } from '@playwright/test'
import { expectSignedIn, expireSessionCookie, failNextAnalyticsCallAsExpired, signIn, trackForbiddenResponses } from './helpers'

test('anonymous deep link returns to the requested screen after sign-in', async ({ page }) => {
  await page.goto('/analytics')
  await expect(page).toHaveURL(/\/sign-in\?redirect=%2Fanalytics|\/sign-in\?redirect=\/analytics/)

  await signIn(page, 'manager')

  await expect(page).toHaveURL(/\/analytics$/)
  await expect(page.getByRole('heading', { name: 'Analytics' })).toBeVisible()
})

test('signed-in user without the permission is sent to the forbidden page and sees no analytics entry', async ({ page }) => {
  await page.goto('/sign-in')
  await signIn(page, 'clerk')
  await expectSignedIn(page)

  await expect(page.getByTestId('nav-analytics')).toHaveCount(0)

  await page.goto('/analytics')
  await expect(page.getByTestId('forbidden-page')).toBeVisible()
  await expect(page).toHaveURL(/\/forbidden$/)
})

test('sign-out then browser back never shows protected content', async ({ page }) => {
  await page.goto('/sign-in')
  await signIn(page, 'manager')
  await expectSignedIn(page)
  // Create a protected history entry so Back returns to a protected screen.
  await page.getByTestId('nav-analytics').click()
  await expect(page).toHaveURL(/\/analytics$/)

  await page.getByTestId('sign-out').click()
  await expect(page).toHaveURL(/\/sign-in/)

  await page.goBack()
  await expect(page).toHaveURL(/\/sign-in/)
  await expect(page.getByTestId('nav-menu')).toHaveCount(0)
  await expect(page.getByTestId('analytics-config-error')).toHaveCount(0)
  await expect(page.getByTestId('home-title')).toHaveCount(0)
})

test('sign-in and sign-out complete without a rejected anti-forgery request', async ({ page }) => {
  const forbidden = trackForbiddenResponses(page)

  await page.goto('/sign-in')
  await signIn(page, 'manager')
  await expectSignedIn(page)
  await page.getByTestId('sign-out').click()
  await expect(page).toHaveURL(/\/sign-in/)

  expect(forbidden).toEqual([])
})

test('session expiry shows the sign-in dialog and keeps the route mounted; same user resumes', async ({ page }) => {
  await page.goto('/sign-in')
  await signIn(page, 'manager')
  await expectSignedIn(page)

  await page.getByTestId('nav-home').click()
  await expect(page.getByTestId('home-title')).toBeVisible()

  await failNextAnalyticsCallAsExpired(page)
  await expireSessionCookie(page)
  await page.getByTestId('nav-analytics').click()

  const dialog = page.getByTestId('session-expired-dialog')
  await expect(dialog).toBeVisible()
  await expect(page).toHaveURL(/\/analytics$/)
  await expect(page.getByTestId('nav-menu')).toBeVisible()

  await dialog.getByLabel('Password').fill('Test#Passw0rd1!')
  await dialog.getByTestId('sign-in-submit').click()

  await expect(dialog).toBeHidden()
  await expect(page).toHaveURL(/\/analytics$/)
})

test('session expiry followed by a different user purges state and goes home', async ({ page }) => {
  await page.goto('/sign-in')
  await signIn(page, 'manager')
  await expectSignedIn(page)

  await page.getByTestId('nav-home').click()
  await failNextAnalyticsCallAsExpired(page)
  await expireSessionCookie(page)
  await page.getByTestId('nav-analytics').click()

  const dialog = page.getByTestId('session-expired-dialog')
  await expect(dialog).toBeVisible()
  await dialog.getByLabel('Username').fill('clerk')
  await dialog.getByLabel('Password').fill('Test#Passw0rd1!')
  await dialog.getByTestId('sign-in-submit').click()

  await expect(page).toHaveURL(/\/$/)
  await expect(page.getByTestId('home-title')).toContainText('clerk')
})
