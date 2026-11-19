<script setup lang="ts">
import { computed, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useDisplay } from 'vuetify'
import { useSessionStore } from '@/stores/session'
import { useShellStore } from '@/stores/shell'
import AppSidebar from './AppSidebar.vue'
import AppTopbar from './AppTopbar.vue'

const route = useRoute()
const router = useRouter()
const session = useSessionStore()
const shell = useShellStore()
const display = useDisplay()

const mobileNavOpen = ref(false)
const desktopSidebarCollapsed = ref(false)

const isMobile = computed(() => display.smAndDown.value)
const displayName = computed(() => session.identity?.displayName || session.identity?.username || '')

watch(isMobile, (mobile) => {
  if (!mobile) {
    mobileNavOpen.value = false
  }
})

// On small screens the drawer overlays the content; dismiss it after a
// navigation so the destination is visible.
watch(() => route.fullPath, () => {
  if (isMobile.value) {
    mobileNavOpen.value = false
  }
})

function handleNavigationToggle(): void {
  if (isMobile.value) {
    mobileNavOpen.value = !mobileNavOpen.value
    return
  }

  desktopSidebarCollapsed.value = !desktopSidebarCollapsed.value
}

async function retryChunk(): Promise<void> {
  const path = shell.chunkErrorPath
  shell.clearChunkError()
  if (path) {
    await router.push(path)
  }
}

async function signOut(): Promise<void> {
  await session.signOut()
  await router.replace({ name: 'sign-in' })
}
</script>

<template>
  <v-layout class="app-shell">
    <AppSidebar
      v-model="mobileNavOpen"
      :is-mobile="isMobile"
      :is-collapsed="desktopSidebarCollapsed"
    />

    <v-main>
      <div class="app-frame">
        <AppTopbar
          :is-mobile="isMobile"
          :is-sidebar-collapsed="desktopSidebarCollapsed"
          :display-name="displayName"
          @toggle-navigation="handleNavigationToggle"
          @sign-out="signOut"
        />

        <v-alert
          v-if="shell.chunkErrorPath"
          type="error"
          variant="tonal"
          class="mb-4"
          data-testid="chunk-error"
        >
          This screen could not be loaded.
          <template #append>
            <v-btn variant="text" data-testid="chunk-retry" @click="retryChunk">Retry</v-btn>
          </template>
        </v-alert>

        <slot />
      </div>
    </v-main>
  </v-layout>
</template>
