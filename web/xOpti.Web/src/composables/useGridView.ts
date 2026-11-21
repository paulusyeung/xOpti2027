import { computed, ref, watch } from 'vue'

export type GridSortDirection = 'asc' | 'desc'
export type GridViewMode = 'table' | 'card'

export interface GridViewSettings {
  visibleColumns: string[]
  sortKey: string | null
  sortDirection: GridSortDirection
  checkboxMode: boolean
  viewMode: GridViewMode
}

const STORAGE_PREFIX = 'xopti.grid.view.'

const DIRECTIONS: readonly GridSortDirection[] = ['asc', 'desc']
const VIEW_MODES: readonly GridViewMode[] = ['table', 'card']

function isStringArray(value: unknown): value is string[] {
  return Array.isArray(value) && value.every((item) => typeof item === 'string')
}

export function useGridView(viewId: string, defaults: GridViewSettings) {
  const storageKey = `${STORAGE_PREFIX}${viewId}`

  function read(): GridViewSettings {
    try {
      const raw = localStorage.getItem(storageKey)
      if (raw) {
        const parsed = JSON.parse(raw) as Partial<GridViewSettings>
        return {
          visibleColumns: isStringArray(parsed.visibleColumns) && parsed.visibleColumns.length > 0
            ? parsed.visibleColumns
            : [...defaults.visibleColumns],
          sortKey: typeof parsed.sortKey === 'string' ? parsed.sortKey : defaults.sortKey,
          sortDirection: DIRECTIONS.includes(parsed.sortDirection as GridSortDirection)
            ? parsed.sortDirection as GridSortDirection
            : defaults.sortDirection,
          checkboxMode: typeof parsed.checkboxMode === 'boolean' ? parsed.checkboxMode : defaults.checkboxMode,
          viewMode: VIEW_MODES.includes(parsed.viewMode as GridViewMode)
            ? parsed.viewMode as GridViewMode
            : defaults.viewMode,
        }
      }
    } catch {
      // Fall through to defaults when storage is unavailable or malformed.
    }
    return { ...defaults, visibleColumns: [...defaults.visibleColumns] }
  }

  const initial = read()
  const visibleColumns = ref<string[]>(initial.visibleColumns)
  const sortKey = ref<string | null>(initial.sortKey)
  const sortDirection = ref<GridSortDirection>(initial.sortDirection)
  const checkboxMode = ref<boolean>(initial.checkboxMode)
  const viewMode = ref<GridViewMode>(initial.viewMode)

  const settings = computed<GridViewSettings>(() => ({
    visibleColumns: [...visibleColumns.value],
    sortKey: sortKey.value,
    sortDirection: sortDirection.value,
    checkboxMode: checkboxMode.value,
    viewMode: viewMode.value,
  }))

  watch(settings, (value) => {
    try {
      localStorage.setItem(storageKey, JSON.stringify(value))
    } catch {
      // Customisation still applies for this session when storage is blocked.
    }
  }, { deep: true })

  function toggleColumn(key: string): void {
    const index = visibleColumns.value.indexOf(key)
    if (index >= 0) {
      visibleColumns.value = visibleColumns.value.filter((column) => column !== key)
    } else {
      visibleColumns.value = [...visibleColumns.value, key]
    }
  }

  function setSort(key: string | null, direction?: GridSortDirection): void {
    sortKey.value = key
    if (direction) {
      sortDirection.value = direction
    }
  }

  function reset(): void {
    visibleColumns.value = [...defaults.visibleColumns]
    sortKey.value = defaults.sortKey
    sortDirection.value = defaults.sortDirection
    checkboxMode.value = defaults.checkboxMode
    viewMode.value = defaults.viewMode
  }

  return {
    visibleColumns,
    sortKey,
    sortDirection,
    checkboxMode,
    viewMode,
    settings,
    toggleColumn,
    setSort,
    reset,
  }
}

export type GridView = ReturnType<typeof useGridView>
