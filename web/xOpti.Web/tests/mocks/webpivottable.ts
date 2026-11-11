/**
 * Test double for the `webpivottable` package. Mirrors the parts of the real
 * <web-pivot-table> contract the application uses: it dispatches `wpt:ready`
 * from connectedCallback and exposes setOptions, setWptFromDataArray, and an
 * eventBus with unsubscribe-returning `on`.
 */
type Handler = (payload?: unknown) => void

export const mockState = {
  /** Number of times the module was evaluated (i.e. the component code was requested). */
  moduleLoads: 0,
  options: [] as Record<string, unknown>[],
  rows: [] as unknown[],
  instances: 0,
}

mockState.moduleLoads += 1

class FakeWebPivotTable extends HTMLElement {
  private readonly handlers = new Map<string, Set<Handler>>()

  readonly eventBus = {
    on: (event: string, cb: Handler): (() => void) => {
      const set = this.handlers.get(event) ?? new Set<Handler>()
      set.add(cb)
      this.handlers.set(event, set)
      return () => set.delete(cb)
    },
    off: (event: string, cb: Handler): void => {
      this.handlers.get(event)?.delete(cb)
    },
    emit: (event: string, payload?: unknown): void => {
      for (const cb of this.handlers.get(event) ?? []) {
        cb(payload)
      }
    },
  }

  connectedCallback(): void {
    mockState.instances += 1
    this.dispatchEvent(new CustomEvent('wpt:ready', { bubbles: false }))
  }

  disconnectedCallback(): void {
    mockState.instances -= 1
  }

  setOptions(options: Record<string, unknown>): void {
    mockState.options.push(options)
  }

  setData(rows: unknown[]): void {
    mockState.rows = rows
  }
}

if (!customElements.get('web-pivot-table')) {
  customElements.define('web-pivot-table', FakeWebPivotTable)
}

export default FakeWebPivotTable
