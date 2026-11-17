<script setup lang="ts">
import { onMounted, reactive, ref } from 'vue'
import { api, unwrap } from '@/api/client'
import { AppError } from '@/api/problems'

interface PlanRule { id: number; categoryCode: string | null; sku: string | null; coveragePercent: number | string }
interface Plan { id: number; planCode: string; version: number; name: string; payerName: string; rules: PlanRule[] }
interface Member { id: number; customerId: number; planId: number; memberNumber: string; planVersion: number }
interface ClaimLine {
  lineNumber: number; invoiceRowNo: number; sku: string; billedAmount: number | string;
  eligible: boolean; coveragePercent: number | string; coveredAmount: number | string;
  patientAmount: number | string; ineligibleReason: string | null
}
interface ClaimEvent {
  id: number; eventType: string; status: string | null; amount: number | string | null;
  reason: string | null; reference: string | null; occurredAt: string
}
interface Claim {
  id: number; claimNumber: string; invoiceTxNumber: string; customerId: number
  planVersion: number; status: string
  totalBilled: number | string; coveredAmount: number | string; patientAmount: number | string
  approvedAmount: number | string; adjustmentAmount: number | string; paidAmount: number | string
  rejectionReason: string | null; lines: ClaimLine[]; events: ClaimEvent[]
}
interface Reconciliation {
  claimId: number; claimNumber: string; invoiceTxNumber: string; invoiceTotal: number | string
  coveredAmount: number | string; approvedAmount: number | string; paidAmount: number | string
  difference: number | string
}

const plans = ref<Plan[]>([])
const members = ref<Member[]>([])
const claims = ref<Claim[]>([])
const selected = ref<Claim | null>(null)
const reconciliation = ref<Reconciliation[]>([])
const busy = ref(false)
const error = ref<string | null>(null)
const notice = ref<string | null>(null)
const planForm = reactive({ planCode: '', name: '', payerName: '', coveragePercent: 80, annualMaximum: 10000 })
const memberForm = reactive({ customerId: 0, planId: 0, memberNumber: '', groupNumber: '', effectiveFrom: new Date().toISOString().slice(0, 10) })
const claimForm = reactive({ invoiceTxNumber: '', memberId: 0, rowNumbers: '1', reason: 'insurance claim' })
const approveAmount = ref(0)
const approveReason = ref('insurer approval')
const approveReference = ref('')
const rejectReason = ref('missing documentation')
const resubmitReason = ref('documents supplied')
const resubmitReference = ref('')
const paymentAmount = ref(0)
const paymentMethod = ref('EFT')
const paymentReference = ref('')

function handleError(caught: unknown): void {
  if (caught instanceof AppError) {
    if (caught.kind === 'validation') {
      const fields = caught.fieldErrors as Record<string, readonly string[]>
      error.value = Object.values(fields)[0]?.[0] ?? caught.userMessage
    } else error.value = caught.userMessage
  } else error.value = 'The request failed.'
}

async function loadPlans(): Promise<void> {
  plans.value = (await unwrap(await api.client.GET('/api/v1/claims/plans', {
    params: { query: { currentOnly: true } },
  }))) as unknown as Plan[]
}

async function loadMembers(): Promise<void> {
  if (!memberForm.customerId) return
  members.value = (await unwrap(await api.client.GET('/api/v1/claims/members', {
    params: { query: { customerId: Number(memberForm.customerId) } },
  }))) as unknown as Member[]
}

async function loadClaims(): Promise<void> {
  claims.value = (await unwrap(await api.client.GET('/api/v1/claims', {
    params: { query: { invoiceTxNumber: claimForm.invoiceTxNumber || undefined } },
  }))) as unknown as Claim[]
}

async function savePlan(): Promise<void> {
  busy.value = true; error.value = null
  try {
    const plan = await unwrap(await api.client.POST('/api/v1/claims/plans', {
      body: {
        planCode: planForm.planCode, name: planForm.name, payerName: planForm.payerName,
        rules: [{ categoryCode: null, sku: null, coveragePercent: Number(planForm.coveragePercent),
          annualMaximum: Number(planForm.annualMaximum), requiresPreauthorization: false }],
        reason: 'create insurance plan',
      },
    })) as unknown as Plan
    notice.value = `Plan ${plan.planCode} v${plan.version} saved.`
    await loadPlans()
    memberForm.planId = plan.id
  } catch (caught) { handleError(caught) } finally { busy.value = false }
}

