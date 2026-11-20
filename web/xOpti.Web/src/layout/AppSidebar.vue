<script setup lang="ts">
import { computed, ref } from 'vue'
import { useSessionStore } from '@/stores/session'
import { getRuntimeConfig } from '@/runtime/config'
import { buildNavTree } from '@/router/nav'
import MenuItemRenderer from './MenuItemRenderer.vue'
import {
  SIDEBAR_WIDTH_DEFAULT,
  SIDEBAR_WIDTH_MAX,
  SIDEBAR_WIDTH_MIN,
  clampSidebarWidth,
  readSidebarWidth,
  storeSidebarWidth,
} from './sidebarWidth'

const props = defineProps<{
  modelValue: boolean
  isMobile: boolean
  isCollapsed: boolean
}>()

const emit = defineEmits<{
  'update:modelValue': [value: boolean]
}>()

const session = useSessionStore()
const config = getRuntimeConfig()

const items = computed(() => buildNavTree(session, config))
const drawerModel = computed(() => (props.isMobile ? props.modelValue : true))
const showCollapsedTooltips = computed(() => !props.isMobile && props.isCollapsed)

const sidebarWidth = ref(readSidebarWidth())
const resizing = ref(false)

function handleDrawerModelUpdate(value: boolean): void {
  if (!props.isMobile) {
    return
  }
  emit('update:modelValue', value)
}

function startResize(event: PointerEvent): void {
  if (props.isMobile || props.isCollapsed) {
    return
  }
  resizing.value = true
  try {
    (event.currentTarget as HTMLElement).setPointerCapture(event.pointerId)
  } catch {
    // Pointer capture is best-effort; pointermove still works while dragging.
  }
  document.body.style.userSelect = 'none'
  event.preventDefault()
}

function moveResize(event: PointerEvent): void {
  if (!resizing.value) {
    return
  }
  sidebarWidth.value = clampSidebarWidth(event.clientX)
}

function endResize(event: PointerEvent): void {
  if (!resizing.value) {
    return
  }
  resizing.value = false
  try {
    (event.currentTarget as HTMLElement).releasePointerCapture(event.pointerId)
  } catch {
    // Capture may already have been released by the browser.
  }
  document.body.style.userSelect = ''
  storeSidebarWidth(sidebarWidth.value)
}

function resetWidth(): void {
  sidebarWidth.value = SIDEBAR_WIDTH_DEFAULT
  storeSidebarWidth(SIDEBAR_WIDTH_DEFAULT)
}

function nudgeWidth(event: KeyboardEvent): void {
  if (props.isMobile || props.isCollapsed) {
    return
  }
  if (event.key === 'ArrowLeft' || event.key === 'ArrowRight') {
    event.preventDefault()
    const delta = event.key === 'ArrowRight' ? 16 : -16
    sidebarWidth.value = clampSidebarWidth(sidebarWidth.value + delta)
    storeSidebarWidth(sidebarWidth.value)
  }
}
</script>

<template>
  <v-navigation-drawer
    :model-value="drawerModel"
    :permanent="!isMobile"
    :temporary="isMobile"
    :scrim="isMobile"
    :rail="!isMobile && isCollapsed"
    rail-width="82"
    :width="sidebarWidth"
    class="app-sidebar"
    @update:model-value="handleDrawerModelUpdate"
  >
    <div
      v-if="!isMobile && !isCollapsed"
      class="sidebar-resize-handle"
      :class="{ 'sidebar-resize-handle--active': resizing }"
      role="separator"
      aria-label="Resize sidebar"
      aria-orientation="vertical"
      :aria-valuemin="SIDEBAR_WIDTH_MIN"
      :aria-valuemax="SIDEBAR_WIDTH_MAX"
      :aria-valuenow="sidebarWidth"
      tabindex="0"
      @pointerdown="startResize"
      @pointermove="moveResize"
      @pointerup="endResize"
      @pointercancel="endResize"
      @dblclick="resetWidth"
      @keydown="nudgeWidth"
    />

    <div class="brand-lockup">
      <div class="brand-mark">xO</div>
      <div>
        <p class="eyebrow mb-1">Optical retail</p>
        <h1 class="brand-name">xOpti</h1>
      </div>
    </div>

    <MenuItemRenderer
      :items="items"
      :show-tooltips="showCollapsedTooltips"
      :default-open="['Point-of-Sale']"
    />
  </v-navigation-drawer>
</template>
