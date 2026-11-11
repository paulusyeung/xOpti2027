<script setup lang="ts">
import { computed } from 'vue'
import { useRouter } from 'vue-router'
import { useSessionStore } from '@/stores/session'
import SignInForm from './SignInForm.vue'

const session = useSessionStore()
const router = useRouter()

const open = computed(() => session.status === 'expired')

/**
 * A different user signing in after expiry is sent to home: the previous user's
 * screens and drafts were purged, so the current route must not stay open.
 */
function onSignedIn(outcome: string): void {
  if (outcome === 'switched') {
    void router.push('/')
  }
}
</script>

<template>
  <v-dialog :model-value="open" persistent max-width="420" data-testid="session-expired-dialog">
    <v-card>
      <v-card-title>Your session has expired</v-card-title>
      <v-card-subtitle>Sign in again to continue. Unsaved changes are kept if it is the same user.</v-card-subtitle>
      <v-card-text>
        <SignInForm
          :initial-username="session.lastUsername ?? ''"
          submit-label="Continue"
          @signed-in="onSignedIn"
        />
      </v-card-text>
    </v-card>
  </v-dialog>
</template>
