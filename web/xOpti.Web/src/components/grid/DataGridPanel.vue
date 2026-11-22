<script setup lang="ts">
import { computed, onBeforeUnmount, onMounted, ref, watch } from 'vue'
import { useGridView, type GridView } from '@/composables/useGridView'

export interface GridColumn {
  key: string
  title: string
  sortable?: boolean
}

const props = withDefaults(defineProps<{
  viewId: string
  columns: readonly GridColumn[]
  items: readonly Record<string, unknown>[]
  search: string
  searchLabel?: string
  emptyText?: string
  itemKey?: string
  loading?: boolean
  hideSearch?: boolean
  linkKey?: string
  rowTestIdPrefix?: string
}>(), {
  searchLabel: 'Search',
  emptyText: 'No records.',
  itemKey: 'key',
  loading: false,
  hideSearch: false,
  linkKey: 'key',
  rowTestIdPrefix: 'grid-row-',
})

const emit = defineEmits<{
  'update:search': [value: string]
  search: [value: string]
  refresh: []
  open: [item: Record<string, unknown>]
}>()

const view: GridView = useGridView(props.viewId, {
  visibleColumns: props.columns.map((column) => column.key),
  sortKey: props.columns[0]?.key ?? null,
  sortDirection: 'asc',
  checkboxMode: false,
  viewMode: 'table',
})

const searchModel = computed({
  get: () => props.search,
  set: (value: string | null) => emit('update:search', value ?? ''),
})

const sortableColumns = computed(() => props.columns.filter((column) => column.sortable !== false))

const headers = computed(() => props.columns
  .filter((column) => view.visibleColumns.value.includes(column.key))
  .map((column) => ({ ...column, sortable: column.sortable !== false })))

const sortBy = computed(() => {
  const key = view.sortKey.value
  return key ? [{ key, order: view.sortDirection.value }] : []
})

function onSortByUpdate(value: unknown): void {
  const first = Array.isArray(value)
    ? value[0] as { key?: string; order?: string | boolean } | undefined
    : undefined
  if (!first?.key || !first.order) {
    view.setSort(null)
    return
  }
  view.setSort(first.key, first.order === 'desc' ? 'desc' : 'asc')
}

const tableHeaders = computed(() => [
  ...(view.checkboxMode.value ? [{ key: '__checkbox', title: '', sortable: false }] : []),
  ...headers.value,
])

const detailColumns = computed(() => props.columns
  .filter((column) => column.key !== 'actions' && view.visibleColumns.value.includes(column.key)))

const CARD_MIN_WIDTH = 220
const CARD_GAP = 12

const cardContainer = ref<HTMLElement | null>(null)
const cardColumns = ref(3)
let cardObserver: ResizeObserver | null = null

function measureCards(): void {
  const width = cardContainer.value?.clientWidth ?? 0
  if (width <= 0) return
  cardColumns.value = Math.max(1, Math.floor((width + CARD_GAP) / (CARD_MIN_WIDTH + CARD_GAP)))
}

onMounted(() => {
  measureCards()
  if (typeof ResizeObserver !== 'undefined' && cardContainer.value) {
    cardObserver = new ResizeObserver(measureCards)
    cardObserver.observe(cardContainer.value)
  }
})

onBeforeUnmount(() => cardObserver?.disconnect())

// Snake layout: alternate row direction so the reading path forms a Z.
const cardRows = computed(() => {
  const rows: Array<Array<Record<string, unknown>>> = []
  const size = cardColumns.value
  for (let index = 0; index < props.items.length; index += size) {
    const chunk = props.items.slice(index, index + size)
    rows.push(index / size % 2 === 1 ? [...chunk].reverse() : chunk)
  }
  return rows
})

const selectedKeys = ref<string[]>([])

watch(() => props.items, () => {
  selectedKeys.value = []
})

function toggleSelected(key: unknown): void {
  const value = String(key)
  selectedKeys.value = selectedKeys.value.includes(value)
    ? selectedKeys.value.filter((item) => item !== value)
    : [...selectedKeys.value, value]
}

function isSelected(key: unknown): boolean {
  return selectedKeys.value.includes(String(key))
}

function rowKey(item: Record<string, unknown>): string {
  return String(item[props.itemKey] ?? '')
}

function cardValue(item: Record<string, unknown>, column: GridColumn): string {
  const value = item[column.key]
  return value === null || value === undefined || value === '' ? '—' : String(value)
}
</script>

