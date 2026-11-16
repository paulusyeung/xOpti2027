import { expect, test } from '@playwright/test'
import { signIn } from './helpers'

test('sell, partially refund, exchange the remainder, and reprint', async ({ page }) => {
  test.setTimeout(240_000)
  await page.goto('/sign-in')
  await signIn(page, 'manager')
  await expect(page.getByTestId('nav-menu')).toBeVisible()

  await page.goto('/admin/pos/sale')
  await expect(page.getByTestId('pos-sale-page')).toBeVisible()
  await page.getByTestId('pos-sale-customer-search').locator('input').fill('Demo')
  await page.getByTestId('pos-sale-customer-find').click()
  await page.getByTestId(/^pos-sale-customer-option-/).first().click()
  await expect(page.getByTestId('pos-sale-customer-selected')).toContainText('Demo Customer')

  await page.getByTestId('pos-sale-sku-search').locator('input').fill('30110359')
  await page.getByTestId('pos-sale-sku-find').click()
  await page.getByTestId('pos-sale-sku-option-30110359').click()
  await page.getByTestId('pos-sale-line-0-qty').locator('input').fill('2')
  await page.getByTestId('pos-sale-tender').locator('input').fill('120')
  await expect(page.getByTestId('pos-sale-total')).toHaveText('111.98')
  await expect(page.getByTestId('pos-sale-change')).toHaveText('8.02')

  await page.getByTestId('pos-sale-reason').locator('input').fill('e2e counter sale')
  await page.getByTestId('pos-sale-submit').click()
  const saleNotice = page.getByTestId('pos-sale-notice')
  await expect(saleNotice).toContainText('RC')
  const invoiceNumber = (await saleNotice.innerText()).match(/RC\d{8}/)![0]
  await expect(page.getByTestId('pos-document-total').first()).toHaveText('111.98')
  await expect(page.getByTestId('pos-document-total').first()).toBeVisible()

  await page.getByTestId('pos-sale-reprint').click()
  await expect(page.getByTestId('pos-sale-reprinted')).toContainText(invoiceNumber)
  await expect(page.getByTestId('pos-document-total').last()).toHaveText('111.98')

  await page.goto('/admin/pos/refund')
  await expect(page.getByTestId('pos-refund-page')).toBeVisible()
  await page.getByTestId('pos-refund-invoice').locator('input').fill(invoiceNumber)
  await page.getByTestId('pos-refund-load').click()
  await expect(page.getByTestId('pos-refund-lines')).toContainText('30110359')

  await page.getByTestId('pos-refund-line-1-qty').locator('input').fill('1')
  await expect(page.getByTestId('pos-refund-value')).toHaveText('49.99')
  await page.getByTestId('pos-refund-reason').locator('input').fill('e2e partial refund')
  await page.getByTestId('pos-refund-submit').click()
  const refundNotice = page.getByTestId('pos-refund-notice')
  await expect(refundNotice).toContainText('RS')
  const firstRefundNumber = (await refundNotice.innerText()).match(/RS\d{8}/)![0]

  await page.goto('/admin/pos/refund')
  await page.getByTestId('pos-refund-invoice').locator('input').fill(invoiceNumber)
  await page.getByTestId('pos-refund-load').click()
  await expect(page.getByTestId('pos-refund-lines')).toContainText('30110359')
  await page.getByTestId('pos-refund-line-1-qty').locator('input').fill('1')
  await page.getByTestId('pos-refund-line-1-restock').click()
  await page.getByTestId('pos-refund-sku-search').locator('input').fill('30110359')
  await page.getByTestId('pos-refund-sku-find').click()
  await page.getByTestId('pos-refund-sku-option-30110359').click()
  await expect(page.getByTestId('pos-refund-net')).toHaveText('0.00')
  await page.getByTestId('pos-refund-reason').locator('input').fill('e2e exchange')
  await page.getByTestId('pos-refund-submit').click()
  await expect(page.getByTestId('pos-refund-notice')).toContainText('RS')
  const exchangeNotice = await page.getByTestId('pos-refund-notice').innerText()
  const exchangeNumber = exchangeNotice.match(/RS\d{8}/)![0]
  expect(exchangeNumber).not.toBe(firstRefundNumber)
  await expect(page.getByTestId('pos-document-total').first()).toHaveText('0.00')

  await page.getByTestId('pos-refund-reprint').click()
  await expect(page.getByTestId('pos-refund-reprinted')).toContainText(invoiceNumber)
  await expect(page.getByTestId('pos-document-total').last()).toHaveText('111.98')
})
