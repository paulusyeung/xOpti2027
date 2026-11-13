import { expect, test } from '@playwright/test'
import { signIn } from './helpers'

/**
 * Staff administration through the real stack: create, assign a role, force a
 * reset, activate with the token, then prove that disabling the account drops
 * an existing session at the next request.
 */
test('admin manages a staff account end to end', async ({ page, browser, request }) => {
  test.setTimeout(180_000)
  const username = `e2e${Date.now().toString(36).slice(-6)}`
  const password = 'E2e#Strong1Pass'

  await page.goto('/sign-in')
  await signIn(page, 'admin')
  await expect(page.getByTestId('nav-staff')).toBeVisible()
  await page.getByTestId('nav-staff').click()

  await expect(page.getByTestId('staff-admin-page')).toBeVisible()
  await expect(page.getByTestId('roles-panel')).toContainText('Provisional matrix')

  // Create the account; no password is accepted, only a reset token is issued.
  await page.getByTestId('staff-create-open').click()
  await page.getByTestId('staff-username').locator('input').fill(username)
  await page.getByTestId('staff-display-name').locator('input').fill('E2E Staff')
  await page.getByTestId('staff-reason').locator('input').fill('e2e create')
  await page.getByTestId('staff-dialog-submit').click()

  const row = page.getByTestId(`staff-row-${username}`)
  await expect(row).toBeVisible()
  const createToken = await page.getByTestId('staff-reset-token').locator('code').innerText()
  expect(createToken.length).toBeGreaterThan(10)

  // Assign a different role.
  await page.getByTestId(`staff-role-${username}`).click()
  await page.getByTestId('staff-role-select').click()
  await page.locator('.v-overlay-container').getByText('optician', { exact: true }).first().click()
  await page.getByTestId('staff-reason').locator('input').fill('e2e promotion')
  await page.getByTestId('staff-dialog-submit').click()
  await expect(row).toContainText('optician')

  // Force a reset and use the token to activate the account.
  await page.getByTestId(`staff-reset-${username}`).click()
  await page.getByTestId('staff-reason').locator('input').fill('e2e reset')
  await page.getByTestId('staff-dialog-submit').click()
  const resetToken = await page.getByTestId('staff-reset-token').locator('code').innerText()
  expect(resetToken.length).toBeGreaterThan(10)

  const csrfResponse = await request.get('/api/v1/auth/csrf-token')
  expect(csrfResponse.status()).toBe(200)
  const { token: csrf } = (await csrfResponse.json()) as { token: string }
  const resetResponse = await request.post('/api/v1/auth/reset-password', {
    headers: { 'X-CSRF-TOKEN': csrf },
    data: { username, token: resetToken, newPassword: password },
  })
  expect(resetResponse.status()).toBe(200)

  // The new account can sign in on a separate browser context.
  const userContext = await browser.newContext()
  const userPage = await userContext.newPage()
  await userPage.goto('/sign-in')
  await userPage.getByLabel('Username').fill(username)
  await userPage.getByLabel('Password').fill(password)
  await userPage.getByTestId('sign-in-submit').click()
  await expect(userPage.getByTestId('nav-menu')).toBeVisible()

  // Disable the account; the existing session is rejected on the next request.
  await page.getByTestId(`staff-disable-${username}`).click()
  await page.getByTestId('staff-reason').locator('input').fill('e2e disable')
  await page.getByTestId('staff-dialog-submit').click()
  await expect(page.getByTestId(`staff-row-${username}`)).toContainText('Disabled')

  await userPage.goto('/')
  await expect(userPage).toHaveURL(/\/sign-in/)
  await expect(userPage.getByLabel('Username')).toBeVisible()

  await userContext.close()
})
