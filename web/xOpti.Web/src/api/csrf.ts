import { CORRELATION_HEADER, newCorrelationId } from './correlation'
import { AppError, appErrorFromResponse } from './problems'

export const CSRF_HEADER = 'X-CSRF-TOKEN'
export const CSRF_TOKEN_PATH = '/api/v1/auth/csrf-token'

type FetchLike = (input: RequestInfo | URL, init?: RequestInit) => Promise<Response>

/**
 * In-memory anti-forgery token cache. Concurrent callers share one in-flight
 * fetch so parallel unsafe requests do not overwrite each other's antiforgery
 * cookie. Tokens are never written to browser storage.
 */
export class CsrfTokenStore {
  private token: string | null = null
  private inflight: Promise<string> | null = null

  constructor(private readonly fetchImpl: FetchLike) {}

  /** Returns the cached token, fetching one if needed. */
  get(): Promise<string> {
    if (this.token !== null) {
      return Promise.resolve(this.token)
    }
    this.inflight ??= this.fetchToken()
    return this.inflight
  }

  /** Discards the cached token; the next unsafe request fetches a new one. */
  invalidate(): void {
    this.token = null
  }

  /** Forces a fresh token fetch (used after sign-in/out and on rejection). */
  refresh(): Promise<string> {
    this.invalidate()
    this.inflight = this.fetchToken()
    return this.inflight
  }

  private async fetchToken(): Promise<string> {
    const correlationId = newCorrelationId()
    try {
      const response = await this.fetchImpl(CSRF_TOKEN_PATH, {
        method: 'GET',
        credentials: 'same-origin',
        headers: { [CORRELATION_HEADER]: correlationId },
      })
      if (!response.ok) {
        throw await appErrorFromResponse(response, correlationId)
      }
      const body = (await response.json()) as { token?: unknown }
      if (typeof body.token !== 'string' || body.token.length === 0) {
        throw new AppError({ kind: 'unhandled', status: response.status, correlationId })
      }
      this.token = body.token
      return body.token
    } finally {
      this.inflight = null
    }
  }
}
