<script setup lang="ts">
import { computed } from 'vue'
import { useRoute } from 'vue-router'
import AppShell from '@/layout/AppShell.vue'
import SessionExpiredDialog from '@/layout/SessionExpiredDialog.vue'

const route = useRoute()
const isPublic = computed(() => route.meta.public === true)
</script>

<template>
  <v-app>
    <template v-if="isPublic">
      <router-view />
    </template>
    <AppShell v-else>
      <router-view />
    </AppShell>
    <SessionExpiredDialog />
  </v-app>
</template>
