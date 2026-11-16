<script setup lang="ts">
import { computed, onMounted, reactive, ref } from 'vue'
import { api, unwrap } from '@/api/client'
import { AppError } from '@/api/problems'
import DocumentPanel from './DocumentPanel.vue'
import PaymentPanel, { type TenderRow } from './PaymentPanel.vue'
import { requestDocumentPrint } from './print'
import { normalizeTaxCode, round2, taxFor, tenderOutcome, type TaxRates } from './pricing'
import type { CashSession, PaymentMethod, PosDocument, PosItem, RefundableInvoice } from './types'

interface RefundSelection {
  rowNo: number
  sku: string
  originalQuantity: number
  refundableQuantity: number
  unitAmount: number
  amount: number
  taxA: number
  taxB: number
  taxCode: string
  quantity: number
  restock: boolean
}

interface ReplacementLine {
  sku: string
  name: string | null
  quantity: number
  unitAmount: number
  discountAmount: number
  taxCode: string
}

const taxCodes = ['N', 'B', 'G', 'P', 'g', 'p']
const invoiceNumber = ref('')
const invoice = ref<RefundableInvoice | null>(null)
const selections = ref<RefundSelection[]>([])
const replacements = ref<ReplacementLine[]>([])
const skuQuery = ref('')
const skuResults = ref<PosItem[]>([])
const rates = reactive<TaxRates>({ a: 0, b: 0 })
const paymentMethods = ref<PaymentMethod[]>([])
const saleTenders = ref<TenderRow[]>([])
const openSessions = ref<CashSession[]>([])
const sessionId = ref<number | null>(null)
const staffCode = ref('0001')
const reason = ref('customer refund')
const busy = ref(false)
const forbidden = ref(false)
const error = ref<string | null>(null)
const notice = ref<string | null>(null)
const posted = ref<PosDocument | null>(null)
const reprintTarget = ref<PosDocument | null>(null)

function handleError(caught: unknown): void {
  if (caught instanceof AppError) {
    forbidden.value = caught.kind === 'authorization' || caught.kind === 'unauthenticated'
    if (caught.kind === 'validation') {
      const fields = caught.fieldErrors as Record<string, string[]>
      error.value = Object.values(fields)[0]?.[0] ?? caught.userMessage
    } else {
      error.value = caught.userMessage
    }
  } else {
    error.value = 'The request failed.'
  }
}

function replacementAmount(line: ReplacementLine): number {
  return round2(line.unitAmount * line.quantity - line.discountAmount)
}

const refundTotals = computed(() => {
  let refund = 0
  let refundTaxA = 0
  let refundTaxB = 0
  for (const line of selections.value) {
    if (line.quantity > 0) {
      refund += round2(line.amount * line.quantity / line.originalQuantity)
      refundTaxA += round2(line.taxA * line.quantity / line.originalQuantity)
      refundTaxB += round2(line.taxB * line.quantity / line.originalQuantity)
    }
  }
  let replacementNet = 0
  let replacementTaxA = 0
  let replacementTaxB = 0
  for (const line of replacements.value) {
    const amount = replacementAmount(line)
    const tax = taxFor(amount, line.taxCode, rates)
    replacementNet += amount
    replacementTaxA += tax.gst
    replacementTaxB += tax.pst
  }
  replacementNet = round2(replacementNet)
  replacementTaxA = round2(replacementTaxA)
  replacementTaxB = round2(replacementTaxB)
  const replacementTotal = round2(replacementNet + replacementTaxA + replacementTaxB)
  const refundValue = round2(refund)
  refundTaxA = round2(refundTaxA)
  refundTaxB = round2(refundTaxB)
  const refundTotal = round2(refundValue + refundTaxA + refundTaxB)
  return {
    refund: refundValue,
    refundTaxA,
    refundTaxB,
    refundTotal,
    replacementNet,
    replacementTaxA,
    replacementTaxB,
    replacementTotal,
    net: round2(replacementTotal - refundTotal),
  }
})

