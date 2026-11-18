<script setup lang="ts">
import { computed, reactive, ref } from 'vue'
import { api, unwrap } from '@/api/client'
import { AppError } from '@/api/problems'
import { PermissionNames } from '@/security/permissions'
import { useSessionStore } from '@/stores/session'

interface WholesaleAccount {
  customerId: number
  isWholesale: boolean
  priceGrade: string | null
  termsCode: string | null
  termsDays: number
  creditLimit: number | string
  taxTreatment: string | null
  representativeStaffCode: string | null
  creditHold: boolean
  notes: string | null
}
interface PriceItem { sku: string; price: number | string }
interface PriceList {
  id: number; code: string; name: string; version: number; isCurrent: boolean
  items: PriceItem[]
}
interface WholesaleBalance {
  customerId: number; invoiced: number | string; returned: number | string
  payments: number | string; balance: number | string; creditLimit: number | string
  overCreditLimit: boolean
}
interface StatementItem {
  documentType: string; txNumber: string; date: string; amount: number | string
  description: string | null
}
interface WholesaleStatement {
  customerId: number; from: string; to: string; openingBalance: number | string
  invoiced: number | string; returned: number | string; payments: number | string
  closingBalance: number | string; creditLimit: number | string
  overCreditLimit: boolean; items: StatementItem[]
}
interface PriceQuote {
  customerId: number; sku: string; priceListCode: string; priceListVersion: number
  listUnitPrice: number | string; appliedUnitPrice: number | string
  isOverride: boolean; overrideReason: string | null
}

const sessionStore = useSessionStore()
const canMaintain = computed(() => sessionStore.hasPermission(PermissionNames.MasterDataMaintain))
const customerId = ref(0)
const account = ref<WholesaleAccount | null>(null)
const priceLists = ref<PriceList[]>([])
const quote = ref<PriceQuote | null>(null)
const balance = ref<WholesaleBalance | null>(null)
const statement = ref<WholesaleStatement | null>(null)
const statementFrom = ref(new Date(new Date().getFullYear(), new Date().getMonth(), 1)
  .toISOString().slice(0, 10))
const statementTo = ref(new Date().toISOString().slice(0, 10))
const busy = ref(false)
const error = ref<string | null>(null)
const notice = ref<string | null>(null)
const accountForm = reactive({
  priceGrade: 'A', termsCode: 'NET30', termsDays: 30, creditLimit: 0,
  taxTreatment: 'GST', representativeStaffCode: '', creditHold: false, notes: '',
})
const priceForm = reactive({ code: 'A', name: 'Wholesale list', items: '' })
const quoteForm = reactive({ sku: '', unitPrice: '' as string | number, overrideReason: '' })

function handleError(caught: unknown): void {
  if (caught instanceof AppError) {
    if (caught.kind === 'validation') {
      const fields = caught.fieldErrors as Record<string, readonly string[]>
      error.value = Object.values(fields)[0]?.[0] ?? caught.userMessage
    } else {
      error.value = caught.userMessage
    }
  } else {
    error.value = 'The request failed.'
  }
}

function loadAccount(): void {
  if (!customerId.value) return
  const found = account.value
  if (found?.customerId === customerId.value) {
    Object.assign(accountForm, {
      priceGrade: found.priceGrade ?? 'A', termsCode: found.termsCode ?? '',
      termsDays: found.termsDays, creditLimit: Number(found.creditLimit),
      taxTreatment: found.taxTreatment ?? '',
      representativeStaffCode: found.representativeStaffCode ?? '',
      creditHold: found.creditHold, notes: found.notes ?? '',
    })
  }
}

async function fetchAccount(): Promise<void> {
  if (!customerId.value) return
  busy.value = true
  error.value = null
  notice.value = null
  try {
    account.value = await unwrap(await api.client.GET('/api/v1/wholesale/accounts/{customerId}', {
      params: { path: { customerId: customerId.value } },
    })) as unknown as WholesaleAccount
    loadAccount()
    notice.value = `Wholesale account ${account.value.customerId} loaded.`
  } catch (caught) { handleError(caught) } finally { busy.value = false }
}

