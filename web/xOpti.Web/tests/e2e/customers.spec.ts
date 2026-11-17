import { expect, test } from '@playwright/test'
import { signIn } from './helpers'

test('create, edit, merge, and statement customer flow', async ({ page }) => {
  test.setTimeout(180_000)
  const tag = Date.now().toString(36).slice(-6)
  const first = `Customer A ${tag}`
  const second = `Customer B ${tag}`
  const phone = '604' + String(Date.now()).slice(-7)

  await page.goto('/sign-in')
  await signIn(page, 'manager')
  await expect(page.getByTestId('nav-menu')).toBeVisible()
  await page.goto('/admin/customers')
  await expect(page.getByTestId('customer-page')).toBeVisible()

  async function create(name: string, phoneNumber: string, email: string): Promise<number> {
    await page.goto('/admin/customers')
    await expect(page.getByTestId('customer-page')).toBeVisible()
    await page.getByTestId('customer-new').click()
    await page.getByTestId('customer-full-name').locator('input').fill(name)
    await page.getByTestId('customer-phone').locator('input').fill(phoneNumber)
    await page.getByTestId('customer-email').locator('input').fill(email)
    await page.getByTestId('customer-save').click()
    const notice = page.getByTestId('customer-notice')
    await expect(notice).toContainText('Customer')
    return Number((await notice.innerText()).match(/Customer (\d+) saved/)![1])
  }

  const firstId = await create(first, phone, `a${tag}@example.test`)
  const secondPhone = phone.slice(0, -1) + String((Number(phone.slice(-1)) + 1) % 10)
  const secondId = await create(second, secondPhone, `b${tag}@example.test`)

  await page.getByTestId(`customer-select-${firstId}`).click()
  await expect(page.getByTestId('customer-account')).toContainText('Balance')
  await page.getByTestId('customer-edit').click()
  await page.getByTestId('customer-credit-limit').locator('input').fill('500')
  await page.getByTestId('customer-save').click()
  await expect(page.getByTestId('customer-notice')).toContainText('Customer')

  await page.getByTestId('customer-merge-open').click()
  await page.getByTestId('customer-merge-source').locator('input').fill(String(secondId))
  await page.getByTestId('customer-merge-target').locator('input').fill(String(firstId))
  await page.getByTestId('customer-merge-name').locator('input').fill(first)
  await page.getByTestId('customer-merge-phone').locator('input').fill(phone)
  await page.getByTestId('customer-merge-email').locator('input').fill(`a${tag}@example.test`)
  await page.getByTestId('customer-merge-reason').locator('input').fill('duplicate e2e')
  await page.getByTestId('customer-merge-submit').click()
  await expect(page.getByTestId('customer-notice'))
    .toContainText(`Merged ${secondId} into ${firstId}`)

  await page.getByTestId('customer-statement-load').click()
  await expect(page.getByTestId('customer-statement')).toContainText('Closing')
})
