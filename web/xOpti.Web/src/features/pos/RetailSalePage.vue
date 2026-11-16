<script setup lang="ts">
import { computed, onMounted, reactive, ref } from 'vue'
import { api, unwrap } from '@/api/client'
import { AppError } from '@/api/problems'
import DocumentPanel from './DocumentPanel.vue'
import { normalizeTaxCode, round2, taxFor, type TaxRates } from './pricing'
import type { PosCustomer, PosDocument, PosItem } from './types'

interface SaleLine {
  sku: string
  name: string | null
  quantity: number
  unitAmount: number
  discountAmount: number
  taxCode: string
}

const taxCodes = ['N', 'B', 'G', 'P', 'g', 'p']
const methods = [
  { title: 'Cash', value: 'C' },
  { title: 'Card', value: 'K' },
]
const staffCode = ref('0001')
const customerQuery = ref('')
const customerResults = ref<PosCustomer[]>([])
const customer = ref<PosCustomer | null>(null)
const skuQuery = ref('')
const skuResults = ref<PosItem[]>([])
const lines = ref<SaleLine[]>([])
const rates = reactive<TaxRates>({ a: 0, b: 0 })
const tenderMethod = ref('C')
const tenderAmount = ref(0)
const reason = ref('counter sale')
const busy = ref(false)
const forbidden = ref(false)
const error = ref<string | null>(null)
const notice = ref<string | null>(null)
const posted = ref<PosDocument | null>(null)
const reprinted = ref<PosDocument | null>(null)

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

function lineAmount(line: SaleLine): number {
  return round2(line.unitAmount * line.quantity - line.discountAmount)
}

const totals = computed(() => {
  let subtotal = 0
  let taxA = 0
  let taxB = 0
  for (const line of lines.value) {
    const amount = lineAmount(line)
    const tax = taxFor(amount, line.taxCode, rates)
    subtotal += amount
    taxA += tax.gst
    taxB += tax.pst
  }
  subtotal = round2(subtotal)
  taxA = round2(taxA)
  taxB = round2(taxB)
  const total = round2(subtotal + taxA + taxB)
  const tendered = Number(tenderAmount.value || 0) || total
  const change = tenderMethod.value === 'C' ? Math.max(0, round2(tendered - total)) : 0
  return { subtotal, taxA, taxB, total, tendered, change, short: round2(total - tendered) }
})

const canPost = computed(() =>
  customer.value !== null
  && lines.value.length > 0
  && lines.value.every((line) => line.quantity > 0 && line.unitAmount >= 0 && line.discountAmount >= 0)
  && (tenderMethod.value === 'C' ? totals.value.tendered >= totals.value.total : totals.value.tendered === totals.value.total))

async function loadContext(): Promise<void> {
  const context = await unwrap(await api.client.GET('/api/v1/sales/order-entry/context'))
  rates.a = Number(context.taxARate)
  rates.b = Number(context.taxBRate)
}

async function searchCustomers(): Promise<void> {
  busy.value = true
  error.value = null
  try {
    customerResults.value = (await unwrap(await api.client.GET('/api/v1/sales/customers', {
      params: { query: { search: customerQuery.value, limit: 10 } },
    }))) as PosCustomer[]
  } catch (caught) {
    handleError(caught)
  } finally {
    busy.value = false
  }
}