async function saveMember(): Promise<void> {
  busy.value = true; error.value = null
  try {
    const member = await unwrap(await api.client.POST('/api/v1/claims/members', {
      body: {
        customerId: Number(memberForm.customerId), planId: Number(memberForm.planId),
        memberNumber: memberForm.memberNumber,
        groupNumber: memberForm.groupNumber || null,
        effectiveFrom: memberForm.effectiveFrom, effectiveTo: null,
        eligibilityNote: null, reason: 'assign insurance member',
      },
    })) as unknown as Member
    notice.value = `Member ${member.memberNumber} assigned (id ${member.id}).`
    claimForm.memberId = member.id
    await loadMembers()
  } catch (caught) { handleError(caught) } finally { busy.value = false }
}

async function createClaim(): Promise<void> {
  busy.value = true; error.value = null
  try {
    const rows = claimForm.rowNumbers.split(',').map((value) => Number(value.trim()))
      .filter((value) => value > 0)
    const claim = await unwrap(await api.client.POST('/api/v1/claims', {
      body: {
        invoiceTxNumber: claimForm.invoiceTxNumber, memberId: Number(claimForm.memberId),
        invoiceRowNumbers: rows, reason: claimForm.reason,
      },
    })) as unknown as Claim
    selected.value = claim
    approveAmount.value = Number(claim.coveredAmount)
    notice.value = `Claim ${claim.claimNumber} created.`
    await loadClaims()
  } catch (caught) { handleError(caught) } finally { busy.value = false }
}

async function selectClaim(id: number): Promise<void> {
  busy.value = true; error.value = null
  try {
    selected.value = (await unwrap(await api.client.GET('/api/v1/claims/{claimId}', {
      params: { path: { claimId: id } },
    }))) as unknown as Claim
    approveAmount.value = Number(selected.value.coveredAmount)
  } catch (caught) { handleError(caught) } finally { busy.value = false }
}

async function adjudicate(): Promise<void> {
  if (!selected.value) return
  busy.value = true; error.value = null
  try {
    selected.value = (await unwrap(await api.client.POST('/api/v1/claims/{claimId}/adjudicate', {
      params: { path: { claimId: selected.value.id } },
      body: {
        approvedAmount: Number(approveAmount.value), reason: approveReason.value,
        reference: approveReference.value || null, note: null,
      },
    }))) as unknown as Claim
    notice.value = `Claim adjudicated as ${selected.value.status}.`
    await loadClaims()
  } catch (caught) { handleError(caught) } finally { busy.value = false }
}

async function reject(): Promise<void> {
  if (!selected.value) return
  busy.value = true; error.value = null
  try {
    selected.value = (await unwrap(await api.client.POST('/api/v1/claims/{claimId}/reject', {
      params: { path: { claimId: selected.value.id } },
      body: { reason: rejectReason.value },
    }))) as unknown as Claim
    notice.value = 'Claim rejected.'
    await loadClaims()
  } catch (caught) { handleError(caught) } finally { busy.value = false }
}

async function resubmit(): Promise<void> {
  if (!selected.value) return
  busy.value = true; error.value = null
  try {
    selected.value = (await unwrap(await api.client.POST('/api/v1/claims/{claimId}/resubmit', {
      params: { path: { claimId: selected.value.id } },
      body: { reason: resubmitReason.value, reference: resubmitReference.value || null },
    }))) as unknown as Claim
    notice.value = 'Claim resubmitted.'
    await loadClaims()
  } catch (caught) { handleError(caught) } finally { busy.value = false }
}

async function pay(): Promise<void> {
  if (!selected.value) return
  busy.value = true; error.value = null
  try {
    selected.value = (await unwrap(await api.client.POST('/api/v1/claims/{claimId}/payments', {
      params: { path: { claimId: selected.value.id } },
      body: {
        amount: Number(paymentAmount.value), method: paymentMethod.value,
        reference: paymentReference.value || null, reason: 'insurer payment',
      },
    }))) as unknown as Claim
    notice.value = `Payment recorded; paid ${Number(selected.value.paidAmount).toFixed(4)}.`
    await loadClaims()
  } catch (caught) { handleError(caught) } finally { busy.value = false }
}

