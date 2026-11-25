<script setup lang="ts">
import { computed, ref } from 'vue'
import { useRouter } from 'vue-router'
import { api } from '@/api/client'

// Items from eOptical6DAO/frmSpecialReports.frm, Form_Load (lines 200-209).
// The legacy combo is sorted, so the xOpti list is sorted too.
const REPORTS = [
  { title: 'Bar Code Tag', to: '/admin/catalogue' },
  { title: 'Claims Receipt', to: '/admin/claims' },
  { title: 'Invoice', to: '/admin/wholesale/invoices' },
  { title: 'Order', to: '/admin/optical' },
  { title: 'Prescription - By Customer', to: '/admin/prescriptions' },
  { title: 'Prescription - By Order/Invoice Number', to: '/admin/prescriptions' },
  { title: 'Stock Adjustment', to: '/admin/stock-ops' },
  { title: 'Stock Received', to: '/admin/purchasing' },
  { title: 'Stock Rejected', to: '/admin/stock-ops' },
  { title: 'Stock Take Report', to: '/admin/stock-take' },
].sort((left, right) => left.title.localeCompare(right.title))

const router = useRouter()
const selected = ref<string>(REPORTS[0]!.title)
const txDialogOpen = ref(false)
const fromNumber = ref('1')
const toNumber = ref('99999999')
const printing = ref(false)
const error = ref<string | null>(null)
const claimDialogOpen = ref(false)
const orderInvoiceNumber = ref('')
const claimPrinting = ref(false)
const claimError = ref<string | null>(null)

const selectedReport = computed(() => REPORTS.find((report) => report.title === selected.value))

function reset(): void {
  selected.value = REPORTS[0]!.title
}

function resetRange(): void {
  fromNumber.value = '1'
  toNumber.value = '99999999'
}

function open(): void {
  if (selected.value === 'Bar Code Tag') {
    error.value = null
    txDialogOpen.value = true
    return
  }
  if (selected.value === 'Claims Receipt') {
    claimError.value = null
    claimDialogOpen.value = true
    return
  }
  if (selectedReport.value) {
    void router.push(selectedReport.value.to)
  }
}

/** Open the inline preview so the PDF viewer's Save button uses the report name. */
function openPdfPreview(url: string): void {
  const preview = window.open(url, '_blank')
  if (preview) {
    preview.opener = null
    preview.focus()
    return
  }
  // A pop-up blocker can reject a window opened after the await.
  const link = document.createElement('a')
  link.href = url
  link.target = '_blank'
  link.rel = 'noopener'
  link.click()
}

async function problemMessage(response: Response, fallback: string): Promise<string> {
  try {
    const problem = await response.json() as { detail?: string; title?: string }
    return problem.detail || problem.title || fallback
  } catch {
    return fallback
  }
}

async function printBarCodeTags(): Promise<void> {
  const from = fromNumber.value.trim()
  const to = toNumber.value.trim()
  if (!from || !to) return
  printing.value = true
  error.value = null
  const fallback = 'The bar code tag report could not be generated.'
  try {
    const response = await api.request('/api/v1/special-reports/bar-code-tag/print', {
      method: 'POST',
      headers: { 'content-type': 'application/json' },
      body: JSON.stringify({
        fromNumber: from,
        toNumber: to,
        duplicate: false,
        reason: 'bar code tag print',
      }),
    })
    if (!response.ok) throw new Error(await problemMessage(response, fallback))
    // The POST validates the range and keeps the spinner up until the report
    // is rendered; the GET preview serves it inline with a readable filename.
    await response.blob()
    const params = new URLSearchParams({ fromNumber: from, toNumber: to })
    openPdfPreview(`/api/v1/special-reports/bar-code-tag/preview?${params}`)
    txDialogOpen.value = false
  } catch (caught) {
    error.value = caught instanceof Error ? caught.message : fallback
  } finally {
    printing.value = false
  }
}

async function printClaimReceipt(): Promise<void> {
  const orderInvoice = orderInvoiceNumber.value.trim()
  if (!orderInvoice) return
  claimPrinting.value = true
  claimError.value = null
  const fallback = 'The claims receipt could not be generated.'
  try {
    const response = await api.request('/api/v1/special-reports/claim-receipt/print', {
      method: 'POST',
      headers: { 'content-type': 'application/json' },
      body: JSON.stringify({ orderInvoiceNumber: orderInvoice, reason: 'claim receipt print' }),
    })
    if (!response.ok) throw new Error(await problemMessage(response, fallback))
    await response.blob()
    const params = new URLSearchParams({ orderInvoiceNumber: orderInvoice })
    openPdfPreview(`/api/v1/special-reports/claim-receipt/preview?${params}`)
    claimDialogOpen.value = false
  } catch (caught) {
    claimError.value = caught instanceof Error ? caught.message : fallback
  } finally {
    claimPrinting.value = false
  }
}

