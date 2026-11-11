<script setup lang="ts">
import { ref } from 'vue'
import { useSessionStore, type SignInOutcome } from '@/stores/session'
import { AppError } from '@/api/problems'

const props = withDefaults(defineProps<{ initialUsername?: string; submitLabel?: string }>(), {
  initialUsername: '',
  submitLabel: 'Sign in',
})

const emit = defineEmits<{ 'signed-in': [outcome: SignInOutcome] }>()

const session = useSessionStore()
const username = ref(props.initialUsername)
const password = ref('')
const submitting = ref(false)
const formError = ref<string | null>(null)
const usernameError = ref<string[]>([])
const passwordError = ref<string[]>([])
const resetRequired = ref(false)

/** Uniform copy for any credential failure; never reveals whether the account exists. */
const INVALID_CREDENTIALS = 'The username or password is incorrect.'

async function submit(): Promise<void> {
  if (submitting.value) {
    return
  }
  formError.value = null
  usernameError.value = []
  passwordError.value = []
  submitting.value = true
  try {
    const outcome = await session.signIn(username.value.trim(), password.value)
    password.value = ''
    emit('signed-in', outcome)
  } catch (error) {
    password.value = ''
    if (error instanceof AppError) {
      if (error.kind === 'reset-required') {
        resetRequired.value = true
        formError.value = error.userMessage
      } else if (error.kind === 'unauthenticated') {
        formError.value = INVALID_CREDENTIALS
      } else if (error.kind === 'validation') {
        usernameError.value = [...(error.fieldErrors.username ?? [])]
        passwordError.value = [...(error.fieldErrors.password ?? [])]
        formError.value = error.userMessage
      } else {
        formError.value = error.userMessage
      }
    } else {
      formError.value = 'Something went wrong. Please try again.'
    }
  } finally {
    submitting.value = false
  }
}
</script>

<template>
  <form data-testid="sign-in-form" @submit.prevent="submit">
    <v-alert v-if="formError" type="error" variant="tonal" class="mb-4" data-testid="sign-in-error">
      {{ formError }}
    </v-alert>

    <template v-if="!resetRequired">
      <v-text-field
        v-model="username"
        label="Username"
        autocomplete="username"
        name="username"
        :error-messages="usernameError"
        :disabled="submitting"
        required
      />
      <v-text-field
        v-model="password"
        label="Password"
        type="password"
        autocomplete="current-password"
        name="password"
        :error-messages="passwordError"
        :disabled="submitting"
        required
      />
      <v-btn type="submit" color="primary" block :loading="submitting" data-testid="sign-in-submit">
        {{ submitLabel }}
      </v-btn>
    </template>
  </form>
</template>
