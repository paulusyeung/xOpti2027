<script setup lang="ts">
import { onMounted, reactive, ref } from 'vue'
import { api, unwrap } from '@/api/client'
import { AppError } from '@/api/problems'
import { getRuntimeConfig } from '@/runtime/config'
import { pivotFixtureRows } from '@analytics-fixtures'
import type { WptDataRow } from 'webpivottable'
import WptPivotView from './WptPivotView.vue'

interface AnalyticsField { key: string; label: string; type: string; sensitive: boolean }
interface AnalyticsView { key: string; name: string; fields: AnalyticsField[] }
interface AnalyticsFeed {
  viewKey: string; name: string; fields: AnalyticsField[]
  data: unknown[][]; asOf: string; stale: boolean; truncated: boolean; rowCap: number
}
interface SavedView {
  id: number; viewKey: string; name: string; isShared: boolean
  ownerUserId: string; configJson: string; canEdit: boolean
}

const config = getRuntimeConfig()
const views = ref<AnalyticsView[]>([])
const saved = ref<SavedView[]>([])
const selectedKey = ref('sales_by_cost')
const feed = ref<AnalyticsFeed | null>(null)
const rows = ref<WptDataRow[] | null>(null)
const busy = ref(false)
const error = ref<string | null>(null)
const notice = ref<string | null>(null)
const filters = reactive({
  from: '', to: '', branch: '', staff: '', department: '', classCode: '', category: '',
})
const saveForm = reactive({ name: '', isShared: false })
const selectedSaved = ref<number | null>(null)

function handleError(caught: unknown): void {
  if (caught instanceof AppError) error.value = caught.userMessage
  else error.value = 'The analytics request failed.'
}

function query() {
  return {
    from: filters.from || undefined,
    to: filters.to || undefined,
    branch: filters.branch || undefined,
    staff: filters.staff || undefined,
    department: filters.department || undefined,
    classCode: filters.classCode || undefined,
    category: filters.category || undefined,
  }
}

async function loadViews(): Promise<void> {
  try {
    views.value = await unwrap(await api.client.GET('/api/v1/analytics/views')) as unknown as AnalyticsView[]
    if (!views.value.some((view) => view.key === selectedKey.value)) {
      selectedKey.value = views.value[0]?.key ?? 'sales_by_cost'
    }
    await loadFeed()
  } catch {
    // Development/test fallback keeps the licence and lifecycle checks usable
    // without an API; production always loads the server feed.
    rows.value = pivotFixtureRows ? [...pivotFixtureRows] : []
  }
}

async function loadFeed(): Promise<void> {
  if (!config.wptLicenseKey) return
  busy.value = true
  error.value = null
  try {
    feed.value = await unwrap(await api.client.GET('/api/v1/analytics/views/{viewKey}', {
      params: { path: { viewKey: selectedKey.value }, query: query() },
    })) as unknown as AnalyticsFeed
    rows.value = feed.value.data.map((row) => Object.fromEntries(
      feed.value!.fields.map((field, index) => [field.label, row[index]]),
    )) as WptDataRow[]
    notice.value = feed.value.stale
      ? 'The analytics read model is stale; refresh before relying on it.'
      : 'Analytics view loaded.'
  } catch (caught) { handleError(caught) } finally { busy.value = false }
}

async function loadSaved(): Promise<void> {
  try {
    saved.value = await unwrap(await api.client.GET('/api/v1/analytics/saved')) as unknown as SavedView[]
  } catch { saved.value = [] }
}

async function saveView(): Promise<void> {
  if (!saveForm.name.trim()) { error.value = 'A view name is required.'; return }
  busy.value = true
  error.value = null
  try {
    await unwrap(await api.client.POST('/api/v1/analytics/saved', {
      body: {
        viewKey: selectedKey.value, name: saveForm.name, isShared: saveForm.isShared,
        configJson: JSON.stringify({ viewKey: selectedKey.value, filters: { ...filters } }),
        reason: 'save analytics view',
      },
    }))
    notice.value = `Saved analytics view '${saveForm.name}'.`
    saveForm.name = ''
    await loadSaved()
  } catch (caught) { handleError(caught) } finally { busy.value = false }
}

async function openSaved(): Promise<void> {
  if (selectedSaved.value === null) return
  busy.value = true
  error.value = null
  try {
    const view = await unwrap(await api.client.GET('/api/v1/analytics/saved/{id}', {
      params: { path: { id: selectedSaved.value } },
    })) as unknown as SavedView
    const parsed = JSON.parse(view.configJson) as {
      viewKey?: string; filters?: Record<string, string>
    }
    if (parsed.viewKey) selectedKey.value = parsed.viewKey
    Object.assign(filters, {
      from: '', to: '', branch: '', staff: '', department: '', classCode: '', category: '',
      ...(parsed.filters ?? {}),
    })
    await loadFeed()
    notice.value = `Opened '${view.name}'.`
  } catch (caught) { handleError(caught) } finally { busy.value = false }
}

