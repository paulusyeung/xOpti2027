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
