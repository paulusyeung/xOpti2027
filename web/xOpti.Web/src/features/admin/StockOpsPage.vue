<script setup lang="ts">
import { computed, reactive, ref } from 'vue'
import { api, unwrap } from '@/api/client'
import { AppError } from '@/api/problems'

const modes = ['Adjust', 'Transfer'] as const
const mode = ref<(typeof modes)[number]>('Adjust')
const reasonCodes = ['COUNT', 'DAMAGE', 'FOUND', 'CORRECTION', 'THEFT', 'EXPIRY']
const form = reactive({
  sku: '',
  branchCode: '01',
  fromBranch: '01',
  toBranch: '02',
  quantityDelta: -1,
  quantity: 1,
  reasonCode: 'COUNT',
  reason: '',
  allowNegative: false,
})
const saving = ref(false)
const forbidden = ref(false)
const error = ref<string | null>(null)
const fieldErrors = ref<Record<string, string[]>>({})
const pending = ref(false)
const result = ref<string | null>(null)

const summary = computed(() =>
  mode.value === 'Adjust'
    ? `${form.sku}: ${form.quantityDelta >= 0 ? '+' : ''}${form.quantityDelta} (${form.reasonCode})`
    : `${form.sku}: ${form.quantity} from ${form.fromBranch} to ${form.toBranch}`)

function errorFor(field: string): string | null {
  return (fieldErrors.value[field] ?? [])[0] ?? null
}

function handleError(caught: unknown): void {
  pending.value = false
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

function requestConfirmation(): void {
  error.value = null
  fieldErrors.value = {}
  result.value = null
  pending.value = true
}

async function confirm(): Promise<void> {
  saving.value = true
  error.value = null
  try {
    const key = crypto.randomUUID()
    if (mode.value === 'Adjust') {
      const posted = await unwrap(
        await api.client.POST('/api/v1/inventory/adjustments', {
          headers: { 'Idempotency-Key': key },
          body: {
            sku: form.sku, branchCode: form.branchCode,
            quantityDelta: Number(form.quantityDelta), reasonCode: form.reasonCode,
            reason: form.reason, allowNegative: form.allowNegative,
          },
        }),
      )
      result.value = `${posted.txNumber}: on hand now ${posted.newOnHand}.`
    } else {
      const posted = await unwrap(
        await api.client.POST('/api/v1/inventory/transfers', {
          headers: { 'Idempotency-Key': key },
          body: {
            sku: form.sku, fromBranch: form.fromBranch, toBranch: form.toBranch,
            quantity: Number(form.quantity), reason: form.reason,
          },
        }),
      )
      result.value = `${posted.transferId}: ${posted.quantity} moved (${posted.sourceTxNumber} -> ${posted.destinationTxNumber}).`
    }

    pending.value = false
  } catch (caught) {
    handleError(caught)
  } finally {
    saving.value = false
  }
}
</script>

<template>
  <div data-testid="stock-ops-page">
    <div class="d-flex align-center mb-4">
      <h1 class="text-h5">Stock operations</h1>
      <v-spacer />
      <v-btn-toggle v-model="mode" mandatory density="compact" data-testid="stock-ops-mode">
        <v-btn value="Adjust" data-testid="stock-ops-adjust">Adjust</v-btn>
        <v-btn value="Transfer" data-testid="stock-ops-transfer">Transfer</v-btn>
      </v-btn-toggle>
    </div>

    <v-alert v-if="forbidden" type="error" variant="tonal" data-testid="stock-ops-forbidden">
      You do not have permission to adjust or transfer stock.
    </v-alert>
    <v-alert v-else-if="error" type="error" variant="tonal" class="mb-4" data-testid="stock-ops-error">
      {{ error }}
    </v-alert>
    <v-alert v-if="result" type="success" variant="tonal" class="mb-4" data-testid="stock-ops-result">
      {{ result }}
    </v-alert>

    <v-card variant="outlined" class="mb-4">
      <v-card-text>
        <v-text-field v-model="form.sku" label="SKU" data-testid="stock-ops-sku"
          :error-messages="errorFor('Sku')" />
        <template v-if="mode === 'Adjust'">
          <div class="d-flex flex-wrap ga-3">
            <v-text-field v-model="form.branchCode" label="Branch" data-testid="stock-ops-branch"
              :error-messages="errorFor('BranchCode')" style="max-width: 120px" />
            <v-text-field v-model.number="form.quantityDelta" type="number" label="Quantity delta"
              data-testid="stock-ops-delta" :error-messages="errorFor('QuantityDelta')" style="max-width: 180px" />
            <v-select v-model="form.reasonCode" :items="reasonCodes" label="Reason code"
              data-testid="stock-ops-reason-code" :error-messages="errorFor('ReasonCode')" style="max-width: 200px" />
          </div>
          <v-checkbox v-model="form.allowNegative" label="Allow the adjustment to create a deficit"
            data-testid="stock-ops-allow-negative" :error-messages="errorFor('AllowNegative')" />
        </template>
        <template v-else>
          <div class="d-flex flex-wrap ga-3">
            <v-text-field v-model="form.fromBranch" label="From branch" data-testid="stock-ops-from"
              style="max-width: 140px" />
            <v-text-field v-model="form.toBranch" label="To branch" data-testid="stock-ops-to"
              :error-messages="errorFor('ToBranch')" style="max-width: 140px" />
            <v-text-field v-model.number="form.quantity" type="number" label="Quantity"
              data-testid="stock-ops-quantity" :error-messages="errorFor('Quantity')" style="max-width: 160px" />
          </div>
        </template>
        <v-text-field v-model="form.reason" label="Reason" data-testid="stock-ops-reason"
          :error-messages="errorFor('Reason')" />
      </v-card-text>
      <v-card-actions>
        <v-spacer />
        <v-btn v-if="!pending" color="primary" data-testid="stock-ops-submit" :disabled="forbidden"
          @click="requestConfirmation">Review</v-btn>
        <v-btn v-else color="error" data-testid="stock-ops-confirm" :loading="saving" @click="confirm">
          Confirm {{ mode === 'Adjust' ? 'adjustment' : 'transfer' }}
        </v-btn>
      </v-card-actions>
    </v-card>

    <v-alert v-if="pending" type="warning" variant="tonal" data-testid="stock-ops-confirmation">
      Confirm: {{ summary }}
    </v-alert>
  </div>
</template>
