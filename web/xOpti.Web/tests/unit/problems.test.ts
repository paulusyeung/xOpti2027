import { describe, expect, it } from 'vitest'
import { AppError, kindForProblemType, toAppError } from '@/api/problems'

describe('ProblemDetails mapping', () => {
  const cases: [string, string][] = [
    ['validation', 'https://errors.xopti/validation'],
    ['authorization', 'https://errors.xopti/authorization'],
    ['unauthenticated', 'https://errors.xopti/unauthenticated'],
    ['session-expired', 'https://errors.xopti/session-expired'],
    ['reset-required', 'https://errors.xopti/reset-required'],
    ['concurrency-conflict', 'https://errors.xopti/concurrency-conflict'],
    ['idempotency-conflict', 'https://errors.xopti/idempotency-conflict'],
    ['idempotency-key-required', 'https://errors.xopti/idempotency-key-required'],
    ['unsupported-request', 'https://errors.xopti/unsupported-request'],
    ['domain-rule', 'https://errors.xopti/domain-rule'],
    ['not-found', 'https://errors.xopti/not-found'],
    ['unhandled', 'https://errors.xopti/unhandled'],
  ]

  it.each(cases)('maps %s by its type URI', (kind, type) => {
    expect(kindForProblemType(type)).toBe(kind)
  })

  it('classifies unknown type URIs as unknown, regardless of title', () => {
    const error = toAppError({ type: 'https://example.test/other', title: 'Unauthorized' }, 401, 'cid-1')
    expect(error.kind).toBe('unknown')
    expect(error.userMessage).toContain('Something went wrong')
    expect(error.userMessage).toContain('Reference: cid-1')
  })

  it('never classifies by title or detail text', () => {
    const error = toAppError({ title: 'Session expired', detail: 'session-expired' }, 401, null)
    expect(error.kind).toBe('unknown')
  })

  it('shows server detail only for domain rules, never for unhandled errors', () => {
    const domain = toAppError({ type: cases[9][1], detail: 'Stock is insufficient.' }, 400, null)
    expect(domain.userMessage).toBe('Stock is insufficient.')

    const unhandled = toAppError({ type: cases[11][1], detail: 'NullReferenceException at Foo' }, 500, 'cid-9')
    expect(unhandled.userMessage).not.toContain('NullReference')
    expect(unhandled.userMessage).toContain('Reference: cid-9')
  })

  it('collects validation field errors', () => {
    const error = toAppError(
      { type: cases[0][1], errors: { username: ['Required.'], password: 'bad' } },
      400,
      null,
    )
    expect(error).toBeInstanceOf(AppError)
    expect(error.fieldErrors).toEqual({ username: ['Required.'] })
  })

  it('prefers the body correlation id over the fallback', () => {
    const error = toAppError({ type: cases[11][1], correlationId: 'body-id' }, 500, 'header-id')
    expect(error.correlationId).toBe('body-id')
  })
})
