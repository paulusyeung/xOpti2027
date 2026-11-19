<script setup lang="ts">
import { computed, onMounted, reactive, ref } from 'vue'
import { api, unwrap } from '@/api/client'
import { AppError } from '@/api/problems'

interface ParameterDefinition { name: string; type: string; required: boolean }
interface ReportEntry {
  id: string; logicalName: string; title: string; subject: string
  parameters: ParameterDefinition[]; readModel: string; layoutKey: string
  requiredPermissions: string[]; rowCap: number; criticality: string
  criticalDocument: boolean; inScope: string; signoffStatus: string
}
interface PreviewColumn { key: string; label: string; type: string }
interface Preview {
  reportId: string; title: string; columns: PreviewColumn[]
  rows: unknown[][]; truncated: boolean; appliedCap: number
  asOf: string; stale: boolean; parameters: Record<string, string | null>
}

const reports = ref<ReportEntry[]>([])
const search = ref('')
const selected = ref<ReportEntry | null>(null)
const preview = ref<Preview | null>(null)
const busy = ref(false)
const error = ref<string | null>(null)
const notice = ref<string | null>(null)
const favoriteIds = ref<string[]>(load<string[]>('xopti.report.favorites', []))
const recentIds = ref<string[]>(load<string[]>('xopti.report.recent', []))
const onlyFavorites = ref(false)
const parameters = reactive<Record<string, string>>({})

function load<T>(key: string, fallback: T): T {
  try { return JSON.parse(localStorage.getItem(key) ?? '') as T } catch { return fallback }
}
function persist(): void {
  localStorage.setItem('xopti.report.favorites', JSON.stringify(favoriteIds.value))
  localStorage.setItem('xopti.report.recent', JSON.stringify(recentIds.value))
}

const visibleReports = computed(() => reports.value.filter((entry) => {
  if (onlyFavorites.value && !favoriteIds.value.includes(entry.id)) return false
  const term = search.value.trim().toLowerCase()
  return term.length === 0 || entry.id.toLowerCase().includes(term)
    || entry.logicalName.toLowerCase().includes(term)
    || entry.title.toLowerCase().includes(term)
}))
const recentReports = computed(() => recentIds.value.map((id) =>
  reports.value.find((entry) => entry.id === id)).filter(Boolean) as ReportEntry[])

function handleError(caught: unknown): void {
  error.value = caught instanceof AppError ? caught.userMessage : 'The report request failed.'
}

function customParameters(entry: ReportEntry): ParameterDefinition[] {
  if (entry.layoutKey === 'invoice' || entry.layoutKey === 'order'
    || entry.layoutKey === 'receipt' || entry.layoutKey === 'packing-list') {
    return [{ name: 'DocumentNumber', type: 'document-number', required: true }]
  }
  if (entry.layoutKey === 'claim-receipt') {
    return [{ name: 'ClaimId', type: 'number', required: true }]
  }
  if (entry.layoutKey === 'statement') {
    return [{ name: 'CustomerId', type: 'number', required: true }]
  }
  return []
}

function select(entry: ReportEntry): void {
  selected.value = entry
  preview.value = null
  notice.value = null
  error.value = null
  Object.keys(parameters).forEach((key) => delete parameters[key])
  for (const definition of [...entry.parameters, ...customParameters(entry)]) {
    parameters[definition.name] = ''
  }
  recentIds.value = [entry.id, ...recentIds.value.filter((id) => id !== entry.id)].slice(0, 10)
  persist()
}

function parameterPayload(): Record<string, string> {
  return Object.fromEntries(Object.entries(parameters)
    .filter(([, value]) => value !== '' && value !== null && value !== undefined)
    .map(([key, value]) => [key, String(value)]))
}

