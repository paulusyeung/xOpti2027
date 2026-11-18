<script setup lang="ts">
import { onMounted, reactive, ref } from 'vue'
import { api, unwrap } from '@/api/client'
import { AppError } from '@/api/problems'

interface InvoiceLine {
  rowNo: number
  sku: string
  description: string | null
  quantity: number
  unitAmount: number | string
  discountAmount: number | string
  amount: number | string
  taxCode: string | null
  backorderQuantity: number
  overrideReason: string | null
}
interface Tender { method: string; amount: number | string; reference: string | null }
interface Backorder {
  id: number; sku: string; orderedQuantity: number; shippedQuantity: number
  remainingQuantity: number; status: string
}
interface Invoice {
  txNumber: string; customerId: number; customerName: string | null
  status: string; dateOfEntry: string; totalSale: number | string
  taxA: number | string; taxB: number | string; totalAmount: number | string
  paid: number | string; termsCode: string | null; dueDate: string | null
  shippingMethod: string | null; shipToName: string | null; shipToAddress: string | null
  shippingInstructions: string | null; purchaseOrderNumber: string | null
  lines: InvoiceLine[]; tenders: Tender[]
}
interface EditLine {
  sku: string; quantity: number; unitAmount: string | number; discountAmount: string | number
  taxCode: string; backorderQuantity: number; description: string; overrideReason: string
}
interface PackingLine {
  rowNo: number; sku: string; description: string | null; quantity: number
  backorderQuantity: number; unitAmount: number | null; amount: number | null
}
interface PackingList {
  txNumber: string; includesPrices: boolean; shipToName: string | null
  shippingMethod: string | null; shipToAddress: string | null
  purchaseOrderNumber: string | null; lines: PackingLine[]
}
interface Page { items: Invoice[]; nextCursor: string | null }

const invoices = ref<Invoice[]>([])
const current = ref<Invoice | null>(null)
const backorders = ref<Backorder[]>([])
const packing = ref<PackingList | null>(null)
const includePrices = ref(false)
const busy = ref(false)
const error = ref<string | null>(null)
const notice = ref<string | null>(null)
const customerId = ref(0)
const staffCode = ref('0007')
const editing = ref(false)
const lines = ref<EditLine[]>([blankLine()])
const tenders = ref<Tender[]>([{ method: 'C', amount: 0, reference: null }])
const shipping = reactive({
  shippingMethod: 'Courier', shipToName: '', shipToAddress: '',
  shippingInstructions: '', purchaseOrderNumber: '', dueDate: '',
})

function blankLine(): EditLine {
  return {
    sku: '', quantity: 1, unitAmount: '', discountAmount: 0, taxCode: 'B',
    backorderQuantity: 0, description: '', overrideReason: '',
  }
}

function handleError(caught: unknown): void {
  if (caught instanceof AppError) {
    if (caught.kind === 'validation') {
      const fields = caught.fieldErrors as Record<string, readonly string[]>
      error.value = Object.values(fields)[0]?.[0] ?? caught.userMessage
    } else error.value = caught.userMessage
  } else error.value = 'The request failed.'
}

async function loadList(): Promise<void> {
  busy.value = true
  try {
    const page = await unwrap(await api.client.GET('/api/v1/wholesale/invoices', {
      params: { query: { pageSize: 20 } },
    })) as unknown as Page
    invoices.value = page.items
  } catch (caught) { handleError(caught) } finally { busy.value = false }
}

function linePayload(line: EditLine) {
  return {
    sku: line.sku,
    quantity: Number(line.quantity),
    unitAmount: line.unitAmount === '' ? null : Number(line.unitAmount),
    discountAmount: Number(line.discountAmount || 0),
    taxCode: line.taxCode,
    overrideReason: line.overrideReason || null,
    description: line.description || null,
    backorderQuantity: Number(line.backorderQuantity || 0),
  }
}

