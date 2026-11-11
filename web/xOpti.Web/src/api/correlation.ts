export const CORRELATION_HEADER = 'x-correlation-id'

export function newCorrelationId(): string {
  return crypto.randomUUID()
}
