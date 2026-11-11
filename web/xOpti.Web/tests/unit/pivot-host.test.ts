import { beforeEach, describe, expect, it } from 'vitest'
import { mountPivot } from '@/features/analytics/pivot-host'
import { mockState } from '../mocks/webpivottable'

describe('pivot host', () => {
  let container: HTMLElement

  beforeEach(() => {
    container = document.createElement('div')
    document.body.appendChild(container)
    mockState.options = []
    mockState.rows = []
  })

  it('configures licence, self-hosted locales, AI off, and no vendor sample links before loading data', async () => {
    const handle = await mountPivot(container, { licenseKey: 'KEY-1', rows: [{ a: 1 }] })

    const settings = mockState.options.at(-1)!
    expect(settings.licenseKey).toBe('KEY-1')
    expect(settings.localeBaseUrl).toBe('/vendor/webpivottable/locales')
    expect(settings.ai).toEqual({ enabled: false })
    expect(settings.fileLinks).toEqual([])
    expect(mockState.rows).toEqual([{ a: 1 }])
    handle.dispose()
  })

  it('removes the element and unsubscribes on dispose', async () => {
    const handle = await mountPivot(container, { licenseKey: 'K', rows: [] })
    expect(container.querySelector('web-pivot-table')).not.toBeNull()

    handle.dispose()
    expect(container.querySelector('web-pivot-table')).toBeNull()
  })

  it('delivers each event to its handler exactly once per mount', async () => {
    let calls = 0
    const first = await mountPivot(container, { licenseKey: 'K', rows: [], onPivotChanged: () => calls++ })
    first.dispose()

    const second = await mountPivot(container, { licenseKey: 'K', rows: [], onPivotChanged: () => calls++ })
    const element = container.querySelector('web-pivot-table') as HTMLElement & {
      eventBus: { emit(event: string): void }
    }
    element.eventBus.emit('PIVOT_CHANGED')

    expect(calls).toBe(1)
    second.dispose()
  })
})
