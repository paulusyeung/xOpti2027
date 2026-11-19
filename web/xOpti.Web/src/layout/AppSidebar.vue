<script setup lang="ts">
import { computed } from 'vue'
import { useSessionStore } from '@/stores/session'
import { getRuntimeConfig } from '@/runtime/config'
import { buildNavTree } from '@/router/nav'
import MenuItemRenderer from './MenuItemRenderer.vue'

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

function handleDrawerModelUpdate(value: boolean): void {
  if (!props.isMobile) {
    return
  }
  emit('update:modelValue', value)
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
    width="252"
    class="app-sidebar"
    @update:model-value="handleDrawerModelUpdate"
  >
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
      :default-open="['Point-of-Service']"
    />
  </v-navigation-drawer>
</template>
