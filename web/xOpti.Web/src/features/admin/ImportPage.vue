<script setup lang="ts">
import { computed, reactive, ref } from 'vue'
import { api, unwrap } from '@/api/client'
import { AppError } from '@/api/problems'

interface ImportRowError { row: number; field: string; message: string }
interface ImportResult {
  kind: string
  dryRun: boolean
  created: number
  updated: number
  skipped: number
  errors: ImportRowError[]
  resumeFrom: number | null
}

const kinds = ['Sku', 'Supplier', 'Brand'] as const
const form = reactive({ kind: 'Sku' as (typeof kinds)[number], csv: '', reason: '' })
const result = ref<ImportResult | null>(null)
const loading = ref(false)
const forbidden = ref(false)
const message = ref<string | null>(null)
const downloadUrl = computed(() => {
  if (!result.value || result.value.errors.length === 0) return null
  const csv = ['row,field,message', ...result.value.errors.map((error) =>
    `${error.row},"${error.field}","${error.message.replaceAll('"', '""')}"`)].join('\n')
  return URL.createObjectURL(new Blob([csv], { type: 'text/csv' }))
})

async function run(dryRun: boolean): Promise<void> {
  loading.value = true
  message.value = null
  try {
    result.value = await unwrap(
      await api.client.POST('/api/v1/admin/import', {
        body: { kind: form.kind, csv: form.csv, dryRun, reason: form.reason },
      }),
    ) as ImportResult
    if (result.value.errors.length > 0) {
      message.value = `Import stopped at row ${result.value.resumeFrom}; nothing was written.`
    } else {
      message.value = dryRun
        ? 'Dry run complete; nothing was written.'
        : `Import committed: ${result.value.created} created, ${result.value.updated} updated.`
    }
  } catch (error) {
    if (error instanceof AppError) {
      forbidden.value = error.kind === 'authorization' || error.kind === 'unauthenticated'
      message.value = error.userMessage
    } else {
      message.value = 'The import request failed.'
    }
  } finally {
    loading.value = false
  }
}

function onFile(event: Event): void {
  const file = (event.target as HTMLInputElement).files?.[0]
  if (!file) return
  const reader = new FileReader()
  reader.onload = () => { form.csv = String(reader.result ?? '') }
  reader.readAsText(file)
}
</script>

<template>
  <div data-testid="import-page">
    <h1 class="text-h5 mb-4">Master-data import</h1>

    <v-alert v-if="forbidden" type="error" variant="tonal" data-testid="import-forbidden">
      You do not have permission to import master data.
    </v-alert>

    <v-card variant="outlined" class="mb-4">
      <v-card-text>
        <v-select v-model="form.kind" :items="kinds" label="Type" data-testid="import-kind" />
        <v-file-input label="CSV file" accept=".csv,text/csv" data-testid="import-file" @change="onFile" />
        <v-textarea v-model="form.csv" label="CSV content" rows="6" data-testid="import-csv" />
        <v-text-field v-model="form.reason" label="Reason" data-testid="import-reason" />
        <div class="d-flex ga-2">
          <v-btn variant="tonal" data-testid="import-dry-run" :loading="loading" @click="run(true)">
            Dry run
          </v-btn>
          <v-btn color="primary" data-testid="import-confirm" :loading="loading" @click="run(false)">
            Confirm import
          </v-btn>
        </div>
      </v-card-text>
    </v-card>

    <v-alert v-if="message" type="info" variant="tonal" class="mb-4" data-testid="import-message">
      {{ message }}
    </v-alert>

    <v-card v-if="result" variant="outlined" data-testid="import-result">
      <v-card-title>
        {{ result.dryRun ? 'Dry-run result' : 'Import result' }}
      </v-card-title>
      <v-card-text>
        <p data-testid="import-counts">
          Created: {{ result.created }} · Updated: {{ result.updated }} · Skipped: {{ result.skipped }}
        </p>
        <v-table v-if="result.errors.length > 0" data-testid="import-errors">
          <thead><tr><th>Row</th><th>Field</th><th>Message</th></tr></thead>
          <tbody>
            <tr v-for="error in result.errors" :key="`${error.row}-${error.field}`">
              <td>{{ error.row }}</td><td>{{ error.field }}</td><td>{{ error.message }}</td>
            </tr>
          </tbody>
        </v-table>
        <a v-if="downloadUrl" :href="downloadUrl" download="import-errors.csv"
          data-testid="import-download">Download error report</a>
      </v-card-text>
    </v-card>
  </div>
</template>
