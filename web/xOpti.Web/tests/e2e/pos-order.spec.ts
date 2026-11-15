import { expect, test } from '@playwright/test'
import { signIn } from './helpers'

test('enter, save, and resume a sale order', async ({ page }) => {
  test.setTimeout(180_000)
  await page.goto('/sign-in')
  await signIn(page, 'manager')
  await expect(page.getByTestId('nav-menu')).toBeVisible()
  await page.goto('/admin/pos')
  await expect(page.getByTestId('pos-order-page')).toBeVisible()

  await page.getByTestId('pos-customer-search').locator('input').fill('Demo')
  await page.getByTestId('pos-customer-find').click()
  await page.getByTestId(/^pos-customer-option-/).first().click()
  await expect(page.getByTestId('pos-customer-selected')).toContainText('Demo Customer')

  await page.getByTestId('pos-sku-search').locator('input').fill('30110359')
  await page.getByTestId('pos-sku-find').click()
  await page.getByTestId('pos-sku-option-30110359').click()

  await page.getByTestId('pos-line-0-qty').locator('input').fill('2')
  await page.getByTestId('pos-line-0-discount').locator('input').fill('5')
  await expect(page.getByTestId('pos-total')).toHaveText('106.38')

  await page.getByTestId('pos-reason').locator('input').fill('e2e order entry')
  await page.getByTestId('pos-save').click()

  const notice = page.getByTestId('pos-notice')
  await expect(notice).toContainText('SA')
  const orderNumber = (await notice.innerText()).match(/SA\d{8}/)![0]

  await page.reload()
  await expect(page.getByTestId('pos-order-page')).toBeVisible()
  await page.getByTestId(`pos-resume-${orderNumber}`).click()
  await expect(page.getByTestId('pos-lines')).toContainText('30110359')
  await expect(page.getByTestId('pos-line-0-qty').locator('input')).toHaveValue('2')
  await expect(page.getByTestId('pos-line-0-discount').locator('input')).toHaveValue('5')
  await expect(page.getByTestId('pos-total')).toHaveText('106.38')
})
