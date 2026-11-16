<script setup lang="ts">
import type { PosDocument } from './types'

defineProps<{ document: PosDocument; title?: string }>()
</script>

<template>
  <v-card variant="outlined" data-testid="pos-document-panel">
    <v-card-title>
      {{ title ?? document.kind }} {{ document.txNumber }}
      <span class="text-caption text-medium-emphasis ml-2">{{ document.statusLabel }}</span>
    </v-card-title>
    <v-card-text>
      <p class="text-body-2" data-testid="pos-document-customer">
        {{ document.customerName ?? 'Customer ' + document.customerId }}
        <span class="text-medium-emphasis">({{ document.kind }})</span>
      </p>
      <v-table density="compact" data-testid="pos-document-lines">
        <thead>
          <tr><th>SKU</th><th>Qty</th><th>Unit</th><th>Discount</th><th>Tax</th><th class="text-right">Amount</th></tr>
        </thead>
        <tbody>
          <tr v-for="line in document.lines" :key="line.rowNo">
            <td>{{ line.sku }}</td>
            <td>{{ line.qty }}</td>
            <td>{{ Number(line.unitAmount).toFixed(2) }}</td>
            <td>{{ Number(line.discountAmount).toFixed(2) }}</td>
            <td>{{ line.taxCode ?? 'N' }}</td>
            <td class="text-right">{{ Number(line.amount).toFixed(2) }}</td>
          </tr>
        </tbody>
      </v-table>
      <div class="d-flex justify-space-between text-body-2 mt-2">
        <span>Subtotal</span><span>{{ Number(document.totalSale).toFixed(2) }}</span>
      </div>
      <div class="d-flex justify-space-between text-body-2">
        <span>GST</span><span>{{ Number(document.taxA).toFixed(2) }}</span>
      </div>
      <div class="d-flex justify-space-between text-body-2">
        <span>PST</span><span>{{ Number(document.taxB).toFixed(2) }}</span>
      </div>
      <div class="d-flex justify-space-between text-body-1 mt-2">
        <strong>Total</strong><strong data-testid="pos-document-total">{{ Number(document.totalAmount).toFixed(2) }}</strong>
      </div>
      <div v-if="Number(document.change) !== 0" class="d-flex justify-space-between text-body-2">
        <span>Change</span><span data-testid="pos-document-change">{{ Number(document.change).toFixed(2) }}</span>
      </div>
      <v-table v-if="document.payments.length" density="compact" class="mt-2" data-testid="pos-document-tenders">
        <thead><tr><th>Method</th><th>Tendered</th><th>Applied</th><th>Reference</th></tr></thead>
        <tbody>
          <tr v-for="payment in document.payments" :key="payment.paymentLineNo + payment.type">
            <td>{{ payment.type }}</td>
            <td>{{ Number(payment.amountTender).toFixed(2) }}</td>
            <td>{{ Number(payment.appliedAmount).toFixed(2) }}</td>
            <td>{{ payment.reference ?? '' }}</td>
          </tr>
        </tbody>
      </v-table>
    </v-card-text>
  </v-card>
</template>
