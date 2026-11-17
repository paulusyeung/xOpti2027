import { expect, test } from '@playwright/test'
import { signIn } from './helpers'

test('plan, member, claim, rejection, resubmission, approval, payment, and reconciliation', async ({ page }) => {
  test.setTimeout(240_000)
  const tag = Date.now().toString(36).slice(-6)
  await page.goto('/sign-in')
  await signIn(page, 'manager')
  await expect(page.getByTestId('nav-menu')).toBeVisible()

  await page.goto('/admin/customers')
  await page.getByTestId('customer-new').click()
  await page.getByTestId('customer-full-name').locator('input').fill(`Claim Patient ${tag}`)
  await page.getByTestId('customer-phone').locator('input').fill('604666' + tag.slice(-4))
  await page.getByTestId('customer-email').locator('input').fill(`claim${tag}@example.test`)
  await page.getByTestId('customer-save').click()
  const customerNotice = page.getByTestId('customer-notice')
  await expect(customerNotice).toContainText('Customer')
  const customerId = Number((await customerNotice.innerText()).match(/Customer (\d+) saved/)![1])

  await page.goto('/admin/pos/sale')
  await page.getByTestId('pos-sale-customer-search').locator('input').fill(String(customerId))
  await page.getByTestId('pos-sale-customer-find').click()
  await page.getByTestId(`pos-sale-customer-option-${customerId}`).click()
  await page.getByTestId('pos-sale-sku-search').locator('input').fill('30110359')
  await page.getByTestId('pos-sale-sku-find').click()
  await page.getByTestId('pos-sale-sku-option-30110359').click()
  await page.getByTestId('pos-sale-payment-amount-0').locator('input').fill('60')
  await page.getByTestId('pos-sale-submit').click()
  const saleNotice = page.getByTestId('pos-sale-notice')
  await expect(saleNotice).toContainText('RC')
  const invoiceNumber = (await saleNotice.innerText()).match(/RC\d{8}/)![0]

  await page.goto('/admin/claims')
  await expect(page.getByTestId('claims-page')).toBeVisible()
  await page.getByTestId('claim-plan-code').locator('input').fill('PL' + tag.toUpperCase())
  await page.getByTestId('claim-plan-name').locator('input').fill('E2E Plan')
  await page.getByTestId('claim-plan-payer').locator('input').fill('E2E Payer')
  await page.getByTestId('claim-plan-coverage').locator('input').fill('80')
  await page.getByTestId('claim-plan-save').click()
  await expect(page.getByTestId('claims-notice')).toContainText('Plan')

  await page.getByTestId('claim-member-customer').locator('input').fill(String(customerId))
  await page.getByTestId('claim-member-number').locator('input').fill('MEM-' + tag)
  await page.getByTestId('claim-member-save').click()
  await expect(page.getByTestId('claims-notice')).toContainText('Member')
  const memberId = Number((await page.getByTestId('claims-notice').innerText()).match(/id (\d+)/)![1])

  await page.getByTestId('claim-invoice').locator('input').fill(invoiceNumber)
  await page.getByTestId('claim-member-id').locator('input').fill(String(memberId))
  await page.getByTestId('claim-rows').locator('input').fill('1')
  await page.getByTestId('claim-create').click()
  await expect(page.getByTestId('claim-detail')).toContainText('submitted')
  const claimNumber = (await page.getByTestId('claim-detail').locator('.v-card-title').innerText())
    .match(/CL\d{8}/)![0]

  await page.getByTestId('claim-reject').click()
  await expect(page.getByTestId('claim-detail')).toContainText('rejected')
  await page.getByTestId('claim-resubmit').click()
  await expect(page.getByTestId('claim-detail')).toContainText('submitted')

  await page.getByTestId('claim-approve').click()
  await expect(page.getByTestId('claim-detail')).toContainText('approved')
  await page.getByTestId('claim-payment-amount').locator('input').fill('39.9920')
  await page.getByTestId('claim-payment-reference').locator('input').fill('PAY-' + tag)
  await page.getByTestId('claim-pay').click()
  await expect(page.getByTestId('claim-detail')).toContainText('paid')

  await page.getByTestId('claim-reconcile-load').click()
  await expect(page.getByTestId('claim-reconciliation')).toContainText(claimNumber)
})
