/**
 * Error contract shared with xOpti.Api (src/xOpti.Api/Middleware/Problems.cs).
 * Errors are classified by ProblemDetails `type` URI only; titles and details
 * are never used for control flow.
 */

export const PROBLEM_TYPES = [
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
] as const

export type ProblemKind = (typeof PROBLEM_TYPES)[number][0]

/** Type URIs the transport needs to branch on directly. */
export const ProblemTypeUris = {
  authorization: 'https://errors.xopti/authorization',
  sessionExpired: 'https://errors.xopti/session-expired',
} as const

/** Client-side kinds: problem kinds plus transport failure and unrecognised types. */
export type AppErrorKind = ProblemKind | 'network' | 'unknown'

const KIND_BY_TYPE = new Map<string, ProblemKind>(PROBLEM_TYPES.map(([kind, type]) => [type, kind]))

export function problemTypeOf(body: unknown): string | undefined {
  if (body && typeof body === 'object' && 'type' in body && typeof body.type === 'string') {
    return body.type
  }
  return undefined
}

export function kindForProblemType(type: string | undefined): AppErrorKind {
  if (type === undefined) {
    return 'unknown'
  }
  return KIND_BY_TYPE.get(type) ?? 'unknown'
}

/** Kinds whose server detail is safe to show. Other kinds show fixed copy only. */
const SAFE_DETAIL_KINDS: ReadonlySet<AppErrorKind> = new Set<AppErrorKind>(['domain-rule', 'validation'])

const FIXED_MESSAGES: Record<AppErrorKind, string> = {
  validation: 'Please correct the highlighted fields.',
  authorization: 'You do not have permission to do that.',
  unauthenticated: 'Please sign in to continue.',
  'session-expired': 'Your session has expired. Sign in to continue.',
  'reset-required': 'This account must be activated by an administrator before it can be used.',
  'concurrency-conflict': 'This record was changed by someone else. Reload it and try again.',
  'idempotency-conflict': 'This request is already being processed.',
  'idempotency-key-required': 'The request could not be identified. Please try again.',
  'unsupported-request': 'This request is not supported.',
  'domain-rule': 'This action is not allowed.',
  'not-found': 'The requested item was not found.',
  unhandled: 'Something went wrong. Please try again.',
  network: 'The server could not be reached. Check the connection and try again.',
  unknown: 'Something went wrong. Please try again.',
}

/** Kinds that expose a support reference (correlation id) to the user. */
const REFERENCE_KINDS: ReadonlySet<AppErrorKind> = new Set<AppErrorKind>(['unhandled', 'unknown', 'network'])

export class AppError extends Error {
  readonly kind: AppErrorKind
  readonly status: number
  readonly correlationId: string | null
  readonly fieldErrors: Readonly<Record<string, readonly string[]>>
  readonly userMessage: string

  constructor(init: {
    kind: AppErrorKind
    status: number
    correlationId: string | null
    detail?: string
    fieldErrors?: Record<string, readonly string[]>
  }) {
    super(`${init.kind} (${init.status})`)
    this.name = 'AppError'
    this.kind = init.kind
    this.status = init.status
    this.correlationId = init.correlationId
    this.fieldErrors = init.fieldErrors ?? {}

    const base = init.detail && SAFE_DETAIL_KINDS.has(init.kind) ? init.detail : FIXED_MESSAGES[init.kind]
    this.userMessage =
      REFERENCE_KINDS.has(init.kind) && init.correlationId
        ? `${base} (Reference: ${init.correlationId})`
        : base
  }
}

/** Converts a parsed ProblemDetails body (or undefined) into an AppError. */
export function toAppError(
  body: unknown,
  status: number,
  fallbackCorrelationId: string | null,
): AppError {
  const record = body && typeof body === 'object' ? (body as Record<string, unknown>) : {}
  const kind = kindForProblemType(problemTypeOf(record))
  const bodyCorrelation = typeof record.correlationId === 'string' ? record.correlationId : null
  const detail = typeof record.detail === 'string' ? record.detail : undefined

  const fieldErrors: Record<string, string[]> = {}
  if (Array.isArray(record.errors)) {
    // The API emits [{ field, code, message }]; keep field-level errors usable.
    for (const entry of record.errors) {
      if (!entry || typeof entry !== 'object') {
        continue
      }
      const { field, message } = entry as { field?: unknown; message?: unknown }
      if (typeof field === 'string' && typeof message === 'string') {
        ;(fieldErrors[field] ??= []).push(message)
      }
    }
  } else if (record.errors && typeof record.errors === 'object') {
    for (const [field, messages] of Object.entries(record.errors as Record<string, unknown>)) {
      if (Array.isArray(messages)) {
        fieldErrors[field] = messages.filter((m): m is string => typeof m === 'string')
      }
    }
  }

  return new AppError({
    kind,
    status,
    correlationId: bodyCorrelation ?? fallbackCorrelationId,
    detail,
    fieldErrors,
  })
}

/** Reads a non-OK response's body as a problem and returns the AppError. */
export async function appErrorFromResponse(response: Response, correlationId: string | null): Promise<AppError> {
  let body: unknown
  try {
    body = await response.clone().json()
  } catch {
    body = undefined
  }
  return toAppError(body, response.status, response.headers.get('x-correlation-id') ?? correlationId)
}
