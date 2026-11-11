<script setup lang="ts">
import { onBeforeUnmount, onMounted, ref } from 'vue'
import type { WptDataRow } from 'webpivottable'
import { api } from '@/api/client'
import { appErrorFromResponse, AppError } from '@/api/problems'
import { ANALYTICS_DATA_URL } from './config'
import { mountPivot, type PivotHandle } from './pivot-host'

const props = withDefaults(
  defineProps<{
    licenseKey: string
    /** Development/test rows; when absent the component loads from the API. */
    fixtureRows?: WptDataRow[] | null
    /** Same-origin endpoint returning pivot-ready rows (an array, or { data: [] }). */
    dataUrl?: string
  }>(),
  { fixtureRows: null, dataUrl: ANALYTICS_DATA_URL },
)

const host = ref<HTMLElement | null>(null)
const loading = ref(true)
const error = ref<string | null>(null)
let handle: PivotHandle | null = null
let disposed = false

/** Loads pivot-ready rows from the same-origin API, mapping problems to AppError. */
async function loadRowsFromApi(): Promise<WptDataRow[]> {
  const response = await api.request(props.dataUrl, { headers: { Accept: 'application/json' } })
  if (!response.ok) {
    throw await appErrorFromResponse(response, null)
  }
  const body = (await response.json()) as WptDataRow[] | { data?: WptDataRow[] }
  return Array.isArray(body) ? body : (body.data ?? [])
}

onMounted(async () => {
  try {
    const rows = props.fixtureRows ?? (await loadRowsFromApi())
    if (disposed || !host.value) {
      return
    }
    const mounted = await mountPivot(host.value, {
      licenseKey: props.licenseKey,
      rows,
    })
    if (disposed) {
      // Unmounted while the component was loading: release immediately.
      mounted.dispose()
      return
    }
    handle = mounted
  } catch (cause) {
    if (cause instanceof AppError) {
      if (!disposed) {
        error.value = cause.userMessage
      }
    } else {
      // Not a problem response: log the cause for support, show fixed copy.
      console.error('Analytics component failed to start', cause)
      if (!disposed) {
        error.value = 'The analytics component could not be loaded.'
      }
    }
  } finally {
    if (!disposed) {
      loading.value = false
    }
  }
})

onBeforeUnmount(() => {
  disposed = true
  handle?.dispose()
  handle = null
})
</script>

<template>
  <div data-testid="wpt-view">
    <v-alert v-if="error" type="error" variant="tonal" data-testid="wpt-error">{{ error }}</v-alert>
    <v-progress-linear v-if="loading && !error" indeterminate color="primary" data-testid="wpt-loading" />
    <div ref="host" data-testid="wpt-host" />
  </div>
</template>