async function previewReport(): Promise<void> {
  if (!selected.value) return
  busy.value = true
  error.value = null
  try {
    preview.value = await unwrap(await api.client.POST('/api/v1/reports/{reportId}/preview', {
      params: { path: { reportId: selected.value.id } },
      body: { parameters: parameterPayload() },
    })) as unknown as Preview
    notice.value = preview.value.stale
      ? 'Preview loaded from a stale read model.'
      : 'Preview loaded.'
  } catch (caught) { handleError(caught) } finally { busy.value = false }
}

async function printReport(duplicate: boolean): Promise<void> {
  if (!selected.value) return
  busy.value = true
  error.value = null
  try {
    const response = await api.request(`/api/v1/reports/${selected.value.id}/print`, {
      method: 'POST',
      headers: { 'content-type': 'application/json' },
      body: JSON.stringify({
        parameters: parameterPayload(), duplicate, terminalCode: '01',
        reason: duplicate ? 'report reprint' : 'report print',
      }),
    })
    if (!response.ok) throw new Error('print failed')
    const blob = await response.blob()
    const url = URL.createObjectURL(blob)
    const link = document.createElement('a')
    link.href = url
    link.download = `${selected.value.id}${duplicate ? '-duplicate' : ''}.pdf`
    link.click()
    URL.revokeObjectURL(url)
    notice.value = duplicate
      ? `Duplicate generated for ${selected.value.id}.`
      : `Report ${selected.value.id} generated.`
  } catch (caught) { handleError(caught) } finally { busy.value = false }
}

async function exportReport(): Promise<void> {
  if (!selected.value) return
  busy.value = true
  error.value = null
  try {
    const response = await api.request(`/api/v1/reports/${selected.value.id}/export`, {
      method: 'POST',
      headers: { 'content-type': 'application/json' },
      body: JSON.stringify({ parameters: parameterPayload(), reason: 'report export' }),
    })
    if (!response.ok) throw new Error('export failed')
    const blob = await response.blob()
    const url = URL.createObjectURL(blob)
    const link = document.createElement('a')
    link.href = url
    link.download = `${selected.value.id}.csv`
    link.click()
    URL.revokeObjectURL(url)
    notice.value = `Export generated for ${selected.value.id}.`
  } catch (caught) { handleError(caught) } finally { busy.value = false }
}

function toggleFavorite(): void {
  if (!selected.value) return
  favoriteIds.value = favoriteIds.value.includes(selected.value.id)
    ? favoriteIds.value.filter((id) => id !== selected.value!.id)
    : [...favoriteIds.value, selected.value.id]
  persist()
}

function printIndex(): void {
  window.print()
}

onMounted(async () => {
  busy.value = true
  try {
    reports.value = await unwrap(await api.client.GET('/api/v1/reports')) as unknown as ReportEntry[]
  } catch (caught) { handleError(caught) } finally { busy.value = false }
})
</script>

