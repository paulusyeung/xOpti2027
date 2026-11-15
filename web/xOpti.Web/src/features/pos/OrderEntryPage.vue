<script setup lang="ts">
import { computed, onMounted, reactive, ref } from 'vue'
import { api, unwrap } from '@/api/client'
import { AppError } from '@/api/problems'

interface CustomerLookup {
  id: number
  fullName: string | null
  vipCode: string | null
}

interface ItemLookup {
  sku: string
  name: string | null
  retailPrice: number | null
  taxCode: string | null
  qtyOnHand: number
}

interface DocumentLine {
  rowNo: number
  sku: string
  qty: number
  unitAmount: number
  discountAmount: number
  unitCost?: number | null
  amount: number
  taxCode: string | null
}

interface SalesDocument {
  txNumber: string
  controlNumber: string
  kind: string
  status: string | null
  statusLabel: string
  customerId: number
  customerName: string | null
  refNumber: string | null
  totalSale: number
  taxA: number
  taxB: number
  grossSale: number
  totalAmount: number
  totalQty: number
  paid: number
  balance: number
  lines: DocumentLine[]
}

interface OrderLine {
  sku: string
  name: string | null
  quantity: number
  unitAmount: number
  discountAmount: number
  taxCode: string
}

const taxCodes = ['N', 'B', 'G', 'P', 'g', 'p']
const staffCode = ref('0001')
const customerQuery = ref('')
const customerResults = ref<CustomerLookup[]>([])
const customer = ref<CustomerLookup | null>(null)
const skuQuery = ref('')
const skuResults = ref<ItemLookup[]>([])
const lines = ref<OrderLine[]>([])
const depositAmount = ref(0)
const reason = ref('pos order')
const rates = reactive({ a: 0, b: 0 })
const openOrders = ref<SalesDocument[]>([])
const editingNumber = ref<string | null>(null)
const busy = ref(false)
const forbidden = ref(false)
const error = ref<string | null>(null)
const notice = ref<string | null>(null)

function handleError(caught: unknown): void {
  if (caught instanceof AppError) {
    forbidden.value = caught.kind === 'authorization' || caught.kind === 'unauthenticated'
    error.value = caught.userMessage
  } else {
    error.value = 'The request failed.'
  }
}

function round2(value: number): number {
  return Math.round((value + Number.EPSILON) * 100) / 100
}

function normalizeTaxCode(code: string | null): string {
  const trimmed = code?.trim() ?? ''
  return taxCodes.includes(trimmed) ? trimmed : 'B'
}

/** Mirrors TaxCalculator's legacy methods so the preview matches the posted totals. */
function taxFor(amount: number, code: string): { gst: number; pst: number; gross: number } {
  const gstRate = rates.a / 100
  const pstRate = rates.b / 100
  switch (code) {
    case 'B': {
      const gst = round2(amount * gstRate)
      const pst = round2(amount * pstRate)
      return { gst, pst, gross: round2(amount + gst + pst) }
    }
    case 'G': {
      const gst = round2(amount * gstRate)
      return { gst, pst: 0, gross: round2(amount + gst) }
    }
    case 'P': {
      const pst = round2(amount * pstRate)
      return { gst: 0, pst, gross: round2(amount + pst) }
    }
    case 'g': {
      const net = round2(amount / (1 + gstRate))
      return { gst: round2(amount - net), pst: 0, gross: amount }
    }
    case 'p': {
      const gst = round2(amount * gstRate)
      const pst = round2((amount + gst) * pstRate)
      return { gst, pst, gross: round2(amount + gst + pst) }
    }
    default:
      return { gst: 0, pst: 0, gross: amount }
  }
}

function lineAmount(line: OrderLine): number {
  return round2(line.unitAmount * line.quantity - line.discountAmount)
}

