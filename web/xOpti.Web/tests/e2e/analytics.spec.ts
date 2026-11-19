import { expect, test } from '@playwright/test'
import { signIn } from './helpers'

// Analytics is enabled with a runtime licence key in the E2E stack. The route
// loads the server feed and the self-hosted WebPivotTable component.
test('analytics screen opens for an authorised user and loads the server feed', async ({ page }) => {
  await page.goto('/sign-in')
  await signIn(page, 'manager')
  await expect(page.getByTestId('nav-menu')).toBeVisible()

  await page.getByTestId('nav-analytics').click()
  await expect(page).toHaveURL(/\/analytics$/)
  await expect(page.getByTestId('analytics-page')).toBeVisible()
  await expect(page.getByTestId('wpt-view')).toBeVisible()
  await expect(page.getByTestId('analytics-view-select')).toBeVisible()
})
