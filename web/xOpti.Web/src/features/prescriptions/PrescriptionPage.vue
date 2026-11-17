<script setup lang="ts">
import { computed, onMounted, reactive, ref } from 'vue'
import { useRoute } from 'vue-router'
import { api, unwrap } from '@/api/client'
import { AppError } from '@/api/problems'
import { PermissionNames } from '@/security/permissions'
import { useSessionStore } from '@/stores/session'

interface EyeValues {
  sphere: number | null; cylinder: number | null; axis: number | null
  add: number | null; prism: number | null; base: number | null; pd: number | null
}
interface VersionBase {
  id: number; versionNumber: number; source: string; issuedOn: string
  isCurrent: boolean; verifiedAt: string | null; verifiedBy: string | null
  verificationNote: string | null; reason: string; notes: string | null
}
interface SpectacleVersion extends VersionBase { right: EyeValues; left: EyeValues }
interface ContactVersion extends VersionBase {
  brand: string | null; baseCurve: number | null; diameter: number | null
  rightPower: number | null; rightCylinder: number | null; rightAxis: number | null
  leftPower: number | null; leftCylinder: number | null; leftAxis: number | null
  replacementSchedule: string | null
}
interface MedicalNote { id: number; note: string; recordedAt: string; recordedBy: string | null }
interface Attachment {
  id: number; kind: string; fileName: string; contentType: string; size: number
  uploadedAt: string; uploadedBy: string | null
}
interface History {
  customerId: number
  medical: { careCardNo: string | null; careCardType: string | null } | null
  spectacle: SpectacleVersion[]
  contact: ContactVersion[]
  medicalNotes: MedicalNote[]
  attachments: Attachment[]
}

const route = useRoute()
const sessionStore = useSessionStore()
const canEnter = computed(() => sessionStore.hasPermission(PermissionNames.PrescriptionEnter))
const customerId = ref<number | null>(null)
const history = ref<History | null>(null)
const busy = ref(false)
const error = ref<string | null>(null)
const notice = ref<string | null>(null)
const issueDate = ref(new Date().toISOString().slice(0, 10))
const prescriberId = ref(1)
const reason = ref('new prescription')
const notes = ref('')
const verificationNote = ref('checked')
const medicalNote = ref('')
const attachmentKind = ref('prescription')
const attachmentReason = ref('supporting document')
const fileInput = ref<File | null>(null)

const eye = (): EyeValues => ({ sphere: 0, cylinder: 0, axis: 0, add: null, prism: null, base: null, pd: null })
const spectacle = reactive({ right: eye(), left: eye() })
const contact = reactive({
  brand: '', baseCurve: 8.6, diameter: 14.2, rightPower: -2.5, rightCylinder: 0,
  rightAxis: 0, leftPower: -2.5, leftCylinder: 0, leftAxis: 0,
  replacementSchedule: 'monthly',
})

const currentSpectacle = computed(() => history.value?.spectacle.find((row) => row.isCurrent) ?? null)
const currentContact = computed(() => history.value?.contact.find((row) => row.isCurrent) ?? null)

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
    add: values.add === null ? null : Number(values.add),
    prism: values.prism === null ? null : Number(values.prism),
    base: values.base === null ? null : Number(values.base),
    pd: values.pd === null ? null : Number(values.pd),
  }
}

function loadVersion(version: SpectacleVersion): void {
  Object.assign(spectacle.right, version.right)
  Object.assign(spectacle.left, version.left)
  issueDate.value = version.issuedOn.slice(0, 10)
  reason.value = 'amended prescription'
}

async function load(): Promise<void> {
  if (!customerId.value) return
  busy.value = true
  error.value = null
  try {
    history.value = await unwrap(await api.client.GET('/api/v1/customers/{customerId}/prescriptions', {
      params: { path: { customerId: customerId.value } },
    })) as unknown as History
    if (currentSpectacle.value) loadVersion(currentSpectacle.value)
  } catch (caught) { handleError(caught) } finally { busy.value = false }
}