async function saveAccount(): Promise<void> {
  if (!customerId.value) return
  busy.value = true
  error.value = null
  try {
    account.value = await unwrap(await api.client.PUT('/api/v1/wholesale/accounts/{customerId}', {
      params: { path: { customerId: customerId.value } },
      body: {
        input: {
          priceGrade: accountForm.priceGrade,
          termsCode: accountForm.termsCode,
          termsDays: Number(accountForm.termsDays),
          creditLimit: Number(accountForm.creditLimit),
          taxTreatment: accountForm.taxTreatment,
          representativeStaffCode: accountForm.representativeStaffCode || null,
          creditHold: accountForm.creditHold,
          notes: accountForm.notes || null,
        },
        reason: 'wholesale account setup',
      },
    })) as unknown as WholesaleAccount
    notice.value = `Wholesale account ${account.value.customerId} saved.`
  } catch (caught) { handleError(caught) } finally { busy.value = false }
}

async function loadPriceLists(): Promise<void> {
  busy.value = true
  error.value = null
  try {
    priceLists.value = await unwrap(await api.client.GET('/api/v1/wholesale/price-lists')) as unknown as PriceList[]
  } catch (caught) { handleError(caught) } finally { busy.value = false }
}

function parseItems(): { sku: string; price: number }[] {
  return priceForm.items.split('\n')
    .map((line) => line.trim())
    .filter((line) => line.length > 0)
    .map((line) => {
      const [sku, price] = line.split(',')
      return { sku: (sku ?? '').trim(), price: Number((price ?? '').trim()) }
    })
}

async function publishPriceList(): Promise<void> {
  busy.value = true
  error.value = null
  try {
    const list = await unwrap(await api.client.POST('/api/v1/wholesale/price-lists', {
      body: {
        input: {
          code: priceForm.code, name: priceForm.name, items: parseItems(),
        },
        reason: 'publish wholesale price list',
      },
    })) as unknown as PriceList
    notice.value = `Price list ${list.code} v${list.version} published.`
    await loadPriceLists()
  } catch (caught) { handleError(caught) } finally { busy.value = false }
}

async function importLegacy(): Promise<void> {
  busy.value = true
  error.value = null
  try {
    const created = await unwrap(await api.client.POST('/api/v1/wholesale/price-lists/import-legacy', {
      body: { reason: 'import legacy wholesale grades' },
    })) as unknown as number
    notice.value = `Imported ${created} legacy price list(s).`
    await loadPriceLists()
  } catch (caught) { handleError(caught) } finally { busy.value = false }
}

async function loadBalance(): Promise<void> {
  if (!customerId.value) return
  busy.value = true
  error.value = null
  try {
    balance.value = await unwrap(await api.client.GET(
      '/api/v1/wholesale/customers/{customerId}/balance', {
        params: { path: { customerId: customerId.value } },
      })) as unknown as WholesaleBalance
  } catch (caught) { handleError(caught) } finally { busy.value = false }
}

async function loadStatement(): Promise<void> {
  if (!customerId.value) return
  busy.value = true
  error.value = null
  try {
    statement.value = await unwrap(await api.client.GET(
      '/api/v1/wholesale/customers/{customerId}/statement', {
        params: {
          path: { customerId: customerId.value },
          query: { from: statementFrom.value, to: statementTo.value },
        },
      })) as unknown as WholesaleStatement
    notice.value = `Statement loaded for ${customerId.value}.`
  } catch (caught) { handleError(caught) } finally { busy.value = false }
}

async function printStatement(): Promise<void> {
  if (!customerId.value) return
  busy.value = true
  error.value = null
  try {
    const response = await api.request(
      `/api/v1/wholesale/customers/${customerId.value}/statement/prints`, {
        method: 'POST',
        headers: { 'content-type': 'application/json' },
        body: JSON.stringify({
          from: statementFrom.value, to: statementTo.value, reprint: false,
          terminalCode: '01', reason: 'statement print',
        }),
      })
    if (!response.ok) throw new Error('statement print failed')
    await response.blob()
    notice.value = `Statement printed for ${customerId.value}.`
  } catch (caught) { handleError(caught) } finally { busy.value = false }
}

