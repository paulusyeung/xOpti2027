<script setup lang="ts">
import { onMounted, reactive, ref } from 'vue'
import { api, unwrap } from '@/api/client'
import { AppError } from '@/api/problems'

interface ReturnableLine {
  rowNo: number; sku: string; originalQuantity: number; returnedQuantity: number
  availableQuantity: number; unitAmount: number | string; amount: number | string
  taxA: number | string; taxB: number | string; availableAmount: number | string
  taxCode: string | null
}
interface Returnable {
  txNumber: string; customerId: number; customerName: string | null
  totalAmount: number | string; termsCode: string | null; termsDays: number
  lines: ReturnableLine[]
}
interface ReturnLine {
  rowNo: number; originalRowNo: number; sku: string; quantity: number
  unitAmount: number | string; amount: number | string; taxA: number | string
  taxB: number | string; restock: boolean; dispositionReason: string | null
}
interface Tender { method: string; amount: number | string; reference: string | null }
interface ReturnDoc {
  txNumber: string; originalInvoiceNumber: string; customerId: number
  customerName: string | null; status: string; dateOfEntry: string
  totalAmount: number | string; refunded: number | string
  lines: ReturnLine[]; tenders: Tender[]
}
interface EditLine {
  originalRowNo: number; quantity: number; restock: boolean; dispositionReason: string
}
interface Page { items: ReturnDoc[]; nextCursor: string | null }

const returns = ref<ReturnDoc[]>([])
const returnable = ref<Returnable | null>(null)
const current = ref<ReturnDoc | null>(null)
const busy = ref(false)
const error = ref<string | null>(null)
const notice = ref<string | null>(null)
const invoiceNumber = ref('')
const staffCode = ref('0007')
const lines = ref<EditLine[]>([blankLine()])
const tenders = ref<Tender[]>([{ method: 'C', amount: 0, reference: null }])
const showPrint = reactive({ terminal: '01', reason: 'customer requested duplicate' })

function blankLine(): EditLine {
  return { originalRowNo: 1, quantity: 1, restock: true, dispositionReason: '' }
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
    const page = await unwrap(await api.client.GET('/api/v1/wholesale/returns', {
      params: { query: { pageSize: 20 } },
    })) as unknown as Page
    returns.value = page.items
  } catch (caught) { handleError(caught) } finally { busy.value = false }
}

async function loadReturnable(): Promise<void> {
  if (!invoiceNumber.value.trim()) return
  busy.value = true
  error.value = null
  try {
    returnable.value = await unwrap(await api.client.GET(
      '/api/v1/wholesale/invoices/{txNumber}/returnable', {
        params: { path: { txNumber: invoiceNumber.value.trim() } },
      })) as unknown as Returnable
    const first = returnable.value.lines.find((line) => line.availableQuantity > 0)
    lines.value = [{
      originalRowNo: first?.rowNo ?? 1, quantity: 1, restock: true,
      dispositionReason: '',
    }]
    notice.value = `Returnable invoice ${returnable.value.txNumber} loaded.`
  } catch (caught) { handleError(caught) } finally { busy.value = false }
}

async function openReturn(txNumber: string): Promise<void> {
  busy.value = true
  error.value = null
  try {
    const doc = await unwrap(await api.client.GET('/api/v1/wholesale/returns/{txNumber}', {
      params: { path: { txNumber } },
    })) as unknown as ReturnDoc
    current.value = doc
    invoiceNumber.value = doc.originalInvoiceNumber
    lines.value = doc.lines.map((line) => ({
      originalRowNo: line.originalRowNo, quantity: line.quantity,
      restock: line.restock, dispositionReason: line.dispositionReason ?? '',
    }))
    tenders.value = doc.tenders.map((tender) => ({ ...tender }))
  } catch (caught) { handleError(caught) } finally { busy.value = false }
}

function newReturn(): void {
  current.value = null
  returnable.value = null
  invoiceNumber.value = ''
  lines.value = [blankLine()]
  tenders.value = [{ method: 'C', amount: 0, reference: null }]
  notice.value = null
  error.value = null
}

