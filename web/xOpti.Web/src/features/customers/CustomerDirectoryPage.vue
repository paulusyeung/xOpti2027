<script setup lang="ts">
import { computed, onMounted, reactive, ref } from 'vue'
import { api, unwrap } from '@/api/client'
import { AppError } from '@/api/problems'
import { PermissionNames } from '@/security/permissions'
import { useSessionStore } from '@/stores/session'

interface CustomerSummary {
  id: number
  vipCode: string | null
  displayName: string | null
  homePhone: string | null
  email: string | null
  homeCity: string | null
}
interface CustomerDetail {
  id: number
  vipCode: string | null
  salutation: string | null
  firstName: string | null
  initial: string | null
  lastName: string | null
  fullName: string | null
  birthday: string | null
  homeAddress: string | null
  homeCity: number
  homeProvince: string | null
  homePostalCode: string | null
  homeCountry: string | null
  homePhone: string | null
  homeFax: string | null
  cellular: string | null
  email: string | null
  bizCompanyName: string | null
  bizJobTitle: string | null
  bizAddress: string | null
  bizCity: number
  bizProvince: string | null
  bizPostalCode: string | null
  bizCountry: string | null
  bizPhone: string | null
  bizFax: string | null
  creditLimit: number | string
  paymentTerms: string | null
  vipMarkDownPct: number
  summaryFlag: boolean | null
  accountingFlag: boolean | null
  remarks: string | null
}
interface CustomerView { customer: CustomerDetail; resolvedFrom: number | null }
interface CustomerBalance {
  customerId: number; charges: number | string; payments: number | string
  refunds: number | string; balance: number | string; creditLimit: number | string
  overCreditLimit: boolean
}
interface Purchase {
  txNumber: string; txType: string; dateOfEntry: string; totalAmount: number | string
  paid: number | string; status: string | null; refNumber: string | null
}
interface Statement {
  openingBalance: number | string; charges: number | string; payments: number | string
  refunds: number | string; closingBalance: number | string; items: Purchase[]
}

const sessionStore = useSessionStore()
const canSeePii = computed(() => sessionStore.hasPermission(PermissionNames.CustomerPii))
const search = ref('')
const items = ref<CustomerSummary[]>([])
const nextCursor = ref<string | null>(null)
const selected = ref<CustomerView | null>(null)
const balance = ref<CustomerBalance | null>(null)
const history = ref<Purchase[]>([])
const statement = ref<Statement | null>(null)
const statementFrom = ref(new Date(new Date().getFullYear(), new Date().getMonth(), 1).toISOString().slice(0, 10))
const statementTo = ref(new Date().toISOString().slice(0, 10))
const busy = ref(false)
const error = ref<string | null>(null)
const notice = ref<string | null>(null)
const duplicateWarning = ref(false)
const confirmDuplicate = ref(false)

const blankForm = () => ({
  vipCode: '', salutation: '', firstName: '', initial: '', lastName: '', fullName: '',
  birthday: '', homeAddress: '', homeCity: 0, homeProvince: '', homePostalCode: '',
  homeCountry: 'CA', homePhone: '', homeFax: '', cellular: '', email: '',
  bizCompanyName: '', bizJobTitle: '', bizAddress: '', bizCity: 0, bizProvince: '',
  bizPostalCode: '', bizCountry: '', bizPhone: '', bizFax: '', creditLimit: 0,
  paymentTerms: '', vipMarkDownPct: 0, summaryFlag: false, accountingFlag: false, remarks: '',
})
const form = reactive(blankForm())
const editing = ref<number | null>(null)
const createOpen = ref(false)
const merge = reactive({ sourceId: 0, targetId: 0, fullName: '', phone: '', email: '', reason: '' })
const mergeOpen = ref(false)

