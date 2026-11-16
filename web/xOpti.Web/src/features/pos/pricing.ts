export interface TaxRates {
  a: number
  b: number
}

export function round2(value: number): number {
  return Math.round((value + Number.EPSILON) * 100) / 100
}

export function normalizeTaxCode(code: string | null | undefined): string {
  const trimmed = code?.trim() ?? ''
  return ['N', 'B', 'G', 'P', 'g', 'p'].includes(trimmed) ? trimmed : 'B'
}

/** Mirrors TaxCalculator's legacy methods so previews match posted totals. */
export function taxFor(
  amount: number,
  code: string,
  rates: TaxRates,
): { gst: number; pst: number; gross: number } {
  const gstRate = rates.a / 100
  const pstRate = rates.b / 100
  switch (code) {
    case 'B': {
      const gst = round2(amount * gstRate)
      const pst = round2(amount * pstRate)
      return { gst, pst, gross: round2(amount + gst + pst) }
    }
    case 'G': {
      const gst = round2(amount * gstRate)
      return { gst, pst: 0, gross: round2(amount + gst) }
    }
    case 'P': {
      const pst = round2(amount * pstRate)
      return { gst: 0, pst, gross: round2(amount + pst) }
    }
    case 'g': {
      const net = round2(amount / (1 + gstRate))
      return { gst: round2(amount - net), pst: 0, gross: amount }
    }
    case 'p': {
      const gst = round2(amount * gstRate)
      const pst = round2((amount + gst) * pstRate)
      return { gst, pst, gross: round2(amount + gst + pst) }
    }
    default:
      return { gst: 0, pst: 0, gross: amount }
  }
}