function body() {
  return {
    originalInvoiceNumber: invoiceNumber.value,
    staffCode: staffCode.value,
    lines: lines.value.map((line) => ({
      originalRowNo: Number(line.originalRowNo),
      quantity: Number(line.quantity),
      restock: line.restock,
      dispositionReason: line.dispositionReason || null,
    })),
    tenders: tenders.value.map((tender) => ({
      method: tender.method, amount: Number(tender.amount), reference: tender.reference,
    })),
    reason: current.value ? 'wholesale return update' : 'wholesale return create',
  }
}

async function save(): Promise<void> {
  if (current.value && current.value.status !== 'draft') return
  busy.value = true
  error.value = null
  notice.value = null
  try {
    const key = `wr-ui-${Date.now()}-${Math.random().toString(36).slice(2)}`
    const doc = current.value && current.value.status === 'draft'
      ? await unwrap(await api.client.PUT('/api/v1/wholesale/returns/{txNumber}', {
        params: { path: { txNumber: current.value.txNumber } }, body: body(),
      }))
      : await unwrap(await api.client.POST('/api/v1/wholesale/returns', {
        body: body(), headers: { 'Idempotency-Key': key },
      }))
    current.value = doc as unknown as ReturnDoc
    notice.value = `Return ${current.value.txNumber} saved as ${current.value.status}.`
    await loadList()
  } catch (caught) { handleError(caught) } finally { busy.value = false }
}

async function post(): Promise<void> {
  if (!current.value) return
  busy.value = true
  error.value = null
  try {
    const key = `wr-post-${Date.now()}-${Math.random().toString(36).slice(2)}`
    const doc = await unwrap(await api.client.POST(
      '/api/v1/wholesale/returns/{txNumber}/post', {
        params: { path: { txNumber: current.value.txNumber } },
        body: {
          tenders: tenders.value.map((tender) => ({
            method: tender.method, amount: Number(tender.amount), reference: tender.reference,
          })),
          reason: 'wholesale return post',
        },
        headers: { 'Idempotency-Key': key },
      })) as unknown as ReturnDoc
    current.value = doc
    notice.value = `Return ${doc.txNumber} posted.`
    await loadList()
  } catch (caught) { handleError(caught) } finally { busy.value = false }
}

