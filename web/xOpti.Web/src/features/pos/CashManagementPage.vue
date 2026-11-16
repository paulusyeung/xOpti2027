<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { api, unwrap } from '@/api/client'
import { AppError } from '@/api/problems'
import { PermissionNames } from '@/security/permissions'
import { useSessionStore } from '@/stores/session'
import type { CashJournal, CashSession, CashSessionDetail } from './types'

const session = useSessionStore()
const branchCode = ref('01')
const terminalCode = ref('01')
const openingFloat = ref(100)
const businessDate = ref(new Date().toISOString().slice(0, 10))
const sessions = ref<CashSession[]>([])
const selectedId = ref<number | null>(null)
const detail = ref<CashSessionDetail | null>(null)
const expectedCash = ref<number | null>(null)
const blind = ref(false)
const journal = ref<CashJournal | null>(null)
const countKind = ref('interim')
const countAmount = ref(0)
const countReason = ref('spot count')
const movementKind = ref('paid-out')
const movementAmount = ref(0)
const movementReason = ref('petty cash')
const movementDestination = ref('')
const closeCount = ref(0)
const closeReason = ref('close drawer')
const varianceReason = ref('')
const finalizeReason = ref('end of day')
const busy = ref(false)
const forbidden = ref(false)
const error = ref<string | null>(null)
const notice = ref<string | null>(null)

const canFinalize = computed(() =>
  session.hasPermission(PermissionNames.ReportFinancial) && journal.value?.status !== 'final')

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

async function loadSessions(): Promise<void> {
  sessions.value = (await unwrap(await api.client.GET('/api/v1/cash/sessions/open', {
    params: { query: { branchCode: branchCode.value } },
  }))) as unknown as CashSession[]
  if (selectedId.value === null && sessions.value.length > 0) {
    await selectSession(sessions.value[0].id)
  }
}

async function selectSession(id: number): Promise<void> {
  selectedId.value = id
  busy.value = true
  error.value = null
  try {
    detail.value = (await unwrap(await api.client.GET('/api/v1/cash/sessions/{sessionId}', {
      params: { path: { sessionId: id } },
    }))) as unknown as CashSessionDetail
    const context = await unwrap(await api.client.GET(
      '/api/v1/cash/sessions/{sessionId}/count-context',
      { params: { path: { sessionId: id } } },
    )) as unknown as { expectedCash: number | null; blind: boolean }
    expectedCash.value = context.expectedCash === null ? null : Number(context.expectedCash)
    blind.value = context.blind
  } catch (caught) {
    handleError(caught)
  } finally {
    busy.value = false
  }
}

async function openSession(): Promise<void> {
  busy.value = true
  error.value = null
  notice.value = null
  try {
    const opened = await unwrap(await api.client.POST('/api/v1/cash/sessions', {
      body: {
        branchCode: branchCode.value,
        terminalCode: terminalCode.value,
        openingFloat: Number(openingFloat.value),
        reason: 'open drawer',
      },
    })) as unknown as CashSession
    notice.value = `Opened ${opened.terminalCode} with float ${Number(opened.openingFloat).toFixed(2)}.`
    selectedId.value = opened.id
    await loadSessions()
    await selectSession(opened.id)
  } catch (caught) {
    handleError(caught)
  } finally {
    busy.value = false
  }
}

async function changeStatus(action: 'suspend' | 'resume'): Promise<void> {
  if (selectedId.value === null) return
  busy.value = true
  error.value = null
  try {
    await unwrap(await api.client.POST(`/api/v1/cash/sessions/{sessionId}/${action}`, {
      params: { path: { sessionId: selectedId.value } },
      body: { reason: action === 'suspend' ? 'operator break' : 'operator returned' },
    }))
    await loadSessions()
    await selectSession(selectedId.value)
  } catch (caught) {
    handleError(caught)
  } finally {
    busy.value = false
  }
}