function invoicePayload() {
  return {
    customerId: Number(customerId.value),
    staffCode: staffCode.value,
    lines: lines.value.map(linePayload),
    tenders: tenders.value.map((tender) => ({
      method: tender.method,
      amount: Number(tender.amount),
      reference: tender.reference,
    })),
    shipping: {
      shippingMethod: shipping.shippingMethod || null,
      shipToName: shipping.shipToName || null,
      shipToAddress: shipping.shipToAddress || null,
      shippingInstructions: shipping.shippingInstructions || null,
      purchaseOrderNumber: shipping.purchaseOrderNumber || null,
      dueDate: shipping.dueDate || null,
    },
    reason: current.value ? 'wholesale invoice update' : 'wholesale invoice create',
  }
}

function loadInvoice(invoice: Invoice): void {
  current.value = invoice
  editing.value = true
  customerId.value = invoice.customerId
  lines.value = invoice.lines.map((line) => ({
    sku: line.sku,
    quantity: line.quantity,
    unitAmount: Number(line.unitAmount),
    discountAmount: Number(line.discountAmount),
    taxCode: line.taxCode ?? 'B',
    backorderQuantity: line.backorderQuantity,
    description: line.description ?? '',
    overrideReason: line.overrideReason ?? '',
  }))
  tenders.value = invoice.tenders.map((tender) => ({ ...tender }))
  shipping.shippingMethod = invoice.shippingMethod ?? ''
  shipping.shipToName = invoice.shipToName ?? ''
  shipping.shipToAddress = invoice.shipToAddress ?? ''
  shipping.shippingInstructions = invoice.shippingInstructions ?? ''
  shipping.purchaseOrderNumber = invoice.purchaseOrderNumber ?? ''
  shipping.dueDate = invoice.dueDate ?? ''
  loadBackorders(invoice.txNumber)
}

async function openInvoice(txNumber: string): Promise<void> {
  busy.value = true
  error.value = null
  try {
    const invoice = await unwrap(await api.client.GET('/api/v1/wholesale/invoices/{txNumber}', {
      params: { path: { txNumber } },
    })) as unknown as Invoice
    loadInvoice(invoice)
  } catch (caught) { handleError(caught) } finally { busy.value = false }
}

async function loadBackorders(txNumber: string): Promise<void> {
  try {
    backorders.value = await unwrap(await api.client.GET(
      '/api/v1/wholesale/invoices/{txNumber}/backorders', {
        params: { path: { txNumber } },
      })) as unknown as Backorder[]
  } catch { backorders.value = [] }
}

function newInvoice(): void {
  current.value = null
  editing.value = false
  lines.value = [blankLine()]
  tenders.value = [{ method: 'C', amount: 0, reference: null }]
  backorders.value = []
  Object.assign(shipping, {
    shippingMethod: 'Courier', shipToName: '', shipToAddress: '',
    shippingInstructions: '', purchaseOrderNumber: '', dueDate: '',
  })
  notice.value = null
  error.value = null
}

async function save(): Promise<void> {
  if (current.value && current.value.status !== 'draft') return
  busy.value = true
  error.value = null
  notice.value = null
  try {
    const body = invoicePayload()
    const key = `wc-ui-${Date.now()}-${Math.random().toString(36).slice(2)}`
    const invoice = current.value && current.value.status === 'draft'
      ? await unwrap(await api.client.PUT('/api/v1/wholesale/invoices/{txNumber}', {
        params: { path: { txNumber: current.value.txNumber } }, body,
      }))
      : await unwrap(await api.client.POST('/api/v1/wholesale/invoices', {
        body,
        headers: { 'Idempotency-Key': key },
      }))
    loadInvoice(invoice as unknown as Invoice)
    notice.value = `Invoice ${(invoice as unknown as Invoice).txNumber} saved as ${(invoice as unknown as Invoice).status}.`
    await loadList()
  } catch (caught) { handleError(caught) } finally { busy.value = false }
}

