<script setup lang="ts">
import { computed, onMounted, reactive, ref, watch } from 'vue'
import { api, unwrap } from '@/api/client'
import { AppError } from '@/api/problems'

interface ReferenceItem {
  kind: string
  key: string
  name: string
  parent?: string | null
  detail?: string | null
}

const kinds = [
  'City', 'Province', 'Country', 'Department', 'Class', 'Category',
  'Brand', 'Material', 'TaxMethod', 'PaymentMethod',
] as const

const kind = ref<(typeof kinds)[number]>('Brand')
const search = ref('')
const loading = ref(true)
const saving = ref(false)
const forbidden = ref(false)
const errorMessage = ref<string | null>(null)
const notice = ref<string | null>(null)
const fieldErrors = ref<Record<string, string[]>>({})
const items = ref<ReferenceItem[]>([])
const nextCursor = ref<string | null>(null)

const mode = ref<'create' | 'edit' | null>(null)
const retireTarget = ref<ReferenceItem | null>(null)
const form = reactive({
  key: '',
  name: '',
  parent: '',
  summaryFlag: false,
  costingMethod: '1',
  inventoryMethod: '1',
  taxMethod: '1',
  paymentNameShort: '',
  exchangeRate: 1,
  reason: '',
  confirmReferenced: false,
})

const isCategory = computed(() => kind.value === 'Category')
const isPayment = computed(() => kind.value === 'PaymentMethod')

function clearForm(): void {
  form.key = ''
  form.name = ''
  form.parent = ''
  form.summaryFlag = false
  form.costingMethod = '1'
  form.inventoryMethod = '1'
  form.taxMethod = '1'
  form.paymentNameShort = ''
  form.exchangeRate = 1
  form.reason = ''
  form.confirmReferenced = false
  fieldErrors.value = {}
  errorMessage.value = null
}

function handleError(error: unknown): void {
  if (error instanceof AppError) {
    if (error.kind === 'authorization' || error.kind === 'unauthenticated') {
      forbidden.value = true
      return
    }
    if (error.kind === 'validation') {
      fieldErrors.value = Object.fromEntries(
        Object.entries(error.fieldErrors).map(([field, messages]) => [field, [...messages]]),
      )
      errorMessage.value = error.userMessage
      return
    }
    errorMessage.value = error.userMessage
    return
  }
  errorMessage.value = 'The request failed. Please try again.'
}

function errorFor(field: string): string | null {
  const messages = fieldErrors.value[field] ?? fieldErrors.value[`Input.${field}`]
  return messages && messages.length > 0 ? messages[0] : null
}

async function load(reset = true): Promise<void> {
  loading.value = true
  errorMessage.value = null
  try {
    const page = await unwrap(
      await api.client.GET('/api/v1/admin/reference/{kind}', {
        params: {
          path: { kind: kind.value },
          query: {
            search: search.value.trim() || undefined,
            cursor: reset ? undefined : (nextCursor.value ?? undefined),
            pageSize: 50,
          },
        },
      }),
    )
    items.value = reset ? (page.items as ReferenceItem[]) : [...items.value, ...(page.items as ReferenceItem[])]
    nextCursor.value = page.nextCursor ?? null
  } catch (error) {
    handleError(error)
  } finally {
    loading.value = false
  }
}

function openCreate(): void {
  clearForm()
  mode.value = 'create'
  retireTarget.value = null
}

function openEdit(item: ReferenceItem): void {
  clearForm()
  mode.value = 'edit'
  retireTarget.value = null
  form.key = item.key
  form.name = item.name
  form.parent = item.parent ?? ''
}

function openRetire(item: ReferenceItem): void {
  clearForm()
  mode.value = null
  retireTarget.value = item
  form.key = item.key
}

