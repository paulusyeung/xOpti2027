import { afterEach, describe, expect, it, vi } from 'vitest'
import { DOMWrapper, flushPromises } from '@vue/test-utils'
import { createPinia, setActivePinia } from 'pinia'
import { api } from '@/api/client'
import SpecialReportsPage from '@/features/admin/SpecialReportsPage.vue'
import { useSessionStore } from '@/stores/session'
import { mountInApp } from './support'

afterEach(() => vi.restoreAllMocks())

function dialogField(testId: string): DOMWrapper<Element> {
  const root = document.body.querySelector(`[data-testid="${testId}"]`)
  const element = root?.querySelector('input') ?? root?.querySelector('button') ?? root
  if (!element) throw new Error(`Barcode dialog field not rendered: ${testId}`)
  return new DOMWrapper(element)
}

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

  it('opens the PDF in a new tab and keeps the spinner until it arrives', async () => {
    let resolveResponse!: (response: Response) => void
    const pending = new Promise<Response>((resolve) => { resolveResponse = resolve })
    vi.spyOn(api, 'request').mockReturnValue(pending)
    const preview = { opener: window, focus: vi.fn() } as unknown as Window
    const open = vi.spyOn(window, 'open').mockReturnValue(preview)

    const { wrapper } = await mountInApp(SpecialReportsPage, {
      path: '/admin/special-reports',
      pinia: authenticatedPinia(),
    })
    await flushPromises()
    await wrapper.get('[data-testid="special-report-ok"]').trigger('click')
    await dialogField('barcode-from-number').setValue('34203')
    await dialogField('barcode-to-number').setValue('34215')
    await dialogField('barcode-print-submit').trigger('click')
    await flushPromises()

    expect(document.body.querySelector('[data-testid="barcode-printing"]')).not.toBeNull()
    expect(open).not.toHaveBeenCalled()

    resolveResponse(new Response(new Uint8Array([1, 2, 3]), { status: 200 }))
    await flushPromises()

    expect(open).toHaveBeenCalledWith(
      '/api/v1/special-reports/bar-code-tag/preview?fromNumber=34203&toNumber=34215',
      '_blank',
    )
    expect(document.body.querySelector('[data-testid="barcode-printing"]')).toBeNull()
    wrapper.unmount()
  })
})
