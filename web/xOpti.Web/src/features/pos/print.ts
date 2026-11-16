import { api } from '@/api/client'
import { appErrorFromResponse } from '@/api/problems'

export interface PrintOptions {
  reprint: boolean
  format?: 'receipt' | 'invoice' | 'order'
  terminalCode?: string | null
  reason: string
}

/** Requests the server-rendered PDF; the caller decides whether to display it. */
export async function requestDocumentPrint(txNumber: string, options: PrintOptions): Promise<Blob> {
  const response = await api.request(`/api/v1/sales/documents/${txNumber}/prints`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      reprint: options.reprint,
      format: options.format ?? 'receipt',
      terminalCode: options.terminalCode ?? null,
      reason: options.reason,
    }),
  })
  if (!response.ok) {
    throw await appErrorFromResponse(response, response.headers.get('x-correlation-id'))
  }
  return await response.blob()
}
