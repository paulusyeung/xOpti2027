<script setup lang="ts">
import { reactive, ref } from 'vue'
import { api, unwrap } from '@/api/client'
import { AppError } from '@/api/problems'

interface VarianceRow {
  sku: string
  computerQty: number | null
  countedQty: number | null
  difference: number | null
  averageCost: number | null
}
interface Variance { headerId: number; name: string; status: number; rows: VarianceRow[] }
interface ImportResult {
  headerId: number; dryRun: boolean; accepted: number; resumeFrom: number | null
  errors: Array<{ row: number; field: string; message: string }>
}

const form = reactive({ name: '', branchCode: '', reason: '' })
const headerId = ref<number | null>(null)
const csv = ref('sku,qty\n')
const importReason = ref('')
const importResult = ref<ImportResult | null>(null)
const variance = ref<Variance | null>(null)
const approvalReason = ref('')
const postingReason = ref('')
const posted = ref<string | null>(null)
const busy = ref(false)
const forbidden = ref(false)
const error = ref<string | null>(null)

function handleError(caught: unknown): void {
  if (caught instanceof AppError) {
    forbidden.value = caught.kind === 'authorization' || caught.kind === 'unauthenticated'
    error.value = caught.userMessage
  } else {
    error.value = 'The request failed.'
  }
}

async function create(): Promise<void> {
  busy.value = true
  error.value = null
  try {
    const created = await unwrap(
      await api.client.POST('/api/v1/inventory/stock-takes', {
        body: { name: form.name, branchCode: form.branchCode || null, reason: form.reason },
      }),
    )
    headerId.value = Number(created.id)
    await loadVariances()
  } catch (caught) {
    handleError(caught)
  } finally {
    busy.value = false
  }
}

async function loadVariances(): Promise<void> {
  if (headerId.value === null) return
  try {
    variance.value = (await unwrap(
      await api.client.GET('/api/v1/inventory/stock-takes/{id}/variances', {
        params: { path: { id: headerId.value } },
      }),
    )) as Variance
  } catch (caught) {
    handleError(caught)
  }
}

async function importCounts(dryRun: boolean): Promise<void> {
  if (headerId.value === null) return
  busy.value = true
  error.value = null
  try {
    importResult.value = (await unwrap(
      await api.client.POST('/api/v1/inventory/stock-takes/{id}/counts', {
        params: { path: { id: headerId.value } },
        body: { csv: csv.value, dryRun, reason: importReason.value },
      }),
    )) as ImportResult
    await loadVariances()
  } catch (caught) {
    handleError(caught)
  } finally {
    busy.value = false
  }
}

async function act(action: 'approve' | 'post', reason: string): Promise<void> {
  if (headerId.value === null) return
  busy.value = true
  error.value = null
  try {
    if (action === 'approve') {
      await unwrap(
        await api.client.POST('/api/v1/inventory/stock-takes/{id}/approve', {
          params: { path: { id: headerId.value } },
          body: { reason },
        }),
      )
    } else {
      const result = await unwrap(
        await api.client.POST('/api/v1/inventory/stock-takes/{id}/post', {
          params: { path: { id: headerId.value } },
          body: { reason },
        }),
      )
      posted.value = result.txNumber
    }
    await loadVariances()
  } catch (caught) {
    handleError(caught)
  } finally {
    busy.value = false
  }
}
</script>

<template>
  <div data-testid="stock-take-page">
    <h1 class="text-h5 mb-4">Stock take</h1>

    <v-alert v-if="forbidden" type="error" variant="tonal" data-testid="stock-take-forbidden">
      You do not have permission to run stock takes.
    </v-alert>
    <v-alert v-else-if="error" type="error" variant="tonal" class="mb-4" data-testid="stock-take-error">
      {{ error }}
    </v-alert>

    <v-card variant="outlined" class="mb-4">
      <v-card-title>Create</v-card-title>
      <v-card-text>
        <v-text-field v-model="form.name" label="Name" data-testid="stock-take-name" />
        <v-text-field v-model="form.branchCode" label="Branch (blank = all)" data-testid="stock-take-branch" />
        <v-text-field v-model="form.reason" label="Reason" data-testid="stock-take-reason" />
        <v-btn color="primary" data-testid="stock-take-create" :loading="busy" @click="create">Freeze snapshot</v-btn>
      </v-card-text>
    </v-card>

    <template v-if="headerId !== null">
      <v-card variant="outlined" class="mb-4" data-testid="stock-take-header">
        <v-card-text>
          Stock take #{{ headerId }} · status
          {{ variance?.status ?? 1 }} · {{ variance?.rows.length ?? 0 }} snapshot rows
        </v-card-text>
      </v-card>

      <v-card variant="outlined" class="mb-4">
        <v-card-title>Count import</v-card-title>
        <v-card-text>
          <v-textarea v-model="csv" label="CSV (sku,qty)" rows="4" data-testid="stock-take-csv" />
          <v-text-field v-model="importReason" label="Reason" data-testid="stock-take-import-reason" />
          <div class="d-flex ga-2">
            <v-btn variant="tonal" data-testid="stock-take-dry-run" :loading="busy"
              @click="importCounts(true)">Dry run</v-btn>
            <v-btn color="primary" data-testid="stock-take-import" :loading="busy"
              @click="importCounts(false)">Import counts</v-btn>
          </div>
          <v-alert v-if="importResult" type="info" variant="tonal" class="mt-3"
            data-testid="stock-take-import-result">
            Accepted {{ importResult.accepted }} row(s)
            <span v-if="importResult.errors.length">; resume from row {{ importResult.resumeFrom }}</span>
            <ul v-if="importResult.errors.length">
              <li v-for="rowError in importResult.errors" :key="rowError.row">
                Row {{ rowError.row }}: {{ rowError.message }}
              </li>
            </ul>
          </v-alert>
        </v-card-text>
      </v-card>

      <v-card variant="outlined" class="mb-4">
        <v-card-title>Variances</v-card-title>
        <v-card-text>
          <v-table density="compact" data-testid="stock-take-variances">
            <thead><tr><th>SKU</th><th>System</th><th>Counted</th><th>Difference</th></tr></thead>
            <tbody>
              <tr v-for="row in variance?.rows ?? []" :key="row.sku">
                <td>{{ row.sku }}</td>
                <td>{{ row.computerQty }}</td>
                <td>{{ row.countedQty }}</td>
                <td>{{ row.difference }}</td>
              </tr>
            </tbody>
          </v-table>
          <v-text-field v-model="approvalReason" label="Approval reason"
            data-testid="stock-take-approval-reason" class="mt-2" />
          <v-btn variant="tonal" data-testid="stock-take-approve" :loading="busy"
            @click="act('approve', approvalReason)">Approve variances</v-btn>
          <v-text-field v-model="postingReason" label="Posting reason"
            data-testid="stock-take-posting-reason" class="mt-2" />
          <v-btn color="primary" data-testid="stock-take-post" :loading="busy"
            @click="act('post', postingReason)">Post adjustments</v-btn>
          <v-alert v-if="posted" type="success" variant="tonal" class="mt-2" data-testid="stock-take-posted">
            Posted as {{ posted }}.
          </v-alert>
        </v-card-text>
      </v-card>
    </template>
  </div>
</template>
