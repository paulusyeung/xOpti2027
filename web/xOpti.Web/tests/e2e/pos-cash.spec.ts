import { expect, test } from '@playwright/test'
import { signIn } from './helpers'

test('open a drawer, associate a sale, record paid-out, close with variance, and finalize', async ({ page }) => {
  test.setTimeout(240_000)
  await page.goto('/sign-in')
  await signIn(page, 'manager')
  await expect(page.getByTestId('nav-menu')).toBeVisible()

  await page.goto('/admin/pos/cash')
  await expect(page.getByTestId('cash-page')).toBeVisible()
  await page.getByTestId('cash-terminal').locator('input').fill('01')
  await page.getByTestId('cash-float').locator('input').fill('100')
  await page.getByTestId('cash-open').click()
  await expect(page.getByTestId('cash-notice')).toContainText('Opened')
  await expect(page.getByTestId('cash-expected')).toContainText('100.00')

  await page.goto('/admin/pos/sale')
  await expect(page.getByTestId('pos-sale-page')).toBeVisible()
  await expect(page.getByTestId('pos-sale-session')).toContainText('01')
  await page.getByTestId('pos-sale-customer-search').locator('input').fill('Demo')
  await page.getByTestId('pos-sale-customer-find').click()
  await page.getByTestId(/^pos-sale-customer-option-/).first().click()
  await page.getByTestId('pos-sale-sku-search').locator('input').fill('30110359')
  await page.getByTestId('pos-sale-sku-find').click()
  await page.getByTestId('pos-sale-sku-option-30110359').click()
  await page.getByTestId('pos-sale-payment-amount-0').locator('input').fill('60')
  await page.getByTestId('pos-sale-reason').locator('input').fill('cash drawer sale')
  await page.getByTestId('pos-sale-submit').click()
  await expect(page.getByTestId('pos-sale-notice')).toContainText('RC')
  const invoiceNumber = (await page.getByTestId('pos-sale-notice').innerText()).match(/RC\d{8}/)![0]

  await page.goto('/admin/pos/cash')
  await expect(page.getByTestId('cash-expected')).toContainText('155.99')

  await page.getByTestId('cash-movement-amount').locator('input').fill('5')
  await page.getByTestId('cash-movement-reason').locator('input').fill('petty cash')
  await page.getByTestId('cash-movement-destination').locator('input').fill('EXP-1')
  await page.getByTestId('cash-movement-submit').click()
  await expect(page.getByTestId('cash-movements')).toContainText('paid-out')
  await expect(page.getByTestId('cash-expected')).toContainText('150.99')

  await page.getByTestId('cash-close-count').locator('input').fill('145')
  await page.getByTestId('cash-variance-reason').locator('input').fill('till short')
  await page.getByTestId('cash-close-submit').click()
  await expect(page.getByTestId('cash-notice')).toContainText('-5.99')

  await page.getByTestId('cash-finalize').click()
  await expect(page.getByTestId('cash-journal-status')).toContainText('final')
  await expect(page.getByTestId('cash-journal-totals')).toContainText('Sales 49.99')
  await expect(page.getByTestId('cash-journal-totals')).toContainText('Cash 55.99')
  await expect(page.getByTestId('cash-journal-totals')).toContainText('Paid out 5.00')
  await expect(page.getByTestId('cash-journal-variance')).toContainText('-5.99')
  await expect(page.getByTestId('cash-journal-documents')).toContainText(invoiceNumber)
})
