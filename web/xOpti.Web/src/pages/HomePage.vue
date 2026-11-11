<script setup lang="ts">
import { computed } from 'vue'
import { useSessionStore } from '@/stores/session'

const session = useSessionStore()
const greeting = computed(() => session.identity?.displayName || session.identity?.username || 'there')
</script>

<template>
  <div>
    <h1 class="text-h5 mb-2" data-testid="home-title">Welcome, {{ greeting }}</h1>
    <p class="text-body-1">Choose a screen from the navigation menu.</p>
  </div>
</template>