const totals = computed(() => {
  let subtotal = 0
  let taxA = 0
  let taxB = 0
  for (const line of lines.value) {
    const amount = lineAmount(line)
    const tax = taxFor(amount, line.taxCode)
    subtotal += amount
    taxA += tax.gst
    taxB += tax.pst
  }
  subtotal = round2(subtotal)
  taxA = round2(taxA)
  taxB = round2(taxB)
  const total = round2(subtotal + taxA + taxB)
  return { subtotal, taxA, taxB, total, balance: round2(total - Number(depositAmount.value || 0)) }
})

const canSave = computed(() =>
  customer.value !== null
  && lines.value.length > 0
  && lines.value.every((line) => line.quantity > 0 && line.unitAmount >= 0 && line.discountAmount >= 0))

async function loadContext(): Promise<void> {
  const context = await unwrap(await api.client.GET('/api/v1/sales/order-entry/context'))
  rates.a = Number(context.taxARate)
  rates.b = Number(context.taxBRate)
}

async function loadOrders(): Promise<void> {
  const page = await unwrap(await api.client.GET('/api/v1/sales/orders', {
    params: { query: { status: '0', pageSize: 10 } },
  }))
  openOrders.value = page.items as SalesDocument[]
}

async function searchCustomers(): Promise<void> {
  busy.value = true
  error.value = null
  try {
    customerResults.value = (await unwrap(await api.client.GET('/api/v1/sales/customers', {
      params: { query: { search: customerQuery.value, limit: 10 } },
    }))) as CustomerLookup[]
  } catch (caught) {
    handleError(caught)
  } finally {
    busy.value = false
  }
}

function selectCustomer(selected: CustomerLookup): void {
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
    }))) as ItemLookup[]
  } catch (caught) {
    handleError(caught)
  } finally {
    busy.value = false
  }
}