<template>
  <div data-testid="report-page">
    <div class="d-flex align-center mb-4 no-print">
      <h1 class="text-h5">Reports</h1>
      <v-spacer />
      <v-checkbox v-model="onlyFavorites" label="Favorites" density="compact" hide-details
        data-testid="report-only-favorites" />
      <v-btn variant="text" class="ml-2" data-testid="report-index-print"
        @click="printIndex">Print index</v-btn>
    </div>

    <v-alert v-if="error" type="error" variant="tonal" class="mb-3 no-print"
      data-testid="report-error">{{ error }}</v-alert>
    <v-alert v-if="notice" type="success" variant="tonal" class="mb-3 no-print"
      data-testid="report-notice">{{ notice }}</v-alert>

    <v-row class="no-print">
      <v-col cols="12" md="5">
        <v-card variant="outlined">
          <v-card-text>
            <v-text-field v-model="search" label="Search catalogue" density="compact"
              hide-details data-testid="report-search" />
            <p v-if="recentReports.length" class="text-caption mt-2" data-testid="report-recent">
              Recent: {{ recentReports.map((entry) => entry.id).join(', ') }}
            </p>
            <v-table density="compact" class="mt-2" data-testid="report-list">
              <thead><tr><th>ID</th><th>Report</th><th>Permission</th></tr></thead>
              <tbody>
                <tr v-for="entry in visibleReports" :key="entry.id">
                  <td>{{ entry.id }}</td>
                  <td>
                    <v-btn variant="text" size="small" :data-testid="`report-select-${entry.id}`"
                      @click="select(entry)">{{ entry.logicalName }}</v-btn>
                    <span v-if="favoriteIds.includes(entry.id)">★</span>
                  </td>
                  <td>{{ entry.requiredPermissions.join(', ') }}</td>
                </tr>
              </tbody>
            </v-table>
          </v-card-text>
        </v-card>
      </v-col>

      <v-col cols="12" md="7">
        <v-card v-if="selected" variant="outlined">
          <v-card-title>
            {{ selected.id }} · {{ selected.logicalName }}
            <v-btn size="small" variant="text" data-testid="report-favorite"
              @click="toggleFavorite">
              {{ favoriteIds.includes(selected.id) ? '★ Favorite' : '☆ Favorite' }}
            </v-btn>
          </v-card-title>
          <v-card-text>
            <p class="text-body-2">{{ selected.title }}</p>
            <p class="text-caption">
              {{ selected.readModel }} · {{ selected.layoutKey }} · {{ selected.criticality }}
              · sign-off {{ selected.signoffStatus }}
            </p>
            <div data-testid="report-params">
              <div v-for="definition in [...selected.parameters, ...customParameters(selected)]"
                :key="definition.name" class="mb-2">
                <v-checkbox v-if="definition.type === 'boolean'"
                  v-model="parameters[definition.name]" :label="definition.name" density="compact"
                  hide-details :data-testid="`report-param-${definition.name}`" />
                <v-text-field v-else v-model="parameters[definition.name]"
                  :label="definition.name + (definition.required ? ' *' : '')"
                  :type="definition.type === 'date' ? 'date' : 'text'"
                  density="compact" hide-details
                  :data-testid="`report-param-${definition.name}`" />
              </div>
            </div>
            <div class="d-flex ga-2 mt-3">
              <v-btn :loading="busy" data-testid="report-preview" @click="previewReport">Preview</v-btn>
              <v-btn color="primary" :loading="busy" data-testid="report-print"
                @click="printReport(false)">Print PDF</v-btn>
              <v-btn variant="text" :loading="busy" data-testid="report-duplicate"
                @click="printReport(true)">Duplicate</v-btn>
              <v-btn variant="text" :loading="busy" data-testid="report-export"
                @click="exportReport">Export CSV</v-btn>
            </div>
          </v-card-text>
        </v-card>
      </v-col>
    </v-row>

    <v-card v-if="preview" variant="outlined" class="mt-4" data-testid="report-preview-table">
      <v-card-title>
        {{ preview.title }}
        <span class="text-caption ml-2">As of {{ preview.asOf }}</span>
      </v-card-title>
      <v-card-text>
        <v-alert v-if="preview.stale" type="warning" variant="tonal" class="mb-2">
          Stale read model.
        </v-alert>
        <v-alert v-if="preview.truncated" type="warning" variant="tonal" class="mb-2">
          Truncated at {{ preview.appliedCap }} rows.
        </v-alert>
        <v-table density="compact">
          <thead><tr><th v-for="column in preview.columns" :key="column.key">{{ column.label }}</th></tr></thead>
          <tbody>
            <tr v-for="(row, index) in preview.rows" :key="index">
              <td v-for="(column, columnIndex) in preview.columns" :key="column.key">
                {{ row[columnIndex] ?? '' }}
              </td>
            </tr>
          </tbody>
        </v-table>
      </v-card-text>
    </v-card>
  </div>
</template>

<style>
@media print {
  .no-print { display: none !important; }
}
</style>