function exit(): void {
  void router.push('/')
}
</script>

<template>
  <v-card rounded="xl" elevation="0" class="panel-card pa-6" data-testid="special-reports-page">
    <v-card-title class="text-subtitle-1 px-0 pt-0">Report Selection</v-card-title>
    <v-card-text class="px-0">
      <v-select
        v-model="selected"
        :items="REPORTS.map((report) => report.title)"
        label="Report Name"
        variant="outlined"
        density="comfortable"
        data-testid="special-report-select"
      />
      <p class="text-caption text-medium-emphasis mt-3 mb-0">
        These are the legacy Special Reports selections. The corresponding xOpti screen opens
        when you choose OK; Crystal report layouts are not bundled in this release.
      </p>
    </v-card-text>
    <v-card-actions class="px-0 pb-0">
      <v-btn color="primary" data-testid="special-report-ok" @click="open">OK</v-btn>
      <v-btn variant="text" data-testid="special-report-reset" @click="reset">Reset</v-btn>
      <v-btn variant="text" data-testid="special-report-exit" @click="exit">Exit</v-btn>
    </v-card-actions>

    <v-dialog v-model="txDialogOpen" max-width="480">
      <v-card rounded="xl" data-testid="barcode-print-dialog">
        <v-card-title>Bar Code Tag</v-card-title>
        <v-card-text>
          <v-row dense>
            <v-col cols="12" sm="2">
              <v-text-field label="Prefix" model-value="SR" disabled hide-details />
            </v-col>
            <v-col cols="12" sm="4">
              <v-text-field
                v-model="fromNumber"
                label="From"
                data-testid="barcode-from-number"
                hide-details
              />
            </v-col>
            <v-col cols="12" sm="2">
              <v-text-field label="Prefix" model-value="SR" disabled hide-details />
            </v-col>
            <v-col cols="12" sm="4">
              <v-text-field
                v-model="toNumber"
                label="To"
                data-testid="barcode-to-number"
                hide-details
              />
            </v-col>
          </v-row>
          <p class="text-caption text-medium-emphasis mt-3 mb-0">
            Enter numbers between 1 and 99999999. The prefix is fixed at SR, as in the legacy report.
          </p>
          <v-alert v-if="error" type="error" variant="tonal" class="mt-3">{{ error }}</v-alert>
          <div
            v-if="printing"
            class="d-flex align-center justify-center py-4"
            data-testid="barcode-printing"
          >
            <v-progress-circular indeterminate color="primary" size="28" />
            <span class="text-caption ml-3">Preparing PDF…</span>
          </div>
        </v-card-text>
        <v-card-actions>
          <v-btn variant="text" data-testid="barcode-print-reset" @click="resetRange">Reset</v-btn>
          <v-spacer />
          <v-btn variant="text" data-testid="barcode-print-cancel" @click="txDialogOpen = false">Cancel</v-btn>
          <v-btn
            color="primary"
            :loading="printing"
            data-testid="barcode-print-submit"
            @click="printBarCodeTags"
          >
            Print
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <v-dialog v-model="claimDialogOpen" max-width="480">
      <v-card rounded="xl" data-testid="claim-receipt-dialog">
        <v-card-title>Order/Invoice Number</v-card-title>
        <v-card-text>
          <v-text-field
            v-model="orderInvoiceNumber"
            label="Order/Invoice No."
            data-testid="claim-order-invoice-number"
            hide-details
          />
          <p class="text-caption text-medium-emphasis mt-3 mb-0">
            Enter the RC order/invoice number printed on the claim, for example RC00023372.
          </p>
          <v-alert v-if="claimError" type="error" variant="tonal" class="mt-3">{{ claimError }}</v-alert>
          <div
            v-if="claimPrinting"
            class="d-flex align-center justify-center py-4"
            data-testid="claim-printing"
          >
            <v-progress-circular indeterminate color="primary" size="28" />
            <span class="text-caption ml-3">Preparing PDF…</span>
          </div>
        </v-card-text>
        <v-card-actions>
          <v-btn variant="text" data-testid="claim-print-reset" @click="orderInvoiceNumber = ''">Reset</v-btn>
          <v-spacer />
          <v-btn variant="text" data-testid="claim-print-cancel" @click="claimDialogOpen = false">Cancel</v-btn>
          <v-btn
            color="primary"
            :loading="claimPrinting"
            data-testid="claim-print-submit"
            @click="printClaimReceipt"
          >
            Print
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
  </v-card>
</template>
