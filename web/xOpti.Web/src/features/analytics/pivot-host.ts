import type { WebPivotTableElement, WptDataRow, WptOptions } from 'webpivottable'
import { PIVOT_LOCALE_BASE_URL, PIVOT_READY_TIMEOUT_MS } from './config'

export interface PivotMountOptions {
  licenseKey: string
  rows: WptDataRow[]
  onPivotChanged?: () => void
}

export interface PivotHandle {
  dispose(): void
}

/**
 * Creates the <web-pivot-table> element, then loads its data. The element is
 * created and listened to before insertion because the component dispatches
 * `wpt:ready` from connectedCallback, which would otherwise be missed.
 *
 * The module is imported here (inside the analytics route chunk) so the
 * component code is requested only when the analytics screen is opened.
 */
export async function mountPivot(container: HTMLElement, options: PivotMountOptions): Promise<PivotHandle> {
  await import('webpivottable')

  const element = document.createElement('web-pivot-table') as WebPivotTableElement
  element.style.display = 'block'
  element.style.width = '100%'
  element.style.height = '600px'

  let timer: ReturnType<typeof setTimeout> | undefined
  const ready = new Promise<void>((resolve, reject) => {
    element.addEventListener('wpt:ready', () => resolve(), { once: true })
    timer = setTimeout(() => reject(new Error('Analytics component did not become ready')), PIVOT_READY_TIMEOUT_MS)
  })

  container.appendChild(element)
  try {
    await ready
  } finally {
    clearTimeout(timer)
  }

  const settings: Partial<WptOptions> = {
    locale: 'en',
    localeBaseUrl: PIVOT_LOCALE_BASE_URL,
    licenseKey: options.licenseKey,
    // AI features send data to third-party providers; they stay off for xOpti.
    ai: { enabled: false },
    // The default sample-file links point at the vendor CDN; xOpti offers only its own data.
    fileLinks: [],
  } as Partial<WptOptions>
  element.setOptions(settings)
  // setData is the documented entry point for in-memory rows (README). The package's
  // setWptFromDataArray takes (attrArray, dataArray, ...) at runtime, not (rows, options).
  element.setData(options.rows)

  const unsubscribe = element.eventBus.on('PIVOT_CHANGED', () => options.onPivotChanged?.())

  return {
    dispose() {
      unsubscribe()
      element.remove()
    },
  }
}