<template>
  <section
    class="grid-panel"
    data-testid="grid-panel"
  >
    <v-card rounded="xl" elevation="0" class="panel-card">
      <v-card-text>
        <div class="filter-bar mb-3">
          <v-text-field
            v-if="!hideSearch"
            v-model="searchModel"
            :label="searchLabel"
            prepend-inner-icon="mdi-magnify"
            variant="solo-filled"
            density="comfortable"
            hide-details
            clearable
            data-testid="grid-search"
            @click:clear="emit('search', '')"
            @keyup.enter="emit('search', searchModel)"
          />
          <slot name="filters" />
          <v-btn
            v-if="!hideSearch"
            color="primary"
            prepend-icon="mdi-magnify"
            data-testid="grid-search-button"
            @click="emit('search', searchModel)"
          >
            Search
          </v-btn>
          <slot name="filter-actions" />
        </div>

        <div class="toolbar-bar mb-3">
          <v-menu location="bottom">
            <template #activator="{ props: activatorProps }">
              <v-btn
                v-bind="activatorProps"
                variant="outlined"
                size="small"
                prepend-icon="mdi-view-column"
                data-testid="grid-columns-button"
              >
                Columns
              </v-btn>
            </template>
            <v-list density="compact" class="toolbar-menu-list">
              <v-list-item
                v-for="column in columns"
                :key="column.key"
                :data-testid="`grid-column-${column.key}`"
                @click="view.toggleColumn(column.key)"
              >
                <template #prepend>
                  <v-checkbox-btn :model-value="view.visibleColumns.value.includes(column.key)" />
                </template>
                <v-list-item-title>{{ column.title }}</v-list-item-title>
              </v-list-item>
            </v-list>
          </v-menu>

          <v-menu location="bottom" :close-on-content-click="false">
            <template #activator="{ props: activatorProps }">
              <v-btn
                v-bind="activatorProps"
                variant="outlined"
                size="small"
                prepend-icon="mdi-sort"
                data-testid="grid-sort-button"
              >
                Sorting
              </v-btn>
            </template>
            <v-card min-width="280" class="pa-3">
              <v-select
                :model-value="view.sortKey.value"
                :items="sortableColumns"
                item-title="title"
                item-value="key"
                label="Sort by"
                density="compact"
                variant="outlined"
                hide-details
                data-testid="grid-sort-key"
                @update:model-value="view.setSort($event)"
              />
              <v-btn-toggle
                :model-value="view.sortDirection.value"
                mandatory
                divided
                density="compact"
                class="mt-3"
                data-testid="grid-sort-direction"
                @update:model-value="view.sortDirection.value = $event"
              >
                <v-btn value="asc">Ascending</v-btn>
                <v-btn value="desc">Descending</v-btn>
              </v-btn-toggle>
            </v-card>
          </v-menu>

          <v-btn
            variant="outlined"
            size="small"
            prepend-icon="mdi-checkbox-multiple-marked-outline"
            :color="view.checkboxMode.value ? 'primary' : undefined"
            data-testid="grid-checkbox-button"
            @click="view.checkboxMode.value = !view.checkboxMode.value"
          >
            Checkbox
          </v-btn>

          <v-menu location="bottom">
            <template #activator="{ props: activatorProps }">
              <v-btn
                v-bind="activatorProps"
                variant="outlined"
                size="small"
                prepend-icon="mdi-eye-outline"
                data-testid="grid-views-button"
              >
                Views
              </v-btn>
            </template>
            <v-list density="compact" class="toolbar-menu-list">
              <v-list-item
                prepend-icon="mdi-table"
                :active="view.viewMode.value === 'table'"
                data-testid="grid-view-table"
                @click="view.viewMode.value = 'table'"
              >
                <v-list-item-title>Table view</v-list-item-title>
              </v-list-item>
              <v-list-item
                prepend-icon="mdi-view-grid-outline"
                :active="view.viewMode.value === 'card'"
                data-testid="grid-view-card"
                @click="view.viewMode.value = 'card'"
              >
                <v-list-item-title>Card view</v-list-item-title>
              </v-list-item>
              <v-divider class="my-1" />
              <v-list-item
                prepend-icon="mdi-undo-variant"
                data-testid="grid-reset-button"
                @click="view.reset()"
              >
                <v-list-item-title>Reset view</v-list-item-title>
              </v-list-item>
            </v-list>
          </v-menu>

          <v-divider vertical class="mx-1" />

          <v-btn
            variant="outlined"
            size="small"
            prepend-icon="mdi-refresh"
            data-testid="grid-refresh-button"
            @click="emit('refresh')"
          >
            Refresh
          </v-btn>

          <slot name="toolbar-actions" />

          <v-spacer />
          <span v-if="view.checkboxMode.value" class="text-caption text-medium-emphasis">
            {{ selectedKeys.length }} selected
          </span>
          <span v-else class="text-caption text-medium-emphasis">{{ items.length }} records</span>
        </div>

        <v-data-table
          v-if="view.viewMode.value === 'table'"
          :headers="tableHeaders"
          :items="items"
          :item-value="itemKey"
          :sort-by="sortBy"
          @update:sort-by="onSortByUpdate"
          :loading="loading"
          density="comfortable"
          :items-per-page="-1"
          hide-default-footer
          class="grid-table"
          data-testid="grid-table"
        >
          <template #item="{ item, props }">
            <tr v-bind="props" :data-testid="`${rowTestIdPrefix}${item[itemKey]}`">
              <td v-for="column in tableHeaders" :key="column.key">
                <v-checkbox-btn
                  v-if="column.key === '__checkbox'"
                  :model-value="isSelected(item)"
                  data-testid="grid-row-checkbox"
                  @click.stop="toggleSelected(rowKey(item))"
                />
                <slot
                  v-else-if="$slots[`cell-${column.key}`]"
                  :name="`cell-${column.key}`"
                  :item="item"
                  :value="item[column.key]"
                />
                <v-btn
                  v-else-if="column.key === linkKey"
                  variant="text"
                  color="primary"
                  density="comfortable"
                  class="px-0 text-none text-decoration-underline"
                  :data-testid="`grid-link-${item[itemKey]}`"
                  @click.stop="emit('open', item)"
                >
                  {{ item[column.key] }}
                </v-btn>
                <template v-else>{{ item[column.key] ?? '—' }}</template>
              </td>
            </tr>
          </template>
          <template #no-data>
            <div class="pa-6 text-center text-medium-emphasis">{{ emptyText }}</div>
          </template>
        </v-data-table>

        <div v-else ref="cardContainer" class="grid-cards">
          <div
            v-for="(row, rowIndex) in cardRows"
            :key="rowIndex"
            class="grid-card-row"
            :style="{ gridTemplateColumns: `repeat(${cardColumns}, minmax(220px, 1fr))` }"
          >
            <v-card
              v-for="item in row"
              :key="rowKey(item)"
              variant="outlined"
              rounded="lg"
              class="grid-card pa-4"
              :data-testid="`grid-card-${rowKey(item)}`"
            >
              <div class="d-flex align-start ga-3">
                <v-checkbox-btn
                  v-if="view.checkboxMode.value"
                  :model-value="isSelected(item)"
                  data-testid="grid-card-checkbox"
                  @click="toggleSelected(rowKey(item))"
                />
                <div class="flex-grow-1">
                  <div class="font-weight-semibold">{{ cardValue(item, detailColumns[0] ?? columns[0]!) }}</div>
                  <div class="text-caption text-medium-emphasis">{{ rowKey(item) }}</div>
                </div>
                <v-tooltip location="top" text="Edit">
                  <template #activator="{ props: tooltipProps }">
                    <v-btn
                      v-bind="tooltipProps"
                      class="grid-card-edit"
                      variant="text"
                      color="primary"
                      :data-testid="`grid-card-edit-${rowKey(item)}`"
                      @click.stop="emit('open', item)"
                    >
                      <v-icon icon="mdi-pencil" size="18" />
                    </v-btn>
                  </template>
                </v-tooltip>
              </div>
              <div class="mt-3">
                <div
                  v-for="column in detailColumns"
                  :key="column.key"
                  class="d-flex justify-space-between text-caption"
                >
                  <span class="text-medium-emphasis">{{ column.title }}</span>
                  <span>{{ cardValue(item, column) }}</span>
                </div>
              </div>
            </v-card>
          </div>
          <div v-if="items.length === 0" class="pa-6 text-center text-medium-emphasis">
            {{ emptyText }}
          </div>
        </div>

        <slot name="footer-actions" />
      </v-card-text>
    </v-card>
  </section>
</template>

<style scoped>
.filter-bar,
.toolbar-bar {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 0.75rem;
}

.toolbar-menu-list {
  min-width: 220px;
}

.grid-cards {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.grid-card-row {
  display: grid;
  gap: 12px;
  justify-content: start;
}

.grid-card-edit {
  width: 18px !important;
  min-width: 18px !important;
  height: 18px !important;
  min-height: 18px !important;
  padding: 0 !important;
}
</style>

<style>
.grid-panel {
  --grid-accent: rgb(var(--v-theme-primary));
  --grid-accent-soft: rgba(var(--v-theme-primary), 0.1);
}

.grid-panel .grid-table .v-data-table__th {
  background: var(--grid-accent-soft);
  color: var(--grid-accent);
  font-weight: 700;
}

.grid-panel .grid-table .v-data-table__td:first-child {
  border-inline-start: 3px solid var(--grid-accent);
}

.grid-panel .grid-table tbody tr:hover {
  background: var(--grid-accent-soft);
}

.grid-panel .grid-card:hover {
  background: var(--grid-accent-soft);
}
</style>