async function recordCount(): Promise<void> {
  if (selectedId.value === null) return
  busy.value = true
  error.value = null
  try {
    await unwrap(await api.client.POST('/api/v1/cash/sessions/{sessionId}/counts', {
      params: { path: { sessionId: selectedId.value } },
      body: {
        kind: countKind.value,
        amount: Number(countAmount.value),
        reason: countReason.value,
      },
    }))
    notice.value = 'Count recorded.'
    await selectSession(selectedId.value)
  } catch (caught) {
    handleError(caught)
  } finally {
    busy.value = false
  }
}

async function recordMovement(): Promise<void> {
  if (selectedId.value === null) return
  busy.value = true
  error.value = null
  try {
    await unwrap(await api.client.POST('/api/v1/cash/sessions/{sessionId}/movements', {
      params: { path: { sessionId: selectedId.value } },
      body: {
        kind: movementKind.value,
        amount: Number(movementAmount.value),
        reason: movementReason.value,
        destinationReference: movementDestination.value || null,
      },
    }))
    notice.value = 'Cash movement recorded.'
    await selectSession(selectedId.value)
  } catch (caught) {
    handleError(caught)
  } finally {
    busy.value = false
  }
}

async function closeSession(): Promise<void> {
  if (selectedId.value === null) return
  busy.value = true
  error.value = null
  try {
    const closed = await unwrap(await api.client.POST('/api/v1/cash/sessions/{sessionId}/close', {
      params: { path: { sessionId: selectedId.value } },
      body: {
        countedCash: Number(closeCount.value),
        varianceReason: varianceReason.value || null,
        reason: closeReason.value,
      },
    })) as unknown as CashSession
    notice.value = `Closed with variance ${Number(closed.variance ?? 0).toFixed(2)}.`
    selectedId.value = null
    detail.value = null
    expectedCash.value = null
    await loadSessions()
    await loadJournal()
  } catch (caught) {
    handleError(caught)
  } finally {
    busy.value = false
  }
}

async function loadJournal(): Promise<void> {
  busy.value = true
  error.value = null
  try {
    journal.value = (await unwrap(await api.client.GET('/api/v1/cash/journal', {
      params: { query: { branchCode: branchCode.value, businessDate: businessDate.value } },
    }))) as unknown as CashJournal
  } catch (caught) {
    handleError(caught)
  } finally {
    busy.value = false
  }
}

async function finalizeDay(): Promise<void> {
  busy.value = true
  error.value = null
  try {
    journal.value = (await unwrap(await api.client.POST('/api/v1/cash/daily-closes', {
      body: {
        branchCode: branchCode.value,
        businessDate: businessDate.value,
        reason: finalizeReason.value,
      },
    }))) as unknown as CashJournal
    notice.value = `Finalized ${journal.value.businessDate}.`
  } catch (caught) {
    handleError(caught)
  } finally {
    busy.value = false
  }
}

onMounted(async () => {
  try {
    await loadSessions()
    await loadJournal()
  } catch (caught) {
    handleError(caught)
  }
})
</script>

