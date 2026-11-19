<script setup lang="ts">
import { computed } from 'vue'
import { useRoute } from 'vue-router'
import { useThemeStore } from '@/stores/theme'
import ThemeSettings from './ThemeSettings.vue'

const props = defineProps<{
  isMobile: boolean
  isSidebarCollapsed: boolean
  displayName: string
}>()

defineEmits<{
  'toggle-navigation': []
  'sign-out': []
}>()

const route = useRoute()
const themeStore = useThemeStore()

const pageTitle = computed(() => {
  const title = route.meta.title
  return typeof title === 'string' && title.length > 0 ? title : 'xOpti'
})

const navigationLabel = computed(() => {
  if (props.isMobile) {
    return 'Open navigation'
  }
  return props.isSidebarCollapsed ? 'Expand navigation' : 'Collapse navigation'
})

const navigationIcon = computed(() => {
  if (props.isMobile) {
    return 'mdi-menu'
  }
  return props.isSidebarCollapsed ? 'mdi-chevron-double-right' : 'mdi-chevron-double-left'
})
</script>

<template>
  <header class="topbar">
    <div class="topbar-summary">
      <v-btn
        icon
        variant="outlined"
        color="primary"
        class="topbar-nav-btn"
        :aria-label="navigationLabel"
        @click="$emit('toggle-navigation')"
      >
        <v-icon :icon="navigationIcon" />
      </v-btn>

      <div>
        <p class="eyebrow mb-1">xOpti</p>
        <h2 class="text-h5 mb-0">{{ pageTitle }}</h2>
      </div>
    </div>

    <div class="topbar-actions">
      <v-menu :close-on-content-click="false" location="bottom end">
        <template #activator="{ props: menuProps }">
          <v-btn
            v-bind="menuProps"
            icon
            variant="outlined"
            color="primary"
            aria-label="Theme settings"
            data-testid="theme-toggle"
          >
            <v-icon :icon="themeStore.isDark ? 'mdi-weather-night' : 'mdi-white-balance-sunny'" />
          </v-btn>
        </template>

        <v-card width="min(480px, calc(100vw - 32px))" class="pa-4">
          <ThemeSettings />
        </v-card>
      </v-menu>

      <span v-if="!isMobile" class="text-body-2" data-testid="current-user">
        {{ displayName }}
      </span>
      <v-btn variant="outlined" color="primary" data-testid="sign-out" @click="$emit('sign-out')">
        <v-icon start icon="mdi-logout" />
        Sign out
      </v-btn>
    </div>
  </header>
</template>
