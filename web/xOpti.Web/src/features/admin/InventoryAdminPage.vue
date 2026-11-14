<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { api, unwrap } from '@/api/client'
import { AppError } from '@/api/problems'

interface Row {
  sku: string
  name?: string | null
  qtyOnHand: number
  lotTracked: boolean
}
interface Lot { lotNo: string; supplierCode: string; qtyOnHand: number }
interface Movement { dateOfEntry: string; txType: string; txNumber: string; qty: number; amount?: { amount: number } }
interface Valuation {
  qtyOnHand: number
  averageCost?: { amount: number }
  extendedCost?: { amount: number }
  lots: Array<{ lotNo: string; qtyOnHand: number; unitCost?: { amount: number } }>
}

const rows = ref<Row[]>([])
const nextCursor = ref<string | null>(null)
const search = ref('')
const loading = ref(true)
const detailLoading = ref(false)
const forbidden = ref(false)
const error = ref<string | null>(null)
const selected = ref<Row | null>(null)
const lots = ref<Lot[]>([])
const movements = ref<Movement[]>([])
const valuation = ref<Valuation | null>(null)
const movementCursor = ref<string | null>(null)
const exceptionsOnly = ref(false)

const visibleRows = computed(() =>
  exceptionsOnly.value ? rows.value.filter((row) => row.qtyOnHand <= 0) : rows.value)
const exceptionCount = computed(() => rows.value.filter((row) => row.qtyOnHand <= 0).length)

function handleError(caught: unknown): void {
  if (caught instanceof AppError) {
    forbidden.value = caught.kind === 'authorization' || caught.kind === 'unauthenticated'
    error.value = caught.userMessage
  } else {
    error.value = 'The request failed.'
  }
}

async function load(reset = true): Promise<void> {
  loading.value = true
  error.value = null
  try {
    const page = await unwrap(
      await api.client.GET('/api/v1/admin/skus', {
        params: { query: { search: search.value.trim() || undefined,
          cursor: reset ? undefined : (nextCursor.value ?? undefined), pageSize: 50 } },
      }),
    )
    rows.value = reset ? (page.items as Row[]) : [...rows.value, ...(page.items as Row[])]
    nextCursor.value = page.nextCursor ?? null
  } catch (caught) {
    handleError(caught)
  } finally {
    loading.value = false
  }
}

async function open(row: Row): Promise<void> {
  selected.value = row
  detailLoading.value = true
  error.value = null
  lots.value = []
  movements.value = []
  valuation.value = null
  movementCursor.value = null
  try {
    const [availability, movementPage, value] = await Promise.all([
      unwrap(await api.client.GET('/api/v1/inventory/{sku}/availability', { params: { path: { sku: row.sku } } })),
      unwrap(await api.client.GET('/api/v1/inventory/{sku}/movements', { params: { path: { sku: row.sku }, query: { pageSize: 50 } } })),
      unwrap(await api.client.GET('/api/v1/inventory/{sku}/valuation', { params: { path: { sku: row.sku } } })),
    ])
    lots.value = availability.lots as Lot[]
    movements.value = movementPage.items as Movement[]
    movementCursor.value = movementPage.nextCursor ?? null
    valuation.value = value as Valuation
  } catch (caught) {
    handleError(caught)
  } finally {
    detailLoading.value = false
  }
}

async function moreMovements(): Promise<void> {
  if (!selected.value || !movementCursor.value) return
  try {
    const page = await unwrap(
      await api.client.GET('/api/v1/inventory/{sku}/movements', {
        params: { path: { sku: selected.value.sku },
          query: { pageSize: 50, cursor: movementCursor.value } },
      }),
    )
    movements.value = [...movements.value, ...(page.items as Movement[])]
    movementCursor.value = page.nextCursor ?? null
  } catch (caught) {
    handleError(caught)
  }
}

onMounted(() => load())
</script>

