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
  if (selectedReport.value) {
    void router.push(selectedReport.value.to)
  }
}

async function printBarCodeTags(): Promise<void> {
  const from = fromNumber.value.trim()
  const to = toNumber.value.trim()
  if (!from || !to) return
  printing.value = true
  error.value = null
  let message = 'The bar code tag report could not be generated.'
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
    if (!response.ok) {
      try {
        const problem = await response.json() as { detail?: string; title?: string }
        message = problem.detail || problem.title || message
      } catch {
        // Keep the generic message when the error body is not readable.
      }
      throw new Error(message)
    }
    const blob = await response.blob()
    const url = URL.createObjectURL(blob)
    const link = document.createElement('a')
    link.href = url
    link.download = `SR${from.padStart(8, '0')}-SR${to.padStart(8, '0')}-barcode-tags.pdf`
    link.click()
    URL.revokeObjectURL(url)
    txDialogOpen.value = false
  } catch (caught) {
    error.value = caught instanceof Error && caught.message !== 'print failed'
      ? caught.message
      : message
  } finally {
    printing.value = false
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
  </v-card>
</template>
