<script setup lang="ts">
import { computed, ref } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useSessionStore } from '@/stores/session'
import { useShellStore } from '@/stores/shell'
import { getRuntimeConfig } from '@/runtime/config'
import { NAV_ITEMS, isNavItemVisible } from '@/router/nav'

const router = useRouter()
const route = useRoute()
const session = useSessionStore()
const shell = useShellStore()

const drawer = ref(true)
const config = getRuntimeConfig()

const visibleItems = computed(() =>
  NAV_ITEMS.filter((item) => isNavItemVisible(item, session, config)),
)

const displayName = computed(() => session.identity?.displayName || session.identity?.username || '')

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
  <v-app-bar color="primary" density="comfortable">
    <v-app-bar-nav-icon aria-label="Toggle navigation" @click="drawer = !drawer" />
    <v-app-bar-title>xOpti</v-app-bar-title>
    <v-spacer />
    <span class="text-body-2 mr-3" data-testid="current-user">{{ displayName }}</span>
    <v-btn variant="text" data-testid="sign-out" @click="signOut">Sign out</v-btn>
  </v-app-bar>

  <v-navigation-drawer v-model="drawer">
    <v-list nav density="comfortable" data-testid="nav-menu">
      <v-list-item
        v-for="item in visibleItems"
        :key="item.to"
        :to="item.to"
        :prepend-icon="item.icon"
        :title="item.title"
        :active="route.path === item.to"
        :data-testid="`nav-${item.title.toLowerCase()}`"
      />
    </v-list>
  </v-navigation-drawer>

  <v-main>
    <v-container fluid>
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
    </v-container>
  </v-main>
</template>
