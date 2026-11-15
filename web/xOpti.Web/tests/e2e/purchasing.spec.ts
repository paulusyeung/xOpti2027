import { expect, test } from '@playwright/test'
import { signIn } from './helpers'

test('receive, return, reprint, and supplier activity', async ({ page }) => {
  test.setTimeout(180_000)
  const lot = 'E' + Date.now().toString(36).slice(-6)

  await page.goto('/sign-in')
  await signIn(page, 'manager')
  await expect(page.getByTestId('nav-menu')).toBeVisible()
  await page.goto('/admin/purchasing')
  await expect(page.getByTestId('purchasing-page')).toBeVisible()

  await page.getByTestId('purchasing-supplier').locator('input').fill('0001')
  await page.getByTestId('line-sku-0').locator('input').fill('30110359')
  await page.getByTestId('line-lot-0').locator('input').fill(lot)
  await page.getByTestId('line-qty-0').locator('input').fill('2')
  await page.getByTestId('line-cost-0').locator('input').fill('4.3650')
  await page.getByTestId('purchasing-reason').locator('input').fill('e2e receive')
  await page.getByTestId('purchasing-submit').click()

  const posted = page.getByTestId('purchasing-posted')
  await expect(posted).toContainText('SR')
  const srNumber = (await posted.innerText()).match(/SR\d{8}/)![0]
  expect(await page.getByTestId('purchasing-posted-summary').innerText()).toContain('8.7300')

  await page.getByTestId('purchasing-mode-reject').click()
  await page.getByTestId('purchasing-original').locator('input').fill(srNumber)
  await page.getByTestId('line-sku-0').locator('input').fill('30110359')
  await page.getByTestId('line-lot-0').locator('input').fill(lot)
  await page.getByTestId('line-qty-0').locator('input').fill('1')
  await page.getByTestId('line-cost-0').locator('input').fill('4.3650')
  await page.getByTestId('purchasing-reason').locator('input').fill('e2e return')
  await page.getByTestId('purchasing-submit').click()

  await expect(posted).toContainText('RJ')
  await page.getByTestId('purchasing-reprint').click()
  await expect(page.getByTestId('purchasing-reprinted')).toBeVisible()

  await page.goto('/admin/supplier-activity')
  await page.getByTestId('supplier-code').locator('input').fill('0001')
  await page.getByTestId('supplier-from').locator('input').fill('2026-01-01')
  await page.getByTestId('supplier-to').locator('input').fill('2026-12-31')
  await page.getByTestId('supplier-load').click()

  await expect(page.getByTestId('supplier-documents')).toContainText(srNumber)
  await page.getByTestId(`supplier-reprint-${srNumber}`).click()
  await expect(page.getByTestId('supplier-document-lines')).toContainText('30110359')
  await expect(page.getByTestId('supplier-reprinted')).toBeVisible()
})
