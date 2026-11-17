import { expect, test } from '@playwright/test'
import { signIn } from './helpers'

test('enter frame and lens details and advance fulfillment', async ({ page }) => {
  test.setTimeout(180_000)
  await page.goto('/sign-in')
  await signIn(page, 'manager')
  await expect(page.getByTestId('nav-menu')).toBeVisible()

  await page.goto('/admin/pos')
  await page.getByTestId('pos-customer-search').locator('input').fill('Demo')
  await page.getByTestId('pos-customer-find').click()
  await page.getByTestId(/^pos-customer-option-/).first().click()
  await page.getByTestId('pos-sku-search').locator('input').fill('30110359')
  await page.getByTestId('pos-sku-find').click()
  await page.getByTestId('pos-sku-option-30110359').click()
  await page.getByTestId('pos-save').click()
  const notice = page.getByTestId('pos-notice')
  await expect(notice).toContainText('SA')
  const orderNumber = (await notice.innerText()).match(/SA\d{8}/)![0]

  await page.goto('/admin/optical')
  await page.getByTestId('optical-order').locator('input').fill(orderNumber)
  await page.getByTestId('optical-load').click()
  await expect(page.getByTestId('optical-status')).toContainText(orderNumber)

  await page.getByTestId('optical-frame-mode').locator('input').fill('Full rim')
  await page.getByTestId('optical-frame-eye').locator('input').fill('52')
  await page.getByTestId('optical-frame-bridge').locator('input').fill('18')
  await page.getByTestId('optical-frame-temple').locator('input').fill('140')
  await page.getByTestId('optical-lens-right-sphere').locator('input').fill('1.25')
  await page.getByTestId('optical-lens-right-cylinder').locator('input').fill('-0.5')
  await page.getByTestId('optical-lens-right-axis').locator('input').fill('90')
  await page.getByTestId('optical-lens-left-sphere').locator('input').fill('-1.75')
  await page.getByTestId('optical-lens-left-cylinder').locator('input').fill('-1.25')
  await page.getByTestId('optical-lens-left-axis').locator('input').fill('85')
  await page.getByTestId('optical-save').click()
  await expect(page.getByTestId('optical-notice')).toContainText('saved')

  await page.getByTestId('optical-status-reference').locator('input').fill('LAB-1')
  await page.getByTestId('optical-status-ordered').click()
  await expect(page.getByTestId('optical-status')).toContainText('ordered')
  await page.getByTestId('optical-status-received').click()
  await expect(page.getByTestId('optical-status')).toContainText('received')
  await page.getByTestId('optical-status-dispensed').click()
  await expect(page.getByTestId('optical-status')).toContainText('dispensed')
  await expect(page.getByTestId('optical-events')).toContainText('dispensed')
})
