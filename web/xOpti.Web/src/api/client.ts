import createClient from 'openapi-fetch'
import type { paths } from '@contract/xopti-client'
import { CORRELATION_HEADER, newCorrelationId } from './correlation'
import { CSRF_HEADER, CsrfTokenStore } from './csrf'
import { AppError, problemTypeOf, ProblemTypeUris, toAppError } from './problems'

type FetchLike = (input: RequestInfo | URL, init?: RequestInit) => Promise<Response>

const UNSAFE_METHODS: ReadonlySet<string> = new Set(['POST', 'PUT', 'PATCH', 'DELETE'])

export interface ApiOptions {
  fetchImpl?: FetchLike
  origin?: string
}

export interface Api {
  /** Typed client generated from the committed contract. */
  readonly client: ReturnType<typeof createClient<paths>>
  readonly csrf: CsrfTokenStore
  /** Raw request through the same middleware (for endpoints outside the contract). */
  request(path: string, init?: RequestInit): Promise<Response>
  /** Registers the handler invoked when the server reports an expired session. */
  setSessionExpiredHandler(handler: (() => void) | null): void
}

/**
 * Builds the API access layer. Every request carries an x-correlation-id; unsafe
 * verbs carry the anti-forgery token; a single CSRF/authorization rejection on an
 * unsafe verb is retried once with a fresh token (the handler has not executed).
 */
export function createApi(options: ApiOptions = {}): Api {
  const fetchImpl: FetchLike = options.fetchImpl ?? ((input, init) => globalThis.fetch(input, init))
  const origin = options.origin ?? globalThis.location?.origin ?? 'http://localhost'
  const csrf = new CsrfTokenStore(fetchImpl)
  let sessionExpiredHandler: (() => void) | null = null

  const transport = async (request: Request): Promise<Response> => {
    const correlationId = request.headers.get(CORRELATION_HEADER) ?? newCorrelationId()
    const unsafe = UNSAFE_METHODS.has(request.method)
    const body = request.method === 'GET' || request.method === 'HEAD' ? undefined : await request.arrayBuffer()

    const send = async (token: string | null): Promise<Response> => {
      const headers = new Headers(request.headers)
      headers.set(CORRELATION_HEADER, correlationId)
      if (token !== null) {
        headers.set(CSRF_HEADER, token)
      }
      try {
        return await fetchImpl(
          new Request(request.url, {
            method: request.method,
            headers,
            body,
            credentials: 'same-origin',
          }),
        )
      } catch {
        throw new AppError({ kind: 'network', status: 0, correlationId })
      }
    }

    let response = await send(unsafe ? await csrf.get() : null)

    if (unsafe && response.status === 403 && (await typeOf(response)) === ProblemTypeUris.authorization) {
      response = await send(await csrf.refresh())
    }

    if (response.status === 401 && (await typeOf(response)) === ProblemTypeUris.sessionExpired) {
      sessionExpiredHandler?.()
    }

    return response
  }

  const client = createClient<paths>({ baseUrl: origin, fetch: transport })

  return {
    client,
    csrf,
    async request(path, init) {
      const url = new URL(path, origin)
      return transport(new Request(url, init))
    },
    setSessionExpiredHandler(handler) {
      sessionExpiredHandler = handler
    },
  }
}

/**
 * Converts an openapi-fetch result into its data, throwing a typed AppError for
 * any ProblemDetails response.
 */
export async function unwrap<T>(result: { data?: T; error?: unknown; response: Response }): Promise<T> {
  if (result.error !== undefined) {
    // openapi-fetch parses the problem body into `error`, consuming the
    // response stream; re-reading the clone would fail and lose the kind.
    throw toAppError(
      result.error,
      result.response.status,
      result.response.headers.get(CORRELATION_HEADER),
    )
  }
  return result.data as T
}

async function typeOf(response: Response): Promise<string | undefined> {
  try {
    return problemTypeOf(await response.clone().json())
  } catch {
    return undefined
  }
}

/** The shared application instance. Wired to the session store in main.ts. */
export const api = createApi()
