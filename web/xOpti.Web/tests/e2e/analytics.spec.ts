import { expect, test } from '@playwright/test'
import { signIn } from './helpers'

// The production build has no fixture data; with analytics enabled and no
// data endpoint yet, the screen must show its mapped error rather than a blank page.
test('analytics screen opens for an authorised user when enabled and reports the missing data source', async ({ page }) => {
  await page.goto('/sign-in')
  await signIn(page, 'manager')
  await expect(page.getByTestId('nav-menu')).toBeVisible()

  await page.getByTestId('nav-analytics').click()
  await expect(page).toHaveURL(/\/analytics$/)
  await expect(page.getByTestId('wpt-error')).toBeVisible()
})
