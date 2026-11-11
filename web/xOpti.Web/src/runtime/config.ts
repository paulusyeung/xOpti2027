/**
 * Runtime configuration served as /config.json by the web container's entrypoint
 * (generated from XOPTI_ANALYTICS_ENABLED and XOPTI_WPT_LICENSE_KEY). A missing,
 * unreadable, or malformed file means every optional feature is disabled.
 */
export interface RuntimeConfig {
  analyticsEnabled: boolean
  wptLicenseKey: string | null
}

export const DISABLED_CONFIG: RuntimeConfig = { analyticsEnabled: false, wptLicenseKey: null }

let current: RuntimeConfig = DISABLED_CONFIG

export function getRuntimeConfig(): RuntimeConfig {
  return current
}

export function parseRuntimeConfig(value: unknown): RuntimeConfig {
  if (!value || typeof value !== 'object') {
    return DISABLED_CONFIG
  }
  const record = value as Record<string, unknown>
  const key = typeof record.wptLicenseKey === 'string' && record.wptLicenseKey.trim() !== '' ? record.wptLicenseKey.trim() : null
  return {
    analyticsEnabled: record.analyticsEnabled === true,
    wptLicenseKey: key,
  }
}

/** Loads /config.json once at startup. Never throws; failures mean disabled. */
export async function loadRuntimeConfig(fetchImpl: typeof fetch = globalThis.fetch): Promise<RuntimeConfig> {
  try {
    const response = await fetchImpl('/config.json', { cache: 'no-store', credentials: 'same-origin' })
    const contentType = response.headers.get('content-type') ?? ''
    if (!response.ok || !contentType.includes('application/json')) {
      current = DISABLED_CONFIG
      return current
    }
    current = parseRuntimeConfig(await response.json())
  } catch {
    current = DISABLED_CONFIG
  }
  return current
}

/** Test helper. */
export function setRuntimeConfigForTests(config: RuntimeConfig): void {
  current = config
}
