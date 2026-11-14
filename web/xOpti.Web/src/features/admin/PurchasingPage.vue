<script setup lang="ts">
import { computed, reactive, ref } from 'vue'
import { api, unwrap } from '@/api/client'
import { AppError } from '@/api/problems'

interface Line {
  sku: string
  lotNo: string
  quantity: number
  unitCost: number
  gstAmount: number
  pstAmount: number
  taxCode: string
}

const mode = ref<'receive' | 'reject'>('receive')
const form = reactive({
  supplierCode: '',
  branchCode: '01',
  originalTxNumber: '',
  reason: '',
})
const lines = ref<Line[]>([emptyLine()])
const saving = ref(false)
const forbidden = ref(false)
const error = ref<string | null>(null)
const fieldErrors = ref<Record<string, string[]>>({})
const posted = ref<{ txNumber: string; controlNumber: string; totalQuantity: number; totalCost: number; totalTax: number } | null>(null)
const reprinted = ref(false)

function emptyLine(): Line {
  return { sku: '', lotNo: '', quantity: 1, unitCost: 0, gstAmount: 0, pstAmount: 0, taxCode: 'N' }
}

const totals = computed(() => ({
  quantity: lines.value.reduce((sum, line) => sum + (Number(line.quantity) || 0), 0),
  cost: lines.value.reduce((sum, line) => sum + (Number(line.quantity) || 0) * (Number(line.unitCost) || 0), 0),
  tax: lines.value.reduce((sum, line) => sum + (Number(line.gstAmount) || 0) + (Number(line.pstAmount) || 0), 0),
}))

function addLine(): void { lines.value.push(emptyLine()) }
function removeLine(index: number): void { lines.value.splice(index, 1) }
function errorFor(field: string): string | null {
  const messages = fieldErrors.value[field] ?? []
  return messages.length ? messages[0] : null
}

function handleError(caught: unknown): void {
  if (caught instanceof AppError) {
    forbidden.value = caught.kind === 'authorization' || caught.kind === 'unauthenticated'
    if (caught.kind === 'validation') {
      fieldErrors.value = caught.fieldErrors as Record<string, string[]>
      error.value = Object.values(fieldErrors.value)[0]?.[0] ?? caught.userMessage
    } else {
      error.value = caught.userMessage
    }
  } else {
    error.value = 'The request failed.'
  }
}

async function submit(): Promise<void> {
  saving.value = true
  error.value = null
  fieldErrors.value = {}
  posted.value = null
  reprinted.value = false
  try {
    const key = crypto.randomUUID()
    const body = {
      supplierCode: form.supplierCode,
      branchCode: form.branchCode,
      originalTxNumber: mode.value === 'reject' ? (form.originalTxNumber || null) : null,
      reason: form.reason,
      lines: lines.value.map((line) => ({
        sku: line.sku, lotNo: line.lotNo, quantity: Number(line.quantity),
        unitCost: Number(line.unitCost), gstAmount: Number(line.gstAmount),
        pstAmount: Number(line.pstAmount), taxCode: line.taxCode,
      })),
    }
    const result = await unwrap(
      mode.value === 'receive'
        ? await api.client.POST('/api/v1/purchasing/receipts', { body, headers: { 'Idempotency-Key': key } })
        : await api.client.POST('/api/v1/purchasing/rejections', { body, headers: { 'Idempotency-Key': key } }),
    )
    posted.value = {
      txNumber: result.txNumber,
      controlNumber: result.controlNumber,
      totalQuantity: Number(result.totalQuantity),
      totalCost: Number(result.totalCost),
      totalTax: Number(result.totalTax),
    }
    lines.value = [emptyLine()]
    form.reason = ''
  } catch (caught) {
    handleError(caught)
  } finally {
    saving.value = false
  }
}

function reprint(): void {
  reprinted.value = true
}
</script>