async function reprint(): Promise<void> {
  if (!current.value) return
  busy.value = true
  error.value = null
  try {
    const response = await api.request(
      `/api/v1/wholesale/returns/${current.value.txNumber}/prints`, {
        method: 'POST',
        headers: { 'content-type': 'application/json' },
        body: JSON.stringify({
          reprint: true, terminalCode: showPrint.terminal, reason: showPrint.reason,
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

onMounted(loadList)
</script>

<template>
  <div data-testid="wholesale-return-page">
    <div class="d-flex align-center mb-4">
      <h1 class="text-h5">Wholesale returns</h1>
      <v-spacer />
      <v-btn color="primary" data-testid="return-new" @click="newReturn">New return</v-btn>
    </div>

    <v-alert v-if="error" type="error" variant="tonal" class="mb-4" data-testid="return-error">
      {{ error }}
    </v-alert>
    <v-alert v-if="notice" type="success" variant="tonal" class="mb-4" data-testid="return-notice">
      {{ notice }}
    </v-alert>

    <v-card variant="outlined" class="mb-4">
      <v-card-title>Returns</v-card-title>
      <v-card-text>
        <v-table density="compact" data-testid="return-list">
          <thead><tr><th>Return</th><th>Invoice</th><th>Status</th><th>Credit</th><th /></tr></thead>
          <tbody>
            <tr v-for="row in returns" :key="row.txNumber">
              <td>{{ row.txNumber }}</td><td>{{ row.originalInvoiceNumber }}</td>
              <td>{{ row.status }}</td>
              <td>{{ Number(row.totalAmount).toFixed(4) }}</td>
              <td><v-btn size="small" variant="text"
                :data-testid="`return-select-${row.txNumber}`"
                @click="openReturn(row.txNumber)">Open</v-btn></td>
            </tr>
            <tr v-if="returns.length === 0">
              <td colspan="5" class="text-medium-emphasis">No wholesale returns.</td>
            </tr>
          </tbody>
        </v-table>
      </v-card-text>
    </v-card>

    <v-card variant="outlined">
      <v-card-title>
        {{ current ? `Return ${current.txNumber}` : 'Draft return' }}
        <span v-if="current" class="text-caption text-medium-emphasis ml-2"
          data-testid="return-status">{{ current.status }}</span>
      </v-card-title>
      <v-card-text>
        <div class="d-flex ga-2 align-center mb-3">
          <v-text-field v-model="invoiceNumber" label="Original invoice" density="compact"
            hide-details data-testid="return-invoice" />
          <v-text-field v-model="staffCode" label="Staff" density="compact" hide-details
            style="max-width: 110px" data-testid="return-staff" />
          <v-btn :loading="busy" data-testid="return-load" @click="loadReturnable">Load invoice</v-btn>
        </div>

        <v-table v-if="returnable" density="compact" data-testid="return-returnable">
          <thead><tr><th>Line</th><th>SKU</th><th>Original</th><th>Returned</th><th>Available</th><th>Credit</th></tr></thead>
          <tbody><tr v-for="line in returnable.lines" :key="line.rowNo">
            <td>{{ line.rowNo }}</td><td>{{ line.sku }}</td>
            <td>{{ line.originalQuantity }}</td><td>{{ line.returnedQuantity }}</td>
            <td>{{ line.availableQuantity }}</td>
            <td>{{ Number(line.availableAmount).toFixed(4) }}</td>
          </tr></tbody>
        </v-table>

        <v-btn size="small" variant="text" class="mt-2 mb-1" data-testid="return-add-line"
          @click="addLine">Add line</v-btn>
        <v-table density="compact" data-testid="return-lines">
          <thead><tr><th>Original line</th><th>Qty</th><th>Restock</th><th>Write-off reason</th><th /></tr></thead>
          <tbody>
            <tr v-for="(line, index) in lines" :key="index">
              <td><v-text-field v-model.number="line.originalRowNo" type="number" density="compact"
                hide-details :data-testid="`return-line-row-${index}`" /></td>
              <td><v-text-field v-model.number="line.quantity" type="number" density="compact"
                hide-details :data-testid="`return-line-qty-${index}`" /></td>
              <td><v-checkbox v-model="line.restock" density="compact" hide-details
                :data-testid="`return-line-restock-${index}`" /></td>
              <td><v-text-field v-model="line.dispositionReason" density="compact" hide-details
                :data-testid="`return-line-reason-${index}`" /></td>
              <td><v-btn size="small" variant="text" :data-testid="`return-line-remove-${index}`"
                @click="removeLine(index)">Remove</v-btn></td>
            </tr>
          </tbody>
        </v-table>

        <div v-for="(tender, index) in tenders" :key="`tender-${index}`" class="d-flex ga-2 mt-2">
          <v-text-field v-model="tender.method" label="Method" density="compact" hide-details
            style="max-width: 110px" :data-testid="`return-tender-method-${index}`" />
          <v-text-field v-model="tender.amount" type="number" label="Refund"
            density="compact" hide-details style="max-width: 160px"
            :data-testid="`return-tender-amount-${index}`" />
        </div>

        <p class="text-body-2 mt-3" data-testid="return-total">
          Credit {{ Number(current?.totalAmount ?? 0).toFixed(4) }}
          · refunded {{ Number(current?.refunded ?? 0).toFixed(4) }}
        </p>

        <div class="d-flex ga-2 mt-2">
          <v-btn color="primary" :loading="busy"
            :disabled="!!current && current.status !== 'draft'"
            data-testid="return-save" @click="save">Save draft</v-btn>
          <v-btn :loading="busy" :disabled="!current || current.status !== 'draft'"
            data-testid="return-post" @click="post">Post</v-btn>
          <v-btn variant="text" :loading="busy"
            :disabled="!current || current.status !== 'posted'"
            data-testid="return-reprint" @click="reprint">Reprint</v-btn>
        </div>
      </v-card-text>
    </v-card>
  </div>
</template>