function handleError(caught: unknown): void {
  if (caught instanceof AppError) {
    if (caught.kind === 'validation') {
      const fields = caught.fieldErrors as Record<string, readonly string[]>
      const first = Object.values(fields)[0]?.[0]
      error.value = first ?? caught.userMessage
      duplicateWarning.value = Object.keys(fields).some((key) => key.toLowerCase() === 'duplicate')
    } else {
      error.value = caught.userMessage
    }
  } else {
    error.value = 'The request failed.'
  }
}

function inputPayload() {
  return {
    ...form,
    birthday: form.birthday || null,
    homeCity: Number(form.homeCity || 0),
    bizCity: Number(form.bizCity || 0),
    creditLimit: Number(form.creditLimit || 0),
    vipMarkDownPct: Number(form.vipMarkDownPct || 0),
  }
}

async function searchCustomers(reset = true): Promise<void> {
  busy.value = true
  error.value = null
  try {
    const page = await unwrap(await api.client.GET('/api/v1/customers', {
      params: { query: { search: search.value, cursor: reset ? undefined : nextCursor.value ?? undefined, pageSize: 20 } },
    })) as unknown as { items: CustomerSummary[]; nextCursor: string | null }
    items.value = reset ? page.items : [...items.value, ...page.items]
    nextCursor.value = page.nextCursor
  } catch (caught) { handleError(caught) } finally { busy.value = false }
}

async function selectCustomer(id: number): Promise<void> {
  busy.value = true
  error.value = null
  statement.value = null
  try {
    selected.value = await unwrap(await api.client.GET('/api/v1/customers/{customerId}', {
      params: { path: { customerId: id } },
    })) as unknown as CustomerView
    balance.value = await unwrap(await api.client.GET('/api/v1/customers/{customerId}/account', {
      params: { path: { customerId: id } },
    })) as unknown as CustomerBalance
    const historyBody = await unwrap(await api.client.GET('/api/v1/customers/{customerId}/history', {
      params: { path: { customerId: id } },
    })) as unknown as { items: Purchase[] }
    history.value = historyBody.items
    loadForm(selected.value.customer)
  } catch (caught) { handleError(caught) } finally { busy.value = false }
}

function loadForm(customer: CustomerDetail): void {
  editing.value = customer.id
  Object.assign(form, blankForm(), {
    vipCode: customer.vipCode ?? '', salutation: customer.salutation ?? '',
    firstName: customer.firstName ?? '', initial: customer.initial ?? '',
    lastName: customer.lastName ?? '', fullName: customer.fullName ?? '',
    birthday: customer.birthday ? customer.birthday.slice(0, 10) : '',
    homeAddress: customer.homeAddress ?? '', homeCity: customer.homeCity,
    homeProvince: customer.homeProvince ?? '', homePostalCode: customer.homePostalCode ?? '',
    homeCountry: customer.homeCountry ?? '', homePhone: customer.homePhone ?? '',
    homeFax: customer.homeFax ?? '', cellular: customer.cellular ?? '',
    email: customer.email ?? '', bizCompanyName: customer.bizCompanyName ?? '',
    bizJobTitle: customer.bizJobTitle ?? '', bizAddress: customer.bizAddress ?? '',
    bizCity: customer.bizCity, bizProvince: customer.bizProvince ?? '',
    bizPostalCode: customer.bizPostalCode ?? '', bizCountry: customer.bizCountry ?? '',
    bizPhone: customer.bizPhone ?? '', bizFax: customer.bizFax ?? '',
    creditLimit: Number(customer.creditLimit), paymentTerms: customer.paymentTerms ?? '',
    vipMarkDownPct: customer.vipMarkDownPct,
    summaryFlag: customer.summaryFlag ?? false, accountingFlag: customer.accountingFlag ?? false,
    remarks: customer.remarks ?? '',
  })
}

function newCustomer(): void {
  editing.value = null
  createOpen.value = true
  mergeOpen.value = false
  Object.assign(form, blankForm())
  duplicateWarning.value = false
  confirmDuplicate.value = false
  error.value = null
  notice.value = null
}