async function saveSpectacle(): Promise<void> {
  if (!customerId.value) return
  busy.value = true
  error.value = null
  try {
    history.value = await unwrap(await api.client.POST('/api/v1/customers/{customerId}/prescriptions/spectacle', {
      params: { path: { customerId: customerId.value } },
      body: {
        issuedOn: `${issueDate.value}T00:00:00Z`, prescriberId: Number(prescriberId.value),
        right: payloadEye(spectacle.right), left: payloadEye(spectacle.left),
        notes: notes.value, reason: reason.value,
      },
    })) as unknown as History
    notice.value = 'Spectacle prescription saved as a new immutable version.'
    if (currentSpectacle.value) loadVersion(currentSpectacle.value)
  } catch (caught) { handleError(caught) } finally { busy.value = false }
}

async function saveContact(): Promise<void> {
  if (!customerId.value) return
  busy.value = true
  error.value = null
  try {
    history.value = await unwrap(await api.client.POST('/api/v1/customers/{customerId}/prescriptions/contact', {
      params: { path: { customerId: customerId.value } },
      body: {
        issuedOn: `${issueDate.value}T00:00:00Z`, prescriberId: Number(prescriberId.value),
        brand: contact.brand || null, baseCurve: Number(contact.baseCurve),
        diameter: Number(contact.diameter), rightPower: Number(contact.rightPower),
        rightCylinder: Number(contact.rightCylinder), rightAxis: Number(contact.rightAxis),
        leftPower: Number(contact.leftPower), leftCylinder: Number(contact.leftCylinder),
        leftAxis: Number(contact.leftAxis),
        replacementSchedule: contact.replacementSchedule || null,
        notes: notes.value, reason: reason.value,
      },
    })) as unknown as History
    notice.value = 'Contact-lens prescription saved as a new immutable version.'
  } catch (caught) { handleError(caught) } finally { busy.value = false }
}

async function verify(type: 'spectacle' | 'contact', version: VersionBase | null): Promise<void> {
  if (!customerId.value || !version || version.source !== 'app') return
  busy.value = true
  error.value = null
  try {
    history.value = await unwrap(await api.client.POST('/api/v1/customers/{customerId}/prescriptions/verify', {
      params: { path: { customerId: customerId.value } },
      body: { type, versionId: version.id, note: verificationNote.value, reason: 'verified' },
    })) as unknown as History
    notice.value = 'Prescription verified.'
  } catch (caught) { handleError(caught) } finally { busy.value = false }
}

async function addMedicalNote(): Promise<void> {
  if (!customerId.value || !medicalNote.value.trim()) return
  busy.value = true
  error.value = null
  try {
    history.value = await unwrap(await api.client.POST('/api/v1/customers/{customerId}/medical-notes', {
      params: { path: { customerId: customerId.value } },
      body: { note: medicalNote.value, reason: 'medical history' },
    })) as unknown as History
    medicalNote.value = ''
  } catch (caught) { handleError(caught) } finally { busy.value = false }
}

async function uploadAttachment(): Promise<void> {
  if (!customerId.value || !fileInput.value) return
  busy.value = true
  error.value = null
  try {
    const form = new FormData()
    form.append('file', fileInput.value)
    form.append('kind', attachmentKind.value)
    form.append('reason', attachmentReason.value)
    const response = await api.request(`/api/v1/customers/${customerId.value}/attachments`, {
      method: 'POST', body: form,
    })
    if (!response.ok) throw new AppError({ kind: 'validation', status: response.status, correlationId: null })
    history.value = await response.json() as History
    notice.value = 'Attachment stored under the patient namespace.'
    fileInput.value = null
  } catch (caught) { handleError(caught) } finally { busy.value = false }
}

function onFile(event: Event): void {
  const input = event.target as HTMLInputElement
  fileInput.value = input.files?.[0] ?? null
}

async function openAttachment(id: number): Promise<void> {
  const response = await api.request(`/api/v1/customers/attachments/${id}`, { method: 'GET' })
  if (!response.ok) { error.value = 'Attachment could not be opened.'; return }
  const blob = await response.blob()
  const url = URL.createObjectURL(blob)
  window.open(url, '_blank')
}

onMounted(() => {
  const id = route.query.customerId
  if (typeof id === 'string' && id.length > 0) {
    customerId.value = Number(id)
    load()
  }
})
</script>

