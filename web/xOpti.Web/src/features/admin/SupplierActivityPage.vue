<script setup lang="ts">
import { reactive, ref } from 'vue'
import { api, unwrap } from '@/api/client'
import { AppError } from '@/api/problems'

interface Activity {
  supplierCode: string; from: string; to: string
  receiptCount: number; returnCount: number; receiptCost: number; returnCost: number
  netCost: number; taxTotal: number; documentNumbers: string[]; mismatches: string[]
}
interface Document {
  txNumber: string; txType: string; controlNumber: string; dateOfEntry: string
  totalCost: number; taxA: number; taxB: number; totalAmount: number; reprint: boolean
  lines: Array<{ rowNo: number; sku: string; qty: number; unitCost: number; amount: number }>
}

const filters = reactive({ supplier: '', from: '2026-11-01', to: '2026-11-30' })
const activity = ref<Activity | null>(null)
const document = ref<Document | null>(null)
const reprintSeen = ref(false)
const busy = ref(false)
const forbidden = ref(false)
const error = ref<string | null>(null)

function handleError(caught: unknown): void {
  if (caught instanceof AppError) {
    forbidden.value = caught.kind === 'authorization' || caught.kind === 'unauthenticated'
    error.value = caught.userMessage
  } else error.value = 'The request failed.'
}

async function load(): Promise<void> {
  busy.value = true; error.value = null; document.value = null; reprintSeen.value = false
  try {
    activity.value = (await unwrap(await api.client.GET('/api/v1/purchasing/suppliers/{code}/activity', {
      params: { path: { code: filters.supplier }, query: { from: filters.from, to: filters.to } },
    }))) as Activity
  } catch (caught) { handleError(caught) } finally { busy.value = false }
}

async function open(txNumber: string, reprint = false): Promise<void> {
  busy.value = true; error.value = null
  try {
    document.value = (await unwrap(await api.client.GET('/api/v1/purchasing/documents/{txNumber}', {
      params: { path: { txNumber } },
    }))) as Document
    if (reprint) reprintSeen.value = true
  } catch (caught) { handleError(caught) } finally { busy.value = false }
}
</script>

<template>
  <div data-testid="supplier-activity-page">
    <h1 class="text-h5 mb-4">Supplier activity</h1>
    <v-alert v-if="forbidden" type="error" variant="tonal" data-testid="supplier-forbidden">
      You do not have permission to view supplier activity.
    </v-alert>
    <v-alert v-else-if="error" type="error" variant="tonal" class="mb-4" data-testid="supplier-error">
      {{ error }}
    </v-alert>

    <div class="d-flex flex-wrap ga-3 mb-4">
      <v-text-field v-model="filters.supplier" label="Supplier code" data-testid="supplier-code"
        style="max-width: 180px" />
      <v-text-field v-model="filters.from" label="From" data-testid="supplier-from" style="max-width: 180px" />
      <v-text-field v-model="filters.to" label="To" data-testid="supplier-to" style="max-width: 180px" />
      <v-btn color="primary" data-testid="supplier-load" :loading="busy" @click="load">Load</v-btn>
    </div>

    <v-card v-if="activity" variant="outlined" class="mb-4" data-testid="supplier-activity">
      <v-card-text>
        <p data-testid="supplier-totals">
          Receipts {{ activity.receiptCount }} ({{ activity.receiptCost }}) ·
          Returns {{ activity.returnCount }} ({{ activity.returnCost }}) ·
          Net {{ activity.netCost }} · Tax {{ activity.taxTotal }}
        </p>
        <v-alert v-if="activity.mismatches.length" type="warning" variant="tonal"
          data-testid="supplier-mismatches">
          <div v-for="mismatch in activity.mismatches" :key="mismatch">{{ mismatch }}</div>
        </v-alert>
        <v-table density="compact" data-testid="supplier-documents">
          <thead><tr><th>Document</th><th /></tr></thead>
          <tbody>
            <tr v-for="number in activity.documentNumbers" :key="number">
              <td>{{ number }}</td>
              <td>
                <v-btn size="small" variant="text" :data-testid="`supplier-open-${number}`"
                  @click="open(number)">Open</v-btn>
                <v-btn size="small" variant="text" :data-testid="`supplier-reprint-${number}`"
                  @click="open(number, true)">Reprint</v-btn>
              </td>
            </tr>
            <tr v-if="activity.documentNumbers.length === 0">
              <td colspan="2" data-testid="supplier-empty">No documents in this period.</td>
            </tr>
          </tbody>
        </v-table>
      </v-card-text>
    </v-card>

    <v-card v-if="document" variant="outlined" data-testid="supplier-document">
      <v-card-title>{{ document.txNumber }} ({{ document.txType }})</v-card-title>
      <v-card-text>
        <p data-testid="supplier-document-totals">
          Cost {{ document.totalCost }} · GST {{ document.taxA }} · PST {{ document.taxB }} ·
          Total {{ document.totalAmount }}
        </p>
        <v-table density="compact" data-testid="supplier-document-lines">
          <thead><tr><th>SKU</th><th>Qty</th><th>Unit cost</th><th>Amount</th></tr></thead>
          <tbody>
            <tr v-for="line in document.lines" :key="line.rowNo">
              <td>{{ line.sku }}</td><td>{{ line.qty }}</td>
              <td>{{ line.unitCost }}</td><td>{{ line.amount }}</td>
            </tr>
          </tbody>
        </v-table>
        <v-alert v-if="reprintSeen" type="info" variant="tonal" class="mt-2"
          data-testid="supplier-reprinted">
          Reprint rendered from the posted document (identical lines and totals).
        </v-alert>
      </v-card-text>
    </v-card>
  </div>
</template>
