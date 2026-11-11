/**
 * One Idempotency-Key per user submission. The key is reused for automatic
 * retries of the same submission and replaced only after the submission
 * completes, so a new form submission never replays an earlier key.
 */
export interface SubmissionKey {
  /** The key for the current submission, created on first use. */
  current(): string
  /** Marks the submission as complete; the next call to current() returns a new key. */
  complete(): void
}

export function createSubmissionKey(generate: () => string = () => crypto.randomUUID()): SubmissionKey {
  let key: string | null = null
  return {
    current() {
      key ??= generate()
      return key
    },
    complete() {
      key = null
    },
  }
}
