/**
 * Registry of in-progress form state. Forms register a reset callback; the
 * session layer calls purgeDrafts() when a different user signs in or when the
 * user signs out, so one user's unsaved data is never shown to or submitted by
 * another.
 */
const resets = new Set<() => void>()

export function registerDraft(reset: () => void): () => void {
  resets.add(reset)
  return () => {
    resets.delete(reset)
  }
}

export function purgeDrafts(): void {
  for (const reset of [...resets]) {
    reset()
  }
}

export function draftCount(): number {
  return resets.size
}
