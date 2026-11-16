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

export interface TenderLike {
  method: string
  amount: number
}

export function tenderOutcome(tenders: TenderLike[], total: number) {
  let remaining = round2(total)
  let applied = 0
  let change = 0
  for (const tender of tenders) {
    const amount = Number(tender.amount || 0)
    if (amount <= 0 || remaining <= 0) continue
    const isCash = tender.method.toUpperCase() === 'C'
    const take = amount > remaining ? (isCash ? remaining : 0) : amount
    applied += take
    remaining = round2(remaining - take)
    if (isCash && amount > take) change = round2(change + amount - take)
  }
  return { applied: round2(applied), remaining, change }
}
