<script setup lang="ts">
import { computed, reactive, ref } from 'vue'
import { api, unwrap } from '@/api/client'
import { AppError } from '@/api/problems'

interface EyeValues {
  sphere: number | null; cylinder: number | null; axis: number | null
  pd: number | null; add: number | null; prism: number | null
  base: number | null; segHeight: number | null; oc: number | null; vd: number | null
}
interface Frame {
  lineNumber: number; supply: boolean; enclosed: boolean; follow: boolean; lenses: boolean
  mode: string; color: string; eyeSize: string; bridge: number; temple: number
  r1: string; r2: string; r3: string; a: string; b: string; specialInstruction: string
}
interface Lens {
  lineNumber: number; prescriptionVersionId: number | null
  right: EyeValues; left: EyeValues
  rightStyle: string; leftStyle: string; type: string; hardening: string
  material: string; coating: string; tint: string; others: string
  hardCoat: boolean; arCoat: boolean; uv: boolean
}
interface Contact {
  lineNumber: number; prescriptionVersionId: number | null
  right: EyeValues; left: EyeValues
  history: string; medical: string; allergy: string; reason: string
  evaluation: string; test: string; specialInstruction: string
}
interface OpticalEvent {
  id: number; status: string; occurredAt: string; actor: string | null
  reference: string | null; notes: string | null
}
interface OpticalOrder {
  txNumber: string; customerId: number; customerName: string | null
  orderStatus: string | null; status: string; events: OpticalEvent[]
}

const txNumber = ref('')
const order = ref<OpticalOrder | null>(null)
const busy = ref(false)
const error = ref<string | null>(null)
const notice = ref<string | null>(null)
const eye = (): EyeValues => ({ sphere: 0, cylinder: 0, axis: 0, pd: null, add: null,
  prism: null, base: null, segHeight: null, oc: null, vd: null })
const frame = reactive<Frame>({
  lineNumber: 1, supply: true, enclosed: false, follow: false, lenses: true,
  mode: 'Full rim', color: '', eyeSize: '52', bridge: 18, temple: 140,
  r1: '', r2: '', r3: '', a: '', b: '', specialInstruction: '',
})
const lens = reactive<Lens>({
  lineNumber: 1, prescriptionVersionId: null, right: eye(), left: eye(),
  rightStyle: 'SV', leftStyle: 'SV', type: 'Single vision', hardening: 'Standard',
  material: 'CR', coating: 'AR', tint: 'Clear', others: '',
  hardCoat: true, arCoat: true, uv: true,
})
const contact = reactive<Contact>({
  lineNumber: 1, prescriptionVersionId: null, right: eye(), left: eye(),
  history: '', medical: '', allergy: '', reason: '', evaluation: '', test: '',
  specialInstruction: '',
})
const includeFrame = ref(true)
const includeLens = ref(true)
const includeContact = ref(false)
const reason = ref('optical order details')
const statusReference = ref('')
const statusNotes = ref('')

const statusLabel = computed(() => order.value?.status ?? '—')

function handleError(caught: unknown): void {
  if (caught instanceof AppError) {
    if (caught.kind === 'validation') {
      const fields = caught.fieldErrors as Record<string, readonly string[]>
      error.value = Object.values(fields)[0]?.[0] ?? caught.userMessage
    } else error.value = caught.userMessage
  } else error.value = 'The request failed.'
}

function payloadEye(values: EyeValues) {
  return {
    sphere: values.sphere === null ? null : Number(values.sphere),
    cylinder: values.cylinder === null ? null : Number(values.cylinder),
    axis: values.axis === null ? null : Number(values.axis),
    pd: values.pd === null ? null : Number(values.pd),
    add: values.add === null ? null : Number(values.add),
    prism: values.prism === null ? null : Number(values.prism),
    base: values.base === null ? null : Number(values.base),
    segHeight: values.segHeight === null ? null : Number(values.segHeight),
    oc: values.oc === null ? null : Number(values.oc),
    vd: values.vd === null ? null : Number(values.vd),
  }
}

async function load(): Promise<void> {
  if (!txNumber.value.trim()) return
  busy.value = true
  error.value = null
  try {
    order.value = await unwrap(await api.client.GET('/api/v1/sales/orders/{txNumber}/optical', {
      params: { path: { txNumber: txNumber.value.trim() } },
    })) as unknown as OpticalOrder
  } catch (caught) { handleError(caught) } finally { busy.value = false }
}