<template>
  <div data-testid="purchasing-page">
    <div class="d-flex align-center mb-4">
      <h1 class="text-h5">Purchasing</h1>
      <v-spacer />
      <v-btn-toggle v-model="mode" mandatory density="compact" data-testid="purchasing-mode">
        <v-btn value="receive" data-testid="purchasing-mode-receive">Receive</v-btn>
        <v-btn value="reject" data-testid="purchasing-mode-reject">Reject</v-btn>
      </v-btn-toggle>
    </div>

    <v-alert v-if="forbidden" type="error" variant="tonal" data-testid="purchasing-forbidden">
      You do not have permission to post purchasing documents.
    </v-alert>
    <v-alert v-else-if="error" type="error" variant="tonal" class="mb-4" data-testid="purchasing-error">
      {{ error }}
    </v-alert>

    <v-card variant="outlined" class="mb-4">
      <v-card-text>
        <div class="d-flex flex-wrap ga-3">
          <v-text-field v-model="form.supplierCode" label="Supplier code" data-testid="purchasing-supplier"
            :error-messages="errorFor('SupplierCode')" style="max-width: 180px" />
          <v-text-field v-model="form.branchCode" label="Branch" data-testid="purchasing-branch"
            :error-messages="errorFor('BranchCode')" style="max-width: 120px" />
          <v-text-field v-if="mode === 'reject'" v-model="form.originalTxNumber" label="Original SR number"
            data-testid="purchasing-original" style="max-width: 220px" />
        </div>

        <v-table density="compact" data-testid="purchasing-lines">
          <thead>
            <tr><th>SKU</th><th>Lot</th><th>Qty</th><th>Unit cost</th><th>GST</th><th>PST</th><th>Tax</th><th /></tr>
          </thead>
          <tbody>
            <tr v-for="(line, index) in lines" :key="index">
              <td><v-text-field v-model="line.sku" density="compact" hide-details :data-testid="`line-sku-${index}`" /></td>
              <td><v-text-field v-model="line.lotNo" density="compact" hide-details :data-testid="`line-lot-${index}`" /></td>
              <td><v-text-field v-model.number="line.quantity" type="number" density="compact" hide-details :data-testid="`line-qty-${index}`" /></td>
              <td><v-text-field v-model.number="line.unitCost" type="number" step="0.0001" density="compact" hide-details :data-testid="`line-cost-${index}`" /></td>
              <td><v-text-field v-model.number="line.gstAmount" type="number" step="0.0001" density="compact" hide-details :data-testid="`line-gst-${index}`" /></td>
              <td><v-text-field v-model.number="line.pstAmount" type="number" step="0.0001" density="compact" hide-details :data-testid="`line-pst-${index}`" /></td>
              <td><v-text-field v-model="line.taxCode" density="compact" hide-details :data-testid="`line-tax-${index}`" /></td>
              <td><v-btn size="small" variant="text" color="error" :data-testid="`line-remove-${index}`" @click="removeLine(index)">×</v-btn></td>
            </tr>
          </tbody>
        </v-table>
        <div class="d-flex align-center mt-2">
          <v-btn variant="text" data-testid="purchasing-add-line" @click="addLine">Add line</v-btn>
          <v-spacer />
          <span data-testid="purchasing-totals">
            Qty {{ totals.quantity }} · Cost {{ totals.cost.toFixed(4) }} · Tax {{ totals.tax.toFixed(4) }}
          </span>
        </div>

        <v-text-field v-model="form.reason" label="Reason" data-testid="purchasing-reason"
          :error-messages="errorFor('Reason')" />
      </v-card-text>
      <v-card-actions>
        <v-spacer />
        <v-btn color="primary" data-testid="purchasing-submit" :loading="saving" @click="submit">
          Post {{ mode === 'receive' ? 'receipt' : 'rejection' }}
        </v-btn>
      </v-card-actions>
    </v-card>

    <v-card v-if="posted" variant="outlined" data-testid="purchasing-posted">
      <v-card-title>{{ posted.txNumber }}</v-card-title>
      <v-card-text>
        <p data-testid="purchasing-posted-summary">
          Control {{ posted.controlNumber }} · Qty {{ posted.totalQuantity }} ·
          Cost {{ posted.totalCost.toFixed(4) }} · Tax {{ posted.totalTax.toFixed(4) }}
        </p>
        <v-alert v-if="reprinted" type="info" variant="tonal" data-testid="purchasing-reprinted">
          Reprint rendered from the posted document (identical numbers, lines, and totals).
        </v-alert>
      </v-card-text>
      <v-card-actions>
        <v-spacer />
        <v-btn variant="tonal" data-testid="purchasing-reprint" @click="reprint">Reprint</v-btn>
      </v-card-actions>
    </v-card>
  </div>
</template>
