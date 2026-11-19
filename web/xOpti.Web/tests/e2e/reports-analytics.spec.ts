import { expect, test } from '@playwright/test'
import { signIn } from './helpers'

test('preview, print, and export a report, then save and export an analytics view', async ({ page }) => {
  test.setTimeout(240_000)
  await page.goto('/sign-in')
  await signIn(page, 'manager')
  await expect(page.getByTestId('nav-menu')).toBeVisible()

  await page.goto('/admin/reports')
  await expect(page.getByTestId('report-page')).toBeVisible()
  await expect(page.getByTestId('report-list')).toContainText('RPT-001')
  await page.getByTestId('report-search').locator('input').fill('Customer Listing (Active)')
  await page.getByTestId('report-select-RPT-014').click()
  await page.getByTestId('report-param-AskDays').locator('input').fill('0')
  await page.getByTestId('report-param-AskZeroPurchase').locator('input').check()
  await page.getByTestId('report-preview').click()
  await expect(page.getByTestId('report-preview-table')).toContainText('Customer')

  const printed = page.waitForEvent('download')
  await page.getByTestId('report-print').click()
  expect((await printed).suggestedFilename()).toContain('RPT-014')
  await expect(page.getByTestId('report-notice')).toContainText('generated')

  const exported = page.waitForEvent('download')
  await page.getByTestId('report-export').click()
  expect((await exported).suggestedFilename()).toContain('RPT-014')
  await page.getByTestId('report-favorite').click()
  await expect(page.getByTestId('report-favorite')).toContainText('★')

  const external: string[] = []
  page.on('request', (request) => {
    if (!request.url().startsWith('http://127.0.0.1:18095')
      && !request.url().startsWith('blob:')
      && !request.url().startsWith('data:')) {
      external.push(request.url())
    }
  })

  await page.goto('/analytics')
  await expect(page.getByTestId('analytics-page')).toBeVisible()
  await expect(page.getByTestId('wpt-view')).toBeVisible()
  await page.getByTestId('analytics-from').locator('input').fill('2000-01')
  await page.getByTestId('analytics-to').locator('input').fill('2099-12')
  await page.getByTestId('analytics-load').click()
  await expect(page.getByTestId('analytics-notice')).toBeVisible()

  await page.getByTestId('analytics-save-name').locator('input').fill('E2E cost view')
  await page.getByTestId('analytics-save').click()
  await expect(page.getByTestId('analytics-notice')).toContainText('Saved analytics view')

  const analyticsExport = page.waitForEvent('download')
  await page.getByTestId('analytics-export').click()
  expect((await analyticsExport).suggestedFilename()).toContain('sales_by_cost')
  expect(external).toEqual([])
})