async function submit(): Promise<void> {
  saving.value = true
  fieldErrors.value = {}
  errorMessage.value = null
  try {
    if (mode.value === 'create') {
      const created = await unwrap(
        await api.client.POST('/api/v1/admin/reference/{kind}', {
          params: { path: { kind: kind.value } },
          body: {
            key: form.key,
            name: form.name,
            parent: form.parent || null,
            summaryFlag: form.summaryFlag || null,
            costingMethod: isCategory.value ? form.costingMethod : null,
            inventoryMethod: isCategory.value ? form.inventoryMethod : null,
            taxMethod: isCategory.value ? form.taxMethod : null,
            paymentNameShort: isPayment.value ? form.paymentNameShort : null,
            exchangeRate: isPayment.value ? form.exchangeRate : null,
            reason: form.reason,
          },
        }),
      )
      notice.value = `${kind.value} '${created.key}' created.`
    } else if (mode.value === 'edit') {
      await unwrap(
        await api.client.PUT('/api/v1/admin/reference/{kind}', {
          params: { path: { kind: kind.value } },
          body: {
            key: form.key,
            name: form.name,
            parent: form.parent || null,
            summaryFlag: form.summaryFlag || null,
            costingMethod: isCategory.value ? form.costingMethod : null,
            inventoryMethod: isCategory.value ? form.inventoryMethod : null,
            taxMethod: isCategory.value ? form.taxMethod : null,
            paymentNameShort: isPayment.value ? form.paymentNameShort : null,
            exchangeRate: isPayment.value ? form.exchangeRate : null,
            reason: form.reason,
          },
        }),
      )
      notice.value = `${kind.value} '${form.key}' updated.`
    } else if (retireTarget.value) {
      await unwrap(
        await api.client.POST('/api/v1/admin/reference/{kind}/retire', {
          params: { path: { kind: kind.value } },
          body: {
            key: retireTarget.value.key,
            reason: form.reason,
            confirmReferenced: form.confirmReferenced,
          },
        }),
      )
      notice.value = `${kind.value} '${retireTarget.value.key}' retired.`
    }

    mode.value = null
    retireTarget.value = null
    await load()
  } catch (error) {
    handleError(error)
  } finally {
    saving.value = false
  }
}

watch(kind, () => {
  clearForm()
  mode.value = null
  retireTarget.value = null
  items.value = []
  nextCursor.value = null
  notice.value = null
  void load()
})

onMounted(() => load())
</script>

