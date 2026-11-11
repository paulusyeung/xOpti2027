import { computed, ref } from 'vue'
import { defineStore } from 'pinia'
import { api, unwrap } from '@/api/client'
import { AppError } from '@/api/problems'
import { purgeDrafts } from './drafts'

/**
 * unknown       - startup, identity not yet read
 * anonymous     - no session (signed out, never signed in, or unauthenticated)
 * authenticated - session established; identity and permissions loaded
 * expired       - session ended while in use; in-memory form state is kept until
 *                 the same user re-authenticates (then resumed) or a different
 *                 user signs in (then purged)
 */
export type SessionStatus = 'unknown' | 'anonymous' | 'authenticated' | 'expired'

export interface SessionIdentity {
  username: string
  displayName: string | null
  permissions: string[]
}

/** How a successful sign-in relates to the previous session. */
export type SignInOutcome = 'new' | 'resumed' | 'switched'

export const useSessionStore = defineStore('session', () => {
  const status = ref<SessionStatus>('unknown')
  const identity = ref<SessionIdentity | null>(null)
  /** Username of the last authenticated user; kept across expiry for the resume check. */
  const lastUsername = ref<string | null>(null)

  const permissionSet = computed(() => new Set(identity.value?.permissions ?? []))
  const isShellVisible = computed(() => status.value === 'authenticated' || status.value === 'expired')

  function hasPermission(permission: string): boolean {
    return permissionSet.value.has(permission)
  }

  async function loadIdentity(): Promise<SessionIdentity> {
    const me = await unwrap(await api.client.GET('/api/v1/auth/me'))
    return { username: me.username, displayName: me.displayName ?? null, permissions: [...me.permissions] }
  }

  /** Reads the current session on application start. Never throws. */
  async function restore(): Promise<void> {
    try {
      identity.value = await loadIdentity()
      lastUsername.value = identity.value.username
      status.value = 'authenticated'
    } catch (error) {
      identity.value = null
      status.value = 'anonymous'
      if (!(error instanceof AppError) || error.kind !== 'unauthenticated') {
        // Transport or server failure: stay anonymous; the sign-in screen shows the reason on submit.
        console.warn('Session restore failed', error)
      }
    }
  }

  async function signIn(username: string, password: string): Promise<SignInOutcome> {
    const wasExpired = status.value === 'expired'
    await unwrap(await api.client.POST('/api/v1/auth/sign-in', { body: { username, password } }))

    // The antiforgery token is bound to the identity; fetch one for the new session.
    await api.csrf.refresh()
    const next = await loadIdentity()

    const previous = lastUsername.value
    const sameUser = previous !== null && previous.toLowerCase() === next.username.toLowerCase()

    let outcome: SignInOutcome = 'new'
    if (wasExpired) {
      if (sameUser) {
        outcome = 'resumed'
      } else {
        purgeDrafts()
        outcome = 'switched'
      }
    }

    identity.value = next
    lastUsername.value = next.username
    status.value = 'authenticated'
    return outcome
  }

  /** Called when the API reports the session has expired during use. */
  function expire(): void {
    if (status.value !== 'authenticated') {
      return
    }
    identity.value = null
    status.value = 'expired'
  }

  /** Ends the server session and clears all client-side identity state. */
  async function signOut(): Promise<void> {
    try {
      await api.client.POST('/api/v1/auth/sign-out')
    } finally {
      identity.value = null
      lastUsername.value = null
      status.value = 'anonymous'
      api.csrf.invalidate()
      purgeDrafts()
    }
  }

  return {
    status,
    identity,
    lastUsername,
    isShellVisible,
    hasPermission,
    restore,
    signIn,
    expire,
    signOut,
  }
})