<template>
  <div data-testid="prescription-page">
    <h1 class="text-h5 mb-4">Prescriptions</h1>
    <v-alert v-if="error" type="error" variant="tonal" class="mb-4" data-testid="rx-error">{{ error }}</v-alert>
    <v-alert v-if="notice" type="success" variant="tonal" class="mb-4" data-testid="rx-notice">{{ notice }}</v-alert>

    <v-card variant="outlined" class="mb-4">
      <v-card-text>
        <div class="d-flex ga-2 align-center">
          <v-text-field v-model.number="customerId" type="number" label="Customer id" density="compact"
            hide-details style="max-width: 180px" data-testid="rx-customer" />
          <v-btn color="primary" :loading="busy" data-testid="rx-load" @click="load">Load</v-btn>
        </div>
      </v-card-text>
    </v-card>

    <template v-if="history">
      <v-row>
        <v-col cols="12" md="6">
          <v-card variant="outlined">
            <v-card-title>Spectacle prescription</v-card-title>
            <v-card-text>
              <p class="text-body-2" data-testid="rx-spectacle-current">
                Current:
                <span v-if="currentSpectacle">
                  v{{ currentSpectacle.versionNumber }} · {{ currentSpectacle.source }}
                  · {{ currentSpectacle.verifiedAt ? 'verified' : 'unverified' }}
                </span>
                <span v-else>none</span>
              </p>
              <v-row dense>
                <v-col cols="12"><strong>Right eye</strong></v-col>
                <v-col cols="4"><v-text-field v-model.number="spectacle.right.sphere" type="number"
                  label="Sphere" density="compact" data-testid="rx-right-sphere" /></v-col>
                <v-col cols="4"><v-text-field v-model.number="spectacle.right.cylinder" type="number"
                  label="Cylinder" density="compact" data-testid="rx-right-cylinder" /></v-col>
                <v-col cols="4"><v-text-field v-model.number="spectacle.right.axis" type="number"
                  label="Axis" density="compact" data-testid="rx-right-axis" /></v-col>
                <v-col cols="12"><strong>Left eye</strong></v-col>
                <v-col cols="4"><v-text-field v-model.number="spectacle.left.sphere" type="number"
                  label="Sphere" density="compact" data-testid="rx-left-sphere" /></v-col>
                <v-col cols="4"><v-text-field v-model.number="spectacle.left.cylinder" type="number"
                  label="Cylinder" density="compact" data-testid="rx-left-cylinder" /></v-col>
                <v-col cols="4"><v-text-field v-model.number="spectacle.left.axis" type="number"
                  label="Axis" density="compact" data-testid="rx-left-axis" /></v-col>
                <v-col cols="4"><v-text-field v-model="issueDate" type="date" label="Issued"
                  density="compact" data-testid="rx-issued" /></v-col>
                <v-col cols="4"><v-text-field v-model.number="prescriberId" type="number"
                  label="Prescriber id" density="compact" data-testid="rx-prescriber" /></v-col>
                <v-col cols="4"><v-text-field v-model="reason" label="Reason" density="compact"
                  data-testid="rx-reason" /></v-col>
              </v-row>
              <v-btn color="primary" class="mt-2" :loading="busy" :disabled="!canEnter"
                data-testid="rx-spectacle-save" @click="saveSpectacle">Save spectacle version</v-btn>
              <v-btn class="ml-2" variant="text" :disabled="!canEnter || !currentSpectacle"
                data-testid="rx-spectacle-verify"
                @click="verify('spectacle', currentSpectacle)">Verify current</v-btn>
            </v-card-text>
          </v-card>
        </v-col>

        <v-col cols="12" md="6">
          <v-card variant="outlined">
            <v-card-title>Contact-lens prescription</v-card-title>
            <v-card-text>
              <p class="text-body-2" data-testid="rx-contact-current">
                Current:
                <span v-if="currentContact">
                  v{{ currentContact.versionNumber }} · {{ currentContact.source }}
                  · {{ currentContact.verifiedAt ? 'verified' : 'unverified' }}
                </span>
                <span v-else>none</span>
              </p>
              <v-text-field v-model="contact.brand" label="Brand" density="compact" data-testid="rx-contact-brand" />
              <div class="d-flex ga-2">
                <v-text-field v-model.number="contact.baseCurve" type="number" label="Base curve"
                  density="compact" data-testid="rx-contact-base" />
                <v-text-field v-model.number="contact.diameter" type="number" label="Diameter"
                  density="compact" data-testid="rx-contact-diameter" />
              </div>
              <div class="d-flex ga-2">
                <v-text-field v-model.number="contact.rightPower" type="number" label="R power"
                  density="compact" data-testid="rx-contact-right-power" />
                <v-text-field v-model.number="contact.leftPower" type="number" label="L power"
                  density="compact" data-testid="rx-contact-left-power" />
              </div>
              <v-text-field v-model="contact.replacementSchedule" label="Replacement schedule"
                density="compact" data-testid="rx-contact-replacement" />
              <v-btn color="primary" class="mt-2" :loading="busy" :disabled="!canEnter"
                data-testid="rx-contact-save" @click="saveContact">Save contact version</v-btn>
              <v-btn class="ml-2" variant="text" :disabled="!canEnter || !currentContact"
                data-testid="rx-contact-verify"
                @click="verify('contact', currentContact)">Verify current</v-btn>
            </v-card-text>
          </v-card>
        </v-col>
      </v-row>

      <v-row class="mt-2">
        <v-col cols="12" md="6">
          <v-card variant="outlined">
            <v-card-title>History</v-card-title>
            <v-card-text>
              <v-table density="compact" data-testid="rx-history">
                <thead><tr><th>Type</th><th>Version</th><th>Source</th><th>Verified</th><th /></tr></thead>
                <tbody>
                  <tr v-for="row in [...history.spectacle.map((v) => ({ ...v, type: 'spectacle' })),
                    ...history.contact.map((v) => ({ ...v, type: 'contact' }))]"
                    :key="`${row.type}-${row.id}`">
                    <td>{{ row.type }}</td><td>{{ row.versionNumber }}</td><td>{{ row.source }}</td>
                    <td>{{ row.verifiedAt ? 'yes' : 'no' }}</td>
                    <td>{{ row.isCurrent ? 'current' : '' }}</td>
                  </tr>
                </tbody>
              </v-table>
            </v-card-text>
          </v-card>
        </v-col>

        <v-col cols="12" md="6">
          <v-card variant="outlined">
            <v-card-title>Medical history and attachments</v-card-title>
            <v-card-text>
              <p v-if="history.medical" class="text-body-2">
                Care card {{ history.medical.careCardNo ?? '—' }} · {{ history.medical.careCardType ?? '' }}
              </p>
              <v-table v-if="history.medicalNotes.length" density="compact" data-testid="rx-medical-notes">
                <tbody><tr v-for="note in history.medicalNotes" :key="note.id">
                  <td>{{ note.recordedAt.slice(0, 10) }}</td><td>{{ note.note }}</td>
                </tr></tbody>
              </v-table>
              <div class="d-flex ga-2 mt-2">
                <v-text-field v-model="medicalNote" label="Medical note" density="compact" hide-details
                  data-testid="rx-medical-note" />
                <v-btn :disabled="!canEnter" data-testid="rx-medical-note-add" @click="addMedicalNote">Add</v-btn>
              </div>
              <v-divider class="my-3" />
              <div data-testid="rx-attachment">
                <input type="file" accept=".pdf,.jpg,.jpeg,.png" @change="onFile" />
              </div>
              <v-text-field v-model="attachmentReason" label="Reason" density="compact"
                data-testid="rx-attachment-reason" />
              <v-btn :disabled="!canEnter || !fileInput" data-testid="rx-attachment-upload"
                @click="uploadAttachment">Upload</v-btn>
              <v-table v-if="history.attachments.length" density="compact" class="mt-2"
                data-testid="rx-attachments">
                <tbody><tr v-for="file in history.attachments" :key="file.id">
                  <td>{{ file.fileName }}</td>
                  <td><v-btn size="small" variant="text" @click="openAttachment(file.id)">Open</v-btn></td>
                </tr></tbody>
              </v-table>
            </v-card-text>
          </v-card>
        </v-col>
      </v-row>
    </template>
  </div>
</template>
