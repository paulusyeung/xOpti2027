<script setup lang="ts">
import { onBeforeUnmount, reactive, watch } from 'vue'
import type { ReferencePage } from '@/router/referencePages'

interface RecordLike {
  key: string
  name: string
  parent?: string | null
  detail?: string | null
}

const props = withDefaults(defineProps<{
  modelValue: boolean
  page: ReferencePage
  mode: 'view' | 'edit' | 'create' | 'retire'
  record?: RecordLike | null
  saving?: boolean
  fieldErrors?: Record<string, string[]>
  errorMessage?: string | null
}>(), {
  record: null,
  saving: false,
  fieldErrors: () => ({}),
  errorMessage: null,
})

const emit = defineEmits<{
  'update:modelValue': [value: boolean]
  save: [payload: {
    key: string
    name: string
    parent: string | null
    reason: string
    confirmReferenced: boolean
  }]
  edit: []
  retire: []
}>()

let dragCard: HTMLElement | null = null
let dragStartX = 0
let dragStartY = 0
let dragOffsetX = 0
let dragOffsetY = 0

function onDragMove(event: MouseEvent): void {
  dragOffsetX = event.clientX - dragStartX
  dragOffsetY = event.clientY - dragStartY
  if (dragCard) {
    dragCard.style.transform = `translate(${dragOffsetX}px, ${dragOffsetY}px)`
  }
}

function onDragEnd(): void {
  document.removeEventListener('mousemove', onDragMove)
  document.removeEventListener('mouseup', onDragEnd)
}

function onDragStart(event: MouseEvent): void {
  if ((event.target as HTMLElement).closest('button')) return
  dragCard = (event.currentTarget as HTMLElement).closest<HTMLElement>(
    '[data-testid^="reference-form-"], [data-testid="reference-retire-form"]',
  )
  if (!dragCard) return
  dragStartX = event.clientX - dragOffsetX
  dragStartY = event.clientY - dragOffsetY
  document.addEventListener('mousemove', onDragMove)
  document.addEventListener('mouseup', onDragEnd)
}

onBeforeUnmount(() => {
  onDragEnd()
})

watch(() => props.modelValue, (open) => {
  if (!open) return
  dragOffsetX = 0
  dragOffsetY = 0
  if (dragCard) dragCard.style.transform = ''
})

const form = reactive({
  key: '',
  name: '',
  parent: '',
  reason: '',
  confirmReferenced: false,
})

watch(
  () => [props.modelValue, props.mode, props.record] as const,
  ([open, mode, record]) => {
    if (!open) return
    form.key = record?.key ?? ''
    form.name = record?.name ?? ''
    form.parent = record?.parent ?? ''
    form.reason = ''
    form.confirmReferenced = false
    if (mode === 'view') {
      form.confirmReferenced = false
    }
  },
  { immediate: true },
)

function close(): void {
  emit('update:modelValue', false)
}

function submit(): void {
  emit('save', {
    key: form.key,
    name: form.name,
    parent: form.parent || null,
    reason: form.reason,
    confirmReferenced: form.confirmReferenced,
  })
}
</script>

<template>
  <v-dialog
    :model-value="modelValue"
    max-width="min(100%, 680px)"
    scrollable
    @update:model-value="emit('update:modelValue', $event)"
  >
    <v-card
      rounded="xl"
      elevation="6"
      :data-testid="mode === 'retire' ? 'reference-retire-form' : `reference-form-${mode}`"
    >
      <v-card-title class="dialog-drag-handle d-flex align-center ga-2" @mousedown="onDragStart">
        <v-icon :icon="mode === 'create' ? 'mdi-plus-box-outline' : 'mdi-file-document-edit-outline'" />
        <span>
          {{ mode === 'create' ? `New ${page.nameLabel}` : mode === 'retire' ? `Retire ${record?.key}` : `${page.title} · ${record?.key}` }}
        </span>
        <v-spacer />
        <v-btn icon="mdi-close" variant="text" density="compact" aria-label="Close" @click="close" />
      </v-card-title>

      <v-card-text>
        <v-alert v-if="errorMessage" type="error" variant="tonal" class="mb-4" data-testid="reference-dialog-error">
          {{ errorMessage }}
        </v-alert>

        <v-alert
          v-if="Object.keys(fieldErrors).length > 0"
          type="error"
          variant="tonal"
          class="mb-4"
          data-testid="reference-referenced-hint"
        >
          <div v-for="(messages, field) in fieldErrors" :key="field">{{ messages.join(' ') }}</div>
        </v-alert>

        <v-row dense>
          <v-col cols="12" sm="4">
            <v-text-field
              v-model="form.key"
              :label="page.keyLabel"
              :disabled="mode === 'edit' || mode === 'view' || mode === 'retire'"
              data-testid="reference-key"
            />
          </v-col>
          <v-col cols="12" sm="8">
            <v-text-field
              v-model="form.name"
              :label="page.nameLabel"
              :readonly="mode === 'view' || mode === 'retire'"
              data-testid="reference-name"
            />
          </v-col>
          <v-col v-if="page.parentLabel" cols="12">
            <v-text-field
              v-model="form.parent"
              :label="page.parentLabel"
              :readonly="mode === 'view' || mode === 'retire'"
              data-testid="reference-parent"
            />
          </v-col>
          <v-col v-if="page.detailLabel && mode === 'view'" cols="12">
            <v-text-field :label="page.detailLabel" :model-value="record?.detail ?? ''" readonly />
          </v-col>
          <v-col v-if="mode === 'view'" cols="12">
            <v-text-field label="Reference type" :model-value="page.kind" readonly />
          </v-col>
        </v-row>

        <template v-if="mode === 'retire'">
          <v-alert type="warning" variant="tonal" class="mb-4">
            Retiring "{{ record?.name }}" hides it from selection. Existing transactions remain intact.
          </v-alert>
          <v-checkbox
            v-model="form.confirmReferenced"
            label="Also retire when referenced by existing records"
            data-testid="reference-confirm-referenced"
          />
        </template>

        <v-text-field
          v-if="mode !== 'view'"
          v-model="form.reason"
          :label="mode === 'retire' ? 'Retirement reason' : 'Reason (recorded in the audit trail)'"
          data-testid="reference-reason"
          class="mt-2"
        />
      </v-card-text>

      <v-card-actions>
        <v-btn
          v-if="mode === 'edit' || mode === 'view'"
          color="error"
          variant="text"
          class="mr-auto"
          prepend-icon="mdi-delete-outline"
          data-testid="reference-retire"
          @click="emit('retire')"
        >
          Retire
        </v-btn>
        <v-spacer />
        <v-btn v-if="mode === 'view'" variant="text" data-testid="reference-cancel" @click="close">
          Close
        </v-btn>
        <v-btn v-if="mode === 'view'" color="primary" prepend-icon="mdi-pencil" data-testid="reference-edit-record" @click="emit('edit')">
          Edit
        </v-btn>
        <template v-else>
          <v-btn variant="text" data-testid="reference-cancel" @click="close">Cancel</v-btn>
          <v-btn
            color="primary"
            :loading="saving"
            data-testid="reference-submit"
            @click="submit"
          >
            {{ mode === 'retire' ? 'Retire' : 'Save' }}
          </v-btn>
        </template>
      </v-card-actions>
    </v-card>
  </v-dialog>
</template>

<style scoped>
.dialog-drag-handle {
  cursor: move;
  user-select: none;
}
</style>