async function save(): Promise<void> {
  if (!txNumber.value.trim()) return
  busy.value = true
  error.value = null
  try {
    order.value = await unwrap(await api.client.PUT('/api/v1/sales/orders/{txNumber}/optical', {
      params: { path: { txNumber: txNumber.value.trim() } },
      body: {
        frames: includeFrame.value ? [{ ...frame, bridge: Number(frame.bridge), temple: Number(frame.temple) }] : [],
        lenses: includeLens.value ? [{
          lineNumber: Number(lens.lineNumber),
          prescriptionVersionId: lens.prescriptionVersionId,
          right: payloadEye(lens.right), left: payloadEye(lens.left),
          rightStyle: lens.rightStyle, leftStyle: lens.leftStyle, type: lens.type,
          hardening: lens.hardening, material: lens.material, coating: lens.coating,
          tint: lens.tint, others: lens.others, hardCoat: lens.hardCoat,
          arCoat: lens.arCoat, uv: lens.uv,
        }] : [],
        contacts: includeContact.value ? [{
          lineNumber: Number(contact.lineNumber),
          prescriptionVersionId: contact.prescriptionVersionId,
          right: payloadEye(contact.right), left: payloadEye(contact.left),
          history: contact.history, medical: contact.medical, allergy: contact.allergy,
          reason: contact.reason, evaluation: contact.evaluation, test: contact.test,
          specialInstruction: contact.specialInstruction,
        }] : [],
        reason: reason.value,
      },
    })) as unknown as OpticalOrder
    notice.value = 'Optical details saved for the sale order.'
  } catch (caught) { handleError(caught) } finally { busy.value = false }
}

async function advance(status: string): Promise<void> {
  if (!txNumber.value.trim()) return
  busy.value = true
  error.value = null
  try {
    order.value = await unwrap(await api.client.POST('/api/v1/sales/orders/{txNumber}/optical/status', {
      params: { path: { txNumber: txNumber.value.trim() } },
      body: {
        status, reference: statusReference.value || null,
        notes: statusNotes.value || null, reason: 'fulfillment update',
      },
    })) as unknown as OpticalOrder
    notice.value = `Order moved to ${status}.`
  } catch (caught) { handleError(caught) } finally { busy.value = false }
}
</script>

