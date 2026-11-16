export interface PosCustomer {
  id: number
  fullName: string | null
  vipCode: string | null
}

export interface PosItem {
  sku: string
  name: string | null
  retailPrice: number | string | null
  taxCode: string | null
  qtyOnHand: number
}

export interface PosDocumentLine {
  rowNo: number
  sku: string
  qty: number
  unitAmount: number | string
  discountAmount: number | string
  unitCost?: number | string | null
  amount: number | string
  taxCode: string | null
}

export interface PosDocumentPayment {
  paymentLineNo: number
  type: string
  amountTender: number | string
  appliedAmount: number | string
  reference: string | null
}

export interface PosDocument {
  txNumber: string
  controlNumber: string
  kind: string
  status: string | null
  statusLabel: string
  customerId: number
  customerName: string | null
  refNumber: string | null
  totalSale: number | string
  taxA: number | string
  taxB: number | string
  grossSale: number | string
  change: number | string
  totalAmount: number | string
  totalQty: number
  paid: number | string
  balance: number | string
  lines: PosDocumentLine[]
  payments: PosDocumentPayment[]
}

export interface RefundableLine {
  rowNo: number
  sku: string
  originalQuantity: number
  refundedQuantity: number
  refundableQuantity: number
  unitAmount: number | string
  discountAmount: number | string
  amount: number | string
  taxA: number | string
  taxB: number | string
  taxCode: string | null
}

export interface RefundableInvoice {
  txNumber: string
  customerId: number
  customerName: string | null
  dateOfEntry: string
  totalSale: number | string
  taxA: number | string
  taxB: number | string
  totalAmount: number | string
  refundedTaxA: number | string
  refundedTaxB: number | string
  lines: RefundableLine[]
  tenders: RefundableTender[]
}

export interface RefundableTender {
  paymentLineNo: number
  type: string
  amount: number | string
  refundedAmount: number | string
  refundableAmount: number | string
  reference: string | null
}

export interface PaymentMethod {
  code: string
  nameShort: string
  nameLong: string
}

export interface CashSession {
  id: number
  branchCode: string
  terminalCode: string
  businessDate: string
  status: string
  openedAt: string
  openedBy: string | null
  openingFloat: number | string
  expectedCash: number | string
  suspendedAt: string | null
  closedAt: string | null
  closedBy: string | null
  countedCash: number | string | null
  variance: number | string | null
  varianceReason: string | null
}

export interface CashCount {
  id: number
  kind: string
  amount: number | string
  countedAt: string
  countedBy: string | null
  variance: number | string | null
  reason: string | null
}

export interface CashMovement {
  id: number
  kind: string
  amount: number | string
  reason: string
  occurredAt: string
  actor: string | null
  destinationReference: string | null
}

export interface CashSessionDetail {
  session: CashSession
  counts: CashCount[]
  movements: CashMovement[]
}

export interface CashJournalDocument {
  txNumber: string
  txType: string
  totalSale: number | string
  taxA: number | string
  taxB: number | string
  totalAmount: number | string
  tenders: Array<{ method: string; applied: number | string }>
}

export interface CashJournal {
  branchCode: string
  businessDate: string
  status: string
  finalizedAt: string | null
  finalizedBy: string | null
  reason: string | null
  totalSales: number | string
  totalRefunds: number | string
  taxA: number | string
  taxB: number | string
  cashTenders: number | string
  cardTenders: number | string
  otherTenders: number | string
  paidIn: number | string
  paidOut: number | string
  pickups: number | string
  deposits: number | string
  expectedCash: number | string
  countedCash: number | string
  variance: number | string
  sessions: CashSession[]
  documents: CashJournalDocument[]
  movements: CashMovement[]
}