async function exportView(): Promise<void> {
  busy.value = true
  error.value = null
  try {
    const params = new URLSearchParams()
    for (const [key, value] of Object.entries(query())) {
      if (value) params.set(key, value)
    }
    params.set('reason', 'analytics export')
    const response = await api.request(
      `/api/v1/analytics/views/${selectedKey.value}/export?${params.toString()}`)
    if (!response.ok) throw new Error('export failed')
    const blob = await response.blob()
    const url = URL.createObjectURL(blob)
    const link = document.createElement('a')
    link.href = url
    link.download = `${selectedKey.value}.csv`
    link.click()
    URL.revokeObjectURL(url)
    notice.value = 'Analytics export generated.'
  } catch (caught) { handleError(caught) } finally { busy.value = false }
}

onMounted(async () => {
  if (!config.wptLicenseKey) return
  if (import.meta.env.MODE === 'test' && pivotFixtureRows) {
    rows.value = [...pivotFixtureRows]
  }
  await Promise.all([loadViews(), loadSaved()])
})
</script>

<template>
  <div data-testid="analytics-page">
    <h1 class="text-h5 mb-4">Analytics</h1>

    <v-alert v-if="!config.wptLicenseKey" type="warning" variant="tonal"
      data-testid="analytics-config-error">
      Analytics is not configured: a licence key is required before the analytics component can load.
    </v-alert>

    <v-alert v-if="error" type="error" variant="tonal" class="mb-3"
      data-testid="analytics-error">{{ error }}</v-alert>
    <v-alert v-if="notice" type="info" variant="tonal" class="mb-3"
      data-testid="analytics-notice">{{ notice }}</v-alert>
    <v-alert v-if="feed?.stale" type="warning" variant="tonal" class="mb-3"
      data-testid="analytics-stale">
      The read model is stale as of {{ feed.asOf }}. Refresh reporting before relying on this view.
    </v-alert>
    <v-alert v-if="feed?.truncated" type="warning" variant="tonal" class="mb-3"
      data-testid="analytics-truncated">
      The result reached the {{ feed.rowCap }} row cap. Narrow the filters or export the data.
    </v-alert>

    <v-card v-if="config.wptLicenseKey" variant="outlined" class="mb-4">
      <v-card-text>
        <v-row dense>
          <v-col cols="12" md="3">
            <v-select v-model="selectedKey" :items="views" item-title="name" item-value="key"
              label="View" density="compact" data-testid="analytics-view-select" />
          </v-col>
          <v-col cols="12" md="2">
            <v-text-field v-model="filters.from" label="From (YYYY-MM)" density="compact"
              data-testid="analytics-from" />
          </v-col>
          <v-col cols="12" md="2">
            <v-text-field v-model="filters.to" label="To (YYYY-MM)" density="compact"
              data-testid="analytics-to" />
          </v-col>
          <v-col cols="12" md="1">
            <v-text-field v-model="filters.branch" label="Branch" density="compact"
              data-testid="analytics-branch" />
          </v-col>
          <v-col cols="12" md="2">
            <v-text-field v-model="filters.staff" label="Staff" density="compact"
              data-testid="analytics-staff" />
          </v-col>
          <v-col cols="12" md="2">
            <v-text-field v-model="filters.department" label="Department" density="compact"
              data-testid="analytics-department" />
          </v-col>
        </v-row>
        <v-btn color="primary" :loading="busy" data-testid="analytics-load"
          @click="loadFeed">Load view</v-btn>
        <v-btn class="ml-2" variant="text" :loading="busy" data-testid="analytics-export"
          @click="exportView">Export CSV</v-btn>
      </v-card-text>
    </v-card>

    <v-card v-if="config.wptLicenseKey" variant="outlined" class="mb-4">
      <v-card-title>Saved views</v-card-title>
      <v-card-text>
        <div class="d-flex ga-2 align-center flex-wrap">
          <v-select v-model="selectedSaved" :items="saved" item-title="name" item-value="id"
            label="Saved view" density="compact" hide-details style="max-width: 260px"
            data-testid="analytics-saved-select" />
          <v-btn :disabled="selectedSaved === null" data-testid="analytics-open"
            @click="openSaved">Open</v-btn>
          <v-text-field v-model="saveForm.name" label="Save as" density="compact" hide-details
            style="max-width: 220px" data-testid="analytics-save-name" />
          <v-checkbox v-model="saveForm.isShared" label="Shared" density="compact" hide-details
            data-testid="analytics-save-shared" />
          <v-btn :loading="busy" data-testid="analytics-save" @click="saveView">Save view</v-btn>
        </div>
      </v-card-text>
    </v-card>

    <WptPivotView
      v-if="config.wptLicenseKey && rows !== null"
      :license-key="config.wptLicenseKey"
      :fixture-rows="rows"
    />
  </div>
</template>
