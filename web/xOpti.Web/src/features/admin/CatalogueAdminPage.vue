<script setup lang="ts">
import { onMounted, reactive, ref } from 'vue'
import { api, unwrap } from '@/api/client'
import { AppError } from '@/api/problems'

interface CatalogueRow {
  sku: string
  name?: string | null
  departmentCode: string
  classCode: string
  categoryCode: string
  supplierCode: string
  brandCode: string
  materialCode?: string | null
  lotTracked: boolean
  retailPriceFlag: boolean
  wholesalePriceFlag: boolean
  qtyOnHand: number
}

interface BarcodeTag {
  barcode: string
  sku: string
  labelText: string
  reprint: boolean
}

type Mode = 'edit' | 'prices' | 'retire' | 'barcode' | null

const loading = ref(true)
const saving = ref(false)
const forbidden = ref(false)
const errorMessage = ref<string | null>(null)
const notice = ref<string | null>(null)
const fieldErrors = ref<Record<string, string[]>>({})
const rows = ref<CatalogueRow[]>([])
const nextCursor = ref<string | null>(null)
const search = ref('')
const mode = ref<Mode>(null)
const selected = ref<CatalogueRow | null>(null)
const tag = ref<BarcodeTag | null>(null)

const form = reactive({
  name: '',
  departmentCode: '',
  classCode: '',
  categoryCode: '',
  supplierCode: '',
  brandCode: '',
  materialCode: '',
  lotTracked: false,
  retailPriceFlag: false,
  wholesalePriceFlag: false,
  retailPrice: '',
  leastSellingPrice: '',
  retailMarkdownAmount: '',
  retailMarkdownPercent: '',
  suggestedRetailPrice: '',
  gradeA: '',
  gradeB: '',
  gradeC: '',
  reason: '',
  confirmOnHand: false,
})

function clearForm(): void {
  Object.assign(form, {
    name: '', departmentCode: '', classCode: '', categoryCode: '', supplierCode: '', brandCode: '',
    materialCode: '', lotTracked: false, retailPriceFlag: false, wholesalePriceFlag: false,
    retailPrice: '', leastSellingPrice: '', retailMarkdownAmount: '', retailMarkdownPercent: '',
    suggestedRetailPrice: '', gradeA: '', gradeB: '', gradeC: '', reason: '', confirmOnHand: false,
  })
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
  const messages = fieldErrors.value[field] ?? []
  return messages.length > 0 ? messages[0] : null
}

function num(value: string): number | null {
  return value.trim() === '' ? null : Number(value)
}

async function load(reset = true): Promise<void> {
  loading.value = true
  errorMessage.value = null
  try {
    const page = await unwrap(
      await api.client.GET('/api/v1/admin/skus', {
        params: {
          query: {
            search: search.value.trim() || undefined,
            cursor: reset ? undefined : (nextCursor.value ?? undefined),
            pageSize: 50,
          },
        },
      }),
    )
    rows.value = reset ? (page.items as CatalogueRow[]) : [...rows.value, ...(page.items as CatalogueRow[])]
    nextCursor.value = page.nextCursor ?? null
  } catch (error) {
    handleError(error)
  } finally {
    loading.value = false
  }
}

function openEdit(row: CatalogueRow): void {
  clearForm()
  selected.value = row
  Object.assign(form, {
    name: row.name ?? '',
    departmentCode: row.departmentCode,
    classCode: row.classCode,
    categoryCode: row.categoryCode,
    supplierCode: row.supplierCode,
    brandCode: row.brandCode,
    materialCode: row.materialCode ?? '',
    lotTracked: row.lotTracked,
    retailPriceFlag: row.retailPriceFlag,
    wholesalePriceFlag: row.wholesalePriceFlag,
  })
  mode.value = 'edit'
}

function openPrices(row: CatalogueRow): void {
  clearForm()
  selected.value = row
  mode.value = 'prices'
}

function openRetire(row: CatalogueRow): void {
  clearForm()
  selected.value = row
  form.confirmOnHand = false
  mode.value = 'retire'
}

