import { expect, test } from '@playwright/test'
import { signIn } from './helpers'

test('freeze, count, approve, and post a stock take', async ({ page }) => {
  test.setTimeout(180_000)
  await page.goto('/sign-in')
  await signIn(page, 'manager')
  await expect(page.getByTestId('nav-menu')).toBeVisible()
  await page.goto('/admin/stock-take')

  await page.getByTestId('stock-take-name').locator('input').fill('E2E count')
  await page.getByTestId('stock-take-reason').locator('input').fill('e2e stock take')
  await page.getByTestId('stock-take-create').click()
  await expect(page.getByTestId('stock-take-header')).toContainText('Stock take #')

  await page.getByTestId('stock-take-csv').locator('textarea').fill('sku,qty\n30110359,8')
  await page.getByTestId('stock-take-import-reason').locator('input').fill('e2e count import')
  await page.getByTestId('stock-take-import').click()
  await expect(page.getByTestId('stock-take-import-result')).toContainText('Accepted 1 row')

  await page.getByTestId('stock-take-approval-reason').locator('input').fill('e2e approve')
  await page.getByTestId('stock-take-approve').click()
  await page.getByTestId('stock-take-posting-reason').locator('input').fill('e2e post')
  await page.getByTestId('stock-take-post').click()
  await expect(page.getByTestId('stock-take-posted')).toContainText('SJ')
})
