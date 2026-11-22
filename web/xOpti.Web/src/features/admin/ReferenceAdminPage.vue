<script setup lang="ts">
import { computed, onMounted, reactive, ref, watch } from 'vue'
import { useRoute } from 'vue-router'
import { api, unwrap } from '@/api/client'
import { AppError } from '@/api/problems'
import DataGridPanel, { type GridColumn } from '@/components/grid/DataGridPanel.vue'
import { DEFAULT_REFERENCE_PAGE, referencePageByPath } from '@/router/referencePages'
import ReferenceRecordDialog from './ReferenceRecordDialog.vue'

interface ReferenceItem {
  kind: string
  key: string
  name: string
  parent?: string | null
  detail?: string | null
}

interface DialogPayload {
  key: string
  name: string
  parent: string | null
  reason: string
  confirmReferenced: boolean
}

const route = useRoute()

const page = computed(() => referencePageByPath(route.path) ?? DEFAULT_REFERENCE_PAGE)
const kind = computed(() => page.value.kind)

const columns = computed<GridColumn[]>(() => [
  { key: 'key', title: page.value.keyLabel, sortable: true },
  { key: 'name', title: page.value.nameLabel, sortable: true },
  ...(page.value.parentLabel ? [{ key: 'parent', title: page.value.parentLabel, sortable: true }] : []),
  ...(page.value.detailLabel ? [{ key: 'detail', title: page.value.detailLabel, sortable: true }] : []),
])

const search = ref('')
const loading = ref(true)
const saving = ref(false)
const forbidden = ref(false)
const errorMessage = ref<string | null>(null)
const notice = ref<string | null>(null)
const fieldErrors = ref<Record<string, string[]>>({})
const items = ref<ReferenceItem[]>([])
const nextCursor = ref<string | null>(null)

const dialogOpen = ref(false)
const dialogMode = ref<'view' | 'edit' | 'create' | 'retire'>('view')
const dialogRecord = ref<ReferenceItem | null>(null)

const form = reactive({
  summaryFlag: false,
  costingMethod: '1',
  inventoryMethod: '1',
  taxMethod: '1',
  paymentNameShort: '',
  exchangeRate: 1,
})

const isCategory = computed(() => kind.value === 'Category')
const isPayment = computed(() => kind.value === 'PaymentMethod')

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

function clearMessages(): void {
  fieldErrors.value = {}
  errorMessage.value = null
}

async function load(reset = true): Promise<void> {
  loading.value = true
  errorMessage.value = null
  try {
    const result = await unwrap(
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
    items.value = reset
      ? (result.items as ReferenceItem[])
      : [...items.value, ...(result.items as ReferenceItem[])]
    nextCursor.value = result.nextCursor ?? null
  } catch (error) {
    handleError(error)
  } finally {
    loading.value = false
  }
}

function openCreate(): void {
  clearMessages()
  dialogMode.value = 'create'
  dialogRecord.value = null
  dialogOpen.value = true
}

function openEdit(item: ReferenceItem): void {
  clearMessages()
  dialogMode.value = 'edit'
  dialogRecord.value = item
  dialogOpen.value = true
}

function openRetire(item: ReferenceItem): void {
  clearMessages()
  dialogMode.value = 'retire'
  dialogRecord.value = item
  dialogOpen.value = true
}

function mutationBody(payload: DialogPayload) {
  return {
    key: payload.key,
    name: payload.name,
    parent: payload.parent,
    summaryFlag: form.summaryFlag || null,
    costingMethod: isCategory.value ? form.costingMethod : null,
    inventoryMethod: isCategory.value ? form.inventoryMethod : null,
    taxMethod: isCategory.value ? form.taxMethod : null,
    paymentNameShort: isPayment.value ? form.paymentNameShort : null,
    exchangeRate: isPayment.value ? form.exchangeRate : null,
    reason: payload.reason,
  }
}

async function submit(payload: DialogPayload): Promise<void> {
  saving.value = true
  clearMessages()
  try {
    if (dialogMode.value === 'create') {
      const created = await unwrap(
        await api.client.POST('/api/v1/admin/reference/{kind}', {
          params: { path: { kind: kind.value } },
          body: mutationBody(payload),
        }),
      )
      notice.value = `${page.value.nameLabel} '${created.key}' created.`
    } else if (dialogMode.value === 'edit') {
      await unwrap(
        await api.client.PUT('/api/v1/admin/reference/{kind}', {
          params: { path: { kind: kind.value } },
          body: mutationBody(payload),
        }),
      )
      notice.value = `${page.value.nameLabel} '${payload.key}' updated.`
    } else if (dialogMode.value === 'retire' && dialogRecord.value) {
      await unwrap(
        await api.client.POST('/api/v1/admin/reference/{kind}/retire', {
          params: { path: { kind: kind.value } },
          body: {
            key: dialogRecord.value.key,
            reason: payload.reason,
            confirmReferenced: payload.confirmReferenced,
          },
        }),
      )
      notice.value = `${page.value.nameLabel} '${dialogRecord.value.key}' retired.`
    }

    dialogOpen.value = false
    await load()
  } catch (error) {
    handleError(error)
  } finally {
    saving.value = false
  }
}

watch(() => route.fullPath, () => {
  dialogOpen.value = false
  dialogRecord.value = null
  items.value = []
  nextCursor.value = null
  notice.value = null
  clearMessages()
  void load()
})

onMounted(() => load())
</script>

<template>
  <div data-testid="reference-admin-page">
    <v-alert v-if="forbidden" type="error" variant="tonal" class="mb-4" data-testid="reference-forbidden">
      You do not have permission to administer reference data.
    </v-alert>
    <v-alert v-if="notice" type="success" variant="tonal" class="mb-4" data-testid="reference-notice">
      {{ notice }}
    </v-alert>
    <v-alert v-else-if="errorMessage && !dialogOpen" type="error" variant="tonal" class="mb-4" data-testid="reference-error">
      {{ errorMessage }}
    </v-alert>

    <DataGridPanel
      v-if="!forbidden"
      :key="page.id"
      :view-id="page.id"
      :columns="columns"
      :items="items"
      v-model:search="search"
      :search-label="`Search ${page.nameLabel.toLowerCase()}`"
      :loading="loading"
      :empty-text="`No ${page.title.toLowerCase()} records.`"
      data-testid="reference-grid"
      @search="load()"
      @refresh="load()"
      @open="openEdit($event as unknown as ReferenceItem)"
    >
      <template #toolbar-actions>
        <v-btn
          color="primary"
          size="small"
          prepend-icon="mdi-plus"
          data-testid="reference-create-open"
          :disabled="forbidden"
          @click="openCreate"
        >
          New {{ page.nameLabel }}
        </v-btn>
      </template>
    </DataGridPanel>

    <ReferenceRecordDialog
      v-model="dialogOpen"
      :page="page"
      :mode="dialogMode"
      :record="dialogRecord"
      :saving="saving"
      :field-errors="fieldErrors"
      :error-message="errorMessage"
      @save="submit"
      @edit="dialogMode = 'edit'"
      @retire="openRetire(dialogRecord!)"
    />
  </div>
</template>