<template>
  <div data-testid="inventory-page">
    <div class="d-flex align-center flex-wrap ga-3 mb-4">
      <h1 class="text-h5">Inventory</h1>
      <v-spacer />
      <v-text-field v-model="search" label="Search SKU or name" density="compact" clearable
        style="max-width: 320px" data-testid="inventory-search" @keyup.enter="load()" />
      <v-btn variant="tonal" data-testid="inventory-search-button" @click="load()">Search</v-btn>
    </div>

    <v-alert v-if="forbidden" type="error" variant="tonal" data-testid="inventory-forbidden">
      You do not have permission to view inventory.
    </v-alert>
    <v-alert v-else-if="error" type="error" variant="tonal" class="mb-4" data-testid="inventory-error">
      {{ error }}
    </v-alert>

    <div class="d-flex ga-4 align-center mb-2">
      <v-checkbox v-model="exceptionsOnly" label="Exceptions only (zero or negative on hand)"
        data-testid="inventory-exceptions" hide-details />
      <v-chip size="small" color="warning" data-testid="inventory-exception-count">
        {{ exceptionCount }} exception(s)
      </v-chip>
    </div>

    <div v-if="loading" class="d-flex justify-center pa-8" data-testid="inventory-loading">
      <v-progress-circular indeterminate />
    </div>

    <template v-else-if="!forbidden">
      <v-table data-testid="inventory-table" density="comfortable">
        <thead><tr><th>SKU</th><th>Name</th><th>On hand</th><th /></tr></thead>
        <tbody>
          <tr v-for="row in visibleRows" :key="row.sku" :data-testid="`inventory-row-${row.sku}`">
            <td>{{ row.sku }}</td>
            <td>{{ row.name }}</td>
            <td>{{ row.qtyOnHand }}</td>
            <td>
              <v-btn size="small" variant="text" :data-testid="`inventory-open-${row.sku}`" @click="open(row)">
                Open
              </v-btn>
            </td>
          </tr>
          <tr v-if="visibleRows.length === 0">
            <td colspan="4" class="text-medium-emphasis" data-testid="inventory-empty">
              {{ exceptionsOnly ? 'No exceptions in this page.' : 'No inventory records.' }}
            </td>
          </tr>
        </tbody>
      </v-table>

      <div v-if="nextCursor" class="mt-4">
        <v-btn variant="text" data-testid="inventory-load-more" @click="load(false)">Load more</v-btn>
      </div>
    </template>

    <v-card v-if="selected" class="mt-6" variant="outlined" data-testid="inventory-detail">
      <v-card-title>{{ selected.sku }} — {{ selected.name }}</v-card-title>
      <v-card-text>
        <div v-if="detailLoading" class="d-flex justify-center pa-4" data-testid="inventory-detail-loading">
          <v-progress-circular indeterminate />
        </div>
        <template v-else>
          <h2 class="text-subtitle-1">Valuation</h2>
          <p data-testid="inventory-valuation">
            On hand: {{ valuation?.qtyOnHand ?? selected.qtyOnHand }} ·
            <template v-if="valuation?.averageCost">Average cost: {{ valuation.averageCost.amount }} ·</template>
            <template v-if="valuation?.extendedCost">Extended: {{ valuation.extendedCost.amount }}</template>
          </p>

          <h2 class="text-subtitle-1 mt-4">Lots</h2>
          <v-table density="compact" data-testid="inventory-lots">
            <thead><tr><th>Lot</th><th>Supplier</th><th>On hand</th></tr></thead>
            <tbody>
              <tr v-for="lot in lots" :key="lot.lotNo">
                <td>{{ lot.lotNo }}</td><td>{{ lot.supplierCode }}</td><td>{{ lot.qtyOnHand }}</td>
              </tr>
              <tr v-if="lots.length === 0"><td colspan="3">No lots (not lot-tracked).</td></tr>
            </tbody>
          </v-table>

          <h2 class="text-subtitle-1 mt-4">Movement history</h2>
          <v-table density="compact" data-testid="inventory-movements">
            <thead><tr><th>Date</th><th>Type</th><th>Document</th><th>Qty</th></tr></thead>
            <tbody>
              <tr v-for="movement in movements" :key="`${movement.txNumber}-${movement.dateOfEntry}`">
                <td>{{ movement.dateOfEntry }}</td><td>{{ movement.txType }}</td>
                <td>{{ movement.txNumber }}</td><td>{{ movement.qty }}</td>
              </tr>
              <tr v-if="movements.length === 0"><td colspan="4">No movements.</td></tr>
            </tbody>
          </v-table>
          <v-btn v-if="movementCursor" variant="text" class="mt-2" data-testid="inventory-more-movements"
            @click="moreMovements">Load more movements</v-btn>
        </template>
      </v-card-text>
    </v-card>
  </div>
</template>
