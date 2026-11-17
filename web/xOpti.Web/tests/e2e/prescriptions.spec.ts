import { expect, test } from '@playwright/test'
import { signIn } from './helpers'

test('enter, verify, note, and attach a prescription', async ({ page }) => {
  test.setTimeout(180_000)
  const tag = Date.now().toString(36).slice(-6)
  await page.goto('/sign-in')
  await signIn(page, 'manager')
  await expect(page.getByTestId('nav-menu')).toBeVisible()

  await page.goto('/admin/customers')
  await page.getByTestId('customer-new').click()
  await page.getByTestId('customer-full-name').locator('input').fill(`Rx Patient ${tag}`)
  await page.getByTestId('customer-phone').locator('input').fill('604555' + tag.slice(-4))
  await page.getByTestId('customer-email').locator('input').fill(`rx${tag}@example.test`)
  await page.getByTestId('customer-save').click()
  const notice = page.getByTestId('customer-notice')
  await expect(notice).toContainText('Customer')
  const customerId = Number((await notice.innerText()).match(/Customer (\d+) saved/)![1])

  await page.goto(`/admin/prescriptions?customerId=${customerId}`)
  await expect(page.getByTestId('prescription-page')).toBeVisible()
  await expect(page.getByTestId('rx-spectacle-current')).toContainText('none')

  await page.getByTestId('rx-right-sphere').locator('input').fill('1.25')
  await page.getByTestId('rx-right-cylinder').locator('input').fill('-0.5')
  await page.getByTestId('rx-right-axis').locator('input').fill('90')
  await page.getByTestId('rx-left-sphere').locator('input').fill('-1.75')
  await page.getByTestId('rx-left-cylinder').locator('input').fill('-1.25')
  await page.getByTestId('rx-left-axis').locator('input').fill('85')
  await page.getByTestId('rx-spectacle-save').click()
  await expect(page.getByTestId('rx-notice')).toContainText('immutable version')
  await expect(page.getByTestId('rx-spectacle-current')).toContainText('unverified')

  await page.getByTestId('rx-spectacle-verify').click()
  await expect(page.getByTestId('rx-notice')).toContainText('verified')
  await expect(page.getByTestId('rx-spectacle-current')).toContainText('verified')

  await page.getByTestId('rx-medical-note').locator('input').fill('allergy: none')
  await page.getByTestId('rx-medical-note-add').click()
  await expect(page.getByTestId('rx-medical-notes')).toContainText('allergy: none')

  await page.getByTestId('rx-attachment').locator('input[type=file]').setInputFiles({
    name: 'scan.pdf', mimeType: 'application/pdf', buffer: Buffer.from('%PDF-1.4 e2e'),
  })
  await page.getByTestId('rx-attachment-reason').locator('input').fill('supporting scan')
  await page.getByTestId('rx-attachment-upload').click()
  await expect(page.getByTestId('rx-attachments')).toContainText('scan.pdf')
})