<template>
  <div data-testid="reference-admin-page">
    <div class="d-flex align-center flex-wrap ga-3 mb-4">
      <h1 class="text-h5">Reference data</h1>
      <v-spacer />
      <v-btn color="primary" data-testid="reference-create-open" :disabled="forbidden" @click="openCreate">
        New {{ kind }}
      </v-btn>
    </div>

    <div class="d-flex flex-wrap ga-3 mb-4">
      <v-select
        v-model="kind"
        :items="kinds"
        label="Type"
        density="compact"
        style="max-width: 220px"
        data-testid="reference-kind"
      />
      <v-text-field
        v-model="search"
        label="Search name"
        density="compact"
        clearable
        style="max-width: 300px"
        data-testid="reference-search"
        @keyup.enter="load()"
      />
      <v-btn variant="tonal" data-testid="reference-search-button" @click="load()">Search</v-btn>
    </div>

    <v-alert v-if="forbidden" type="error" variant="tonal" data-testid="reference-forbidden">
      You do not have permission to administer reference data.
    </v-alert>
    <v-alert v-else-if="errorMessage" type="error" variant="tonal" class="mb-4" data-testid="reference-error">
      {{ errorMessage }}
    </v-alert>
    <v-alert v-if="notice" type="success" variant="tonal" class="mb-4" data-testid="reference-notice">
      {{ notice }}
    </v-alert>

    <div v-if="loading" class="d-flex justify-center pa-8" data-testid="reference-loading">
      <v-progress-circular indeterminate />
    </div>

    <template v-else-if="!forbidden">
      <v-table data-testid="reference-table" density="comfortable">
        <thead>
          <tr>
            <th>Key</th>
            <th>Name</th>
            <th>Parent</th>
            <th>Detail</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="item in items" :key="item.key" :data-testid="`reference-row-${item.key}`">
            <td>{{ item.key }}</td>
            <td>{{ item.name }}</td>
            <td>{{ item.parent || '—' }}</td>
            <td>{{ item.detail || '—' }}</td>
            <td class="d-flex ga-1">
              <v-btn size="small" variant="text" :data-testid="`reference-edit-${item.key}`" @click="openEdit(item)">
                Edit
              </v-btn>
              <v-btn
                size="small"
                variant="text"
                color="error"
                :data-testid="`reference-retire-${item.key}`"
                @click="openRetire(item)"
              >
                Retire
              </v-btn>
            </td>
          </tr>
          <tr v-if="items.length === 0">
            <td colspan="5" class="text-medium-emphasis">No {{ kind }} records.</td>
          </tr>
        </tbody>
      </v-table>

      <div v-if="nextCursor" class="mt-4">
        <v-btn variant="text" data-testid="reference-load-more" @click="load(false)">Load more</v-btn>
      </div>
    </template>

    <v-card v-if="mode" class="mt-6" variant="outlined" :data-testid="`reference-form-${mode}`">
      <v-card-title>{{ mode === 'create' ? `New ${kind}` : `Edit ${kind}` }}</v-card-title>
      <v-card-text>
        <v-text-field v-model="form.key" label="Key" :disabled="mode === 'edit'" data-testid="reference-key"
          :error-messages="errorFor('Key')" />
        <v-text-field v-model="form.name" label="Name" data-testid="reference-name"
          :error-messages="errorFor('Name')" />
        <v-text-field v-model="form.parent" label="Parent (province/country or dept/class)"
          data-testid="reference-parent" :error-messages="errorFor('Parent')" />
        <template v-if="isCategory">
          <v-text-field v-model="form.costingMethod" label="Costing method 1=FIFO 2=LIFO"
            data-testid="reference-costing" :error-messages="errorFor('CostingMethod')" />
          <v-text-field v-model="form.inventoryMethod" label="Inventory method"
            data-testid="reference-inventory" :error-messages="errorFor('InventoryMethod')" />
          <v-text-field v-model="form.taxMethod" label="Tax method"
            data-testid="reference-tax" :error-messages="errorFor('TaxMethod')" />
        </template>
        <template v-if="isPayment">
          <v-text-field v-model="form.paymentNameShort" label="Short name"
            data-testid="reference-payment-short" :error-messages="errorFor('PaymentNameShort')" />
          <v-text-field v-model.number="form.exchangeRate" type="number" label="Exchange rate"
            data-testid="reference-exchange-rate" :error-messages="errorFor('ExchangeRate')" />
        </template>
        <v-text-field v-model="form.reason" label="Reason (recorded in the audit trail)"
          data-testid="reference-reason" :error-messages="errorFor('Reason')" />
      </v-card-text>
      <v-card-actions>
        <v-spacer />
        <v-btn variant="text" data-testid="reference-cancel" @click="mode = null">Cancel</v-btn>
        <v-btn color="primary" data-testid="reference-submit" :loading="saving" @click="submit">Save</v-btn>
      </v-card-actions>
    </v-card>

    <v-card v-if="retireTarget" class="mt-6" variant="outlined" data-testid="reference-retire-form">
      <v-card-title>Retire {{ retireTarget.key }}</v-card-title>
      <v-card-text>
        <v-text-field v-model="form.reason" label="Retirement reason" data-testid="reference-reason"
          :error-messages="errorFor('Reason')" />
        <v-checkbox v-model="form.confirmReferenced" label="Also retire when referenced by existing records"
          data-testid="reference-confirm-referenced"
          :error-messages="errorFor('ConfirmReferenced')" />
        <v-alert v-if="errorFor('ConfirmReferenced')" type="warning" variant="tonal" dense
          data-testid="reference-referenced-hint">
          This record is still referenced. Review the count and confirm explicitly.
        </v-alert>
      </v-card-text>
      <v-card-actions>
        <v-spacer />
        <v-btn variant="text" data-testid="reference-cancel" @click="retireTarget = null">Cancel</v-btn>
        <v-btn color="error" data-testid="reference-submit" :loading="saving" @click="submit">Retire</v-btn>
      </v-card-actions>
    </v-card>
  </div>
</template>