async function loadQuote(): Promise<void> {
  if (!customerId.value || !quoteForm.sku) return
  busy.value = true
  error.value = null
  try {
    quote.value = await unwrap(await api.client.GET('/api/v1/wholesale/customers/{customerId}/price', {
      params: {
        path: { customerId: customerId.value },
        query: {
          sku: quoteForm.sku,
          unitPrice: quoteForm.unitPrice === '' ? undefined : Number(quoteForm.unitPrice),
          overrideReason: quoteForm.overrideReason || undefined,
        },
      },
    })) as unknown as PriceQuote
    notice.value = quote.value.isOverride
      ? 'Price override applied.'
      : 'List price applied.'
  } catch (caught) { handleError(caught) } finally { busy.value = false }
}

loadPriceLists()
</script>

<template>
  <div data-testid="wholesale-page">
    <h1 class="text-h5 mb-4">Wholesale</h1>
    <v-alert v-if="error" type="error" variant="tonal" class="mb-4" data-testid="wholesale-error">
      {{ error }}
    </v-alert>
    <v-alert v-if="notice" type="success" variant="tonal" class="mb-4" data-testid="wholesale-notice">
      {{ notice }}
    </v-alert>

    <v-card variant="outlined" class="mb-4">
      <v-card-title>Account and terms</v-card-title>
      <v-card-text>
        <div class="d-flex ga-2 align-center mb-3">
          <v-text-field v-model.number="customerId" type="number" label="Customer id" density="compact"
            hide-details style="max-width: 180px" data-testid="wholesale-customer" />
          <v-btn color="primary" :loading="busy" data-testid="wholesale-load" @click="fetchAccount">Load</v-btn>
        </div>
        <v-row dense>
          <v-col cols="12" md="2">
            <v-select v-model="accountForm.priceGrade" :items="['A', 'B', 'C']" label="Price grade"
              density="compact" data-testid="wholesale-grade" />
          </v-col>
          <v-col cols="12" md="2">
            <v-text-field v-model="accountForm.termsCode" label="Terms" density="compact"
              data-testid="wholesale-terms" />
          </v-col>
          <v-col cols="12" md="2">
            <v-text-field v-model.number="accountForm.termsDays" type="number" label="Term days"
              density="compact" data-testid="wholesale-term-days" />
          </v-col>
          <v-col cols="12" md="2">
            <v-text-field v-model.number="accountForm.creditLimit" type="number" label="Credit limit"
              density="compact" data-testid="wholesale-credit" />
          </v-col>
          <v-col cols="12" md="2">
            <v-text-field v-model="accountForm.taxTreatment" label="Tax treatment" density="compact"
              data-testid="wholesale-tax" />
          </v-col>
          <v-col cols="12" md="2">
            <v-text-field v-model="accountForm.representativeStaffCode" label="Representative"
              density="compact" data-testid="wholesale-representative" />
          </v-col>
          <v-col cols="12">
            <v-text-field v-model="accountForm.notes" label="Notes" density="compact"
              data-testid="wholesale-notes" />
          </v-col>
        </v-row>
        <v-checkbox v-model="accountForm.creditHold" label="Credit hold" density="compact"
          hide-details data-testid="wholesale-credit-hold" />
        <v-btn color="primary" class="mt-2" :loading="busy" :disabled="!canMaintain"
          data-testid="wholesale-save" @click="saveAccount">Save account</v-btn>
      </v-card-text>
    </v-card>

    <v-row>
      <v-col cols="12" md="7">
        <v-card variant="outlined">
          <v-card-title>Price lists</v-card-title>
          <v-card-text>
            <v-table density="compact" data-testid="wholesale-price-lists">
              <thead><tr><th>Code</th><th>Name</th><th>Version</th><th>Items</th></tr></thead>
              <tbody>
                <tr v-for="list in priceLists" :key="list.id">
                  <td>{{ list.code }}</td><td>{{ list.name }}</td>
                  <td>{{ list.version }}</td><td>{{ list.items.length }}</td>
                </tr>
                <tr v-if="priceLists.length === 0">
                  <td colspan="4" class="text-medium-emphasis">No published price lists.</td>
                </tr>
              </tbody>
            </v-table>
            <v-row dense class="mt-3">
              <v-col cols="12" md="3">
                <v-text-field v-model="priceForm.code" label="Code" density="compact"
                  data-testid="wholesale-price-code" />
              </v-col>
              <v-col cols="12" md="5">
                <v-text-field v-model="priceForm.name" label="Name" density="compact"
                  data-testid="wholesale-price-name" />
              </v-col>
              <v-col cols="12">
                <v-textarea v-model="priceForm.items" label="Items (SKU,price per line)"
                  rows="3" density="compact" data-testid="wholesale-price-items" />
              </v-col>
            </v-row>
            <v-btn color="primary" :loading="busy" :disabled="!canMaintain"
              data-testid="wholesale-publish" @click="publishPriceList">Publish list</v-btn>
            <v-btn variant="text" class="ml-2" :loading="busy" :disabled="!canMaintain"
              data-testid="wholesale-import" @click="importLegacy">Import legacy grades</v-btn>
          </v-card-text>
        </v-card>
      </v-col>

      <v-col cols="12" md="5">
        <v-card variant="outlined" class="mb-4">
          <v-card-title>Balance</v-card-title>
          <v-card-text>
            <v-btn :loading="busy" data-testid="wholesale-balance-load"
              @click="loadBalance">Load balance</v-btn>
            <div v-if="balance" class="text-body-2 mt-2" data-testid="wholesale-balance">
              Invoiced {{ Number(balance.invoiced).toFixed(4) }} ·
              returned {{ Number(balance.returned).toFixed(4) }} ·
              payments {{ Number(balance.payments).toFixed(4) }} ·
              balance {{ Number(balance.balance).toFixed(4) }}
              <span v-if="balance.overCreditLimit" class="text-error">· over limit</span>
            </div>
          </v-card-text>
        </v-card>

        <v-card variant="outlined">
          <v-card-title>Statement</v-card-title>
          <v-card-text>
            <div class="d-flex ga-2 align-center mb-2">
              <v-text-field v-model="statementFrom" type="date" label="From" density="compact"
                hide-details data-testid="wholesale-statement-from" />
              <v-text-field v-model="statementTo" type="date" label="To" density="compact"
                hide-details data-testid="wholesale-statement-to" />
              <v-btn :loading="busy" data-testid="wholesale-statement-load"
                @click="loadStatement">Generate</v-btn>
            </div>
            <div v-if="statement" data-testid="wholesale-statement" class="text-body-2">
              Opening {{ Number(statement.openingBalance).toFixed(4) }} ·
              invoiced {{ Number(statement.invoiced).toFixed(4) }} ·
              returned {{ Number(statement.returned).toFixed(4) }} ·
              payments {{ Number(statement.payments).toFixed(4) }} ·
              closing {{ Number(statement.closingBalance).toFixed(4) }}
            </div>
            <v-btn class="mt-2" variant="text" :loading="busy"
              data-testid="wholesale-statement-print" @click="printStatement">Print statement</v-btn>
          </v-card-text>
        </v-card>
      </v-col>

      <v-col cols="12" md="5">
        <v-card variant="outlined">
          <v-card-title>Line price</v-card-title>
          <v-card-text>
            <v-text-field v-model="quoteForm.sku" label="SKU" density="compact"
              data-testid="wholesale-quote-sku" />
            <v-text-field v-model="quoteForm.unitPrice" type="number" label="Override price (optional)"
              density="compact" data-testid="wholesale-quote-price" />
            <v-text-field v-model="quoteForm.overrideReason" label="Override reason"
              density="compact" data-testid="wholesale-quote-reason" />
            <v-btn color="primary" :loading="busy" data-testid="wholesale-quote-load"
              @click="loadQuote">Resolve price</v-btn>
            <div v-if="quote" class="mt-3 text-body-2" data-testid="wholesale-quote-result">
              <div>List {{ quote.priceListCode }} v{{ quote.priceListVersion }}</div>
              <div>List price {{ Number(quote.listUnitPrice).toFixed(4) }}</div>
              <div>Applied {{ Number(quote.appliedUnitPrice).toFixed(4) }}</div>
              <div>{{ quote.isOverride ? `Override: ${quote.overrideReason}` : 'No override' }}</div>
            </div>
          </v-card-text>
        </v-card>
      </v-col>
    </v-row>
  </div>
</template>