async function saveCustomer(): Promise<void> {
  busy.value = true
  error.value = null
  notice.value = null
  try {
    const body = { input: inputPayload(), confirmDuplicate: confirmDuplicate.value, reason: editing.value ? 'customer edit' : 'customer create' }
    const result = editing.value
      ? await unwrap(await api.client.PUT('/api/v1/customers/{customerId}', {
        params: { path: { customerId: editing.value } }, body,
      }))
      : await unwrap(await api.client.POST('/api/v1/customers', { body }))
    const view = result as unknown as CustomerView
    notice.value = `Customer ${view.customer.id} saved.`
    duplicateWarning.value = false
    confirmDuplicate.value = false
    createOpen.value = false
    await searchCustomers()
    await selectCustomer(view.customer.id)
  } catch (caught) { handleError(caught) } finally { busy.value = false }
}

async function mergeCustomers(): Promise<void> {
  busy.value = true
  error.value = null
  try {
    const result = await unwrap(await api.client.POST('/api/v1/customers/merge', {
      body: {
        sourceId: Number(merge.sourceId), targetId: Number(merge.targetId),
        fullName: merge.fullName || null, phone: merge.phone || null,
        email: merge.email || null, reason: merge.reason,
      },
    })) as unknown as CustomerView
    notice.value = `Merged ${merge.sourceId} into ${result.customer.id}.`
    mergeOpen.value = false
    await searchCustomers()
    await selectCustomer(result.customer.id)
  } catch (caught) { handleError(caught) } finally { busy.value = false }
}

async function loadStatement(): Promise<void> {
  if (!selected.value) return
  busy.value = true
  error.value = null
  try {
    statement.value = await unwrap(await api.client.GET('/api/v1/customers/{customerId}/statement', {
      params: {
        path: { customerId: selected.value.customer.id },
        query: { from: statementFrom.value, to: statementTo.value },
      },
    })) as unknown as Statement
  } catch (caught) { handleError(caught) } finally { busy.value = false }
}

onMounted(async () => {
  try { await searchCustomers() } catch (caught) { handleError(caught) }
})
</script>