async function openBarcode(row: CatalogueRow): Promise<void> {
  clearForm()
  selected.value = row
  tag.value = null
  mode.value = 'barcode'
  try {
    tag.value = await unwrap(
      await api.client.GET('/api/v1/admin/skus/{sku}/barcode', { params: { path: { sku: row.sku } } }),
    )
  } catch (error) {
    if (error instanceof AppError && error.kind === 'validation') {
      return // no tag yet: offer generation
    }
    handleError(error)
  }
}

async function submit(): Promise<void> {
  if (!selected.value) {
    return
  }
  saving.value = true
  fieldErrors.value = {}
  errorMessage.value = null
  try {
    const sku = selected.value.sku
    if (mode.value === 'edit') {
      const updated = await unwrap(
        await api.client.PUT('/api/v1/admin/skus/{sku}', {
          params: { path: { sku } },
          body: {
            name: form.name,
            departmentCode: form.departmentCode,
            classCode: form.classCode,
            categoryCode: form.categoryCode,
            supplierCode: form.supplierCode,
            brandCode: form.brandCode,
            materialCode: form.materialCode || null,
            lotTracked: form.lotTracked,
            retailPriceFlag: form.retailPriceFlag,
            wholesalePriceFlag: form.wholesalePriceFlag,
            reason: form.reason,
          },
        }),
      )
      notice.value = `SKU '${updated.sku}' updated.`
    } else if (mode.value === 'prices') {
      const prices = await unwrap(
        await api.client.PUT('/api/v1/admin/skus/{sku}/prices', {
          params: { path: { sku } },
          body: {
            retailPrice: num(form.retailPrice),
            leastSellingPrice: num(form.leastSellingPrice),
            retailMarkdownAmount: num(form.retailMarkdownAmount),
            retailMarkdownPercent: num(form.retailMarkdownPercent),
            suggestedRetailPrice: num(form.suggestedRetailPrice),
            gradeA: num(form.gradeA),
            gradeB: num(form.gradeB),
            gradeC: num(form.gradeC),
            reason: form.reason,
          },
        }),
      )
      notice.value = `Prices for '${prices.sku}' updated.`
    } else if (mode.value === 'retire') {
      await unwrap(
        await api.client.POST('/api/v1/admin/skus/{sku}/retire', {
          params: { path: { sku } },
          body: { reason: form.reason, confirmOnHand: form.confirmOnHand },
        }),
      )
      notice.value = `SKU '${sku}' retired.`
    } else if (mode.value === 'barcode' && !tag.value) {
      tag.value = await unwrap(
        await api.client.POST('/api/v1/admin/skus/{sku}/barcode', {
          params: { path: { sku } },
          body: { reason: form.reason },
        }),
      )
      notice.value = `Barcode tag generated for '${sku}'.`
      return
    }

    mode.value = null
    selected.value = null
    await load()
  } catch (error) {
    handleError(error)
  } finally {
    saving.value = false
  }
}

async function reprint(): Promise<void> {
  if (!selected.value) {
    return
  }
  saving.value = true
  try {
    tag.value = await unwrap(
      await api.client.GET('/api/v1/admin/skus/{sku}/barcode', {
        params: { path: { sku: selected.value.sku } },
      }),
    )
    notice.value = `Reprinting tag for '${selected.value.sku}' (identical label).`
  } catch (error) {
    handleError(error)
  } finally {
    saving.value = false
  }
}

onMounted(() => load())
</script>

