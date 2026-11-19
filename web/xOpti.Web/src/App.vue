<script setup lang="ts">
import { computed, watch } from 'vue'
import { useRoute } from 'vue-router'
import { useTheme } from 'vuetify'
import AppShell from '@/layout/AppShell.vue'
import SessionExpiredDialog from '@/layout/SessionExpiredDialog.vue'
import { useThemeStore } from '@/stores/theme'

const route = useRoute()
const theme = useTheme()
const themeStore = useThemeStore()

const isPublic = computed(() => route.meta.public === true)

watch(
  () => themeStore.vuetifyTheme,
  (themeName) => {
    theme.change(themeName)
    document.documentElement.dataset.theme = themeStore.mode
    document.documentElement.dataset.scheme = themeStore.scheme
    document.documentElement.style.colorScheme = themeStore.mode
  },
  { immediate: true },
)
</script>

<template>
  <v-app :theme="themeStore.vuetifyTheme">
    <template v-if="isPublic">
      <router-view />
    </template>
    <AppShell v-else>
      <router-view />
    </AppShell>
    <SessionExpiredDialog />
  </v-app>
</template>