<template>
  <div data-testid="customer-page">
    <div class="d-flex align-center mb-4">
      <h1 class="text-h5">Customers</h1>
      <v-spacer />
      <v-btn color="primary" data-testid="customer-new" @click="newCustomer">New customer</v-btn>
      <v-btn class="ml-2" variant="text" data-testid="customer-merge-open"
        @click="mergeOpen = !mergeOpen; createOpen = false">Merge</v-btn>
    </div>

    <v-alert v-if="error" type="error" variant="tonal" class="mb-4" data-testid="customer-error">
      {{ error }}
    </v-alert>
    <v-alert v-if="notice" type="success" variant="tonal" class="mb-4" data-testid="customer-notice">
      {{ notice }}
    </v-alert>

    <v-card variant="outlined" class="mb-4">
      <v-card-text>
        <div class="d-flex ga-2">
          <v-text-field v-model="search" label="Name, phone, email, VIP, or id" density="compact"
            hide-details data-testid="customer-search" @keyup.enter="searchCustomers()" />
          <v-btn color="primary" :loading="busy" data-testid="customer-search-button"
            @click="searchCustomers()">Search</v-btn>
        </div>
      </v-card-text>
    </v-card>

    <v-row>
      <v-col cols="12" md="5">
        <v-card variant="outlined">
          <v-card-title>Directory</v-card-title>
          <v-card-text>
            <v-table density="compact" data-testid="customer-list">
              <thead><tr><th>Id</th><th>Name</th><th>Phone</th><th>VIP</th></tr></thead>
              <tbody>
                <tr v-for="row in items" :key="row.id" :data-testid="`customer-row-${row.id}`">
                  <td>{{ row.id }}</td>
                  <td>
                    <v-btn variant="text" size="small" :data-testid="`customer-select-${row.id}`"
                      @click="selectCustomer(row.id)">{{ row.displayName ?? '***' }}</v-btn>
                  </td>
                  <td>{{ row.homePhone ?? '—' }}</td>
                  <td>{{ row.vipCode ?? '' }}</td>
                </tr>
                <tr v-if="items.length === 0">
                  <td colspan="4" class="text-medium-emphasis" data-testid="customer-empty">No customers.</td>
                </tr>
              </tbody>
            </v-table>
            <v-btn v-if="nextCursor" variant="text" size="small" data-testid="customer-more"
              @click="searchCustomers(false)">Load more</v-btn>
          </v-card-text>
        </v-card>
      </v-col>

      <v-col cols="12" md="7">
        <v-card v-if="selected" variant="outlined" data-testid="customer-detail">
          <v-card-title>
            Customer {{ selected.customer.id }}
            <span v-if="selected.resolvedFrom" class="text-caption text-medium-emphasis ml-2">
              (merged from {{ selected.resolvedFrom }})
            </span>
          </v-card-title>
          <v-card-text>
            <p class="text-body-2" data-testid="customer-identity">
              {{ selected.customer.fullName ?? '***' }}
              · VIP {{ selected.customer.vipCode ?? '—' }}
              · {{ selected.customer.email ?? 'email hidden' }}
            </p>
            <p v-if="balance" class="text-body-2" data-testid="customer-account">
              Balance {{ Number(balance.balance).toFixed(2) }} / credit
              {{ Number(balance.creditLimit).toFixed(2) }}
              <span v-if="balance.overCreditLimit" class="text-error">· over limit</span>
            </p>
            <v-btn size="small" variant="text" data-testid="customer-edit" @click="createOpen = true; mergeOpen = false">
              Edit
            </v-btn>
            <v-btn size="small" variant="text" :href="`/admin/prescriptions?customerId=${selected.customer.id}`"
              data-testid="customer-prescriptions">Prescriptions</v-btn>
          </v-card-text>
        </v-card>

        <v-card v-if="selected" variant="outlined" class="mt-4">
          <v-card-title>Purchase history</v-card-title>
          <v-card-text>
            <v-table density="compact" data-testid="customer-history">
              <thead><tr><th>Document</th><th>Type</th><th>Date</th><th class="text-right">Total</th></tr></thead>
              <tbody>
                <tr v-for="row in history" :key="row.txNumber">
                  <td>{{ row.txNumber }}</td><td>{{ row.txType }}</td>
                  <td>{{ row.dateOfEntry.slice(0, 10) }}</td>
                  <td class="text-right">{{ Number(row.totalAmount).toFixed(2) }}</td>
                </tr>
              </tbody>
            </v-table>
          </v-card-text>
        </v-card>

        <v-card v-if="selected" variant="outlined" class="mt-4">
          <v-card-title>Statement</v-card-title>
          <v-card-text>
            <div class="d-flex ga-2 align-center mb-3">
              <v-text-field v-model="statementFrom" type="date" label="From" density="compact"
                hide-details data-testid="customer-statement-from" />
              <v-text-field v-model="statementTo" type="date" label="To" density="compact"
                hide-details data-testid="customer-statement-to" />
              <v-btn :loading="busy" data-testid="customer-statement-load" @click="loadStatement">Generate</v-btn>
            </div>
            <div v-if="statement" data-testid="customer-statement">
              <p class="text-body-2">
                Opening {{ Number(statement.openingBalance).toFixed(2) }} ·
                Charges {{ Number(statement.charges).toFixed(2) }} ·
                Payments {{ Number(statement.payments).toFixed(2) }} ·
                Refunds {{ Number(statement.refunds).toFixed(2) }} ·
                Closing {{ Number(statement.closingBalance).toFixed(2) }}
              </p>
            </div>
          </v-card-text>
        </v-card>
      </v-col>
    </v-row>

    <v-card v-if="createOpen" variant="outlined" class="mt-4">
      <v-card-title>{{ editing ? 'Edit customer ' + editing : 'New customer' }}</v-card-title>
      <v-card-text>
        <v-row dense>
          <v-col cols="12" md="4"><v-text-field v-model="form.fullName" label="Full name"
            :disabled="!canSeePii && !!editing" data-testid="customer-full-name" /></v-col>
          <v-col cols="12" md="4"><v-text-field v-model="form.firstName" label="First name"
            :disabled="!canSeePii && !!editing" data-testid="customer-first-name" /></v-col>
          <v-col cols="12" md="4"><v-text-field v-model="form.lastName" label="Last name"
            :disabled="!canSeePii && !!editing" data-testid="customer-last-name" /></v-col>
          <v-col cols="12" md="4"><v-text-field v-model="form.homePhone" label="Home phone"
            :disabled="!canSeePii && !!editing" data-testid="customer-phone" /></v-col>
          <v-col cols="12" md="4"><v-text-field v-model="form.email" label="Email"
            :disabled="!canSeePii && !!editing" data-testid="customer-email" /></v-col>
          <v-col cols="12" md="4"><v-text-field v-model="form.vipCode" label="VIP code"
            data-testid="customer-vip" /></v-col>
          <v-col cols="12" md="4"><v-text-field v-model.number="form.creditLimit" type="number" min="0"
            label="Credit limit" data-testid="customer-credit-limit" /></v-col>
          <v-col cols="12" md="4"><v-text-field v-model="form.paymentTerms" label="Payment terms"
            data-testid="customer-payment-terms" /></v-col>
          <v-col cols="12" md="4"><v-text-field v-model.number="form.vipMarkDownPct" type="number" min="0"
            label="VIP markdown %" data-testid="customer-vip-markdown" /></v-col>
          <v-col cols="12"><v-text-field v-model="form.remarks" label="Remarks"
            :disabled="!canSeePii && !!editing" data-testid="customer-remarks" /></v-col>
        </v-row>
        <v-checkbox v-if="duplicateWarning" v-model="confirmDuplicate"
          label="Confirm possible duplicate" data-testid="customer-duplicate-confirm" />
        <v-btn color="primary" :loading="busy" data-testid="customer-save" @click="saveCustomer">Save</v-btn>
        <v-btn variant="text" class="ml-2" @click="createOpen = false">Cancel</v-btn>
      </v-card-text>
    </v-card>

    <v-card v-if="mergeOpen" variant="outlined" class="mt-4">
      <v-card-title>Merge duplicate customers</v-card-title>
      <v-card-text>
        <v-row dense>
          <v-col cols="12" md="3"><v-text-field v-model.number="merge.sourceId" type="number"
            label="Source id" data-testid="customer-merge-source" /></v-col>
          <v-col cols="12" md="3"><v-text-field v-model.number="merge.targetId" type="number"
            label="Target id" data-testid="customer-merge-target" /></v-col>
          <v-col cols="12" md="6"><v-text-field v-model="merge.fullName" label="Canonical name (optional)"
            data-testid="customer-merge-name" /></v-col>
          <v-col cols="12" md="3"><v-text-field v-model="merge.phone" label="Canonical phone (optional)"
            data-testid="customer-merge-phone" /></v-col>
          <v-col cols="12" md="3"><v-text-field v-model="merge.email" label="Canonical email (optional)"
            data-testid="customer-merge-email" /></v-col>
          <v-col cols="12"><v-text-field v-model="merge.reason" label="Reason"
            data-testid="customer-merge-reason" /></v-col>
        </v-row>
        <v-btn color="primary" :loading="busy" data-testid="customer-merge-submit"
          @click="mergeCustomers">Merge</v-btn>
      </v-card-text>
    </v-card>
  </div>
</template>
