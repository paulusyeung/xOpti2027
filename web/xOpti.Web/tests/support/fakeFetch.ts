import { vi } from 'vitest'

export interface RecordedCall {
  method: string
  path: string
  headers: Headers
  body: string | undefined
}

export type Responder = (call: RecordedCall) => Response | Promise<Response>

export function json(status: number, body?: unknown, headers: Record<string, string> = {}): Response {
  return new Response(body === undefined ? null : JSON.stringify(body), {
    status,
    headers: body === undefined ? headers : { 'content-type': 'application/json', ...headers },
  })
}

export function problem(status: number, type: string, extra: Record<string, unknown> = {}): Response {
  return new Response(JSON.stringify({ type, status, title: 'x', ...extra }), {
    status,
    headers: { 'content-type': 'application/problem+json' },
  })
}

/** Records every request and answers from `responder`. Accepts Request objects or URL strings. */
export function fakeFetch(responder: Responder) {
  const calls: RecordedCall[] = []
  const fn = vi.fn(async (input: RequestInfo | URL, init?: RequestInit): Promise<Response> => {
    let call: RecordedCall
    if (input instanceof Request) {
      call = {
        method: input.method,
        path: new URL(input.url).pathname,
        headers: input.headers,
        body: input.method === 'GET' || input.method === 'HEAD' ? undefined : await input.text(),
      }
    } else {
      const url = typeof input === 'string' ? input : input.toString()
      call = {
        method: (init?.method ?? 'GET').toUpperCase(),
        path: new URL(url, 'http://localhost').pathname,
        headers: new Headers(init?.headers),
        body: typeof init?.body === 'string' ? init.body : undefined,
      }
    }
    calls.push(call)
    return responder(call)
  })
  return { fn, calls }
}