function addItem(item: ItemLookup): void {
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

function resetOrder(): void {
  editingNumber.value = null
  customer.value = null
  customerQuery.value = ''
  customerResults.value = []
  skuQuery.value = ''
  skuResults.value = []
  lines.value = []
  depositAmount.value = 0
  error.value = null
  notice.value = 'Started a new order.'
}

function applyDocument(document: SalesDocument): void {
  editingNumber.value = document.txNumber
  customer.value = {
    id: document.customerId,
    fullName: document.customerName,
    vipCode: null,
  }
  customerQuery.value = document.customerName ?? String(document.customerId)
  lines.value = document.lines.map((line) => ({
    sku: line.sku,
    name: null,
    quantity: line.qty,
    unitAmount: Number(line.unitAmount),
    discountAmount: Number(line.discountAmount),
    taxCode: normalizeTaxCode(line.taxCode),
  }))
  depositAmount.value = Number(document.paid)
}

async function resumeOrder(txNumber: string): Promise<void> {
  busy.value = true
  error.value = null
  try {
    const document = await unwrap(await api.client.GET('/api/v1/sales/documents/{txNumber}', {
      params: { path: { txNumber } },
    })) as SalesDocument
    applyDocument(document)
    notice.value = `Resumed ${document.txNumber}.`
  } catch (caught) {
    handleError(caught)
  } finally {
    busy.value = false
  }
}

async function saveOrder(): Promise<void> {
  if (customer.value === null || !canSave.value) {
    error.value = 'Select a customer and add at least one valid line.'
    return
  }

  busy.value = true
  error.value = null
  notice.value = null
  const body = {
    customerId: customer.value.id,
    staffCode: staffCode.value,
    depositAmount: Number(depositAmount.value || 0),
    reason: reason.value,
    lines: lines.value.map((line) => ({
      sku: line.sku,
      quantity: line.quantity,
      unitAmount: line.unitAmount,
      taxCode: line.taxCode,
      discountAmount: line.discountAmount,
    })),
  }

  try {
    const saved = editingNumber.value
      ? await unwrap(await api.client.PUT('/api/v1/sales/orders/{txNumber}', {
        params: { path: { txNumber: editingNumber.value } },
        body,
      }))
      : await unwrap(await api.client.POST('/api/v1/sales/orders', {
        headers: { 'Idempotency-Key': crypto.randomUUID() },
        body,
      }))
    const document = saved as SalesDocument
    editingNumber.value = document.txNumber
    notice.value = `${document.txNumber} saved with ${document.totalQty} item(s); total ${document.totalAmount}.`
    await loadOrders()
  } catch (caught) {
    handleError(caught)
  } finally {
    busy.value = false
  }
}

onMounted(async () => {
  try {
    await loadContext()
    await loadOrders()
  } catch (caught) {
    handleError(caught)
  }
})
</script>

<template>
  <div data-testid="pos-order-page">
    <div class="d-flex align-center mb-4">
      <h1 class="text-h5">POS order entry</h1>
      <v-spacer />
      <v-text-field v-model="staffCode" label="Staff code" density="compact" hide-details
        style="max-width: 140px" data-testid="pos-staff-code" />
      <v-btn class="ml-2" variant="text" data-testid="pos-new" @click="resetOrder">New order</v-btn>
    </div>

    <v-alert v-if="forbidden" type="error" variant="tonal" data-testid="pos-forbidden">
      You do not have permission to take sale orders.
    </v-alert>
    <v-alert v-else-if="error" type="error" variant="tonal" class="mb-4" data-testid="pos-error">
      {{ error }}
    </v-alert>
    <v-alert v-if="notice" type="success" variant="tonal" class="mb-4" data-testid="pos-notice">
      {{ notice }}
    </v-alert>

    <v-row>
      <v-col cols="12" md="8">
        <v-card variant="outlined" class="mb-4">
          <v-card-title>Customer</v-card-title>
          <v-card-text>
            <div class="d-flex ga-2 mb-2">
              <v-text-field v-model="customerQuery" label="Customer name, VIP code, or id"
                density="compact" hide-details data-testid="pos-customer-search"
                @keyup.enter="searchCustomers" />
              <v-btn color="primary" :loading="busy" data-testid="pos-customer-find"
                @click="searchCustomers">Find</v-btn>
            </div>
            <div v-if="customerResults.length" data-testid="pos-customer-results">
              <v-btn v-for="result in customerResults" :key="result.id" variant="text" block
                class="justify-start text-none" :data-testid="`pos-customer-option-${result.id}`"
                @click="selectCustomer(result)">
                {{ result.fullName ?? 'Customer ' + result.id }}
                <span v-if="result.vipCode" class="ml-2 text-caption">VIP {{ result.vipCode }}</span>
              </v-btn>
            </div>
            <p v-if="customer" class="text-body-2 mb-0" data-testid="pos-customer-selected">
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
                data-testid="pos-sku-search" @keyup.enter="searchItems" />
              <v-btn color="primary" :loading="busy" data-testid="pos-sku-find"
                @click="searchItems">Search</v-btn>
            </div>
            <div v-if="skuResults.length" data-testid="pos-sku-results">
              <v-btn v-for="item in skuResults" :key="item.sku" variant="text" block
                class="justify-start text-none" :data-testid="`pos-sku-option-${item.sku}`"
                @click="addItem(item)">
                {{ item.sku }} — {{ item.name ?? 'Item' }} ({{ item.retailPrice ?? 0 }})
              </v-btn>
            </div>
            <v-table density="compact" data-testid="pos-lines">
              <thead>
                <tr>
                  <th>Item</th>
                  <th style="width: 90px">Qty</th>
                  <th style="width: 130px">Unit price</th>
                  <th style="width: 120px">Discount</th>
                  <th style="width: 80px">Tax</th>
                  <th class="text-right">Amount</th>
                  <th />
                </tr>
              </thead>
              <tbody>
                <tr v-for="(line, index) in lines" :key="line.sku" :data-testid="`pos-line-${index}`">
                  <td>
                    <div class="text-body-2">{{ line.sku }}</div>
                    <div class="text-caption text-medium-emphasis">{{ line.name ?? '' }}</div>
                  </td>
                  <td>
                    <v-text-field v-model.number="line.quantity" type="number" min="1" density="compact"
                      hide-details :data-testid="`pos-line-${index}-qty`" />
                  </td>
                  <td>
                    <v-text-field v-model.number="line.unitAmount" type="number" min="0" density="compact"
                      hide-details :data-testid="`pos-line-${index}-price`" />
                  </td>
                  <td>
                    <v-text-field v-model.number="line.discountAmount" type="number" min="0"
                      density="compact" hide-details :data-testid="`pos-line-${index}-discount`" />
                  </td>
                  <td>
                    <v-select v-model="line.taxCode" :items="taxCodes" density="compact" hide-details
                      :data-testid="`pos-line-${index}-tax`" />
                  </td>
                  <td class="text-right" :data-testid="`pos-line-${index}-amount`">
                    {{ lineAmount(line).toFixed(2) }}
                  </td>
                  <td>
                    <v-btn icon="mdi-close" size="small" variant="text"
                      :data-testid="`pos-line-${index}-remove`" @click="removeLine(index)" />
                  </td>
                </tr>
                <tr v-if="lines.length === 0">
                  <td colspan="7" class="text-medium-emphasis" data-testid="pos-lines-empty">
                    Search for a SKU to add the first line.
                  </td>
                </tr>
              </tbody>
            </v-table>
          </v-card-text>
        </v-card>

        <v-card variant="outlined">
          <v-card-title>Totals</v-card-title>
          <v-card-text>
            <div class="d-flex justify-space-between text-body-2">
              <span>Subtotal</span><span data-testid="pos-subtotal">{{ totals.subtotal.toFixed(2) }}</span>
            </div>
            <div class="d-flex justify-space-between text-body-2">
              <span>GST</span><span data-testid="pos-tax-a">{{ totals.taxA.toFixed(2) }}</span>
            </div>
            <div class="d-flex justify-space-between text-body-2">
              <span>PST</span><span data-testid="pos-tax-b">{{ totals.taxB.toFixed(2) }}</span>
            </div>
            <v-divider class="my-2" />
            <div class="d-flex justify-space-between text-body-1">
              <strong>Total</strong><strong data-testid="pos-total">{{ totals.total.toFixed(2) }}</strong>
            </div>
            <div class="d-flex justify-space-between text-body-2 mt-2">
              <span>Deposit</span>
              <v-text-field v-model.number="depositAmount" type="number" min="0" density="compact"
                hide-details style="max-width: 130px" data-testid="pos-deposit" />
            </div>
            <div class="d-flex justify-space-between text-body-2 mt-2">
              <span>Balance</span><span data-testid="pos-balance">{{ totals.balance.toFixed(2) }}</span>
            </div>
            <v-text-field v-model="reason" label="Reason" density="compact" class="mt-3"
              data-testid="pos-reason" />
            <v-btn color="primary" class="mt-2" :loading="busy" :disabled="!canSave"
              data-testid="pos-save" @click="saveOrder">
              {{ editingNumber ? 'Update order' : 'Save order' }}
            </v-btn>
          </v-card-text>
        </v-card>
      </v-col>

      <v-col cols="12" md="4">
        <v-card variant="outlined">
          <v-card-title>Open orders</v-card-title>
          <v-card-text>
            <v-table density="compact" data-testid="pos-open-orders">
              <thead><tr><th>Order</th><th>Total</th><th /></tr></thead>
              <tbody>
                <tr v-for="order in openOrders" :key="order.txNumber">
                  <td>{{ order.txNumber }}</td>
                  <td>{{ order.totalAmount.toFixed(2) }}</td>
                  <td>
                    <v-btn size="small" variant="text" :data-testid="`pos-resume-${order.txNumber}`"
                      @click="resumeOrder(order.txNumber)">Resume</v-btn>
                  </td>
                </tr>
                <tr v-if="openOrders.length === 0">
                  <td colspan="3" class="text-medium-emphasis" data-testid="pos-open-orders-empty">
                    No open orders.
                  </td>
                </tr>
              </tbody>
            </v-table>
          </v-card-text>
        </v-card>
      </v-col>
    </v-row>
  </div>
</template>