async function post(): Promise<void> {
  if (!current.value) return
  busy.value = true
  error.value = null
  try {
    const key = `wc-post-${Date.now()}-${Math.random().toString(36).slice(2)}`
    const invoice = await unwrap(await api.client.POST(
      '/api/v1/wholesale/invoices/{txNumber}/post', {
        params: { path: { txNumber: current.value.txNumber } },
        body: {
          tenders: tenders.value.map((tender) => ({
            method: tender.method, amount: Number(tender.amount), reference: tender.reference,
          })),
          reason: 'wholesale invoice post',
        },
        headers: { 'Idempotency-Key': key },
      })) as unknown as Invoice
    loadInvoice(invoice)
    notice.value = `Invoice ${invoice.txNumber} posted.`
    await loadList()
  } catch (caught) { handleError(caught) } finally { busy.value = false }
}

async function loadPackingList(): Promise<void> {
  if (!current.value) return
  busy.value = true
  error.value = null
  try {
    packing.value = await unwrap(await api.client.GET(
      '/api/v1/wholesale/invoices/{txNumber}/packing-list', {
        params: {
          path: { txNumber: current.value.txNumber },
          query: { includePrices: includePrices.value },
        },
      })) as unknown as PackingList
    notice.value = `Packing list loaded for ${packing.value.txNumber}.`
  } catch (caught) { handleError(caught) } finally { busy.value = false }
}

async function printPacking(reprint: boolean): Promise<void> {
  if (!current.value) return
  busy.value = true
  error.value = null
  try {
    const response = await api.request(
      `/api/v1/wholesale/invoices/${current.value.txNumber}/packing-list/prints`, {
        method: 'POST',
        headers: { 'content-type': 'application/json' },
        body: JSON.stringify({
          includePrices: includePrices.value, reprint,
          terminalCode: '01', reason: 'packing list print',
        }),
      })
    if (!response.ok) throw new Error('packing list print failed')
    await response.blob()
    notice.value = reprint
      ? `Packing-list reprint generated for ${current.value.txNumber}.`
      : `Packing list printed for ${current.value.txNumber}.`
  } catch (caught) { handleError(caught) } finally { busy.value = false }
}

async function reprint(): Promise<void> {
  if (!current.value) return
  busy.value = true
  error.value = null
  try {
    const response = await api.request(
      `/api/v1/wholesale/invoices/${current.value.txNumber}/prints`, {
        method: 'POST',
        headers: { 'content-type': 'application/json' },
        body: JSON.stringify({
          reprint: true, terminalCode: '01', reason: 'customer requested duplicate',
        }),
      })
    if (!response.ok) throw new Error('reprint failed')
    await response.blob()
    notice.value = `Reprint generated for ${current.value.txNumber}.`
  } catch (caught) { handleError(caught) } finally { busy.value = false }
}

function addLine(): void { lines.value.push(blankLine()) }
function removeLine(index: number): void {
  if (lines.value.length > 1) lines.value.splice(index, 1)
}
function addTender(): void {
  tenders.value.push({ method: 'C', amount: 0, reference: null })
}
function removeTender(index: number): void {
  if (tenders.value.length > 1) tenders.value.splice(index, 1)
}

onMounted(loadList)
</script>