function selectCustomer(selected: PosCustomer): void {
  customer.value = selected
  customerQuery.value = selected.fullName ?? String(selected.id)
  customerResults.value = []
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

function addItem(item: PosItem): void {
  const existing = lines.value.find((line) => line.sku === item.sku)
  if (existing) {
    existing.quantity += 1
  } else {
    lines.value.push({
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

function removeLine(index: number): void {
  lines.value.splice(index, 1)
}

function resetSale(): void {
  customer.value = null
  customerQuery.value = ''
  customerResults.value = []
  lines.value = []
  skuResults.value = []
  skuQuery.value = ''
  tenderAmount.value = 0
  posted.value = null
  reprinted.value = null
  error.value = null
  notice.value = 'Started a new sale.'
}

async function postSale(): Promise<void> {
  if (customer.value === null || !canPost.value) {
    error.value = 'Select a customer, add lines, and tender the full total.'
    return
  }
  busy.value = true
  error.value = null
  notice.value = null
  reprinted.value = null
  try {
    const document = await unwrap(await api.client.POST('/api/v1/sales/invoices', {
      headers: { 'Idempotency-Key': crypto.randomUUID() },
      body: {
        customerId: customer.value.id,
        staffCode: staffCode.value,
        reason: reason.value,
        lines: lines.value.map((line) => ({
          sku: line.sku,
          quantity: line.quantity,
          unitAmount: line.unitAmount,
          discountAmount: line.discountAmount,
          taxCode: line.taxCode,
        })),
        tenders: [{
          method: tenderMethod.value,
          amount: totals.value.tendered,
          reference: null,
        }],
      },
    })) as PosDocument
    posted.value = document
    notice.value = `${document.txNumber} posted; change ${Number(document.change).toFixed(2)}.`
  } catch (caught) {
    handleError(caught)
  } finally {
    busy.value = false
  }
}

async function reprint(): Promise<void> {
  if (!posted.value) return
  busy.value = true
  error.value = null
  try {
    reprinted.value = (await unwrap(await api.client.GET('/api/v1/sales/documents/{txNumber}', {
      params: { path: { txNumber: posted.value.txNumber } },
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
  <div data-testid="pos-sale-page">
    <div class="d-flex align-center mb-4">
      <h1 class="text-h5">POS sale</h1>
      <v-spacer />
      <v-text-field v-model="staffCode" label="Staff code" density="compact" hide-details
        style="max-width: 140px" data-testid="pos-sale-staff-code" />
      <v-btn class="ml-2" variant="text" data-testid="pos-sale-new" @click="resetSale">New sale</v-btn>
    </div>

    <v-alert v-if="forbidden" type="error" variant="tonal" data-testid="pos-sale-forbidden">
      You do not have permission to post retail invoices.
    </v-alert>
    <v-alert v-else-if="error" type="error" variant="tonal" class="mb-4" data-testid="pos-sale-error">
      {{ error }}
    </v-alert>
    <v-alert v-if="notice" type="success" variant="tonal" class="mb-4" data-testid="pos-sale-notice">
      {{ notice }}
    </v-alert>

    <v-row>
      <v-col cols="12" md="8">
        <v-card variant="outlined" class="mb-4">
          <v-card-title>Customer</v-card-title>
          <v-card-text>
            <div class="d-flex ga-2 mb-2">
              <v-text-field v-model="customerQuery" label="Customer name, VIP code, or id"
                density="compact" hide-details data-testid="pos-sale-customer-search"
                @keyup.enter="searchCustomers" />
              <v-btn color="primary" :loading="busy" data-testid="pos-sale-customer-find"
                @click="searchCustomers">Find</v-btn>
            </div>
            <div v-if="customerResults.length" data-testid="pos-sale-customer-results">
              <v-btn v-for="result in customerResults" :key="result.id" variant="text" block
                class="justify-start text-none" :data-testid="`pos-sale-customer-option-${result.id}`"
                @click="selectCustomer(result)">
                {{ result.fullName ?? 'Customer ' + result.id }}
              </v-btn>
            </div>
            <p v-if="customer" class="text-body-2 mb-0" data-testid="pos-sale-customer-selected">
              {{ customer.fullName ?? 'Customer ' + customer.id }} (#{{ customer.id }})
            </p>
            <p v-else class="text-body-2 text-medium-emphasis mb-0">No customer selected.</p>
          </v-card-text>
        </v-card>

        <v-card variant="outlined" class="mb-4">
          <v-card-title>Items</v-card-title>
          <v-card-text>
            <div class="d-flex ga-2 mb-2">
              <v-text-field v-model="skuQuery" label="SKU or item name" density="compact" hide-details
                data-testid="pos-sale-sku-search" @keyup.enter="searchItems" />
              <v-btn color="primary" :loading="busy" data-testid="pos-sale-sku-find"
                @click="searchItems">Search</v-btn>
            </div>
            <div v-if="skuResults.length" data-testid="pos-sale-sku-results">
              <v-btn v-for="item in skuResults" :key="item.sku" variant="text" block
                class="justify-start text-none" :data-testid="`pos-sale-sku-option-${item.sku}`"
                @click="addItem(item)">
                {{ item.sku }} — {{ item.name ?? 'Item' }} ({{ Number(item.retailPrice ?? 0).toFixed(2) }})
              </v-btn>
            </div>
            <v-table density="compact" data-testid="pos-sale-lines">
              <thead>
                <tr>
                  <th>Item</th><th style="width: 90px">Qty</th><th style="width: 130px">Unit price</th>
                  <th style="width: 120px">Discount</th><th style="width: 80px">Tax</th>
                  <th class="text-right">Amount</th><th />
                </tr>
              </thead>
              <tbody>
                <tr v-for="(line, index) in lines" :key="line.sku" :data-testid="`pos-sale-line-${index}`">
                  <td>{{ line.sku }}<div class="text-caption text-medium-emphasis">{{ line.name ?? '' }}</div></td>
                  <td><v-text-field v-model.number="line.quantity" type="number" min="1" density="compact"
                    hide-details :data-testid="`pos-sale-line-${index}-qty`" /></td>
                  <td><v-text-field v-model.number="line.unitAmount" type="number" min="0" density="compact"
                    hide-details :data-testid="`pos-sale-line-${index}-price`" /></td>
                  <td><v-text-field v-model.number="line.discountAmount" type="number" min="0"
                    density="compact" hide-details :data-testid="`pos-sale-line-${index}-discount`" /></td>
                  <td><v-select v-model="line.taxCode" :items="taxCodes" density="compact" hide-details
                    :data-testid="`pos-sale-line-${index}-tax`" /></td>
                  <td class="text-right" :data-testid="`pos-sale-line-${index}-amount`">
                    {{ lineAmount(line).toFixed(2) }}
                  </td>
                  <td><v-btn icon="mdi-close" size="small" variant="text"
                    :data-testid="`pos-sale-line-${index}-remove`" @click="removeLine(index)" /></td>
                </tr>
                <tr v-if="lines.length === 0">
                  <td colspan="7" class="text-medium-emphasis" data-testid="pos-sale-lines-empty">
                    Search for a SKU to add the first line.
                  </td>
                </tr>
              </tbody>
            </v-table>
          </v-card-text>
        </v-card>
      </v-col>

      <v-col cols="12" md="4">
        <v-card variant="outlined" class="mb-4">
          <v-card-title>Payment</v-card-title>
          <v-card-text>
            <div class="d-flex justify-space-between text-body-2">
              <span>Subtotal</span><span data-testid="pos-sale-subtotal">{{ totals.subtotal.toFixed(2) }}</span>
            </div>
            <div class="d-flex justify-space-between text-body-2">
              <span>GST</span><span data-testid="pos-sale-tax-a">{{ totals.taxA.toFixed(2) }}</span>
            </div>
            <div class="d-flex justify-space-between text-body-2">
              <span>PST</span><span data-testid="pos-sale-tax-b">{{ totals.taxB.toFixed(2) }}</span>
            </div>
            <v-divider class="my-2" />
            <div class="d-flex justify-space-between text-body-1">
              <strong>Total</strong><strong data-testid="pos-sale-total">{{ totals.total.toFixed(2) }}</strong>
            </div>
            <v-select v-model="tenderMethod" :items="methods" item-title="title" item-value="value"
              label="Method" density="compact" class="mt-3" data-testid="pos-sale-method" />
            <v-text-field v-model.number="tenderAmount" type="number" min="0" label="Amount tendered"
              density="compact" :placeholder="totals.total.toFixed(2)" data-testid="pos-sale-tender" />
            <div class="d-flex justify-space-between text-body-2">
              <span>Change</span><span data-testid="pos-sale-change">{{ totals.change.toFixed(2) }}</span>
            </div>
            <div v-if="totals.short > 0" class="text-caption text-error" data-testid="pos-sale-short">
              {{ totals.short.toFixed(2) }} still due.
            </div>
            <v-text-field v-model="reason" label="Reason" density="compact" class="mt-3"
              data-testid="pos-sale-reason" />
            <v-btn color="primary" class="mt-2" block :loading="busy" :disabled="!canPost"
              data-testid="pos-sale-submit" @click="postSale">Post invoice</v-btn>
          </v-card-text>
        </v-card>

        <DocumentPanel v-if="posted" :document="posted" title="Receipt" />
        <v-btn v-if="posted" variant="text" class="mt-2" data-testid="pos-sale-reprint" @click="reprint">
          Reprint receipt
        </v-btn>
        <v-alert v-if="reprinted" type="info" variant="tonal" class="mt-2" data-testid="pos-sale-reprinted">
          Reprinted {{ reprinted.txNumber }} from the posted document.
        </v-alert>
        <DocumentPanel v-if="reprinted" :document="reprinted" title="Reprint" />
      </v-col>
    </v-row>
  </div>
</template>