<template>
  <div data-testid="optical-page">
    <h1 class="text-h5 mb-4">Optical orders</h1>
    <v-alert v-if="error" type="error" variant="tonal" class="mb-4" data-testid="optical-error">{{ error }}</v-alert>
    <v-alert v-if="notice" type="success" variant="tonal" class="mb-4" data-testid="optical-notice">{{ notice }}</v-alert>

    <v-card variant="outlined" class="mb-4">
      <v-card-text>
        <div class="d-flex ga-2">
          <v-text-field v-model="txNumber" label="Sale order number" density="compact" hide-details
            data-testid="optical-order" @keyup.enter="load" />
          <v-btn color="primary" :loading="busy" data-testid="optical-load" @click="load">Load</v-btn>
        </div>
        <p v-if="order" class="text-body-2 mt-3" data-testid="optical-status">
          {{ order.txNumber }} · customer {{ order.customerName ?? order.customerId }} · status {{ statusLabel }}
        </p>
      </v-card-text>
    </v-card>

    <v-row>
      <v-col cols="12" md="6">
        <v-card variant="outlined">
          <v-card-title>
            <v-checkbox v-model="includeFrame" label="Frame" density="compact" hide-details
              data-testid="optical-include-frame" />
          </v-card-title>
          <v-card-text>
            <div class="d-flex ga-2">
              <v-text-field v-model="frame.mode" label="Mode" density="compact" data-testid="optical-frame-mode" />
              <v-text-field v-model="frame.eyeSize" label="Eye size" density="compact" data-testid="optical-frame-eye" />
            </div>
            <div class="d-flex ga-2">
              <v-text-field v-model.number="frame.bridge" type="number" label="Bridge" density="compact"
                data-testid="optical-frame-bridge" />
              <v-text-field v-model.number="frame.temple" type="number" label="Temple" density="compact"
                data-testid="optical-frame-temple" />
              <v-text-field v-model="frame.color" label="Color" density="compact" data-testid="optical-frame-color" />
            </div>
            <v-text-field v-model="frame.specialInstruction" label="Lab instructions" density="compact"
              data-testid="optical-frame-instructions" />
          </v-card-text>
        </v-card>
      </v-col>

      <v-col cols="12" md="6">
        <v-card variant="outlined">
          <v-card-title>
            <v-checkbox v-model="includeLens" label="Lenses" density="compact" hide-details
              data-testid="optical-include-lens" />
          </v-card-title>
          <v-card-text>
            <v-text-field v-model.number="lens.prescriptionVersionId" type="number"
              label="Spectacle version id (optional)" density="compact" data-testid="optical-lens-version" />
            <div class="d-flex ga-2">
              <v-text-field v-model.number="lens.right.sphere" type="number" label="R sphere"
                density="compact" data-testid="optical-lens-right-sphere" />
              <v-text-field v-model.number="lens.right.cylinder" type="number" label="R cyl"
                density="compact" data-testid="optical-lens-right-cylinder" />
              <v-text-field v-model.number="lens.right.axis" type="number" label="R axis"
                density="compact" data-testid="optical-lens-right-axis" />
            </div>
            <div class="d-flex ga-2">
              <v-text-field v-model.number="lens.left.sphere" type="number" label="L sphere"
                density="compact" data-testid="optical-lens-left-sphere" />
              <v-text-field v-model.number="lens.left.cylinder" type="number" label="L cyl"
                density="compact" data-testid="optical-lens-left-cylinder" />
              <v-text-field v-model.number="lens.left.axis" type="number" label="L axis"
                density="compact" data-testid="optical-lens-left-axis" />
            </div>
            <v-text-field v-model="lens.type" label="Lens type" density="compact" data-testid="optical-lens-type" />
          </v-card-text>
        </v-card>
      </v-col>
    </v-row>

    <v-card variant="outlined" class="mt-4">
      <v-card-title>
        <v-checkbox v-model="includeContact" label="Contact lenses" density="compact" hide-details
          data-testid="optical-include-contact" />
      </v-card-title>
      <v-card-text v-if="includeContact">
        <v-text-field v-model.number="contact.prescriptionVersionId" type="number"
          label="Contact version id (optional)" density="compact" data-testid="optical-contact-version" />
        <div class="d-flex ga-2">
          <v-text-field v-model.number="contact.right.sphere" type="number" label="R power"
            density="compact" data-testid="optical-contact-right-sphere" />
          <v-text-field v-model.number="contact.left.sphere" type="number" label="L power"
            density="compact" data-testid="optical-contact-left-sphere" />
        </div>
      </v-card-text>
    </v-card>

    <v-card variant="outlined" class="mt-4">
      <v-card-text>
        <v-text-field v-model="reason" label="Reason" density="compact" data-testid="optical-reason" />
        <v-btn color="primary" :loading="busy" data-testid="optical-save" @click="save">Save optical details</v-btn>
      </v-card-text>
    </v-card>

    <v-card v-if="order" variant="outlined" class="mt-4">
      <v-card-title>Fulfillment</v-card-title>
      <v-card-text>
        <div class="d-flex ga-2 align-center mb-2">
          <v-text-field v-model="statusReference" label="Lab/reference" density="compact" hide-details
            data-testid="optical-status-reference" />
          <v-text-field v-model="statusNotes" label="Notes" density="compact" hide-details
            data-testid="optical-status-notes" />
        </div>
        <v-btn size="small" data-testid="optical-status-ordered" @click="advance('ordered')">Ordered</v-btn>
        <v-btn size="small" class="ml-2" data-testid="optical-status-received" @click="advance('received')">Received</v-btn>
        <v-btn size="small" class="ml-2" data-testid="optical-status-dispensed" @click="advance('dispensed')">Dispensed</v-btn>
        <v-table density="compact" class="mt-3" data-testid="optical-events">
          <thead><tr><th>Status</th><th>Time</th><th>Reference</th></tr></thead>
          <tbody>
            <tr v-for="event in order.events" :key="event.id">
              <td>{{ event.status }}</td><td>{{ event.occurredAt.slice(0, 19) }}</td>
              <td>{{ event.reference ?? '' }}</td>
            </tr>
          </tbody>
        </v-table>
      </v-card-text>
    </v-card>
  </div>
</template>