<template>
  <div data-testid="cash-page">
    <h1 class="text-h5 mb-4">Drawer and daily close</h1>

    <v-alert v-if="forbidden" type="error" variant="tonal" data-testid="cash-forbidden">
      You do not have permission for this cash operation.
    </v-alert>
    <v-alert v-else-if="error" type="error" variant="tonal" class="mb-4" data-testid="cash-error">
      {{ error }}
    </v-alert>
    <v-alert v-if="notice" type="success" variant="tonal" class="mb-4" data-testid="cash-notice">
      {{ notice }}
    </v-alert>

    <v-card variant="outlined" class="mb-4">
      <v-card-text>
        <div class="d-flex flex-wrap ga-3 align-center">
          <v-text-field v-model="branchCode" label="Branch" density="compact" hide-details
            style="max-width: 120px" data-testid="cash-branch" />
          <v-text-field v-model="terminalCode" label="Terminal" density="compact" hide-details
            style="max-width: 140px" data-testid="cash-terminal" />
          <v-text-field v-model.number="openingFloat" type="number" min="0" label="Opening float"
            density="compact" hide-details style="max-width: 160px" data-testid="cash-float" />
          <v-btn color="primary" :loading="busy" data-testid="cash-open" @click="openSession">
            Open drawer
          </v-btn>
        </div>
      </v-card-text>
    </v-card>

    <v-row>
      <v-col cols="12" md="5">
        <v-card variant="outlined">
          <v-card-title>Open sessions</v-card-title>
          <v-card-text>
            <v-table density="compact" data-testid="cash-sessions">
              <thead><tr><th>Terminal</th><th>Status</th><th>Expected</th><th /></tr></thead>
              <tbody>
                <tr v-for="row in sessions" :key="row.id" :data-testid="`cash-session-${row.id}`">
                  <td>{{ row.terminalCode }}</td>
                  <td>{{ row.status }}</td>
                  <td>{{ Number(row.expectedCash).toFixed(2) }}</td>
                  <td>
                    <v-btn size="small" variant="text" :data-testid="`cash-select-${row.id}`"
                      @click="selectSession(row.id)">Open</v-btn>
                  </td>
                </tr>
                <tr v-if="sessions.length === 0">
                  <td colspan="4" class="text-medium-emphasis" data-testid="cash-sessions-empty">
                    No open drawer sessions.
                  </td>
                </tr>
              </tbody>
            </v-table>
          </v-card-text>
        </v-card>
      </v-col>

      <v-col cols="12" md="7">
        <v-card v-if="detail" variant="outlined" data-testid="cash-session-detail">
          <v-card-title>
            {{ detail.session.terminalCode }} · {{ detail.session.status }}
          </v-card-title>
          <v-card-text>
            <p class="text-body-1" data-testid="cash-expected">
              Expected cash:
              {{ expectedCash === null ? 'hidden (blind count)' : expectedCash.toFixed(2) }}
            </p>
            <div class="d-flex ga-2 mb-3">
              <v-btn size="small" variant="text" data-testid="cash-suspend"
                :disabled="detail.session.status !== 'open'" @click="changeStatus('suspend')">Suspend</v-btn>
              <v-btn size="small" variant="text" data-testid="cash-resume"
                :disabled="detail.session.status !== 'suspended'" @click="changeStatus('resume')">Resume</v-btn>
            </div>

            <v-table density="compact" data-testid="cash-counts">
              <thead><tr><th>Count</th><th>Amount</th><th>Variance</th><th>Reason</th></tr></thead>
              <tbody>
                <tr v-for="row in detail.counts" :key="row.id">
                  <td>{{ row.kind }}</td>
                  <td>{{ Number(row.amount).toFixed(2) }}</td>
                  <td>{{ Number(row.variance ?? 0).toFixed(2) }}</td>
                  <td>{{ row.reason ?? '' }}</td>
                </tr>
              </tbody>
            </v-table>
            <div class="d-flex flex-wrap ga-2 mt-2">
              <v-select v-model="countKind" :items="['opening', 'interim', 'closing']"
                density="compact" hide-details style="max-width: 150px" data-testid="cash-count-kind" />
              <v-text-field v-model.number="countAmount" type="number" min="0" label="Counted"
                density="compact" hide-details style="max-width: 140px" data-testid="cash-count-amount" />
              <v-text-field v-model="countReason" label="Count reason" density="compact" hide-details
                style="max-width: 220px" data-testid="cash-count-reason" />
              <v-btn :loading="busy" data-testid="cash-count-submit" @click="recordCount">Record count</v-btn>
            </div>

            <v-divider class="my-4" />
            <v-table density="compact" data-testid="cash-movements">
              <thead><tr><th>Movement</th><th>Amount</th><th>Reason</th><th>Destination</th></tr></thead>
              <tbody>
                <tr v-for="row in detail.movements" :key="row.id">
                  <td>{{ row.kind }}</td>
                  <td>{{ Number(row.amount).toFixed(2) }}</td>
                  <td>{{ row.reason }}</td>
                  <td>{{ row.destinationReference ?? '' }}</td>
                </tr>
              </tbody>
            </v-table>
            <div class="d-flex flex-wrap ga-2 mt-2">
              <v-select v-model="movementKind" :items="['paid-in', 'paid-out', 'pickup', 'deposit']"
                density="compact" hide-details style="max-width: 150px" data-testid="cash-movement-kind" />
              <v-text-field v-model.number="movementAmount" type="number" min="0" label="Amount"
                density="compact" hide-details style="max-width: 130px" data-testid="cash-movement-amount" />
              <v-text-field v-model="movementReason" label="Reason" density="compact" hide-details
                style="max-width: 200px" data-testid="cash-movement-reason" />
              <v-text-field v-model="movementDestination" label="Destination" density="compact"
                hide-details style="max-width: 180px" data-testid="cash-movement-destination" />
              <v-btn :loading="busy" data-testid="cash-movement-submit" @click="recordMovement">Record movement</v-btn>
            </div>

            <v-divider class="my-4" />
            <div class="d-flex flex-wrap ga-2 align-center">
              <v-text-field v-model.number="closeCount" type="number" min="0" label="Closing count"
                density="compact" hide-details style="max-width: 160px" data-testid="cash-close-count" />
              <v-text-field v-model="varianceReason" label="Variance reason" density="compact"
                hide-details style="max-width: 220px" data-testid="cash-variance-reason" />
              <v-text-field v-model="closeReason" label="Close reason" density="compact" hide-details
                style="max-width: 200px" data-testid="cash-close-reason" />
              <v-btn color="primary" :loading="busy" data-testid="cash-close-submit"
                @click="closeSession">Close drawer</v-btn>
            </div>
          </v-card-text>
        </v-card>
      </v-col>
    </v-row>

    <v-card variant="outlined" class="mt-4">
      <v-card-title>Daily close and journal</v-card-title>
      <v-card-text>
        <div class="d-flex flex-wrap ga-2 align-center mb-3">
          <v-text-field v-model="businessDate" type="date" label="Business date" density="compact"
            hide-details style="max-width: 180px" data-testid="cash-business-date" />
          <v-btn :loading="busy" data-testid="cash-load-journal" @click="loadJournal">Load journal</v-btn>
          <v-text-field v-model="finalizeReason" label="Finalize reason" density="compact"
            hide-details style="max-width: 220px" data-testid="cash-finalize-reason" />
          <v-btn color="primary" :loading="busy" :disabled="!canFinalize"
            data-testid="cash-finalize" @click="finalizeDay">Finalize day</v-btn>
        </div>
        <div v-if="journal" data-testid="cash-journal">
          <p class="text-body-2" data-testid="cash-journal-status">
            Status: {{ journal.status }}
            <span v-if="journal.finalizedAt">· finalized {{ journal.finalizedAt }}</span>
          </p>
          <div class="d-flex flex-wrap ga-4 text-body-2" data-testid="cash-journal-totals">
            <span>Sales {{ Number(journal.totalSales).toFixed(2) }}</span>
            <span>Refunds {{ Number(journal.totalRefunds).toFixed(2) }}</span>
            <span>GST {{ Number(journal.taxA).toFixed(2) }}</span>
            <span>PST {{ Number(journal.taxB).toFixed(2) }}</span>
            <span>Cash {{ Number(journal.cashTenders).toFixed(2) }}</span>
            <span>Card {{ Number(journal.cardTenders).toFixed(2) }}</span>
            <span>Paid out {{ Number(journal.paidOut).toFixed(2) }}</span>
            <span>Expected {{ Number(journal.expectedCash).toFixed(2) }}</span>
            <span>Counted {{ Number(journal.countedCash).toFixed(2) }}</span>
            <span data-testid="cash-journal-variance">Variance {{ Number(journal.variance).toFixed(2) }}</span>
          </div>
          <v-table density="compact" class="mt-3" data-testid="cash-journal-documents">
            <thead><tr><th>Document</th><th>Type</th><th>Total</th><th>Tenders</th></tr></thead>
            <tbody>
              <tr v-for="document in journal.documents" :key="document.txNumber">
                <td>{{ document.txNumber }}</td>
                <td>{{ document.txType }}</td>
                <td>{{ Number(document.totalAmount).toFixed(2) }}</td>
                <td>{{ document.tenders.map((tender) => `${tender.method} ${Number(tender.applied).toFixed(2)}`).join(' · ') }}</td>
              </tr>
            </tbody>
          </v-table>
        </div>
      </v-card-text>
    </v-card>
  </div>
</template>
