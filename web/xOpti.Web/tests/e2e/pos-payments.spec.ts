import { expect, test } from '@playwright/test'
import { signIn } from './helpers'

// Requires the disposable stack to run with XOPTI_PAYMENT_TERMINAL_MODE=simulated.
test.skip(process.env.XOPTI_E2E_SIMULATED !== '1',
  'set XOPTI_E2E_SIMULATED=1 and start the API with a simulated terminal')

async function startSale(page: import('@playwright/test').Page): Promise<void> {
  await page.goto('/sign-in')
  await signIn(page, 'manager')
  await expect(page.getByTestId('nav-menu')).toBeVisible()
  await page.goto('/admin/pos/sale')
  await page.getByTestId('pos-sale-customer-search').locator('input').fill('Demo')
  await page.getByTestId('pos-sale-customer-find').click()
  await page.getByTestId(/^pos-sale-customer-option-/).first().click()
  await page.getByTestId('pos-sale-sku-search').locator('input').fill('30110359')
  await page.getByTestId('pos-sale-sku-find').click()
  await page.getByTestId('pos-sale-sku-option-30110359').click()
}

async function chooseCard(page: import('@playwright/test').Page): Promise<void> {
  await page.getByTestId('pos-sale-payment-method-0').click()
  await page.getByRole('option', { name: 'Card' }).click()
}

test('declines, times out, then posts a split tender with change', async ({ page }) => {
  test.setTimeout(240_000)
  await startSale(page)
  await expect(page.getByTestId('pos-sale-total')).toHaveText('55.99')
  await chooseCard(page)

  await page.getByTestId('pos-sale-payment-amount-0').locator('input').fill('55.99')
  await page.getByTestId('pos-sale-payment-reference-0').locator('input').fill('SIM-DECLINE')
  await page.getByTestId('pos-sale-submit').click()
  await expect(page.getByTestId('pos-sale-error')).toContainText('declined')

  await page.getByTestId('pos-sale-payment-reference-0').locator('input').fill('SIM-TIMEOUT')
  await page.getByTestId('pos-sale-submit').click()
  await expect(page.getByTestId('pos-sale-error')).toContainText('timed out')

  await page.getByTestId('pos-sale-payment-amount-0').locator('input').fill('30')
  await page.getByTestId('pos-sale-payment-reference-0').locator('input').fill('AUTH-SPLIT')
  await page.getByTestId('pos-sale-payment-add').click()
  await page.getByTestId('pos-sale-payment-amount-1').locator('input').fill('30')
  await expect(page.getByTestId('pos-sale-payment-remaining')).toHaveText('0.00')
  await expect(page.getByTestId('pos-sale-payment-change')).toHaveText('4.01')

  await page.getByTestId('pos-sale-reason').locator('input').fill('e2e split tender')
  await page.getByTestId('pos-sale-submit').click()
  await expect(page.getByTestId('pos-sale-notice')).toContainText('RC')
  await expect(page.getByTestId('pos-document-total').first()).toHaveText('55.99')
  await expect(page.getByTestId('pos-document-tenders')).toContainText('K')
  await expect(page.getByTestId('pos-document-tenders')).toContainText('C')
  await expect(page.getByTestId('pos-document-change')).toHaveText('4.01')
})