<template>
  <div data-testid="wholesale-invoice-page">
    <div class="d-flex align-center mb-4">
      <h1 class="text-h5">Wholesale invoices</h1>
      <v-spacer />
      <v-btn color="primary" data-testid="invoice-new" @click="newInvoice">New invoice</v-btn>
    </div>

    <v-alert v-if="error" type="error" variant="tonal" class="mb-4" data-testid="invoice-error">
      {{ error }}
    </v-alert>
    <v-alert v-if="notice" type="success" variant="tonal" class="mb-4" data-testid="invoice-notice">
      {{ notice }}
    </v-alert>

    <v-card variant="outlined" class="mb-4">
      <v-card-title>Invoices</v-card-title>
      <v-card-text>
        <v-table density="compact" data-testid="invoice-list">
          <thead><tr><th>Invoice</th><th>Customer</th><th>Status</th><th>Total</th><th /></tr></thead>
          <tbody>
            <tr v-for="invoice in invoices" :key="invoice.txNumber">
              <td>{{ invoice.txNumber }}</td>
              <td>{{ invoice.customerName ?? invoice.customerId }}</td>
              <td>{{ invoice.status }}</td>
              <td>{{ Number(invoice.totalAmount).toFixed(4) }}</td>
              <td><v-btn size="small" variant="text"
                :data-testid="`invoice-select-${invoice.txNumber}`"
                @click="openInvoice(invoice.txNumber)">Open</v-btn></td>
            </tr>
            <tr v-if="invoices.length === 0">
              <td colspan="5" class="text-medium-emphasis">No wholesale invoices.</td>
            </tr>
          </tbody>
        </v-table>
      </v-card-text>
    </v-card>

    <v-card variant="outlined">
      <v-card-title>
        {{ current ? `Invoice ${current.txNumber}` : 'Draft invoice' }}
        <span v-if="current" class="text-caption text-medium-emphasis ml-2"
          data-testid="invoice-status">{{ current.status }}</span>
      </v-card-title>
      <v-card-text>
        <v-row dense>
          <v-col cols="12" md="3">
            <v-text-field v-model.number="customerId" type="number" label="Customer id"
              density="compact" data-testid="invoice-customer" />
          </v-col>
          <v-col cols="12" md="2">
            <v-text-field v-model="staffCode" label="Staff" density="compact"
              data-testid="invoice-staff" />
          </v-col>
          <v-col cols="12" md="3">
            <v-text-field v-model="shipping.purchaseOrderNumber" label="PO number"
              density="compact" data-testid="invoice-po" />
          </v-col>
          <v-col cols="12" md="2">
            <v-text-field v-model="shipping.shippingMethod" label="Shipping method"
              density="compact" data-testid="invoice-shipping-method" />
          </v-col>
          <v-col cols="12" md="2">
            <v-text-field v-model="shipping.shipToName" label="Ship-to name"
              density="compact" data-testid="invoice-ship-name" />
          </v-col>
          <v-col cols="12" md="4">
            <v-text-field v-model="shipping.shipToAddress" label="Ship-to address"
              density="compact" data-testid="invoice-ship-address" />
          </v-col>
          <v-col cols="12" md="4">
            <v-text-field v-model="shipping.shippingInstructions" label="Instructions"
              density="compact" data-testid="invoice-instructions" />
          </v-col>
          <v-col cols="12" md="2">
            <v-text-field v-model="shipping.dueDate" type="date" label="Due date"
              density="compact" data-testid="invoice-due-date" />
          </v-col>
        </v-row>

        <v-btn size="small" variant="text" class="mb-2" data-testid="invoice-add-line"
          @click="addLine">Add line</v-btn>
        <v-table density="compact" data-testid="invoice-lines">
          <thead><tr>
            <th>SKU</th><th>Qty</th><th>Unit</th><th>Discount</th><th>Tax</th>
            <th>Backorder</th><th>Description</th><th />
          </tr></thead>
          <tbody>
            <tr v-for="(line, index) in lines" :key="index">
              <td><v-text-field v-model="line.sku" density="compact" hide-details
                :data-testid="`invoice-line-sku-${index}`" /></td>
              <td><v-text-field v-model.number="line.quantity" type="number" density="compact"
                hide-details :data-testid="`invoice-line-qty-${index}`" /></td>
              <td><v-text-field v-model="line.unitAmount" type="number" density="compact"
                hide-details :data-testid="`invoice-line-price-${index}`" /></td>
              <td><v-text-field v-model="line.discountAmount" type="number" density="compact"
                hide-details :data-testid="`invoice-line-discount-${index}`" /></td>
              <td><v-text-field v-model="line.taxCode" density="compact" hide-details
                :data-testid="`invoice-line-tax-${index}`" /></td>
              <td><v-text-field v-model.number="line.backorderQuantity" type="number"
                density="compact" hide-details :data-testid="`invoice-line-backorder-${index}`" /></td>
              <td><v-text-field v-model="line.description" density="compact" hide-details
                :data-testid="`invoice-line-description-${index}`" /></td>
              <td><v-btn size="small" variant="text" :data-testid="`invoice-line-remove-${index}`"
                @click="removeLine(index)">Remove</v-btn></td>
            </tr>
          </tbody>
        </v-table>

        <v-btn size="small" variant="text" class="mt-2" data-testid="invoice-add-tender"
          @click="addTender">Add payment</v-btn>
        <div v-for="(tender, index) in tenders" :key="`tender-${index}`" class="d-flex ga-2 mt-2">
          <v-text-field v-model="tender.method" label="Method" density="compact" hide-details
            style="max-width: 110px" :data-testid="`invoice-tender-method-${index}`" />
          <v-text-field v-model="tender.amount" type="number" label="Amount" density="compact"
            hide-details style="max-width: 160px" :data-testid="`invoice-tender-amount-${index}`" />
          <v-btn size="small" variant="text" :data-testid="`invoice-tender-remove-${index}`"
            @click="removeTender(index)">Remove</v-btn>
        </div>

        <p class="text-body-2 mt-3" data-testid="invoice-total">
          Total {{ Number(current?.totalAmount ?? 0).toFixed(4) }}
          · paid {{ Number(current?.paid ?? 0).toFixed(4) }}
          · tax {{ Number(current?.taxA ?? 0).toFixed(4) }}/{{ Number(current?.taxB ?? 0).toFixed(4) }}
        </p>

        <div class="d-flex ga-2 mt-2">
          <v-btn color="primary" :loading="busy"
            :disabled="!!current && current.status !== 'draft'"
            data-testid="invoice-save" @click="save">
            Save draft
          </v-btn>
          <v-btn :loading="busy" :disabled="!current || current.status !== 'draft'"
            data-testid="invoice-post" @click="post">Post</v-btn>
          <v-btn variant="text" :loading="busy"
            :disabled="!current || current.status !== 'posted'"
            data-testid="invoice-reprint" @click="reprint">Reprint</v-btn>
        </div>

        <v-divider class="my-4" />
        <div class="d-flex ga-2 align-center">
          <v-checkbox v-model="includePrices" label="Include prices (approved)"
            density="compact" hide-details data-testid="packing-list-prices" />
          <v-btn :loading="busy" :disabled="!current || current.status !== 'posted'"
            data-testid="packing-list-open" @click="loadPackingList">Packing list</v-btn>
          <v-btn variant="text" :loading="busy"
            :disabled="!current || current.status !== 'posted'"
            data-testid="packing-list-print" @click="printPacking(false)">Print</v-btn>
          <v-btn variant="text" :loading="busy"
            :disabled="!current || current.status !== 'posted'"
            data-testid="packing-list-reprint" @click="printPacking(true)">Reprint</v-btn>
        </div>
        <div v-if="packing" data-testid="packing-list-result" class="text-body-2 mt-2">
          <div>Ship to {{ packing.shipToName }} · {{ packing.shippingMethod }} · PO {{ packing.purchaseOrderNumber }}</div>
          <div v-for="line in packing.lines" :key="line.rowNo">
            {{ line.sku }} qty {{ line.quantity }}
            <span v-if="line.backorderQuantity > 0">· backordered {{ line.backorderQuantity }}</span>
            <span v-if="packing.includesPrices">
              · unit {{ Number(line.unitAmount ?? 0).toFixed(4) }}
            </span>
          </div>
        </div>

        <v-table v-if="backorders.length" density="compact" class="mt-3"
          data-testid="invoice-backorders">
          <thead><tr><th>SKU</th><th>Ordered</th><th>Shipped</th><th>Remaining</th><th>Status</th></tr></thead>
          <tbody><tr v-for="row in backorders" :key="row.id">
            <td>{{ row.sku }}</td><td>{{ row.orderedQuantity }}</td>
            <td>{{ row.shippedQuantity }}</td><td>{{ row.remainingQuantity }}</td>
            <td>{{ row.status }}</td>
          </tr></tbody>
        </v-table>
      </v-card-text>
    </v-card>
  </div>
</template>