const refundTenders = computed(() => {
  if (!invoice.value || refundTotals.value.net >= 0) return [] as TenderRow[]
  let remaining = round2(-refundTotals.value.net)
  const rows: TenderRow[] = []
  for (const tender of invoice.value.tenders) {
    if (remaining <= 0) break
    const available = Number(tender.refundableAmount)
    if (available <= 0) continue
    const amount = round2(Math.min(available, remaining))
    rows.push({
      method: tender.type,
      amount,
      reference: tender.reference ?? '',
      originalPaymentLineNo: tender.paymentLineNo,
    })
    remaining = round2(remaining - amount)
  }
  return rows
})

const refundShortfall = computed(() => {
  if (!invoice.value || refundTotals.value.net >= 0) return 0
  const allocated = refundTenders.value.reduce((sum, tender) => sum + tender.amount, 0)
  return round2(Math.max(0, -refundTotals.value.net - allocated))
})

const saleOutcome = computed(() =>
  tenderOutcome(saleTenders.value, Math.max(0, refundTotals.value.net)))

const canSubmit = computed(() =>
  invoice.value !== null
  && selections.value.some((line) => line.quantity > 0)
  && selections.value.every((line) => line.quantity >= 0 && line.quantity <= line.refundableQuantity)
  && reason.value.trim().length >= 3
  && (refundTotals.value.net > 0
    ? saleOutcome.value.remaining === 0
    : refundShortfall.value === 0))

async function loadContext(): Promise<void> {
  const context = await unwrap(await api.client.GET('/api/v1/sales/order-entry/context'))
  rates.a = Number(context.taxARate)
  rates.b = Number(context.taxBRate)
  paymentMethods.value = (await unwrap(await api.client.GET('/api/v1/sales/payment-methods', {}))) as unknown as PaymentMethod[]
  openSessions.value = (await unwrap(await api.client.GET('/api/v1/cash/sessions/open', {
    params: { query: { branchCode: '01' } },
  }))) as unknown as CashSession[]
  sessionId.value = openSessions.value[0]?.id ?? null
}

async function fetchRefundable(): Promise<void> {
  const result = (await unwrap(await api.client.GET('/api/v1/sales/invoices/{txNumber}/refundable', {
    params: { path: { txNumber: invoiceNumber.value.trim() } },
  }))) as RefundableInvoice
  invoice.value = result
  selections.value = result.lines.map((line) => ({
    rowNo: line.rowNo,
    sku: line.sku,
    originalQuantity: line.originalQuantity,
    refundableQuantity: line.refundableQuantity,
    unitAmount: Number(line.unitAmount),
    amount: Number(line.amount),
    taxA: Number(line.taxA),
    taxB: Number(line.taxB),
    taxCode: normalizeTaxCode(line.taxCode),
    quantity: 0,
    restock: true,
  }))
  replacements.value = []
  saleTenders.value = []
}

async function loadInvoice(): Promise<void> {
  busy.value = true
  error.value = null
  notice.value = null
  posted.value = null
  reprintTarget.value = null
  try {
    await fetchRefundable()
  } catch (caught) {
    invoice.value = null
    selections.value = []
    handleError(caught)
  } finally {
    busy.value = false
  }
}

async function refreshRefundable(): Promise<void> {
  try {
    await fetchRefundable()
  } catch (caught) {
    handleError(caught)
  }
}

async function searchItems(): Promise<void> {
  busy.value = true
  error.value = null
  try {
    skuResults.value = (await unwrap(await api.client.GET('/api/v1/sales/items', {
      params: { query: { search: skuQuery.value, limit: 10 } },
    }))) as PosItem[]
  } catch (caught) {
    handleError(caught)
  } finally {
    busy.value = false
  }
}

