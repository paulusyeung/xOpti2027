import { describe, expect, it } from 'vitest'
import { createSubmissionKey } from '@/api/idempotency'

describe('submission idempotency keys', () => {
  it('reuses the same key for retries of one submission', () => {
    let n = 0
    const submission = createSubmissionKey(() => `k${++n}`)

    expect(submission.current()).toBe('k1')
    expect(submission.current()).toBe('k1')
    expect(n).toBe(1)
  })

  it('issues a new key only after the submission completes', () => {
    let n = 0
    const submission = createSubmissionKey(() => `k${++n}`)

    const first = submission.current()
    submission.complete()
    const second = submission.current()

    expect(first).not.toBe(second)
  })

  it('defaults to a UUID', () => {
    const key = createSubmissionKey().current()
    expect(key).toMatch(/^[0-9a-f-]{36}$/)
  })
})
