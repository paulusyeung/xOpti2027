import { defineComponent, h, ref } from 'vue'
import { afterEach, describe, expect, it } from 'vitest'
import { flushPromises } from '@vue/test-utils'
import PaymentPanel, { type TenderRow } from '@/features/pos/PaymentPanel.vue'
import { mountInApp } from './support'

const methods = [
  { code: 'C', nameShort: 'CSH', nameLong: 'Cash' },
  { code: 'K', nameShort: 'CRD', nameLong: 'Card' },
]

afterEach(() => {
  // no global stubs used
})

describe('PaymentPanel', () => {
  it('previews split tenders with cash change and card reference state', async () => {
    const Host = defineComponent({
      setup() {
        const tenders = ref<TenderRow[]>([
          { method: 'K', amount: 51.98, reference: 'AUTH-SPLIT' },
          { method: 'C', amount: 70, reference: '' },
        ])
        return () => h(PaymentPanel, {
          modelValue: tenders.value,
          'onUpdate:modelValue': (value: TenderRow[]) => { tenders.value = value },
          methods,
          total: 111.98,
          testPrefix: 'split',
        })
      },
    })

    const { wrapper } = await mountInApp(Host, { path: '/' })
    await flushPromises()
    expect(wrapper.find('[data-testid="split-payment-remaining"]').text()).toBe('0.00')
    expect(wrapper.find('[data-testid="split-payment-change"]').text()).toBe('10.00')
    expect(wrapper.find('[data-testid="split-payment-reference-hint"]').exists()).toBe(false)
    wrapper.unmount()
  })

  it('flags non-cash tenders that lack an approval reference', async () => {
    const Host = defineComponent({
      setup() {
        const tenders = ref<TenderRow[]>([{ method: 'K', amount: 56, reference: '' }])
        return () => h(PaymentPanel, {
          modelValue: tenders.value,
          'onUpdate:modelValue': (value: TenderRow[]) => { tenders.value = value },
          methods,
          total: 56,
          testPrefix: 'noref',
        })
      },
    })

    const { wrapper } = await mountInApp(Host, { path: '/' })
    await flushPromises()
    expect(wrapper.find('[data-testid="noref-payment-reference-hint"]').exists()).toBe(true)
    wrapper.unmount()
  })
})