function addReplacement(item: PosItem): void {
  const existing = replacements.value.find((line) => line.sku === item.sku)
  if (existing) {
    existing.quantity += 1
  } else {
    replacements.value.push({
      sku: item.sku,
      name: item.name,
      quantity: 1,
      unitAmount: Number(item.retailPrice ?? 0),
      discountAmount: 0,
      taxCode: normalizeTaxCode(item.taxCode),
    })
  }
  skuResults.value = []
  skuQuery.value = ''
}

function refundAll(): void {
  for (const line of selections.value) line.quantity = line.refundableQuantity
}

async function postRefund(): Promise<void> {
  if (!canSubmit.value || invoice.value === null) {
    error.value = 'Select an invoice and at least one refundable unit.'
    return
  }
  busy.value = true
  error.value = null
  notice.value = null
  reprintTarget.value = null
  try {
    const document = await unwrap(await api.client.POST('/api/v1/sales/refunds', {
      headers: { 'Idempotency-Key': crypto.randomUUID() },
      body: {
        originalTxNumber: invoice.value.txNumber,
        staffCode: staffCode.value,
        sessionId: sessionId.value,
        reason: reason.value,
        lines: selections.value
          .filter((line) => line.quantity > 0)
          .map((line) => ({ originalRowNo: line.rowNo, quantity: line.quantity, restock: line.restock })),
        replacements: replacements.value.map((line) => ({
          sku: line.sku,
          quantity: line.quantity,
          unitAmount: line.unitAmount,
          discountAmount: line.discountAmount,
          taxCode: line.taxCode,
        })),
        refundTenders: refundTenders.value.map((tender) => ({
          method: tender.method,
          amount: tender.amount,
          reference: tender.reference || null,
          originalPaymentLineNo: tender.originalPaymentLineNo,
        })),
        saleTenders: saleTenders.value
          .filter((tender) => Number(tender.amount) > 0)
          .map((tender) => ({
            method: tender.method,
            amount: Number(tender.amount),
            reference: tender.reference.trim() || null,
          })),
      },
    })) as unknown as PosDocument
    posted.value = document
    notice.value = `${document.txNumber} posted for ${invoice.value.txNumber}.`
    await refreshRefundable()
  } catch (caught) {
    handleError(caught)
  } finally {
    busy.value = false
  }
}

async function reprintOriginal(): Promise<void> {
  if (!invoice.value) return
  busy.value = true
  error.value = null
  try {
    await requestDocumentPrint(invoice.value.txNumber, {
      reprint: true,
      format: 'invoice',
      terminalCode: openSessions.value[0]?.terminalCode ?? null,
      reason: 'reprint invoice',
    })
    reprintTarget.value = (await unwrap(await api.client.GET('/api/v1/sales/documents/{txNumber}', {
      params: { path: { txNumber: invoice.value.txNumber } },
    }))) as PosDocument
  } catch (caught) {
    handleError(caught)
  } finally {
    busy.value = false
  }
}

onMounted(async () => {
  try {
    await loadContext()
  } catch (caught) {
    handleError(caught)
  }
})
</script>