<template>
  <div data-testid="catalogue-admin-page">
    <div class="d-flex align-center flex-wrap ga-3 mb-4">
      <h1 class="text-h5">Catalogue</h1>
      <v-spacer />
      <v-text-field
        v-model="search"
        label="Search SKU or name"
        density="compact"
        clearable
        style="max-width: 320px"
        data-testid="catalogue-search"
        @keyup.enter="load()"
      />
      <v-btn variant="tonal" data-testid="catalogue-search-button" @click="load()">Search</v-btn>
    </div>

    <v-alert v-if="forbidden" type="error" variant="tonal" data-testid="catalogue-forbidden">
      You do not have permission to administer the catalogue.
    </v-alert>
    <v-alert v-else-if="errorMessage" type="error" variant="tonal" class="mb-4" data-testid="catalogue-error">
      {{ errorMessage }}
    </v-alert>
    <v-alert v-if="notice" type="success" variant="tonal" class="mb-4" data-testid="catalogue-notice">
      {{ notice }}
    </v-alert>

    <div v-if="loading" class="d-flex justify-center pa-8" data-testid="catalogue-loading">
      <v-progress-circular indeterminate />
    </div>

    <template v-else-if="!forbidden">
      <v-table data-testid="catalogue-table" density="comfortable">
        <thead>
          <tr>
            <th>SKU</th><th>Name</th><th>Qty</th><th>Flags</th><th>Actions</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in rows" :key="row.sku" :data-testid="`catalogue-row-${row.sku}`">
            <td>{{ row.sku }}</td>
            <td>{{ row.name }}</td>
            <td>{{ row.qtyOnHand }}</td>
            <td>
              <v-chip v-if="row.lotTracked" size="small" class="mr-1" data-testid="flag-lot">Lot</v-chip>
              <v-chip v-if="row.retailPriceFlag" size="small" class="mr-1">Retail</v-chip>
              <v-chip v-if="row.wholesalePriceFlag" size="small">Wholesale</v-chip>
            </td>
            <td class="d-flex flex-wrap ga-1">
              <v-btn size="small" variant="text" :data-testid="`catalogue-edit-${row.sku}`" @click="openEdit(row)">
                Edit
              </v-btn>
              <v-btn size="small" variant="text" :data-testid="`catalogue-prices-${row.sku}`" @click="openPrices(row)">
                Prices
              </v-btn>
              <v-btn size="small" variant="text" :data-testid="`catalogue-barcode-${row.sku}`" @click="openBarcode(row)">
                Barcode
              </v-btn>
              <v-btn
                size="small" variant="text" color="error"
                :data-testid="`catalogue-retire-${row.sku}`" @click="openRetire(row)"
              >
                Retire
              </v-btn>
            </td>
          </tr>
          <tr v-if="rows.length === 0">
            <td colspan="5" class="text-medium-emphasis">No SKUs found.</td>
          </tr>
        </tbody>
      </v-table>

      <div v-if="nextCursor" class="mt-4">
        <v-btn variant="text" data-testid="catalogue-load-more" @click="load(false)">Load more</v-btn>
      </div>
    </template>

    <v-card v-if="mode === 'edit'" class="mt-6" variant="outlined" data-testid="catalogue-form-edit">
      <v-card-title>Edit {{ selected?.sku }}</v-card-title>
      <v-card-text>
        <v-text-field v-model="form.name" label="Name" data-testid="catalogue-name"
          :error-messages="errorFor('Name')" />
        <v-text-field v-model="form.departmentCode" label="Department" data-testid="catalogue-department"
          :error-messages="errorFor('DepartmentCode')" />
        <v-text-field v-model="form.classCode" label="Class" data-testid="catalogue-class"
          :error-messages="errorFor('ClassCode')" />
        <v-text-field v-model="form.categoryCode" label="Category" data-testid="catalogue-category"
          :error-messages="errorFor('CategoryCode')" />
        <v-text-field v-model="form.supplierCode" label="Supplier" data-testid="catalogue-supplier"
          :error-messages="errorFor('SupplierCode')" />
        <v-text-field v-model="form.brandCode" label="Brand" data-testid="catalogue-brand"
          :error-messages="errorFor('BrandCode')" />
        <v-checkbox v-model="form.lotTracked" label="Track lots" data-testid="catalogue-lot" />
        <v-checkbox v-model="form.retailPriceFlag" label="Retail price" />
        <v-checkbox v-model="form.wholesalePriceFlag" label="Wholesale price" />
        <v-text-field v-model="form.reason" label="Reason" data-testid="catalogue-reason"
          :error-messages="errorFor('Reason')" />
      </v-card-text>
      <v-card-actions>
        <v-spacer />
        <v-btn variant="text" data-testid="catalogue-cancel" @click="mode = null">Cancel</v-btn>
        <v-btn color="primary" data-testid="catalogue-submit" :loading="saving" @click="submit">Save</v-btn>
      </v-card-actions>
    </v-card>

    <v-card v-if="mode === 'prices'" class="mt-6" variant="outlined" data-testid="catalogue-form-prices">
      <v-card-title>Prices — {{ selected?.sku }}</v-card-title>
      <v-card-text>
        <v-text-field v-model="form.retailPrice" label="Retail price" type="number" step="0.0001"
          data-testid="catalogue-retail-price" :error-messages="errorFor('RetailPrice')" />
        <v-text-field v-model="form.leastSellingPrice" label="Least selling price" type="number" step="0.0001"
          data-testid="catalogue-least-price" :error-messages="errorFor('LeastSellingPrice')" />
        <v-text-field v-model="form.retailMarkdownAmount" label="Markdown amount" type="number" step="0.0001"
          data-testid="catalogue-markdown" />
        <v-text-field v-model="form.gradeA" label="Wholesale grade A" type="number" step="0.0001"
          data-testid="catalogue-grade-a" />
        <v-text-field v-model="form.reason" label="Reason" data-testid="catalogue-reason"
          :error-messages="errorFor('Reason')" />
      </v-card-text>
      <v-card-actions>
        <v-spacer />
        <v-btn variant="text" data-testid="catalogue-cancel" @click="mode = null">Cancel</v-btn>
        <v-btn color="primary" data-testid="catalogue-submit" :loading="saving" @click="submit">Save prices</v-btn>
      </v-card-actions>
    </v-card>

    <v-card v-if="mode === 'retire'" class="mt-6" variant="outlined" data-testid="catalogue-form-retire">
      <v-card-title>Retire {{ selected?.sku }}</v-card-title>
      <v-card-text>
        <p>On hand: {{ selected?.qtyOnHand }}</p>
        <v-text-field v-model="form.reason" label="Retirement reason" data-testid="catalogue-reason"
          :error-messages="errorFor('Reason')" />
        <v-checkbox v-model="form.confirmOnHand" label="Retire even with stock on hand"
          data-testid="catalogue-confirm-on-hand" :error-messages="errorFor('ConfirmOnHand')" />
        <v-alert v-if="errorFor('ConfirmOnHand')" type="warning" variant="tonal" dense
          data-testid="catalogue-on-hand-hint">
          {{ errorFor('ConfirmOnHand') }}
        </v-alert>
      </v-card-text>
      <v-card-actions>
        <v-spacer />
        <v-btn variant="text" data-testid="catalogue-cancel" @click="mode = null">Cancel</v-btn>
        <v-btn color="error" data-testid="catalogue-submit" :loading="saving" @click="submit">Retire</v-btn>
      </v-card-actions>
    </v-card>

    <v-card v-if="mode === 'barcode'" class="mt-6" variant="outlined" data-testid="catalogue-form-barcode">
      <v-card-title>Barcode tag — {{ selected?.sku }}</v-card-title>
      <v-card-text>
        <v-alert v-if="tag" type="info" variant="tonal" data-testid="catalogue-barcode-tag">
          Barcode: <code>{{ tag.barcode }}</code> · Label: <code>{{ tag.labelText }}</code>
          <span v-if="tag.reprint" data-testid="catalogue-barcode-reprint">(reprint)</span>
        </v-alert>
        <v-text-field v-if="!tag" v-model="form.reason" label="Reason" data-testid="catalogue-reason"
          :error-messages="errorFor('Reason')" />
        <v-alert v-if="errorFor('Sku')" type="warning" variant="tonal" dense data-testid="catalogue-barcode-error">
          {{ errorFor('Sku') }}
        </v-alert>
      </v-card-text>
      <v-card-actions>
        <v-spacer />
        <v-btn variant="text" data-testid="catalogue-cancel" @click="mode = null">Close</v-btn>
        <v-btn v-if="tag" color="primary" data-testid="catalogue-barcode-reprint-button" :loading="saving" @click="reprint">
          Reprint tag
        </v-btn>
        <v-btn v-else color="primary" data-testid="catalogue-submit" :loading="saving" @click="submit">
          Generate tag
        </v-btn>
      </v-card-actions>
    </v-card>
  </div>
</template>