async function loadReconciliation(): Promise<void> {
  busy.value = true; error.value = null
  try {
    reconciliation.value = (await unwrap(await api.client.GET('/api/v1/claims/reconciliation'))) as unknown as Reconciliation[]
  } catch (caught) { handleError(caught) } finally { busy.value = false }
}

onMounted(async () => {
  try { await loadPlans(); await loadClaims() } catch (caught) { handleError(caught) }
})
</script>

<template>
  <div data-testid="claims-page">
    <h1 class="text-h5 mb-4">Insurance claims</h1>
    <v-alert v-if="error" type="error" variant="tonal" class="mb-4" data-testid="claims-error">{{ error }}</v-alert>
    <v-alert v-if="notice" type="success" variant="tonal" class="mb-4" data-testid="claims-notice">{{ notice }}</v-alert>

    <v-row>
      <v-col cols="12" md="4">
        <v-card variant="outlined">
          <v-card-title>Plan</v-card-title>
          <v-card-text>
            <v-text-field v-model="planForm.planCode" label="Plan code" density="compact"
              data-testid="claim-plan-code" />
            <v-text-field v-model="planForm.name" label="Name" density="compact"
              data-testid="claim-plan-name" />
            <v-text-field v-model="planForm.payerName" label="Payer" density="compact"
              data-testid="claim-plan-payer" />
            <v-text-field v-model.number="planForm.coveragePercent" type="number" label="Coverage %"
              density="compact" data-testid="claim-plan-coverage" />
            <v-btn color="primary" :loading="busy" data-testid="claim-plan-save" @click="savePlan">Save plan</v-btn>
            <p class="text-caption mt-2" data-testid="claim-plans">
              {{ plans.map((plan) => `${plan.planCode} v${plan.version}`).join(' · ') }}
            </p>
          </v-card-text>
        </v-card>

        <v-card variant="outlined" class="mt-4">
          <v-card-title>Member</v-card-title>
          <v-card-text>
            <v-text-field v-model.number="memberForm.customerId" type="number" label="Customer id"
              density="compact" data-testid="claim-member-customer" />
            <v-text-field v-model.number="memberForm.planId" type="number" label="Plan id"
              density="compact" data-testid="claim-member-plan" />
            <v-text-field v-model="memberForm.memberNumber" label="Member number" density="compact"
              data-testid="claim-member-number" />
            <v-btn :loading="busy" data-testid="claim-member-save" @click="saveMember">Assign member</v-btn>
            <p class="text-caption mt-2" data-testid="claim-members">
              {{ members.map((member) => `${member.id}:${member.memberNumber}`).join(' · ') }}
            </p>
          </v-card-text>
        </v-card>
      </v-col>

      <v-col cols="12" md="8">
        <v-card variant="outlined">
          <v-card-title>Claim</v-card-title>
          <v-card-text>
            <div class="d-flex ga-2">
              <v-text-field v-model="claimForm.invoiceTxNumber" label="Invoice" density="compact"
                data-testid="claim-invoice" />
              <v-text-field v-model.number="claimForm.memberId" type="number" label="Member id"
                density="compact" data-testid="claim-member-id" />
              <v-text-field v-model="claimForm.rowNumbers" label="Rows" density="compact"
                data-testid="claim-rows" />
              <v-btn color="primary" :loading="busy" data-testid="claim-create" @click="createClaim">Create</v-btn>
            </div>
            <v-table density="compact" class="mt-3" data-testid="claim-list">
              <thead><tr><th>Claim</th><th>Invoice</th><th>Status</th><th>Covered</th><th /></tr></thead>
              <tbody>
                <tr v-for="claim in claims" :key="claim.id">
                  <td>{{ claim.claimNumber }}</td><td>{{ claim.invoiceTxNumber }}</td>
                  <td>{{ claim.status }}</td><td>{{ Number(claim.coveredAmount).toFixed(4) }}</td>
                  <td><v-btn size="small" variant="text" :data-testid="`claim-select-${claim.id}`"
                    @click="selectClaim(claim.id)">Open</v-btn></td>
                </tr>
              </tbody>
            </v-table>
          </v-card-text>
        </v-card>

        <v-card v-if="selected" variant="outlined" class="mt-4" data-testid="claim-detail">
          <v-card-title>{{ selected.claimNumber }} · {{ selected.status }}</v-card-title>
          <v-card-text>
            <p class="text-body-2" data-testid="claim-totals">
              Billed {{ Number(selected.totalBilled).toFixed(4) }} · covered
              {{ Number(selected.coveredAmount).toFixed(4) }} · patient
              {{ Number(selected.patientAmount).toFixed(4) }} · approved
              {{ Number(selected.approvedAmount).toFixed(4) }} · paid
              {{ Number(selected.paidAmount).toFixed(4) }} · plan v{{ selected.planVersion }}
            </p>
            <v-table density="compact" data-testid="claim-lines">
              <thead><tr><th>Line</th><th>SKU</th><th>Billed</th><th>Covered</th><th>Patient</th><th>Eligible</th></tr></thead>
              <tbody><tr v-for="line in selected.lines" :key="line.lineNumber">
                <td>{{ line.lineNumber }}</td><td>{{ line.sku }}</td>
                <td>{{ Number(line.billedAmount).toFixed(4) }}</td>
                <td>{{ Number(line.coveredAmount).toFixed(4) }}</td>
                <td>{{ Number(line.patientAmount).toFixed(4) }}</td>
                <td>{{ line.eligible ? 'yes' : line.ineligibleReason }}</td>
              </tr></tbody>
            </v-table>
            <v-divider class="my-3" />
            <div class="d-flex flex-wrap ga-2 align-center">
              <v-text-field v-model.number="approveAmount" type="number" label="Approved"
                density="compact" hide-details style="max-width: 150px" data-testid="claim-approve-amount" />
              <v-text-field v-model="approveReference" label="Reference" density="compact" hide-details
                style="max-width: 160px" data-testid="claim-approve-reference" />
              <v-btn :loading="busy" data-testid="claim-approve" @click="adjudicate">Adjudicate</v-btn>
              <v-text-field v-model="rejectReason" label="Reject reason" density="compact" hide-details
                style="max-width: 180px" data-testid="claim-reject-reason" />
              <v-btn :loading="busy" data-testid="claim-reject" @click="reject">Reject</v-btn>
              <v-btn :loading="busy" data-testid="claim-resubmit" @click="resubmit">Resubmit</v-btn>
            </div>
            <div class="d-flex flex-wrap ga-2 align-center mt-2">
              <v-text-field v-model.number="paymentAmount" type="number" label="Payment"
                density="compact" hide-details style="max-width: 140px" data-testid="claim-payment-amount" />
              <v-text-field v-model="paymentMethod" label="Method" density="compact" hide-details
                style="max-width: 100px" data-testid="claim-payment-method" />
              <v-text-field v-model="paymentReference" label="Payment reference" density="compact"
                hide-details style="max-width: 170px" data-testid="claim-payment-reference" />
              <v-btn :loading="busy" data-testid="claim-pay" @click="pay">Record payment</v-btn>
            </div>
            <v-table density="compact" class="mt-3" data-testid="claim-events">
              <thead><tr><th>Event</th><th>Status</th><th>Amount</th><th>Time</th></tr></thead>
              <tbody><tr v-for="event in selected.events" :key="event.id">
                <td>{{ event.eventType }}</td><td>{{ event.status ?? '' }}</td>
                <td>{{ event.amount === null ? '' : Number(event.amount).toFixed(4) }}</td>
                <td>{{ event.occurredAt.slice(0, 19) }}</td>
              </tr></tbody>
            </v-table>
          </v-card-text>
        </v-card>
      </v-col>
    </v-row>

    <v-card variant="outlined" class="mt-4">
      <v-card-title>Reconciliation</v-card-title>
      <v-card-text>
        <v-btn :loading="busy" data-testid="claim-reconcile-load" @click="loadReconciliation">Load</v-btn>
        <v-table v-if="reconciliation.length" density="compact" class="mt-2" data-testid="claim-reconciliation">
          <thead><tr><th>Claim</th><th>Invoice</th><th>Invoice total</th><th>Approved</th><th>Paid</th><th>Difference</th></tr></thead>
          <tbody><tr v-for="row in reconciliation" :key="row.claimId">
            <td>{{ row.claimNumber }}</td><td>{{ row.invoiceTxNumber }}</td>
            <td>{{ Number(row.invoiceTotal).toFixed(4) }}</td>
            <td>{{ Number(row.approvedAmount).toFixed(4) }}</td>
            <td>{{ Number(row.paidAmount).toFixed(4) }}</td>
            <td>{{ Number(row.difference).toFixed(4) }}</td>
          </tr></tbody>
        </v-table>
      </v-card-text>
    </v-card>
  </div>
</template>