<template>
  <div data-testid="pos-refund-page">
    <div class="d-flex align-center mb-4">
      <h1 class="text-h5">POS refund / exchange</h1>
      <v-spacer />
      <v-text-field v-model="staffCode" label="Staff code" density="compact" hide-details
        style="max-width: 140px" data-testid="pos-refund-staff-code" />
    </div>

    <v-alert v-if="forbidden" type="error" variant="tonal" data-testid="pos-refund-forbidden">
      You do not have permission to post refunds.
    </v-alert>
    <v-alert v-else-if="error" type="error" variant="tonal" class="mb-4" data-testid="pos-refund-error">
      {{ error }}
    </v-alert>
    <v-alert v-if="notice" type="success" variant="tonal" class="mb-4" data-testid="pos-refund-notice">
      {{ notice }}
    </v-alert>

    <v-card variant="outlined" class="mb-4">
      <v-card-text>
        <div class="d-flex ga-2">
          <v-text-field v-model="invoiceNumber" label="Original invoice number" density="compact"
            hide-details data-testid="pos-refund-invoice" @keyup.enter="loadInvoice" />
          <v-btn color="primary" :loading="busy" data-testid="pos-refund-load" @click="loadInvoice">Load</v-btn>
        </div>
      </v-card-text>
    </v-card>

    <v-row v-if="invoice">
      <v-col cols="12" md="8">
        <v-card variant="outlined" class="mb-4">
          <v-card-title>
            {{ invoice.txNumber }} · {{ invoice.customerName ?? 'Customer ' + invoice.customerId }}
          </v-card-title>
          <v-card-text>
            <p class="text-body-2" data-testid="pos-refund-summary">
              Invoice total {{ Number(invoice.totalAmount).toFixed(2) }}
            </p>
            <v-btn size="small" variant="text" class="mb-2" data-testid="pos-refund-reprint"
              @click="reprintOriginal">Reprint invoice</v-btn>
            <v-table density="compact" data-testid="pos-refund-lines">
              <thead>
                <tr>
                  <th>SKU</th><th>Original</th><th>Refunded</th><th>Refundable</th>
                  <th style="width: 120px">Refund qty</th><th style="width: 90px">Restock</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="line in selections" :key="line.rowNo"
                  :data-testid="`pos-refund-line-${line.rowNo}`">
                  <td>{{ line.sku }}</td>
                  <td>{{ line.originalQuantity }}</td>
                  <td>{{ line.originalQuantity - line.refundableQuantity }}</td>
                  <td>{{ line.refundableQuantity }}</td>
                  <td>
                    <v-text-field v-model.number="line.quantity" type="number" min="0"
                      :max="line.refundableQuantity" density="compact" hide-details
                      :data-testid="`pos-refund-line-${line.rowNo}-qty`" />
                  </td>
                  <td>
                    <v-checkbox v-model="line.restock" density="compact" hide-details
                      :data-testid="`pos-refund-line-${line.rowNo}-restock`" />
                  </td>
                </tr>
              </tbody>
            </v-table>
            <v-btn size="small" variant="text" class="mt-2" data-testid="pos-refund-all"
              @click="refundAll">Refund all remaining</v-btn>
          </v-card-text>
        </v-card>

        <v-card variant="outlined">
          <v-card-title>Exchange replacements</v-card-title>
          <v-card-text>
            <div class="d-flex ga-2 mb-2">
              <v-text-field v-model="skuQuery" label="Add a replacement SKU" density="compact"
                hide-details data-testid="pos-refund-sku-search" @keyup.enter="searchItems" />
              <v-btn color="primary" :loading="busy" data-testid="pos-refund-sku-find"
                @click="searchItems">Search</v-btn>
            </div>
            <div v-if="skuResults.length" data-testid="pos-refund-sku-results">
              <v-btn v-for="item in skuResults" :key="item.sku" variant="text" block
                class="justify-start text-none" :data-testid="`pos-refund-sku-option-${item.sku}`"
                @click="addReplacement(item)">
                {{ item.sku }} — {{ item.name ?? 'Item' }} ({{ Number(item.retailPrice ?? 0).toFixed(2) }})
              </v-btn>
            </div>
            <v-table v-if="replacements.length" density="compact" data-testid="pos-refund-replacements">
              <thead>
                <tr><th>SKU</th><th>Qty</th><th>Unit</th><th>Discount</th><th>Tax</th><th class="text-right">Amount</th></tr>
              </thead>
              <tbody>
                <tr v-for="(line, index) in replacements" :key="line.sku">
                  <td>{{ line.sku }}</td>
                  <td><v-text-field v-model.number="line.quantity" type="number" min="1" density="compact"
                    hide-details :data-testid="`pos-refund-replacement-${index}-qty`" /></td>
                  <td><v-text-field v-model.number="line.unitAmount" type="number" min="0" density="compact"
                    hide-details :data-testid="`pos-refund-replacement-${index}-price`" /></td>
                  <td><v-text-field v-model.number="line.discountAmount" type="number" min="0" density="compact"
                    hide-details :data-testid="`pos-refund-replacement-${index}-discount`" /></td>
                  <td><v-select v-model="line.taxCode" :items="taxCodes" density="compact" hide-details
                    :data-testid="`pos-refund-replacement-${index}-tax`" /></td>
                  <td class="text-right">{{ replacementAmount(line).toFixed(2) }}</td>
                </tr>
              </tbody>
            </v-table>
            <p v-else class="text-body-2 text-medium-emphasis mb-0">No replacement items.</p>
          </v-card-text>
        </v-card>
      </v-col>

      <v-col cols="12" md="4">
        <v-card variant="outlined">
          <v-card-title>Refund totals</v-card-title>
          <v-card-text>
            <div class="d-flex justify-space-between text-body-2">
              <span>Refund value</span><span data-testid="pos-refund-value">{{ refundTotals.refund.toFixed(2) }}</span>
            </div>
            <div class="d-flex justify-space-between text-body-2">
              <span>Refund tax</span><span>{{ (refundTotals.refundTaxA + refundTotals.refundTaxB).toFixed(2) }}</span>
            </div>
            <div class="d-flex justify-space-between text-body-2">
              <span>Refund total</span><span data-testid="pos-refund-total">{{ refundTotals.refundTotal.toFixed(2) }}</span>
            </div>
            <div class="d-flex justify-space-between text-body-2">
              <span>Replacement total</span><span>{{ refundTotals.replacementTotal.toFixed(2) }}</span>
            </div>
            <v-divider class="my-2" />
            <div class="d-flex justify-space-between text-body-1">
              <strong>{{ refundTotals.net < 0 ? 'Refund due' : refundTotals.net > 0 ? 'Balance due' : 'Settled' }}</strong>
              <strong data-testid="pos-refund-net">{{ Math.abs(refundTotals.net).toFixed(2) }}</strong>
            </div>
            <div v-if="refundTenders.length" class="mt-3" data-testid="pos-refund-tenders">
              <div class="text-subtitle-2 mb-1">Refund to original tenders</div>
              <div v-for="(tender, index) in refundTenders" :key="index" class="d-flex justify-space-between text-body-2"
                :data-testid="`pos-refund-tender-${index}`">
                <span>{{ tender.method }} · line {{ tender.originalPaymentLineNo }}</span>
                <span :data-testid="`pos-refund-tender-amount-${index}`">{{ tender.amount.toFixed(2) }}</span>
              </div>
            </div>
            <v-alert v-if="refundShortfall > 0" type="warning" variant="tonal" class="mt-2"
              data-testid="pos-refund-shortfall">
              {{ refundShortfall.toFixed(2) }} has no refundable original tender.
            </v-alert>
            <div v-if="refundTotals.net > 0" class="mt-3">
              <PaymentPanel v-model="saleTenders" :methods="paymentMethods"
                :total="refundTotals.net" test-prefix="pos-refund-sale" />
            </div>
            <v-select v-model="sessionId" :items="openSessions" item-title="terminalCode"
              item-value="id" label="Drawer session" density="compact" class="mt-3"
              data-testid="pos-refund-session" />
            <v-text-field v-model="reason" label="Reason" density="compact" class="mt-3"
              data-testid="pos-refund-reason" />
            <v-btn color="primary" class="mt-2" block :loading="busy" :disabled="!canSubmit"
              data-testid="pos-refund-submit" @click="postRefund">Post refund / exchange</v-btn>
          </v-card-text>
        </v-card>
      </v-col>
    </v-row>

    <div v-if="posted" class="mt-4">
      <DocumentPanel :document="posted" title="Refund" />
    </div>
    <v-alert v-if="reprintTarget" type="info" variant="tonal" class="mt-2" data-testid="pos-refund-reprinted">
      Reprinted {{ reprintTarget.txNumber }} from the posted document.
    </v-alert>
    <DocumentPanel v-if="reprintTarget" :document="reprintTarget" title="Invoice reprint" />
  </div>
</template>
