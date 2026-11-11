<script setup lang="ts">
import { useRoute, useRouter } from 'vue-router'
import SignInForm from '@/layout/SignInForm.vue'
import { safeRedirect } from '@/router'
import type { SignInOutcome } from '@/stores/session'

const route = useRoute()
const router = useRouter()

function onSignedIn(_outcome: SignInOutcome): void {
  void router.replace(safeRedirect(route.query.redirect) ?? '/')
}
</script>

<template>
  <v-container class="fill-height" max-width="420">
    <v-card class="w-100 pa-6" data-testid="sign-in-page">
      <v-card-title class="text-h5 mb-2">Sign in to xOpti</v-card-title>
      <v-card-text>
        <SignInForm @signed-in="onSignedIn" />
      </v-card-text>
    </v-card>
  </v-container>
</template>
