import { describe, expect, it, vi } from 'vitest'
import { flushPromises } from '@vue/test-utils'
import { createPinia, setActivePinia } from 'pinia'
import SpecialReportsPage from '@/features/admin/SpecialReportsPage.vue'
import { useSessionStore } from '@/stores/session'
import { mountInApp } from './support'

function authenticatedPinia() {
  const pinia = createPinia()
  setActivePinia(pinia)
  const session = useSessionStore(pinia)
  session.status = 'authenticated'
  session.identity = {
    username: 'admin',
    displayName: 'Admin',
    permissions: ['report:financial'],
  }
  return pinia
}

describe('SpecialReportsPage', () => {
  it('offers the ten legacy special report items', async () => {
    const { wrapper } = await mountInApp(SpecialReportsPage, {
      path: '/admin/special-reports',
      pinia: authenticatedPinia(),
    })
    await flushPromises()

    const options = wrapper.findComponent({ name: 'VSelect' }).props('items') as string[]
    expect(options).toEqual([
      'Bar Code Tag',
      'Claims Receipt',
      'Invoice',
      'Order',
      'Prescription - By Customer',
      'Prescription - By Order/Invoice Number',
      'Stock Adjustment',
      'Stock Received',
      'Stock Rejected',
      'Stock Take Report',
    ])
    wrapper.unmount()
  })

  it('opens the stock received prompt for Bar Code Tag', async () => {
    const { wrapper, router } = await mountInApp(SpecialReportsPage, {
      path: '/admin/special-reports',
      pinia: authenticatedPinia(),
    })
    await flushPromises()
    const push = vi.spyOn(router, 'push')

    await wrapper.get('[data-testid="special-report-ok"]').trigger('click')
    expect(document.body.querySelector('[data-testid="barcode-print-dialog"]')).not.toBeNull()
    expect(push).not.toHaveBeenCalled()

    wrapper.unmount()
  })
})
