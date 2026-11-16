<script setup lang="ts">
import { computed, watch } from 'vue'
import { tenderOutcome } from './pricing'
import type { PaymentMethod } from './types'

export interface TenderRow {
  method: string
  amount: number
  reference: string
  originalPaymentLineNo?: number
}

const props = defineProps<{
  methods: PaymentMethod[]
  total: number
  testPrefix: string
  readonlyMode?: boolean
}>()

const tenders = defineModel<TenderRow[]>({ required: true })

const outcome = computed(() => tenderOutcome(tenders.value, props.total))

const missingReference = computed(() =>
  tenders.value.some((tender) =>
    tender.method.toUpperCase() !== 'C' && Number(tender.amount) > 0 && !tender.reference.trim()))

watch(
  [() => props.total, () => props.methods.length, () => tenders.value.length],
  ([total, _methodCount, length], previous) => {
    const previousTotal = previous?.[0] ?? 0
    if (length === 0) {
      const method = props.methods[0]?.code ?? 'C'
      if (total > 0) tenders.value = [{ method, amount: total, reference: '' }]
      return
    }
    // Keep the auto-filled amount in step with the basket until the operator
    // edits the tender.
    if (length === 1) {
      const methods = props.methods.map((method) => method.code)
      if (methods.length > 0 && !methods.includes(tenders.value[0].method)) {
        tenders.value[0].method = methods[0]
      }
      if (previousTotal > 0 && Number(tenders.value[0].amount) === previousTotal) {
        tenders.value[0].amount = total
      }
    }
  },
  { immediate: true },
)

function addTender(): void {
  const method = props.methods[0]?.code ?? 'C'
  tenders.value = [...tenders.value, { method, amount: 0, reference: '' }]
}

function removeTender(index: number): void {
  tenders.value = tenders.value.filter((_row, position) => position !== index)
}
</script>

<template>
  <div data-testid="payment-panel">
    <div class="d-flex align-center mb-2">
      <span class="text-subtitle-2">Tenders</span>
      <v-spacer />
      <v-btn v-if="!readonlyMode" size="small" variant="text" :data-testid="`${testPrefix}-payment-add`"
        @click="addTender">Add tender</v-btn>
    </div>
    <div v-for="(tender, index) in tenders" :key="index" class="d-flex ga-2 mb-2 align-center"
      :data-testid="`${testPrefix}-payment-row-${index}`">
      <v-select v-model="tender.method" :items="methods" item-title="nameLong" item-value="code"
        label="Method" density="compact" hide-details style="max-width: 150px"
        :readonly="readonlyMode" :data-testid="`${testPrefix}-payment-method-${index}`" />
      <v-text-field v-model.number="tender.amount" type="number" min="0" label="Amount" density="compact"
        hide-details style="max-width: 140px" :readonly="readonlyMode"
        :data-testid="`${testPrefix}-payment-amount-${index}`" />
      <v-text-field v-if="tender.method.toUpperCase() !== 'C'" v-model="tender.reference"
        label="Approval reference" density="compact" hide-details
        :readonly="readonlyMode" :data-testid="`${testPrefix}-payment-reference-${index}`" />
      <v-btn v-if="!readonlyMode && tenders.length > 1" icon="mdi-close" size="small" variant="text"
        :data-testid="`${testPrefix}-payment-remove-${index}`" @click="removeTender(index)" />
    </div>
    <div class="d-flex justify-space-between text-body-2">
      <span>Remaining</span><span :data-testid="`${testPrefix}-payment-remaining`">{{ outcome.remaining.toFixed(2) }}</span>
    </div>
    <div class="d-flex justify-space-between text-body-2">
      <span>Change</span><span :data-testid="`${testPrefix}-payment-change`">{{ outcome.change.toFixed(2) }}</span>
    </div>
    <div v-if="missingReference" class="text-caption text-warning" :data-testid="`${testPrefix}-payment-reference-hint`">
      Non-cash tenders need the terminal approval reference.
    </div>
  </div>
</template>
